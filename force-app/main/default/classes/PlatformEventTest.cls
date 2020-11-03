@isTest
public class PlatformEventTest {
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    @isTest static void publishEvent(){
    Test.startTest();
        List<ErrorLog__e> publishEvents = new List<ErrorLog__e>();
        List<Database.SaveResult> saveres = new List<Database.SaveResult>();
        publishEvents.add(new ErrorLog__e(StackTrace__c = 'test', DebugLevel__c = string.valueof(LOG_LogMessageUtility.LOG_LogLevel.Error),
                                              ErroLog__c= 'ERROR LOG', Source__c ='PlatformEventTest', 
                                              Message__c = 'test' ,SourceFunction__c = 'publishEvent'));
            if(publishEvents.size()>0){
                saveres = EventBus.publish(publishEvents);
            }
        	System.assertNotEquals(saveres,null);
            Test.stopTest();
    }
}