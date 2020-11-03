@isTest(seeAllData=false)
public class SSP_ClientCaseNoteCtrlTest {

    @testSetup
    public static void createTestData(){
        
        
        SSP_ClientCaseNote__c ccn1 = new SSP_ClientCaseNote__c(Case_Number__c = 123445, Comments__c='uasja adufhsdfk ajfdaiuhdj sdofaosifjaosdi');
        insert ccn1;
    }
    
    @isTest
    public static void getCaseDetailsTest(){
        SSP_LightningResponse dataToSend = SSP_ClientCaseNoteCtrl.getCaseDetails();
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123445','PE');
        mapCaseVsStatus.put('445566','PE');
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        SSP_LightningResponse dataToSend2 = SSP_ClientCaseNoteCtrl.getCaseDetails();
        System.assertNotEquals(null, dataToSend2);
    }
    
    @isTest
    public static void getClientCaseNotesTest(){
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123445','PE');
        mapCaseVsStatus.put('445566','PE');
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        SSP_LightningResponse dataToSend = SSP_ClientCaseNoteCtrl.getClientCaseNotes(123445);
        SSP_LightningResponse dataToSend2 = SSP_ClientCaseNoteCtrl.getClientCaseNotes(null);
    }
    
    @isTest
    public static void saveClientCaseNotesTest(){
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        mapCaseVsStatus.put('123445','PE');
        mapCaseVsStatus.put('445566','PE');
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionpart.put('caseVsStatus',JSON.serialize(mapCaseVsStatus),3600,Cache.Visibility.ALL,false);
        SSP_ClientCaseNoteCtrl.saveClientCaseNotes(445566, 'oiasjalkjfsiodfjsdoifjsdiofjsdfioj');
        SSP_ClientCaseNoteCtrl.saveClientCaseNotes(445566, null);
    }
}