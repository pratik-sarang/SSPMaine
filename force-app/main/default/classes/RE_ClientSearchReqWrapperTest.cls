@isTest
public class RE_ClientSearchReqWrapperTest {
     @isTest
    public static void RequestData(){
        RE_ClientSearchReqWrapper.RequestData objData1= new RE_ClientSearchReqWrapper.RequestData('testFname','testLname','testdob','testSearchtype');   
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(objData1.firstName,'testFname','Positive Scenario');  
        RE_ClientSearchReqWrapper.RequestData objDatasearch= new RE_ClientSearchReqWrapper.RequestData('testSearchValue','SSN');
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(objDatasearch.SSN,'testSearchValue','Positive Scenario');  
        RE_ClientSearchReqWrapper.RequestData objDatasearch1= new RE_ClientSearchReqWrapper.RequestData('testSearchValue','CaseNumber');
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(objDatasearch1.CaseNumber,'testSearchValue','Positive Scenario');
        RE_ClientSearchReqWrapper.RequestData objDatasearch2= new RE_ClientSearchReqWrapper.RequestData('testSearchValue','Individualid');
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(objDatasearch2.Individualid,'testSearchValue','Positive Scenario');
    }
}