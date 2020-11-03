/*
* Classname     :  SSP_ContentDocumentCleanUp_Sch
* @description  :  This is a scheduler class for Batch 'SSP_ContentDocumentCleanUp_Batch'.
* @author       :  Ragunathan
* @date         :  09/08/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  09/08/2020			Initial creation
**/
global class SSP_ContentDocumentCleanUp_Sch implements Schedulable {
    Integer defaultDays = 0;
    public SSP_ContentDocumentCleanUp_Sch(Integer defaultDays) {
        this.defaultDays = defaultDays;
    }
    
   global void execute(SchedulableContext sc) {
      SSP_ContentDocumentCleanUp_Batch batchObj = new SSP_ContentDocumentCleanUp_Batch(defaultDays); 
      database.executebatch(batchObj);
   }
}