/**
*@author       : Karthik Gulla
*@date         : 12/02/2019
*@description  : Test class for Resources Summary, Resources Details Functionality
*/  
@isTest
public class SSP_ResourcesTest {
    @testSetup static void setup() {
        SSP_TestDataFactory.setupTestData();
        Id contactRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Contact','Citizen');
        Id accRecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName('Account','Application');

        List<Account> lstAccounts = SSP_TestDataFactory.createAccounts(1, false);
        lstAccounts[0].Name = 'TaxFilingTestAppAccount';
        lstAccounts[0].RecordTypeId = accRecordTypeId;
        lstAccounts = ESAPI.accessController().insertAsUser(lstAccounts, SSP_Utility.getFieldsNamesList (lstAccounts)).getInsertedObjects();
        
        //List<Contact> lstContacts = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        List<Contact> lstContacts = new List<Contact>();
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenOne', 'User', 'citizenone@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTwo', 'User', 'citizentwo@abc.xyz', contactRecordTypeId, false));
        lstContacts.add(SSP_TestDataFactory.createContactRecord('CitizenTww', 'User', 'citizentww@abc.xyz', contactRecordTypeId, false));
        insert lstContacts;

        AccountContactRelation acrObjectMemberOne = new AccountContactRelation(); 
        acrObjectMemberOne.Accountid = lstAccounts[0].Id;
        acrObjectMemberOne.Contactid = fetchCitizenUser().ContactId;
        acrObjectMemberOne.IsActive = true;

        List<AccountContactRelation> lstACRRecords = new List<AccountContactRelation>();
        lstACRRecords.add(acrObjectMemberOne);

        ESAPI.accessController().insertAsUser(lstACRRecords, SSP_Utility.getFieldsNamesList (lstACRRecords));       
        
        List<SSP_Application__c> lstApplications = SSP_TestDataFactory.createSSPApplications(1, false);
        lstApplications[0].Account__c=lstAccounts[0].Id;
        lstApplications[0].ProgramsApplied__c = 'SN;KT;MA;SS';
        lstApplications[0].HasLifeEstateToggle__c = 'Y';
        lstApplications= ESAPI.accessController().insertAsUser(lstApplications, SSP_Utility.getFieldsNamesList (lstApplications)).getInsertedObjects();
        
        List<SSP_Member__c> lstMembers = SSP_TestDataFactory.createSSPMembers(3, false);
        lstMembers[0].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[0].FirstName__c=lstContacts[0].FirstName;
        lstMembers[0].LastName__c=lstContacts[0].LastName;     
        lstMembers[0].MiddleInitial__c = 'Y';
        lstMembers[0].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[0].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[0].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[0].HasInvestmentsToggle__c = 'Y';
        lstMembers[0].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[0].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[0].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers[0].IsBlindToggle__c = 'Y';
        lstMembers[1].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[1].FirstName__c=lstContacts[1].FirstName;
        lstMembers[1].LastName__c=lstContacts[1].LastName;     
        lstMembers[1].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[1].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[1].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[1].HasInvestmentsToggle__c = 'Y';
        lstMembers[1].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[1].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[1].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers[2].Contact__c=fetchCitizenUser().ContactId;
        lstMembers[2].FirstName__c=lstContacts[2].FirstName;
        lstMembers[2].LastName__c=lstContacts[2].LastName;     
        lstMembers[2].PrimaryPhoneExtension__c ='7348789790';
        lstMembers[2].PrimaryPhoneNumber__c ='8983838290';
        lstMembers[2].HasOwnBankAccountToggle__c = 'Y';
        lstMembers[2].HasInvestmentsToggle__c = 'Y';
        lstMembers[2].HasLifeInsuranceToggle__c = 'Y';
        lstMembers[2].HasCashReloadableMoneyCardToggle__c = 'Y';
        lstMembers[2].HasRealEstatePropertyToggle__c = 'Y';
        lstMembers = ESAPI.accessController().insertAsUser(lstMembers, SSP_Utility.getFieldsNamesList (lstMembers)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_TestDataFactory.createApplicationIndividuals(3, false); 
        lstAppIndividuals[0].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[0].SSP_Member__c=lstMembers[0].Id;
        lstAppIndividuals[0].IsHeadOfHousehold__c=true;
        lstAppIndividuals[1].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[1].SSP_Member__c=lstMembers[1].Id;
        lstAppIndividuals[1].IsHeadOfHousehold__c=false;
        lstAppIndividuals[2].SSP_Application__c=lstApplications[0].Id;
        lstAppIndividuals[2].SSP_Member__c=lstMembers[2].Id;
        lstAppIndividuals[2].IsHeadOfHousehold__c=false;
        lstAppIndividuals = ESAPI.accessController().insertAsUser(lstAppIndividuals, SSP_Utility.getFieldsNamesList (lstAppIndividuals)).getInsertedObjects();
        
        insert new LOG_LogMessageSettings__c(
            Name = RE_GlobalConstants.LOGS_DEFAULT_AUTOGENERATED,
            LOG_Debug__c = true,
            LOG_Error__c= true,
            LOG_Info__c = true,
            LOG_Warning__c = true,
            LOG_Log_Purge__c = 365
        );

        List<SSP_Asset__c> lstTestAssets = SSP_TestDataFactory.createAssets(6, 'Resource', false);
        lstTestAssets[0].ResourceTypeCode__c = 'VI';
        lstTestAssets[0].Make__c = 'Hero'; 
        lstTestAssets[0].Model__c  = 'Splendour';
        lstTestAssets[0].ModelYear__c = '2019';
        lstTestAssets[0].SSP_Member__c = lstMembers[0].Id;
        lstTestAssets[0].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        lstTestAssets[0].DCId__c = 8934;

        lstTestAssets[1].ResourceTypeCode__c = 'RP';
        lstTestAssets[1].RealEstateFairMarketValue__c = 345; 
        lstTestAssets[1].SSP_Member__c = lstMembers[1].Id;
        lstTestAssets[1].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        lstTestAssets[1].DCId__c = 8935;

        lstTestAssets[2].ResourceTypeCode__c = 'FA';
        lstTestAssets[2].FuneralLocation__c = 'Test Funeral Location'; 
        lstTestAssets[2].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        lstTestAssets[2].SSP_Member__c = lstMembers[0].Id;
        lstTestAssets[2].DCId__c = 8936;

        lstTestAssets[3].ResourceTypeCode__c = 'FA';
        lstTestAssets[3].FuneralLocation__c = 'Test Funeral Location1'; 
        lstTestAssets[3].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        lstTestAssets[3].SSP_Member__c = lstMembers[0].Id;
        lstTestAssets[3].DCId__c = 8937;

        lstTestAssets[4].ResourceTypeCode__c = 'RP';
        lstTestAssets[4].RealEstateFairMarketValue__c = 345; 
        lstTestAssets[4].SSP_Member__c = lstMembers[0].Id;
        lstTestAssets[4].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        
        lstTestAssets[5].ResourceTypeCode__c = 'LI';
        lstTestAssets[5].RecordTypeId = SSP_Utility.getRecrodTypeIdBySobjectAndDevName(SSP_GlobalConstants.ASSETOBJECTNAME, SSP_GlobalConstants.RESOURCERECORDTYPENAME);
        lstTestAssets[5].SSP_Member__c = lstMembers[0].Id;
        lstTestAssets[5].DCId__c = 8937;
        insert lstTestAssets;

        SSP_TestDataFactory.createResourceOwnerships(1, new List<SSP_Asset__c>{lstTestAssets[1]}, new List<SSP_Member__c>{lstMembers[0]}, true);
        SSP_TestDataFactory.createResourceOwnerships(1, new List<SSP_Asset__c>{lstTestAssets[0]}, null, true);
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id','ContactId'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }

    @isTest
    public static void testResourcesController(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_Asset__c> lstAssets = [SELECT Id, ResourceTypeCode__c FROM SSP_Asset__c WHERE ResourceTypeCode__c = 'VI' LIMIT 1];
        System.runAs(fetchCitizenUser()){
            Map<String,String> mapUserInputs = new Map<String,String>();
            mapUserInputs.put('applicationId', lstApplications[0].Id);
            mapUserInputs.put('memberId', lstMembers[0].Id);
            SSP_LightningResponse clsResponse = SSP_ResourcesController.getDetailsForResourcesSummary(mapUserInputs);
            List<SSP_ResourcesWrapper> lstResWrapper = (List<SSP_ResourcesWrapper>) JSON.deserialize(String.valueOf((clsResponse.mapResponse).get('ResRequiringDetails')), List<SSP_ResourcesWrapper>.class);

            mapUserInputs.clear();
            mapUserInputs.put('strResourceId', lstAssets[0].Id);
            mapUserInputs.put('memberId', lstMembers[0].Id);
            mapUserInputs.put('strResourceType','VI');
            SSP_ResourcesController.removeResources(mapUserInputs);

            mapUserInputs.clear();
            mapUserInputs.put('applicationId', 'app123434');
            mapUserInputs.put('memberId', 'mem12232');
            SSP_ResourcesController.getDetailsForResourcesSummary(mapUserInputs);
            SSP_ResourcesController.removeResources(mapUserInputs);
        }    
    }

    @isTest
    public static void testResourcesDetailsController(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id];
        List<SSP_Asset__c> lstAssets = [SELECT Id, ResourceTypeCode__c FROM SSP_Asset__c WHERE ResourceTypeCode__c = 'VI' LIMIT 1];
        String strJSON ='{"strResourceId":"'+lstAssets[0].Id+'","strApplicationId":"'+lstApplications[0].Id+'","strOtherOwners":"Other","IsThereAnotherOwnerToggle__c":"Y","NotEnoughInformation__c": false,"StartDate__c":"'+SSP_Utility.today()+'","VehicleFairMarketValue__c":"132","ResourceSubTypeCode__c":"CAR","ResourceTypeCode__c":"VI","strTempResId":"409576","strAdditionalOwners":[{"value":"tejst"},{"value":"tejstonw"}]}';
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.saveResourceDetails(strJSON);
            SSP_ResourceDetailsController.getInsurancePolicyDetailsForAsset(lstMembers[0].Id);
            SSP_ResourceDetailsController.getInsurancePolicyDetailsForAsset('mem824923');
        }

        String strJSONOne ='{"ResourceTypeCode__c": null,"ResourceSubTypeCode__c":"","strTempResId":"409576"]}';
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.saveResourceDetails(strJSONOne);
        } 

        String strJSONTwo ='{"strApplicationId":"'+lstApplications[0].Id+'","strMemberId":"'+lstMembers[0].Id+'","ResourceTypeCode__c":"BP"}';
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.saveResourceDetails(strJSONTwo);
        }

        String strJSONThree ='{"strMemberId":"'+lstMembers[0].Id+'","strApplicationId":"'+lstApplications[0].Id+'","strOtherOwners":"Other,'+lstMembers[1].Id+'","IsThereAnotherOwnerToggle__c":"Y","NotEnoughInformation__c": false,"StartDate__c":"'+SSP_Utility.today()+'","VehicleFairMarketValue__c":"132","ResourceSubTypeCode__c":"CAR","ResourceTypeCode__c":"VI","strTempResId":"409576","strAdditionalOwners":[{"value":"tejst"},{"value":"tejstonw"}]}';
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.saveResourceDetails(strJSONThree);
        }

        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers(lstApplications[0].Id,'23223244',SSP_GlobalConstants.OTHERS);
        }

        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ResourceDetailsController.getCurrentApplicationHouseholdMembers('1232412323','23223244',SSP_GlobalConstants.OTHERS);
        } 

        Map<String,Object> mapUserInputs = new Map<String,Object>();
        mapUserInputs.put('strResourceType', '34');
        mapUserInputs.put('memberId', 'mem2347834');
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourceDetailsController.updateQuestionsBasedOnResourceType(mapUserInputs);
        } 

        System.runAs(fetchCitizenUser()){ 
            SSP_ResourceDetailsController.removeResourceOwnershipRecords('asset23343');
        }
    }

    @isTest
    public static void testResourcesService(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getApplicationIndividualForMember(lstApplications[0].Id, lstMembers[0].Id);
        }

        Map<String,String> mapUserInputs = new Map<String,String>();
        mapUserInputs.put('strResourceType', '34');
        mapUserInputs.put('memberId', 'mem2347834');
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getResourcesForMemberBasedOnResourceType(mapUserInputs);
        }
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getApplicationIndividualForMember('app1233', 'mem12232');
        }
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getAdditionalOwnersByResourceOwnership('asset1234');
        }
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getResourcesByOwnership('mem4556', new List<String>());
        }
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.updateGatepostQuestions(mapUserInputs,'Y','Add');
        }
        System.runAs(fetchCitizenUser()){ 
            SSP_ResourcesService.getResourcesDetailsMappings(null);
        }
    }

    @isTest
    public static void testExistResourcesController(){
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c WHERE HasRealEstatePropertyToggle__c = 'Y'];
        List<SSP_Asset__c> lstAssets = [SELECT Id, ResourceTypeCode__c, FaceValueAmount__c FROM SSP_Asset__c WHERE ResourceTypeCode__c = 'VI' AND SSP_Member__c = : lstMembers[0].Id LIMIT 1];
        Map<String,String> mapUserInputs = new Map<String,String>();
        mapUserInputs.put('memberId', '1234567890');

        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ExistResourcesController.getExistingResourcesForChangeOrRemoval(mapUserInputs, new List<String>());
            
            String strUpdatedValues = '[{"PreFuneralAgmtGoodsAndServicesCost__c":"657.12"}]';
            SSP_LightningResponse clsResponse2 = SSP_ExistResourcesController.updateExistingResources(strUpdatedValues, mapUserInputs.get('memberId'));
        }

        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ExistResourcesController.getExistingResourcesForChangeOrRemoval(mapUserInputs, new List<String>());
            
            String strUpdatedValues = '[{"Id":"'+lstAssets[0].Id+'","IsDeleted__c": true,"PreFuneralAgmtGoodsAndServicesCost__c":"657.12"}]';
            SSP_LightningResponse clsResponse2 = SSP_ExistResourcesController.updateExistingResources(strUpdatedValues, mapUserInputs.get('memberId'));
        }

        mapUserInputs.put('memberId', lstMembers[0].Id);
        System.runAs(fetchCitizenUser()){ 
            SSP_LightningResponse clsResponse = SSP_ExistResourcesController.getExistingResourcesForChangeOrRemoval(mapUserInputs, new List<String>());
            List<SSP_ResourcesWrapper> lstResWrapper = (List<SSP_ResourcesWrapper>) JSON.deserialize(String.valueOf((clsResponse.mapResponse).get('ExistingResources')), List<SSP_ResourcesWrapper>.class);
            
            String strUpdatedValues = '[{"Id":"'+lstAssets[0].Id+'","IsDeleted__c": true,"PreFuneralAgmtGoodsAndServicesCost__c":"657.12"}]';
            SSP_LightningResponse clsResponse2 = SSP_ExistResourcesController.updateExistingResources(strUpdatedValues, lstMembers[0].Id);
        }
    }

    @isTest
    public static void testResourcesSelectionController(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id,HasOwnBankAccountToggle__c,HasVehicleToggle__c,HasLifeInsuranceToggle__c,HasInvestmentsToggle__c,HasRealEstatePropertyToggle__c,
                                                                HasPreArrangedFuneralContractToggle__c,HasCashReloadableMoneyCardToggle__c FROM SSP_Member__c];
        List<SSP_Asset__c> lstAssets = [SELECT Id, ResourceTypeCode__c FROM SSP_Asset__c WHERE ResourceTypeCode__c = 'VI' LIMIT 1];
        System.runAs(fetchCitizenUser()){
            Map<String,String> mapUserInputs = new Map<String,String>();
            mapUserInputs.put('applicationId', lstApplications[0].Id);
            mapUserInputs.put('memberId', lstMembers[0].Id);
            SSP_LightningResponse clsResponse = SSP_ResourcesSelectionController.getResourcesSelectionDetails(mapUserInputs,'');
            System.assertEquals(clsResponse.bIsSuccess, true);

            SSP_LightningResponse clsOtherResourceSelectionResponse = SSP_ResourcesSelectionController.getOtherResourceSelectionDetails(lstApplications[0].Id);
            System.assertEquals(clsOtherResourceSelectionResponse.bIsSuccess, true);
        }

        System.runAs(fetchCitizenUser()){
            SSP_LightningResponse clsOtherResourceSelectionResponse = SSP_ResourcesSelectionController.getOtherResourceSelectionDetails('122323233');
        }

        System.runAs(fetchCitizenUser()){
            String strResSelectionJSON = '[{"strObject":"SSP_Application__c","strObjectRecords":"'+lstApplications[0].Id+'","strQuestionValue":null,"strField":"IsAssetsInExcess1MToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"Y","strField":"HasOwnBankAccountToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"N","strField":"HasInvestmentsToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"Y","strField":"HasCashReloadableMoneyCardToggle__c"}]';
            SSP_LightningResponse clsResponse = SSP_ResourcesSelectionController.updateResourcesSelectionDetails(strResSelectionJSON,lstApplications[0].Id);
            System.assertEquals(clsResponse.bIsSuccess, true);
        }

        System.runAs(fetchCitizenUser()){
            String strResSelectionJSON = '[{"strObject":"SSP_Application__c","strObjectRecords":"'+lstApplications[0].Id+'","strQuestionValue":null,"strField":"IsAssetsInExcess1MToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"Y","strField":"HasOwnBankAccountToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"N","strField":"HasInvestmentsToggle__c"},{"strObject":"SSP_Member__c","strObjectRecords":"'+lstMembers[0].Id+'","strQuestionValue":"Y","strField":"HasCashReloadableMoneyCardToggle__c"}]';
            SSP_LightningResponse clsResponse = SSP_ResourcesSelectionController.updateResourcesSelectionDetails(strResSelectionJSON,'1223222323');
        }
    }

    @isTest
    public static void testResourcesSummaryQueueRule(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, IsHeadOfHousehold__c,MedicaidType__c, SSP_Member__r.HasOwnBankAccountToggle__c, SSP_Member__r.HasVehicleToggle__c,
                                                                SSP_Member__r.HasLifeInsuranceToggle__c,SSP_Member__r.HasInvestmentsToggle__c,SSP_Member__r.HasRealEstatePropertyToggle__c,
                                                                SSP_Member__r.HasPreArrangedFuneralContractToggle__c,SSP_Member__r.HasCashReloadableMoneyCardToggle__c,
                                                                SSP_Application__r.HasAnnuityToggle__c,SSP_Application__r.HasBurialFundToggle__c,SSP_Application__r.HasPromissoryNoteOrLandContractToggle__c,
                                                                SSP_Application__r.HasBurialPlotsToggle__c,SSP_Application__r.HasLifeEstateToggle__c,SSP_Application__r.HasLifeSettlementContractToggle__c,
                                                                SSP_Application__r.HasSpecialNeedTrustToggle__c,SSP_Application__r.HasLTCAgreementToggle__c,SSP_Application__r.HasOtherResourceToggle__c,
                                                                SSP_Application__r.HasPartnershipQualifiedLTCPolicyToggle__c,SSP_Application__r.IsAssetsInExcess1MToggle__c
                                                                FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        List<SSP_ApplicationIndividual__c> lstAppIndividualsOne = [SELECT Id, ProgramsApplied__c,SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];

        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>();

        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = lstMembers[0].Id;
        ctxData.ApplicationId = lstApplications[0].Id;
        
        for(SSP_ApplicationIndividual__c sspAppIndividual:lstAppIndividuals){
            memberAppIndividualMap.put(sspAppIndividual.SSP_Member__c, sspAppIndividual);
        }

        Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String, List<SSP_Asset__c>>();
        Set<Id> setMemberIds = new Set<Id>();
        setMemberIds.add(lstMembers[0].Id);
        for(SSP_Asset__c sspAsset: SSP_ResourcesService.getResourcesForMember(setMemberIds, true, new List<String>())){
            if(mapMemberAsset.get(sspAsset.SSP_Member__c) != null){
                mapMemberAsset.get(sspAsset.SSP_Member__c).add(sspAsset);
            } else{
                List<SSP_Asset__c> lstMemberAssets = new List<SSP_Asset__c>();
                lstMemberAssets.add(sspAsset);
                mapMemberAsset.put(sspAsset.SSP_Member__c, lstMemberAssets);
            }
        }

        QueuingWrapper qWrapper = new QueuingWrapper();
        qWrapper.memberAppIndividualMap = memberAppIndividualMap;    
        qWrapper.mapMemberAsset = mapMemberAsset;
        ctxData.queueobject = qWrapper;

        System.runAs(fetchCitizenUser()){
            SSP_ResourceSummaryQueueRule sspResSummaryRule = new SSP_ResourceSummaryQueueRule();
            Boolean bRequired = sspResSummaryRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, true);
        }  

        for(SSP_ApplicationIndividual__c sspAppIndividual:lstAppIndividualsOne){
            memberAppIndividualMap.put(sspAppIndividual.SSP_Member__c, sspAppIndividual);
        }
        qWrapper.memberAppIndividualMap = memberAppIndividualMap; 
        System.runAs(fetchCitizenUser()){
            SSP_ResourceSummaryQueueRule sspResSummaryRule = new SSP_ResourceSummaryQueueRule();
            Boolean bRequired = sspResSummaryRule.isRequired(ctx,ctxData);

            SSP_ResourcesService.isNONMagiApplication('1232233');
        }  
    }

    @isTest
    public static void testResourcesSelectionQueueRule(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, MedicaidType__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        List<SSP_Asset__c> lstAssets = new List<SSP_Asset__c>();
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = lstMembers[0].Id;
        ctxData.ApplicationId = lstApplications[0].Id;
        
        Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String, List<SSP_Asset__c>>();
        Set<Id> setMemberIds = new Set<Id>();
        setMemberIds.add(lstMembers[0].Id);
        for(SSP_Asset__c sspAsset: SSP_ResourcesService.getResourcesForMember(setMemberIds, true, new List<String>())){
            if(mapMemberAsset.get(sspAsset.SSP_Member__c) != null){
                mapMemberAsset.get(sspAsset.SSP_Member__c).add(sspAsset);
            } else{
                List<SSP_Asset__c> lstMemberAssets = new List<SSP_Asset__c>();
                lstMemberAssets.add(sspAsset);
                mapMemberAsset.put(sspAsset.SSP_Member__c, lstMemberAssets);
            }
        }

        QueuingWrapper qWrapper = new QueuingWrapper();
        qWrapper.applicationIndividualList = lstAppIndividuals;
        qWrapper.mapMemberAsset = mapMemberAsset;
        ctxData.queueobject = qWrapper;
        System.runAs(fetchCitizenUser()){
            SSP_ResourcesSelectionScreenQueueRule sspResRule = new SSP_ResourcesSelectionScreenQueueRule();
            Boolean bRequired = sspResRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, true);
        } 
    }

    @isTest
    public static void testOtherResourcesSelectionQueueRule(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, MedicaidType__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        List<SSP_ApplicationIndividual__c> lstAppIndividualsOne = [SELECT Id, ProgramsApplied__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
    
        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = lstMembers[0].Id;
        ctxData.ApplicationId = lstApplications[0].Id;
        
        QueuingWrapper qWrapper = new QueuingWrapper();
        ctxData.queueobject = qWrapper;
        qWrapper.applicationIndividualList = lstAppIndividuals;
        System.runAs(fetchCitizenUser()){
            SSP_OtherResSelectionScreenQueueRule sspOtherResRule = new SSP_OtherResSelectionScreenQueueRule();
            Boolean bRequired = sspOtherResRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, true);
        }

        qWrapper.applicationIndividualList = lstAppIndividualsOne;
        System.runAs(fetchCitizenUser()){
            SSP_OtherResSelectionScreenQueueRule sspOtherResRule = new SSP_OtherResSelectionScreenQueueRule();
            Boolean bRequired = sspOtherResRule.isRequired(ctx,ctxData);
        }  
    } 

    @isTest
    public static void testResourcesQueueRule(){
        List<SSP_Application__c> lstApplications = [SELECT Id FROM SSP_Application__c];
        List<SSP_Member__c> lstMembers = [SELECT Id FROM SSP_Member__c ORDER BY Id LIMIT 1];
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = [SELECT Id, ProgramsApplied__c, MedicaidType__c, SSP_Member__c FROM SSP_ApplicationIndividual__c WHERE SSP_Application__c = :lstApplications[0].Id];
        Map<String,SSP_ApplicationIndividual__c> memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>();

        Context ctx = new Context();
        ContextData ctxData = new ContextData();
        ctxData.MemberId = lstMembers[0].Id;
        ctxData.ApplicationId = lstApplications[0].Id;
        
        for(SSP_ApplicationIndividual__c sspAppIndividual:lstAppIndividuals){
            memberAppIndividualMap.put(sspAppIndividual.SSP_Member__c, sspAppIndividual);
        }

        Map<String,List<SSP_Asset__c>> mapMemberAsset = new Map<String, List<SSP_Asset__c>>();
        Set<Id> setMemberIds = new Set<Id>();
        setMemberIds.add(lstMembers[0].Id);
        for(SSP_Asset__c sspAsset: SSP_ResourcesService.getResourcesForMember(setMemberIds, true, new List<String>())){
            if(mapMemberAsset.get(sspAsset.SSP_Member__c) != null){
                mapMemberAsset.get(sspAsset.SSP_Member__c).add(sspAsset);
            } else{
                List<SSP_Asset__c> lstMemberAssets = new List<SSP_Asset__c>();
                lstMemberAssets.add(sspAsset);
                mapMemberAsset.put(sspAsset.SSP_Member__c, lstMemberAssets);
            }
        }

        QueuingWrapper qWrapper = new QueuingWrapper();
        qWrapper.memberAppIndividualMap = memberAppIndividualMap;
        qWrapper.mapMemberAsset = mapMemberAsset;
        ctxData.queueobject = qWrapper;
        System.runAs(fetchCitizenUser()){
            SSP_ResourcesScreenQueueRule sspResRule = new SSP_ResourcesScreenQueueRule();
            Boolean bRequired = sspResRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, true);
        }  

        qWrapper.memberAppIndividualMap = new Map<String, SSP_ApplicationIndividual__c>(); 
        System.runAs(fetchCitizenUser()){
            SSP_ResourcesScreenQueueRule sspResRule = new SSP_ResourcesScreenQueueRule();
            Boolean bRequired = sspResRule.isRequired(ctx,ctxData);
            System.assertEquals(bRequired, false);
        }   
    }
}