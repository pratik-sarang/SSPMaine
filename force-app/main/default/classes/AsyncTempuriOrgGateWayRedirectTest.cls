/**
 * @File Name          : AsyncTempuriOrgGateWayRedirectTest.cls
 * @Description        : 
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              : 
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 5/12/2020, 12:08:41 PM
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    5/12/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
**/
@isTest
private class AsyncTempuriOrgGateWayRedirectTest {
   
    @isTest public static void beginSaveAddRoleParametersEx_test(){    
        AsyncTempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_elementFuture SaveAddroleTestClass= new AsyncTempuriOrgGateWayRedirect.SaveAddRoleParametersExResponse_elementFuture();
        //SaveAddroleTestClass.getValue();
        AsyncTempuriOrgGateWayRedirect.AsyncBasicHttpsBinding_IGatewayRedirectContextService testingmethod = new AsyncTempuriOrgGateWayRedirect.AsyncBasicHttpsBinding_IGatewayRedirectContextService();
		System.Continuation cont=new system.Continuation(120);
        cont.continuationMethod='getAddress';
        testingmethod.beginSaveAddRoleParametersEx(cont,'http://tempuri.org/IGatewayRedirectContextService/RoleRequestShortcut','BackYard','CP Admin',true);        
        system.assert(cont.continuationMethod=='getAddress','Success');
	}
    
    	@isTest public static void beginRoleRequestShortcut_test(){    
        AsyncTempuriOrgGateWayRedirect.RoleRequestShortcutResponse_elementFuture beginRoleRequestShortcutTestClass= new AsyncTempuriOrgGateWayRedirect.RoleRequestShortcutResponse_elementFuture();
        //SaveAddroleTestClass.getValue();
        AsyncTempuriOrgGateWayRedirect.AsyncBasicHttpsBinding_IGatewayRedirectContextService testingmethod = new AsyncTempuriOrgGateWayRedirect.AsyncBasicHttpsBinding_IGatewayRedirectContextService();
		System.Continuation cont=new system.Continuation(120);
        cont.continuationMethod='getAddress';
        schemasDatacontractOrg200407KeupsB.UserAttributes userAttr = new schemasDatacontractOrg200407KeupsB.UserAttributes();
        testingmethod.beginRoleRequestShortcut(cont,'http://tempuri.org/IGatewayRedirectContextService/RoleRequestShortcut','BackYard','CP Admin',true,userAttr);        
        system.assert(cont.continuationMethod=='getAddress','Success');
	}
}