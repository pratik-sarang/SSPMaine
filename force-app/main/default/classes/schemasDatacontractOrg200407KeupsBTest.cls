/********************************************************************************************
* @author       Venkat Korra
* @date         5/11/2020
* @methodname   test_Exceptions
* @description  This method is used to cover the variable declaration of class - schemasDatacontractOrg200407KeupsB
* @param        none
* @return       none
********************************************************************************************/
@isTest
public class schemasDatacontractOrg200407KeupsBTest
{
    @isTest static void test_Exceptions()
    {
        Test.startTest();
        schemasDatacontractOrg200407KeupsB.UserAttribute clsObj = new schemasDatacontractOrg200407KeupsB.UserAttribute();
        schemasDatacontractOrg200407KeupsB.ServiceData clsObj1 = new schemasDatacontractOrg200407KeupsB.ServiceData();
        schemasDatacontractOrg200407KeupsB.UserAttributes clsObj2 = new schemasDatacontractOrg200407KeupsB.UserAttributes();
        System.assert(clsObj != null,'Positive Scenario'); 
        Test.stopTest();
    }

}