@isTest
public class MCIHandlerTest {
    
    @isTest static  void MCIHandlerTestForIEES(){
        
            WebServiceSettings__c wss = new WebServiceSettings__c();
        wss.Name = 'MCI Entity Search';
        wss.Certificate_Name__c = 'backyardnonprodmulecert';
        wss.Source_System__c = 'Kog';
        wss.Target_URL__c = 'https://ms-nonprod-lb.ky.gov/ky-re-mci-services-xapi-qa/MCI_WCFService/MciService.svc?wsdl';
        wss.Time_Out__c = 120000;
        insert wss;
        Test.setMock(WebServiceMock.class, new kyHbeMciDatacontractsMock());
        kyHbeMciDatacontracts.MciEntitySearchResponse res;
        user usr;
        test.startTest();
        res = MciServiceHandler.getIndividualBenefindId('indivKOGId',usr,'strSourceSystemName');
        System.assertEquals(true,res.IsRecordFound);
        test.stopTest();
    }
}