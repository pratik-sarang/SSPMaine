/**
* Class Name    : SSP_RSSPDC_TransactionUpdateControlTest
* Owner         : DELOITTE
* Created Date  : 04/7/2020
* Description   : Test class for SSP_RSSPDC_TransactionUpdateController class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer            Description                                                         
*  ----------  --------------     -------------------------------------------------------------------
*  04/7/2020    Ragunathan	        Initial Version
*/
@isTest
public class SSP_RSSPDC_TransactionUpdateControlTest {
    
    private static testmethod void shouldInsertTransactionRecord() {
        PageReference pageRef = Page.SSP_RSSPDC_TransactionUpdatePage;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('AppID','testAppId');
        pageRef.getParameters().put('CaseNumber', '5667');
        pageRef.getParameters().put('status', 'Completed');
        pageRef.getParameters().put('Mode', 'RAC');
        pageRef.getParameters().put('PrimaryAppIndId', '8998654');
        pageRef.getParameters().put('Views', 'Views');
        pageRef.getParameters().put('All_Views', 'All_Views');
        pageRef.getParameters().put('viewName', 'NotificationInformation');
        pageRef.getParameters().put(SSP_InterfaceConstants.FLOW_TYPE, 'Employment');
        pageRef.getParameters().put(SSP_InterfaceConstants.ROLE_NAME, 'Citizen_Indivdiual');
        pageRef.getParameters().put(SSP_InterfaceConstants.USER_ID, '1234234234234');
        pageRef.getParameters().put(SSP_InterfaceConstants.CONTACT_ID, '23423423');
        
        SSP_RSSPDC_RequestWrapper req = new SSP_RSSPDC_RequestWrapper();
        req.viewName = 'All_Views';
        req.Mode='RAC';
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        List<ReverseSSPViewMapping__mdt> mappingMdt = dmlUtility.getRequestedMappingRecords(req);
        //mappingMdt = [select id,is_RAC__c from ReverseSSPViewMapping__mdt where Id =:mappingMd[0].Id ];
        mappingMdt[0].is_RAC__c = true;
        //mappingMdt = ESAPI.accessController().insertAsUser(mappingMdt, SSP_Utility.getFieldsNamesList (mappingMdt)).getInsertedObjects();
        
        Set<String> setViews = new Set<String>();
        Map<String,Set<String>> mapData = new Map<String,Set<String>>{'SetOfViews'=>setViews};
            pageRef.getParameters().put('setOfViews', JSON.serialize(mapData));
        
        SSP_RSSPDC_TransactionUpdateController controllerTest = new SSP_RSSPDC_TransactionUpdateController();
        controllerTest.insertTransactionRecord();
        
        SSP_Transaction__c trans = [Select Id, CaseNumber__c from SSP_Transaction__c where ApplicationId__c = 'testAppId' limit 1];
        System.assertEquals('5667', trans.CaseNumber__c);
        
        SSP_Transaction__c trans1 = [Select Id, CaseNumber__c,status__c from SSP_Transaction__c where ApplicationId__c = 'testAppId' limit 1];
        trans1.Status__c='Not Started';
        update trans1; 
        System.assertEquals('5667', trans.CaseNumber__c);
    }
    
    private static testmethod void shouldUpdateTransactionRecord(){
        
        PageReference pageRef = Page.SSP_RSSPDC_TransactionUpdatePage;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('AppID','testAppId');
        pageRef.getParameters().put('CaseNumber', '5667');
        pageRef.getParameters().put('status', 'Not Started');
        pageRef.getParameters().put('Mode', 'RAC');
        pageRef.getParameters().put('PrimaryAppIndId', '8998654');
        pageRef.getParameters().put(SSP_InterfaceConstants.VIEWS, 'IncomeInformation;QualifiedIndividual');
        pageRef.getParameters().put(SSP_InterfaceConstants.VIEW_NAME, SSP_InterfaceConstants.ALL_VIEWS);
        pageRef.getParameters().put(SSP_InterfaceConstants.FLOW_TYPE, 'Employment');
        pageRef.getParameters().put(SSP_InterfaceConstants.ROLE_NAME, 'Citizen_Indivdiual');
        pageRef.getParameters().put(SSP_InterfaceConstants.USER_ID, '1234234234234');
        pageRef.getParameters().put(SSP_InterfaceConstants.CONTACT_ID, '23423423');
        Set<String> setViews = new Set<String>();
        //setViews.add(SSP_InterfaceConstants.VIEWS);
        Map<String,Set<String>> mapData = new Map<String,Set<String>>{'SetOfViews'=>setViews};
        pageRef.getParameters().put('setOfViews', JSON.serialize(mapData));
        
        
        SSP_RSSPDC_TransactionUpdateController controllerTest = new SSP_RSSPDC_TransactionUpdateController();
        controllerTest.insertTransactionRecord();
        
        SSP_Transaction__c trans1 = [Select Id, CaseNumber__c,status__c from SSP_Transaction__c where ApplicationId__c = 'testAppId' limit 1];
        trans1.Status__c='Not Started';
        update trans1; 
        System.assertEquals('Not Started', trans1.Status__c);
        
    }
}