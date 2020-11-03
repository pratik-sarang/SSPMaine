public class SSP_ShoppingIntegration {
    
    static final String cryptoKey = EncryptionDecryptionSettings__c.getInstance('SSPKey').Key__c;
    static Blob cryptoKeyValue = Blob.valueof(cryptoKey);
    @AuraEnabled
    public static SSP_LightningResponse generateEncryptedData(String caseNumber, Boolean isHeadOfHouseHold) {        
        SSP_LightningResponse objResponse = new SSP_LightningResponse();
        String responseData;
        try {
            
            responseData = getRequestBody(caseNumber);
            
            objResponse.bIsSuccess = true;
            objResponse.put('responseData', responseData);
            String portalUrl;
            
            if(isHeadOfHouseHold)
                portalUrl = SSPIntegrationEndpoints__c.getInstance('ShoppingPortal').URL__c + responseData;
            else 
                portalUrl = SSPIntegrationEndpoints__c.getInstance('ShoppingPortalNonPrimary').URL__c + responseData;
            objResponse.put('shoppingPortalUrl', portalUrl);
        } 
        catch (Exception ex) {            
            objResponse.bIsSuccess = false;
            objResponse.put('error', ex.getMessage());
        }
        
        return objResponse;
    }
    
    public static String getRequestBody(String caseNumber) {
        
        Map<String, ShoppingRequest> mapParams = new Map<String, ShoppingRequest>();
        ShoppingRequest reqDetail = new ShoppingRequest();
        reqDetail.CaseNumber = caseNumber;
        reqDetail.TimeStamp = SSP_Utility.now();
        reqDetail.Language = UserInfo.getLanguage() == 'en_US' ? 'EN' : 'ES';        
        mapParams.put('data', reqDetail);        
        Blob data = Blob.valueOf(JSON.serialize(mapParams)); 
        Blob encryptedData = Crypto.encryptWithManagedIV('AES256', cryptoKeyValue, data ); 
        String encryptedValue = EncodingUtil.base64Encode(encryptedData); 
        
        return encryptedValue;
    }
    public class ShoppingRequest {
        public String CaseNumber;
        public DateTime TimeStamp;
        public String Language;
    }
}