/*
* Classname     :  SSP_ShoppingIntegrationTest
* @description  :  This class is a Unit test class for SSP_ShoppingIntegration class
* @author       :  Ragunathan
* @date         :  06/16/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       			MM/DD/YYYY          A Brief Description about the Change
* Ragunathan					06/16/2020			Initial creation
**/
@isTest
public class SSP_ShoppingIntegrationTest {

    @isTest
    static void shouldGenerateEncryptedData() {
        EncryptionDecryptionSettings__c settings = new EncryptionDecryptionSettings__c();
        settings.Name = 'SSPKey';
        settings.Key__c = 'r5u8x!A%D*G-KaPdSgVkYp3s6v9y$B?E';
        upsert settings Name;
        SSP_LightningResponse response = SSP_ShoppingIntegration.generateEncryptedData('123456', true);

        Map<String, Object> mapResp = response.mapResponse;
        String input = (String) mapResp.get('responseData');
        final String cryptoKey = EncryptionDecryptionSettings__c.getInstance('SSPKey').Key__c;
        Blob cryptoKeyValue = Blob.valueof(cryptoKey);

        Blob data = EncodingUtil.base64Decode(input); 
        Blob decryptedData = Crypto.decryptWithManagedIV('AES256', cryptoKeyValue, data); 
        String decryptData = decryptedData.toString(); 
        
        Map<String, Object> decryptDataMap = (Map<String, Object>) JSON.deserializeUntyped(decryptData);
        String jsonStr = JSON.serialize(decryptDataMap.get('data'));
        SSP_ShoppingIntegration.ShoppingRequest requestSent = (SSP_ShoppingIntegration.ShoppingRequest) JSON.deserialize(jsonStr, SSP_ShoppingIntegration.ShoppingRequest.class);
        System.assertEquals('123456', requestSent.caseNumber);
    }
}