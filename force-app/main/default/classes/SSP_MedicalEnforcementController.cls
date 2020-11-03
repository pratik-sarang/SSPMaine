/*
* classname     :  SSP_MedicalEnforcementController {
* @description  : Controller Class For Medical Enforcement Screen
* @author       :  Kireeti Gora
* @date         :  12/19/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------*/

public with sharing class SSP_MedicalEnforcementController {
    
    /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         12/19/2019
    * @methodname   getMedicalEnforcementDetailsWithId
    * @description  This methods is to query records related to SSP_NonCustodialParent__c object
    * @return       SSP_LightningResponse
    *****************************************************************************************************/ 
    @AuraEnabled(cacheable=true)
    public static SSP_LightningResponse getMedicalEnforcementDetailsWithId(String sspApplicationId, String sspMemberId) {
        SSP_Utility.isAuthenticatedUser();
        sspApplicationId = String.escapeSingleQuotes(sspApplicationId);
        sspMemberId = String.escapeSingleQuotes(sspMemberId);
        SSP_LightningResponse response = new SSP_LightningResponse();
        
        List<SSP_ApplicationIndividual__c> lstApplicationIndividual = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> lstmember = new List<SSP_Member__c>();
        List<SSP_NoncustodialRelationship__c> lstNonCustodialRelationship = new List<SSP_NoncustodialRelationship__c>();
        
        try {
            if(sspMemberId != null && sspMemberId != '' ) {
                   // Start - CD2 Security Fixes
                   lstNonCustodialRelationship = SSP_SharingBypassFetcher.fetchRecords (
                       new Map<String, String> {'objectName'=>'SSP_NoncustodialRelationship__c','operator'=>'AND'},
                       new Set<String> {'Id','SSP_Member__c','HasChildSupportToggle__c','GoodCauseCode__c','MedicalSupportComments__c'},
                       new Map<String, String> {'limit'=>'1','SSP_Member__c'=> sspMemberId}
                   );
                   // End - CD2 Security Fixes
                   if(!lstNonCustodialRelationship.isEmpty()) {                       
                       response.put('nonCustodialRelationshipRecord',JSON.serialize(lstNonCustodialRelationship[0]));
                   }
            }
            if(sspApplicationId != null && sspMemberId != null) {
                List<SSP_ApplicationIndividual__c> lstApplicationIndividualForProgram = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                    (Id)sspMemberId,
                    (Id)sspApplicationId,
                    null
                );
                if(!lstApplicationIndividualForProgram.isEmpty()) {
                    response.put('applicationIndividualPrograms', lstApplicationIndividualForProgram);
                }
            }
            if(sspApplicationId != null && sspMemberId != null) {
                List<SSP_ApplicationIndividual__c> lstApplicationHousehold =
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(
                        new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
						new Set<String>{'Id','SSP_ApplicationIndividual__c.Name', 'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c','SSP_Application__r.ProgramsApplied__c'}, 
                        new Map<String, String>{'limit'=>'1','SSP_Application__c'=> sspApplicationId,'SSP_ApplicationIndividual__c.isHeadOfHousehold__c'=>'true'}
                    );
                if(!lstApplicationHousehold.isEmpty()) {
                    response.put('headOfHousehold',lstApplicationHousehold);  
                }                
            }            
        } catch(Exception e) {
          LOG_LogMessageUtility.logMessage(e, 'SSP_MedicalEnforcementController', 'getMedicalEnforcementDetailsWithId', 'Failed to fetch Medical Enforcement Details', true);
        }        
        return response;
    }
     /***************************************************************************************************
    * @author       Kireeti Gora
    * @date         12/19/2019
    * @methodname   updateNonCustodRecords
    * @description  This methods upserts the data given by the user on non-custodial screen,
    * @return      Boolean
    *****************************************************************************************************/ 
    @auraEnabled
    public static Boolean updateNonCustodRecords(String nonCustodialJSON){     
        SSP_Utility.isAuthenticatedUser();     
        SSP_NoncustodialRelationship__c objNonCustodialParent= New SSP_NoncustodialRelationship__c();
        List<SSP_NoncustodialRelationship__c> lstNonCustodialRelationship = new List<SSP_NoncustodialRelationship__c>();
        List<SSP_NoncustodialRelationship__c> lstNonCustodialRelationshipToUpsert = new List<SSP_NoncustodialRelationship__c>();
        Boolean result = true;
        try{
            if(nonCustodialJSON != null && Schema.sObjectType.SSP_NoncustodialRelationship__c.isUpdateable()){
                
                objNonCustodialParent = (SSP_NoncustodialRelationship__c)JSON.deserialize(nonCustodialJSON, SSP_NoncustodialRelationship__c.class);                    
                  
                if(objNonCustodialParent != null && objNonCustodialParent.SSP_Member__c != null){
					// Start - CD2 Security Fixes
                    lstNonCustodialRelationship = SSP_SharingBypassFetcher.fetchRecords (
                       new Map<String, String> {'objectName'=>'SSP_NoncustodialRelationship__c','operator'=>'AND'},
                       new Set<String> {'Id','SSP_Member__c','HasChildSupportToggle__c','GoodCauseCode__c','MedicalSupportComments__c'},
                       new Map<String, String> {'limit'=>'100','SSP_Member__c'=> objNonCustodialParent.SSP_Member__c}
                   );                    
                    // End - CD2 Security Fixes
                }
                for(SSP_NoncustodialRelationship__c objNonCustodialParentRelation :lstNonCustodialRelationship){
                     SSP_NoncustodialRelationship__c objNonCustodialParentToUpdate = New SSP_NoncustodialRelationship__c();
                    objNonCustodialParentToUpdate.id = objNonCustodialParentRelation.id;
                    
                    objNonCustodialParentToUpdate.GoodCauseCode__c = objNonCustodialParent.GoodCauseCode__c;
                    if(SSP_NoncustodialRelationship__c.HasChildSupportToggle__c != null){
                    objNonCustodialParentToUpdate.HasChildSupportToggle__c = objNonCustodialParent.HasChildSupportToggle__c;
                        }
                    
                    objNonCustodialParentToUpdate.MedicalSupportComments__c = objNonCustodialParent.MedicalSupportComments__c;
                    lstNonCustodialRelationshipToUpsert.add(objNonCustodialParentToUpdate);
                    
                }
                if(!lstNonCustodialRelationshipToUpsert.isEmpty()){
                	SSP_SharingBypassFetcher.dmlOnGenericSobjectList(lstNonCustodialRelationshipToUpsert, 'update', 'SSP_NoncustodialRelationship__c'); // CD2 Security Fixes
                }
                if(objNonCustodialParent != null && objNonCustodialParent.id == null){
                	SSP_SharingBypassFetcher.dmlOnGenericSobjectList(new List<sobject>{objNonCustodialParent}, 'insert', 'SSP_NoncustodialRelationship__c'); // CD2 Security Fixes
                }
            }
        }
        catch(Exception ex){                       
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'SSP_MedicalEnforcementController', 'updateNonCustodRecords', ex.getMessage(), true);
        }
        return result;
    }
    
    
}