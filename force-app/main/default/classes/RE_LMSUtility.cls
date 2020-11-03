/******************************************************************************************
*   Type             :   Apex Class
*   Name             :   RE_LMSUtility
*   Author           :   CHFS
*   Created Date     :   11/04/2019
*   Description      :   An utility class contains assignments of learning courses to community partner
*
*  								M O D I F I C A T I O N   L O G
*   --------------------------------------------------------------------------------------
*   * Developer                  Date          Description
*   * ------------------------------------------------------------------------------------
*	* Siri Putta			 11/05/2019       Initial Version
*******************************************************************************************/
public without sharing class RE_LMSUtility {
    
    /********************************************************************************************
    * @author       Siri Putta
    * @date         11/05/2019
    * @methodname   getPlanId()
    * @description  This methods is used to fetch learning plan id
    * @return       planId
    **********************************************************************************************/
    public static Id getPlanId(String propertyName)
    { 
        Id planId;
        RE_Properties__c propertyValues = RE_Properties__c.getValues(propertyName);
        string planName = propertyValues.PropertyValue__c;
        try{
            List<redwing__Training_Plan__c> listOfTrainingPlan;
            if(redwing__Training_Plan__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.redwing__Training_Plan__c.fields.Name.isAccessible()){
                listOfTrainingPlan = [SELECT Id, Name FROM redwing__Training_Plan__c WHERE Name = :planName];
            }
            if(listOfTrainingPlan != null && !listOfTrainingPlan.isEmpty())
            {
                for(redwing__Training_Plan__c tp: listOfTrainingPlan){
                    planId= tp.Id;
                }
            }
        }catch(exception ex){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LMSUtility','getPlanId','Error Occured:: '+ ex.getMessage(), true); 
            throw ex;
        }
        return planId;
    }  
    /********************************************************************************************
    * @author       Siri Putta
    * @date         11/05/2019
    * @methodname   getCommunityId()
    * @description  This methods is used to fetch Community id
    * @return       communityId
    **********************************************************************************************/
    public static Id getCommunityId(String propertyName) 
    {
        Id communityId;
        RE_Properties__c propertyValues = RE_Properties__c.getValues(propertyName);
        string communityName = propertyValues.PropertyValue__c;
        try{
            //Kojashree
            String switchchoiceKey = (Schema.sObjectType.Network.fields.Id.isAccessible() && Schema.sObjectType.Network.fields.Name.isAccessible()) ? 'success' : 'failure';
          	 switch on (switchchoiceKey) {
                 when 'success'{
                     List<Network> listOfCommunities = [SELECT Id, Name FROM Network WHERE Name = :communityName];
                     if(listOfCommunities != null && !listOfCommunities.isEmpty())
                     {
                         for(Network c:listOfCommunities){
                             communityId = c.Id;   
                         }
                     }
                 }
             }
            
        }catch(exception ex){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LMSUtility','getCommunityId','Error Occured:: '+ ex.getMessage(), true);
            throw ex;
        } 
        return communityId;
    }
    /********************************************************************************************
    * @author       Siri Putta
    * @date         11/05/2019
    * @methodname   assignCPUserOnboardingTraining()
    * @description  This methods is used assign Onboarding training to CP User
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    public static void assignCPUserOnboardingTraining(List<Id> userIds)
    {
        Id planId = getPlanId(RE_GlobalConstants.LearningPlanName);
        Id communityId = getCommunityId(RE_GlobalConstants.CommunityName);
        try{
            if(planId != null && communityId != null)
            {
                Set<Id> setOfUserTrainingNotAssigned = new Set<Id>();
                List<User> listOfUser = new List<User>();
               if(User.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.User.fields.IsOnboardTrainingDone__c.isAccessible()){
                 listOfUser = [SELECT Id, IsOnboardTrainingDone__c FROM User WHERE Id IN :userIds];
               }
                //The object access and permission to the user is automatically done during the profile assignment. It will be redundant to apply FLS checks and data accesibility checks here.  
                Map<Id, redwing__Training_Plan_Assignment__c> mapOfUserWithTrainingAssigned = new Map<Id, redwing__Training_Plan_Assignment__c>();
                for(redwing__Training_Plan_Assignment__c tPA: [SELECT Id, Name, redwing__User__c, redwing__Training_Plan__c 
                                                               FROM redwing__Training_Plan_Assignment__c 
                                                               WHERE redwing__User__c IN :userIds AND redwing__Training_Plan__c = :planId])
                {
                    mapOfUserWithTrainingAssigned.put(tPA.redwing__User__c, tPA);
                }
                for(User u: listOfUser){
                    if(!u.IsOnboardTrainingDone__c && !mapOfUserWithTrainingAssigned.containsKey(u.Id)){
                        setOfUserTrainingNotAssigned.add(u.Id);
                    }
                }
                if(setOfUserTrainingNotAssigned != null && setOfUserTrainingNotAssigned.size() > 0)
                {
                    redwing.LMS_API.upsertPlanAssignments(setOfUserTrainingNotAssigned, planId, communityId, null);
                }
            }
        }catch(exception ex){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LMSUtility','assignCPUserOnboardingTraining','Error Occured:: '+ ex.getMessage() + 'Stack Trace : '+ex.getStackTraceString(), true);
            throw ex;
        } 
    }   
    /********************************************************************************************
    * @author       Siri Putta
    * @date         11/06/2019
    * @methodname   completeCPUserOnboardingTraining()
    * @description  This is an invocable method to check IsOnboardTrainingDone__c to true once the learning plan is completed.     
    **********************************************************************************************/
    @InvocableMethod(label='completeCPUserOnboardingTraining')
    public static void completeCPUserOnboardingTraining(List<Id> userId)
    {
        try{
            List<User> listOfUser = new List<User>();
           if(User.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.User.fields.IsOnboardTrainingDone__c.isAccessible()){
             listOfUser = [SELECT Id, IsOnboardTrainingDone__c FROM User WHERE Id IN :userId];
           }
            for (User u: listOfUser)
            {
                u.IsOnboardTrainingDone__c = True;
            }
            if(listOfUser!=null && !listOfUser.isEmpty())
            {
                update listOfUser;
            }
        }catch(exception ex){
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LMSUtility','completeCPUserOnboardingTraining','Error Occured:: '+ ex.getMessage(), true);
            throw ex;
        } 
    }
}