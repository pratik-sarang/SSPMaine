/***************************************************************************************************************************************
* Class Name    : StaffJitHandler 
* Owner         : Deloitte
* Created Date  : 11/05/2019 
* Description   : class is used to make a Inquiry Service Call out
*
*  Exception generated from this class follows below error code description
* 
*  ERR001: User does not have UW Staff role from KOG SAML on User Creation 
*  ERR002: CreateUser: Error inserting user in Database
*  ERR003: UpdateUser: Error updating User to Database
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date          Developer       	Description                                                         
*  ----------    -------------     	----------------------------------------------------------------------------------------------------
*  04/29/2020	 Venkat Korra		Task-339189: Added changes related to New Production Support Profile. 
*									And modified class name from REStaffJitHandler to StaffJitHandler
****************************************************************************************************************************************/
global class StaffJitHandler implements Auth.SamlJitHandler {
    
    public class CcAccessException extends Exception{}
   //Sample code for Jit Handler
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        StaffHandler.staffExceptionCapture staffException = new StaffHandler.staffExceptionCapture();    
        User usr;
            Boolean UpdateCon=false, CreateCon=false;
            usr = JitHelper.parseSamlAttribute(attributes);
            String userinfo=JSON.serialize(usr);
        
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new CcAccessException('MFARequired');
            }
        }
          //[Suresh] set applicable role field
            if(usr.KOG_Role__c.contains('UW Staff')){
              usr.ApplicableRoles__c = 'RE United Way Staff'; 
            }
            else if(usr.KOG_Role__c.contains('SF Production Support')){
                usr.ApplicableRoles__c = 'PROD_Support_Read_Only'; 
            } 
            /*String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new CcAccessException('MFARequired');
            }*/
            // Venkat: 04/29/2020: Task-339189: Added changes related to New Production Support Profile.
            if(usr.KOG_Role__c.contains('UW Staff') || usr.KOG_Role__c.contains('SF Production Support')){
                staffException = StaffHandler.createUser(usr,FederationIdentifier);
                if(staffException.isExceptionFound){
                    throw new CcAccessException(staffException.ExceptionCode);
                }
            }
            // Venkat: 04/29/2020: Task-339189: Added changes related to New Production Support Profile.
            if(!usr.KOG_Role__c.contains('UW Staff') && !usr.KOG_Role__c.contains('SF Production Support') && !usr.KOG_Role__c.contains('State User')){
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'StaffJitHandler','createUser',
                                                 ' Role is Not appropriate' +federationIdentifier ,false);             
                throw new CcAccessException('ERR001');// role doesn't match
            }
        return usr;
    }
    

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,String federationIdentifier, Map<String, String> attributes, String assertion) {
        User usr= JitHelper.parseSamlAttribute(attributes);
        if(attributes.containskey(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c)){
            String needKogVisitValue = attributes.get(KOG_SAML_Attributes__c.getValues('needkogvisit').SAML_Attribute__c);
            if(needKogVisitValue == 'yes') {
                throw new CcAccessException('MFARequired');
            }
        }
           //[Suresh] set applicable role field
        if(usr.KOG_Role__c.contains('UW Staff')){
          usr.ApplicableRoles__c = 'RE United Way Staff'; 
        }
        else if(usr.KOG_Role__c.contains('SF Production Support')){
            usr.ApplicableRoles__c = 'PROD_Support_Read_Only'; 
        } 
        /*KOG_SAML_Attributes__c kogSamlAttr = KOG_SAML_Attributes__c.getValues('needkogvisit');
        if(attributes.get(kogSamlAttr.SAML_Attribute__c) == 'Yes'){
            throw new CcAccessException('MFARequired');
        }*/
        // Venkat: 04/29/2020: Task-339189: Added changes related to New Production Support Profile.
        if(usr.KOG_Role__c != null && (usr.KOG_Role__c.contains('UW Staff') || usr.KOG_Role__c.contains('SF Production Support'))){
            usr = StaffHandler.updateUser(usr,federationIdentifier);
        }
    }

}