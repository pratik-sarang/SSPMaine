@isTest
public class tempuriOrgGateWayRedirectTest {
     @isTest
    public static void unitTest1() {
        tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element cl1= new tempuriOrgGateWayRedirect.RoleRequestShortcutResponse_element();
        tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element cl3= new tempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_element();
        tempuriOrgGateWayRedirect.SaveAddRoleParametersEx_element cl4= new tempuriOrgGateWayRedirect.SaveAddRoleParametersEx_element();
        tempuriOrgGateWayRedirectMock mockClass= new tempuriOrgGateWayRedirectMock();
        mockClass.isRequestReq=true;
        Test.setMock(WebServiceMock.class,mockClass);
        tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService cl2= new tempuriOrgGateWayRedirect.BasicHttpsBinding_IGatewayRedirectContextService();
        String rpsn = cl2.RoleRequestShortcut('https://test.com','test app','roleTest',true,new schemasDatacontractOrg200407KeupsB.UserAttributes());
        Test.setMock(WebServiceMock.class,new tempuriOrgGateWayRedirectMock());
        String rpsn1 = cl2.SaveAddRoleParametersEx('https://test.com','test app','roleTest',true);
    }

}