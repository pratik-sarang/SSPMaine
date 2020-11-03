/*
* classname     :  SSP_KHIPPPreferredPaymentMethod
* @description  :  Class for getting KHIPP Preferred payment method;
* @author       :  Varun Kochar   
* @date         :  23/01/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_KHIPPPreferredPaymentMethod {
    /***************************************************************************************************
* @author       Varun Kochar
* @date         24/01/2019
* @methodname   SSP_KHIPPPreferredPaymentMethodWrapper
* @description  This methods is used to get details of SSP Member
* @return       
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getKHIPPDetails(String applicationId){
        try{
            SSP_Utility.isAuthenticatedUser();
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            List<SSP_KHIPPPreferredPaymentMethodWrapper> wrapper = new  List<SSP_KHIPPPreferredPaymentMethodWrapper>();
            Set<String> setRoutingIds = new set<String>();
            List<SSP_Institution__c> lstInstitution = new List<SSP_Institution__c>();
            Map<String, SSP_Member__c> memberAndIdMap = new Map<String, SSP_Member__c>();
            Map<String, SSP_Institution__c> routingInstitutionMap = new Map<String, SSP_Institution__c>();
            List<SSP_ApplicationIndividual__c> lstApplicationIndividual = SSP_KHIPPPreferredPaymentMethodService.getApplicationIndividual(new Set<String>{applicationId});
            for(SSP_ApplicationIndividual__c applicationIndividual : lstApplicationIndividual){
                SSP_Member__c member = new SSP_Member__c();
                member.Id = applicationIndividual.SSP_Member__c;
                member.Name = applicationIndividual.SSP_Member__r.Name;
                member.FirstName__c = applicationIndividual.SSP_Member__r.FirstName__c;
                member.LastName__c = applicationIndividual.SSP_Member__r.LastName__c;
                member.MiddleInitial__c = applicationIndividual.SSP_Member__r.MiddleInitial__c;
                member.SuffixCode__c = applicationIndividual.SSP_Member__r.SuffixCode__c;
                member.PreferredIssuanceMethod__c = applicationIndividual.SSP_Member__r.PreferredIssuanceMethod__c;
                member.RoutingNumber__c = applicationIndividual.SSP_Member__r.RoutingNumber__c;
                member.CheckingAccountNumber__c = applicationIndividual.SSP_Member__r.CheckingAccountNumber__c;
                member.MailingAddressLine1__c = applicationIndividual.SSP_Member__r.MailingAddressLine1__c;
                member.MailingAddressLine2__c = applicationIndividual.SSP_Member__r.MailingAddressLine2__c ;
                member.MailingCity__c = applicationIndividual.SSP_Member__r.MailingCity__c ;
                member.MailingCountyCode__c = applicationIndividual.SSP_Member__r.MailingCountyCode__c ;
                member.MailingCountryCode__c = applicationIndividual.SSP_Member__r.MailingCountryCode__c ;
                member.MailingStateCode__c = applicationIndividual.SSP_Member__r.MailingStateCode__c ;
                member.MailingZipCode5__c = applicationIndividual.SSP_Member__r.MailingZipCode5__c ;
                memberAndIdMap.put(applicationIndividual.SSP_Member__c, member);
                if(applicationIndividual.SSP_Member__r.RoutingNumber__c != NULL){
                    setRoutingIds.add(String.valueOf(applicationIndividual.SSP_Member__r.RoutingNumber__c));
                }
            }
            lstInstitution = SSP_KHIPPPreferredPaymentMethodService.getBankDetails(setRoutingIds);
            if(!lstInstitution.isEmpty()){
                for(SSP_Institution__c objInstitution : lstInstitution){
                    routingInstitutionMap.put(objInstitution.RoutingNumber__c, objInstitution);
                }
            }
            List<SSP_InsuranceCoveredIndiv__c> policyHolder = SSP_KHIPPPreferredPaymentMethodService.getCoveredIndividual(memberAndIdMap.KeySet());
            for(SSP_InsuranceCoveredIndiv__c coveredIndividual : policyHolder){
                if(memberAndIdMap.containsKey(coveredIndividual.SSP_Member__c)){
                    SSP_Member__c member = memberAndIdMap.get(coveredIndividual.SSP_Member__c);
                    Boolean isDirectDeposit = String.isNotBlank(member.PreferredIssuanceMethod__c) && member.PreferredIssuanceMethod__c.contains(SSP_GlobalConstants.EFT) ? true : false;
                    Boolean isCheck = String.isNotBlank(member.PreferredIssuanceMethod__c) && member.PreferredIssuanceMethod__c.contains(SSP_GlobalConstants.CH) ? true : false;
                    Boolean showBankDetails = member.RoutingNumber__c != null ? true : false;
                    String bankName = ((member.RoutingNumber__c != null) && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL) && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).Name__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).Name__c : '';
                    String sAddress1 = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).AddressLine1__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).AddressLine1__c+', ': '';
                    String sAddress2 = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).AddressLine2__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).AddressLine2__c+', ': '';
                    String sCity = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).City__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).City__c+', ' : '';
                    String sState = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).StateCode__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).StateCode__c+', ' : '';
                    String sCountry = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).Country__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).Country__c : '';
                    String sCounty = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).County__c != NULL)) ? routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).County__c+', ' : '';
                    String sZipcode = (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)) != NULL && (routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).ZipCode__c != NULL)) ? ', '+routingInstitutionMap.get(String.valueOf(member.RoutingNumber__c)).ZipCode__c : '';
                    String bankAddress = sAddress1+sAddress2+sCity+sCounty+sState+sCountry+sZipCode;
                    wrapper.add(new SSP_KHIPPPreferredPaymentMethodWrapper(member, isDirectDeposit, isCheck, Integer.valueOf(member.CheckingAccountNumber__c), showBankDetails, bankName,bankAddress));
                    memberAndIdMap.remove(coveredIndividual.SSP_Member__c);
                }
            }
            objResponse.put('wrapper', wrapper);
            return objResponse;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethod', 'getKHIPPDetails', e.getMessage(), true);
        }
         
        return null;
    }
    /***************************************************************************************************
* @author       Varun Kochar
* @date         24/01/2019
* @methodname   saveKHIPPPreferredPayment
* @description  This methods is used to save details of SSP members
* @return       
*****************************************************************************************************/
    @AuraEnabled
    public static void saveKHIPPPreferredPayment(String wrapper){
        try{
            SSP_Utility.isAuthenticatedUser();
            List<SSP_KHIPPPreferredPaymentMethodWrapper> wrapperToSave = (List<SSP_KHIPPPreferredPaymentMethodWrapper>)JSON.deserialize(wrapper, List<SSP_KHIPPPreferredPaymentMethodWrapper>.class);
            List<SSP_Member__c> memberList = new List<SSP_Member__c>();
            Map<String,String> map_CountyCode = SSP_Utility.getPickListValue('SSP_Member__c', 'MailingCountyCode__c', null);
            Map<String,String> map_StateCode = SSP_Utility.getPickListValue('SSP_Member__c', 'MailingStateCode__c', null);
            for(SSP_KHIPPPreferredPaymentMethodWrapper memberWrapper : wrapperToSave){
                memberWrapper.member.MailingCountyCode__c = map_CountyCode.get(memberWrapper.member.MailingCountyCode__c);
                memberWrapper.member.MailingStateCode__c = map_StateCode.get(memberWrapper.member.MailingStateCode__c);
                memberList.add(memberWrapper.member);
            }
            if(Schema.sObjectType.SSP_Member__c.isupdateable()){
                update  memberList;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethod', 'saveKHIPPPreferredPayment', e.getMessage(), true);
        }
    }
     /***************************************************************************************************
* @author       Varun Kochar
* @date         24/01/2019
* @methodname   getBankDetails
* @description  This methods is used to get Bank details associated to Routing Number
* @return       
*****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getBankDetails(String routingNumber){
        try{
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            List<SSP_Institution__c> sspInstitutionList = SSP_KHIPPPreferredPaymentMethodService.getBankDetails(new Set<String>{routingNumber});
            if(!sspInstitutionList.isEmpty()){
                objResponse.put('bankDetails', sspInstitutionList[0]);
                return objResponse;
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_KHIPPPreferredPaymentMethod', 'getBankDetails', e.getMessage(), true);
        }
        
        return null;
    }
    public class SSP_KHIPPPreferredPaymentMethodWrapper{
        @AuraEnabled public SSP_Member__c member;
        @AuraEnabled public Boolean isDirectDeposit;
        @AuraEnabled public Boolean isCheck;
        @AuraEnabled public Integer verifyAccountNumber;
        @AuraEnabled public Integer validRoutingNumberCount = 0;
        @AuraEnabled public Boolean showBankDetails;
        @AuraEnabled public String bankName;
        @AuraEnabled public String bankAddress;
        @AuraEnabled public Boolean disablePreferredMethodOfPayment;
        @AuraEnabled public String routingNumberErrorMessage;
        @AuraEnabled public Boolean showRoutingNumberErrorMessage;
        @AuraEnabled public Boolean showDefaultRoutingNumberErrorMessage;
        @AuraEnabled public Boolean disableVerifyAccountNumber = true;
        @AuraEnabled public String verifyAccountErrorMessage;
        @AuraEnabled public Boolean showVerifyAccountErrorMessage;
        public SSP_KHIPPPreferredPaymentMethodWrapper(SSP_Member__c member, Boolean isDirectDeposit, Boolean isCheck, Integer verifyAccountNumber, Boolean showBankDetails,String bankName, String bankAddress){
            this.member = member;
            this.isDirectDeposit = isDirectDeposit;
            this.isCheck = isCheck;
            this.verifyAccountNumber = verifyAccountNumber;
            this.showBankDetails = showBankDetails;
            this.bankName = bankName;
            this.bankAddress = bankAddress;
        }
    }
}