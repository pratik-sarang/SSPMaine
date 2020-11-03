/*
* classname     :  SSP_NonCitizenRAC
* @description  :  This class contains all methods to fetch get data on RAC for Non Citizen User
* @author       :  Keshav Poduval   
* @date         :  04/21/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
Keshav Poduval               04/21/2020                             Created.
* ---------------------------------------------------------------------------------------------
**/
public without sharing class SSP_NonCitizenRAC {
    
    /***************************************************************************************************
* @author       Keshav Poduval
* @date         04/21/2020
* @methodname   triggerBenefitsServiceCall
* @description  This method takes a Individual Id and Refresh required and uses it to query the relevant data for the Non Citizen User.
* @return       ssp_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static Map<String,List<String>> triggerBenefitsServiceCall(String individualId, String memberId){   
        SSP_Utility.isAuthenticatedUser();                     
        List<Object> serviceResponses =  new List<Object>();        
        List<SSP_BenefitInformationWrapper> benefitData = new  List<SSP_BenefitInformationWrapper>();              
        Map<String, Object> mapParamsBenefit = new Map<String, Object>(); 
        Map<String,List<String>> mapIndividualIdVsPrograms = new  Map<String,List<String>>();
        List<String> lstPrograms= new List<String>(); 
        
        try{            
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName =SSP_InterfaceConstants.BENEFIT_INFORMATION;                 
            reqWrapper.primaryApplicationIndividualId = individualId;
            //Defect 386563 - Start
            reqWrapper.KeyValueParameters = new List<SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper>();
    	    reqWrapper.KeyValueParameters.add(new SSP_RSSPDC_RequestWrapper.KeyValueParametersWrapper(SSP_GlobalConstants.BENEFITPROGRAMSKEY,'Y'));
            //Defect 386563 - End
            mapParamsBenefit.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParamsBenefit);                 
            if(serviceResponses != null && !serviceResponses.isEmpty()){
                RSSP_DC_Wrapper wrapperResponse =  (RSSP_DC_Wrapper) serviceResponses[0];                    
                if(wrapperResponse != null && wrapperResponse.benefitInformations != null && wrapperResponse.benefitInformations.Benefit != null){
                    benefitData  = wrapperResponse.benefitInformations.Benefit;
                    Contact citizenContact = SSP_DashboardService.getIndividualContact(individualId);                    
                    updateBenefitsInfo(memberId, JSON.serialize(benefitData),citizenContact != null ? citizenContact.Id : null );

                    User currentUser = new User(Id = UserInfo.getUserId(), ImpersonatedIndividualId__c = individualId);
                    update currentUser;
                    
                    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
                    sessionPart.put(SSP_GlobalConstants.INDIVIDUAL_ID, individualId);

                    //#382572
                    sessionPart.put('ActiveBenefits',parsePrograms('ActiveBenefits', JSON.serialize(benefitData), individualId ));
                    sessionPart.put('PendingInterviewBenefits',parsePrograms('PendingInterviewBenefits', JSON.serialize(benefitData), individualId ));
                    sessionPart.put('PendingVerificationBenefits',parsePrograms('PendingVerificationBenefits', JSON.serialize(benefitData), individualId ));

                } 
            }                            
            for(SSP_BenefitInformationWrapper objBenefit : benefitData){                 
                if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED || objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION || objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW){
                    if(mapIndividualIdVsPrograms.containsKey(objBenefit.IndividualId)){
                       lstPrograms=mapIndividualIdVsPrograms.get(objBenefit.IndividualId);
                       lstPrograms.add(objBenefit.ProgramCode);
                       mapIndividualIdVsPrograms.put(objBenefit.IndividualId, lstPrograms);
                    } else{
                        mapIndividualIdVsPrograms.put(objBenefit.IndividualId, new list<String>{objBenefit.ProgramCode});
                    }                         
                                                 
                }                        
            } 
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenRAC', 'triggerBenefitsServiceCall', 'Failed to fetch Program from Benefits call', true);
        }        
        return mapIndividualIdVsPrograms;
    }   

    private static void updateBenefitsInfo(String memberId, String benefitData, String contactId){
        Contact toUpdate = new Contact(CacheBenefitProgramData__c = benefitData);   
        if(String.isNotBlank(contactId)){
            toUpdate.Id = contactId;
        }
        else if(String.isNotBlank(memberId)){
            List<SSP_Member__c> memberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, new Set<String>{'Contact__c'}, 
                                                            new Map<String, String>{'Id'=> memberId });
            if(memberList != null && !memberList.isEmpty()){
                toUpdate.Id = memberList[0].Contact__c;                
            }                               
        }                         

        if(toUpdate != null && String.isNotBlank(toUpdate.Id)){
            update toUpdate;
        }
    }
    
 /***************************************************************************************************
* @author       Chandra Shekhar
* @date         05/06/2020
* @methodname   getCISData
* @description  This method takes a application Id and Mode and return CIS caretaker true or false
* @return       SSP_LightningResponse
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getCISData(String sApplicationId,String sMode){
        SSP_Utility.isAuthenticatedUser(); 
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        toSend.put('CIS_CareTaker', false);
        try{
            if(String.isNotBlank(sMode) &&  (SSP_GlobalConstants.SSP_INTAKE_FLOW.equals(sMode) || sMode.equalsIgnoreCase(SSP_GlobalConstants.RAC_AddMember)) ){ //385177 Fix
                toSend.put('CIS_CareTaker', true);
                toSend.bIsSuccess = true;               
            }
            else if(String.isNotBlank(sMode) &&  SSP_GlobalConstants.SSP_RAC_FLOW.equals(sMode)){  
                SSP_Application__c app= [Select id,RAC_Selections__c from SSP_Application__c where id=:sApplicationId];
                if(app!=null){
                    String racSelection=app.RAC_Selections__c;
                    if(racSelection.contains('CIS_CareTaker')){
                        toSend.put('CIS_CareTaker', true);
                        toSend.bIsSuccess = true;
                    }  
                }                
            }
        }
        catch(Exception ex){
            toSend.bIsSuccess = false;            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_NonCitizenRAC', 'getCISData', ex.getMessage() , true);
            toSend.put('Error', lstLogMessages[0].Name);
        }        
        return toSend;
    } 
    
    //#382572
    public static String parsePrograms(String key, String benefitStr, String individualId) {
        String value = '';
        try{
            Set<String> setCaseNumbers = new Set<String>();
            Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsActiveBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
            Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingInterviewBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
            Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingVerificationBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
            Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsAllBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
            List<String> lstActiveCases = new List<String>();
            List<SSP_BenefitInformationWrapper> benefitData = (List<SSP_BenefitInformationWrapper>)JSON.deserialize(benefitStr, List<SSP_BenefitInformationWrapper>.class);
          
            
            for(SSP_BenefitInformationWrapper objBenefit : benefitData){
                setCaseNumbers.add(objBenefit.CaseNumber);
            }

            for(String strCaseNumber: setCaseNumbers){
                Boolean isHeadOfHousehold = true;              
                List<SSP_BenefitInformationWrapper> lstAllActiveBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllPendingInterviewBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllPendingVerificationBenefits = new List<SSP_BenefitInformationWrapper>();
                
                for(SSP_BenefitInformationWrapper objBenefit : benefitData){  
                    if(objBenefit.ProgramCode == SSP_GlobalConstants.KTAP){
                        objBenefit.ProgramCode = system.label.SSP_KTAP;
                    }else if(objBenefit.ProgramCode == SSP_GlobalConstants.MEDICAID){
                        objBenefit.ProgramCode =system.label.SSP_Medicaid;
                    } 
                    else if(objBenefit.ProgramCode == SSP_GlobalConstants.CHILDCARE){
                        objBenefit.ProgramCode = system.label.SSP_ChildCareAssistance;
                    } 
                    else if(objBenefit.ProgramCode == SSP_GlobalConstants.STATE){
                        objBenefit.ProgramCode = system.label.SSP_StateSupplementation;
                    } 
                    else if(objBenefit.ProgramCode ==SSP_GlobalConstants.KHIPP){  
                        objBenefit.ProgramCode = system.label.SSP_KIHIPP;
                    }else if (objBenefit.ProgramCode ==SSP_GlobalConstants.SNAP){
                        objBenefit.ProgramCode = system.label.SSP_SNAP;
                    }
                   
                    if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                        lstAllActiveBenefits.add(objBenefit);
                    }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                        lstAllPendingVerificationBenefits.add(objBenefit);
                    }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                        lstAllPendingInterviewBenefits.add(objBenefit);
                    }
                    
                    if(!lstAllActiveBenefits.isEmpty()){                    
                        mapCaseVsActiveBenefits.put(strCaseNumber,lstAllActiveBenefits);  
                    }
                    if(!lstAllPendingInterviewBenefits.isEmpty()){    
                        mapCaseVsPendingInterviewBenefits.put(strCaseNumber,lstAllPendingInterviewBenefits);
                    }
                    if(!lstAllPendingVerificationBenefits.isEmpty()){    
                        mapCaseVsPendingVerificationBenefits.put(strCaseNumber,lstAllPendingVerificationBenefits);
                    }
                }                               
            } 
			
            if(!mapCaseVsAllBenefits.isEmpty() && key == 'AllBenefits'){ 
                value = JSON.serialize(mapCaseVsAllBenefits);
            }
            if(!mapCaseVsActiveBenefits.isEmpty() && key == 'ActiveBenefits'){ 
                value = JSON.serialize(mapCaseVsActiveBenefits);
            }
            if(!mapCaseVsPendingInterviewBenefits.isEmpty() && key == 'PendingInterviewBenefits'){ 
                value = JSON.serialize(mapCaseVsPendingInterviewBenefits);
            }
            if(!mapCaseVsPendingVerificationBenefits.isEmpty() && key == 'PendingVerificationBenefits'){ 
                value = JSON.serialize(mapCaseVsPendingVerificationBenefits);
            }               
        
        }
        catch(Exception ex){
            value = null;
        }
        return value;
    }

 
}