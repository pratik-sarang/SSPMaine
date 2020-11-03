@isTest
public class platformTriggerEventForUserTest {
    @isTest  
    public static void testMethod1(){
        Test.startTest();
        SSP_TestDataFactory.setupTestData();
        user userDeactive1 = fetchCitizenUser();  
        user userDeactive = [Select id,lastname,Username from user where id =: userDeactive1.Id];
        List<Database.SaveResult> saveres = new List<Database.SaveResult>();
        List<UpdateSSOUser__e> publishEvents = new List<UpdateSSOUser__e>();
        publishEvents.add(new UpdateSSOUser__e(UserId__c = userDeactive.Id ,Alias__c = userDeactive.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5),
                                               CommunityNickname__c = userDeactive.LastName.substring(0,3)+String.valueOf(DateTime.now().getTime()).right(5), FederationIdentifier__c = '',IsActive__c = false,UserName__c = userDeactive.Username ));
        if(publishEvents.size()>0){
            saveres = EventBus.publish(publishEvents);
        } 
        System.assertNotEquals(saveres,null);
        Test.stopTest();
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
}