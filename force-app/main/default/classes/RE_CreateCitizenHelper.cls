/**
* Class Name    : RE_CreateCitizenHelper
* Owner         : DELOITTE
* Created Date  : 11/11/2019
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  10/22/2019  Payal Dubela       Initial Version
* */
public with sharing class RE_CreateCitizenHelper {
    
    public static Id createContact(Integer individualId,RE_ClientsHelper.DataTableWrapper clientData){

        Boolean bContact = false;
        Set<Id> setContactIds = new Set<Id>(); 
        Set<Integer> setIeesIds = new Set<Integer>(); 
        Set<Integer> setIeesIdsNotInMappingTable = new Set<Integer>();
        Set<Integer> setIeesIdsInMappingTable = new Set<Integer>();
        Integer latestIeesId;
        Id latestContactId ;
        map<Integer,Id> mapContactIEESIds = new map<Integer,Id>();
        List<Contact_Mapping__c> lstContactMapping = new List<Contact_Mapping__c>();
        List<RE_ResidentLogic.ContactMappingWrapper> lstContMapWrap = new List<RE_ResidentLogic.ContactMappingWrapper>();
        List<SystemAlert__c> lstSystemAlerts = new List<SystemAlert__c>();
        WebServiceSettings__c mciConfig = WebServiceSettings__c.getValues('MCI Client Search');
        String sourceName = mciConfig.Source_System__c; 
        SSP_ResidentLogic.MCIResponseWrapper returnResultMCIwrapper=SSP_ResidentLogic.getIndividualInfo(String.valueOf(individualId),null,sourceName);
       Contact citizenContact=new Contact();
       
       latestIeesId = RE_ResidentLogic.getlatestIEEsid(returnResultMCIwrapper.setIeesIds);
       if(returnResultMCIwrapper.setIeesIds.isEmpty()){
           citizenContact=createCitizenContact(clientData,latestIeesId,returnResultMCIwrapper);
           lstContactMapping.add(createContactMapping(citizenContact.Id,individualId));
           latestContactId=citizenContact.Id;
       }else{
           
           List<Contact_Mapping__c> lstContactMap = new List<Contact_Mapping__c>();
           
           if (Schema.sObjectType.Contact_Mapping__c.fields.Contact__c.isAccessible() && Schema.sObjectType.Contact_Mapping__c.fields.IEES_Id__c.isAccessible()
              && Schema.sObjectType.Contact_Mapping__c.fields.Group_Id__c.isAccessible() ) {
               lstContactMap = [SELECT Contact__c,IEES_Id__c,Group_Id__c FROM Contact_Mapping__c WHERE IEES_Id__c IN:returnResultMCIwrapper.setIeesIds];
              }
                if(!lstContactMap.isEmpty()){
                     Id contactId = lstContactMap[0].Contact__c;
                        for(Contact_Mapping__c conMap :lstContactMap){
                            mapContactIEESIds.put(integer.valueOf(conMap.IEES_Id__c),conMap.Contact__c);
                            RE_ResidentLogic.ContactMappingWrapper cmw = new RE_ResidentLogic.ContactMappingWrapper(conMap.Contact__c,integer.valueOf(conMap.IEES_Id__c),conMap.Group_Id__c);
                            lstContMapWrap.add(cmw);
                            setIeesIdsInMappingTable.add(integer.valueOf(conMap.IEES_Id__c));
                            setContactIds.add(conMap.Contact__c);
                            bContact = conMap.Contact__c != contactId?true:false;
                         }
                    
                     for(Integer ieesids : returnResultMCIwrapper.setIeesIds){
                            if(!setIeesIdsInMappingTable.contains(ieesids)){
                                setIeesIdsNotInMappingTable.add(ieesids);
                            }
                     } 
                     //if returned IEES id's belong to same contact
                    if(!bContact){
                        latestContactId=contactId;
                        for(Integer IEESId : setIeesIdsNotInMappingTable){
                            Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                            objContactMapping.Contact__c = contactId;
                            objContactMapping.IEES_Id__c = IEESId;
                                for(RE_ResidentLogic.ContactMappingWrapper cmw : lstContMapWrap){
                                    objContactMapping.Group_Id__c = cmw.ieesId == IEESId ? cmw.groupId : 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                }
                            lstContactMapping.add(objContactMapping);
                      }
                 }else{ // is IEES ids's doesn't belong to the same contact
                     RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (Schema.sObjectType.Contact.fields.Id.isAccessible()) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
                      switch on (switchContactUserKey) {
                         when SWITCH_SUCCESS {
                                 Contact con = RE_DataAccessChecker.isAllowedToAccess(Contact.sObjectType) && RE_DataAccessChecker.isSafeField('Id', 'Contact')?[SELECT Id FROM Contact WHERE Id=:mapContactIEESIds.get(latestIeesId) LIMIT 1]:new Contact();
                             latestContactId=con.Id;
                          for(Integer IEESId : setIeesIdsNotInMappingTable){
                                Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                                objContactMapping.Contact__c = con.Id;
                                objContactMapping.IEES_Id__c = IEESId;
                                //check if IEES id belong to other contact
                                    for(RE_ResidentLogic.ContactMappingWrapper cmw : lstContMapWrap){
                                        if(cmw.ieesId == IEESId ){
                                            objContactMapping.Group_Id__c = cmw.groupId;
                                            SystemAlert__c objSystemAlert = new SystemAlert__c();
                                            objSystemAlert.AlertDetails__c = 'This is a duplicate the contact';
                                            objSystemAlert.ParentId__c = con.Id;
                                            objSystemAlert.IEESId__c = IEESId;
                                            objSystemAlert.GroupId__c = cmw.groupId;
                                            lstSystemAlerts.add(objSystemAlert);
                                        }
                                        else{
                                            objContactMapping.Group_Id__c = 'Grp'+string.valueOf(IEESId)+String.valueOf(DateTime.now().getTime()).right(3);
                                        }
                                    }
                            lstContactMapping.add(objContactMapping);
                           }
                         }
                    }
                }
               }else{
                    Contact con=createCitizenContact(clientData,latestIeesId,returnResultMCIwrapper);
                    latestContactId=con.Id;
                    String grpId ='Grp'+string.valueOf(latestIeesId)+String.valueOf(DateTime.now().getTime()).right(3);
                     for(Integer IEESId : returnResultMCIwrapper.setIeesIds){
                            Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
                            objContactMapping.Contact__c = con.Id;
                            objContactMapping.IEES_Id__c = IEESId;
                            //check if IEES id belong to other contact
                            //RESecurity Changes - Payal dubela
                            objContactMapping.Group_Id__c = grpId;
                            lstContactMapping.add(objContactMapping);
                    }

               }
           } 

        if(!lstContactMapping.isEmpty()){
                        //INSERT lstContactMapping;
                 RE_SharingByPassCtrl.insertSobjects(Contact_Mapping__c.getSobjectType(), lstContactMapping);
        }
        if(!lstSystemAlerts.isEmpty()){
                                //INSERT lstSystemAlerts;
            RE_SharingByPassCtrl.insertSobjects(SystemAlert__c.getSobjectType(), lstSystemAlerts);
        }

       return  latestContactId;
    }

    public static Contact createCitizenContact(RE_ClientsHelper.DataTableWrapper clientData,Integer IEESId,SSP_ResidentLogic.MCIResponseWrapper MCIResp){
        RecordType objRecordType = GeneralUtility.fetchRecordType('Citizen', 'Contact');
        Contact con = new Contact();
        //only mandatory fields are added for now , in order to get contact created
        con.RecordTypeId = objRecordType.Id;
        con.FirstName = clientData.FirstName;
        con.LastName = clientData.LastName;
        con.Email = clientData.Email;
        con.Gender__c = clientData.Gender;
        con.Phone=clientData.Phone;
        con.Birthdate=clientData.Birthdate;
        con.GenderCode__c = MCIResp.Gender == 'Male' ? 'M' : (MCIResp.Gender == 'Female' ? 'F' : 'U');
        if(IEESId != 0) con.IndividualId__c = String.valueof(IEESId);
        if(string.isNotBlank(MCIResp.SSN)) con.SSN__c = MCIResp.SSN; 
        con.Status__c=RE_GlobalConstants.ACTIVE; 
        //RE_Release 1.2 – Bug 365740- Payal Dubela– Remove Preferred communication population on contact
        //con.PreferredCommunicationMethod__c=clientData.PreferredContactMethodCode;
        Map<Boolean, String> mapContactResponse = RE_DataAccessChecker.checkSafeFields(con);
        RE_GlobalConstants.SWITCH_CONSTANTS switchContactUserKey = (mapContactResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchContactUserKey) {
         when SWITCH_SUCCESS {
              RE_SharingByPassCtrl.insertSobject(con.getSobjectType(), con);
         }
        when SWITCH_FAILURE {LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,RE_CreateCitizenHelper.class.getName(), 'createContact', RE_GlobalConstants.FLS_ERROR + '' + mapContactResponse.get(false), true);}
       }   
        return con;

    }
    public static Contact_Mapping__c createContactMapping(Id contactId,Integer individualId){
    
         Contact_Mapping__c objContactMapping = new Contact_Mapping__c();
         objContactMapping.Contact__c = contactId;
         objContactMapping.IEES_Id__c = individualId;
         objContactMapping.Group_Id__c = 'Grp'+string.valueOf(individualId)+String.valueOf(DateTime.now().getTime()).right(3);

        return objContactMapping;
    }

}