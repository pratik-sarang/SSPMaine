global with sharing class RE_CitizenNonCitizenJITHandlerHelper {
   public static string rolesToBeAssigned(List<String> lstRolesFromKog){
        return SSPCitizenJITHandler.rolesToBeAssigned(lstRolesFromKog);
    }

 @future 
    public static void UpdateConDetails(id ConId, String RecordTypeNametoUpdate,string AgentId){
        contact con = RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('RecordTypeId', 'Contact') && RE_DataAccessChecker.isSafeField('AgentId__c', 'Contact')?[SELECT Id,RecordTypeId,RecordType.Name,AgentId__c FROM Contact WHERE Id=:conid]:new Contact();
        Boolean doUpdate=false;
        
        if(String.isNotBlank(RecordTypeNametoUpdate) && String.isNotEmpty(RecordTypeNametoUpdate) && con.RecordType.Name != RecordTypeNametoUpdate ){
            RecordType objContactRecordType = GeneralUtility.fetchRecordType(RecordTypeNametoUpdate, 'Contact');
            con.RecordTypeId = objContactRecordType.Id;
            doUpdate=true;
        }
        if(String.isNotBlank(AgentId) && String.isNotEmpty(AgentId) && con.AgentId__c!=AgentId){
            con.AgentId__c=AgentId;
            doUpdate=true;
        }
        if(doUpdate && Schema.sObjectType.contact.isUpdateable()){
            update con;
        }
    }
}