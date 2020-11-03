public class QueuingWrapper {
    @AuraEnabled
	public List<SSP_ApplicationIndividual__c> applicationIndividualList;  
    
    @AuraEnabled
    public Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap;
    
    @AuraEnabled
    public Map<String,List<SSP_Asset__c>> mapMemberAsset;
}