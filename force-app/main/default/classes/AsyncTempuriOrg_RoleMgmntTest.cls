@isTest
public class AsyncTempuriOrg_RoleMgmntTest
{
	@isTest public static void beginRemoveRolesFromUser_test()
    {  
        Test.setMock(WebServiceMock.class, new tempuriOrg_RoleMgmntMock());
        AsyncTempuriOrg_RoleMgmnt.RemoveRolesFromUserResponse_elementFuture removeRoleTest = new AsyncTempuriOrg_RoleMgmnt.RemoveRolesFromUserResponse_elementFuture();
        //schemasDatacontractOrg200407_Role.ArrayOfMessageResponse a = removeRoleTest.getValue();
        AsyncTempuriOrg_RoleMgmnt.AsyncBasicHttpsBinding_IRoleManagement testingmethod = new AsyncTempuriOrg_RoleMgmnt.AsyncBasicHttpsBinding_IRoleManagement();
		System.Continuation cont=new system.Continuation(120);
        cont.continuationMethod='getAddress';
        testingmethod.beginRemoveRolesFromUser(cont,'Test','http://schemas.datacontract.org/2004/07/System', null, 'authorizedByUserKOGID');        
        system.assert(cont.continuationMethod=='getAddress','Success');
	}
}