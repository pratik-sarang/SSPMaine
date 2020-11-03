@isTest
public class JsonFlowControllerTest {
    
	@isTest
    public static void getFlowInitDataTest(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            PGObj = JsonFlowController.getFlowInitData('','Test');

        }catch(Exception e){
             
        }
        
        test.stopTest();
    }
    @isTest
    public static void execTest(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            PGObj = JsonFlowController.exec('next','',new Account(),'','','',new List<String>());

        }catch(Exception e){
             
        }
        
        test.stopTest();
    }
    @isTest
    public static void execTestForNext(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            List<NavFlowDetail__mdt> navFlowDetails = [SELECT Id, JsonObjectSchema__c FROM NavFlowDetail__mdt];
            String flowId = '';
            for(NavFlowDetail__mdt nvDetail: navFlowDetails) {
                if(nvDetail.JsonObjectSchema__c != null) {
                    flowId = nvDetail.Id;
                    break;
                }
            }
            PGObj = JsonFlowController.exec('next','',new Account(),'',flowId,'',new List<String>());

        }catch(Exception e){
             
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void execTestForBack(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            List<NavFlowDetail__mdt> navFlowDetails = [SELECT Id, JsonObjectSchema__c FROM NavFlowDetail__mdt];
            String flowId = '';
            for(NavFlowDetail__mdt nvDetail: navFlowDetails) {
                if(nvDetail.JsonObjectSchema__c != null) {
                    flowId = nvDetail.Id;
                    break;
                }
            }
            PGObj = JsonFlowController.exec('back','',new Account(),'',flowId,'',new List<String>());

        }catch(Exception e){
             
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void execTestForSubmit(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            List<NavFlowDetail__mdt> navFlowDetails = [SELECT Id, JsonObjectSchema__c FROM NavFlowDetail__mdt];
            String flowId = '';
            for(NavFlowDetail__mdt nvDetail: navFlowDetails) {
                if(nvDetail.JsonObjectSchema__c != null) {
                    flowId = nvDetail.Id;
                    break;
                }
            }
            PGObj = JsonFlowController.exec('submit','',new Account(),'',flowId,'',new List<String>());

        }catch(Exception e){
             System.debug('Error : '+e.getMessage());
            System.debug('Stack string : '+e.getStackTraceString() );
        }
        
        test.stopTest();
    }
    
     @isTest
    public static void shouldGetPageInfo(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            PGObj = JsonFlowController.getPageInfo('next','');

        }catch(Exception e){
             
        }
        
        test.stopTest();
    }
    
    @isTest
    public static void shouldGetPageInfoInitData(){
        test.startTest();
        List<User> lstexistinguser = new List<User>();
        lstexistinguser  = [SELECT ID,ContactId FROM User];
        // end
        try{
            JsonPageResponse PGObj = new JsonPageResponse();
            PGObj = JsonFlowController.getPageInfoInitData('next','');
            
        }catch(Exception e){
            
        }
        
        test.stopTest();
    }
    
    @isTest
    Public static void getPageToLoadIdTest(){
        test.startTest();
        JsonPageResponse PGObj = new JsonPageResponse();
        NavFlowDetail__mdt navFlowDetails = [SELECT Id, JsonObjectSchema__c FROM NavFlowDetail__mdt Limit 1];
        JsonFlowController.getPageToLoadId(navFlowDetails,null,'Submit');
         test.stopTest();
    }
    
}