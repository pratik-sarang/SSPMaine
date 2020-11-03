/*
* classname     :  SSP_RSSPDC_CalloutHelper
* @description  :  Class to handle async callouts
* @author       :  Shrikant Raut   
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public with sharing class SSP_RSSPDC_CalloutHelper implements Queueable, Database.AllowsCallouts {  
    private String interfaceName;  
    private SSP_RSSPDC_RequestWrapper reqWrapper;
    private SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper;
    /*
     * Method Name          : SSP_RSSPDC_CalloutHelper
     * Params               : interfaceName - viewName to be processed
     *                      : reqWrapper - SSP_RSSPDC_RequestWrapper
     * Description          : Constructor
     */
    public SSP_RSSPDC_CalloutHelper(String interfaceName, SSP_RSSPDC_RequestWrapper reqWrapper) {
        this.interfaceName = interfaceName;
        this.reqWrapper = reqWrapper;
    }

     /*
     * Method Name          : SSP_RSSPDC_CalloutHelper
     * Description          : Constructor
     */
    public SSP_RSSPDC_CalloutHelper(String interfaceName, SSP_RSSPDC_RequestWrapper reqWrapper, SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper ) {
        this.interfaceName = interfaceName;
        this.reqWrapper = reqWrapper;
        this.detailsWrapper = detailsWrapper;
    }
    
    /*
     * Description          : Default Constructor
     */
    public SSP_RSSPDC_CalloutHelper() {} 

    /*
     * Method Name          : execute
     * Params               : context - Queable context
     * Description          : Method for enque job and chaining job queue
     */
    public void execute(QueueableContext context) {
        try{
            Map<String, Object> mapParams = new Map<String, Object>();
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> objList = IntegrationFactory.invokeCallout(interfaceName, mapParams);             
            RSSP_DC_Wrapper responseWrapper = (RSSP_DC_Wrapper) objList.get(0);
            if((responseWrapper != null && responseWrapper.payload != null && reqWrapper.applicationID != null) || test.isRunningTest()){
                if(detailsWrapper != null && !detailsWrapper.isCitizenUser){
                    updateRequiredData(reqWrapper.applicationID, detailsWrapper);
                }
                updateContactDetails(reqWrapper.applicationID);
            }
        }
        catch(Exception ex){
            
        }
    }

    /*
     * Method Name          : updateContactDetails
     * Description          : Method to update is used to update details on contact in case of dummy contact
     */ 
    public static Boolean updateContactDetails(String applicationId){
        Boolean result = false;
        try{
            if(String.isNotBlank(applicationId)){
                Set<String> fields = new Set<String>{'SSP_Application__r.Account__c', 'SSP_Member__r.Contact__r.IndividualId__c', 'SSP_Member__r.Contact__r.AccountId', 'SSP_Member__r.Contact__r.FirstName', 'SSP_Member__r.Contact__r.LastName', 'SSP_Member__r.Contact__c', 'SSP_Member__r.BirthDate__c','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','SSP_Member__r.MiddleInitial__c','SSP_Member__r.SuffixCode__c','SSP_Member__r.Email__c','SSP_Member__r.GenderCode__c','SSP_Member__r.SSN__c'};
                List<SSP_ApplicationIndividual__c> hohAppIndvList = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(applicationId, fields);
				
                //If contact's first and last name is DUMMY DATA, update the contact details with member details
                if(hohAppIndvList != null && !hohAppIndvList.isEmpty() && String.isNotBlank(hohAppIndvList[0].SSP_Member__r.Contact__r.FirstName) && String.isNotBlank(hohAppIndvList[0].SSP_Member__r.Contact__r.LastName) &&
                    hohAppIndvList[0].SSP_Member__r.Contact__r.FirstName.equalsIgnoreCase(SSP_GlobalConstants.DUMMY_KEY) && hohAppIndvList[0].SSP_Member__r.Contact__r.LastName.equalsIgnoreCase(SSP_GlobalConstants.DUMMY_KEY)){
                        
                        List<Account> actList = new List<Account>();
                        SSP_ApplicationIndividual__c hohAppIndv = hohAppIndvList[0];
                        Contact con = new Contact(Id = hohAppIndv.SSP_Member__r.Contact__c);
                        con.FirstName = hohAppIndv.SSP_Member__r.FirstName__c;
                        con.LastName = hohAppIndv.SSP_Member__r.LastName__c;
                        con.MiddleName = hohAppIndv.SSP_Member__r.MiddleInitial__c;                    
                        con.SuffixCode__c = hohAppIndv.SSP_Member__r.SuffixCode__c;
                        con.Email = hohAppIndv.SSP_Member__r.Email__c;
                        con.GenderCode__c = hohAppIndv.SSP_Member__r.GenderCode__c ;
                        con.SSN__c = hohAppIndv.SSP_Member__r.SSN__c;
                        con.Birthdate = hohAppIndv.SSP_Member__r.BirthDate__c;
                        if(Schema.sObjectType.Contact.isUpdateable()){ //#377137
                            update con; //#377137
                        }

                        Account conAct = new Account(Id = hohAppIndv.SSP_Member__r.Contact__r.AccountId, Name =  con.FirstName + ' ' + con.LastName );
                        actList.add(conAct);

                        Account appAct = new Account(Id = hohAppIndv.SSP_Application__r.Account__c, Name = 'Application Account for ' + con.FirstName + ' ' + con.LastName + ' ' + 'Household');
                        actList.add(appAct);

                        if(actList != null && !actList.isEmpty() && Schema.sObjectType.Account.isUpdateable()){ //#377137
                            update actList; //#377137                           
                        }
 
                        result = true;
                }
            }
        }
        catch(Exception ex){
            result = false;
        }
        return result;
    } 

    /*
     * Method Name          : updateRequiredData
     * Description          : Method to update required data on to SSP_Member__c and SSP_ApplicationIndividual__c
     */        
    public static void updateRequiredData(String applicationId, SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper){
        if(applicationId != null && !String.isBlank(applicationId) && detailsWrapper != null && detailsWrapper.member != null && detailsWrapper.responseMemberData != null){
            //Fetch HOH App detailsWrapper
            SSP_ApplicationIndividual__c appIndividualData = (SSP_ApplicationIndividualSelector.queryApplicationIndividualData(
                                        new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                        new Set<String>{'Id', 'SSP_Member__c','SSP_Application__c','SSP_Application__r.SectionStatus__c'}, 
                                        new Map<String, String>{'limit'=>'1','SSP_Application__c'=> applicationId, 'IsHeadOfHousehold__c'=> '#true#'}))[0];
            SSP_Member__c memberToUpdate = SSP_HouseHoldSummaryService.saveValueEnteredFromUser(detailsWrapper.member, detailsWrapper.responseMemberData);
            
            if(memberToUpdate != null && Schema.sObjectType.SSP_Member__c.isUpdateable()){ //#377137
                memberToUpdate.Id = appIndividualData.SSP_Member__c;                
                update memberToUpdate; //#377137
            }

            if(detailsWrapper.applicationIndividual != null && Schema.sObjectType.SSP_ApplicationIndividual__c.isUpdateable()){  //#377137
                detailsWrapper.applicationIndividual.Id = appIndividualData.Id;
                update detailsWrapper.applicationIndividual; //#377137
            }
            //#384698 Start
            String selectedRole = SSP_Utility.getSelectedRole();
            if(detailsWrapper.applicationData != null && Schema.sObjectType.SSP_Application__c.isUpdateable()){  
                detailsWrapper.applicationData.Id = appIndividualData.SSP_Application__c;
                //detailsWrapper.applicationData.SectionStatus__c = appIndividualData.SSP_Application__r.SectionStatus__c;
                update detailsWrapper.applicationData; //#384698

                List<NavFlowStatus__c> listNavFlowStatus = SSP_NavFlowStatusSelector.queryFlowStatus(
                                                            new Map<String, String>{'objectName'=>'NavFlowStatus__c','operator'=>'AND'},
                                                            new Set<String>{'Id', 'Member__c'},
                                                            new Map<String, String>{'limit'=>'1','SSPApplication__c'=> applicationId, 'NavFlowName__c'=> 'ContactInformation'});
                if(listNavFlowStatus != null && listNavFlowStatus.size()>0){
                    listNavFlowStatus[0].Member__c = appIndividualData.SSP_Member__c;
                      if(Schema.sObjectType.NavFlowStatus__c.isUpdateable()){
                          update listNavFlowStatus;
                      }
                }
            }
            //#384698 End
        }
    }

}