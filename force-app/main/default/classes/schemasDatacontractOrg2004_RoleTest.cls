/********************************************************************************************
* @author       Venkat Korra
* @date         5/11/2020
* @methodname   test_Exceptions
* @description  This method is used to cover the variable declaration of class - schemasDatacontractOrg2004_Role
* @param        none
* @return       none
********************************************************************************************/
@isTest
public class schemasDatacontractOrg2004_RoleTest
{
    @isTest static void test_Exceptions()
    {
        Test.startTest();
        schemasDatacontractOrg2004_Role.FaultException clsObj = new schemasDatacontractOrg2004_Role.FaultException();
        schemasDatacontractOrg2004_Role.CommunicationException clsObj1 = new schemasDatacontractOrg2004_Role.CommunicationException();
        schemasDatacontractOrg2004_Role.ArrayOfFaultException_FaultCodeData clsObj2 = new schemasDatacontractOrg2004_Role.ArrayOfFaultException_FaultCodeData();
        schemasDatacontractOrg2004_Role.FaultException_FaultReasonData clsObj3 = new schemasDatacontractOrg2004_Role.FaultException_FaultReasonData();
        schemasDatacontractOrg2004_Role.FaultException_FaultCodeData clsObj4 = new schemasDatacontractOrg2004_Role.FaultException_FaultCodeData();
        schemasDatacontractOrg2004_Role.ArrayOfFaultException_FaultReasonData clsObj5 = new schemasDatacontractOrg2004_Role.ArrayOfFaultException_FaultReasonData();
        System.assert(clsObj != null,'Positive Scenario');
        Test.stopTest();
    }
}