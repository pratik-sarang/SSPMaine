@isTest
public class AsyncSSP_DDtempuriOrgTest {
	@isTest
    public static void testMethod1(){
        AsyncSSP_DDtempuriOrg.AsyncBasicHttpBinding_ITwoWayAsync dat = new AsyncSSP_DDtempuriOrg.AsyncBasicHttpBinding_ITwoWayAsync(); 
        System.Continuation cont=new system.Continuation(120);
        dat.beginDMSGetDocumentService(cont,'12345','1234');
    }
}