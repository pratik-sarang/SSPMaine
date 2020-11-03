/*
* classname     :  SSP_MedicareCoverageDetails
* @description  :  Class to get medical coverage details
* @author       :  Varun Kochar   
* @date         :  04/02/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/
public class SSP_MedicareCoverageDetails {
    
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   getMedicalCoverageDetail
* @description  This methods is used to get medical coverage detail
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static SSP_LightningResponse getMedicalCoverageDetail(Id benefitId, String memberId){
        try{
            SSP_Utility.isAuthenticatedUser();
            SSP_LightningResponse objResponse = new SSP_LightningResponse();
            SSP_MedicareCoverageDetailsWrapper wrapper = new SSP_MedicareCoverageDetailsWrapper();
            List<SSP_Benefits__c> sspBenefitList = SSP_MedicareCoverageService.getBenefit(new Set<String>{memberId});
            if(!sspBenefitList.isEmpty()){
                for(SSP_Benefits__c benefitObj : sspBenefitList){
                    if(benefitObj.Id == benefitId){
                        wrapper.benefit = benefitObj;
                        wrapper.memberName = benefitObj.SSP_Member__r.FirstName__c + ' ' + benefitObj.SSP_Member__r.LastName__c;
                    }else{
                        wrapper.benefitList.add(benefitObj);
                    }
                }
            }
            if(wrapper.benefit == null){
                String benefitRecordtypeId = Schema.SObjectType.SSP_Benefits__c.getRecordTypeInfosByDeveloperName().get(SSP_GlobalConstants.MEDICAREBENEFIT).getRecordTypeId();
                List<SSP_Member__c> memberList = SSP_MedicareCoverageService.getMember(new Set<String>{memberId});
                wrapper.benefit = new SSP_Benefits__c(SSP_Member__c = memberId , RecordtypeId = benefitRecordtypeId);
                wrapper.memberName = memberList[0].FirstName__c + ' ' + memberList[0].LastName__c;
            }
            Date timeTravelTodayDate = SSP_Utility.today();
            objResponse.put('wrapper', wrapper);
            objResponse.put('timeTravelTodayDate', timeTravelTodayDate);
            return objResponse;
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageDetails', 'getMedicalCoverageDetail', e.getMessage(), true);
        }
        return null;
    }
    /***************************************************************************************************
* @author       Varun Kochar
* @date         04/02/2020
* @methodname   saveMedicalCoverageDetail
* @description  This methods is used to save medical coverage detail
* @return       
*****************************************************************************************************/
    @auraEnabled
    public static void saveMedicalCoverageDetail(SSP_Benefits__c benefit, String memberId){
        try{
            SSP_Utility.isAuthenticatedUser();
            if(String.isBlank(benefit.Id)){
                benefit.SSP_Member__c = memberId;
            }
            upsert benefit;
            Set<String> membersSet = new  Set<String>{memberId};
            List<SSP_Member__c> members = SSP_MedicareCoverageService.getMember(membersSet);
            if(members.size()>0 && members[0].IsReceivingMedicareBenefitToggle__c== SSP_GlobalConstants.NO){
                members[0].IsReceivingMedicareBenefitToggle__c= SSP_GlobalConstants.YES;
                update members[0];
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_MedicareCoverageDetails', 'saveMedicalCoverageDetail', e.getMessage(), true);
        }
        
    }
    public class SSP_MedicareCoverageDetailsWrapper{
        @AuraEnabled public SSP_Benefits__c benefit;
        @AuraEnabled public String memberName;
        @AuraEnabled public List<SSP_Benefits__c> benefitList = new List<SSP_Benefits__c>();
    }
}