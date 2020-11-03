/*********************************************************************************************************************************
* Class Name    : CPUserCreationBatch 
* Owner         : Sai Kiran
* Created Date  : 11/05/2019 
* Description   : Batch class is used to make a Inquiry Service Call out
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
global class CPUserCreationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    Set<ID> conIds = new Set<ID>();
    
    //Constructor initialization
    global CPUserCreationBatch(Set<ID> contactIds) {
        
        conIds = contactIds;
    }
    
    //Quuery method.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        String sQuery = 'SELECT Id, Account.Name,Name,FirstName,LastName, Phone, Email, PermissionsLevel__c,Isclaim__c FROM Contact WHERE ID IN : conIds';
        return DataBase.getQueryLocator(sQuery);
    }
    
    //Execute
    global void execute(Database.BatchableContext BC,List<Contact> lstContact) {
        
        RECommunityPartnerLogin CPUserLogic = new RECommunityPartnerLogin();
        CPUserLogic.sendEmailtoCommunityPartner(lstContact);
        
    }
    
    //Finish method to execute at last.
    global void finish(Database.BatchableContext BC) {
        //mandatory method in batch apex 
    }
    
}