/*
* classname     : SSP_ProgramSelectionCtrl
* @description  : This class is used to create application with the selected programs and retrieve/update the programs at application level.
* @author       : Nupoor Nimbalkar
* @date         : 13/11/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Nupoor Nimbalkar      13/11/2019      Initial Version
*/
public with sharing class SSP_ProgramSelectionCtrl {
    /*
* method        : getPrograms
* @description  : This method is use to retrieve the programs stored at Application level
* @author       : Nupoor Nimbalkar
* @param        : String sApplicationId - Contains Application Id, String sMemberId - Contains Member Id
* @return       : SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse getPrograms(String sMemberId, String sApplicationId, String mode)
    {
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        List<ProgramsWrapper> applicablePrograms = new List<ProgramsWrapper>();        
        List<SSP_ApplicationIndividual__c> lstAppIndiv = new List<SSP_ApplicationIndividual__c>(); 
        List<SSP_Application__c> lstApplications = new List<SSP_Application__c>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        
        sMemberId = sMemberId!=null ? String.escapeSingleQuotes(sMemberId) : null;
        sApplicationId = sApplicationId!=null ? String.escapeSingleQuotes(sApplicationId) : null;
        
        try{            
            Map<String, String> mapPrograms = SSP_Utility.getPickListValues('SSP_Application__c', 'ProgramsApplied__c', null);
            if((sApplicationId == null || sApplicationId == '') && (mode == null || mode == '' || mode == 'Intake')){
                 SSP_LightningResponse responseForUnSubmittedApplication = new SSP_LightningResponse();
                      List<SSP_DashboardController.AboutToExpireWrapper> lstUnsubmittedApplication =  new List<SSP_DashboardController.AboutToExpireWrapper>();
                    responseForUnSubmittedApplication = SSP_DashboardController.checkHasExistingApplication();
                     if(responseForUnSubmittedApplication != null && responseForUnSubmittedApplication.mapResponse != null && responseForUnSubmittedApplication.mapResponse.get('hasExpiringApplicationsForSelection') != null){
                       lstUnsubmittedApplication =  (List<SSP_DashboardController.AboutToExpireWrapper>)responseForUnSubmittedApplication.mapResponse.get('hasExpiringApplicationsForSelection');
                     }
                     if((!lstUnsubmittedApplication.isEmpty()) && lstUnsubmittedApplication[0].applicationId != null){
                         sApplicationId = lstUnsubmittedApplication[0].applicationId;
                     }
                     
                 }
            if(sMemberId != null && sMemberId != ''){                
                lstAppIndiv = SSP_ProgramSelectionService.getProgsAppIndividual(sMemberId);                                
                lstMembers = SSP_ProgramSelectionService.getMemberData(sMemberId);
            }
            
            if(sApplicationId != null && sApplicationId != ''){
                lstApplications = SSP_ProgramSelectionService.getApplicationData(sApplicationId); 
                objResponse.put('applicationId', sApplicationId); 
            } 
            
            applicablePrograms = SSP_ProgramSelectionService.getApplicablePrograms(new Map<String, String>{'applicationId'=>sApplicationId,'mode'=>mode}, lstApplications, mapPrograms);
            
            objResponse.bIsSuccess = true;            
            objResponse.put('programs', applicablePrograms); 
            
            /** 2.5	Security Role Matrix and Program Access. */
            objResponse.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.PROGRAM_SELECTION_SCREENID, null));
            /** */
        }catch(Exception e){
            objResponse.bIsSuccess = false;
            objResponse.put('ERROR',e.getMessage());
            LOG_LogMessageUtility.logMessage(e, 'SSP_ProgramSelectionCtrl', 'getPrograms', e.getMessage() , true);
        }
        return objResponse;
    }
    
    /*
    * method        : updatePrograms
    * @description  : This method is used to update the programs at Application level. Create an application if the program selection 
    *                 is for new application. Create account, ACR and Application Individual records.
    * @author       : Shrikant Raut
    * @param        : List<String> selectedPrograms - programs selected at application level,
    *                 String sApplicationId - Contains Application Id, 
    *                 String sMemberId - Contains Member Id
    * @return       : SSP_LightningResponse
    * */
    @AuraEnabled
    public static SSP_LightningResponse updatePrograms(Map<String, String> detailMap, String selectedPrograms){              
        SSP_LightningResponse response = new SSP_LightningResponse();
        String sApplicationId = detailMap != null && detailMap.containsKey(SSP_GlobalConstants.SSP_APPLICATION_ID) ? detailMap.get(SSP_GlobalConstants.SSP_APPLICATION_ID) : null;
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        SSP_ProgramSelectionService.DetailsWrapper wrap = new SSP_ProgramSelectionService.DetailsWrapper();        
        wrap.mode = detailMap != null && detailMap.containsKey(SSP_GlobalConstants.SSP_MODE) ? detailMap.get(SSP_GlobalConstants.SSP_MODE) : null;
        wrap.caseNo = detailMap != null && detailMap.containsKey(SSP_GlobalConstants.SSP_CASE_NO) ? detailMap.get(SSP_GlobalConstants.SSP_CASE_NO) : null;
        
        Savepoint sp;
        try{            
            wrap.loggedInUser = (SSP_UserSelector.queryUserData(new Map<String, String>{'objectName'=>'User','operator'=>'AND'}, 
                                                                        new Set<String>{'Id', 'ContactId','Profile.Name','SelectedRole__c','ImpersonatedIndividualId__c','Contact.FirstName','Contact.LastName','Contact.IndividualId__c','Contact.DoesCaseExistForIndividual__c'}, 
                                                                        new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}))[0];
            wrap.programs = SSP_ProgramSelectionService.constructProgramsString(selectedPrograms);   
            if(wrap.programs != null && wrap.loggedInUser != null){                
                //Update programs on existing application
                if(sApplicationId != null && wrap.loggedInUser != null){
                    sp = Database.setSavepoint(); 
                    List<SSP_Application__c> applicationList = new List<SSP_Application__c>{
                        new SSP_Application__c(Id = sApplicationId, ProgramsApplied__c = wrap.programs, Status__c = 'UN')
                    };
                    //response = SSP_ApplicationSummaryController.fireReviewRequiredOnProgramChange((Id)sApplicationId, wrap.programs.split(';'));
                    //SSP_ApplicationSummaryController.markSectionsReviewRequired((Id)sApplicationId, 'SSP_APP_HHMembersSummary;REPS_Home');
                    ESAPI.accessController().updateAsUser(new Map<ID,SSP_Application__c>(applicationList), SSP_Utility.getFieldsNamesList (applicationList));
                    SSP_ProgramSelectionService.resetDashboardRefreshFlag(wrap.loggedInUser.ContactId);//WIP                                 
                }
                //Handle program selection for first time
                else{
                    //Setting does case exist on wrapper variable is to be set - WIP
                    List<Contact> contactList; 
                    wrap.individualId = SSP_Utility.getIndividualId(); //Impersonated or self depending on the selected role and profile
                    if(wrap.individualId != null && !String.isBlank(wrap.individualId)){                    
                        contactList = SSP_ProgramSelectionService.queryContactDetails(new Map<String, String>{'IndividualId__c'=> wrap.individualId});
                    }

                    wrap.individualContact = (contactList != null && !contactList.isEmpty()) ? contactList[0] : null; 
                    wrap.doesCaseExists = (wrap.individualContact != null) ? wrap.individualContact.DoesCaseExistForIndividual__c : false;//WIP
                    wrap = SSP_ProgramSelectionService.identifyOperationType(wrap, response);//(loggedInUser, programs, caseNo, mode, doesCaseExists, individualContact)
                    response = wrap.response == null ? SSP_ProgramSelectionService.triggerProgramSelectionOps(wrap, response) : wrap.response;
                }
            }
        }
        catch(Exception ex){
            Database.rollback(sp);
            response.put('ERROR', ex.getStackTraceString()+ ' //Msg  : '+ex.getMessage());        
            
            
        }
        return response;
    }
    
        @AuraEnabled
    public static SSP_LightningResponse getHouseholdMemebers(Id applicationId) {
        SSP_Utility.isAuthenticatedUser(); //Iron Dome fix
        SSP_LightningResponse response = new SSP_LightningResponse();
        try {
            List<SSP_ApplicationIndividual__c> individuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(null, applicationId, new Set<String>());
            List<Id> members = new List<Id>();
            Id hohId;
            for(SSP_ApplicationIndividual__c individual: individuals) {
                if(individual.IsHeadOfHousehold__c == false) {
                    members.add(individual.SSP_Member__c);
                }
                else {
                    hohId = individual.SSP_Member__c;
                }
            }
            List<Id> sortedMembers = new List<Id>{hohId};
            sortedMembers.addAll(members);
            response.put('members', sortedMembers);
        }
        catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, '', 'getHouseholdMemebers', ex.getMessage() , true);
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }

    
    /*
    * method        : ProgramsWrapper
    * @description  : Wrapper structure for programs to show on Program Selection screen
    * @author       : Nupoor Nimbalkar
    * @param        : 
    * @return       : 
    * */
    public class ProgramsWrapper {
        @AuraEnabled public String programLabel {get;set;}
        @AuraEnabled public String programValue {get;set;}
        @AuraEnabled public Boolean isDisabled {get;set;}
        @AuraEnabled public Boolean isSelected {get;set;}
        @AuraEnabled public Boolean stampOnApplication {get;set;}
    }
}