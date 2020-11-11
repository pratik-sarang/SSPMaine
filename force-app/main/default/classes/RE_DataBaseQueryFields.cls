/**
* Class Name    : RE_DataBaseQueryFields
* Owner         : DELOITTE
* Created Date  : 06/24/2019
* Description   : Class for database query fields.
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  05/09/2019  PANKAJ       Initial Version
*  12/04/2019  Megha M      Modified Version- Added the fields firstname,lastname and email to fetch from contact - Bug(341987)
**/
public with sharing class RE_DataBaseQueryFields {
    /* Added By Sai
     * Variable added as part of RE_ReferralDashboardCtrl Class
     */
    public static final String sAccountFieldsReferralDashboardCtrl = 'ID, Rating_Count__c, Rating_Sum__c';
    public static final String sAccountWhereClauseReferralDashboardCtrl = 'ID =:loggedInAccountId';
    
    //Anuj : 361790 New queries
    public static final String sAccountFieldsOffboardEMail = 'Id, Name, POC_Email__c, POC_Name__c';
    public static final String sAccountWhereClauseOffboardEMail = 'Id IN : orgIds';
    
    public static final String sFieldsQueriedOnReferralLR = 'Id,Resource__c,Location__c,FirstPointOfContactName__c, FirstPointofContactEmail__c, SecondPointOfContactName__c, SecondPointofContactEmail__c,OrgId__c,AccountName__c';
    
    public static final String sLocationFieldsOffboardEMail = 'Id, PointOfContactName__c, PointofContactEmail__c, Account__c,AccountName__c';
    public static final String sLocationWhereClauseOffboardEMail = 'Account__c IN : orgIds';
    
    public static final String sFieldsToQueryOnUnclaimedOrg = 'Id,Name,Type,Website,OrganizationUniqueId__c,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode';
    public static final String sLocationWhereClauseOnUnclaimedOrg = 'Id =: orgId';
    
    public static final String sAggrFieldsOnReferralCreate = 'COUNT(Id) cnt, ReferredAccountID__c rid';
    public static final String sAggrWhereClauseOnReferralCreate = 'ReferredAccountID__c IN : setOrgId';
    public static final String sGroupByClauseOnReferralCreate = 'ReferredAccountID__c';
    //Anuj : 361790 New queries ends
    
    public static final String sReferralFieldsReferralDashboardCtrl = 'DateClosed__c, DateOfReferral__c';
    public static final String sReferralWhereClauseReferralDashboardCtrl = 'Status__c =\'Closed\' AND DateOfReferral__c !=NULL AND DateClosed__c!=NULL';
    
    /* Since we need to have a subquery on Resource to display data on Clients 
       and the current framework does not supoort check for subquery,
       we have taken the complete sub query as a final string so that it cannt be modified and prevent SOQL attacks */
	   //srikanth - removed status field from the below SOQL query
    public static final String RESOURCE_SUBQUERY='(SELECT id, Location__c, UserComplete__c, Contacts__c  FROM Referrals__r WHERE UserComplete__c = false AND Status__c !=: sClosed AND Contacts__c =:contactId)';
    
    public static final String sWhereClauseLocationLookup ='Account__c =:loggedInUserAccountId and Status__c = \'Active\' AND Name LIKE: searchKey';
    public static final String sWhereClauseReferralRDResidentViewCtrlKeywordSearch ='UserComplete__c = false AND Status__c IN: referralstatus AND Contacts__c =:contactId';
    public static final String sFieldsforLocResourceOperationHours = 'Id,Location__c,DaysClosed__c,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,'+
    'WednesdayOpen__c,WednesdayClose__c,ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c';
     public static final String sWhereClauseLocResourceOperationHours = 'Id IN : setLocResourceIds';
    // Location Fields
    public static final String sFieldsToQueryOnLocation = 'Id, Name';
    public static final String sWhereClauseOnLocation = 'recordtypeId =: locationRecordTypeId';
    
    public static final String sFieldsToQueryOnLocationCtrl = 'id,PointofContactEmail__c,Name,AnnouncementStatus__c,PointOfContactName__c,'+
        'PointofContactPhone__c,POCPhoneExt__c,SaturdayClose__c,SaturdayOpen__c,SpecialAnnouncements__c,'+
        'SpecialLocationInstructions__c,State__c,SundayClose__c,SundayOpen__c,ThursdayClose__c,'+
        'ThursdayOpen__c, TransportationInstructions__c,TuesdayClose__c,TuesdayOpen__c,Status__c,'+
        'WednesdayClose__c, WednesdayOpen__c,Zip__c,ZipExtensionCode__c,'+
        'ParkingInstructions__c, MondayOpen__c,Address1__c,Address2__c,'+
        'City__c,County__c,Description__c, Email__c,FridayClose__c,FridayOpen__c,'+
        'Language__c,LocationType__c,MondayClose__c,DaysLocationClosed__c,TimeZone__c, Notes__c, LocationWebsite__c, Phone__c';
    
     public static final String sWhereClauseOnLocationCtrl = 'Id =:sRecordId AND RecordtypeId =:locationRecordTypeId';
    public static final String sLocationFieldsOrgSearch = 'Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,LocationType__c,Account__c';
    public static final String sLocationWhereClauseOrgSearch = 'Account__c=:accountId';
    //Added by LK
     public static final String sDaysFieldsQueryLocation = 'MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,'+
                                              'ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,'+
                                              'SundayOpen__c,SundayClose__c';
    public static final String sWhereClauseForDays = 'Id =: LocId';
    public static final String sWhereClauseOnLocationCtrl_RE_CreateLightningServerResponse = 'LinkedEntityId =: sParentId';
    public static final String sQueryRE_CreateLightningServerResponse = 'Id, Title, FileType, CreatedDate, ContentSize, Description, latestpublishedversionId';
    public static final String strWhereClauseOnLocationCtrl_RE_CreateLightningServerResponse = 'Id IN :lstConDocIds';
    public static final String strsDcoDetailsFields = 'id,FileId__c,DocumentType__c,Location__c';
    public static final String sDocDetailWhereClause = 'FileId__c IN : lstConDocIds AND RecordTypeId =: sDocumentRecordType';
    public static final String sDocDetailWhereClauseWithoutSharingMethod = 'Location__c =: sParentId AND RecordTypeId =: sDocumentRecordType';
    public static final String sfieldsConDoc =  'Id';
    public static final String sWhereClauseIdInCont = 'Id =: sContDocId';
    public static final String sFieldsToQueryOnLocationResourceCtrl = 'Id,Name,AgesServed__c,Location__c,Status__c,Phone__c,TollFree__c,Fax__c,ResourceDescription__c,'+
        'Geography_Served__c,EligibilityCCAP__c,EligibilityDescription__c,EligibilityMedicaid__c,EligibilitySNAP__c,EligibilityTANF__c,'+
        'FirstPointofContactEmail__c,FirstPointOfContactName__c,FirstPointofContactPhone__c,FirstPointOfContactTitle__c,'+
        'SecondPointofContactEmail__c,SecondPointOfContactName__c,SecondPointofContactPhone__c,SecondPointOfContactTitle__c,'+
        'TimeZone__c,Fees__c,Notes__c,WhatToBring__c,NextSteps__c,MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,'+
        'ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,Resource__c,DaysClosed__c'; 
        public static final String sWhereClauseOnLocationResourceCtrl = 'Id =:sRecordId'; 
    /*
    *1029 Defect Modifications 
    *Eligibility__c Field removed from Query as Part of Defect 1029
    *Start
    */
	//srikanth - removed status,AgesServed__c,Benefits__c,Category__c,EligibilityCCAP__c,EligibilityDescription__c,EligibilityMedicaid__c,EligibilitySNAP__c,EligibilityTANF__c,Fees__c,IncomeEligibility__c,NextSteps__c, PointofContactEmail__c , PointOfContactName__c , PointofContactPhone__c,WhatToBring__c,Geography_Served__c field from the below SOQL query
    public static final String RE_ResourceCtrlQuery = 'Id, Name,'
                + 'SdohDomain__c,'
        + 'Organization__r.Name, Organization__r.Website,Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c,'
        + 'Organization__r.ShippingStreet,Organization__r.ShippingCity,Organization__r.ShippingState,Organization__r.ShippingPostalCode, ManagingAgencyName__c, ManagingAgencyURL__c, ProgramPolicyURL__c';
    public static final String sWhereClauseRE_ResourceCtrl = 'Organization__c =: sAccountId AND Id =: resourceRecId';
    //RE_RDResidentViewCtrl variables
	//srikanth - removed status,AgesServed__c,Benefits__c,Category__c,EligibilityCCAP__c,EligibilityDescription__c,EligibilityMedicaid__c,EligibilitySNAP__c,EligibilityTANF__c,Fees__c,IncomeEligibility__c,NextSteps__c, PointofContactEmail__c , PointOfContactName__c , PointofContactPhone__c,WhatToBring__c,Geography_Served__c field from the below SOQL query
    //Nandita 12-Feb-2020: removed Description__c
    public static final String RDResidentViewResourceQuery = 'Id, Name,'
                + 'SdohDomain__c, RecordType.Name, '
                + 'Organization__r.Name, Organization__r.Website,Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c,'
                + 'Organization__r.ShippingStreet,Organization__r.ShippingCity,Organization__r.ShippingState,Organization__r.ShippingPostalCode, ManagingAgencyName__c, ManagingAgencyURL__c, ProgramPolicyURL__c';
    public static final String RDResidentViewResourceQueryToLabel = 'Id, Name,'
        + 'toLabel(SdohDomain__c), RecordType.Name, '
        + 'Organization__r.Name, Organization__r.Website,Organization__c,Organization__r.Status__c,Organization__r.IsClaimed__c,'
        + 'Organization__r.ShippingStreet,Organization__r.ShippingCity,Organization__r.ShippingState,Organization__r.ShippingPostalCode, ManagingAgencyName__c, ManagingAgencyURL__c, ProgramPolicyURL__c';
    // 1029 Modification End
    public static final String sWhereClauseRDResidentViewCtrl = 'Id =: resourceRecId';
    public static final String sWhereClauseResourceRDResidentViewCtrl = 'Id IN : setResourcesIds AND (Organization__r.IsClaimed__c = false OR (Organization__r.IsClaimed__c = true AND Organization__r.Status__c =: sAccountStatus))';
    public static final String sQueryLocFieldsRDResidentViewCtrl = 'Resource__c, Location__r.Name, Location__c, Location__r.AnnouncementStatus__c, Location__r.County__c,'+
        'Location__r.ParkingInstructions__c, Location__r.PointOfContactName__c, Location__r.PointofContactEmail__c,'+
        'Location__r.SpecialLocationInstructions__c, Location__r.Language__c,'+
        'Location__r.MondayOpen__c, Location__r.MondayClose__c,'+
        'Location__r.TuesdayOpen__c, Location__r.TuesdayClose__c,'+
        'Location__r.WednesdayOpen__c, Location__r.WednesdayClose__c,'+
        'Location__r.ThursdayOpen__c, Location__r.ThursdayClose__c,'+
        'Location__r.FridayOpen__c, Location__r.FridayClose__c,'+
        'Location__r.SaturdayOpen__c, Location__r.SaturdayClose__c,'+
        'Location__r.SundayOpen__c, Location__r.SundayClose__c, Location__r.DaysLocationClosed__c,'+
        'Location__r.Geolocation__c,Location__r.Address2__c,Location__r.ZipExtensionCode__c,Location__r.Zip__c,DaysClosed__c,NextSteps__c,TollFree__c,'+
        'MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,'+
        'ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,'+
        'Notes__c,Benefits__c,EligibilityDescription__c,Fees__c,FirstPointofContactEmail__c,FirstPointOfContactName__c,FirstPointofContactPhone__c,'+
        'Geography_Served__c,IncomeEligibility__c,Phone__c,SecondPointofContactEmail__c,SecondPointOfContactName__c,SecondPointofContactPhone__c,WhatToBring__c,ResourceDescription__c,AgesServed__c';
    public static final String sWhereClauseLocRDResidentViewCtrl = 'Location__c =: slocationID OR Resource__c =: resourceRecId ';
    public static final String sQueryReferralFieldsRDResidentViewCtrl = 'id,Status__c,UserComplete__c,Contacts__c';
    public static final String sWhereClauseReferralRDResidentViewCtrl = 'UserComplete__c = false AND Status__c !=: sClosed AND Contacts__c =:contactId ';
    public static final String sQueryLocationFieldsRDResidentViewCtrl = 'id,Account__r.Name,Name,AnnouncementStatus__c,SpecialAnnouncements__c,county__c,Language__c,ParkingInstructions__c,'
                                                                                +'SpecialLocationInstructions__c, TransportationInstructions__c, PointOfContactName__c,PointofContactEmail__c,'
                                                                                +'MondayOpen__c,MondayClose__c, TuesdayOpen__c,TuesdayClose__c,'
                                                                                +'WednesdayOpen__c,WednesdayClose__c, ThursdayOpen__c,ThursdayClose__c,'
                                                                                +'FridayOpen__c,FridayClose__c, SaturdayOpen__c, SaturdayClose__c,'
                                                                                +'SundayOpen__c,SundayClose__c, DaysLocationClosed__c,'
        +'Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,Account__r.Email__c,Account__r.Phone,Phone__c,Email__c,Notes__c,LocationWebsite__c';
    public static final String sWhereClauseLocationFieldsRDResidentViewCtrl = 'Id in :  setLocIds';
    public static final String sWhereClauseAllLocRDResidentViewCtrl = 'Resource__c =: sResourceID  AND Status__c =\'Active\' AND location__r.status__c=\'Active\'';
    public static final String sQueryLocAddressFieldsRDResidentViewCtrl = 'ID,Name,Address1__c,Address2__c,City__c,State__c,Zip__c';
    public static final String sWhereClauseLocAddressRDResidentViewCtrl = 'ID in : setLocIds ';
    
    //public static final String sQueryRefChildFieldsRDResidentViewCtrl = ' FROM ' +sRelationshipName + ' WHERE ' +sWhereClauseReferral;
    //
    public static final String sWhereClauseWhereAccount = 'Account__c =: sAccountId and Status__c =\'Active\'';
    public static final String sQueryLocationFields = 'Location__c,Location__r.Name, Location__r.Address1__c, Location__r.Address2__c, Location__r.City__c, Location__r.State__c, Location__r.Zip__c';
    public static final String sWhereClauseLocation = 'Resource__c =: resourceRecId';// and location__r.status__c=\'Active\' AND Status__c =\'Active\'';
    public static final String sWhereClauseLocationRecId = 'Resource__c =: resId';
    public static final String sWhereLocationIdFilter = 'Location__c =: locationIds';
    public static final String sFieldsApiNameForContact= 'Name,Email,PrimaryLocation__c,Phone,Firstname,Lastname';
    public static final String sWhereClauseForContact= 'id=: conrecordId';
    public static final String sRefDetailsQueryFields=  'CreatedDate,Contacts__r.OptOutInfoSharing__c,Contacts__c,Contacts__r.PreferredCommunicationMethod__c,Contacts__r.AccountId,Id,Resource__c,Resource__r.Name,AdditionalComments__c,OutcomeReason__c,Outcome__c,Name,DaysSinceOpened__c,Contacts__r.Firstname,Contacts__r.Email,Contacts__r.LastName,CreatedBy.Name,DateOfReferral__c,OwnerId,ReferredAccountID__c,ReferredAccountID__r.IsClaimed__c,ReferredAccountID__r.Status__c,ReferredAccountID__r.Name,ReferringUserEmail__c,ReferringUserPhone__c,Status__c,Closed_By__c';
    //RE_Release 1.1 – Bug 361197 - Payal Dubela 
    public static final String sRefDetailsQueryFieldsCitizen=  'CreatedDate,Contacts__r.OptOutInfoSharing__c,Contacts__c,Contacts__r.PreferredCommunicationMethod__c,Contacts__r.AccountId,Id,Resource__c,Resource__r.Name,AdditionalComments__c,OutcomeReason__c,Outcome__c,Name,DaysSinceOpened__c,Contacts__r.Firstname,Contacts__r.Email,Contacts__r.LastName,CreatedBy.Name,DateOfReferral__c,OwnerId,ReferredAccountID__c,ReferredAccountID__r.IsClaimed__c,ReferredAccountID__r.Status__c,ReferredAccountID__r.Name,ReferringUserEmail__c,ReferringUserPhone__c,Status__c';
    public static final String sWhereClauseIdInRecordId= 'Id =: recordId';
    public static final String sQueryIdName= 'Id, Name';
    public static final String sQueryOnUser= 'Id, Name, RE_Selected_Role__c';
    public static final String sQueryConsentIdName= 'Id, Client__c, Client__r.Name,Client__r.Phone,Client__r.Email';
    public static final String sWhereClauseConsentLookup = 'Client__r.Name LIKE: searchKey and Client__r.recordtypeid =:rectypeID and Client__r.OptOutInfoSharing__c = false and Status__c = \'Active\'';
    public static final String sFieldsApiNameForFeedback= 'id,Rating__c,Referral__c,RatingDescription__c';
    public static final String sWhereClauseForFeedback= 'Referral__c=:refObjId and recordtypeid =:rectypeID';
    public static final String sFieldsApiName_LocationCtrl= 'Id,FileId__c';
    public static final String sFieldsIsContactId= 'FileId__c =: sContDocId';
    public static final String sIdVerContent= 'Id,VersionData, ContentDocumentId';
    public static final String sIdinFieldId= 'Id =: fileId';
    public static final String sOrderByNameAsc = 'Name ASC';
    public static final String sQueryIdCreatedByName = 'Id, Createdby.Name, ';
    public static final String sWhereClauseDataTableAPIFields = 'client__r.Id,client__r.FirstName, client__r.lastName, client__r.Email, client__r.Phone, client__r.BirthDate '; 
    public static final String sWhereClauseOrgAndStatus = 'Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Organization\' AND Status__c = \'Active\' AND client__r.OptOutInfoSharing__c=false AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null)';
    public static final String sUserWhereClauseForAllCients = 'Profile.Name = \'RE Citizen Profile\' AND isActive = true';
    public static final String sWhereClauseRecNameHasOptedOutOfAccount = ' RecordType.Name =: sRecordType AND Account.HasOptedOutOfAccount__c = false AND Id IN:setUserId';

    public static final String sWhereClausePriLocationRecordType = 'PrimaryLocation__c =: recordId AND recordTypeId =:nonCitizenRecordTypeId AND Id IN (SELECT ContactId from AccountContactRelation where AccountId=:sAccountId AND (Roles includes (:cpAdminRole) OR Roles includes (:cpStaffRole) OR Roles includes (:agencyAdminRole) OR Roles includes (:agencyStaffRole)))';
    public static final String sPrimaryLocationNameAddition = ', PrimaryLocation__r.Name';   
    public static final String sWhereClauseRecTypeNoteqLocRecType = 'recordTypeId =:nonCitizenRecordTypeId AND Id IN (SELECT ContactId from AccountContactRelation where AccountId=:sAccountId AND (Roles includes (:cpAdminRole) OR Roles includes (:cpStaffRole) OR Roles includes (:agencyAdminRole) OR Roles includes (:agencyStaffRole)))';
    //public static final String sWhereClauseOrganizationToAccount = 'Organization__c =: sAccountId AND (Organization__r.IsClaimed__c = false OR (Organization__r.IsClaimed__c = true AND Organization__r.Status__c =: sAccountStatus))';
    public static final String sWhereClauseOrganizationToAccount = 'Organization__c =: sAccountId';
    //Srikanth - Removed "Status__c Asc," from below as part of datamodel changes
    public static final String sOrderbyStatusAsc = 'Name Asc';
    public static final String sAPINamesLocCont = ', Location__r.Name, Resource__r.Name, Contacts__r.FirstName, Contacts__r.LastName';
    public static final String sWhereClauseLocInRecordId = 'Location__c =: recordId';
    //public static final String sWhereClauseLocInRecordId = 'Location__c =: recordId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus))';
    //public static final String sWhereClauseActiveOrg = '(ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus))';
    
    public static final String sFieldsToQueryOnRecmd = 'LocationResource__c,User__c';
    public static final String sWhereClauseOnRecmd = 'LocationResource__c=:locId AND User__c=:loggedinUserId';
    
    public static final String sQueryFieldsForSMSClass = 'id, SMSReceivers__c, TemplateBody__c';
    public static final String sWhereClauseForSMSClass = 'Id = :communicationRecIds';

    public static final String sQueryFieldsOnResource = 'Id, Organization__c,Organization__r.IsClaimed__c,Organization__r.Status__c';
    public static final String sQueryWhereClauseOnResource = 'Organization__c IN :setAccountIds';
    
    //Added for Location Trigger
    public static final String sQueryFieldsForLocationTrigger = 'LocationType__c,Account__c, Zip__c';
    public static final String sWhereFieldsForLocationTrigger = 'Id not in : lstLocations and Account__c in : lstAccountIds';
    //
    public static final String sFieldsToQueryOnMtdData = 'List_of_Fields__c, ListOfLabels__c';
    public static final String sWhereClauseOnMtdData = 'DeveloperName =: strMtdDeveloperName';
    public static final String sLocationFieldsToQuery = 'Name,Address1__c,Address2__c,City__c,State__c,Zip__c,ZipExtensionCode__c,LocationType__c,Account__c';                                       
    public static final String sWhereClauseOnLoc = 'Account__c=:accountId';
    public static final String sWhereClauseOnLocDetails = 'LocationType__c=\'Headquarters\' AND Account__c=:accountId';
    
    // User Fields
    public static final String sFieldsToQueryOnUser = 'Id, Name, ContactId, isActive,Profile.Name, Contact.PermissionsLevel__c,Contact.MailingPostalCode,Contact.MailingStreet,Contact.MailingCity,Contact.MailingState,Contact.MailingCountry, Contact.ContactGeoLocation__c,ApplicableRoles__c';
    public static final String sWhereClauseOnUser = 'contactId = :sContactId';
    public static final String sWhereClauseGetLoggedUser = 'Id=:loggedinUserId';
    public static final String sWhereClauseGetLoggedContact = 'Id=:userContactId';
    
    // Contact Fields
    public static final String sFieldsToQueryOnContact = 'Id, FirstName, LastName, Email, Phone, PermissionsLevel__c, TrainingLevel__c, Status__c, PrimaryLocation__c ';
    public static final String sWhereClauseOnContact = 'recordtypeId =: contactRecordTypeId AND Id =: sContactId';
    
    public static final String sFieldsToQueryOnContactForConsentClass = 'id ,PreferredCommunicationMethod__c,ConsentToTexts__c,Email,Phone,FirstName, LastName';
    public static final String sFieldsToQueryOnContactForWrapper = 'id ,Name, PreferredCommunicationMethod__c,Email,Phone,ConsentToTexts__c';
    public static final String sWhereClauseOnContactForWrapper = 'id=:conid';
    
    
    
    //Account Fields
    public static final String sFieldsToQueryOnAccount = 'Name,Twitter__c,Facebook__c,Status__c,CommonlyUsedName__c,POC_Phone__c,POCPhoneExt__c,POC_Name__c,POC_Email__c,CountyServed__c,Website,Phone,OrganizationUniqueId__c,TaxID__c,Email__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode';
    public static final String sWhereClauseGetAccountId = 'Id=:contactAccountId';
    public static final String sUserAccountId = 'Id=:userAccountId';
    
    
    //Enum 
    public enum SWITCH_CASE {SWITCH_SUCCESS, SWITCH_FAIURE}
    public static final String SWITCH_SUCCESS = 'success';
    public static final String SWITCH_FAIURE = 'failure';
    
    //Referral Fields
    public static final String sFieldsApiNameForReferralTest = 'Id,Resource__c,Resource__r.Name,Location__c,ReferredAccountID__c,ReferredAccountID__r.Name'; //Anuj- Defect#346650
    public static final String sFieldsApiNameForReferral = 'Outcome__c,Status__c,UserComplete__c';
    public static final String sFieldsApiNameForReferralDuplicate = 'Contacts__c=: scontactid and Resource__c=: sresourceid and Location__c=:sLocationId and ReferredAccountID__c=: saccountid and Status__c!=: sClosed and UserComplete__c!=true';
    public static final String sOrderByForReferralTest='CreatedDate ASC';
    public static final String sWhereClauseForReferral = 'Id =: refId' ;
    //public static final String sWhereClauseForReferralCart = 'Status__c=\'Draft\' AND Contacts__c=:userContactId AND recordtypeId =: referralRecordTypeId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus))' ;
    public static final String sWhereClauseForReferralCart = 'Contacts__c =: userContactId AND recordtypeId =: referralRecordTypeId AND Status__c =\'Draft\'';


    //ClaimSite Fields
    public static final String sWhereClauseOnClaim = 'Type = \'Queue\' AND DeveloperName =: claimSiteQueue';
    
    
    //ResourceFields
    public static final String sResourceRelationshipName = 'Resource__r.Name';
    
    //User fields
    public static final String sWhereClauseOnUserSetId = 'Id =: setUserIds';
    
    // permission set fields
    public static final String sFieldsToQueryOnPermissionSet = 'Id,Label'; 
    public static final String sWhereClauseOnPermissionSet = 'Label IN : lstPermissionSetNames';
    public static final String sWhereClauseCondition = 'PermissionSet.Name=:permissionSetName';
    //LOG_DeleteLogMessagesScheduler query
    public static final String sFieldsToQueryOnLogMsg='id, LOG_Age__c';
    public static final String sWhereClauseOnLogMsg='LOG_Age__c > :dPurgeDays';

    //Client Details Fields
    public static final String sFieldsToQueryOnClientContact= 'Id, Name,MailingAddress,Email,PreferredCommunicationMethod__c,ConsentToTexts__c,Phone,OptOutComm__c,ClientDetails_MockReponse__c,Age__c,Gender__c,BirthDate, OptOutInfoSharing__c'; 
    //RE_Release 1.1 – Security Fixes - Payal Dubela(Added opt out check)
    public static final String sWhereClauseOnClientContact= 'Id =: clientId and OptOutInfoSharing__c = false';
    public static final String sFieldsToQueryOnClientUser= 'Id,IsProfilePhotoActive,MediumPhotoUrl,LanguageLocaleKey';
    public static final String sWhereClauseOnClientUser= 'contactId = :clientId';
    public static final String sFieldsToQueryOnClientReferral= 'Id,Status__c,Contacts__c';
    public static final String sWhereClauseOnClientReferral= 'Contacts__c =: clientId';
    public static final String sFieldsToQueryOnClientNotePermission= 'Id,LastModifiedBy.Name, LastModifiedDate,CreatedById';
    public static final String sWhereClauseOnClientNotePermission= 'Id = : noteId';
    
    //Consent
    public static final String sFieldsToQueryOnClientConsent= 'Id, ClientEmailProvided__c, Name,LastTextDate__c,LastEmailDate__c,Status__c,StartDate__c,EndDate__c,Assister__c,Organization__c,ConsentLevel__c,Client__c';//Abhijeet-User Story-179 -Added extra fields 
    public static final String sWhereClauseOnClientConsent= 'Status__c=:consentStatus AND  (EndDate__c = null OR EndDate__c >= TODAY) AND (StartDate__c = null OR StartDate__c<=TODAY) AND Organization__c=:loggedInUserAccountId AND ConsentLevel__c=:sOrganization AND Client__c=:clientId';
    public static final String sWhereClauseOnClientConsentForAssister= 'Status__c=:consentStatus AND  (EndDate__c = null OR EndDate__c >= TODAY) AND (StartDate__c = null OR StartDate__c<=TODAY) AND Organization__c=:loggedInUserAccountId AND ConsentLevel__c=:sAssister  AND Client__c=:clientId';
    public static final String sFieldsToConsentStatus= 'Id,Name,ConsentLevel__c,Organization__r.Name,Assister__r.Name,Status__c';
    public static final String sFieldConsentWhereClauseOnStatus = 'Status__c=\'Pending\' AND Client__c=:contactId AND (EndDate__c = null OR EndDate__c <= TODAY) ORDER BY Organization__r.Name ASC, Assister__r.Name ASC'; //AND (EndDate__c = null OR EndDate__c <= TODAY)
    public static final String sFieldConsentNonActiveWhereClause ='Client__r.OptOutInfoSharing__c = false AND ConsentLevel__c IN:lstConsentLevel AND Status__c=\'Active\' AND StartDate__c <= TODAY AND Client__c=:contactId ORDER BY Organization__r.Name ASC, Assister__r.Name ASC ';
    public static final String sFieldConsentFieldsStatus = 'Id, Name, ConsentLevel__c,Status__c';
    public static final String sFieldConsentWhereConditionStatus = 'ConsentLevel__c IN:lstConsentLevel AND Status__c IN:lstConsentStatus  AND Client__c=:userContactId';
    public static final String sFieldConsentWhereConditionStatus1 = 'ConsentLevel__c IN:lstConsentLevel AND Status__c IN:lstConsentStatus  AND Client__c=:contactRecordId';
    public static final String sWhereClauseOnExistingConsent = 'Id =: consentId';//Abhijeet USerStory-179
    public static final String sFIeldsToQueryOnConsentHttpUpdate = 'Id,Name,Status__c,StartDate__c,Client__r.Phone';//Abhijeet Two way sms
    public static final String sWhereClauseOnConsentHttpUpdate = 'Name =: cns';//Abhijeet Two way sms
    public static final String sWhereClauseOnConsentForConsentClass= 'Id,Status__c,Assister__c,Client__c,ConsentLevel__c,Organization__c,ConsentProvidedBy__c,StartDate__c,ClientEmailProvided__c';
    public static final String sFieldsToQueryOnConsentObject = 'Id,Client__c,Client__r.FirstName,Client__r.LastName,ClientEmailProvided__c,Organization__c,Organization__r.Name,Assister__c';
    public static final String sWhereClauseOnConsentObject = 'Id =: sConsentId';
       
    
    // removeFromMyPlans Fields
    public static final String sFieldsToQueryOnReferral = 'Id,Contacts__c';
    public static final String sWhereClauseOnReferral = 'Id =: sReferralId';
    
    // permssionset 
    public static final String sFieldsToQueryOnPermissionSetAssignment = 'Id, PermissionSetId, AssigneeId';
    public static final String sWhereClauseOnPermissionSetAssignment = 'AssigneeId In : lstUsers AND PermissionSet.Label IN : lstPermissionSetNames';

    // profile
    public static final String sFieldsToQueryOnProfile = 'Id, Name';
    public static final String sWhereClauseOnProfile = 'Name =: sProfileName';
    
    // user aggregate query
    public static final String sAggregateFieldsToQueryOnUser = 'count(Id) total';
    public static final String sAggregateWhereClauseOnUser = 'Profile.Name =: sProfileName AND Contact.Email =: sEmail';
    
    // Account fields
    public static final String sAccountFields = 'OrganizationUniqueId__c,Name,ShippingCity,BillingCity,ShippingState,BillingState,ShippingStreet,BillingStreet,ShippingPostalCode,BillingPostalCode,Website,Type,IsClaimed__c';
    public static final String sAccountWhereClause = ' AND ShippingCity LIKE: orgcity AND RecordTypeId =: recordTypeId AND ((IsClaimed__c = false AND Status__c !=: sAccountInactiveStatus) OR (IsClaimed__c = true AND Status__c =: sAccountStatus)) AND Is_CP_Organization__c=true order by Name ASC';
    public static final String sAccountWhereClauseFilter1 =' AND RecordTypeId =: recordTypeId AND ((IsClaimed__c = false AND Status__c !=: sAccountInactiveStatus) OR (IsClaimed__c = true AND Status__c =: sAccountStatus)) AND Is_CP_Organization__c=true order by Name ASC';
    public static final String sAccountWhereClauseFilter2 ='ShippingCity LIKE: orgcity AND RecordTypeId =: recordTypeId AND ((IsClaimed__c = false AND Status__c !=: sAccountInactiveStatus) OR (IsClaimed__c = true AND Status__c =: sAccountStatus)) AND Is_CP_Organization__c=true order by Name ASC';
    public static final String sAccountWhereClauseFilter3 ='RecordTypeId =: recordTypeId AND ((IsClaimed__c = false AND Status__c !=: sAccountInactiveStatus) OR (IsClaimed__c = true AND Status__c =: sAccountStatus)) AND Is_CP_Organization__c=true order by Name ASC';
    
    // claim fields
    public static final String sClaimFields ='UniqueIdentificationNo__c,Status__c';
    public static final String sClaimWhereClause = 'UniqueIdentificationNo__c IN:uniqueids AND Status__c!=\'Denied\'';
    
    //claim fields to be used in email template
    public static final String sClaimFieldsForEmailTemplate ='FirstName__c,LastName__c,RequestingOrganizationName__c,Email__c,Status__c,ReasonForDenial__c';
    public static final String sWhereClauseClaimForEmailTemplate ='Id =: consentRecordId';
    // Account Id
    public static final String  sIdNameField = 'Id, Name';
    public static final String sAccountIdWhereClause = 'Id =: accountId';
    
    // Referral Fields
    /*
     *1029 Defect Modifications 
     * Eligibility__c field removed as part of Defect Modifications
     * Pankaj -[12/2/2019] - added closed days for resources on myplan
     */
     //srikanth - removed Resource__r.Status__c,Resource__r.Description__c,Resource__r.EligibilityDescription__c,Resource__r.Fees__c,Resource__r.NextSteps__c, Resource__r.WhatToBring__c field from the below SOQL query
    //Added for performance fix:
    public static final String sFieldsToQueryreferralcount = 'Id,UserComplete__c,Outcome__c,Status__c'; 
    public static final String sFieldsToQueryOnReferralObject = 'Id, Name, Resource__c, CreatedDate, DaysSinceOpened__c, OutcomeReason__c, Location__r.Geolocation__latitude__s, Location__r.Geolocation__longitude__s, Resource__r.Name, ReferredAccountID__r.Website, ReferredAccountID__r.Name, ReferredAccountID__r.ShippingStreet, ReferredAccountID__r.IsClaimed__c,'+
        'ReferredAccountID__c,ReferredAccountID__r.ShippingState, UserComplete__c, Outcome__c,  ReferredAccountID__r.ShippingPostalCode, ReferredAccountID__r.ShippingCity,'+
        'Resource__r.SdohDomain__c, Resource__r.Organization__r.Name,'+
        ' Resource__r.CreatedDate, Status__c,Contacts__c,Contacts__r.AccountId, Location__c, Location__r.Zip__c, Location__r.Address1__c, Location__r.Address2__c, Location__r.City__c, Location__r.County__c, Location__r.State__c, Location__r.SpecialLocationInstructions__c,'+
        'Location__r.PointofContactEmail__c, Location__r.PointofContactPhone__c, Location__r.Name, Location__r.Geolocation__c,contacts__r.firstname,contacts__r.lastname,Location__r.Account__r.Phone,Location__r.Account__r.Email__c,Location__r.Email__c,Location__r.Phone__c,Location__r.ZipExtensionCode__c,Location__r.LocationWebsite__c,Location__r.Account__r.Website, Location__r.DaysLocationClosed__c';
    // Referral Fields with tolabel
	//srikanth - removed Resource__r.Status__c, Resource__r.Description__c,Resource__r.EligibilityDescription__c,Resource__r.Fees__c,Resource__r.NextSteps__c, Resource__r.WhatToBring__c field from the below SOQL query
    public static final String sFieldsToQueryOnReferralObjectToLabel = 'Id, Name, Resource__c, CreatedDate, CreatedBy.Account.Name, CreatedBy.Name, DaysSinceOpened__c, OutcomeReason__c, Location__r.Geolocation__latitude__s, Location__r.Geolocation__longitude__s, Resource__r.Name, ReferredAccountID__r.Website, ReferredAccountID__r.Name, ReferredAccountID__r.ShippingStreet, ReferredAccountID__r.IsClaimed__c,'+
        'ReferredAccountID__c,ReferredAccountID__r.ShippingState, UserComplete__c, Outcome__c,  ReferredAccountID__r.ShippingPostalCode, ReferredAccountID__r.ShippingCity,'+
        'toLabel(Resource__r.SdohDomain__c), Resource__r.Organization__r.Name,'+
        'Resource__r.CreatedDate, Status__c,Contacts__c,Contacts__r.AccountId, Location__c, Location__r.Zip__c, Location__r.Address1__c, Location__r.Address2__c, Location__r.City__c, Location__r.County__c, Location__r.State__c, Location__r.SpecialLocationInstructions__c,'+
        'Location__r.PointofContactEmail__c, Location__r.PointofContactPhone__c, Location__r.Name, Location__r.Geolocation__c,contacts__r.firstname,contacts__r.lastname,Location__r.Account__r.Phone,Location__r.Account__r.Email__c,Location__r.Email__c,Location__r.Phone__c,Location__r.ZipExtensionCode__c,Location__r.LocationWebsite__c,Location__r.Account__r.Website,Location__r.DaysLocationClosed__c';
    // 1029 defect modifications End
    public static final String sWhereClauseOnReferralObject = 'Contacts__c =: contactId AND recordtypeId =: referralRecordTypeId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus))';
    
    public static final String sWhereClauseOnReferralSearchResult = 'Contacts__c =: contactId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c = \'Active - Allow referrals\')) AND Status__C != \'Closed\' AND Outcome__c!= \'Resource Cancelled\' AND Resource__c IN:setResourceIds' ;
    
    public static final String sWhereClauseOnReferralObjectupdatedNew = 'Contacts__c =: contactId AND recordtypeId =: referralRecordTypeId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus)) AND Status__C != \'Closed\' AND Status__C != \'Draft\' AND Outcome__c!= \'Resource Cancelled\'' ;
    public static final String sWhereClauseOnReferralObjectupdatedCompleted = 'Contacts__c =: contactId AND recordtypeId =: referralRecordTypeId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus)) AND (Status__C = \'Closed\' OR UserComplete__c=true) AND Outcome__c!= \'Resource Cancelled\'' ;
    public static final String sWhereClauseOnReferralObjectupdatedDraft = 'Contacts__c =: contactId AND recordtypeId =: referralRecordTypeId AND (ReferredAccountID__r.IsClaimed__c = false OR (ReferredAccountID__r.IsClaimed__c = true AND ReferredAccountID__r.Status__c =: sAccountStatus)) AND Status__C=\'Draft\'' ;
    //Location fields
    public static final String sFieldsToQueryOnLocationObject = 'Id, Name, SundayOpen__c, SundayClose__c, MondayOpen__c, MondayClose__c, TuesdayOpen__c,TuesdayClose__c, WednesdayOpen__c, WednesdayClose__c, ThursdayOpen__c, ThursdayClose__c,FridayOpen__c, FridayClose__c, SaturdayOpen__c, SaturdayClose__c, DaysLocationClosed__c';
    public static final String sWhereClauseOnLocationObject = 'Id IN : lstLocations';
    
    // Account fields
    public static final String sWhereClauseForlstrec = 'Name LIKE: searchKey and recordtypeid =:rectypeID AND (IsClaimed__c = false OR (IsClaimed__c = true AND Status__c =: sAccountStatus)) AND Is_CP_Organization__c= true' ;

    
     // Conatc fields
    public static final String  sContactNameFields = 'id,Name,Phone,Email';
    public static final String sContactNameWhereConditionfilter = 'Name LIKE: searchKey and (recordtypeid =:rectypeID OR (recordtypeid=:nonCitizenRectypeId AND Account.Applicable_Roles__c LIKE :citizenRole))';
    public static final String sContactNameWhereConditionassistor = 'Name LIKE: searchKey and (recordtypeid =:rectypeID OR (recordtypeid=:nonCitizenRectypeId AND Account.Applicable_Roles__c LIKE :citizenRole)) and OptOutInfoSharing__c = false and Id in (SELECT Client__c from Consent__c where Status__c=\'Active\' and Organization__c=: conAccountId )';
    
    public static final String sContactNameWhereCondition = 'Name LIKE: searchKey and (recordtypeid =:rectypeID OR (recordtypeid=:nonCitizenRectypeId AND Account.Applicable_Roles__c LIKE :citizenRole)) and OptOutInfoSharing__c = false and Id in (SELECT Client__c from Consent__c where Status__c=\'Active\' and Organization__c=: conAccountId)';
    public static final String sQueryforUser='Select contactId,contact.accountid from user where id=:sUserId';
    public static final String sContactNameWhereConditionagency = 'Name LIKE: searchKey and (recordtypeid =:rectypeID OR (recordtypeid=:nonCitizenRectypeId AND Account.Applicable_Roles__c LIKE :citizenRole)) and OptOutInfoSharing__c = false';
    
    // ArcheType fields
    public static final String sWhereClauseGetRelatedArcheType = 'ParentArchetype__c =: archTypeId';
    public static final String sFieldsToQueryOnArcheType ='Id,Title__c,ParentArchetype__r.Title__c,ParentArchetype__r.BannerImage__c';
    
    // created by Asc
    public static final String sCreatedDateASC = 'CreatedDate ASC';
    public static final String sRecIdCondition = 'id =:recID ';
    
    public static final String sIdReferralId = 'Id, Referral__c';
   // public static final String sWhereClauseOnFeedback = 'recordtypeId =: feedbackRecordTypeId';
    public static final String sWhereClauseOnFeedback = 'recordtypeId =: feedbackRecordTypeId and Referral__c IN: setReferralIds';
    
    // content documents
    public static final String sContentDocumentFieldsApiName = 'Id, ContentDocumentId, ContentDocument.Title, LinkedEntity.Name, LinkedEntityId';
    public static final String sContentDocumentWhereClause = 'LinkedEntityId IN: setReferralIds';
    
    // content notes
    public static final String sContentNotesFieldsApiName = 'Id, Title, Content, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LatestPublishedVersionId';
    public static final String sContentNotesWhereClause = 'Id IN : setContentDocumentIds';
    
    public static final String  sLocationFilter = 'Account__c=: accountrecId and Status__c=: activestatus' ;
    
    // location
    public static final String sFieldsApiNameForlocationres = 'Id,Resource__c,Resource__r.Name';
    public static final String sWhereClauseForlocationres = 'Location__c=: locationrecId and Status__c=: activestatus' ;
    
    public static final String sReferringContactWhereClause = 'contactid =: referringcontactid';
    
    public static final String sGeoLocationQueryOnContact = 'Id, Name,FirstName,LastName, ContactGeoLocation__c, mailingpostalcode, mailingstreet, mailingstate, mailingcity,mailingcountry, Email';
    //RE_Release 1.1 – Security Fixes - Payal Dubela(Added opt out flag)
    public static final String sGeoLocationWhereClauseOnContact = 'Id = : contactId AND OptOutInfoSharing__c = false';
    public static final String sWhereClauseOnContactId = 'Id = : contactId';
    
    public static final String sContentDocumentLinkFieldsApiName = 'Id, ContentDocumentId, ContentDocument.Title, LinkedEntity.Name, LinkedEntityId';
    public static final String sContentDocumentLinkWhereClause = 'LinkedEntityId =: recordid';
    
    public static final String sContentDocumentLinkFieldsNames = 'Id, Title, Content, CreatedDate, CreatedBy.Name, LastModifiedDate,LastModifiedBy.Name, LatestPublishedVersionId';
    public static final String sContentDocumentLinkWhereCondition = 'Id IN : idset';
    public static final String sPopulatelatAndLongContactQuery = 'Id,ContactGeoLocation__Latitude__s,ContactGeoLocation__Longitude__s,MailingPostalCode';
    public static final String sPopulatelatAndLongContactWhereClause = 'Id =: recordId ';
    public static final String sPopulatelatAndLongLocationQuery = 'Id,Zip__c,Geolocation__Longitude__s,Geolocation__Latitude__s';
    public static final String sPopulatelatAndLongLocationWhereClause = 'Id =: recordId';
    public static final String sPopulateLocationQuery = 'Id,Address1__c,Address2__c,City__c,Zip__c';
    public static final String sPopulateLocationWhereClause = 'Id =: lstIds';
    public static final String sPopulateContactQuery = 'Id, MailingStreet,MailingCity,MailingState,MailingCountry,MailingPostalCode';
    public static final String sPopulateContactWhereClause = 'Id =: lstIds';
    
    //Security
    public static final String sFieldsToQueryOnperm = 'Id, PermissionSetId, PermissionSet.Name, AssigneeId';
    public static final String sWhereClauseOnperm = 'AssigneeId =: userid';
    
    public static final String sWhereClauseOnIdContactId = 'contactId = :sContactId';
    public static final String sWhereClauseOnReferralRecord = 'Id =: sRecordId';

    public static final String sFieldsToQueryOnRecordType = 'DeveloperName,Id,IsActive,Name,SobjectType';
    public static final String sWhereClauseOnRecordTypeRecord = 'DeveloperName=: strRecordTypeDeveloperName and SobjectType=: strSobjectName';

    public static final String sFieldsToQueryOnUserForLoggedIn = 'Id,ContactId';
    public static final String sWhereClauseOnUserForLoggedIn = 'Id=:loggedinUserId';

    public static final String sFieldsToQueryOnContactForLoggedIn = 'Id,AccountId,Account.Name';
    public static final String sWhereClauseOnContactForLoggedIn = 'Id =: contactId';
    
    //Resident Registration
     public static final String sWhereClauseOnArchetype = 'Status__c=\'Active\' AND RecordtypeId =:archetypeRecordtypeId';
     public static final String sWhereClauseOnContactForRegistration = 'Id=:contactId';
     public static final String sWhereClauseOnCitizenUser= 'contactId = :contactId';
     
     //Archetype Landing Page
    public static final String sFieldsToQueryOnArchetypeLP = 'Id, Title__c, Description__c,Status__c, Image__c, DisplayOrder__c';
    public static final String sWhereClauseOnArchetypeLP = 'RecordTypeId = :recordTypeId AND Status__c = \'Active\'';
    public static final String sOrderByClauseOnArchetypeLP = 'DisplayOrder__c NULLS LAST';
            
    public static final String sFieldsToQueryOnArchetypeCarousel = 'Id, Title__c, Description__c, Language__c, Status__c, Image__c, Link__c, DisplayOrder__c';
    public static final String sWhereClauseOnArchetypeCarousel = 'RecordTypeId = :recordTypeId AND Status__c = \'Active\' AND Language__c = :userLanguage';
    
    public static final String sFieldsToQueryOnConfig = 'Id, DomainCategory__c, DomainOrder__c, Domain__c, IsMaster__c, DomainImage__c';
    public static final String sFieldsToQueryOnConfigLabel = 'Id, DomainCategory__c, toLabel(DomainCategory__c) domainCategory, DomainOrder__c, Domain__c, toLabel(Domain__c) domainName, IsMaster__c, DomainImage__c';
    public static final String sWhereClauseForConfig = 'IsMaster__c = true AND RecordTypeId = :domainConfigRecId';
    public static final String sOrderByClauseForConfig = 'DomainCategory__c,DomainOrder__c';
    
    public static final String sFieldsToQueryOnDomainConfig = 'Id, Domain__c, Category__c, Subcategory__c, ShowCategory__c'; 
    public static final String sFieldsToQueryOnDomainConfigLabel = 'Id, Domain__c, toLabel(Domain__c) domainName, Category__c, toLabel(Category__c) categoryName, Subcategory__c, toLabel(Subcategory__c) subcategoryName';    
    public static final String sWhereClauseForDomainConfig = 'RecordTypeId = :domainConfigRecId AND Domain__c IN :setDomains AND Category__c!=null AND Subcategory__c!=null';
    public static final String sWhereClauseForConfigLandingPage = 'RecordTypeId = :domainConfigRecId AND Domain__c IN :setDomains AND ShowCategory__c = true AND Category__c!=null AND Subcategory__c!=null';
    public static final String sFieldsToQueryOnGoal = 'Archetype__r.ParentArchetype__c, id';
    //RE_RelatedResources Query Params
    public static final String sQueryFieldsResourceTaxonomy = 'Taxonomy__c,Resource__c,Taxonomy__r.Name';
    public static final String sWhereClauseResourceTaxonomy = 'Resource__c =: sResourceId';
    public static final String sLimit = '500';
    public static final String sObjectApiName = 'RE_Resource_Taxonomy__c';
    
    public static final String sConfigObjectApiName = 'RE_Config__c';
    public static final String sQueryFieldsRelatedTaxGrp = ' id,ParentConfig__c';
    public static final String sWhereClauseRelatedTaxGrp = 'Taxonomy__c IN : setTaxonomyIds AND Recordtypeid =:idSuggestedResourceRecType';
    
    public static final String sQueryFieldsTaxGrpMembers = 'id,Taxonomy__c';
    public static final String sWhereClauseTaxGrpMembers = 'ParentConfig__c IN : setTaxonomyGroupIds AND Recordtypeid =:idTaxonomyGrpMemberRecType';
    
    public static final String sQueryFieldsFinalResourceTaxs = ' Taxonomy__c,Taxonomy__r.Factoid__c,Resource__r.SdohDomain__c,Resource__r.Organization__c,Resource__c,Resource__r.Name,Resource__r.Organization__r.Name';
    public static final String sWhereClauseFinalResourceTaxs = 'Taxonomy__c IN : setFinalTaxonomyIds';
    
    public static final String sLocResObjectApiName = 'LocationResource__c';
    public static final String sQueryFieldsLocResources = ' id,location__c,Location__r.Geolocation__c,Resource__c,Resource__r.Organization__r.IsClaimed__c';
    public static final String sWhereClauseLocResources = 'Resource__c IN : setResourceIds';
    public static final String sWhereClauseTaxonomyLookup = 'Name LIKE: searchKey'; 
     
    // created by Desc
    public static final String sCreatedDateDESC = 'CreatedDate DESC';//Added by Abhijeet- User Story-179
    
    public static final String sQueryFieldsForGettingPhoneFromContact = 'Phone';
    public static final String sWhereFieldsForGettingPhoneFromContact = 'OWNERID =:OwnerId';
    
    //For ShareEmailCtrl
    
    public static final String sWhereFieldsForGettingPhoneFromUser = 'Id =: ownerId';
    public static final String sQueryFieldsForGettingContactId = 'ContactId';
    
    public static final String sLocationResourceWhereClasue = 'Location__c IN :setResLocationIds';
    
    //Archetype Detail
    public static final String sArcheFieldsToQueryOnGoalArcheConfigObj = 'Archetype__c,Goal__c,Archetype__r.ParentArchetype__c,Archetype__r.ParentArchetype__r.Title__c';
    public static final String sFieldsToQueryOnConfigObj = 'Id, Taxonomy__c, Goal__r.Title__c, Goal__r.Description__c, Category__c,Subcategory__c,Goal__r.Domain__c,Goal__r.Domain_Category__c';
    public static final String sArcheWhereClauseOnGoalArcheConfigObjWithGoal = 'Archetype__r.ParentArchetype__c =:strArchetypeIdParam AND Archetype__c =: strSubArchetypeIdParam AND RecordTypeId =: goalArchetypeConfigRecId AND Goal__c IN:lstGoalParam';
    public static final String sArcheWhereClauseOnGoalArcheConfigObjWOGoal = 'Archetype__r.ParentArchetype__c =:strArchetypeIdParam AND Archetype__c =: strSubArchetypeIdParam AND RecordTypeId =: goalArchetypeConfigRecId';
    // ToLabel
    public static final String sFieldsToQueryOnConfigObjToLabel = 'Id, Taxonomy__c, Goal__r.Title__c, Goal__r.Description__c, Category__c,Subcategory__c, Goal__r.Domain__c, Goal__r.Domain_Category__c, toLabel(Goal__r.Domain__c) goalDomainLabel, toLabel(Goal__r.Domain_Category__c) goalCategoryLabel';
    public static final String sWhereClauseOnConfigObj = 'Goal__c IN: setGoalId AND Goal__r.Domain__c IN: lstDomainsSplit AND RecordTypeId =: goalConfigRecId AND Goal__c !=null AND Taxonomy__c != null';
    public static final String sFieldsToQueryOnDomainConfigObj = 'Id, DomainCategory__c, DomainOrder__c, Domain__c, IsMaster__c, DomainImage__c';
    public static final String sWhereClauseOnDomainConfigObj = 'IsMaster__c = true AND RecordTypeId = :domainConfigRecId AND Domain__c IN:setKeySetDomain';
    public static final String sOrderByClauseDomainConfigObj = 'DomainCategory__c,DomainOrder__c';
    public static final String sFieldsToQueryOnResTaxonomy = 'Id, Resource__c,Taxonomy__c,Resource__r.Organization__r.Name,Resource__r.Organization__r.Website,Resource__r.Name,Resource__r.SdohDomain__c, Resource__r.Organization__r.ShippingStreet,Resource__r.Organization__r.ShippingCity,Resource__r.Organization__r.ShippingState,Resource__r.Organization__r.ShippingPostalCode, Resource__r.Organization__r.Status__c,Resource__r.Organization__r.IsClaimed__c';
    //Srikanth - removed "AND Resource__r.Status__c=\'Active\'" from the below line
	public static final String sWhereClauseOnResTaxonomy = 'Resource__c != null AND Taxonomy__c != null AND Taxonomy__c IN: setTaxonomyId AND (Resource__r.Organization__r.IsClaimed__c = false OR (Resource__r.Organization__r.IsClaimed__c = true AND Resource__r.Organization__r.Status__c =: sAccountStatus))';
    public static final String sFieldsToQueryOnReferralObj = 'Id,Resource__c,Status__c';
    public static final String sWhereClauseOnReferralWhenGuest = 'UserComplete__c = false AND Status__c != \'Closed\' AND Resource__c IN:setResourceId';
    public static final String sWhereClauseOnReferralWhenNotGuest = 'UserComplete__c = false AND Status__c != \'Closed\' AND Contacts__c =:contactId AND Resource__c IN:setResourceId';
    public static final String sFieldsToQueryOnLocRes = 'Id,Resource__c,Phone__c,TollFree__c,ResourceDescription__c,Notes__c,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,Location__r.City__c,Location__r.State__c,Location__r.Geolocation__c,Location__r.PointofContactPhone__c,Location__r.PointofContactEmail__c,Location__r.DaysLocationClosed__c,Location__r.Zip__c,Location__r.Account__r.Phone,Location__r.Account__r.Email__c,Location__r.ZipExtensionCode__c,Location__r.LocationWebsite__c,'+
    'MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,ThursdayOpen__c,ThursdayClose__c,FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,DaysClosed__c';
    public static final String sArchetypeWhereClauseOnLocRes = 'Resource__c != null AND Location__c != null AND Location__r.Geolocation__Latitude__s != null AND Location__r.Geolocation__Longitude__s != null AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < 3000 AND Resource__c IN: setResourceId AND Location__r.Status__c=\'Active\' AND Status__c=\'Active\'';
    public static final String sWhereClauseOnLocRes = 'DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles AND Resource__c IN: setResourceId';
    public static final String sWhereClauseOnLocResWithoutDistance = 'Resource__c IN: setResourceId';
    public static final String sOrderByClauseOnLocRes = 'DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') ASC';
    public static final String sArchetypeOrderByClauseOnLocRes = 'DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') ASC';
    
    // Start - Assessment Results Fields
    public static final String sArchetypeWhereClauseOnConfigObj = 'Goal__c IN: setGoalId AND Goal__r.Domain__c IN: lstDomainsSplit AND RecordTypeId =: goalConfigRecId AND Taxonomy__c != null';
    public static final String sAssessFieldsToQueryOnConfig = 'Id,Taxonomy__c,Goal__c';
    public static final String sAssessWhereClauseOnConfigObj = 'Goal__c IN: setGoalId AND RecordTypeId =: goalConfigRecId AND Taxonomy__c != null';
    public static final String sFieldsToQueryOnSDOHObj = 'Id, SDOH__c, Score__c, Description__c';
    public static final String sWhereClauseOnSDOHObj = 'Assessment_Template__c =:sAssessTemplateName AND SDOH__c IN:setSDOHDmain AND SDOH__c != null AND Score__c != null AND Description__c != null';
    public static final String sAssessFieldsToQueryOnSDOHObj = 'Id, Name, Category__c, Resident__c, Score__c, IsLatest__c, AssessmentDate__c, Assessment__c';
    //Removed for the balnk tile
   // public static final String sAssessWhereClauseOnSDOHObj = 'Assessment__c=:sUserAssessId AND Category__c !=null AND Category__c IN:setSDOHDmain';
 public static final String sAssessWhereClauseOnSDOHObj = 'Assessment__c=:sUserAssessId AND Category__c !=null';
    public static final String sAssessFieldsToQueryOnGoalAnswerObj = 'Id, Name, AnswerChoice__c, Goal__c, AnswerChoice__r.Question__r.SDOH__c,AnswerChoice__r.Question__r.Assessment__r.AssessmentTitle__c,Goal__r.Title__c,Goal__r.Description__c';
    public static final String sAssessWhereClauseOnGoalAnswerObj = 'AnswerChoice__c IN:setAnswerChoiceId AND Goal__c != null AND AnswerChoice__r.Question__r.SDOH__c != null';
    public static final String sWhereClauseOnAssessResponseObj = 'Assessment__c =:sUserAssessId AND Assessment__r.RecordTypeId =:sRecTypeAssessUser and resident__r.OptOutInfoSharing__c=false AND recordtypeid =: sAssessmentRespRecTypeId';//Nandita: Added check for recordtype
    public static final String sFieldsToQueryOnAssessResponseObj = 'AssessmentGeolocation__c,Id, Name,Resident__c, AnswerChoice__c, Assessment__c, Question__c, TextAnswer__c, Assessment__r.AssessmentTemplate__r.AssessmentTitle__c,Assessment__r.Resident__r.Name,'+
            'Assessment__r.Partner__r.Name,Assessment__r.CreatedDate,Assessment__r.Resident__r.ContactGeoLocation__c,Assessment__r.Resident__r.MailingPostalCode,Assessment__r.Resident__r.ZipCode__c,'+
            'Question__r.Question__c,AnswerChoice__r.Answer__c';
    // End - Assessment Results Fields
    
    public static final String sQueryFieldsPermissionSet = 'Id, AssigneeId, PermissionSet.Name';
    public static final String sWhereClausePermissionSet = 'AssigneeId =:sUserId  AND (PermissionSet.Name = \'RE_Community_Partner_Staff\' OR PermissionSet.Name = \'RE_Agency_Staff\')'; //RE_Release 1.1 - Agency User Capture - Siri
    //344534
    public static final String allfilter='Id != null AND (DateOfReferral__c=LAst_N_Months:6 or DateOfReferral__c =THIS_Month)';
    public static final String sFieldsToQueryOnConfigData = 'Id, Domain__c, Subcategory__c, Taxonomy__c, DomainImage__c';
    public static final String sWhereClauseForOnConfigData = 'Domain__c = :sDomain AND Subcategory__c = :sSubcategory AND RecordTypeId = :searchConfigRecId';
    // changed by Pankaj [12/23/2019] as part of perf issue
    public static final String sFieldsOnResTaxonomy = 'Id,Resource__c,Taxonomy__c,Resource__r.id,Resource__r.Organization__r.IsClaimed__c,Resource__r.Organization__r.Status__c';
    // changed by Pankaj [12/23/2019] as part of perf issue
    public static final String sWhereClauseForResTaxonomy = 'Taxonomy__c IN :setTaxonomyIds AND (Resource__r.Organization__r.IsClaimed__c = false OR (Resource__r.Organization__r.IsClaimed__c = true AND Resource__r.Organization__r.Status__c =: sAccountStatus))';
    
    /*
     *1029 Defect Modifications 
     * Eligibility__c field removed as part of Defect Modifications
     */
    public static final String sFieldsToQueryOnLocResource = 'Id,Location__c,Location__r.Address1__c,Location__r.Address2__c, Location__r.City__c,Location__r.SpecialLocationInstructions__c,'+
        'Location__r.State__c, Location__r.County__c, Location__r.Zip__c,Location__r.ZipExtensionCode__c, Location__r.PointofContactEmail__c, Location__r.PointofContactPhone__c,'+
        'Location__r.Name,Resource__r.Organization__c,Location__r.Geolocation__c,Location__r.LocationWebsite__c,'+
        'Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s, Location__r.DaysLocationClosed__c,'+
        'Resource__r.Organization__r.Website,Resource__r.Organization__r.Name,Resource__r.Organization__r.ShippingStreet,Resource__r.Organization__r.ShippingCity,'+
        'Resource__r.Organization__r.ShippingState,Resource__r.Organization__r.ShippingPostalCode,'+
        'Resource__r.Organization__r.Status__c,Resource__r.Organization__r.IsClaimed__c,'+
        'Resource__c,Resource__r.Name,Resource__r.SdohDomain__c,'+
        'Location__r.Account__r.Phone,Location__r.Account__r.Email__c,Location__r.Phone__c,Location__r.Email__c,TollFree__c,Phone__c,Fees__c,WhattoBring__c,'+
        'MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,ThursdayOpen__c,ThursdayClose__c,'+
        'FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,DaysClosed__c,Notes__c,ResourceDescription__c';
    
    public static final String sFieldsToQueryOnLocResourceToLabel = 'Id,Location__c,Location__r.Address1__c,Location__r.Address2__c, Location__r.City__c,Location__r.SpecialLocationInstructions__c,'+
        'Location__r.State__c, Location__r.County__c, Location__r.Zip__c,Location__r.ZipExtensionCode__c, Location__r.PointofContactEmail__c, Location__r.PointofContactPhone__c,'+
        'Location__r.Name,Resource__r.Organization__c,Location__r.Geolocation__c,Location__r.LocationWebsite__c,'+
        'Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s, Location__r.DaysLocationClosed__c,'+
        'Resource__r.Organization__r.Website,Resource__r.Organization__r.Name,Resource__r.Organization__r.ShippingStreet,Resource__r.Organization__r.ShippingCity,'+
        'Resource__r.Organization__r.ShippingState,Resource__r.Organization__r.ShippingPostalCode,'+
        'Resource__r.Organization__r.Status__c,Resource__r.Organization__r.IsClaimed__c,'+
        'Resource__c,Resource__r.Name,toLabel(Resource__r.SdohDomain__c) resourceDomain, Resource__r.SdohDomain__c,'+
        'Location__r.Account__r.Phone,Location__r.Account__r.Email__c,Location__r.Phone__c,Location__r.Email__c,TollFree__c,Phone__c,Fees__c,WhattoBring__c,'+
        'MondayOpen__c,MondayClose__c,TuesdayOpen__c,TuesdayClose__c,WednesdayOpen__c,WednesdayClose__c,ThursdayOpen__c,ThursdayClose__c,'+
        'FridayOpen__c,FridayClose__c,SaturdayOpen__c,SaturdayClose__c,SundayOpen__c,SundayClose__c,DaysClosed__c,Notes__c,ResourceDescription__c';
    //1029 Modifications end
    
    //Favorites Fields in Archetype Detail Screen
    public static final String sWhereClauseGetFavorites = 'LocationResource__c IN:setLocResId AND Contact__c =:sContactId AND recordTypeId =: sFavRecordTypeId';
    public static final String sFieldsGetFavorites='Id,Contact__c,LocationResource__c,LocationResource__r.Resource__c,LocationResource__r.Location__c';
       // commented to check perf issue without filter [Pankaj-12/20/2019]
    // public static final String sWhereClauseForLocResourceNoDomain = 'Resource__c IN :setLocationResourceIds AND Resource__r.Status__c=\'Active\' AND (Resource__r.Organization__r.IsClaimed__c = false OR (Resource__r.Organization__r.IsClaimed__c = true AND Resource__r.Organization__r.Status__c =: sAccountStatus)) AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles';
    // public static final String sWhereClauseForLocResourceNoDomain = 'Resource__c IN :setLocationResourceIds AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles AND status__c=\'Active\' AND location__r.status__c=\'Active\'';
    public static final String sWhereClauseForLocResourceNoDomain = '(Resource__c IN :setLocationResourceIds OR Id IN:setGlobalLocaResourceIds) AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles AND status__c=\'Active\' AND location__r.status__c=\'Active\'';
    // commented to check perf issue without filter [Pankaj-12/20/2019]
    ///public static final String sWhereClauseForLocResourceWithDomain = 'Resource__c IN :setLocationResourceIds AND Resource__r.Status__c=\'Active\' AND (Resource__r.Organization__r.IsClaimed__c = false OR (Resource__r.Organization__r.IsClaimed__c = true AND Resource__r.Organization__r.Status__c =: sAccountStatus)) AND Resource__r.SdohDomain__c =: sDomain AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles';
    public static final String sWhereClauseForLocResourceWithDomain = 'Resource__c IN :setLocationResourceIds AND Resource__r.SdohDomain__c =: sDomain AND DISTANCE(Location__r.Geolocation__c, GEOLOCATION(:dblLat, :dblLon), \'mi\') < :iRadiusMiles AND status__c=\'Active\' AND location__r.status__c=\'Active\'';
    // Include null resources - added by Pankaj-12/02/2019
	//Srikanth - removed "AND Resource__r.Status__c=\'Active\'" from below query as part of Datamodel changes
    public static final String sWhereClasueForNullResources= ' Location__r.Geolocation__latitude__s=null AND Resource__c IN :setLocationResourceIds AND (Resource__r.Organization__r.IsClaimed__c = false OR (Resource__r.Organization__r.IsClaimed__c = true AND Resource__r.Organization__r.Status__c =: sAccountStatus)) AND status__c=\'Active\' AND location__r.status__c=\'Active\'';
    //Srikanth - removed "Status__c" from below as part of Datamodel Changes
    public static final String sResourceFields = 'Id,Resource__c,Location__c';
    public static final String sWhereClauseForReferrals = 'UserComplete__c = false AND Status__c != \'Closed\' AND Resource__c IN:setResourceIds';
    public static final String sWhereClauseForContactReferrals ='UserComplete__c = false AND Status__c != \'Closed\' AND Contacts__c =:contactId AND Resource__c IN:setResourceIds';
    public static final String sFieldsOnDomain = 'Domain__c';
    public static final String sFieldsToQueryOnReferralsForConnect = 'Id, Name, ReferredAccountID__r.Name, ReferredAccountID__r.IsClaimed__c,ReferredAccountID__r.Status__c';
    
     public static final String WHERE_CLAUSE_SERVICE_UTILITY = 'DeveloperName =: sServiceName';
    public static final String FIELDS_SERVICE_UTILITY ='Id, DeveloperName, Value__c';
    public static final String sFieldsToQueryOnAccountForOptOut = 'Id,Name,HasOptedOutOfAccount__c';
    
    // Create Favorites Query Constants
    public static final String WHERE_CLAUSE_GET_FAVORITES = 'Contact__c =:sContactId AND LocationResource__r.status__c=\'Active\' AND LocationResource__r.location__r.status__c=\'Active\' AND recordTypeId =: sFavRecordTypeId';
    //Payal - Removed LocationResource__r.Resource__r.Description__c from soql query
    public static final String FIELDS_GET_FAVORITES ='Id, Contact__c,Contact__r.ZipCode__c,LocationResource__c,LocationResource__r.Resource__c,'+
                                                    'LocationResource__r.Resource__r.Name,ToLabel(LocationResource__r.Resource__r.SdohDomain__c),'+
                                                    'LocationResource__r.Location__r.Name,LocationResource__r.Location__c,LocationResource__r.Location__r.Geolocation__latitude__s,LocationResource__r.Location__r.Geolocation__longitude__s,LocationResource__r.Location__r.Address1__c,'+
                                                    'LocationResource__r.Resource__r.Organization__r.Name,LocationResource__r.Resource__r.Organization__r.IsClaimed__c,LocationResource__r.Resource__r.Organization__r.Status__c,'+
                                                    'LocationResource__r.Resource__r.Organization__r.Email__c,LocationResource__r.Resource__r.Organization__r.Phone,'+
                                                    'LocationResource__r.Resource__r.Organization__r.Website,LocationResource__r.Resource__r.Organization__c,'+
                                                    'LocationResource__r.Location__r.Email__c,LocationResource__r.Location__r.Phone__c,LocationResource__r.Location__r.Address2__c,'+
                                                    'LocationResource__r.Location__r.City__c,LocationResource__r.Location__r.State__c,LocationResource__r.Location__r.Zip__c,LocationResource__r.Location__r.LocationWebsite__c,LocationResource__r.Location__r.DaysLocationClosed__c,'+
                                                    'LocationResource__r.ResourceDescription__c,LocationResource__r.Phone__c,LocationResource__r.Notes__c,LocationResource__r.TollFree__c';

    public static final String WHERE_CLAUSE_DELETE_FAVORITES = 'Contact__c =:sContactId AND LocationResource__c =:sLocationResId AND recordTypeId =: sFavRecordTypeId '; //Nandita: Added recordtype check
    public static final String FIELDS_DELETE_FAVORITES ='Id';
    public static final String WHERE_CLAUSE_DELETE_FAVORITESMYFVRTS = 'Contact__c =:sContactId AND LocationResource__c IN:sLocationResId AND recordTypeId =: sFavRecordTypeId '; //Nandita: Added recordtype check
    public static final String WHERE_CLAUSE_CREATE_FAVORITES = 'Contact__c =:sContactId AND LocationResource__c =:sLocationResId AND recordTypeId =: sFavRecordTypeId'; //Nandita: Added recordtype check
    public static final String FIELDS_CREATE_FAVORITES ='Id, LocationResource__c';
    public static final String sFieldsToQueryOnFavorite = 'Id,Contact__c, LocationResource__c,LocationResource__r.Location__c,LocationResource__r.Resource__c';
    public static final String sWhereClauseOnOnFavorite = '(LocationResource__r.Location__c IN:setLocationIds OR LocationResource__r.Resource__c IN: setResourceIds) AND recordTypeId=:sFavRecordTypeId AND Contact__c=:loggedinUser';// AND LocationResource__r.status__c=\'Active\' AND LocationResource__r.location__r.status__c=\'Active\'';
    
    public static final String sFieldsTobeQueryOnLocationResource = 'Id, Notes__c, ResourceDescription__c, Phone__c, TollFree__c, Resource__c, WhatToBring__c, EligibilityDescription__c, NextSteps__c, Fees__c, Location__c, SundayOpen__c, SundayClose__c,ThursdayClose__c, ThursdayOpen__c, TuesdayClose__c, TuesdayOpen__c, WednesdayClose__c, WednesdayOpen__c, SaturdayClose__c, SaturdayOpen__c, MondayClose__c, MondayOpen__c, FridayClose__c, FridayOpen__c, DaysClosed__c,Resource__r.Organization__r.IsClaimed__c,Resource__r.Organization__r.Status__c,Location__r.Notes__c';//Anuj - Basic Search/PrintMyPlan - LocationHoursIssue/
    public static final String sWhereClauseOnLocationResource = '(Resource__c IN : setResourceIds OR Location__c IN : setLocationIds) AND status__c=\'Active\' AND Location__r.Status__c=\'Active\'';
     //Nandita: 03/24/2020: added parameters for Favorite Client Query :357475
    public static final String sFieldsToQueryOnFavoriteClient = 'Id,Contact__c,Client__c';
    public static final String sWhereClauseOnFavoriteClient = 'recordTypeId=:sFavRecordTypeId AND Contact__c=:sContactId';
    public static final String sWhereClauseonMyClients = 'Id IN: sFavClientIdSet';
    public static final String WHERE_CLAUSE_CREATE_FAVORITE_CLIENTS = 'Contact__c =:sContactId AND client__c =:sClientId AND recordTypeId =: sFavRecordTypeId'; //Nandita: Added recordtype check
     public static final String WHERE_CLAUSE_DELETE_FAVORITE_CLIENTS = 'Client__c =: sClientId AND recordTypeId =: sFavRecordTypeId';
    //ContentVersion
    public static final String sFieldsToQueryOnContentVersion = 'Id,ContentdocumentId';
    public static final String sWhereClauseOnContentVersion = 'ContentdocumentId IN : lstConDocIds';
    public static final String sFieldsToQueryOnCN = 'Id,LatestPublishedVersionId';
    public static final String sWhereClauseOnCN = 'Id =:contentNoteId';
    public static final String sFieldsToQueryOnCV = 'Id,isPublic__c';
    public static final String sWhereClauseOnCV = 'Id =:contentVersionId';
    public static final String sWhereClauseOnCVForNotes = 'Id In :setVersionIds';
    public static final String sWhereClauseOnCVForNotesMyPlan = 'Id In :setContentIds';
    
    //ContentDDistribution
    public static final String sFieldsToQueryOnContentDistribution = 'Id,ContentversionId,DistributionPublicUrl';
    public static final String sWhereClauseOnContentDistribution = 'ContentversionId IN: setContIds';
    
    //Bulk Referrals
    public static final String sWherClauseForBulkReferralDuplicates = 'Contacts__c=: sContactId AND Resource__c IN : setResourceIds AND  Status__c!=: sClosed and UserComplete__c!=true';
    
    //CommunicationLog
    public static final String sFieldsToQueryOnCommunicationLog = 'Id, TriggeredRecordId__c,SMSReceivers__c,'
                                                                +'TemplateBody__c, EmailSubject__c, TemplateId__c';
    public static final String sWhereClauseOnCommunicationLog = 'Id = :communicationRecIds';
    public static final String sFieldsToQueryOnClientSDOH = 'Id, CreatedDate, Category__c, IsLatest__c, AssessmentDate__c, LastModifiedDate, Resident__c, Score__c';
    public static final String sFieldsToQueryOnClientSDOHToLabel = 'Id, CreatedDate, toLabel(Category__c), IsLatest__c, AssessmentDate__c, LastModifiedDate, Resident__c, Score__c';
    public static final String sWhereClauseOnSDOHOneView = 'Resident__c = :clientId AND IsLatest__c=true';
    
    //User Fields
    public static final String  sIdNameFieldUsers = 'Id, Name,Contact.Account.Name,Contact.Phone,Contact.Email'; 
    public static final String sFieldsToQueryOnFeedbackForRating = 'Id,Rating__c,AccountID__c,Referral__r.Location__c,Referral__r.Resource__c';
    public static final String sWhereClauseOnFeedbackForRating = 'RecordTypeId=:feedbackRecordTypeId AND (AccountID__c=:accountId OR Referral__r.Location__c =: locationId OR Referral__r.Resource__c =: resourceId)';
    
    //SurveyQuestionResponse Fields
    public static final String sFieldsToQueryOnSurveyQuestionResponse = 'id,question.Name,ChoiceValue,ResponseValue,InvitationId,Invitation.Referral__c,Invitation.Referral__r.ReferredAccountID__c,Invitation.Survey.Name';
    public static final String sWhereClauseOnSurveyQuestionResponse = 'ResponseId=: ResponseId';
    
    //SurveySetting Fields
    public static final String sFieldsToQueryOnSurveySetting = 'DeveloperName,Question_1__c,Question_2__c';
    public static final String sWhereClauseOnSurveySetting = 'DeveloperName=:surveyName';

    //Survey Fields
    public static final String sFieldsToQueryOnSurvey = 'id';
    public static final String sWhereClauseOnSurvey = 'Name=: SurveyName';
    
    //Network Fields
    public static final String sFieldsToQueryOnCommunity = 'id';
    public static final String sWhereClauseOnCommunity = 'Name=: CommunityName';

    //Contact Fields
    public static final String sFieldsToQueryOnContactRecord = 'Id, FirstName, LastName';
    public static final String sWhereClauseOnContactRecord= 'Id in: contactIds';
    public static final String sFieldsToQueryOnContactForAssessment = 'Id,MailingStreet,MailingCity,MailingState,MailingPostalCode,MailingCountry,MailingAddress';
    public static final String sWhereClauseOnContactForAssessment = 'Id =: conid';
    
    // Get Reports/Folder Query
    public static final String sFieldsToQueryOnFolder = 'Id';
    public static final String sWhereClauseOnFolder = 'developername=:reportFolderName';
    public static final String sFieldsToQueryOnReport = 'Id, name, description';
    public static final String sWhereClauseOnReport = 'ownerid = : myFolderId  order by createddate desc';
    // Assessment object fields 
    public static final String sFieldsToQueryOnAssessment = 'Id,AssessmentTitle__c,Description__c';
    public static final String sWhereClauseOnAssessment = 'recordtypeid =:assessmentRecordTypeId ';
    public static final String sFieldsToQueryonGuestAssessment = 'AssessmentTemplate__c, Id, AssessmentTitle__c';
    public static final String sWhereClauseOnGuestAssessment = 'recordtypeid =:assessmentRecordTypeId and AssessmentTitle__c =:assessmentTitle and AssessmentTemplate__c = null';
    public static final String sFieldsToQueryOnUserAssessment = 'Id,Assessment__c,Assessment__r.AssessmentTemplate__r.AssessmentTitle__c,Assessment__r.Partner__r.name,createddate';
    public static final String sWhereClauseOnUserAssessment = 'Assessment__r.Resident__c=:residentId and Assessment__r.recordtypeid =:userAssessmentRecordTypeId order by createddate desc';
    public static final String sFieldsToQueryOnUserRecordType = 'Id,AssessmentTemplate__c,AssessmentTemplate__r.AssessmentTitle__c,Partner__r.name,createddate';
    public static final String sWhereClauseOnUserRecordType = 'resident__c=:residentId and recordtypeid =:userAssessmentRecordTypeId order by createddate desc';
    // for SDOH Scoring 
    public static final String sFieldsToQueryOnAssessmentRes = 'Id,AnswerChoice__c,AnswerChoice__r.Answer__c,Question__c,Question__r.Question__c,AnswerChoice__r.Score__c,Question__r.SDOH__c';
    public static final String sWhereClauseOnAssessmentRes = 'Assessment__c=:userAssessmentTempId and Assessment__r.Resident__c=:clientId';
    // SDOH object fields
    public static final String sFieldsToQueryOnSDOH = 'Id,Category__c,IsLatest__c';
    public static final String sWhereClauseOnSDOH = 'Category__c IN:setSDOHCats and Resident__c=:clientId';
    
    //Suresh: Bug #357427
    public static final String sRferralQuery='Select Id,Contacts__r.Name,Contacts__r.FirstName,Contacts__r.LastName,Contacts__r.Email,CreatedById,ReferredAccountID__r.Name,Resource__r.Name, Contacts__r.PreferredCommunicationMethod__c,ReferredByAccountID__r.Name,Location__r.Address1__c,Location__r.Address2__c,Location__r.City__c, Location__r.State__c,Location__r.Zip__c,Location__r.PointofContactPhone__c,Location__r.MondayOpen__c, Location__r.MondayClose__c,Location__r.TuesdayOpen__c, Location__r.TuesdayClose__c,Location__r.WednesdayOpen__c, Location__r.WednesdayClose__c,Location__r.ThursdayOpen__c, Location__r.ThursdayClose__c,Location__r.FridayOpen__c, Location__r.FridayClose__c,Location__r.SaturdayOpen__c, Location__r.SaturdayClose__c,Location__r.SundayOpen__c, Location__r.SundayClose__c,Location__r.DaysLocationClosed__c FROM Referral__c WHERE Id IN: setResourceId';  
    
    //Query for questions and answers
    public static final String sFieldsToQueryOnQuestions = 'Id, name,Assessment__c,Question__c,Assessment__r.name,SDOH__c,AnswerType__c,IsRequired__c';
    public static final String sWhereClauseOnQuestions = 'Assessment__c=: sAssessmentId AND recordtypeid =: sQuesRecordTypeId';//Nandita: added check for record type
    public static final String sFieldsToQueryOnAnswer = 'Id, Name,Answer__c,Score__c,Question__c';
    public static final String sQueryString='SELECT Id, name,Assessment__c,QuestionOrder__c,Question__c,Assessment__r.name,SDOH__c,AnswerType__c,IsRequired__c, (SELECT Id, Name,Answer__c,Score__c,Question__c FROM Answer_Choices__r order by answerorder__c asc) FROM Question__c where Assessment__c=: sAssessmentId AND recordtypeid =: sQuesRecordTypeId order by QuestionOrder__c asc';//Nandita: Added check for Question Record Type
    
    //Added by Payal(ONEVIEW-1361)
    public static final String sWhereClauseRecNameHasOptedOutOfAccountNew = ' RecordType.Name =: sRecordType AND Account.HasOptedOutOfAccount__c = false'; 


     public static final String sFieldsForResourceSearch = 'Id, Name';
     public static final String WHERE_CLAUSE_CONTACT_MAPPING = 'Contact__c IN: conList';
     public static final String sFieldsToQueryOnContactMapping = 'Id,Contact__c,Group_Id__c,IEES_Id__c,Contact__r.OptOutInfoSharing__c';
     public static final String sOrderByOnContactMapping = 'IEES_Id__c desc';
     public static final String sFieldsToQueryOnMyAccountAssister = 'Id,FirstName,LastName,CompletedFirstTime__c,Email,Phone';
     
    //RE_ReferralDetailsCtrl user record
    public static final String WHERE_CLAUSE_getUserRecordDetails = 'IsActive = true AND ContactId IN (SELECT ContactId from AccountContactRelation where AccountId=:referredAccountID AND (Roles includes (:communityAdminRolename) OR Roles includes (:communityStaffRolename) OR Roles includes (:agencyAdminRoleName) OR Roles includes (:agencyStaffRoleName))) AND (ApplicableRoles__c includes (:communityAdminRolename) OR ApplicableRoles__c includes (:agencyAdminRoleName) OR ApplicableRoles__c includes (:communityStaffRolename) OR ApplicableRoles__c includes (:agencyStaffRoleName))';
    //RE_RDResidentViewCtrl user record
    public static final String WHERE_CLAUSE_guestReferral = 'UserComplete__c = false AND Status__c !=: sClosed';
    
    //RE_DataTable 
    public static final String WHERE_CLAUSE_9_ContactWrapperDataTable=' Client__c IN: setContactIds AND ConsentLevel__c=\'Assister\' AND Organization__c =: sAccountId AND Status__c = \'Active\' AND client__r.OptOutInfoSharing__c=false AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null)';
    public static final String WHERE_CLAUSE_10_ContactWrapperDataTable=' (RecordType.Name =: sRecordType OR (RecordType.Name=:sNonCitizenRecordType AND Account.Applicable_Roles__c LIKE :citizenRole)) AND Account.HasOptedOutOfAccount__c = false';    
    public static final String WHERE_CLAUSE_ContactWrapperDataTable= ' RecordType.Name =: sRecordType AND Account.HasOptedOutOfAccount__c = false AND LastName LIKE \'%';
    public static final String WHERE_CLAUSE_2_ContactWrapperDataTable=' RecordType.Name =: sRecordType AND Account.HasOptedOutOfAccount__c = false AND FirstName LIKE \'%';      
    public static final String WHERE_CLAUSE_3_ContactWrapperDataTable=' RecordType.Name =: sRecordType AND Account.HasOptedOutOfAccount__c = false AND (FirstName LIKE \'%';

    public static final String WHERE_CLAUSE_5_ContactWrapperDataTable= 'Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Organization\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND client__r.LastName LIKE \'%';
    public static final String WHERE_CLAUSE_6_ContactWrapperDataTable='Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Organization\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND client__r.FirstName LIKE \'%';    
    public static final String WHERE_CLAUSE_8_ContactWrapperDataTable='Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Organization\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND (client__r.FirstName LIKE \'%';
    
    public static final String sWhereClauseOnFeedbackForRatingWithoutLocation = 'RecordTypeId=:feedbackRecordTypeId AND (AccountID__c=:accountId OR Referral__r.Resource__c =: resourceId)';   

    public static final String sFieldsonClientSearch = 'PreferredCommunicationMethod__c,Gender__c,OptOutInfoSharing__c, ';
    public static final String sWhereClauseonClientSearch = 'BirthDate =: userInputDate AND Age__c >= 18 AND (RecordType.Name =: sRecordType OR (RecordType.Name=:sNonCitizenRecordType AND Account.Applicable_Roles__c LIKE :citizenRole)) AND ';
    public static final String sFieldsOnContact = 'Id,ContactId';
    public static final String sWhereClauseOnContactForUser = 'ContactID = :strContactId';
    public static final String sIdStatusFields = 'Id,Status__c,AccountId';
    public static final String sWhereClauseOnContactIdValue = 'id=:strContactId';
    //SurveyInvitation fields
    public static final String sFieldsonSurveyInvite = 'Id ';
    public static final String sWhereClauseonSurveyInvite = ' consent__C=:recordId or Referral__c=:recordId ';
    public static final String sAggregateFieldsToQueryOnLocationResource = 'count(Id) total';
    public static final String sOrderbyAssessment = 'AssessmentTitle__c ASC';

    public static final String WHERE_CLAUSE_5_ContactWrapperDataTableAssister= 'Client__c!=null AND Organization__c =: sAccountId  AND ConsentLevel__c=\'Assister\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND client__r.LastName LIKE \'%';
    public static final String WHERE_CLAUSE_6_ContactWrapperDataTableAssister='Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Assister\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND client__r.FirstName LIKE \'%';    
    public static final String WHERE_CLAUSE_8_ContactWrapperDataTableAssister='Client__c!=null AND Organization__c =: sAccountId AND ConsentLevel__c=\'Assister\' AND client__r.OptOutInfoSharing__c=false AND Status__c = \'Active\' AND StartDate__c <=: sDate AND (EndDate__c >=: sDate OR EndDate__c = null) AND (client__r.FirstName LIKE \'%';

    public static final String sWhereClauseForLocationResource = 'Location__c=: locationrecId and Resource__c=:resourceId' ;
    public static final String sFieldsToQueryOnLocationResource = 'Id,Location__c,Resource__c' ;

    public static final String sFieldsToQueryOnUserForSystemAutoProcess= 'Id,Name' ;
    public static final String sWhereClauseForUserForSystemAutoProcess= 'Profile.Name=:sProfileName and IsActive=true' ;
    public static final String sOrderByUser= 'CreatedDate asc';

    public static final String SFieldsToqueryonLocationResourceRR= 'Id,Resource__c.Name,Resource__c,Resource__r.Organization__r.Name,Resource__r.Organization__c,Location__r.Geolocation__c,Resource__r.Organization__r.IsClaimed__c' ;
    public static final String sWhereClauseForLocationResourceRR='Id IN: locationResourceIds AND Location__r.Status__c=:sActiveStatus AND Status__c=:sActiveStatus AND Resource__r.Organization__r.Status__c=: sActiveAllowReferral';

    public static final String sFieldsToQueryOnAccountCreateReferral = 'Id,Name,Status__c,IsClaimed__c';
    public static final String sWhereClauseForAccountCreatReferral = 'Id =:orgId';

    public static final String sWhereClauseOnAssessResponseObjCitizen = 'Assessment__c =:sUserAssessId AND Assessment__r.RecordTypeId =:sRecTypeAssessUser AND recordtypeid =: sAssessmentRespRecTypeId';

    public static final String sFieldsToQueryOnUserNew = 'Id,ContactId,RE_Selected_Role__c,ApplicableRoles__c,Username';
    public static final String sWhereClauseOnUserNew = 'Id=: userId';
    public static final String sFieldsToQueryOnACR = 'Id,ContactId,AccountId,IsActive';
    public static final String sWhereClauseForACRGetOrg = 'Account.RecordtypeId=:sAccountRecordTypeId AND ContactId=: contactId AND Roles includes (:selectedRole) AND IsActive=true';
    public static final String sWhereClauseForACRGetOrg1 = 'Account.RecordtypeId=:sAccountRecordTypeId AND ContactId=: contactId AND Roles includes (:selectedRole) AND IsActive=false';
    
    public static final String sQueryDuplicateUser = 'Select Email,Count(Id) numcount from Contact where email != null AND email IN : lstEmails AND RecordtypeId =: nonCitizenRectypeId AND Status__c = \'Active\' AND (Account.Applicable_Roles__c LIKE ';
    public static final String sQueryDuplicateUser1 = ' OR Account.Applicable_Roles__c LIKE ';
    public static final String sQueryDuplicateUser2 = ' ) Group By Email';
    public static final String sFieldsToQueryOnACR1 = 'Id,ContactId,AccountId,Account.Name';

    public static final String sWhereClauseContactQuery = 'Id=:clientId';

    public static final String sWhereClauseForInactiveACRGetOrg = 'Account.RecordtypeId=:sAccountRecordTypeId AND ContactId=: contactId AND (Roles includes (:cpAdminRole)  OR Roles includes (:cpStaffRole)) AND IsActive=false';

}