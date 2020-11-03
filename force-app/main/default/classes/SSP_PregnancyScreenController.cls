/***************************************************************************************************************************
*   Type        :   Controller Class
*   Name        :   SSP_PregnancyScreenController
*   Create By   :   Shivam Tiwari
*   Create Date :   DEC-20-2019
*   Description :   This class is controller class for SspHealthInformationPregnancy LWC.
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                	Description
*   --------------------------------------------------------------------------------------
*    Shivam Tiwari             DEC-20-2019             Initial Version
*
*****************************************************************************************************************************/
public with sharing class SSP_PregnancyScreenController {
    
    /*
	* method 		: getPregnancyScreenData()
	* @description  : This method is use to get the Today's Date SSP Application Individual data by Application Id and Member Id
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - It is the Application Id
					  String sMemberId - It is the Member Id
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getPregnancyScreenData(String sApplicationId, String sMemberId) {
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        try {
            sApplicationId = String.escapeSingleQuotes(sApplicationId);
            sMemberId = String.escapeSingleQuotes(sMemberId);
        	objResponse.bIsSuccess = true;
        	objResponse.put('todayDate', SSP_Utility.today());        
        	List<SSP_ApplicationIndividual__c> lstIndApp = getAppIndData(sApplicationId, sMemberId);
        	objResponse.put('appIndData', lstIndApp);
        } catch(Exception ex) {
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PregnancyScreenController', 'getPregnancyScreenData', ex.getMessage() , true);
            objResponse.bIsSuccess = false;
            objResponse.addException(ex, lstLogMessages[0].Id);
        }
        return objResponse;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse createTrackDeletion(String applicationId, String memberId){
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            //if(String.isNotBlank(applicationId) && String.isNotBlank(memberId)){
                List<SSP_TrackDeletion__c> trackDelRecList = new List<SSP_TrackDeletion__c>();
                List<String> lstTrackDeletionFields = new List<String>{'SSP_Application__c','DCId__c','EndDate__c','EndReason__c','SSP_Member__c','OtherReason__c','ParentDCId__c','SalesforceId__c','Source__c','SFObject__c'};
                    Boolean viewTrackDeletionFields = ESAPI.accessController().isAuthorizedToView(SSP_TrackDeletion__c.getSObjectType(), lstTrackDeletionFields);            
                List<SSP_Member__c> lstMember  = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                                                                                    new Set<String>{'Id','Name', 'DCPregnancyId__c'}, 
                                                                                    new Map<String, String>{'Id'=> memberId});
                
                if(!lstMember.isEmpty()){
                    if(viewTrackDeletionFields){
                        SSP_TrackDeletion__c trackDelRec = new  SSP_TrackDeletion__c();
                        trackDelRec.DCId__c= lstMember[0].DCPregnancyId__c ;
                        trackDelRec.Source__c='Pregnancy'; //SSP_GlobalConstants.PREGNANCY_SCREEN_ID;
                        trackDelRec.EndDate__c= SSP_Utility.today();
                        trackDelRec.EndReason__c= 'Pregnancy Terminated';
                        trackDelRec.SSP_Application__c=applicationId;
                        trackDelRec.SalesforceId__c= memberId;
                        trackDelRec.SSP_Member__c= memberId;
                        trackDelRec.SFObject__c='SSP_Member__c';
                        trackDelRecList.add(trackDelRec);
                    }
                }
                
                if(null!=trackDelRecList && trackDelRecList.size()>0){
                    ESAPI.accessController().insertAsUser(trackDelRecList, lstTrackDeletionFields);
                    //insert trackDelRecList;
                }
            //}
            toSend.put('bIsSuccess', true);
        }
        catch(Exception ex){
            toSend.put('bIsSuccess', false); 
            toSend.put('error', ex.getMessage()); 
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PregnancyScreenController', 'createTrackDeletion', ex.getMessage() , true);
        }
        return toSend;
    } 
    /*
	* method 		: getAppIndData
	* @description  : This method is use to get the SSP Application Individual data by Application Id and Member Id
	* @author 		: Ashwin Kasture
	* @param 		: String sApplicationId - It is the Application Id
					  String sMemberId - It is the Member Id
	* @return 		: List<SSP_ApplicationIndividual__c>
	* */
    public static List<SSP_ApplicationIndividual__c> getAppIndData(String sApplicationId, String sMemberId) {
        SSP_Utility.isAuthenticatedUser();
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new List<SSP_ApplicationIndividual__c>();
        Map<String, String> conditionMap = new Map<String, String>();
        List<String> lstSSPAppFields = new List<String> {'DCCaseNumber__c'};
		List<String> lstAppIndFields = new List<String> {'Id','SSP_Application__c','SSP_Member__c'};
        Boolean canViewSSPAppFields = ESAPI.accessController().isAuthorizedToView(SSP_Application__c.getSObjectType(), lstSSPAppFields);
        Boolean canViewSSPAppIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstAppIndFields);
        if(canViewSSPAppFields && canViewSSPAppIndFields) {
            Set<String> allApplIndFieldSet = new Set<String> {
                'Id','SSP_Application__c','SSP_Member__c','SSP_Application__r.DCCaseNumber__c','SSP_Member__r.Contact__r.DoesCaseExistForIndividual__c'
            };
			conditionMap.put('SSP_Application__c', sApplicationId);
            conditionMap.put('SSP_Member__c', sMemberId);
            lstAppIndRecords = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'},
                allApplIndFieldSet,
                conditionMap
            );
        }
        return lstAppIndRecords;
    }
}