public class RE_PopulateGeoLocationAsync implements Queueable, Database.AllowsCallouts {
    List<Location__c> lstLocation= new List<Location__c>();
    List<Contact> lstContact= new List<Contact>();
    List<Location__c> lstLocToUpdate = new List<Location__c>();
    List<Contact> lstConToUpdate = new List<Contact>();
    String zipCode;
    String sObjectName;
    Integer loopCount = 0;
    Integer iChunk = 0;
    Integer extraRecs = 0;
    public RE_PopulateGeoLocationAsync(List<Location__c> lstLocation){
        this.lstLocation = lstLocation;
    }
    public RE_PopulateGeoLocationAsync(List<Contact> lstContact){
        this.lstContact = lstContact;
    }
    public void execute(QueueableContext context) {
     try{
        if(!lstLocation.isEmpty()){
            for(Location__c loc : lstLocation){ 
                Id sId = loc.id;
                sObjectName = sId.getSObjectType().getDescribe().getName();
                if(loc.Zip__c == null){
                    
                    zipCode = (loc.Address1__c == null ? '' : loc.Address1__c)+(loc.Address2__c == null ? '' : loc.Address2__c)+(loc.City__c == null ? '' : loc.City__c);
                }else{
                    zipCode = (loc.Address1__c == null ? '' : splitAndAppendData(loc.Address1__c)+'+')+(loc.Address2__c == null ? '' : splitAndAppendData(loc.Address2__c)+'+')+(loc.City__c == null ? '' : splitAndAppendData(loc.City__c)+'+')+loc.Zip__c;
                }
                Location__c objLoc = (Location__c)RE_PopulateLatAndLong.calloutmethod(loc,sObjectName,zipCode);
                if(objLoc != null){
                    lstLocToUpdate.add(objLoc);
                }
                loopCount++; 
            }
            
            if(lstLocToUpdate!= null && !lstLocToUpdate.isEmpty()){
                makeDMLOperation(lstLocToUpdate);
            }
        }else if(!lstContact.isEmpty()){
            for(Contact con:lstContact){
                Id sId = con.id;
                sObjectName = sId.getSObjectType().getDescribe().getName();
                zipCode = (con.MailingStreet == null ? '' : splitAndAppendData(con.MailingStreet)+'+')+(con.MailingCity == null ? '' : splitAndAppendData(con.MailingCity)+'+')+(con.MailingState == null ? '' : splitAndAppendData(con.MailingState)+'+')+(con.MailingCountry == null ? '' : splitAndAppendData(con.MailingCountry)+'+')+con.MailingPostalCode;
                //zipCode = con.MailingStreet+con.MailingCity+con.MailingState+con.MailingCountry+con.MailingPostalCode;
                Contact objCon = (Contact)RE_PopulateLatAndLong.calloutmethod(con,sObjectName,zipCode);
                if(objCon != null){
                    lstConToUpdate.add(objCon);
                }
            }
            if(lstConToUpdate!= null && !lstConToUpdate.isEmpty()){
                makeDMLOperation(lstConToUpdate);
            }
        }
    }catch(Exception e){
        LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_PopulateGeoLocationAsync','execute',e.getMessage()+' '+e.getStackTraceString(),true);
    }
        
    }
    
    public static void makeDMLOperation(List<sObject> sObj){
        if(sObj != null && !sObj.isEmpty()){
            Schema.SObjectType objectType = sObj[0].getSObjectType();
            String switchKey = (objectType ==Contact.getSObjectType()) ? 'Contact' : 'Location__c'; 
            switch on (switchKey) {
                when 'Contact' {
                    RE_DataAccessChecker.updateObjects(Contact.getSObjectType(), sObj,false); 
                }
                when 'Location__c' {
                    RE_DataAccessChecker.updateObjects(Location__c.getSObjectType(), sObj,false);
                }
            }
        }
    }
    
    public String splitAndAppendData(String strAddress){
        String appendedData=strAddress.replaceAll(' ', '+');
        return appendedData;
    }
}