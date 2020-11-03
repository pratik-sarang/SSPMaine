/***************************************************************************************************************************
*   Type         :   Controller Class
*   Name         :   SSP_RelationshipInformationController
*   Created By   :   Sanchita Tibrewala and Shivam Tiwari
*   Created Date :   12/01/2019
*   Description  :   Controller for Relationship Information Page
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Sanchita                 12/01/2019     Initial Version
*****************************************************************************************************************************/
public with sharing class SSP_RelationshipInformationController {
    
/********************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/01/2019
* @methodname   getRelatives
* @description  This method fetches the Relationship Information for a member
* @param        String, String
* @return       SSP_LightningResponse
********************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getRelatives(String memberId, String applicationId)
    {        
            SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse toSend = new SSP_LightningResponse(); 
        try{
            List<SSP_RelationshipWrapper> relativesWrapperList = new List<SSP_RelationshipWrapper> ();
            List<SSP_Relationship__c> sspRelationshipList = new List<SSP_Relationship__c> ();
            Map<Id, SSP_Relationship__c> sspRelationshipMap = new Map<Id, SSP_Relationship__c> ();
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c> ();
            Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
            List<SSP_Relationship__c> sspRelativesRelationshipList = new List<SSP_Relationship__c> ();
            Map<Id, SSP_Relationship__c> sspRelativesRelationshipMap = new Map<Id, SSP_Relationship__c> ();
            SSP_ApplicationIndividual__c currentUser;
            Map<String,String> getValueMap = new Map<String,String> ();
            if(String.isNotBlank(memberId) && String.isNotBlank(applicationId)){
                Schema.DescribeFieldResult fieldPicklist = SSP_Relationship__c.RelationshipType__c.getDescribe();
                List<Schema.PicklistEntry> picklistValues = fieldPicklist.getPicklistValues();
                getValueMap = new Map<String,String>();
                for(Schema.PicklistEntry val : picklistValues) {
                    getValueMap.put(val.getLabel(), val.getValue());        
                }
                sspRelationshipList = 
                    SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','operator'=>'AND'}, 
                                                                   new Set<String>{'Id', 'SSP_Member__r.FirstName__c', 'SSP_Member__r.LastName__c', 'SSP_Member__r.Age__c', 'SSP_Member__r.GenderCode__c',
                                                                       'SSP_MemberRelatedTo__r.FirstName__c', 'SSP_MemberRelatedTo__r.LastName__c', 'SSP_MemberRelatedTo__r.Age__c',
                                                                       'RelationshipType__c', 'IsActingParentToggle__c', 'IsCareTakerToggle__c', 
                                                                       'IntendToPursueLegalCustodyToggle__c'}, 
                                                                   new Map<String, String>{'limit'=>'100','SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
                
                sspApplicationIndividualList = [SELECT Id,SSP_Application__c,SSP_Member__c,SSP_Member__r.FirstName__c,SSP_Member__r.LastName__c,
                                                SSP_Member__r.Age__c, SSP_Member__r.GenderCode__c, SSP_Application__r.ProgramsApplied__c, 
                                                ProgramsApplied__c,MemberProgramsApplied__c,CreatedDate,SSP_Member__r.MiddleInitial__c,SSP_Member__r.SuffixCode__c
                                                FROM SSP_ApplicationIndividual__c
                                                WHERE MemberStatus__c != 'Removed' AND SSP_Application__c = :String.escapeSingleQuotes(applicationId)
                                                ORDER BY IsHeadOfHousehold__c DESC,SSP_Member__r.IndividualId__c];
               
                
                sspRelativesRelationshipList = 
                    SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','operator'=>'AND'}, 
                                                                   new Set<String>{'Id', 'SSP_MemberRelatedTo__c', 'SSP_Member__c', 'RelationshipType__c'}, 
                                                                   new Map<String, String>{'limit'=>'100','SSP_MemberRelatedTo__c'=> String.escapeSingleQuotes(memberId)});
            }
            if(!sspApplicationIndividualList.isEmpty()){
                for(SSP_ApplicationIndividual__c rel : sspApplicationIndividualList){
                    if(rel.SSP_Member__c != memberId){
                        sspApplicationIndividualMap.put(rel.SSP_Member__c, rel);
                    }
                    else{
                        currentUser = rel;
                    }
                }
            }
            if(!sspRelationshipList.isEmpty()){
                for(SSP_Relationship__c rel : sspRelationshipList){
                    sspRelationshipMap.put(rel.SSP_MemberRelatedTo__c, rel); 
                }                   
            }
            if(!sspRelativesRelationshipList.isEmpty()){    
                for(SSP_Relationship__c rel : sspRelativesRelationshipList){
                    sspRelativesRelationshipMap.put(rel.SSP_Member__c, rel);
                }  
            }
            relativesWrapperList = createWrapper(sspRelationshipMap, sspApplicationIndividualMap, currentUser, sspRelativesRelationshipMap);
            toSend.put('relativesWrapperList', relativesWrapperList);
            toSend.put('relationshipTypeCodeValues',getValueMap);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'getRelatives', ex.getMessage() , true);
            toSend.bIsSuccess = false;
            toSend.addException(ex, lstLogMessages[0].Id);
        } 
        return toSend;
    } 
    
/**********************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/09/2019
* @methodname   saveRelatives
* @description  This method saves all the Relationship Information retrieved from the component
* @param        String, String, String
* @return       Boolean
***********************************************************************************************/
    @AuraEnabled
    public static void saveRelatives(String memberId, String applicationId, String relList, String mode){
            SSP_Utility.isAuthenticatedUser();
        try{
            List<SSP_RelationshipWrapper> relInfo = new List<SSP_RelationshipWrapper> ();
            List<SSP_Relationship__c> sspRelativesRelationshipList = new List<SSP_Relationship__c> ();
            Map<Id, SSP_Relationship__c> sspRelativesRelationshipMap = new Map<Id, SSP_Relationship__c> ();
            List<SSP_Relationship__c> sspRelationshipList = new List<SSP_Relationship__c> ();
            Map<Id, SSP_Relationship__c> sspRelationshipMap = new Map<Id, SSP_Relationship__c> ();
            List<SSP_ApplicationIndividual__c> sspApplicationIndividualList = new List<SSP_ApplicationIndividual__c> ();
            Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
            SSP_Relationship__c reverseRelationshipRecord;
            Map<String,String> getValueMap = new Map<String,String> ();
            SSP_Relationship__c currentRelationship;
            if(String.isNotBlank(memberId) && String.isNotBlank(applicationId) && String.isNotBlank(relList)){
                Schema.DescribeFieldResult fieldPicklist = SSP_Relationship__c.RelationshipType__c.getDescribe();
                List<Schema.PicklistEntry> picklistValues = fieldPicklist.getPicklistValues();
                getValueMap = new Map<String,String>();
                for(Schema.PicklistEntry val : picklistValues) {
                    getValueMap.put(val.getLabel(), val.getValue());        
                }
                relInfo = (List<SSP_RelationshipWrapper>)JSON.deserialize(relList, List<SSP_RelationshipWrapper>.class);
                sspRelationshipList = 
                    SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','operator'=>'AND'}, 
                                                                   new Set<String>{'Id', 'SSP_Member__c', 'SSP_MemberRelatedTo__c',
                                                                       'RelationshipType__c', 'IsActingParentToggle__c', 'IsCareTakerToggle__c', 
                                                                           'IntendToPursueLegalCustodyToggle__c','SSP_Member__r.Age__c'}, 
                                                                   new Map<String, String>{'limit'=>'100','SSP_Member__c'=> String.escapeSingleQuotes(memberId)});
                sspRelativesRelationshipList = 
                        SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','operator'=>'AND'}, 
                                                                           new Set<String>{'Id', 'SSP_MemberRelatedTo__c', 'SSP_Member__c', 'SSP_Member__r.GenderCode__c', 'RelationshipType__c','SSP_Member__r.Age__c'}, 
                                                                       new Map<String, String>{'limit'=>'100','SSP_MemberRelatedTo__c'=> String.escapeSingleQuotes(memberId)});
                sspApplicationIndividualList = 
                    SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND', 'MemberStatus__c' => '!='}, 
                                                                                         new Set<String>{'Id', 'SSP_Member__c', 'SSP_Application__c','SSP_Member__r.GenderCode__c','SSP_Member__r.Age__c'}, 
                                                                                     new Map<String, String>{'limit'=>'100','SSP_Application__c'=> String.escapeSingleQuotes(applicationId),'MemberStatus__c'=> 'Removed'});
            }

            if(!sspRelativesRelationshipList.isEmpty()){
                sspRelativesRelationshipMap = new Map<Id, SSP_Relationship__c> ();
                for(SSP_Relationship__c rel : sspRelativesRelationshipList){
                    sspRelativesRelationshipMap.put(rel.SSP_Member__c, rel);
                }
            }
            
            Map<String,Reverse_Relationship__mdt> reverseMDMap = new Map<String,Reverse_Relationship__mdt>();
            for(Reverse_Relationship__mdt revRel : getRelationshipMetadata()){
                reverseMDMap.put(revRel.MasterLabel, revRel);
            }
            
            List<SSP_Relationship__c> updatedRelationshipList = new List<SSP_Relationship__c> ();
            
            if(!sspRelationshipList.isEmpty()){
                sspRelationshipMap = new Map<Id, SSP_Relationship__c> ();
                for(SSP_Relationship__c rel : sspRelationshipList){
                    sspRelationshipMap.put(rel.SSP_MemberRelatedTo__c, rel);
                }
            }
            if(!sspApplicationIndividualList.isEmpty()){
                sspApplicationIndividualMap = new Map<Id, SSP_ApplicationIndividual__c> ();
                for(SSP_ApplicationIndividual__c rel : sspApplicationIndividualList){
                    if(rel.SSP_Member__c != memberId){
                        sspApplicationIndividualMap.put(rel.SSP_Member__c, rel);
                    }
                }
            }
                
            for(SSP_RelationshipWrapper sspRelationship : relInfo){
                if(!sspRelationshipList.isEmpty() && sspRelationshipMap.get(sspRelationship.memberId) != null){
                    currentRelationship = sspRelationshipMap.get(sspRelationship.memberId);
                }
                else{
                    currentRelationship = new SSP_Relationship__c();
                    if(sspApplicationIndividualMap.get(sspRelationship.memberId) != null){
                        currentRelationship.SSP_MemberRelatedTo__c = sspApplicationIndividualMap.get(sspRelationship.memberId).SSP_Member__c;
                    }
                    currentRelationship.SSP_Member__c = memberId;
                }
                if(getValueMap.get(sspRelationship.relationshipType) != null){
                    currentRelationship.RelationshipType__c = getValueMap.get(sspRelationship.relationshipType);
                }
                else{
                    currentRelationship.RelationshipType__c = sspRelationship.relationshipType;
                }
                
                if(!sspRelativesRelationshipMap.isEmpty() && sspRelativesRelationshipMap.get(currentRelationship.SSP_MemberRelatedTo__c) != Null){
                    reverseRelationshipRecord = sspRelativesRelationshipMap.get(currentRelationship.SSP_MemberRelatedTo__c);
                }
                else{
                    reverseRelationshipRecord = new SSP_Relationship__c();
                    if(sspApplicationIndividualMap.get(sspRelationship.memberId) != null){
                        reverseRelationshipRecord.SSP_Member__c = sspApplicationIndividualMap.get(sspRelationship.memberId).SSP_Member__c;
                    }
                    reverseRelationshipRecord.SSP_MemberRelatedTo__c = memberId;
                }
                Reverse_Relationship__mdt result = reverseMDMap.get(currentRelationship.RelationshipType__c);
                String RelationshipTypeLabel = reverseRelationship(result, sspApplicationIndividualMap.get(sspRelationship.memberId).SSP_Member__r.GenderCode__c);
                reverseRelationshipRecord.RelationshipType__c = getValueMap.get(RelationshipTypeLabel);
                updatedRelationshipList.add(reverseRelationshipRecord);
                
                currentRelationship.IsActingParentToggle__c = sspRelationship.isActingParent;
                currentRelationship.IsCareTakerToggle__c = sspRelationship.isCareTaker;
                currentRelationship.IntendToPursueLegalCustodyToggle__c = sspRelationship.intendToPursueLegalCustody;
                updatedRelationshipList.add(currentRelationship);
            }
                Set<String> memberIdSet = new Set<String>();
                for(SSP_Relationship__c relationship : updatedRelationshipList){
                    memberIdSet.add(relationship.SSP_Member__c);
                }
                List<SSP_Relationship__c> oldRelationshipValue = 
                    SSP_RelationshipSelector.queryRelationshipData(new Map<String, String>{'objectName'=>'SSP_Relationship__c','operator'=>'AND','IN'=>'SSP_Member__c'}, 
                                                                       new Set<String>{'Id', 'SSP_Member__c', 'SSP_MemberRelatedTo__c','RelationshipType__c'}, 
                                                                       new Map<String, String>{'limit'=>'100','SSP_Member__c'=> String.join(new List<String>(memberIdSet),',')});
                    //[SELECT Id, SSP_Member__c, SSP_MemberRelatedTo__c, RelationshipType__c FROM SSP_Relationship__c WHERE SSP_Member__c IN :memberIdSet];
            if(updatedRelationshipList != null){
                //ESAPI.accessController().upsertAsUser(updatedRelationshipList, SSP_Utility.getFieldsNamesList (updatedRelationshipList));
                SSP_GenericDMLHelper.upsertRecords(updatedRelationshipList,new List<String>{'RelationshipType__c','IsActingParentToggle__c','IsCareTakerToggle__c','IntendToPursueLegalCustodyToggle__c'});//Added for Perf fix - Keshav
            }
                reviewAbsentParent(updatedRelationshipList,oldRelationshipValue,applicationId, memberId, mode);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'saveRelatives', ex.getMessage() , true);
        }
    }    
    
        public static void reviewAbsentParent(List<SSP_Relationship__c> updatedRelationshipList, List<SSP_Relationship__c> oldRelationshipValue,
                                              String appId, String memId, String mode){
                Set<String> memberIdSet = new Set<String>();
                Set<String> reviewRequiredMemberSet = new Set<String>();
                Set<String> reviewReqFalseMemberSet = new Set<String>();
                List<SSP_Relationship__c> currentMemberRelationshipList = new List<SSP_Relationship__c> ();//Relationships of current member
                List<SSP_Relationship__c> reverseRelationshipList = new List<SSP_Relationship__c> ();//Reverse Relationships of current member 
                Map<Id, SSP_Relationship__c> reverseRelationshipMap = new Map<Id, SSP_Relationship__c> ();//Reverse Relationships Map of current member
                Set<String> childrenOfCurrentmember = new Set<String>();//List of Member with changed relationships who were either previously or are currently children of current member
                for(SSP_Relationship__c relationship : updatedRelationshipList){
                    memberIdSet.add(relationship.SSP_Member__c);
                    if(relationship.SSP_Member__c == memId){
                        currentMemberRelationshipList.add(relationship);
                    }
                    else{
                       reverseRelationshipList.add(relationship);
                    }
                }
                
                if(!reverseRelationshipList.isEmpty()){
                    reverseRelationshipMap = new Map<Id, SSP_Relationship__c> ();
                    for(SSP_Relationship__c rel : reverseRelationshipList){
                        reverseRelationshipMap.put(rel.SSP_Member__c, rel);
                    }
                }
                                                  
                Map<String,SSP_Relationship__c> oldValueMap = new Map<String,SSP_Relationship__c>();            
                for(SSP_Relationship__c rel : oldRelationshipValue){
                    oldValueMap.put(rel.SSP_Member__c + (String)rel.SSP_MemberRelatedTo__c, rel);
                }
                Integer oldAbsentParentCount = 2;
                Integer newAbsentParentCount = 2;                                 
                for(SSP_Relationship__c relationship : currentMemberRelationshipList){ //Changes in child's screen
                    String relationshipType = relationship.RelationshipType__c;
                    String keyValue = relationship.SSP_Member__c + (String)relationship.SSP_MemberRelatedTo__c;
                    if(oldValueMap.containskey(keyValue)){
                        String oldRelationshipType = oldValueMap.get(keyValue).RelationshipType__c;
                        if(SSP_GlobalConstants.CHILD_CODE_SET.contains(relationshipType) && 
                              relationship.SSP_Member__r.Age__c <= 18){
                               newAbsentParentCount = newAbsentParentCount - 1;
                           }
                    	if(SSP_GlobalConstants.CHILD_CODE_SET.contains(oldRelationshipType) && 
                              relationship.SSP_Member__r.Age__c <= 18){
                               oldAbsentParentCount = oldAbsentParentCount - 1;
                           }
                        if(oldRelationshipType != relationshipType && 
                          (SSP_GlobalConstants.PARENT_CODE_SET.contains(oldRelationshipType) ||
                           SSP_GlobalConstants.PARENT_CODE_SET.contains(relationshipType)) &&
                           reverseRelationshipMap.containsKey(relationship.SSP_MemberRelatedTo__c) &&
                           reverseRelationshipMap.get(relationship.SSP_MemberRelatedTo__c).SSP_Member__r.Age__c <= 18){
                            childrenOfCurrentmember.add(relationship.SSP_MemberRelatedTo__c);
                        }                        
                    }                    
                }
                
                if(newAbsentParentCount != oldAbsentParentCount && newAbsentParentCount != 0){
                    reviewRequiredMemberSet.add(memId);
                }
                else if(newAbsentParentCount == 0){
                    reviewReqFalseMemberSet.add(memId);                               
                }
                
                for(String childId : childrenOfCurrentmember){ //change in parent's screen
                    Integer absentParentCount = 2;
                    if(SSP_GlobalConstants.CHILD_CODE_SET.contains(reverseRelationshipMap.get(childId).RelationshipType__c)){
                        absentParentCount = absentParentCount - 1;
                    }
                    for(String eachMember : memberIdSet){
                        String keyValue = childId + (String)eachMember;
                        if(oldValueMap.containskey(keyValue) && eachMember != memId &&
                          SSP_GlobalConstants.CHILD_CODE_SET.contains(oldValueMap.get(keyValue).RelationshipType__c)){
                        	absentParentCount = absentParentCount - 1;
                        }
                    }
                    if(absentParentCount != 0){
                        reviewRequiredMemberSet.add(childId);
                    }
                    else{
                        reviewReqFalseMemberSet.add(childId);
                    }
                }                                    
                
            if(!reviewRequiredMemberSet.isEmpty() || !reviewReqFalseMemberSet.isEmpty()){
                List<String> reviewMemberList = new List<String>();                
                reviewMemberList.addAll(reviewRequiredMemberSet);
                String reviewRule ;                
                if(!reviewRequiredMemberSet.isEmpty()){
                    reviewMemberList.clear();
                    reviewMemberList.addAll(reviewRequiredMemberSet);
                 	reviewRule = 'removeParentRelationship,true,'+String.join(reviewMemberList,','); 
                    List<String> reviewRequiredList = new List<String>{reviewRule};
                	SSP_RulesEngine.getRRTriggerRules(appId , memId, new List<String> {'SSP_APP_RTF_Relationships'}, 
                                             reviewRequiredList, mode);
                }    
                if(!reviewReqFalseMemberSet.isEmpty()){
					reviewMemberList.clear(); 
                    reviewMemberList.addAll(reviewReqFalseMemberSet);
                    reviewRule = 'removeParentRelationship,false,'+String.join(reviewMemberList,',');  
                    List<String> reviewRequiredList = new List<String>{reviewRule};
                	SSP_RulesEngine.getRRTriggerRules(appId , memId, new List<String> {'SSP_APP_RTF_Relationships'}, 
                                             reviewRequiredList, mode);
                }   
            }                               
        }
/**********************************************************************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/13/2019
* @methodname   createWrapper
* @description  This method creates the wrapper that is sent to the screen
* @param        Map<Id, SSP_Relationship__c>, Map<Id, SSP_ApplicationIndividual__c>, SSP_ApplicationIndividual__c, Map<Id, SSP_Relationship__c>
* @return       List<SSP_RelationshipWrapper>
**********************************************************************************************************************************************/
    public static List<SSP_RelationshipWrapper> createWrapper(Map<Id, SSP_Relationship__c> sspRelationshipMap, Map<Id, SSP_ApplicationIndividual__c> sspApplicationIndividualMap, SSP_ApplicationIndividual__c currentUser, Map<Id, SSP_Relationship__c> sspRelativesRelationshipMap){
        List<SSP_RelationshipWrapper> relWrapperList = new List<SSP_RelationshipWrapper>();
        try{
            List<String> genderBasedRelationshipValuesList = new List<String> ();
            Map<String,Reverse_Relationship__mdt> reverseMDMap = new Map<String,Reverse_Relationship__mdt>();
            for(Reverse_Relationship__mdt revRel : getRelationshipMetadata()){
                reverseMDMap.put(revRel.MasterLabel, revRel);
            }
            for(Reverse_Relationship__mdt revRel : getRelationshipMetadata()){
                if(revRel.genderCode__c == currentUser.SSP_Member__r.GenderCode__c || revRel.genderCode__c == SSP_GlobalConstants.BOTH){
                    genderBasedRelationshipValuesList.add(revRel.MasterLabel);
                }       
            }
            for(Id rel : sspApplicationIndividualMap.keySet()){
                SSP_RelationshipWrapper relWrap = new SSP_RelationshipWrapper();
                relWrap.memberId = sspApplicationIndividualMap.get(rel).SSP_Member__c;
                relWrap.currentUserFirstName = currentUser.SSP_Member__r.FirstName__c;
                relWrap.currentUserLastName = currentUser.SSP_Member__r.LastName__c;
                relWrap.currentUserMiddleName = currentUser.SSP_Member__r.MiddleInitial__c;
                relWrap.currentUserSuffix = currentUser.SSP_Member__r.SuffixCode__c;
                relWrap.currentUserAge = (Integer)currentUser.SSP_Member__r.Age__c;
                relWrap.otherUserFirstName = sspApplicationIndividualMap.get(rel).SSP_Member__r.FirstName__c;
                relWrap.otherUserMiddleName = sspApplicationIndividualMap.get(rel).SSP_Member__r.MiddleInitial__c;
                relWrap.otherUserSuffix = sspApplicationIndividualMap.get(rel).SSP_Member__r.SuffixCode__c;
                relWrap.otherUserLastName = sspApplicationIndividualMap.get(rel).SSP_Member__r.LastName__c;
                relWrap.otherUserAge = (Integer)sspApplicationIndividualMap.get(rel).SSP_Member__r.Age__c;

                if(!sspRelationshipMap.isEmpty() && sspRelationshipMap.get(rel) != Null){
                    relWrap.relationshipType = getLabelValueOfRelationshipType(sspRelationshipMap.get(rel).RelationshipType__c);
                    relWrap.isActingParent = sspRelationshipMap.get(rel).IsActingParentToggle__c;
                    relWrap.isCareTaker = sspRelationshipMap.get(rel).IsCareTakerToggle__c;
                    relWrap.intendToPursueLegalCustody = sspRelationshipMap.get(rel).IntendToPursueLegalCustodyToggle__c;
                }
                else if(!sspRelativesRelationshipMap.isEmpty() && sspRelativesRelationshipMap.get(rel) != Null){
                    Reverse_Relationship__mdt result = reverseMDMap.get(sspRelativesRelationshipMap.get(rel).RelationshipType__c);
                    relWrap.relationshipType = reverseRelationship(result, currentUser.SSP_Member__r.GenderCode__c);
                    relWrap.isActingParent = Null;
                    relWrap.isCareTaker = Null;
                    relWrap.intendToPursueLegalCustody = Null;
                }
                else{
                    relWrap.relationshipType = Null;
                    relWrap.isActingParent = Null;
                    relWrap.isCareTaker = Null;
                    relWrap.intendToPursueLegalCustody = Null;
                }
                
                if(sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c!= null && sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.CHILD_CARE_CODE) &&
                   sspApplicationIndividualMap.get(rel).MemberProgramsApplied__c!= null && sspApplicationIndividualMap.get(rel).MemberProgramsApplied__c.split(';').contains(SSP_GlobalConstants.CHILD_CARE_CODE) &&
                   sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c.split(';').size() == 1){
                          relWrap.showQuestionActingParent = True;
                          relWrap.showQuestionCareTaker = False;
                }
                else if(sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c!= null && sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c.split(';').contains(SSP_GlobalConstants.CHILD_CARE_CODE) &&
                   		sspApplicationIndividualMap.get(rel).MemberProgramsApplied__c!= null && sspApplicationIndividualMap.get(rel).MemberProgramsApplied__c.split(';').contains(SSP_GlobalConstants.CHILD_CARE_CODE) && 
                        sspApplicationIndividualMap.get(rel).SSP_Application__r.ProgramsApplied__c.split(';').size() != 1){
                            relWrap.showQuestionActingParent = False;
                            relWrap.showQuestionCareTaker = True;
                        }   
                else{
                    relWrap.showQuestionActingParent = False;
                    relWrap.showQuestionCareTaker = False;
                }
                if((relWrap.relationshipType == SSP_GlobalConstants.OTHER_RELATIONSHIP || relWrap.relationshipType == SSP_GlobalConstants.UNRELATED) && relWrap.showQuestionCareTaker){
                    relWrap.showQuestionPursueLegalCustody = True;
                }
                else{
                    relWrap.showQuestionPursueLegalCustody = False;
                }
                relWrap.ageLessThanTenShowError = False;
                relWrap.ageLessThanTwentyShowError = False;
                relWrap.individualAgeLessThanRelatedShowError = False;
                relWrap.individualIsMinorShowError = False;
                relWrap.individualAgeGreaterThanRelatedShowError = False;
                relWrap.individualAgeLessThanRelatedStepShowError = False;
                relWrap.genderBasedRelationshipValues = genderBasedRelationshipValuesList;
                relWrapperList.add(relWrap);
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'createWrapper', ex.getMessage() , true);
        }
        return relWrapperList;
    }
    
/********************************************************************************************
* @author       Shivam Tiwari
* @date         12/17/2019
* @methodname   reverseRelationship
* @description  This method gives reverse relationship of a particular list
* @param        Reverse_Relationship__mdt, String
* @return       String
********************************************************************************************/
    public static String reverseRelationship(Reverse_Relationship__mdt result, String gender){
        String revRelationship = null;
        try{
            if(result != null && gender!= null && gender!=''){
                if(gender.equalsIgnoreCase(SSP_GlobalConstants.FEMALE)){
                    revRelationship = result.femaleRevCode__c;                    
                }
                else if(gender.equalsIgnoreCase(SSP_GlobalConstants.MALE)){
                    revRelationship = result.maleRevCode__c;
                }
            }
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'reverseRelationship', ex.getMessage() , true);
        } 
        return revRelationship;
    }
    
/********************************************************************************************
* @author       Sanchita Tibrewala
* @date         12/15/2019
* @methodname   getLabelValueOfRelationshipType
* @description  This method returns teh label for a given picklist value
* @param        String
* @return       String
********************************************************************************************/
    public static String getLabelValueOfRelationshipType (String apiValue){
        String picklistLabel;
        try{
            Map<String,String> picklistMap = SSP_Utility.getPickListValues('SSP_Relationship__c', 'RelationshipType__c', null);
            picklistLabel = picklistMap.get(apiValue);
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'getLabelValueOfRelationshipType', ex.getMessage() , true);
        }
        return picklistLabel;
    }
    
/********************************************************************************************
* @author       Sanchita Tibrewala
* @date         02/19/2020
* @methodname   getRelationshipMetadata
* @description  This method returns Reverse Relationship metadata
* @param        void
* @return       List<Reverse_Relationship__mdt>
********************************************************************************************/
    public static List<Reverse_Relationship__mdt> getRelationshipMetadata (){
        List<Reverse_Relationship__mdt> reverseRelationshipList = new List<Reverse_Relationship__mdt> ();
        try{
            reverseRelationshipList = [Select MasterLabel, relType__c, femaleRevCode__c, maleRevCode__c, genderCode__c
                                       From Reverse_Relationship__mdt];
        }
        catch(Exception ex){            
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_RelationshipInformationController', 'getRelationshipMetadata', ex.getMessage() , true);
        }
        return reverseRelationshipList;
    }
    
}