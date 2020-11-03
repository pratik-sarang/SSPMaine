@isTest
public class GenericValidationControllerTest{
 
   @isTest public static void getMetadataListTest(){
       List<EntityMapping__mdt> lstEntity = [Select Id, SF_ObjectAPI__c, SF_FieldAPI__c, ScreenName__c From EntityMapping__mdt
 Where  SF_FieldAPI__c = 'IsBlindToggle__c' Limit 1];
       GenericValidationController.getMetadataList(new List<String>{lstEntity[0].SF_FieldAPI__c+','+lstEntity[0].SF_ObjectAPI__c}, lstEntity[0].ScreenName__c);       
    } 
}