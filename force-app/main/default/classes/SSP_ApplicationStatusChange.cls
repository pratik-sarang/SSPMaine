global class SSP_ApplicationStatusChange implements Database.Batchable<sObject>,Schedulable{
    date lastSubmissionDate = SSP_Utility.today().addDays(-8);
    String unStatus=SSP_GlobalConstants.BATCH_SSP_APPLICATION_STATUS_UN;
    
    Id recordTypeId = Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName()
        .get(SSP_GlobalConstants.BATCH_RECORDTYPE_DEVNAME_SSPAPPLICATION).getRecordTypeId();
    
    String Query='SELECT Id, ApplicationCreationInSSP__c,RecordTypeId, Status__c FROM SSP_Application__c where ApplicationCreationInSSP__c < : lastSubmissionDate and RecordTypeId=:recordTypeId and Status__c=:unStatus';
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<SSP_Application__c> scope){
        List<SSP_Application__c> listApplications =new List<SSP_Application__c>();
        if(scope.size()>0) 
        {
            for(SSP_Application__c sspApp : scope){
                sspApp.Status__c=SSP_GlobalConstants.BATCH_SSP_APPLICATION_STATUS_INACTIVE;
                listApplications.add(sspApp);
                
            }
            if (Schema.sObjectType.SSP_Application__c.fields.Status__c.isUpdateable()){
                update scope;
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
    }
    
    global void execute(SchedulableContext sc) {
        SSP_ApplicationStatusChange batchObj = new SSP_ApplicationStatusChange();
        database.executebatch(batchObj);
    }
}