/***************************************************************************************************************************
*   Type         :   Service Class
*   Name         :   SSP_EligibilityResultsCtrl
*   Created By   :   Suyash Singhal
*   Created Date :  
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                                  Initial Version
*	  Vishakha					10/03/2020 	   
*****************************************************************************************************************************/
public with sharing class SSP_EligibilityResultsCtrl {
    
  
    
    @AuraEnabled
    public static  Map<String, Object> getEligibilityData(String sApplicationId){        
        Map<String, Object> objResponse = new Map<String, Object>();
        RSSP_DC_Wrapper wrapperResponse  = new RSSP_DC_Wrapper();
        SSP_EligibilitySummaryPayloadWrapper eligibilityWrapper = new SSP_EligibilitySummaryPayloadWrapper();
        List<WrapperProgramsIndviduals> wrapperList = new List<WrapperProgramsIndviduals>();
        List<SSP_EligibilitySummaryWrapper> ssp_EligibilitySummaryInList = new  List<SSP_EligibilitySummaryWrapper> ();
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new  SSP_RSSPDC_RequestWrapper();
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c>();
        //Shikha - added contact
        List<Contact> contactRecord = new List<Contact>();
        try{    
            SSP_Utility.isAuthenticatedUser();
            
            List<SSP_Application__c>  lstApps =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                                              new Set<String>{'Id','ProgramsApplied__c','Account__c','DCCaseNumber__c', 'Name', 'SSPDCMessage__c','Name','CHFS_Exception_ID__c','RecordType.Name'}, 
                                                                                              new Map<String, String>{'Id'=> sApplicationId});                                                                                            
            if(null!=lstApps&& lstApps.size()>0){
                lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                                 new Set<String>{'Id','SSP_Member__c','SSP_Application__c','SSP_Member__r.IndividualId__c','SSP_Member__r.Contact__c'}, 
                                                                                 new Map<String, String>{'limit'=>'1','SSP_Application__c'=> sApplicationId,'IsHeadOfHousehold__c' =>'#true#'});
                
                reqWrapper.viewName = SSP_GlobalConstants.ELIGIBILITY_SUMMARY_VIEW_NAME;
                if(lstAppIndividuals != NULL && !lstAppIndividuals.isEmpty() && lstAppIndividuals[0].SSP_Member__r.IndividualId__c != NULL){
                    reqWrapper.primaryApplicationIndividualId = lstAppIndividuals[0].SSP_Member__r.IndividualId__c;
                    Id contactId = lstAppIndividuals[0].SSP_Member__r.Contact__c;
                    if(contactId != null ){
                        contactRecord = SSP_ContactSelector.queryContactData(
                			new Map<String, String>{'objectName'=>'Contact', 'operator'=>'AND'}, 
                			new Set<String>{'Id', 'IsDashboardRefreshNeeded__c', 'Name'}, 
               			    new Map<String, String>{'limit'=>'1','Id' => contactId});                        
                    }
                }
                reqWrapper.caseNumber = Integer.ValueOf(lstApps[0].DCCaseNumber__c);
                reqWrapper.programCode = lstApps[0].ProgramsApplied__c;
                ObjResponse.put(SSP_GlobalConstants.APPLICATION_NUMBER,lstApps[0].Name);
                ObjResponse.put(SSP_GlobalConstants.CASE_NUMBER,Integer.ValueOf(lstApps[0].DCCaseNumber__c));
                ObjResponse.put(SSP_GlobalConstants.RECORD_TYPE,lstApps[0].RecordType.Name);
                
                if(null!=lstApps[0].SSPDCMessage__c){
                    if(SSP_GlobalConstants.SSPDC_F_Message == lstApps[0].SSPDCMessage__c || 
                       SSP_GlobalConstants.SSPDC_HBE3_Message == lstApps[0].SSPDCMessage__c ||
                      SSP_GlobalConstants.SSPDC_HBE1_Message == lstApps[0].SSPDCMessage__c ||
                      SSP_GlobalConstants.SSPDC_LOG2_Message == lstApps[0].SSPDCMessage__c ||
                      SSP_GlobalConstants.SSPDC_LOG3_Message == lstApps[0].SSPDCMessage__c ||
                      SSP_GlobalConstants.SSPDC_LOG4_Message == lstApps[0].SSPDCMessage__c){
                        objResponse.put('bIsSuccess', true); 
                        objResponse.put('underReview', true);             
                    }else if(lstApps[0].SSPDCMessage__c == SSP_GlobalConstants.SSPDC_P_Message){
                        objResponse.put('underReview', false);  
                        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
                        List<Object> serviceResponses = IntegrationFactory.invokeCallout('Reverse_SSP_DC', mapParams);

                        if(serviceResponses!=null && !serviceResponses.isEmpty()){
                            //Shikha: -                             
                            if(!contactRecord.isEmpty()){
                                contactRecord[0].IsDashboardRefreshNeeded__c = true;
                                ESAPI.accessController().updateAsUser(new Map<Id,Contact>(contactRecord), new List<String> {'IsDashboardRefreshNeeded__c'});                                
                    		}
                            wrapperResponse =  (RSSP_DC_Wrapper) serviceResponses[0];
                            if(wrapperResponse.ACKRESPONSE != NULL && wrapperResponse.ACKRESPONSE.AckResponseCode != NULL){
                                objResponse.put('bIsSuccess', false); 
                                objResponse.put('error', wrapperResponse.ACKRESPONSE.AckResponseCode);                            	
                            }else{
                                eligibilityWrapper = wrapperResponse.EligibilitySummaryPayload;
                                ssp_EligibilitySummaryInList = eligibilityWrapper.SSP_EligibilitySummary;
                                SSP_NextStepsController.memberDataWrapper nextStepData = new SSP_NextStepsController.memberDataWrapper ();
                                if(ssp_EligibilitySummaryInList !=NULL && !ssp_EligibilitySummaryInList.isEmpty()){
                                    wrapperList = buildEligibilityWrapper(ssp_EligibilitySummaryInList, lstApps);
                                    nextStepData = SSP_NextStepsController.enableNextSteps(ssp_EligibilitySummaryInList, constructExistingProgramsSet(eligibilityWrapper.HOHReceivingBenefit, lstAppIndividuals[0].SSP_Member__r.IndividualId__c));
                                }
                                if(!wrapperList.isEmpty()){
                                    objResponse.put('bIsSuccess', true); 
                                    objResponse.put('nextStepData',nextStepData);  
                                    objResponse.put('eligibilityData',JSON.serialize(wrapperList));
                                }else{
                                    objResponse.put('bIsSuccess', false); 
                                    objResponse.put('error', '');
                                }
                                // Document Center is open rfi flag - fix for #371968
                                if(eligibilityWrapper.CaseRFIInfo != null && !(eligibilityWrapper.CaseRFIInfo).isEmpty() && ((eligibilityWrapper.CaseRFIInfo)[0]).IsPendingRFIPresentInCase == 'Y'){
                                    objResponse.put('isRFI', true); 
                                }
                                else{
                                    objResponse.put('isRFI', false); 
                                } 
			         //Added for CR 1061
                                 if(eligibilityWrapper.CaseRFIInfo != null && !(eligibilityWrapper.CaseRFIInfo).isEmpty() && ((eligibilityWrapper.CaseRFIInfo)[0]).ShowBanner == 'Y'){
                                    objResponse.put('isBannerShow', true); 
                                }
                                else{
                                    objResponse.put('isBannerShow', false);                                    
                                }
                                
                                // For KI-HIPP Enhacement CR 6.11.1
                                if(eligibilityWrapper.CaseRFIInfo != null && !(eligibilityWrapper.CaseRFIInfo).isEmpty() && ((eligibilityWrapper.CaseRFIInfo)[0]).ReportedPolicyDetails  == 'Y'){
                                    objResponse.put('showReportedPolicyNote', true);
                                }
                                else{
                                    objResponse.put('showReportedPolicyNote', false); 
                                } 
                                
                                 // For KI-HIPP Enhacement CR 6.11.1
                                if(eligibilityWrapper.CaseRFIInfo != null && !(eligibilityWrapper.CaseRFIInfo).isEmpty() && ((eligibilityWrapper.CaseRFIInfo)[0]).ShowKHIPPVerificationText  == 'Y'){
                                    objResponse.put('showVerificationText', true);
                                }
                                else{
                                    objResponse.put('showVerificationText', false); 
                                } 
                            } 
                        }
                    }else if( (lstApps[0].SSPDCMessage__c == SSP_GlobalConstants.SSPDC_LOG1_Message)) {
                        objResponse.put('error', lstApps[0].SSPDCMessage__c);
                    }else{
                        objResponse.put('bIsSuccess', false);
                        objResponse.put('error', lstApps[0].CHFS_Exception_ID__c);
                    }
                }else{
                    objResponse.put('bIsSuccess', false);
                    LOG_LogMessage__c objLogMessage = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, 'SSP_EligibilityResultsCtrl', 'getEligibilityData', 'Timed out Exception' , true);
                   if (Schema.sObjectType.LOG_LogMessage__c.isAccessible()) {
                    LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:objLogMessage.Id LIMIT 1];
                    objResponse.put('error', objLog.Name);
                   }
                }
            }

            /** 2.5	Security Role Matrix and Program Access. */
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_ELIGIBILITY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.ELIGIBILITY_RESULTS_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.SECURITY_MATRIX_NEXT_STEPS, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.NEXT_STEPS_SCREENID, null));
            objResponse.put(SSP_GlobalConstants.HELP_AND_INFO, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.HELP_AND_INFO_SCREENID, null));
            /** */

        }
        catch(Exception ex){
            objResponse.put('bIsSuccess', false); 
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_EligibilityResultsCtrl', 'getEligibilityData', ex.getMessage() , true);
             if (Schema.sObjectType.LOG_LogMessage__c.isAccessible()) {
                LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:lstLogMessages[0].Id LIMIT 1];
                objResponse.put('error',  objLog.Name);
            }
        }
        
        
        return objResponse;
        
    }

    private static Set<String> constructExistingProgramsSet(List<SSP_EligibilitySummaryPayloadWrapper.HOHReceivingBenefitWrapper> HOHReceivingBenefitList, String individualId){
        Set<String> existingAppliedProgramSet = new Set<String>();
        if(String.isNotBlank(individualId) && HOHReceivingBenefitList != null && !HOHReceivingBenefitList.isEmpty()){
            for(SSP_EligibilitySummaryPayloadWrapper.HOHReceivingBenefitWrapper wrap : HOHReceivingBenefitList){
                if(wrap != null && String.isNotBlank(wrap.IndividualId) && String.isNotBlank(wrap.ProgramApplied) && wrap.IndividualId == individualId){
                    existingAppliedProgramSet =new Set<String>(wrap.ProgramApplied.split(';'));
                }
            }
        }
        return existingAppliedProgramSet;
    }


    public static List<WrapperProgramsIndviduals> buildEligibilityWrapper(List<SSP_EligibilitySummaryWrapper> objList, List<SSP_Application__c> appData){

        Map<String, List<SSP_EligibilitySummaryWrapper>> mapProgramCodesVsListRecords= new Map<String, List<SSP_EligibilitySummaryWrapper>>();
        List<WrapperProgramsIndviduals> lstWrapper = new List<WrapperProgramsIndviduals>();
        Map<String,String> mapMemberVsName = new Map<String,String> ();
        Set<Integer> indiviIds = new Set<Integer>();
        Map<String, String> progTypesMap = new Map<String, String>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();        
        
         progTypesMap = SSP_Utility.getPickListValues('SSP_ApplicationIndividual__c','ProgramsApplied__c',null);
      
        if(objList != null && !objList.isempty()){
            //create a map for programCode vs SSP_EligibilitySummaryWrapper 
            for(SSP_EligibilitySummaryWrapper obj : objList){
                indiviIds.add(Integer.ValueOf(obj.IndividualId));
                if( mapProgramCodesVsListRecords.get(obj.ProgramCode) == null ){
                    mapProgramCodesVsListRecords.put(obj.ProgramCode, new List<SSP_EligibilitySummaryWrapper>{obj});
                }
                else{
                    mapProgramCodesVsListRecords.get(obj.ProgramCode).add(obj);
                }
            }
        }
        
        
         lstMembers =  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'IndividualId__c'}, 
                                                                            new Set<String>{'Id','IndividualId__c','Name','FirstName__C','LastName__C'}, 
                                                                            new Map<String, String>{'IndividualId__c'=> String.join(new List<Integer>(indiviIds), ',')}); 


       
        for(SSP_Member__c lisMem:lstMembers){
           mapMemberVsName.put(lisMem.IndividualId__c, (lisMem.FirstName__C+' '+lisMem.LastName__C));
        }        
        
              
        if(!mapProgramCodesVsListRecords.isEmpty()){            
            for (String progCode : mapProgramCodesVsListRecords.keyset()){
                WrapperProgramsIndviduals objWrapper = new WrapperProgramsIndviduals();
                objWrapper.sProgramCode =  progTypesMap.get(progCode);
                objWrapper.applicationId = appData[0].Name;
                objWrapper.caseNumber = String.valueOf(appData[0].DCCaseNumber__c);
               // objWrapper.nextStepsDetails = SSP_NextStepsController.enableNextSteps(objList);

               /* if (!SSP_GlobalConstants.INDIVIDUAL_LEVEL_PROGRAMS_MEDICATE.contains(progCode) && SSP_GlobalConstants.HOUSEHOLD_LEVEL_PROGRAMS.contains(progCode)){    
                    List<WrapperIndividuals> lstChildWrapper = new List<WrapperIndividuals>();
                    List<SSP_EligibilitySummaryWrapper> listIndivs =  mapProgramCodesVsListRecords.get(progCode);
                     WrapperIndividuals objChild = new WrapperIndividuals();
                    for (SSP_EligibilitySummaryWrapper obj : listIndivs){
                     objChild.IndividualNames =  String.isNotBlank(objChild.IndividualNames) ? objChild.IndividualNames + ', ' + mapMemberVsName.get(obj.IndividualId) : mapMemberVsName.get(obj.IndividualId);
                     objChild.IndividualIds = String.isNotBlank(objChild.IndividualIds) ? objChild.IndividualIds + ', ' + obj.IndividualId : obj.IndividualId;
                     objChild.BenefitStatusCode = obj.BenefitStatusCode;
                     objChild.BenefitBeginDate =obj.BenefitBeginDate!=null? Date.valueOf(obj.BenefitBeginDate):null;
                     objChild.BenefitEndDate = obj.BenefitEndDate!=null ?Date.valueOf(obj.BenefitEndDate):null;
                     objChild.EligibleForExpeditedSNAP = (obj.EligibleForExpeditedSNAP==null  || obj.EligibleForExpeditedSNAP==SSP_GlobalConstants.EligibleForExpeditedSNAP_False )? false : true;
                     objChild.EligibleForKIHIPP = (obj.EligibleForKIHIPP==null ||obj.EligibleForKIHIPP==SSP_GlobalConstants.EligibleForKIHIPP_False)?false:true;
                     objChild.IsReferredToFFM = obj.IsReferredToFFM == null || obj.IsReferredToFFM== SSP_GlobalConstants.IsReferredToFFM_False ? false:true;
                     objChild.DenialReason= obj.DenialReason;
                      lstChildWrapper.add(objChild);
                    }
                    objWrapper.lstMemberRecords = lstChildWrapper;
                }
                    
                else */if(SSP_GlobalConstants.INDIVIDUAL_LEVEL_PROGRAMS_MEDICATE.contains(progCode)){
                    List<WrapperIndividuals> lstChildWrapper = new List<WrapperIndividuals>();
                    List<SSP_EligibilitySummaryWrapper> listIndivs =  mapProgramCodesVsListRecords.get(progCode);
                    for (SSP_EligibilitySummaryWrapper obj : listIndivs)
                    {                       
                        WrapperIndividuals objChild = new WrapperIndividuals();
                        objChild.IndividualNames = mapMemberVsName.get(obj.IndividualId);
                        objChild.IndividualIds =  obj.IndividualId;
                        objChild.BenefitStatusCode = obj.BenefitStatusCode;
                        if(null!=obj.BenefitBeginDate)
                            objChild.BenefitBeginDate =Date.valueOf(obj.BenefitBeginDate);
                        if(null!=obj.BenefitEndDate)
                            objChild.BenefitEndDate = Date.valueOf(obj.BenefitEndDate);
                        objChild.EligibleForExpeditedSNAP = (obj.EligibleForExpeditedSNAP==null ||obj.EligibleForExpeditedSNAP==SSP_GlobalConstants.EligibleForExpeditedSNAP_False)?false:true;
                        objChild.EligibleForKIHIPP = (obj.EligibleForKIHIPP==null ||obj.EligibleForKIHIPP==SSP_GlobalConstants.EligibleForKIHIPP_False)?false:true;
                         objChild.IsReferredToFFM =obj.IsReferredToFFM == null || obj.IsReferredToFFM==SSP_GlobalConstants.IsReferredToFFM_False ? false:true;
                         objChild.DenialReason= null!=obj.DenialReason?obj.DenialReason:'';
                        lstChildWrapper.add(objChild);
                    }
                    
                    
                    objWrapper.lstMemberRecords = lstChildWrapper;
                }
                else{
                    List<WrapperIndividuals> lstChildWrapper = new List<WrapperIndividuals>();
                     Map<String,WrapperIndividuals> mapChildWrapper = new Map<String,WrapperIndividuals>();
                    List<SSP_EligibilitySummaryWrapper> listIndivs =  mapProgramCodesVsListRecords.get(progCode);
                    
                    for (SSP_EligibilitySummaryWrapper obj : listIndivs)
                    {  
                        WrapperIndividuals objChild = new WrapperIndividuals();
                        if(mapChildWrapper.get(obj.BenefitStatusCode)==null){
                            objChild.IndividualNames = mapMemberVsName.get(obj.IndividualId);
                            objChild.IndividualIds =  obj.IndividualId;
                            objChild.BenefitStatusCode = obj.BenefitStatusCode;
                            if(null!=obj.BenefitBeginDate)
                                objChild.BenefitBeginDate =Date.valueOf(obj.BenefitBeginDate);
                            if(null!=obj.BenefitEndDate)
                                objChild.BenefitEndDate = Date.valueOf(obj.BenefitEndDate);
                            objChild.EligibleForExpeditedSNAP = (obj.EligibleForExpeditedSNAP==null ||obj.EligibleForExpeditedSNAP==SSP_GlobalConstants.EligibleForExpeditedSNAP_False)?false:true;
                            objChild.EligibleForKIHIPP = (obj.EligibleForKIHIPP==null ||obj.EligibleForKIHIPP==SSP_GlobalConstants.EligibleForKIHIPP_False)?false:true;
                            objChild.IsReferredToFFM =obj.IsReferredToFFM == null || obj.IsReferredToFFM==SSP_GlobalConstants.IsReferredToFFM_False ? false:true;
                            objChild.DenialReason= null!=obj.DenialReason?obj.DenialReason:'';
                            mapChildWrapper.put(obj.BenefitStatusCode,objChild);
                            lstChildWrapper.add(objChild);  
                        }
                        else {
                            objChild= mapChildWrapper.get(obj.BenefitStatusCode);
                            objChild.IndividualNames = objChild.IndividualNames + ', '+  mapMemberVsName.get(obj.IndividualId);
                            objChild.IndividualIds = objChild.IndividualIds+', '+ obj.IndividualId;
                            if(objChild.DenialReason != obj.DenialReason && null!=objChild.DenialReason  && objChild.DenialReason!='')
                                objChild.DenialReason = objChild.DenialReason + ', '+ obj.DenialReason;  
                            else 
                                objChild.DenialReason = obj.DenialReason;
                        }
                    } 
                    
                    
                    objWrapper.lstMemberRecords = lstChildWrapper;
                    }
                
                lstWrapper.add(objWrapper);           
               
            }
           

        }
        
        return lstWrapper;
        
    } 
    
    public class WrapperProgramsIndviduals{
        @AuraEnabled public string sProgramCode;
        @AuraEnabled public String applicationId ;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public List<WrapperIndividuals> lstMemberRecords;
       // @AuraEnabled public SSP_NextStepsController.memberDataWrapper nextStepsDetails ;        
    } 

    public class WrapperIndividuals{
        @AuraEnabled public string IndividualNames; 
        @AuraEnabled public string IndividualIds; 
        @AuraEnabled public string BenefitStatusCode; 
        @AuraEnabled public Date BenefitBeginDate; 
        @AuraEnabled public Date BenefitEndDate; 
        @AuraEnabled public Boolean EligibleForExpeditedSNAP;
        @AuraEnabled public Boolean EligibleForKIHIPP;
        @AuraEnabled public Boolean IsReferredToFFM;
        @AuraEnabled public string DenialReason;   
       }

    
}