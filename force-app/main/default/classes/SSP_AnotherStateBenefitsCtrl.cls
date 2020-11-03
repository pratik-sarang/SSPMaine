/*
* classname 	: SSP_AnotherStateBenefitsCtrl
* @description 	: This class is used to save and retrieve the benefits from another state in detail and summmary screen.
* @author 		: Nupoor Nimbalkar
* @date 		: 11/27/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar 		11/27/2019		Initial Version
*/
public class SSP_AnotherStateBenefitsCtrl {
    /*
* method 		: fetchAnotherStateBenefits
* @description  : This method is used to fetch all the details of benefits from another state.
* @author 		: Sai Kiran
* @param 		: sMemberId - Member ID in string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse fetchAnotherStateBenefits(String sMemberId){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords objSSPBenefitsWrapper;
        SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords objSSPBenefitsWrapperUpdate = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords();
        Map<string, SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords> mapSSPBenefits = new Map<string, SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords>();
        Map<String, String> benefitStateValues = SSP_Utility.getPickListValues('SSP_Benefits__c', 'State__c', null);        
        Map<String, String> benefitProgramValues = SSP_Utility.getPickListValues('SSP_Benefits__c', 'BenefitPrograms__c', null);
        String SNAP = SSP_GlobalConstants.SNAP;
        String TANF = SSP_GlobalConstants.TANF;
        String MEDICAID = SSP_GlobalConstants.MEDICAID;
        Date timeTravelTodayDate;
        String timeTravelCurrentMonth;
        try{
            SSP_Utility.isAuthenticatedUser();
            //Check the List of Variable's & their functionality in the Wrapper Class
            sMemberId = String.escapeSingleQuotes(sMemberId);
            lstBenefits = SSP_AnotherStateBenefitsService.fetchOutOfStateBenefits(sMemberId);
            //Below Loop is get the Benefit Records in a MAP Object with KEY as UNIQUE on SSP_Benefits__c Object
            //which Stores the Value When USER Creates the Record.
            for(SSP_Benefits__c objSSPBenefit : lstBenefits){
                objSSPBenefitsWrapperUpdate = mapSSPBenefits.get(objSSPBenefit.BenefitStateCountyKey__c);
                if (objSSPBenefitsWrapperUpdate != NULL){
                    objSSPBenefitsWrapperUpdate.sBenefitIds = objSSPBenefitsWrapperUpdate.sBenefitIds +','+objSSPBenefit.ID;
                    objSSPBenefitsWrapperUpdate.sMemberId = objSSPBenefit.SSP_Member__c;
                    objSSPBenefitsWrapperUpdate.sBenefitState = objSSPBenefit.State__c;
                    objSSPBenefitsWrapperUpdate.sBenefitStateLabel = benefitStateValues.get(objSSPBenefit.State__c);
                    objSSPBenefitsWrapperUpdate.sBenefitUniqueKey = objSSPBenefit.BenefitStateCountyKey__c;
                    if(objSSPBenefit.BenefitInfoCounty__c != NULL && objSSPBenefit.BenefitInfoCounty__c != '' && !String.isEmpty(objSSPBenefit.BenefitInfoCounty__c)){
                        objSSPBenefitsWrapperUpdate.sBenefitCounty = objSSPBenefit.BenefitInfoCounty__c;
                        objSSPBenefitsWrapperUpdate.bIsCounty = true;
                    }else{
                        objSSPBenefitsWrapperUpdate.bIsCounty = false;
                    }                    
                    if(objSSPBenefit.BenefitPrograms__c != NULL && !objSSPBenefitsWrapperUpdate.sBenefitProgram.contains(objSSPBenefit.BenefitPrograms__c)){
                        objSSPBenefitsWrapperUpdate.sBenefitProgram = objSSPBenefitsWrapperUpdate.sBenefitProgram+', '+objSSPBenefit.BenefitPrograms__c;
                        objSSPBenefitsWrapperUpdate.sBenefitProgramLabel = objSSPBenefitsWrapperUpdate.sBenefitProgramLabel+', '+benefitProgramValues.get(objSSPBenefit.BenefitPrograms__c);
                    }else{
                        objSSPBenefitsWrapperUpdate.sBenefitProgram = objSSPBenefit.BenefitPrograms__c;
                        objSSPBenefitsWrapperUpdate.sBenefitProgramLabel = benefitProgramValues.get(objSSPBenefit.BenefitPrograms__c);
                    }
                    if(objSSPBenefit.BenefitPrograms__c == SNAP){
                        objSSPBenefitsWrapperUpdate.sBenefitSNAPId = objSSPBenefit.Id;
                        objSSPBenefitsWrapperUpdate.dBenefitSNAPStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapperUpdate.dBenefitSNAPEndDate = objSSPBenefit.EndDate__c;
                    }
                    if(objSSPBenefit.BenefitPrograms__c == MEDICAID){
                        objSSPBenefitsWrapperUpdate.sBenefitMEDICAIDId = objSSPBenefit.Id;
                        objSSPBenefitsWrapperUpdate.dBenefitMEDICADEStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapperUpdate.dBenefitMEDICADEEndDate = objSSPBenefit.EndDate__c;
                    }
                    if(objSSPBenefit.BenefitPrograms__c == TANF){
                        objSSPBenefitsWrapperUpdate.sBenefitTANFId = objSSPBenefit.Id;
                        objSSPBenefitsWrapperUpdate.dBenefitTANFStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapperUpdate.dBenefitTANFEndDate = objSSPBenefit.EndDate__c;
                    }
                    mapSSPBenefits.put(objSSPBenefit.BenefitStateCountyKey__c, objSSPBenefitsWrapperUpdate);
                }else{
                    objSSPBenefitsWrapper  = new SSP_AnotherStateBenefitsWrapper.SSP_BenefitRecords();
                    objSSPBenefitsWrapper.sBenefitIds = objSSPBenefit.ID;
                    objSSPBenefitsWrapper.sMemberId = objSSPBenefit.SSP_Member__c;
                    objSSPBenefitsWrapper.sBenefitState = objSSPBenefit.State__c;
                    objSSPBenefitsWrapper.sBenefitStateLabel = benefitStateValues.get(objSSPBenefit.State__c);
                    objSSPBenefitsWrapper.sBenefitUniqueKey = objSSPBenefit.BenefitStateCountyKey__c;
                    if(objSSPBenefit.BenefitInfoCounty__c != NULL && objSSPBenefit.BenefitInfoCounty__c != '' && !String.isEmpty(objSSPBenefit.BenefitInfoCounty__c)){
                        objSSPBenefitsWrapper.sBenefitCounty = objSSPBenefit.BenefitInfoCounty__c;
                        objSSPBenefitsWrapper.bIsCounty = true;
                    }else{
                        objSSPBenefitsWrapper.bIsCounty = false;
                    }                    
                    objSSPBenefitsWrapper.sBenefitProgram = objSSPBenefit.BenefitPrograms__c;
                    objSSPBenefitsWrapper.sBenefitProgramLabel = benefitProgramValues.get(objSSPBenefit.BenefitPrograms__c);
                    if(objSSPBenefit.BenefitPrograms__c == SNAP){
                        objSSPBenefitsWrapper.sBenefitSNAPId = objSSPBenefit.Id;
                        objSSPBenefitsWrapper.dBenefitSNAPStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapper.dBenefitSNAPEndDate = objSSPBenefit.EndDate__c;
                    }
                    if(objSSPBenefit.BenefitPrograms__c == MEDICAID){
                        objSSPBenefitsWrapper.sBenefitMEDICAIDId = objSSPBenefit.Id;
                        objSSPBenefitsWrapper.dBenefitMEDICADEStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapper.dBenefitMEDICADEEndDate = objSSPBenefit.EndDate__c;
                    }
                    if(objSSPBenefit.BenefitPrograms__c == TANF){
                        objSSPBenefitsWrapper.sBenefitTANFId = objSSPBenefit.Id;
                        objSSPBenefitsWrapper.dBenefitTANFStartDate = objSSPBenefit.BeginDate__c;
                        objSSPBenefitsWrapper.dBenefitTANFEndDate = objSSPBenefit.EndDate__c;
                    }
                    mapSSPBenefits.put(objSSPBenefit.BenefitStateCountyKey__c, objSSPBenefitsWrapper); 
                }    
            }
            timeTravelTodayDate = SSP_Utility.today();
            objResponse.put('lstBenefitsWrapper', mapSSPBenefits.values());
            objResponse.put('timeTravelTodayDate', timeTravelTodayDate);
            objResponse.put('timeTravelCurrentMonth', SSP_Utility.monthToday());

            /** 2.5	Security Role Matrix and Program Access. */
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_SUMMARY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.BENEFITS_ANOTHER_STATE_SUMMARY_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_DETAILS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.BENEFITS_ANOTHER_STATE_DETAILS_SCREENID, null));
            /** */

            objResponse.bIsSuccess = true;
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AnotherStateBenefitsCtrl', 'fetchAnotherStateBenefits', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
* method 		: upsertAnotherStateBenefits
* @description  : This method is used to insert/update the details of benefits from another state.
* @author 		: Sai Kiran Velpula
* @param 		: sBenefitsWrapper - Wrapper in json string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse upsertAnotherStateBenefits(String sBenefitsWrapper){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        Map<String, SSP_Benefits__c> mapBenefits = new Map<String, SSP_Benefits__c>();
        SSP_Benefits__c objBenefit;
        Map<String, String> benefitProgramValues = SSP_Utility.getPickListValues('SSP_Benefits__c', 'BenefitPrograms__c', null);
        String uniqueKey;
        String SNAP = SSP_GlobalConstants.SNAP;
        String TANF = SSP_GlobalConstants.TANF;
        String MEDICAID = SSP_GlobalConstants.MEDICAID;
        try{
            SSP_Utility.isAuthenticatedUser();
            List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList> lstPrograms = new List<SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList>();
            SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList benefitDataWrapper = (SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList) JSON.deserialize(sBenefitsWrapper, SSP_AnotherStateBenefitsWrapper.SSP_BenefitDataList.class);
            lstPrograms = benefitDataWrapper.lstBenefitProgramList;
            for(SSP_Benefits__c objSSPBenefit : SSP_AnotherStateBenefitsService.fetchOutOfStateBenefits(String.escapeSingleQuotes(benefitDataWrapper.sMemberId))){
                mapBenefits.put(objSSPBenefit.ID, objSSPBenefit);
                
            }
            //Inserts the Records when the User clicks on 'Add Benefit' or 'Start' on Benefit Summary Page.
            if(!benefitDataWrapper.bIsInsert){
                uniqueKey = SSP_AnotherStateBenefitsService.generateUniqueID();
                for(SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType : lstPrograms){
                        objBenefit = new SSP_Benefits__c();
                        objBenefit.SSP_Member__c = benefitDataWrapper.sMemberId;
                        objBenefit.BenefitInfoCounty__c = benefitDataWrapper.sBenefitCounty;
                        objBenefit.State__c = benefitDataWrapper.sBenefitState;
                        objBenefit.BenefitPrograms__c = programType.sBenefitProgram;
                        objBenefit.BeginDate__c = programType.dBenefitStartDate;
                        objBenefit.EndDate__c = programType.dBenefitEndDate;
                    objBenefit.BenefitStateCountyKey__c = uniqueKey;
                        lstBenefits.add(objBenefit);
                }
            }else{
                //Upsert the Benefit Record when the User clicks on 'Edit' on Benefit Summary page.
                //Line 198 - Condition to check the user is modifying the Existing Record,
                //If not Create the new Record under the same tile in Summary Page.
                for(SSP_AnotherStateBenefitsWrapper.SSP_BenefitProgramList programType : lstPrograms){
                    if( (programType.sBenefitProgram == SNAP && benefitDataWrapper.bSnapCheck) || (programType.sBenefitProgram == TANF && benefitDataWrapper.bTanfCheck) ||(programType.sBenefitProgram == MEDICAID &&  benefitDataWrapper.bMedicaidCheck)){
                        objBenefit = mapBenefits.get(programType.sBenefitId);
                    }else{
                        objBenefit = new SSP_Benefits__c();
                        objBenefit.SSP_Member__c = benefitDataWrapper.sMemberId;
                        
                    }
                    objBenefit.BenefitStateCountyKey__c = benefitDataWrapper.sBenefitUniqueKey;
                    objBenefit.BenefitInfoCounty__c = benefitDataWrapper.sBenefitCounty;
                    objBenefit.State__c = benefitDataWrapper.sBenefitState;
                    objBenefit.BenefitPrograms__c = programType.sBenefitProgram;
                    objBenefit.BeginDate__c = programType.dBenefitStartDate;
                    objBenefit.EndDate__c = programType.dBenefitEndDate;
                    lstBenefits.add(objBenefit);
                }
            }
            if(lstBenefits.size()>0){
                ESAPI.accessController().upsertAsUser(lstBenefits, SSP_Utility.getFieldsNamesList(lstBenefits));
            }   
            if(benefitDataWrapper.sBenefitIds != NULL && String.isNotEmpty(benefitDataWrapper.sBenefitIds)){
                removeBenefitData(benefitDataWrapper.sBenefitIds, benefitDataWrapper.sMemberId);
            }
            objResponse.bIsSuccess = true;
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AnotherStateBenefitsCtrl', 'upsertAnotherStateBenefits', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    /*
* method 		: removeBenefitData
* @description  : This method is used to Delete the details of benefits from another state.
* @author 		: Sai Kiran Velpula
* @param 		: sBenefitIds - Id's in string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse removeBenefitData(String sBenefitIds, String sMemberId){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<SSP_Benefits__c> lstBenefits = new List<SSP_Benefits__c>();
        List<SSP_Benefits__c> updatedListBenefitsOnDelete = new List<SSP_Benefits__c>();
        try{
            SSP_Utility.isAuthenticatedUser();
            lstBenefits = SSP_AnotherStateBenefitsService.fetchBenefitRecords(sBenefitIds);
            if(lstBenefits.size() > 0){
                ESAPI.accessController().deleteAsUser(lstBenefits);
            }
            sMemberId = String.escapeSingleQuotes(sMemberId);
            updatedListBenefitsOnDelete = SSP_AnotherStateBenefitsService.fetchOutOfStateBenefits(sMemberId);
            objResponse.put('updatedListBenefits',updatedListBenefitsOnDelete);
            objResponse.bIsSuccess = true;
        }catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AnotherStateBenefitsCtrl', 'removeBenefitData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
        }
        return objResponse;
    }
    /*
* method 		: updateMemberData
* @description  : This method is used to Delete the details of benefits from another state.
* @author 		: Sai Kiran Velpula
* @param 		: sBenefitIds - Id's in string format
* @return 		: SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse updateMemberData(String sMemberId){
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        Map<String,String> mapConditions = new Map<String,String>();
        List<String> lstMemberFields = new List<String>{'HasReceivedBenefitsFromOtherStateToggle__c'};
            try{
                SSP_Utility.isAuthenticatedUser();
                mapConditions.clear();
                mapConditions.put('SSP_Member__c',sMemberId);
                SSP_Member__c objSSPMember = SSP_MemberSelector.queryMemberDataById(sMemberId, lstMemberFields);
                objSSPMember.HasReceivedBenefitsFromOtherStateToggle__c ='N';
                if(objSSPMember != NULL){
                    ESAPI.accessController().updateAsUser(objSSPMember, lstMemberFields);
                }
                objResponse.bIsSuccess = true;
            }catch(Exception ex){
                List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_AnotherStateBenefitsCtrl', 'updateMemberData', ex.getMessage() , true);
                objResponse.bIsSuccess = false;
            }
        return objResponse;
    }
    
}