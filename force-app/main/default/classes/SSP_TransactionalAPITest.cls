@IsTest
public class SSP_TransactionalAPITest {

    @IsTest
    static void shouldSendComList() {
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_GenerateTokenTest.SSP_SendComToMC_GenerateTokenServiceMock());
        Test.setMock(HttpCalloutMock.class, new SSP_SendComToMC_EmailSMSServiceTest.SSP_SendComToMC_EmailSMSServiceMock());
        String comLog =     '   [ {  '  + 
                            '     "attributes" : {  '  + 
                            '       "type" : "CommunicationLog__c",  '  + 
                            '       "url" : "/services/data/v50.0/sobjects/CommunicationLog__c/a04r0000003jwEPAAY"  '  + 
                            '     },  '  + 
                            '     "LastModifiedDate" : "2020-10-05T08:14:31.000+0000",  '  + 
                            '     "EmailSubject__c" : "Resource Engine access request from Assister John Doe(CP Admin)",  '  + 
                            '     "IsDeleted" : false,  '  + 
                            '     "processed_reminder_batch__c" : false,  '  + 
                            '     "SourceSystem__c" : "SSP",  '  + 
                            '     "Name" : "CL-2363",  '  + 
                            '     "FromEmail__c" : "rvelusamy@deloitte.com",  '  + 
                            '     "TemplateBody__c" : "Hello, Chris John,",  '  + 
                            '     "SystemModstamp" : "2020-10-05T08:14:31.000+0000",  '  + 
                            '     "Send_SMS__c" : false,  '  + 
                            '     "OwnerId" : "005r0000003fahzAAA",  '  + 
                            '     "CreatedById" : "005r0000003fahzAAA",  '  + 
                            '     "TriggeredRecordId__c" : "003r000000HI2YjAAL",  '  + 
                            '     "SendMail__c" : true,  '  + 
                            '     "CreatedDate" : "2020-10-05T08:14:31.000+0000",  '  + 
                            '     "TemplateName__c" : "RE_Request_Consent_Email_Template",  '  + 
                            '     "Id" : "a04r0000003jwEPAAY",  '  + 
                            '     "Status__c" : "In Progress",  '  + 
                            '     "LastModifiedById" : "005r0000003fahzAAA",  '  + 
                            '     "TriggeredRecordName__c" : "Chris John",  '  + 
                            '     "ToEmail__c" : "rvelusamy@deloitte.com"  '  + 
                            '  } ]  ' ;
        REIntegrationEndpoints__c endpointObj = new REIntegrationEndpoints__c();
        endpointObj.Name = 'SSP_SFMC';
        endpointObj.Client_Id__c = 'SSP_SFMC';
        endpointObj.Client_Secret__c = 'SSP_SFMC';
        insert endpointObj;
        AppConfig__c config = new AppConfig__c();
        config.Name = 'SFMC_DEFAULT_EMAIL';
        config.Value__c = 'test@email.com';
        insert config;
        List < CommunicationLog__c > comLogs = (List < CommunicationLog__c >) JSON.deserialize(comLog, List < CommunicationLog__c >.class);

        Test.startTest();
            SSP_TransactionalAPI.sendComList(comLogs);
        Test.stopTest();
    }
    
}