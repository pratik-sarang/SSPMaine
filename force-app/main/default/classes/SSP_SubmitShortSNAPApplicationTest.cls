/* Classname 		:  SSP_SubmitShortSNAPApplicationTest
* @description 		:  Test Class for SSP_SubmitShortSNAPApplication.
* @author 			:  Shivam Tiwari
* @date 			:  APR-23-2020
* MODIFICATION LOG	:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      		MM/DD/YYYY	      			A Brief Description about the Change
**/

@isTest
public class SSP_SubmitShortSNAPApplicationTest {
    
    //Mock Application String to be passed to method.
    public static final String applicationString = '{"ShortSnapIsIntentionToResideInKentucky__c":"N","ShortSnapMailingAddressLine1__c":"qwerty","ShortSnapMailingAddressLine2__c":"asd","ShortSnapMailingCity__c":"zxcv","ShortSnapMailingCountyCode__c":"200","ShortSnapMailingStateCode__c":"AK","ShortSnapMailingCountryCode__c":null,"ShortSnapMailingZipCode5__c":"45667","ShortSnapMailingGeolocation__Latitude__s":null,"ShortSnapMailingGeolocation__Longitude__s":null,"ShortSnapFirstName__c":"Shailja","ShortSnapMiddleInitial__c":"","ShortSnapLastName__c":"Mishra","ShortSnapPrimaryPhoneNumber__c":"","ShortSnapPreferredNotificationMethodCode__c":"P"}';
    
    //Method to test pass scenario
    @isTest
    public static void submitApplication_valid(){
        
        test.startTest();
        	SSP_SubmitShortSNAPApplication.submitApplication(applicationString);
        test.stopTest();
        
        
    }

}