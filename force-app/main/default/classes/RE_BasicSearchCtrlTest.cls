/***************************************************************************************************************************
*   Type        :   Test Class
*   Name        :   RE_BasicSearchCtrlTest
*   Created By   :   Deloitte
*   Created Date :   07/26/2019
*   Description :   This class acts as a test class for RE_BasicSearchCtrl
*   Modification Log:
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Deeksha                    07/26/2019       Initial Version
*****************************************************************************************************************************/
@isTest
private class RE_BasicSearchCtrlTest {
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         07/26/2019
* @methodname   setupTestData
* @description  This method is used to create test records for all test methods
* @param        none
* @return       none
********************************************************************************************/
    static  Id citizenRecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static Id contactCitizenRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(RE_GlobalConstants.strCitizenRecordTypeName).getRecordTypeId();
    static   Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
    
    @testSetup static void setupTestData() {
        TestDataFactory.testDataSetup();
        List<Account> lstCitizenAccounts = [SELECT Id FROM Account where recordTypeId=:citizenRecordTypeIdAccount LIMIT 1];
        lstCitizenAccounts[0].Status__c='Active - Allow referrals';
        lstCitizenAccounts[0].IsClaimed__c=false;        
        update lstCitizenAccounts;
        Contact citizenContact = TestDataFactory.createContactRecord(RE_GlobalConstants.strCitizenFirstName,RE_GlobalConstants.strCitizenLastName,RE_GlobalConstants.strCitizenEmail,contactCitizenRecordTypeId,false);
        citizenContact.AccountId=lstCitizenAccounts[0].Id;
        citizenContact.MailingPostalCode='75643';        
        citizenContact.ContactGeoLocation__Latitude__s=Double.valueof(44.140789);
        citizenContact.ContactGeoLocation__Longitude__s=Double.valueof(-80.095978);        
        insert citizenContact;
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation = TestDataFactory.createLocations(3, true, locationRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id, Name FROM Resource__c LIMIT 10];
        lstResource[0].Name= 'test Desc';
        TestDataFactory.createResources(2, true, resourceRecordTypeId, new List<Id>{lstCitizenAccounts[0].Id});
        List<LocationResource__c> lstLocRes = TestDataFactory.createLocationResource(2, true, null, lstLocation, lstResource);        
        List<RE_Archetype__c> lstArchetype = TestDataFactory.createArchetypeRecords(2,true,GeneralUtility.getRecrodTypeIdBySobjectAndDevName('RE_Archetype__c','SubArchetype'));
        List<RE_Goal__c> lstGoals = TestDataFactory.createGoalRecords(2,true,lstArchetype);
        List<RE_Taxonomy__c> lstTaxonomy = TestDataFactory.createTaxonomyRecords(2,true);
        List<RE_Resource_Taxonomy__c> lstResTaxonomy = TestDataFactory.createResourceTaxonomyRecords(2, true, lstResource, lstTaxonomy);
        List<Favorite__c> lstFavorite = TestDataFactory.createFavoritesRecords(2, true, lstLocRes);
        List<RE_Config__c> lstConfigRecords = TestDataFactory.createDomainConfigRecords(1,true,lstGoals,lstTaxonomy,'DomainConfig');  
        Profile citizenProfile = [SELECT Id FROM Profile WHERE Name =: RE_GlobalConstants.strCitizenProfileName];
        User citizenUser = TestDataFactory.createSpecificCommunityUser('reCusr', citizenContact.Id, 'RECitizenUser', RE_GlobalConstants.SAMPLE_USER_NAME_TEST, RE_GlobalConstants.strCitizenEmail, RE_GlobalConstants.strCitizenEmail, citizenProfile.Id, true);                   
        List<Referral__c> referralRec = TestDataFactory.createReferral(2, true, referralRecordTypeId, citizenContact.Id, lstCitizenAccounts, lstResource);
        Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
        RE_Config__c objConfig =new RE_Config__c(RecordTypeId=searchConfigRecId,Domain__c='Food',Subcategory__c='Emergencies & Disasters',Taxonomy__c=lstTaxonomy[0].Id);
        insert objConfig;
    }
    /********************************************************************************************
* @author       Deeksha Gupta
* @date         07/26/2019
* @methodname   testGetDomainCategories
* @description  This method is used to test the functionality of method - getDomainCategories.
* @param        none
* @return       none
********************************************************************************************/
    @isTest static void testCtrlMethods() {  
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
        

        RE_CreateLightningServerResponse result;
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
        lstCitizenAccounts[0].Name='test Desc';
        update lstCitizenAccounts;
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];

        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        

        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation= new List<Location__c>();
        
        List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 3];
        for(Location__c locationObj :lstLocationRec){
            locationObj.Zip__c= 75643;
            lstLocation.add(locationObj);
        }
        update lstLocation;
        TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
        
        List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                               Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                               Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                               Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                               Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                               Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
        List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
        Set<String> setTaxonomyIds = new Set<String>();
        for(RE_Taxonomy__c tax : lstTaxRecords){
            setTaxonomyIds.add(tax.Id);
        }
        Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
        
        RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
        
        Map<String, Object> mapInputs = new Map<String, Object>();
        mapInputs.put('locationresource',lstLocRes[0]);
        
        Location location1 = Location.newInstance(28.635308,77.22496);
        Location location2 = Location.newInstance(37.7749295,-122.4194155);
        mapInputs.put('location',location1);
        Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
        Map<Id, Double> milesMap = new Map<Id, Double>();
        milesMap.put(lstResource[0].Id,distance);
        mapInputs.put('miles',milesMap);   
        Set<Id> setLocationIds = new Set<Id>();
        setLocationIds.add(lstLocation[0].Id);
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
        mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
        String locationId = lstLocation[0].Id;
        
        System.runAs(lstUsers[0]){
            result= RE_BasicSearchCtrl.getDomainCategories(true);
            System.assert(result.isSuccessful == true,'Success');
            result= RE_BasicSearchCtrl.getUserInfo();
            System.assert(result.isSuccessful == true,'Success');
            result= RE_BasicSearchCtrl.insertReferralForResident(objResourceJson,locationId, false);
            RE_BasicSearchCtrl.insertReferralForResident('','', false);
            System.assert(result.isSuccessful == true,'Success');
            //result= RE_BasicSearchCtrl.getSubCategorySearchResults('11570','Employment','Emergencies & Disasters','Advocacy and Referrals','1','1','searchbycategory',JSON.serialize(setOFResourceIds));      
            //RE_BasicSearchCtrl.createFavorite(lstLocRes[0].Id);
            //RE_BasicSearchCtrl.getResourceTaxonomies(setTaxonomyIds);
            //RE_BasicSearchCtrl.getLocationWrapper(mapInputs);
               
            }
            Test.stopTest();
        }
        
            /********************************************************************************************
    * @author       Deeksha Gupta
    * @date         07/26/2019
    * @methodname   testGetDomainCategories
    * @description  This method is used to test the functionality of method - getDomainCategories.
    * @param        none
    * @return       none
    ********************************************************************************************/
        @isTest static void testCtrlMethodsTest() {  
            List <User> lstUsers = new List<User>();
            lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                        Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
            

            RE_CreateLightningServerResponse result;
            Test.startTest();
            List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
            lstCitizenAccounts[0].Name='test Desc';
            update lstCitizenAccounts;
            Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];

            Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
            List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
            
            Set<Id> setOFResourceIds = new Set<Id>();
            for(Resource__c res: lstResource){
                setOFResourceIds.add(res.Id);
            }
            Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
            
            String stringResIds = '';
            for(String s:setOfIdString) {
                stringResIds += (stringResIds == ''?'':',')+s;
            }
            

            Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
            Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
            List<Location__c> lstLocation= new List<Location__c>();
            
            List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 3];
            for(Location__c locationObj :lstLocationRec){
                locationObj.Zip__c= 75643;
                lstLocation.add(locationObj);
            }
            update lstLocation;
            TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
            
            List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
            List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                                   Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                                   Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                                   Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                                   Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                                   Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
            List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
            Set<String> setTaxonomyIds = new Set<String>();
            for(RE_Taxonomy__c tax : lstTaxRecords){
                setTaxonomyIds.add(tax.Id);
            }
            Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
            
            RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                    WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
            
            Map<String, Object> mapInputs = new Map<String, Object>();
            mapInputs.put('locationresource',lstLocRes[0]);
            
            Location location1 = Location.newInstance(28.635308,77.22496);
            Location location2 = Location.newInstance(37.7749295,-122.4194155);
            mapInputs.put('location',location1);
            Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
            Map<Id, Double> milesMap = new Map<Id, Double>();
            milesMap.put(lstResource[0].Id,distance);
            mapInputs.put('miles',milesMap);   
            Set<Id> setLocationIds = new Set<Id>();
            setLocationIds.add(lstLocation[0].Id);
            Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
            mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
            String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
            String locationId = lstLocation[0].Id;
            
            System.runAs(lstUsers[0]){
 
            Map<String, Object> mapRes= new Map<String, Object>();
            mapRes = RE_BasicSearchHelper.getUserLocation(lstUsers[0].ContactId, lstUsers[0].ProfileId);
            Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = lstLocation[0].Id;
            fixedSearchResults[1] = lstResource[1].Id;
            fixedSearchResults[2] = lstResource[2].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            result= RE_BasicSearchCtrl.getKeywordSearchResults('test','75643','10','0','searchkeyword',JSON.serialize(new Set<Id>()),JSON.serialize(new Set<Id>()));
            result= RE_BasicSearchCtrl.getKeywordSearchResults('test Desc','75643','10','0','searchkeyword',JSON.serialize(new Set<Id>{lstResource[0].Id}),JSON.serialize(new Set<Id>()));
            result= RE_BasicSearchCtrl.getKeywordSearchResults('test Desc','75643','10','0','searchresults',JSON.serialize(new Set<Id>{lstResource[0].Id}),JSON.serialize(new Set<Id>()));
            
            System.assert(result.isSuccessful == true,'Success');
            //result= RE_BasicSearchCtrl.getSubCategorySearchResults('11570','Employment','Emergencies & Disasters','Advocacy and Referrals','1','1','searchbycategory',JSON.serialize(setOFResourceIds));      
            //RE_BasicSearchCtrl.createFavorite(lstLocRes[0].Id);
            //RE_BasicSearchCtrl.getResourceTaxonomies(setTaxonomyIds);
            //RE_BasicSearchCtrl.getLocationWrapper(mapInputs);
               
            }
            Test.stopTest();
        }
        
         @isTest static void testCtrlMethods6() {  
            List <User> lstUsers = new List<User>();
            lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                        Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
            

            RE_CreateLightningServerResponse result;
            //Test.startTest();
            List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
            lstCitizenAccounts[0].Name='test Desc';
            update lstCitizenAccounts;
            Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
            Test.startTest();
            Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
            List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
            
            Set<Id> setOFResourceIds = new Set<Id>();
            for(Resource__c res: lstResource){
                setOFResourceIds.add(res.Id);
            }
            Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
            
            String stringResIds = '';
            for(String s:setOfIdString) {
                stringResIds += (stringResIds == ''?'':',')+s;
            }
            

            Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
            Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
            List<Location__c> lstLocation= new List<Location__c>();
            
            List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 3];
            for(Location__c locationObj :lstLocationRec){
                locationObj.Zip__c= 75643;
                lstLocation.add(locationObj);
            }
            update lstLocation;
            TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
            
            List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
            List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                                   Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                                   Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                                   Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                                   Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                                   Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
            LocationResource__c lstLcnRsr1 = lstLocRes[0].clone(false);
            insert lstLcnRsr1;
            LocationResource__c lstLcnRsr2 = lstLocRes[1].clone(false);
            insert lstLcnRsr2;
            LocationResource__c lstLcnRsr3 = lstLocRes[2].clone(false);
            insert lstLcnRsr3;
            List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
            Set<String> setTaxonomyIds = new Set<String>();
            for(RE_Taxonomy__c tax : lstTaxRecords){
                setTaxonomyIds.add(tax.Id);
            }
            Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
            
            RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                    WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
            
            Map<String, Object> mapInputs = new Map<String, Object>();
            mapInputs.put('locationresource',lstLocRes[0]);
            
            Location location1 = Location.newInstance(28.635308,77.22496);
            Location location2 = Location.newInstance(37.7749295,-122.4194155);
            mapInputs.put('location',location1);
            Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
            Map<Id, Double> milesMap = new Map<Id, Double>();
            milesMap.put(lstResource[0].Id,distance);
            mapInputs.put('miles',milesMap);   
            Set<Id> setLocationIds = new Set<Id>();
            setLocationIds.add(lstLocation[0].Id);
            Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
            mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
            String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
            String locationId = lstLocation[0].Id;
            
            System.runAs(lstUsers[0]){
                
                Map<String, Object> mapRes= new Map<String, Object>();
                mapRes = RE_BasicSearchHelper.getUserLocation(lstUsers[0].ContactId, lstUsers[0].ProfileId);
                Id [] fixedSearchResults= new Id[3];
                fixedSearchResults[0] = lstLocation[0].Id;
                fixedSearchResults[1] = lstResource[1].Id;
                fixedSearchResults[2] = lstResource[2].Id;
                Test.setFixedSearchResults(fixedSearchResults);
                result= RE_BasicSearchCtrl.getKeywordSearchResults('test','75643','10','0','searchkeyword',JSON.serialize(new Set<Id>()),JSON.serialize(new Set<Id>()));
                result= RE_BasicSearchCtrl.getKeywordSearchResults('test Desc','75643','10','0','searchkeyword',JSON.serialize(new Set<Id>{lstResource[0].Id}),JSON.serialize(new Set<Id>()));
                result= RE_BasicSearchCtrl.getKeywordSearchResults('test Desc','75643','10','0','searchresults',JSON.serialize(new Set<Id>{lstResource[0].Id}),JSON.serialize(new Set<Id>()));
                System.assert(result.isSuccessful == true,'Success');
                //result= RE_BasicSearchCtrl.getSubCategorySearchResults('11570','Employment','Emergencies & Disasters','Advocacy and Referrals','1','1','searchbycategory',JSON.serialize(setOFResourceIds));      
            //RE_BasicSearchCtrl.createFavorite(lstLocRes[0].Id);
            //RE_BasicSearchCtrl.getResourceTaxonomies(setTaxonomyIds);
            //RE_BasicSearchCtrl.getLocationWrapper(mapInputs);
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getSubCategorySearchResultsTest(){
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 3];
        test.startTest();
        
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        List<LocationResource__c> lstLocationRes = new List<LocationResource__c>([SELECT id, Location__r.Zip__c, Location__r.Geolocation__c FROM LocationResource__c LIMIT 5]);
        Set<Id> setLocResIds = new Set<Id>();
        for(LocationResource__c locRes : lstLocationRes){
            setLocResIds.add(locRes.Id);
        }
        
        System.runAs(lstUsers[0]){
            RE_CreateLightningServerResponse result= RE_BasicSearchCtrl.getSubCategorySearchResults('','Food','Emergencies & Disasters','Advocacy and Referrals','20',null,'searchbycategory',null);
            system.assert(result.isSuccessful == true,'Success');
        }
        test.stopTest();
    }
    
 @isTest
    public static void getOptOutInfoSharingDetailsTest(){
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail LIMIT 3];
        test.startTest();
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        List<LocationResource__c> lstLocationRes = new List<LocationResource__c>([SELECT id, Location__r.Zip__c, Location__r.Geolocation__c FROM LocationResource__c LIMIT 5]);
        Set<Id> setLocResIds = new Set<Id>();
        for(LocationResource__c locRes : lstLocationRes){
            setLocResIds.add(locRes.Id);
        }

        if(lstUsers!=null && lstUsers.size()>0){
            System.runAs(lstUsers[0]){
                RE_CreateLightningServerResponse result = RE_BasicSearchCtrl.getOptOutInfoSharingDetails();
                system.assert(result.isSuccessful == true,'Success');
            }
        }
        test.stopTest();
    }    
    @isTest
    public static void connectDraftReferralsFromSearchResultZipChng(){
        List<Referral__c> lstRef = new List<Referral__c>();
        lstRef = [Select id from Referral__c limit 1];
        RE_CreateLightningServerResponse result = RE_BasicSearchCtrl.connectDraftReferralsFromSearchResults(lstRef[0].Id, false);
        //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
        system.assert(result.isSuccessful == true,'Success');
    }
     @isTest static void testCtrlMethodsZipCHange() {  
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
        
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
        lstCitizenAccounts[0].Name='test Desc';
        update lstCitizenAccounts;
        
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation= new List<Location__c>();
        
        List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 3];
        for(Location__c locationObj :lstLocationRec){
            locationObj.Zip__c= 75643;
            lstLocation.add(locationObj);
        }
        update lstLocation;
        
        TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
        
        List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                               Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                               Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                               Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                               Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                               Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
        
        List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
        Set<String> setTaxonomyIds = new Set<String>();
        for(RE_Taxonomy__c tax : lstTaxRecords){
            setTaxonomyIds.add(tax.Id);
        }
        Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
        
        RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
        
        Map<String, Object> mapInputs = new Map<String, Object>();
        mapInputs.put('locationresource',lstLocRes[0]);
        
        Location location1 = Location.newInstance(28.635308,77.22496);
        Location location2 = Location.newInstance(37.7749295,-122.4194155);
        mapInputs.put('location',location1);
        Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
        Map<Id, Double> milesMap = new Map<Id, Double>();
        milesMap.put(lstResource[0].Id,distance);
        mapInputs.put('miles',milesMap);   
        Set<Id> setLocationIds = new Set<Id>();
        setLocationIds.add(lstLocation[0].Id);
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
        mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
        String locationId = lstLocation[0].Id;
        
        System.runAs(lstUsers[0]){
            
            
            Map<String, Object> mapRes= new Map<String, Object>();
            mapRes = RE_BasicSearchHelper.getUserLocation(lstUsers[0].ContactId, lstUsers[0].ProfileId);
            Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = lstLocation[0].Id;
            fixedSearchResults[1] = lstResource[1].Id;
            fixedSearchResults[2] = lstResource[2].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            result= RE_BasicSearchCtrl.getKeywordSearchResults('test','75611','10','0','searchkeyword',JSON.serialize(new Set<Id>()),JSON.serialize(new Set<Id>()));
           
            System.assert(result.isSuccessful == true,'Success');
            result= RE_BasicSearchCtrl.getSubCategorySearchResults('115700','Employment','Emergencies & Disasters','Advocacy and Referrals','1','1','searchbycategory',JSON.serialize(setOFResourceIds));      
            
        }
        Test.stopTest();
    }
    
     @isTest static void testCtrlMethods2() {  
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
        
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
        lstCitizenAccounts[0].Name='test Desc';
        update lstCitizenAccounts;
        
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation= new List<Location__c>();
        
        List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 3];
        for(Location__c locationObj :lstLocationRec){
            locationObj.Zip__c= 75643;
            lstLocation.add(locationObj);
        }
        update lstLocation;
        
        TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
        
        List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                               Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                               Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                               Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                               Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                               Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
        
        List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
        Set<String> setTaxonomyIds = new Set<String>();
        for(RE_Taxonomy__c tax : lstTaxRecords){
            setTaxonomyIds.add(tax.Id);
        }
        Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
        
        RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
        
        Map<String, Object> mapInputs = new Map<String, Object>();
        mapInputs.put('locationresource',lstLocRes[0]);
        
        Location location1 = Location.newInstance(28.635308,77.22496);
        Location location2 = Location.newInstance(37.7749295,-122.4194155);
        mapInputs.put('location',location1);
        Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
        Map<Id, Double> milesMap = new Map<Id, Double>();
        milesMap.put(lstResource[0].Id,distance);
        mapInputs.put('miles',milesMap);   
        Set<Id> setLocationIds = new Set<Id>();
        setLocationIds.add(lstLocation[0].Id);
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
        mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
        String locationId = lstLocation[0].Id;
        
        System.runAs(lstUsers[0]){
            result= RE_BasicSearchCtrl.getDomainCategories(true);
            System.assert(result.isSuccessful == true,'Success');
            
            result= RE_BasicSearchCtrl.getUserInfo();
            System.assert(result.isSuccessful == true,'Success');
            
            result= RE_BasicSearchCtrl.insertReferralForResident(objResourceJson,locationId, false);
            RE_BasicSearchCtrl.insertReferralForResident('','', false);
            System.assert(result.isSuccessful == true,'Success');
            
            Map<String, Object> mapRes= new Map<String, Object>();
            mapRes = RE_BasicSearchHelper.getUserLocation(lstUsers[0].ContactId, lstUsers[0].ProfileId);
            Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = lstLocation[0].Id;
            fixedSearchResults[1] = lstResource[1].Id;
            fixedSearchResults[2] = lstResource[2].Id;
                 
            RE_BasicSearchCtrl.createFavorite(lstLocRes[0].Id);
            RE_BasicSearchCtrl.getResourceTaxonomies(setTaxonomyIds);
            RE_BasicSearchCtrl.getLocationWrapper(mapInputs);
            
        }
        Test.stopTest();
    }
    
    @isTest static void testCtrlMethodsGuestZipCHange() {  
        List <User> lstUsers = new List<User>();
        lstUsers = [SELECT Id, ContactId,Contact.Email,Contact.MailingStreet,Contact.MailingState,ProfileId,
                    Contact.MailingCountry,Contact.MailingPostalCode,Contact.MailingCity FROM User WHERE Email=:RE_GlobalConstants.strCitizenEmail];
        
        
        RE_CreateLightningServerResponse result;
        Test.startTest();
        List<Account> lstCitizenAccounts = [SELECT Id, Name FROM Account where recordTypeId=:citizenRecordTypeIdAccount];
        lstCitizenAccounts[0].Name='test Desc';
        update lstCitizenAccounts;
        
        Contact citizenContact = [SELECT Id FROM Contact WHERE Email =:RE_GlobalConstants.strCitizenEmail AND LastName =: RE_GlobalConstants.strCitizenLastName ];
        Id resourceRecordTypeId = Schema.SObjectType.Resource__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strResourceRecordTypeName).getRecordTypeId();
        List<Resource__c> lstResource = [SELECT Id FROM Resource__c LIMIT 10];
        
        Set<Id> setOFResourceIds = new Set<Id>();
        for(Resource__c res: lstResource){
            setOFResourceIds.add(res.Id);
        }
        Set<String> setOfIdString = (Set<String>)JSON.deserialize(JSON.serialize(setOFResourceIds), Set<String>.class);
        
        String stringResIds = '';
        for(String s:setOfIdString) {
            stringResIds += (stringResIds == ''?'':',')+s;
        }
        Id referralRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName('Referral__c', RE_GlobalConstants.strReferralRecordTypeDeveloperName);      
        Id locationRecordTypeId = Schema.SObjectType.Location__c.getRecordTypeInfosByName().get(RE_GlobalConstants.strLocationRecordTypeName).getRecordTypeId();
        List<Location__c> lstLocation= new List<Location__c>();
        
        List<Location__c> lstLocationRec = [SELECT Id, Zip__c FROM Location__c WHERE recordTypeId=:locationRecordTypeId LIMIT 1];
        for(Location__c locationObj :lstLocationRec){
            locationObj.Zip__c= 75643;
            lstLocation.add(locationObj);
        }
        update lstLocation;
        lstLocation.add(lstLocation[0]);
        lstLocation.add(lstLocation[0]);
        TestDataFactory.createLocationResource(3, true, null, lstLocation, lstResource);
        
        List<Referral__c> referralRec = [SELECT Id FROM Referral__c WHERE recordTypeId =:referralRecordTypeId LIMIT 2];      
        List<LocationResource__c> lstLocRes = [SELECT Id,Location__c,Location__r.Name,Location__r.Phone__c,Location__r.Account__r.Phone,
                                               Location__r.Email__c, Location__r.Account__r.Email__c,Location__r.Address1__c,Location__r.Address2__c,
                                               Location__r.City__c,Location__r.State__c,Location__r.County__c,Location__r.Zip__c,Location__r.ZipExtensionCode__c,
                                               Location__r.Geolocation__c,Location__r.SpecialLocationInstructions__c,Location__r.DaysLocationClosed__c,
                                               Location__r.Geolocation__Latitude__s,Location__r.Geolocation__Longitude__s,Resource__c,Resource__r.Organization__r.IsClaimed__c,
                                               Resource__r.SdohDomain__c,Phone__c,TollFree__c,Notes__c FROM LocationResource__c LIMIT 3 ];
        
        
        List<RE_Taxonomy__c> lstTaxRecords = [SELECT Id,Name,Description__c,Name__c FROM RE_Taxonomy__c LIMIT 5];
        Set<String> setTaxonomyIds = new Set<String>();
        for(RE_Taxonomy__c tax : lstTaxRecords){
            setTaxonomyIds.add(tax.Id);
        }
        Id searchConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('SearchConfig').getRecordTypeId();
        
        RE_Config__c lstConf = [SELECT Id,Name,Archetype__c,Category__c,Domain__c,DomainCategory__c,DomainImage__c,DomainOrder__c,Goal__c,ParentConfig__c,ShowCategory__c,Taxonomy__c,Subcategory__c FROM RE_Config__c
                                WHERE recordTypeId=:searchConfigRecId LIMIT 1 ];
        
        Map<String, Object> mapInputs = new Map<String, Object>();
        mapInputs.put('locationresource',lstLocRes[0]);
        
        Location location1 = Location.newInstance(28.635308,77.22496);
        Location location2 = Location.newInstance(37.7749295,-122.4194155);
        mapInputs.put('location',location1);
        Double distance = RE_MyPlanHelper.getDistance(location1,location2,'mi');
        Map<Id, Double> milesMap = new Map<Id, Double>();
        milesMap.put(lstResource[0].Id,distance);
        mapInputs.put('miles',milesMap);   
        Set<Id> setLocationIds = new Set<Id>();
        setLocationIds.add(lstLocation[0].Id);
        Map<Id,  Map<String, List<String>>> mapLocationIdOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationIds,lstLocRes);
        mapInputs.put('operatinghours',mapLocationIdOperatingHours);  
        String objResourceJson ='{"accountIsClaimed": "true","accountStatus":"Active - Allow referrals","locationId": "'+lstLocation[0].Id+'","resourceId": "'+lstResource[0].Id+'","accountId": "'+lstCitizenAccounts[0].Id+'"}';
        String locationId = lstLocation[0].Id;
        //User usr = [select id from user where usertype='Guest' limit 1];
         Profile guestUserProfile = [SELECT Id FROM Profile WHERE Name='Resource Engine Profile' AND Name != null LIMIT 1];
        User guestUser = TestDataFactory.createUser('gusr',guestUserProfile.Id,'testguest@test.com1','test@guest.com',false);
        System.runAs(guestUser){
            
            
            Map<String, Object> mapRes= new Map<String, Object>();
            mapRes = RE_BasicSearchHelper.getUserLocation(lstUsers[0].ContactId, lstUsers[0].ProfileId);
            Id [] fixedSearchResults= new Id[3];
            fixedSearchResults[0] = lstLocation[0].Id;
            fixedSearchResults[1] = lstResource[1].Id;
            fixedSearchResults[2] = lstResource[2].Id;
            Test.setFixedSearchResults(fixedSearchResults);
            result= RE_BasicSearchCtrl.getKeywordSearchResults('test','75611','10','0','searchkeyword',JSON.serialize(new Set<Id>()),JSON.serialize(new Set<Id>()));
           
            System.assert(result.isSuccessful == true,'Success');
            result= RE_BasicSearchCtrl.getSubCategorySearchResults('115700','Employment','Emergencies & Disasters','Advocacy and Referrals','1','1','searchbycategory',JSON.serialize(setOFResourceIds));      
            
        }
        Test.stopTest();
    }
    
}