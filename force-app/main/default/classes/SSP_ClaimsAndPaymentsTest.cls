/*
* classname     :  SSP_ClaimsAndPaymentsTest 
* @description  :  Test class for SSP_ClaimsAndPayments
* @author       :  Chandra Shekhar   
* @date         :  08/13/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
@isTest(seeAllData=false)
public class SSP_ClaimsAndPaymentsTest {   
    
    @isTest    
    public static void  queryPaymentRecords(){
        List<String> individualIds= new List<String>();
        individualIds.add('830008781');
        individualIds.add('810100827');
        SSP_ClaimsAndPayments.individualIdList=individualIds;
        Payment_Tracker__c record = new Payment_Tracker__c();
        record.ClaimNumber__c='1000004512';
        record.IndividualId__c ='830008781';
        record.ClaimStatus__c ='UN';
        record.ProgramCode__c ='MA';
        record.CurrentAmountOwed__c =200.0;
        record.RepaymentAmount__c =50.0;
        record.DueDate__c =System.today()+10;
        record.Status__c='Paid';
        record.SessionId__c ='00Dr00000001m5X!AQEAQPblIPy3mjw2YgfRaQX7Yzlnixf5wAsp_QsY2fXewwD6UtduIhK8wT04HrOsXjQatDLyOso5wW.aFKb6rdMLzmShog_N';
        insert record;
        String CartId='1704d500-23ce-4734-971a-d174f1486f4c';
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getScreenData'));
        Test.startTest();
        SSP_ClaimsAndPayments.getScreenData(individualIds,null,null);
        SSP_ClaimsAndPayments.getScreenData(individualIds,CartId,'Paid');
        Test.stopTest();
        
    }
     @isTest    
    public static void  queryPaymentRecords2(){
        List<String> individualIds= new List<String>();
        individualIds.add('830008781');
        individualIds.add('810100827');
        SSP_ClaimsAndPayments.individualIdList=individualIds;        
        String CartId='1704d500-23ce-4734-971a-d174f1486f4c';
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getScreenData'));
        Test.startTest();
        SSP_ClaimsAndPayments.getScreenData(individualIds,null,null);        
        Test.stopTest();
        
    }
    @isTest    
    public static void  queryPaymentRecords1(){
        List<String> individualIds= new List<String>();
        individualIds.add('830008781');
        individualIds.add('810100827');
        SSP_ClaimsAndPayments.individualIdList=individualIds;
        Payment_Tracker__c record = new Payment_Tracker__c();
        record.ClaimNumber__c='1000004512';
        record.IndividualId__c ='830008781';
        record.ClaimStatus__c ='UN';
        record.ProgramCode__c ='MA';
        record.CurrentAmountOwed__c =200.0;
        record.RepaymentAmount__c =50.0;
        record.DueDate__c =System.today()+10;
        record.Status__c='Paid';
        record.SessionId__c ='00Dr00000001m5X!AQEAQPblIPy3mjw2YgfRaQX7Yzlnixf5wAsp_QsY2fXewwD6UtduIhK8wT04HrOsXjQatDLyOso5wW.aFKb6rdMLzmShog_N';
        insert record;
        String CartId='1704d500-23ce-4734-971a-d174f1486f4c';
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getScreenData'));
        Test.startTest();
        SSP_ClaimsAndPayments.getScreenData(individualIds,CartId,'Paid');
        Test.stopTest();
        
    }
    @isTest 
    public static void  getPaymentURL(){
        Payment_Tracker__c record = new Payment_Tracker__c();
        record.ClaimNumber__c='1000004512';
        record.IndividualId__c ='830008781';
        record.ClaimStatus__c ='UN';
        record.ProgramCode__c ='MA';
        record.CurrentAmountOwed__c =200.0;
        record.RepaymentAmount__c =50.0;
        record.DueDate__c =System.today()+10;
        record.Status__c='Paid';
        record.SessionId__c ='00Dr00000001m5X!AQEAQPblIPy3mjw2YgfRaQX7Yzlnixf5wAsp_QsY2fXewwD6UtduIhK8wT04HrOsXjQatDLyOso5wW.aFKb6rdMLzmShog_N';
        insert record;
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getPaymentURL'));
        Test.startTest();
        SSP_ClaimsAndPayments.getPaymentURL('1000004512', '200', 'https://sspci-benefind-reci.cs32.force.com/benefind/s/claims');       
        Test.stopTest();
        
    }
    @isTest
    public static void  getPaymentStatus(){
        Payment_Tracker__c record = new Payment_Tracker__c();
        record.ClaimNumber__c='1000004512';
        record.IndividualId__c ='830008781';
        record.ClaimStatus__c ='UN';
        record.ProgramCode__c ='MA';
        record.CurrentAmountOwed__c =200.0;
        record.RepaymentAmount__c =50.0;
        record.DueDate__c =System.today()+10;
        record.Status__c='Paid';
        record.SessionId__c ='00Dr00000001m5X!AQEAQPblIPy3mjw2YgfRaQX7Yzlnixf5wAsp_QsY2fXewwD6UtduIhK8wT04HrOsXjQatDLyOso5wW.aFKb6rdMLzmShog_N';
        insert record;
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getPaymentStatus'));
        Test.startTest();
        SSP_ClaimsAndPayments.getPaymentStatus('1000004512',true);
        
        Test.stopTest();
        
    }
    @isTest
    public static void  getPaymentStatus1(){
        Payment_Tracker__c record = new Payment_Tracker__c();
        record.ClaimNumber__c='1000004512';
        record.IndividualId__c ='830008781';
        record.ClaimStatus__c ='UN';
        record.ProgramCode__c ='MA';
        record.CurrentAmountOwed__c =200.0;
        record.RepaymentAmount__c =50.0;
        record.DueDate__c =System.today()+10;
        record.Status__c='Paid';
        record.SessionId__c ='00Dr00000001m5X!AQEAQPblIPy3mjw2YgfRaQX7Yzlnixf5wAsp_QsY2fXewwD6UtduIhK8wT04HrOsXjQatDLyOso5wW.aFKb6rdMLzmShog_N';
        insert record;
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getPaymentStatus'));
        Test.startTest();
        SSP_ClaimsAndPayments.getPaymentStatus('1000004512',false);
        
        Test.stopTest();
        
    }
    @isTest
    public static void  getPaymentStatus3(){
        
        Test.setMock(HttpCalloutMock.class, new SSP_ClaimsAndPayments_HttpMocktest('getPaymentStatus'));
        Test.startTest();
        SSP_ClaimsAndPayments.getPaymentStatus('1000004512',false);
        
        Test.stopTest();
        
    }
    @isTest
    public static void  getIndividualsIdsTest(){
        Test.setMock(HttpCalloutMock.Class, new SSP_DashboardMockCalloutClass());
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
        sessionPart.put('isHeadOfHouseHold','true');
        sessionPart.put('hasActiveCase',JSON.serialize(new List<String>()));
        sessionPart.put('caseOptions',JSON.serialize(new List<String>{'100000089','100000085'}));
        sessionPart.put('hasMedicaidRenewals',JSON.serialize(new  List<SSP_DashboardCaseInformation.Renewal>()));
        sessionPart.put('hasOtherRenewals',JSON.serialize(new  List<SSP_DashboardCaseInformation.Renewal>()));
        sessionPart.put('notificationsList',JSON.serialize(new List<SSP_DashboardController.NotificationWrapper>()));
        sessionpart.put('isExistingUser',true,3600,Cache.Visibility.ALL, false);
        sessionpart.put('hasAuthRepAgents',JSON.serialize(new Map<String, String>()),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsStatus',JSON.serialize(new Map<String, String>{'100000089'=>'AP','100000085'=>'AP'}),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsHOH',JSON.serialize(new Map<String, Boolean>{'100000089'=>true,'100000085'=>true}),3600,Cache.Visibility.ALL,false);
        sessionpart.put('caseVsIndividualIds',JSON.serialize(new Map<String, String>{'100000089'=>'123456','100000085'=>'123456'}),3600,Cache.Visibility.ALL,false);
        sessionpart.put('isCaseInChangeMode', false, 3600, Cache.Visibility.ALL, false);
        sessionpart.put('caseOwnership', '', 3600, Cache.Visibility.ALL, false);
        sessionpart.put('isTeamMember', true, 3600, Cache.Visibility.ALL, false);
		sessionpart.put('individualId', '123456', 3600, Cache.Visibility.ALL, false);
        Test.startTest();
        SSP_ClaimsAndPayments.getIndividualsIds();
        Test.stopTest();
        
    }
}