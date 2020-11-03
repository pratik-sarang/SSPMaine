/*
* Classname     :  SSP_ContentDocumentCleanUp_Batch
* @description  :  This is a batch class to clean up the ContentDocument linked to the DocumentDetail__c,
				   Based on the last n days of last modified date, this batch will pick up the Files linked to the DocumentDetail__c and delete it.
* @author       :  Ragunathan
* @date         :  08/12/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  08/12/2020			Initial creation
**/
global class SSP_ContentDocumentCleanUp_Batch implements Database.Batchable<sObject> {
    //Number of Days from when to consider the DocumentDetail__c to process.
    private Integer numberOfdays;
    public static final String BATCH_NAME = 'SSP_ContentDocumentCleanUp_Batch';
	public SSP_ContentDocumentCleanUp_Batch(Integer numberOfdays) {
		this.numberOfdays = numberOfdays;
	}
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of Document details based on the date
        //Is there any check on date of DocumentDetail__c ?
		String query =  '   SELECT   '  + 
 						'		  Id,  '  + 
 						'		  ContentDocumentId__c,  '  + 
 						'		  StatusCode__c   '  + 
 						'	FROM DocumentDetail__c   '  + 
 						'	Where ContentDocumentId__c != null AND   '  + 
 						'   	  StatusCode__c != null AND  '  + 
 						'   	  LastmodifiedDate = LAST_N_DAYS:'+numberOfdays ;
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<DocumentDetail__c> records){
        try {
            List<DocumentDetail__c> docDetailToUpdate = new List<DocumentDetail__c>();
            List<Id> contentDocIdsToDelete = new List<Id>();
            for(DocumentDetail__c dd: records) {
                contentDocIdsToDelete.add(dd.ContentDocumentId__c);
                dd.ContentDocumentId__c = '';
                docDetailToUpdate.add(dd);
            }
            
            delete [Select Id from ContentDocument where Id IN: contentDocIdsToDelete];
            //Removing the ContentDocumentId__c from the DocumentDetail__c records
            update docDetailToUpdate;
        } catch (Exception ex) {
            LOG_LogMessageUtility.logMessage(ex, BATCH_NAME, 'execute', ex.getMessage() , true);
        }
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}