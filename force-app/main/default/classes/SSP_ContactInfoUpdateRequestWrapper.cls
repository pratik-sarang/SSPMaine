/*
* Classname         :  SSP_ContactInfoUpdateRequestWrapper
* @description  :  This class is request Wrapper for SSP-DC Contact Info Update
* @author       :  Rajeev Kumar
* @date         :  03/04/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
**/
public with sharing class SSP_ContactInfoUpdateRequestWrapper {
    // public attributes
    private Integer IndividualId;
    public Integer ContactId;
    public String Email;
    public String PrimaryPhoneNumber;
    public String PrimaryPhoneTypeCode;
    public String PrimaryPhoneExtension;
    public String IsPrimaryTextPreferred;
    public String SecondaryPhoneNumber;
    public String SecondaryPhoneExtension;
    public String IsSecondaryTextPreferred;    
    public String PreferredWrittenLanguageCode;
    public String PreferredSpokenLanguageCode;
    public String ContactMethodCode;
    public String PreferredTaxNotificationMethodCode;

    /**
    * method        : Constructor
    * @description  : Constructor to set values
    * @author       : Rajeev Kumar
    * @param sIndividualId : Individual Id of the member
    * */
    public SSP_ContactInfoUpdateRequestWrapper(String sIndividualId) {
        List<SSP_Member__c> lstMember;
        if(schema.sObjectType.SSP_Member__c.fields.IndividualId__c.isAccessible()) {
            lstMember = [SELECT Id, IndividualId__c, Email__c, DCID__c,
                                                PrimaryPhoneNumber__c, PrimaryPhoneTypeCode__c, PrimaryPhoneExtension__c, 
                                                IsPrimaryTextPreferred__c, SecondaryPhoneNumber__c, SecondaryPhoneExtension__c,
                                                Send_Text_messages_to_Secondary__c, PreferredWrittenLanguageCode__c,
                                                PreferredSpokenLanguageCode__c, PreferredNotificationMethodCode__c, PreferredNotificationMethodForTaxCode__c
                                                FROM SSP_Member__c
                                                WHERE IndividualId__c = :sIndividualId];
        }
        if(lstMember != null && !lstMember.isEmpty()) {
            SSP_Member__c objMember = lstMember[0];
            this.IndividualId = Integer.valueof(objMember.IndividualId__c);
            this.Email = objMember.Email__c;
            this.ContactId = Integer.valueof(objMember.DCID__c);
            this.PrimaryPhoneNumber = objMember.PrimaryPhoneNumber__c;
            this.PrimaryPhoneTypeCode = objMember.PrimaryPhoneTypeCode__c;
            this.PrimaryPhoneExtension = objMember.PrimaryPhoneExtension__c;
            this.IsPrimaryTextPreferred = objMember.IsPrimaryTextPreferred__c;
            this.SecondaryPhoneNumber = objMember.SecondaryPhoneNumber__c;
            this.SecondaryPhoneExtension = objMember.SecondaryPhoneExtension__c;
            this.IsSecondaryTextPreferred = objMember.Send_Text_messages_to_Secondary__c;
            this.PreferredWrittenLanguageCode = objMember.PreferredWrittenLanguageCode__c;
            this.PreferredSpokenLanguageCode = objMember.PreferredSpokenLanguageCode__c;
            this.ContactMethodCode = objMember.PreferredNotificationMethodCode__c;
            this.PreferredTaxNotificationMethodCode = objMember.PreferredNotificationMethodForTaxCode__c;
        }
    }
}