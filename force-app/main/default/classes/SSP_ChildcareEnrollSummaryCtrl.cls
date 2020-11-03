/*
* classname 	: SSP_ChildcareEnrollSummaryCtrl
* @description 	: A controller class for Childcare Enrollment Screen.
* @author 		: Keshav Poduval
* @date 		: June-30-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Keshav Poduval 		June-30-2020			Initial Version
*/

public class SSP_ChildcareEnrollSummaryCtrl {
    
    @AuraEnabled
    public static SSP_LightningResponse getEnrollmentDetails(String individualIdentity){
        SSP_Utility.isAuthenticatedUser();
        
        SSP_LightningResponse mapResponse = new SSP_LightningResponse();
      
        try{
           if(individualIdentity!=null)
           { 
        List<String> listIndivId = new List<String>();
        List<SSP_BenefitInformationWrapper> listBenWrapper = new List<SSP_BenefitInformationWrapper>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        String caseNumber;
        String individualId;
       mapResponse.bIsSuccess=false;
    mapResponse.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.CHILDCARE_ENROLLEMENT_SUMMARY_SCREENID, null));
    
        String IndiD=individualIdentity;
    listIndivId.add(individualIdentity);
    
        String strActivePendingBenefits='';
        if(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_ACTIVE_BENEFITS) != null)
        {
         strActivePendingBenefits = sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_ACTIVE_BENEFITS) != null ? String.valueOf(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_ACTIVE_BENEFITS)):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,SSP_GlobalConstants.CC_ENROLLMENT_ACTIVE_BENEFITS)); 
        }
        else if(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_INTERVIEW_BENEFITS) != null)
        {
             strActivePendingBenefits = sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_INTERVIEW_BENEFITS) != null ? String.valueOf(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_INTERVIEW_BENEFITS)):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,SSP_GlobalConstants.CC_ENROLLMENT_PENDING_INTERVIEW_BENEFITS)); 
        }
        else if(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_VERIFICATION_BENEFITS) != null)
        {
             strActivePendingBenefits = sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_VERIFICATION_BENEFITS) != null ? String.valueOf(sessionpart.get(SSP_GlobalConstants.CC_ENROLLMENT_PENDING_VERIFICATION_BENEFITS)):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,SSP_GlobalConstants.CC_ENROLLMENT_PENDING_VERIFICATION_BENEFITS)); 
        }
        mapResponse.put('strActivePendingBenefits',strActivePendingBenefits);
        if(!String.isBlank(strActivePendingBenefits))
        {
        Map<String,Object> mapJson = (Map<String,Object>)JSON.deserializeUntyped(strActivePendingBenefits);
        
        for(String caseNum : mapJson.keySet()){
            List<SSP_BenefitInformationWrapper> listWrapper = (List<SSP_BenefitInformationWrapper>) JSON.deserialize(JSON.serialize(mapJson.get(caseNum)), List<SSP_BenefitInformationWrapper>.class);
            
            listBenWrapper.addAll(listWrapper);
        }   
        
        for(SSP_BenefitInformationWrapper benWrapper : listBenWrapper){

            if(benWrapper.ProgramCode.equalsIgnoreCase(SSP_GlobalConstants.CC_ENROLLMENT_CHILD_CARE_ASSISTANCE) && 
               (benWrapper.ProgramStatusCode.equalsIgnoreCase(SSP_GlobalConstants.AP_Code) || benWrapper.ProgramStatusCode.equalsIgnoreCase(SSP_GlobalConstants.PE_Code) || benWrapper.ProgramStatusCode.equalsIgnoreCase(SSP_GlobalConstants.PI_Code))&&               listIndivId.contains(benWrapper.IndividualId) )
            {
               
                caseNumber = benWrapper.CaseNumber;
                individualId = benWrapper.IndividualId;
                mapResponse.put(SSP_GlobalConstants.CC_ENROLLMENT_LOGGED_IN_CONTACT,benWrapper.IndividualName);
            }
        }
        if(String.isNotBlank(caseNumber) && String.isNotBlank(individualId)){
            SSP_CCEnrollSummary_RequestWrapper request = new SSP_CCEnrollSummary_RequestWrapper();
            request.CaseNumber = caseNumber;
            request.IndividualId = individualId;
            request.SubmitType = SSP_GlobalConstants.CC_ENROLLMENT_CHILDCARESUMMARYSUBMITTYPE;
            Map<String, Object> mapParams = new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize(request)};
                List<Object> objList = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSP_CHILDCARE_PROVIDER_SEARCH, mapParams);
            SSP_ChildCareProviderSearchResponse response = (SSP_ChildCareProviderSearchResponse) objList[0];
            List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentDetails> ccEnrollmentDetails = response.ChildCareEnrollmentDetails;
            if(ccEnrollmentDetails !=null){
                mapresponse.bIsSuccess=true;
                mapResponse.put(SSP_GlobalConstants.CC_ENROLLMENT_ENROLLMEMNT_DETAILS,JSON.serialize(ccEnrollmentDetails));
            }
            List<SSP_ChildCareProviderSearchResponse.ChildCareEnrollmentScheduleDetails> ccEnrollmentSchDetails = response.ChildCareEnrollmentScheduleDetails;
            if(ccEnrollmentSchDetails !=null){
                mapresponse.bIsSuccess=true;
                mapResponse.put(SSP_GlobalConstants.CC_ENROLLMENT_ENROLLMEMNT_SCH_DETAILS,JSON.serialize(ccEnrollmentSchDetails));
            }
        }
    }
    }
    }catch(Exception ex) { List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ChildcareEnrollSummaryCtrl', 'getEnrollmentDetails', ex.getMessage() , true); 
                        mapResponse.bIsSuccess = false; mapResponse.addException(ex, lstLogMessages[0].Id);
                    }
        
        return mapResponse;
    }

    
    

}