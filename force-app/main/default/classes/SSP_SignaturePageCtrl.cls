/*
* classname 		: SSP_SignaturePageCtrl
* @description 		: This is the Controller class for Signature Page.
* @author 			: Sai Kiran.
* @date 			: 02/06/2019.
* MODIFICATION LOG	:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
public class SSP_SignaturePageCtrl {
    
        /*
* method 		: fetchResponseData
* @description  : This method is used to fetch Application Obj with Application ID.
* @author 		: Sai Kiran Velpula.
* @param 		: sApplicationID - String
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse fetchResponseData(String sApplicationId){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        SSP_SignaturePageWrapper objWrapper = new SSP_SignaturePageWrapper();
        Map<String,SSP_Relationship__c> mapMemberRelation = new Map<String,SSP_Relationship__c>();
        Map<String,boolean> mapIsMemberHousehold = new Map<String,boolean>();
        SSP_Application__c objApplication;
        Set<String> lstMemberIDs = new Set<String>();
        List<SSP_Member__c> lstMember = new List<SSP_Member__c>();
        Boolean bIsNonMagi = false;
        String sHouseHoldSpouseName;
        String sMemberId;
        String sPrimaryApplicantFirstName;
        String sPrimaryApplicantLastName;
        String sPrimaryApplicantMiddleName;
        String sPrimaryApplicantSuffix;
        Date timeTravelTodayDate;
        Boolean bShowLTCsection = false;
        List<SSP_Relationship__c> lstRelationShip = new List<SSP_Relationship__c>();
        try{
            SSP_Utility.isAuthenticatedUser();
        objApplication = SSP_SignaturePageService.fetchApplication(sApplicationId);
        updateAgencyId(objApplication.Account__c);
        
        if(objApplication != NULL ){
            for(SSP_ApplicationIndividual__c objApplicationIndividual : objApplication.SSP_ApplicationIndividuals__r){
                lstMemberIDs.add(objApplicationIndividual.SSP_Member__c);
                if(objApplicationIndividual.IsHeadOfHousehold__c){
                    sMemberId = objApplicationIndividual.SSP_Member__c;
                    sPrimaryApplicantFirstName = objApplicationIndividual.SSP_Member__r.FirstName__c;
                    sPrimaryApplicantLastName = objApplicationIndividual.SSP_Member__r.LastName__c;
                    sPrimaryApplicantMiddleName = objApplicationIndividual.SSP_Member__r.MiddleInitial__c;
                    sPrimaryApplicantSuffix = objApplicationIndividual.SSP_Member__r.SuffixCode__c; 
                }
                if(objApplicationIndividual.MedicaidType__c == 'Non-MAGI'){
                    bIsNonMagi = true;
                }
            }
        }
        
        if(lstMemberIDs.size() > 0){
            lstRelationShip = SSP_SignaturePageService.fetchRelationShip(lstMemberIDs);
        }
            if(objApplication != NULL && objApplication.SSP_ApplicationIndividuals__r != NULL && !objApplication.SSP_ApplicationIndividuals__r.IsEmpty()){
                for(SSP_ApplicationIndividual__c objInd : objApplication.SSP_ApplicationIndividuals__r){
                    mapIsMemberHousehold.put(objInd.SSP_Member__c, objInd.IsHeadOfHousehold__c);
                }
            }
            if(lstRelationShip.size() > 0){
                for(SSP_Relationship__c objRelationship : lstRelationShip){
                    if(mapIsMemberHousehold != NULL){
                        if(mapIsMemberHousehold.get(objRelationship.SSP_MemberRelatedTo__c) == true && (objRelationship.SSP_MemberRelatedTo__r.LaTypeCode__c == 'HS' || objRelationship.SSP_MemberRelatedTo__r.LaTypeCode__c == 'LTC')
                           && objRelationship.RelationshipType__c == 'SP' && objRelationship.SSP_Member__r.LaTypeCode__c != 'HS'){
                               bShowLTCsection = true;
                               sHouseHoldSpouseName= (objRelationship.SSP_Member__r.FirstName__c != NULL ? objRelationship.SSP_Member__r.FirstName__c :'')+
                                   (objRelationship.SSP_Member__r.MiddleInitial__c != NULL ? +' '+objRelationship.SSP_Member__r.MiddleInitial__c :'')+
                                   (objRelationship.SSP_Member__r.LastName__c != NULL ? +' '+objRelationship.SSP_Member__r.LastName__c :'')+
                                   (objRelationship.SSP_Member__r.SuffixCode__c != NULL ? +' '+objRelationship.SSP_Member__r.SuffixCode__c :''); 
                               break;                                                                            
                           }else if((objRelationship.SSP_MemberRelatedTo__r.LaTypeCode__c == 'HS' || objRelationship.SSP_MemberRelatedTo__r.LaTypeCode__c == 'LTC')
                                    && objRelationship.RelationshipType__c == 'SP' && objRelationship.SSP_Member__r.LaTypeCode__c != 'HS'){
                                        bShowLTCsection = true;
                                        sHouseHoldSpouseName= (objRelationship.SSP_Member__r.FirstName__c != NULL ? objRelationship.SSP_Member__r.FirstName__c :'')+
                                            (objRelationship.SSP_Member__r.MiddleInitial__c != NULL ? +' '+objRelationship.SSP_Member__r.MiddleInitial__c :'')+
                                            (objRelationship.SSP_Member__r.LastName__c != NULL ? +' '+objRelationship.SSP_Member__r.LastName__c :'')+
                                            (objRelationship.SSP_Member__r.SuffixCode__c != NULL ? +' '+objRelationship.SSP_Member__r.SuffixCode__c :''); 
                                        break;
                                    }
                    }
                }
            }
            updateNonPrimaryInd(sApplicationId);
            timeTravelTodayDate = SSP_Utility.today();
            objWrapper.bIsNonMagi = bIsNonMagi;
            objWrapper.bShowLTCSection = bShowLTCSection;
            objWrapper.sHouseHoldSpouseName = sHouseHoldSpouseName;
            objWrapper.sPrimaryApplicantFirstName = sPrimaryApplicantFirstName;
            objWrapper.sPrimaryApplicantLastName = sPrimaryApplicantLastName;
            objWrapper.sPrimaryApplicantMiddleName = sPrimaryApplicantMiddleName;
            objWrapper.sPrimaryApplicantSuffix = sPrimaryApplicantSuffix;
            
            objResponse.put('objWrapper', objWrapper);
            objResponse.put('timeTravelTodayDate', timeTravelTodayDate);
            objResponse.bIsSuccess = true;
            
            /** 2.5	Security Role Matrix and Program Access. */
            objResponse.put(SSP_GlobalConstants.APP_AGREEMENT, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.APP_AGREEMENT_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.MEDICAID_PENALTY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.MEDICAID_PENALTY_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SNAP_INFO_RULES, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.SNAP_INFO_RULES_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.LTC_RESOURCE_TRANSFER, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.LTC_RESOURCE_TRANSFER_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.DECLARATION_ANNUITIES, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.DECLARATION_ANNUITIES_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.KIHIPP_CONSENT, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.KIHIPP_CONSENT_SCREENID, null));
            /** */
            updateDataForExpediteSNAPPage(sApplicationId);
            objResponse.put('selectedRole',SSP_Utility.getSelectedRole()); //Added this as a part of Defect - 377050
        }catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'fetchResponseData', ex.getMessage() , true);
                objResponse.bIsSuccess = false;
            }
        return objResponse;
    }

    private static void updateAgencyId(String accountId){
        try{
            Decimal agencyId , dcContactId;
            String tempRoleName;
            String roleName = SSP_Utility.getSelectedRole();  
            List<String> fieldsToUpdate = new List<String>{'roles'}; 
            User u = SSP_Utility.getCurrentUserDetails()[0];     
            if(String.isNotBlank(accountId) && String.isNotBlank(roleName) && !roleName.equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE)){
                tempRoleName = roleName;
                if(roleName.contains(SSP_GlobalConstants.AGENCY_ADMIN)){
                    roleName = SSP_GlobalConstants.ASSISTER;
                }                
                for(AccountContactRelation acr : [SELECT Id, Account.DCDataId__c, DCAgencyId__c , DCContactId__c FROM AccountContactRelation  WHERE Roles INCLUDES (:roleName) AND Account.RecordTypeId =  :SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Resource_Engine') AND ContactId = :u.ContactId LIMIT 1]){
                   agencyId =  acr.Account.DCDataId__c;
                   dcContactId = acr.DCContactId__c;
                }
                roleName = tempRoleName;
                    
                AccountContactRelation acrToUpdate = new AccountContactRelation();
                for(AccountContactRelation acr : 
                        SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                new Set<String>{'Id'}, 
                                new Map<String, String>{'limit'=>'1','ContactId'=> u.ContactId, 'AccountId' => accountId})){                                        
                                    acrToUpdate.Id = acr.Id;
                                    acrToUpdate.roles = roleName;
                                    if(agencyId != null){
                                        acrToUpdate.DCAgencyId__c = agencyId;
                                        fieldsToUpdate.add('DCAgencyId__c');
                                    }if(dcContactId != null){
				    	acrToUpdate.DCContactId__c = dcContactId;
                                        fieldsToUpdate.add('DCContactId__c');
				    }
                                }
                
                if(acrToUpdate != null && acrToUpdate.Id != null){
                    ESAPI.accessController().updateAsUser(acrToUpdate, fieldsToUpdate);
                }
                
            }
        }
        catch(Exception ex){

        }
    }
    
  
    public static void updateDataForExpediteSNAPPage(String sApplicationId){
        List<Id> memberIds = new list<id>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000'};
        Decimal totalLiquidAmount=0, totalMontlyIncome=0 , totalShelterExpense=0;
        Set<String> appFieldList = new Set<String>{'HouseholdTotalMonthlyCashSavingAmount__c','IsDestituteFarmOrMigrantHouseholdToggle__c','HouseholdTotalMonthlyGrossIncAmount__c','HasShelterExpExceedIncomeResourcesToggle__c','ProgramsApplied__c'};
        
        try{    
        List<SSP_Application__c> expediteRecords =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND'}, 
                                                                                appFieldList, 
                                                                                new Map<String, String>{'limit'=>'1','Id'=>sApplicationId});
            
            
            
       if(expediteRecords[0].ProgramsApplied__c!=null && expediteRecords[0].ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP) && expediteRecords[0].HouseholdTotalMonthlyCashSavingAmount__c==null && expediteRecords[0].IsDestituteFarmOrMigrantHouseholdToggle__c==null && expediteRecords[0].HouseholdTotalMonthlyGrossIncAmount__c==null && expediteRecords[0].HasShelterExpExceedIncomeResourcesToggle__c==null ){     
           
        List<SSP_ApplicationIndividual__c> lstAppIndividuals =  SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','MemberStatus__c' => '!='}, 
                                                                                                                         new Set<String>{'Id','SSP_Member__c', 'SSP_Application__c', 'IsHeadOfHousehold__c','MemberStatus__c'},
                                                                                                                         new Map<String, String>{'limit'=>'100','SSP_Application__c'=> sApplicationId, 'MemberStatus__c'=> 'Removed'});
        for(SSP_ApplicationIndividual__c objAppIndiv : lstAppIndividuals){
            memberIds.add(objAppIndiv.SSP_Member__c);
       }
        conditionMap.put('SSP_Member__c',String.join(memberIds,','));
        
        
        List<SSP_Asset__c> assets = SSP_AssetSelector.queryAssetData(new Map<String, String>{'objectName'=>'SSP_Asset__c','IN'=>'SSP_Member__c','operator'=>'AND'}, 
                                                                    new Set<String>{'Id','ExpenseTypeCode__c','ExpenseAmount__c','IncomePayFrequency__c','TotalGrossAmount__c', 'AccountBalance__c', 'RecordType.DeveloperName','ResourceSubTypeCode__c','IncomeTypeCode__c'}, 
                                                                     new Map<String, String>{'limit'=>'1000', 'SSP_Member__c'=>String.join(new List<Id>(memberIds), ',') , 'IsDeleted__c'=>'false'});
            
        List<SSP_Member__c> lstMembers =  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                                              new Set<String>{'Id','IsMigrantOrSeasonalFarmWorkerToggle__c'}, 
                                                                              new Map<String, String>{'Id'=> String.join(new List<Id>(memberIds), ',')});
        
        for(SSP_Member__c memRec:lstMembers){
            if(memRec.IsMigrantOrSeasonalFarmWorkerToggle__c!=null ){
                expediteRecords[0].IsDestituteFarmOrMigrantHouseholdToggle__c=expediteRecords[0].IsDestituteFarmOrMigrantHouseholdToggle__c==null?memRec.IsMigrantOrSeasonalFarmWorkerToggle__c:expediteRecords[0].IsDestituteFarmOrMigrantHouseholdToggle__c==SSP_GlobalConstants.NO?memRec.IsMigrantOrSeasonalFarmWorkerToggle__c:SSP_GlobalConstants.YES;
            }            
        }
        for(SSP_Asset__c asset : assets){
            if(asset.RecordType.DeveloperName==SSP_GlobalConstants.RESOURCERECORDTYPENAME && asset.ResourceSubTypeCode__c!=null && SSP_GlobalConstants.LIQUID_RESOURCE_TYPE_ESNAP.contains(asset.ResourceSubTypeCode__c)){
                totalLiquidAmount = totalLiquidAmount + asset.AccountBalance__c;
            }
            if(asset.IncomeTypeCode__c!=null && asset.IncomePayFrequency__c!=null && asset.TotalGrossAmount__c!=null && asset.TotalGrossAmount__c!=0 ){
                if(asset.IncomePayFrequency__c==SSP_GlobalConstants.Monthly){
                    totalMontlyIncome = totalMontlyIncome+asset.TotalGrossAmount__c;   }  
                
                else if(asset.IncomePayFrequency__c==SSP_GlobalConstants.BI_Weekly ){
                    totalMontlyIncome = totalMontlyIncome+ asset.TotalGrossAmount__c*2; }
                
                else if (asset.IncomePayFrequency__c==SSP_GlobalConstants.TWICEAMONTH){
                    totalMontlyIncome = totalMontlyIncome+ asset.TotalGrossAmount__c/2; }
                
                else if(asset.IncomePayFrequency__c==SSP_GlobalConstants.Week){
                    totalMontlyIncome =totalMontlyIncome+ asset.TotalGrossAmount__c*4;  }
                
                else if (asset.IncomePayFrequency__c==SSP_GlobalConstants.Yearly ){
                    totalMontlyIncome =totalMontlyIncome+asset.TotalGrossAmount__c/12;  }
                
                else if (asset.IncomePayFrequency__c==SSP_GlobalConstants.Quarterly ){
                    totalMontlyIncome =totalMontlyIncome+asset.TotalGrossAmount__c/3;  }
            }
            
            if(asset.RecordType.DeveloperName==SSP_GlobalConstants.EXPENSERECORDTYPENAME  && asset.ExpenseTypeCode__c==SSP_GlobalConstants.SHELTER_EXPENSE_TYPE && asset.ExpenseAmount__c!=null){
                totalShelterExpense = totalShelterExpense +asset.ExpenseAmount__c;
            }
        }
            
        expediteRecords[0].HasShelterExpExceedIncomeResourcesToggle__c= totalShelterExpense>totalLiquidAmount+totalMontlyIncome? SSP_GlobalConstants.YES:SSP_GlobalConstants.NO;
        expediteRecords[0].HouseholdTotalMonthlyGrossIncAmount__c = totalMontlyIncome;
        expediteRecords[0].HouseholdTotalMonthlyCashSavingAmount__c= totalLiquidAmount;        
        update expediteRecords;
        }
        }
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'updateDataForExpediteSNAPPage', ex.getMessage() , true);
        }
    }
    
    @AuraEnabled 
    public static SSP_LightningResponse fetchCustomSettings(){
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<AppConfig__c> lstAppConfig = new List<AppConfig__c>();
        lstAppConfig = SSP_SignaturePageService.fetchCustomSettings();
        for(AppConfig__c objAppConfig : lstAppConfig){
            response.put(objAppConfig.Name,objAppConfig.Value__c);
        }
        
        /** 2.5	Security Role Matrix and Program Access. */
        response.put(SSP_GlobalConstants.ELIGIBILITY_RESULTS_LOADING, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.ELIGIBILITY_RESULTS_LOADING_SCREENID, null));
        /** */
        return response;
    }
    @AuraEnabled 
    public static SSP_LightningResponse fetchApplicationStatus(Id sApplicationId){
        
        SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_Utility.isAuthenticatedUser();
        response = SSP_SignaturePageService.fetchApplicationStatus(sApplicationId);
        return response;
    }
/* ------------------------------Start----------------------*/

public static List<NavFlowStatus__c> getNavFlowStatusList(String sapplicationId){
        Map<String,String> mapConditions = new Map<String,String>();
        List<NavFlowStatus__c> navFlowStatusList = new List<NavFlowStatus__c>();
        mapConditions.clear();
        mapConditions.put('SSPApplication__c',sapplicationId);
        navFlowStatusList = SSP_NavFlowStatusSelector.queryFlowStatus(new Map<String, String>{'objectName'=>'NavFlowStatus__c'},
                                                                      new Set<String>{'Id','Name','Contact__r.Name','FlowPageStatus__c','FlowDupStatus__c','NavFlowName__c','RecordId__c','SSPApplication__c','InitiatedUser__c'},
                                                                      mapConditions);
        
        /*[SELECT Id, Name, Contact__r.Name, FlowPageStatus__c, NavFlowName__c, RecordId__c, SSPApplication__c, InitiatedUser__c
FROM NavFlowStatus__c
WHERE SSPApplication__c = :applicationId];*/
        return navFlowStatusList;
    }
    
   /* public static List<NavFlowDetail__mdt> getNavFlowDetailList(Set<String> lstFlowNames){
        Map<String,String> mapConditions = new Map<String,String>();
        List<NavFlowDetail__mdt> navFlowStatusList = new List<NavFlowDetail__mdt>();
        //try{
        navFlowStatusList = [SELECT ID, FlowName__c, (SELECT ID,SequenceNumber__c,PageInfo__r.PageName__c FROM Navigation_Flow_Page_Configuration__r LIMIT 5000) 
                             FROM NavFlowDetail__mdt WHERE FlowName__c =: lstFlowNames
                             LIMIT 5000];
        /*}catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowResume', 'getNavFlowDetailList', ex.getMessage() , true);
}
        return navFlowStatusList;
    }*/
    
    /*public static List<NavFlowChildScreen__mdt> getNavFlowChildScreenList(Set<String> lstNavFlowConfigIds){
        Map<String,String> mapConditions = new Map<String,String>();
        List<NavFlowChildScreen__mdt> navFlowChildScreenList = new List<NavFlowChildScreen__mdt>();
        //try{
        navFlowChildScreenList = [SELECT ID, FlowName__c,ParentScreen__c FROM NavFlowChildScreen__mdt WHERE ParentScreen__c =: lstNavFlowConfigIds];
        }catch(Exception ex){
List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'NavFlowResume', 'getNavFlowDetailList', ex.getMessage() , true);
}
        return navFlowChildScreenList;
    }*/
    
    /*public static Set<String> getSelectedScreenNames(String sApplicationId){
Set<String> lstSelectedScreenNames = new Set<String>();
Set<String> lstFlowNames = new Set<String>();
Set<String> lstNavFlowConfigIds = new Set<String>();
List<NavFlowStatus__c> navFlowStatusList = new List<NavFlowStatus__c>();
List<NavFlowDetail__mdt> navFlowDetailList = new List<NavFlowDetail__mdt>();
List<NavFlowPageConfig__mdt> lstNavFlowConfig = new List<NavFlowPageConfig__mdt>();
List<NavFlowChildScreen__mdt> lstNavFlowChildScreen = new List<NavFlowChildScreen__mdt>();
Map<String, List<NavFlowPageConfig__mdt>> mapNavFlowDetail = new Map<String, List<NavFlowPageConfig__mdt>>(); 

navFlowStatusList = getNavFlowStatusList(sApplicationId);

if(navFlowStatusList.size() > 0){
for(NavFlowStatus__c objNavFlowStatus : navFlowStatusList){
lstFlowNames.add(objNavFlowStatus.NavFlowName__c);
}
}

if(lstFlowNames.size() > 0){
navFlowDetailList = getNavFlowDetailList(lstFlowNames);
}

if(navFlowDetailList.size() > 0){
for(NavFlowDetail__mdt objNavFlowDetail : navFlowDetailList){
mapNavFlowDetail.put(objNavFlowDetail.FlowName__c, objNavFlowDetail.Navigation_Flow_Page_Configuration__r);
for(NavFlowPageConfig__mdt navFlowConfig : objNavFlowDetail.Navigation_Flow_Page_Configuration__r){
lstNavFlowConfigIds.add(navFlowConfig.Id);
}
}
}

if(lstNavFlowConfigIds.size() > 0){
lstNavFlowChildScreen = getNavFlowChildScreenList(lstNavFlowConfigIds);
}

if(lstNavFlowChildScreen.size() > 0){
for(NavFlowChildScreen__mdt objChildScreen : lstNavFlowChildScreen){

}
}


if(navFlowStatusList.size() > 0){
for(Integer i = 0; i < navFlowStatusList.size(); i++){
lstNavFlowConfig = mapNavFlowDetail.get(navFlowStatusList[i].NavFlowName__c);


//
for(integer j=0; j < lstNavFlowConfig.size(); j=j+1){



if(navFlowStatusList[i].FlowDupStatus__c.charAt((lstNavFlowConfig[j].SequenceNumber__c).intValue()-1) == 67){
lstSelectedScreenNames.add(lstNavFlowConfig[j].PageInfo__r.PageName__c);
for(Integer k=0; k<lstNavFlowChildScreen.size(); k++){

}

}
}
}
}
return lstSelectedScreenNames;
}*/
    
    public static Set<String> getSelectedScreenNames(String sApplicationId, String sMode){
        Set<String> lstSelectedScreenNames = new Set<String>();
        Set<String> lstFlowNames = new Set<String>();
        List<NavFlowStatus__c> navFlowStatusList = new List<NavFlowStatus__c>();
        List<NavFlowPageConfig__mdt> lstNavFlowConfig = new List<NavFlowPageConfig__mdt>();
        List<NavFlowChildScreen__mdt> lstNavFlowChildScreen = new List<NavFlowChildScreen__mdt>();
        Map<String, List<NavFlowChildScreen__mdt>> mapChildScreens = new Map<String, List<NavFlowChildScreen__mdt>>();
        Map<String,String> mapConditions = new Map<String,String>();
        List<SSP_Application__c> lstApps = new List<SSP_Application__c>();
        SSP_Application__c objApp;
        List<String> lstApplicationFields = new List<String>{'SectionStatus__c','ProgramsApplied__c','IsApplicantAuthorizedRepresentative__c'};
        String sSectionStatus;
        navFlowStatusList = getNavFlowStatusList(sApplicationId);
        
        if(navFlowStatusList.size() > 0){
            for(NavFlowStatus__c objNavFlowStatus : navFlowStatusList){
                lstFlowNames.add(objNavFlowStatus.NavFlowName__c);
            }
        }
        
        lstNavFlowConfig = [SELECT ID,SequenceNumber__c,PageInfo__r.PageName__c,NavigationFlowDetail__r.FlowName__c,
                            (SELECT ID,FlowName__c, ParentScreen__c, PageName__c From Navigation_Flow_Child_Screens__r LIMIT 5000) 
                            FROM NavFlowPageConfig__mdt WHERE NavigationFlowDetail__r.FlowName__c =: lstFlowNames AND IsActive__c = true LIMIT 5000];
        for(NavFlowPageConfig__mdt objNavFlowConfig : lstNavFlowConfig){
            mapChildScreens.put(objNavFlowConfig.Id, objNavFlowConfig.Navigation_Flow_Child_Screens__r);
        }
        
        for(Integer i=0; i<navFlowStatusList.size(); i++){
            for(Integer j=0; j<lstNavFlowConfig.size(); j++){
                if((navFlowStatusList[i].NavFlowName__c == lstNavFlowConfig[j].NavigationFlowDetail__r.FlowName__c) && (navFlowStatusList[i].FlowDupStatus__c.charAt((lstNavFlowConfig[j].SequenceNumber__c).intValue()-1) == 67) ){
                    lstSelectedScreenNames.add(lstNavFlowConfig[j].PageInfo__r.PageName__c);
                    lstNavFlowChildScreen = mapChildScreens.get(lstNavFlowConfig[j].Id);
                    for(NavFlowChildScreen__mdt objNavFlowChild : lstNavFlowChildScreen){
                        lstSelectedScreenNames.add(objNavFlowChild.PageName__c);
                    }
                }
            }
        }
        lstSelectedScreenNames.add('NA');
        lstSelectedScreenNames.add('SSP_APP_Signature');
        lstSelectedScreenNames.add('SSP_APP_Agree_DeclarationAnnuities');
        lstSelectedScreenNames.add('SSP_APP_Agree_LTCResourceTransfer');
        lstSelectedScreenNames.add('SSP_APP_Agree_MedicaidPenalty');
        lstSelectedScreenNames.add('REPS_AddAuthorizedRepresentative1');
        lstSelectedScreenNames.add('REPS_AuthorizedRepConsent');
        lstSelectedScreenNames.add('Add Authorized Representative - Permissions');
        mapConditions.put('ID',sApplicationID);
        mapConditions.put('limit','1');        
        Boolean bViewApplicationFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), lstApplicationFields);
        if(bViewApplicationFields){
            lstApps = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                   new Set<String>{'ID','SectionStatus__c','ProgramsApplied__c','IsApplicantAuthorizedRepresentative__c'}, 
                                                                   mapConditions);
        }
        if(!lstApps.isEmpty()){
            objApp = lstApps[0];
        }
        if(objApp != NULL){
            sSectionStatus = objApp.SectionStatus__c;
            if(sSectionStatus != NULL){
                SSP_SignaturePageWrapper.SSP_AppSectionList objAppSection = (SSP_SignaturePageWrapper.SSP_AppSectionList)JSON.deserialize(sSectionStatus, SSP_SignaturePageWrapper.SSP_AppSectionList.class);
                if(sMode == 'Intake'){
                    if(objAppSection.Intake.SSP_APP_ProgramSelection == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_ProgramSelection');
                    }
                    if(objAppSection.Intake.SSP_APP_HHMembersSummary == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_HHMembersSummary');
                        lstSelectedScreenNames.add('SSP_APP_HHMemberDetails');
                    }
                    if(objApp.ProgramsApplied__c!=null && objApp.ProgramsApplied__c.contains(SSP_GlobalConstants.SNAP)){
                         lstSelectedScreenNames.add('SSP_APP_ExpeditedSNAP');
                    }
                }else if(sMode == 'Renewal'){
                    if(objAppSection.Renewal.SSP_APP_ProgramSelection == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_ProgramSelection');
                    }
                    if(objAppSection.Renewal.SSP_APP_HHMembersSummary == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_HHMembersSummary');
                        lstSelectedScreenNames.add('SSP_APP_HHMemberDetails');
                    }
                }else{
                    if(objAppSection.AddRemoveMember != NULL && objAppSection.AddRemoveMember.SSP_APP_HHMembersSummary == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_HHMembersSummary');
                        lstSelectedScreenNames.add('SSP_APP_HHMemberDetails');
                    } 
                    if(objAppSection.ModifyExistingData != NULL && objAppSection.ModifyExistingData.SSP_APP_HHMembersSummary == 'COMPLETED'){
                        lstSelectedScreenNames.add('SSP_APP_HHMembersSummary');
                        lstSelectedScreenNames.add('SSP_APP_HHMemberDetails');
                    }
                }
            }
           
        }
        
        return lstSelectedScreenNames;
    }    
    
    @AuraEnabled
    public static SSP_LightningResponse sspDCServiceCall(String sApplicationId, String sMode){

        SSP_LightningResponse response = new SSP_LightningResponse();
        Set<String> lstSelectedScreenNames = new Set<String>();
        String sSelectedScreens;
        SSP_Utility.isAuthenticatedUser();
        lstSelectedScreenNames = getSelectedScreenNames(sApplicationId, sMode);
        sSelectedScreens = String.join(new List<String>(lstSelectedScreenNames), ',');
            if(sApplicationId != NULL && sMode != NULL && sMode != 'Not found'){
                response = invokeSSP_DC(sApplicationId,sSelectedScreens,sMode);
            }
        return response;
        
    }
    
    public static void updateNonPrimaryInd(String sApplicationId){
        List<SSP_Application__c>  lstApps;
        List<String> lstAppFields = new List<String>{'IsPrimaryApplicantAddressModified__c'};
        List<SSP_Member__c> sspMemberList = new List<SSP_Member__c>();
        List<SSP_ApplicationIndividual__c> lstAppInd;
        SSP_ApplicationIndividual__c objHOHMember;
        List<SSP_Member__c> lstNonPrimaryInd;
        Set<String> setMemberIds = new Set<String>();
        try{
            if(sApplicationId != NULL && String.isNotBlank(sApplicationId)){
                lstAppInd = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                             new Set<String>{'Id','SSP_Member__c','SSP_Application__c','IsHeadOfHousehold__c','SSP_Member__r.PreferredSpokenLanguageCode__c','SSP_Member__r.PreferredWrittenLanguageCode__c'}, 
                                                                                             new Map<String, String>{'SSP_Application__c'=> sApplicationId});
            }
            if(lstAppInd != NULL && !lstAppInd.isEmpty()){
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    if(objAppInd.IsHeadOfHousehold__c == true){
                        objHOHMember = objAppInd;
                    }else{
                        setMemberIds.add(objAppInd.SSP_Member__c);
                    }
                }        
            }
            if(!setMemberIds.isEmpty()){
                lstNonPrimaryInd = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'ID'}, 
                                                                      new Set<String>{'Id','PreferredSpokenLanguageCode__c','PreferredWrittenLanguageCode__c'}, 
                                                                      new Map<String, String>{'ID'=> String.join(new List<String>(setMemberIds), ',')});
            }
            if(lstNonPrimaryInd != null && !lstNonPrimaryInd.isEmpty() && objHOHMember != NULL){
                for(SSP_Member__c objMember : lstNonPrimaryInd){
                    objMember.PreferredSpokenLanguageCode__c = objHOHMember.SSP_Member__r.PreferredSpokenLanguageCode__c;
                    objMember.PreferredWrittenLanguageCode__c = objHOHMember.SSP_Member__r.PreferredWrittenLanguageCode__c;
                    sspMemberList.add(objMember);
                }
            }
            if(sspMemberList != null && !sspMemberList.isEmpty()){
            	Database.upsertResult[] results = ESAPI.accessController().upsertAsUser(sspMemberList, SSP_Utility.getFieldsNamesList (sspMemberList)).getResults();
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'updateNonPrimaryInd', ex.getMessage() , true);
        }
    }
    
    @future(callout=true)
    public static void sspVCICall(String sApplicationId){
        SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_VCIRequestWrapper objVCIWrap = new SSP_VCIRequestWrapper();
        List<SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividual> lstCurIncInd = new List<SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividual>();
        SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividuals objClsIncInd = new SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividuals();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        Set<String> setOfSSNs = new Set<String>();
        String sDCCaseNumber;
	String sApplicationName;
        try{
            lstAppInd = [SELECT ID,SSP_Member__c,MedicaidType__c,SSP_Application__r.Name,
                         SSP_Member__r.IsHeadOfHousehold__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,
                         SSP_Member__r.SuffixCode__c,SSP_Member__r.BirthDate__c,SSP_Member__r.PhysicalStateCode__c,SSP_Member__r.GenderCode__c,SSP_Application__r.DCCaseNumber__c,
                         SSP_Member__r.IndividualId__c,SSP_Member__r.SSN__c,SSP_Member__r.Contact__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: sApplicationId AND SSP_Application__r.ProgramsApplied__c includes ('MA') AND SSP_Member__r.SSNVerified__c = true];
            
            if(lstAppInd.size() > 0){
                if(lstAppInd[0].SSP_Application__r.DCCaseNumber__c != NULL){
                    sDCCaseNumber = String.valueOf(lstAppInd[0].SSP_Application__r.DCCaseNumber__c);
                }
                if(lstAppInd[0].SSP_Application__r.Name != NULL){
                    sApplicationName = String.valueOf(lstAppInd[0].SSP_Application__r.Name);
                }
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividual objCurrentIncomeInd = new SSP_VCIRequestWrapper.cls_VerifyCurrentIncomeIndividual();
                    objCurrentIncomeInd.IndividualId = objAppInd.SSP_Member__r.IndividualId__c;
                    objCurrentIncomeInd.PersonBirthDate = String.valueOf(objAppInd.SSP_Member__r.BirthDate__c);
                    objCurrentIncomeInd.PersonGivenName = objAppInd.SSP_Member__r.FirstName__c;
                    objCurrentIncomeInd.PersonMiddleName = objAppInd.SSP_Member__r.MiddleInitial__c;
                    objCurrentIncomeInd.PersonSSNIdentification = objAppInd.SSP_Member__r.SSN__c;
                    objCurrentIncomeInd.PersonSurName = objAppInd.SSP_Member__r.LastName__c;
                    lstCurIncInd.add(objCurrentIncomeInd);
                    setOfSSNs.add(objAppInd.SSP_Member__r.SSN__c);
                }
                objClsIncInd.VerifyCurrentIncomeIndividual = lstCurIncInd;
                objVCIWrap.CaseNumber = sDCCaseNumber;
                objVCIWrap.ApplicationNumber = sApplicationName;
                objVCIWrap.VerifyCurrentIncomeIndividuals = objClsIncInd;
                String sRequest = JSON.serialize(objVCIWrap);
                Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=>sRequest,
                    SSP_InterfaceConstants.SSPAHI_APPLICATIONID=>lstAppInd[0].SSP_Application__c,
                    SSP_InterfaceConstants.SSPAHI_CASENUMBER=>sDCCaseNumber,
                    SSP_InterfaceConstants.SSPVCI_SETOFSSNs=>setOfSSNs};
                        List<object> slist = IntegrationFactory.invokeCallout('SSP_VCI', objResponse);
                if(slist.size() > 1){
                    LOG_LogMessage__c objLog = (LOG_LogMessage__c)slist[1];
                    if(Schema.sObjectType.LOG_LogMessage__c.isCreateable()){
                        insert objLog;
                    }
                    //ESAPI.accessController().insertAsUser(objLog);
                    objResponse.put('response', slist[0]);
                }
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'sspVCICall', ex.getMessage() , true);
        }
    }
    @future(callout=true)
    public static void sspNonESIMECCall(String sApplicationId){
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        SSP_NONESIMECRequestWrapper objNonESIMECWrap = new SSP_NONESIMECRequestWrapper();
        List<SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestInner> lstNonESIMECInd = new List<SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestInner>();
        SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestOuter objOuterReq = new SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestOuter();
        String sApplicationName;
        try{
            lstAppInd = [SELECT ID,SSP_Member__c,MedicaidType__c,SSP_Application__r.Name,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,
                         SSP_Member__r.SuffixCode__c,SSP_Member__r.BirthDate__c,SSP_Member__r.PhysicalStateCode__c,SSP_Member__r.GenderCode__c,SSP_Member__r.IndividualId__c,
                         SSP_Member__r.SSN__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: sApplicationId AND SSP_Application__r.ProgramsApplied__c includes ('MA') AND SSP_Member__r.SSNVerified__c = true];
            if(lstAppInd.size() > 0){
                if(lstAppInd[0].SSP_Application__r.Name != NULL){
                    sApplicationName = lstAppInd[0].SSP_Application__r.Name;
                }
                
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    SSP_NONESIMECRequestWrapper.InsurancePolicyWrapper objInsPolicy = new SSP_NONESIMECRequestWrapper.InsurancePolicyWrapper();
                    SSP_NONESIMECRequestWrapper.PersonDetailWrapper objPersonDetail = new SSP_NONESIMECRequestWrapper.PersonDetailWrapper();
                    SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestInner objNonESIMEC = new SSP_NONESIMECRequestWrapper.NonESIMECIndividualRequestInner();
                    
                    objInsPolicy.ApplicationStartDate = String.valueOf(SSP_Utility.today());
                    objInsPolicy.InsurancePolicyExpirationDate = String.valueOf(SSP_Utility.today().addMonths(2));
                    
                    objPersonDetail.PersonGivenName = objAppInd.SSP_Member__r.FirstName__c;
                    objPersonDetail.PersonMiddleName = objAppInd.SSP_Member__r.MiddleInitial__c;
                    objPersonDetail.PersonSurName = objAppInd.SSP_Member__r.LastName__c;
                    objPersonDetail.PersonNameSuffixText = objAppInd.SSP_Member__r.SuffixCode__c;
                    
                    objNonESIMEC.IndividualId = Integer.valueOf(objAppInd.SSP_Member__r.IndividualId__c);
                    objNonESIMEC.PersonBirthDate = String.valueOf(objAppInd.SSP_Member__r.BirthDate__c);
                    objNonESIMEC.LocationStateUSPostalServiceCode = objAppInd.SSP_Member__r.PhysicalStateCode__c;
                    objNonESIMEC.Organization = new List<String>{'MEDI'};
                        objNonESIMEC.PersonSex = objAppInd.SSP_Member__r.GenderCode__c;
                    objNonESIMEC.PersonSSNIdentificationType = objAppInd.SSP_Member__r.SSN__c;
                    objNonESIMEC.InsurancePolicy = objInsPolicy;
                    objNonESIMEC.PersonDetail = objPersonDetail;
                    lstNonESIMECInd.add(objNonESIMEC);
                }
                objOuterReq.NonESIMECIndividualRequest = lstNonESIMECInd;
                objNonESIMECWrap.ApplicationNumber = Integer.valueOf(sApplicationName);
                objNonESIMECWrap.NonESIMECIndividualRequestList = objOuterReq;
                
                String sRequest = JSON.serialize(objNonESIMECWrap);
                Map<String, Object> objResponse = new Map<String, Object>{'jsonbody'=>sRequest};
                    List<object> slist = IntegrationFactory.invokeCallout('SSP_NONESIMECService', objResponse);
                if(slist != null) {
                    SSP_NONESIMECResponseWrapper resp = (SSP_NONESIMECResponseWrapper) slist[0];
                    objResponse.put('response', resp);
                    if(resp != NULL){
                        if(resp.IsSuccess != NULL && resp.IsSuccess) {
                            if(resp.lstofTransactionsToInsert != null && !resp.lstofTransactionsToInsert.isEmpty()) {
                                if(resp.lstofTransactionsToDelete != null && !resp.lstofTransactionsToDelete.isEmpty()) {
                                    delete  resp.lstofTransactionsToDelete;
                                }
                                insert resp.lstofTransactionsToInsert;
                            }  
                        }
                        if(resp.lstofLogMessages != null && !resp.lstofLogMessages.isEmpty()) {
                            
                            LOG_LogMessageUtility.logMessage(resp.lstofLogMessages);
                        }
                    }
                    //sspNONESIMECImpl(slist[0]);
                }
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'sspNonESIMECCall', ex.getMessage() , true);
        }
    }
    
    
    @AuraEnabled
    public static SSP_LightningResponse invokeSSP_DC(Id applicationId, String sSelectedScreens, String sMode){        
        SSP_LightningResponse response = new SSP_LightningResponse();
        SSP_Application__c updateObjApp;
        List<String> lstAppFields = new List<String>{'Status__c'};
        SSP_SignaturePageWrapper.SSP_SSPDCResponse objSSPDCResponse = new SSP_SignaturePageWrapper.SSP_SSPDCResponse();
        SSP_SignaturePageWrapper.SSP_SSPDCResponseMap objSSPDCResponseMap = new SSP_SignaturePageWrapper.SSP_SSPDCResponseMap();
        SSP_SignaturePageWrapper.SSP_SSPDCAcknowledgement objSSPDCAck = new SSP_SignaturePageWrapper.SSP_SSPDCAcknowledgement();
        try{
            if(applicationId != null){
                // SSP_Application__c sspApp = new SSP_Application__c( Id = applicationId, ApplicationReceivedDateTime__c = SSP_Utility.now());
                // update sspApp;

                //String applicationNumber = [select id, name from ssp_application__c where id=:applicationId].name;
                Map<String, Object> requestMap = new Map<String, Object>();
		        SSP_Application__c objApp = [SELECT ID,RAC_Selections__c,SignatureDate__c,ChangeSummaryMode__c,Account__c FROM SSP_Application__c WHERE ID=:applicationId LIMIT 1];
                if(objApp != NULL){
                    Date signDate = objApp.SignatureDate__c;
                    
                    DateTime currentDateTime = SSP_Utility.now();
                    AppConfig__c getTimeZone = AppConfig__c.getValues('timeZone');
                    AppConfig__c getTimeFormat = AppConfig__c.getValues('timeFormat');
                    String sCurrDateToStr = currentDateTime.format(getTimeFormat.Value__c,getTimeZone.Value__c);
                    DateTime reqTime = Datetime.ValueOfGMT(sCurrDateToStr);
                    Time currentTimeGMT = reqTime.timeGmt();
                    
                    Datetime signDateTime = datetime.newInstanceGMT(signDate, currentTimeGMT);
                    requestMap.put(SSP_InterfaceConstants.SSP_RAC_SELECTION, objApp.RAC_Selections__c);
                    requestMap.put(SSP_InterfaceConstants.APPLICATIONRECEIVEDDATETIME, signDateTime);
                    requestMap.put(SSP_InterfaceConstants.CHANGE_SUMMARY_MODE, objApp.ChangeSummaryMode__c);
                }
                // requestMap.put('screenList', APPLICABLE_SCREEN_LIST);
                // requestMap.put('ApplicationId', applicationId);
                // requestMap.put(SSP_InterfaceConstants.SUBMIT_TYPE,SSP_InterfaceConstants.MODE_INTAKE); 

                String screenListOne = System.Label.SSP_DC_Screens_One != 'NA' ? System.Label.SSP_DC_Screens_One : '' ;
                String screenListTwo = System.Label.SSP_DC_Screens_Two != 'NA' ? ','+System.Label.SSP_DC_Screens_Two : '' ;
                String screenListThree = System.Label.SSP_DC_Screens_Three != 'NA' ? ','+System.Label.SSP_DC_Screens_Three : '' ;
                String screenListFour = System.Label.SSP_DC_Screens_Four != 'NA' ? ','+System.Label.SSP_DC_Screens_Four : '' ;
                String screenNamesStr = screenListOne + screenListTwo + screenListThree +screenListFour;
                
                if(sSelectedScreens != null){
                    List<String> applicableScreenList = sSelectedScreens.split(',');
                    requestMap.put(SSP_InterfaceConstants.SCREEN_LIST, applicableScreenList);
                    requestMap.put(SSP_InterfaceConstants.APPLICATION_ID, applicationId);
                    requestMap.put(SSP_InterfaceConstants.ACCOUNT_ID, objApp.Account__c);
                    if(sMode == SSP_InterfaceConstants.MODE_INTAKE){
                    requestMap.put(SSP_InterfaceConstants.SUBMIT_TYPE,SSP_InterfaceConstants.MODE_INTAKE);  
                    }else if(sMode == SSP_InterfaceConstants.SSP_MODE_RAC || sMode == SSP_GlobalConstants.RAC_AddMember){
                        requestMap.put(SSP_InterfaceConstants.SUBMIT_TYPE,SSP_InterfaceConstants.SSP_MODE_RAC);  
                    }else if(sMode == SSP_InterfaceConstants.SSP_MODE_RENEWAL){
                        requestMap.put(SSP_InterfaceConstants.SUBMIT_TYPE,SSP_InterfaceConstants.SSP_MODE_RENEWAL);  
                    }
                    
                    response.put('request', JSON.serialize(requestMap));
                    List<Object> responseList = IntegrationFactory.invokeCallout('SSP_DC', requestMap);
                    
                    // response.put('response',JSON.serialize(responseList));                
                    if(responseList != null){
                        
                        
                        
                        if(((HttpResponse)responseList[0]).getBody() != NULL && !String.isBlank(((HttpResponse)responseList[0]).getBody()) && (responseList.size() == 1)){
                            response.put('response', ((HttpResponse)responseList[0]).getBody());                
                            objSSPDCResponse = (SSP_SignaturePageWrapper.SSP_SSPDCResponse)JSON.deserialize(((HttpResponse)responseList[0]).getBody(), SSP_SignaturePageWrapper.SSP_SSPDCResponse.class);
                    }else if((String)responseList[1] != NULL && String.isNotBlank((String)responseList[1]) && ((String)responseList[1] == 'LOG2000') || (String)responseList[1] == 'LOG3000' || (String)responseList[1] == 'LOG4000'){
                            List<String> lstErrorFields = new List<String>{'SSPDCMessage__c','Status__c'};
                                updateObjApp = new SSP_Application__c(ID = applicationId);
                            if(updateObjApp != NULL){
                                updateObjApp.SSPDCMessage__c = (String)responseList[1];
                                updateObjApp.Status__c = 'P';
                                ESAPI.accessController().updateAsUser(updateObjApp, lstErrorFields);
                            }
                            
                            response.put('ERROR', ((String)responseList[1]));
                        }else{
                            List<String> lstErrorFields = new List<String>{'SSPDCMessage__c','Status__c'};
                                updateObjApp = new SSP_Application__c(ID = applicationId);
                            if(updateObjApp != NULL){
                                updateObjApp.SSPDCMessage__c = (String)responseList[1];
                                ESAPI.accessController().updateAsUser(updateObjApp, lstErrorFields);
                            }
                            response.put('ERROR', ((String)responseList[1]));
                        }
                    }
                    if(objSSPDCResponse != NULL){
                        objSSPDCResponseMap = objSSPDCResponse.SubmitApplicationResponse;
                    }
                    if(objSSPDCResponseMap != NULL){
                        objSSPDCAck = objSSPDCResponseMap.AckResponse;
                    }
                    if(objSSPDCAck != NULL && objSSPDCAck.AckResponseDescription == SSP_GlobalConstants.SUCCESS){
                        updateObjApp = new SSP_Application__c(ID = applicationId);
                        if(updateObjApp != NULL){
                            updateObjApp.Status__c = 'P';
                            ESAPI.accessController().updateAsUser(updateObjApp, lstAppFields);
                        }
                    }
                    
                    
                }
                else{
                    response.put('ERROR', ' Screen List is Empty');                
                }
                
                
            }
        }
        catch(Exception ex){
            
            response.put('ERROR', ex.getStackTraceString());
        }
        return response;
    }
    
    @future(callout=true)
    public static void sspAVSCall(String sApplicationId){
        LOG_LogMessage__c objLog;
        List<LOG_LogMessage__c> lstLog = new List<LOG_LogMessage__c>();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        try{
            lstAppInd = [SELECT ID,SSP_Member__c,MedicaidType__c,SSP_Application__r.Name,
                         SSP_Member__r.IsHeadOfHousehold__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,
                         SSP_Member__r.SuffixCode__c,SSP_Member__r.BirthDate__c,SSP_Member__r.PhysicalStateCode__c,SSP_Member__r.GenderCode__c,
                         SSP_Member__r.SSN__c, SSP_Application__r.DCCaseNumber__c
                         FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: sApplicationId AND MedicaidType__c='Non-MAGI' AND SSP_Member__r.SSNVerified__c = true];
            if(lstAppInd.size() > 0){
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    SSP_AVSSchemasPostAvstr.identity_element objRequest = new  SSP_AVSSchemasPostAvstr.identity_element();
                    objRequest.socialSecurityNumber = objAppInd.SSP_Member__r.SSN__c;
                    SSP_AVSSchemasPostAvstr.name_element objName = new SSP_AVSSchemasPostAvstr.name_element();
                    objName.firstName = objAppInd.SSP_Member__r.FirstName__c;
                    objName.lastName = objAppInd.SSP_Member__r.LastName__c;
                    objName.middleName = objAppInd.SSP_Member__r.MiddleInitial__c;
                    objRequest.name = objName;
                    SSP_AVSSchemasPostAvstr.dateOfBirth_element objDOB = new SSP_AVSSchemasPostAvstr.dateOfBirth_element();
                    if(objAppInd.SSP_Member__r.BirthDate__c != NULL){
                        objDOB.year = String.Valueof(objAppInd.SSP_Member__r.BirthDate__c.year());
                        objDOB.month = String.Valueof(objAppInd.SSP_Member__r.BirthDate__c.month());
                        objDOB.date_x = String.Valueof(objAppInd.SSP_Member__r.BirthDate__c.day());
                    }
                    objRequest.dateOfBirth = objDOB;
                    objLog = sspAVSCallImpl(JSON.serialize(objRequest),objAppInd.SSP_Application__c,String.valueOf(objAppInd.SSP_Application__r.DCCaseNumber__c));
                    if(objLog != NULL){
                        lstLog.add(objLog);
                    }
                }
                if(!lstLog.isEmpty() && (Schema.sObjectType.LOG_LogMessage__c.isCreateable())){
                    insert lstLog;
                }
            } 
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'sspAVSCall', ex.getMessage() , true);
        }
    }
    
    public static LOG_LogMessage__c sspAVSCallImpl(String objRequest, String sApplicationId, String sCaseNumber){
        LOG_LogMessage__c objLog;
        Map<String, Object> objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> objRequest};
                objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,sApplicationId);
            objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,sCaseNumber);
            List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAVS_METADATANAME, objResponse);
        if(lstData.size() > 1){
            objLog = (LOG_LogMessage__c)lstData[1];
            objResponse.put('response', lstData[0]);                
        }
        return objLog;
    }
    @future(callout=true)
    public static void sspAHICall(String sApplicationId, String sMode){
        SSP_LightningResponse response = new SSP_LightningResponse();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        SSP_AHIRequestWrapper objReq = new SSP_AHIRequestWrapper();
        Map<String, Object> objResponse;
        List<SSP_AHIRequestWrapper.IndividualInformation> lstObjInd = new List<SSP_AHIRequestWrapper.IndividualInformation>();
        SSP_AHIRequestWrapper.IndividualInformationListClass objInd = new SSP_AHIRequestWrapper.IndividualInformationListClass();
        String sDCCaseNumber;
	String sApplicationName;
        try{
            lstAppInd = [SELECT ID,SSP_Member__c,MedicaidType__c,SSP_Application__r.Name,
                         SSP_Member__r.IsHeadOfHousehold__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,SSP_Member__r.MiddleInitial__c,
                         SSP_Member__r.SuffixCode__c,SSP_Member__r.BirthDate__c,SSP_Member__r.PhysicalStateCode__c,SSP_Member__r.GenderCode__c,
                         SSP_Member__r.SSN__c, SSP_Member__r.IndividualId__c, SSP_Application__r.DCCaseNumber__c
                         FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c =: sApplicationId AND SSP_Application__r.ProgramsApplied__c includes ('MA') AND SSP_Member__r.SSNVerified__c = true AND SSP_Member__r.TaxFilerStatusCurrentYear__c NOT IN ('NA','NF',NULL)];
            if(lstAppInd.size() > 0){
                if(lstAppInd[0].SSP_Application__r.DCCaseNumber__c != NULL){
                    sDCCaseNumber = String.valueOf(lstAppInd[0].SSP_Application__r.DCCaseNumber__c);
                }
                if(lstAppInd[0].SSP_Application__r.Name != NULL){
                    sApplicationName = String.valueOf(lstAppInd[0].SSP_Application__r.Name);
                }
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    SSP_AHIRequestWrapper.IndividualInformation objIndInfo = new SSP_AHIRequestWrapper.IndividualInformation();
                    objIndInfo.IndividualId = objAppInd.SSP_Member__r.IndividualId__c;
                    objIndInfo.PersonGivenName = objAppInd.SSP_Member__r.FirstName__c;
                    objIndInfo.PersonMiddleName = objAppInd.SSP_Member__r.MiddleInitial__c;
                    objIndInfo.PersonSSNIdentification = objAppInd.SSP_Member__r.SSN__c;
                    objIndInfo.PersonSurName = objAppInd.SSP_Member__r.LastName__c;
                    objIndInfo.TypeOfTaxFiler = 'PRIMARY';
                    lstObjInd.add(objIndInfo);
                }
                objInd.IndividualInformation = lstObjInd;
                if(sMode == 'Intake'){
                    objReq.RequestId = sApplicationName;
                    objReq.KeyIdentifier = 'APPLICATION NUMBER';
                    objReq.KeyValue = sApplicationName;
                }else{
                    objReq.RequestId = sDCCaseNumber;
                    objReq.KeyIdentifier = 'CASE NUMBER';
                    objReq.KeyValue = sDCCaseNumber;
                }
                objReq.IndividualInformationList = objInd;
                objResponse = new Map<String, Object>{SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objReq) };
                    response.put(SSP_InterfaceConstants.JSON_BODY,JSON.serialize(objReq));
                objResponse.put(SSP_InterfaceConstants.SSPAHI_APPLICATIONID,sApplicationName);
                objResponse.put(SSP_InterfaceConstants.SSPAHI_CASENUMBER,sDCCaseNumber);
                List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPAHI_METADATANAME, objResponse);
                if(lstData.size() > 1){
                    LOG_LogMessage__c objLog = (LOG_LogMessage__c)lstData[1];
                    if(Schema.sObjectType.LOG_LogMessage__c.isCreateable()){
                        insert objLog;
                    }
                    objResponse.put('response', lstData[0]);                
                }
            }
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_SignaturePageCtrl', 'sspAHICall', ex.getMessage() , true);
        }
    }
}