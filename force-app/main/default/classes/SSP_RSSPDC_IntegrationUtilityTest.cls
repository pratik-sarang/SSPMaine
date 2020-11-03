/*
* Classname     :  SSP_RSSPDC_IntegrationUtilityTest
* @description  :  This class is the test class of SSP_RSSPDC_IntegrationUtility
* @author       :  Ragunathan
* @date         :  04/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          04/06/2020            Initial Creation
**/
@isTest
public class SSP_RSSPDC_IntegrationUtilityTest {
    @isTest
    static void shouldPerformDMLonProcessedData(){
        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;
        	objAppl.recordTypeId=Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();

        insert objAppl;

        Contact con = createContact('999033137');
        con.AccountId = acc.Id;

        update con;
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = acc.Id,
            ContactId = con.Id,
            DCACRId__c = 'ASSISTER,008,764763'
        ); 
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;
        //Request
        SSP_RSSPDC_RequestWrapper objReq = new SSP_RSSPDC_RequestWrapper();
        objReq.viewName = 'TestName';
        objReq.primaryApplicationIndividualId = '999033177';
        objReq.applicationID = objAppl.Id;
        //SSP_ApplicationIndividual__c
        SSP_ApplicationIndividual__c applIndiv = new SSP_ApplicationIndividual__c(
            ProgramsApplied__c='MA',
            MedicaidType__c='MAGI',
            SSP_Member__c = objMem.Id
        );

        String insurancePolicyTestData =    '  [       {  '  + 
                                            '           "DCId__c": "5663",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "29309",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         },  ' +
                                            '   {  '  + 
                                            '           "DCId__c": "5667",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "297609",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         }  ]'; 
        String insuCoveredIndivTestData =    '   {  '  + 
                                            '     "SSP_InsurancePolicy__r": {  '  + 
                                            '       "DCId__c": "5663"  '  + 
                                            '     },  '  + 
                                            '     "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '     "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '     "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '     "DCId__c": 114,  '  + 
                                            '     "RecordType": {  '  + 
                                            '       "Name": "Insurance External Policy Holder"  '  + 
                                            '     },  '  + 
                                            '     "DCInsuranceCoveredIndivId__c": "5663,114,0"  '  + 
                                            '  }  ' ; 
        List<SSP_InsurancePolicy__c> insCovIndiv = (List<SSP_InsurancePolicy__c>) JSON.deserialize(insurancePolicyTestData, List<SSP_InsurancePolicy__c>.class);
        insert insCovIndiv;
        SSP_InsuranceCoveredIndiv__c insCovIndivs = (SSP_InsuranceCoveredIndiv__c) JSON.deserialize(insuCoveredIndivTestData, SSP_InsuranceCoveredIndiv__c.class);
        insert insCovIndivs;
        
        Map<String, List<sObject>> mapsObjects = new Map<String, List<sObject>>();
        mapsObjects.put(SSP_InterfaceConstants.SSP_Member, (List<SSP_Member__c>)JSON.deserialize(sSSP_Member, List<SSP_Member__c>.class));
        mapsObjects.put('SSP_Asset__c', (List<SSP_Asset__c>)JSON.deserialize(sSSP_Asset, List<SSP_Asset__c>.class));
        mapsObjects.put('SSP_HealthInsuranceFacilityType__c', (List<SSP_HealthInsuranceFacilityType__c>)JSON.deserialize(healthFacilityType, List<SSP_HealthInsuranceFacilityType__c>.class));
        mapsObjects.put('SSP_Attendance__c', (List<SSP_Attendance__c>)JSON.deserialize(sSSP_Attendance, List<SSP_Attendance__c>.class));
        mapsObjects.put('SSP_Benefits__c', (List<SSP_Benefits__c>)JSON.deserialize(sSSP_Benefits, List<SSP_Benefits__c>.class));
        mapsObjects.put('SSP_InsuranceCoveredIndiv__c', (List<SSP_InsuranceCoveredIndiv__c>)JSON.deserialize(sSSP_InsuranceCovIndiv, List<SSP_InsuranceCoveredIndiv__c>.class));
        mapsObjects.put('SSP_NonCustodialParent__c', (List<SSP_NonCustodialParent__c>)JSON.deserialize(sSSP_NonCustodialParent, List<SSP_NonCustodialParent__c>.class));
        mapsObjects.put('SSP_NonCustodialRelationship__c', (List<SSP_NonCustodialRelationship__c>)JSON.deserialize(sSSP_NonCustodialParentRelationShip, List<SSP_NonCustodialRelationship__c>.class));
        mapsObjects.put('SSP_InsurancePolicy__c', (List<SSP_InsurancePolicy__c>)JSON.deserialize(sSSP_InsurancyPolicy, List<SSP_InsurancePolicy__c>.class));
        mapsObjects.put('SSP_AlienSponsor__c', (List<SSP_AlienSponsor__c>)JSON.deserialize(sSSP_AlienSponsor, List<SSP_AlienSponsor__c>.class));
        mapsObjects.put('AccountContactRelation', (List<AccountContactRelation>)JSON.deserialize(sACR, List<AccountContactRelation>.class));
        mapsObjects.put('SSP_ApplicationIndividual__c', (List<SSP_ApplicationIndividual__c>)JSON.deserialize(sSSP_ApplIndiv, List<SSP_ApplicationIndividual__c>.class));
        Contact conResponse = createContact('999033187');
        conResponse.DCACRId__c = '345678';
        update conResponse;
        List<Contact> contactResponses = new List<Contact>();
        contactResponses.add(conResponse);
        contactResponses.addAll( (List<Contact>)JSON.deserialize(sContact, List<Contact>.class) );
        mapsObjects.put('Contact', contactResponses);
        List<RSSP_DC_JSON_Object_Mapping__mdt> objMapping = [Select 
                                                             External_Id__c, 
                                                             SF_Object_Name__c 
                                                             From RSSP_DC_JSON_Object_Mapping__mdt];
        SSP_RSSPDC_IntegrationHandler dmlUtility = new SSP_RSSPDC_IntegrationHandler();
        Test.startTest();
        dmlUtility.performDMLonProcessedData(objReq, mapsObjects, objMapping);
        Test.stopTest();
        System.assertEquals('999033177', objMem.IndividualId__c);
    }
    @isTest
    static void shouldPerformDMLonProcessedDataForApplication(){
        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;
        	objAppl.recordTypeId=Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get('SSP_Application').getRecordTypeId();

        insert objAppl;

        Contact con = createContact('999033137');
        con.AccountId = acc.Id; 
        con.DCACRId__c = 'MANUAL AUTHORIZED REPRESENTATIVE,008,764763';
        con.IsManualAuthRep__c = true;

        update con;
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = acc.Id,
            ContactId = con.Id,
            DCACRId__c = 'MANUAL AUTHORIZED REPRESENTATIVE,008,764763'
        ); 
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;
        //Request
        SSP_RSSPDC_RequestWrapper objReq = new SSP_RSSPDC_RequestWrapper();
        objReq.viewName = 'Test View';
        objReq.primaryApplicationIndividualId = '999033177';
        objReq.applicationID = objAppl.Id;
        //SSP_ApplicationIndividual__c
        SSP_ApplicationIndividual__c applIndiv = new SSP_ApplicationIndividual__c(
            ProgramsApplied__c='MA',
            MedicaidType__c='MAGI',
            SSP_Member__c = objMem.Id
        );

        Contact_Mapping__c conMap = new Contact_Mapping__c (Contact__c = con.Id, IEES_Id__c = 999033177);
        insert conMap;
        String insurancePolicyTestData =    '  [       {  '  + 
                                            '           "DCId__c": "5663",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "29309",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         },  ' +
                                            '   {  '  + 
                                            '           "DCId__c": "5667",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "297609",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         }  ]'; 
        String insuCoveredIndivTestData =    '   {  '  + 
                                            '     "SSP_InsurancePolicy__r": {  '  + 
                                            '       "DCId__c": "5663"  '  + 
                                            '     },  '  + 
                                            '     "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '     "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '     "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '     "DCId__c": 114,  '  + 
                                            '     "RecordType": {  '  + 
                                            '       "Name": "Insurance External Policy Holder"  '  + 
                                            '     },  '  + 
                                            '     "DCInsuranceCoveredIndivId__c": "5663,114,0"  '  + 
                                            '  }  ' ; 
        List<SSP_InsurancePolicy__c> insCovIndiv = (List<SSP_InsurancePolicy__c>) JSON.deserialize(insurancePolicyTestData, List<SSP_InsurancePolicy__c>.class);
        insert insCovIndiv;
        SSP_InsuranceCoveredIndiv__c insCovIndivs = (SSP_InsuranceCoveredIndiv__c) JSON.deserialize(insuCoveredIndivTestData, SSP_InsuranceCoveredIndiv__c.class);
        insert insCovIndivs;
        
        Map<String, List<sObject>> mapsObjects = new Map<String, List<sObject>>();
        mapsObjects.put(SSP_InterfaceConstants.SSP_Member, (List<SSP_Member__c>)JSON.deserialize(sSSP_Member, List<SSP_Member__c>.class));
        mapsObjects.put('SSP_Asset__c', (List<SSP_Asset__c>)JSON.deserialize(sSSP_Asset, List<SSP_Asset__c>.class));
        mapsObjects.put('SSP_HealthInsuranceFacilityType__c', (List<SSP_HealthInsuranceFacilityType__c>)JSON.deserialize(healthFacilityType, List<SSP_HealthInsuranceFacilityType__c>.class));
        mapsObjects.put('SSP_Attendance__c', (List<SSP_Attendance__c>)JSON.deserialize(sSSP_Attendance, List<SSP_Attendance__c>.class));
        mapsObjects.put('SSP_Benefits__c', (List<SSP_Benefits__c>)JSON.deserialize(sSSP_Benefits, List<SSP_Benefits__c>.class));
        mapsObjects.put('SSP_InsuranceCoveredIndiv__c', (List<SSP_InsuranceCoveredIndiv__c>)JSON.deserialize(sSSP_InsuranceCovIndiv, List<SSP_InsuranceCoveredIndiv__c>.class));
        mapsObjects.put('SSP_NonCustodialParent__c', (List<SSP_NonCustodialParent__c>)JSON.deserialize(sSSP_NonCustodialParent, List<SSP_NonCustodialParent__c>.class));
        mapsObjects.put('SSP_InsurancePolicy__c', (List<SSP_InsurancePolicy__c>)JSON.deserialize(sSSP_InsurancyPolicy, List<SSP_InsurancePolicy__c>.class));
        mapsObjects.put('SSP_AlienSponsor__c', (List<SSP_AlienSponsor__c>)JSON.deserialize(sSSP_AlienSponsor, List<SSP_AlienSponsor__c>.class));
        mapsObjects.put('AccountContactRelation', (List<AccountContactRelation>)JSON.deserialize(sACR, List<AccountContactRelation>.class));
        mapsObjects.put('SSP_ApplicationIndividual__c', (List<SSP_ApplicationIndividual__c>)JSON.deserialize(sSSP_ApplIndiv, List<SSP_ApplicationIndividual__c>.class));
        mapsObjects.put('SSP_Relationship__c', (List<SSP_Relationship__c>)JSON.deserialize(sRelationship, List<SSP_Relationship__c>.class));
        mapsObjects.put('SSP_Notifications__c', (List<SSP_Notifications__c>)JSON.deserialize(sSSPNotification, List<SSP_Notifications__c>.class));
        Contact conResponse = createContact('999033187');
        conResponse.DCACRId__c = '345678';
        update conResponse;
        List<Contact> contactResponses = new List<Contact>();
        contactResponses.add(conResponse);
        contactResponses.addAll( (List<Contact>)JSON.deserialize(sContact, List<Contact>.class) );
        mapsObjects.put('Contact', contactResponses);
        List<RSSP_DC_JSON_Object_Mapping__mdt> objMapping = [Select 
                                                             External_Id__c, 
                                                             SF_Object_Name__c 
                                                             From RSSP_DC_JSON_Object_Mapping__mdt];
        SSP_RSSPDC_IntegrationHandler dmlUtility = new SSP_RSSPDC_IntegrationHandler();
        Test.startTest();
        dmlUtility.performDMLonProcessedData(objReq, mapsObjects, objMapping);
        Test.stopTest();
        System.assertEquals('999033177', objMem.IndividualId__c);
    }
    @isTest
    static void shouldPerformDMLonProcessedDataForApplicationForOrgAuthRep(){
        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;
        	objAppl.recordTypeId=Schema.SObjectType.SSP_Application__c.getRecordTypeInfosByDeveloperName().get('SSP_Application').getRecordTypeId();

        insert objAppl;

        Contact con = createContact('999033137');
        con.AccountId = acc.Id; 
        con.DCACRId__c = 'MANUAL AUTHORIZED REPRESENTATIVE,008,764763';
        con.IsManualAuthRep__c = true;

        update con;
        AccountContactRelation acr = new AccountContactRelation(
            AccountId = acc.Id,
            ContactId = con.Id,
            DCACRId__c = 'MANUAL AUTHORIZED REPRESENTATIVE,008,764763'
        ); 
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;
        //Request
        SSP_RSSPDC_RequestWrapper objReq = new SSP_RSSPDC_RequestWrapper();
        objReq.viewName = SSP_InterfaceConstants.ONBOARD_INDV_AUTHREP;
        objReq.primaryApplicationIndividualId = '999033177';
        objReq.applicationID = objAppl.Id;
        //SSP_ApplicationIndividual__c
        SSP_ApplicationIndividual__c applIndiv = new SSP_ApplicationIndividual__c(
            ProgramsApplied__c='MA',
            MedicaidType__c='MAGI',
            SSP_Member__c = objMem.Id
        );

        Contact_Mapping__c conMap = new Contact_Mapping__c (Contact__c = con.Id, IEES_Id__c = 999033177);
        insert conMap;
        String insurancePolicyTestData =    '  [       {  '  + 
                                            '           "DCId__c": "5663",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "29309",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         },  ' +
                                            '   {  '  + 
                                            '           "DCId__c": "5667",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "297609",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         }  ]'; 
        String insuCoveredIndivTestData =    '   {  '  + 
                                            '     "SSP_InsurancePolicy__r": {  '  + 
                                            '       "DCId__c": "5663"  '  + 
                                            '     },  '  + 
                                            '     "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '     "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '     "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '     "DCId__c": 114,  '  + 
                                            '     "RecordType": {  '  + 
                                            '       "Name": "Insurance External Policy Holder"  '  + 
                                            '     },  '  + 
                                            '     "DCInsuranceCoveredIndivId__c": "5663,114,0"  '  + 
                                            '  }  ' ; 
        List<SSP_InsurancePolicy__c> insCovIndiv = (List<SSP_InsurancePolicy__c>) JSON.deserialize(insurancePolicyTestData, List<SSP_InsurancePolicy__c>.class);
        insert insCovIndiv;
        SSP_InsuranceCoveredIndiv__c insCovIndivs = (SSP_InsuranceCoveredIndiv__c) JSON.deserialize(insuCoveredIndivTestData, SSP_InsuranceCoveredIndiv__c.class);
        insert insCovIndivs;
        
        Map<String, List<sObject>> mapsObjects = new Map<String, List<sObject>>();
        mapsObjects.put(SSP_InterfaceConstants.SSP_Member, (List<SSP_Member__c>)JSON.deserialize(sSSP_Member, List<SSP_Member__c>.class));
        mapsObjects.put('SSP_Asset__c', (List<SSP_Asset__c>)JSON.deserialize(sSSP_Asset, List<SSP_Asset__c>.class));
        mapsObjects.put('SSP_HealthInsuranceFacilityType__c', (List<SSP_HealthInsuranceFacilityType__c>)JSON.deserialize(healthFacilityType, List<SSP_HealthInsuranceFacilityType__c>.class));
        mapsObjects.put('SSP_Attendance__c', (List<SSP_Attendance__c>)JSON.deserialize(sSSP_Attendance, List<SSP_Attendance__c>.class));
        mapsObjects.put('SSP_Benefits__c', (List<SSP_Benefits__c>)JSON.deserialize(sSSP_Benefits, List<SSP_Benefits__c>.class));
        mapsObjects.put('SSP_InsuranceCoveredIndiv__c', (List<SSP_InsuranceCoveredIndiv__c>)JSON.deserialize(sSSP_InsuranceCovIndiv, List<SSP_InsuranceCoveredIndiv__c>.class));
        mapsObjects.put('SSP_NonCustodialParent__c', (List<SSP_NonCustodialParent__c>)JSON.deserialize(sSSP_NonCustodialParent, List<SSP_NonCustodialParent__c>.class));
        mapsObjects.put('SSP_InsurancePolicy__c', (List<SSP_InsurancePolicy__c>)JSON.deserialize(sSSP_InsurancyPolicy, List<SSP_InsurancePolicy__c>.class));
        mapsObjects.put('SSP_AlienSponsor__c', (List<SSP_AlienSponsor__c>)JSON.deserialize(sSSP_AlienSponsor, List<SSP_AlienSponsor__c>.class));
        mapsObjects.put('AccountContactRelation', (List<AccountContactRelation>)JSON.deserialize(sACR, List<AccountContactRelation>.class));
        mapsObjects.put('SSP_ApplicationIndividual__c', (List<SSP_ApplicationIndividual__c>)JSON.deserialize(sSSP_ApplIndiv, List<SSP_ApplicationIndividual__c>.class));
        mapsObjects.put('SSP_Relationship__c', (List<SSP_Relationship__c>)JSON.deserialize(sRelationship, List<SSP_Relationship__c>.class));
        mapsObjects.put('SSP_Notifications__c', (List<SSP_Notifications__c>)JSON.deserialize(sSSPNotification, List<SSP_Notifications__c>.class));
        Contact conResponse = createContact('999033187');
        conResponse.DCACRId__c = '345678';
        update conResponse;
        List<Contact> contactResponses = new List<Contact>();
        contactResponses.add(conResponse);
        contactResponses.addAll( (List<Contact>)JSON.deserialize(sContact, List<Contact>.class) );
        mapsObjects.put('Contact', contactResponses);
        List<RSSP_DC_JSON_Object_Mapping__mdt> objMapping = [Select 
                                                             External_Id__c, 
                                                             SF_Object_Name__c 
                                                             From RSSP_DC_JSON_Object_Mapping__mdt];
        SSP_RSSPDC_IntegrationHandler dmlUtility = new SSP_RSSPDC_IntegrationHandler();
        Test.startTest();
        dmlUtility.performDMLonProcessedData(objReq, mapsObjects, objMapping);
        Test.stopTest();
        System.assertEquals('999033177', objMem.IndividualId__c);
    }
    @isTest
    static void shouldUpsertAccount() {
        SSP_RSSPDC_IntegrationDMLUtility dmlUtility = new SSP_RSSPDC_IntegrationDMLUtility();
        dmlUtility.upsertAccounts( new List<Account> { new Account(Name = 'testAccount')});
    }
    @isTest
    static void shouldResetMembers() {
        Contact con = createContact('999033177');
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;

        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;
        insert objAppl;

        SSP_RSSPDC_IntegrationDMLUtility dmlUtility = new SSP_RSSPDC_IntegrationDMLUtility();
        dmlUtility.resetMembers(new List<SSP_Member__c> {objMem}, (String)objAppl.Id, SSP_InterfaceConstants.MODE_RAC);
        System.assertEquals('999033177', objMem.IndividualId__c);
    } 

    @isTest
    static void shouldDeleteChildRecs() {
        Contact con = createContact('999033177');
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;

        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;
        insert objAppl;

        SSP_RSSPDC_IntegrationDMLUtility dmlUtility = new SSP_RSSPDC_IntegrationDMLUtility();
		dmlUtility.deleteChildRecs(new List<SSP_Member__c> {objMem}, objAppl.Id);
        System.assertEquals('999033177', objMem.IndividualId__c);
    }
    @isTest
    static void shouldUpdateTransactionStatus() {

        LOG_LogMessage__c log = new LOG_LogMessage__c(
            LOG_Source__c = 'SSPService',
            LOG_Source_Function__c  = 'invokeMethod'
        );
        insert log;
        SSP_RSSPDCWrapper objWrapper = new SSP_RSSPDCWrapper();
        objWrapper.objUser = [SELECT Id, contactId from User WHERE Id =:UserInfo.getUserId()];
        objWrapper.objRequest.primaryApplicationIndividualId = '123456';
        objWrapper.lstAllViews = new List<String> {'TestView'};
        objWrapper.objRequest.applicationID = '23456789';
        objWrapper.objRequest.caseNumber = 875456;
        objWrapper.objRequest.mode = 'RAC';
        SSP_Transaction__c trans = new SSP_Transaction__c(
            Unique_Id__c = String.valueOf(objWrapper.objRequest.primaryApplicationIndividualId)+
            SSP_InterfaceConstants.OPERATOR_SEMICOLON+'TestView',
            Log_Message__c = null,
            ApplicationId__c = objWrapper.objRequest.applicationID,
            CaseNumber__c = String.valueof(objWrapper.objRequest.caseNumber),
            IndividualId__c = String.valueOf(objWrapper.objRequest.primaryApplicationIndividualId),
            Mode__c = objWrapper.objRequest.mode,
            View_Name__c = 'TestView',
            status__c = SSP_InterfaceConstants.PENDING
        );

        insert trans;

        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        dmlUtility.updateTransactionStatus(objWrapper, SSP_InterfaceConstants.PENDING);
        dmlUtility.updateTransactionStatus(objWrapper, SSP_InterfaceConstants.SUCCESS);
        dmlUtility.updateTransactionStatus(objWrapper, SSP_InterfaceConstants.FAILED);
        dmlUtility.updateTransactionStatus(objWrapper, SSP_InterfaceConstants.RETRY);
        System.assertEquals('TestView', trans.View_Name__c);
    }
    @isTest
    static void shouldUpdateAssets() {
        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.Account__c = acc.Id;
        insert objAppl;
        Contact con = createContact('999033177');
        Contact con2 = createContact('9990333477');
        SSP_Member__c objMem = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '999033177',
            Contact__c = con.Id);
        insert objMem;
        
        SSP_Member__c objMem1 = new SSP_Member__c(
            FirstName__c='Firsttest',
            LastName__c='LastTest',
            IndividualId__c = '9990333477',
            Contact__c = con2.Id);
        insert objMem1;


        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SSP_Asset__c.fields.getMap();
        SSP_Asset__c parentAsset =new SSP_Asset__c(
            BusinessTypeCode__c ='SF',
            EmployerName__c ='ABC Consulting Ltd',
            DCAssetId__c = 'extID456789',
            SSP_Member__c = objMem.Id
        );
        insert parentAsset;
        SSP_Asset__c asset =new SSP_Asset__c(
            BusinessTypeCode__c ='SF',
            EmployerName__c ='ABC Consulting Ltd',
            DCAssetId__c = 'extID456729',
            InsurancePolicyAsset__c = parentAsset.Id,
            SSP_Member__c = objMem1.Id
        );
        insert asset;

        SSP_RSSPDC_IntegrationDMLUtility dmlUtility = new SSP_RSSPDC_IntegrationDMLUtility();
        dmlUtility.upsertAssets(new List<SSP_Asset__c>{asset, parentAsset}, fieldMap.get('DCAssetId__c'), objAppl.Id);
        System.assertEquals('999033177', objMem.IndividualId__c);
    }
    @isTest
    private static void updateApplication() {
        Account acc = new Account(Name='test account');
        insert acc;
        SSP_Application__c objAppl = new SSP_Application__c();
            objAppl.ProgramsApplied__c='MA';
            objAppl.DCCaseNumber__c= 0;
            objAppl.TransactionId__c='';
            objAppl.HouseholdTotalMonthlyCashSavingAmount__c=11;
            objAppl.HouseholdTotalMonthlyGrossIncAmount__c=11;
            objAppl.ApplicationEsignFirstName__c='';
            objAppl.ApplicationEsignMiddleInitial__c='';
            objAppl.ApplicationEsignLastName__c='';
            objAppl.ApplicationEsignSuffixCode__c='';
            objAppl.Account__c = acc.Id;

        insert objAppl;
        SSP_RSSPDC_IntegrationDMLUtility dmlUtility = new SSP_RSSPDC_IntegrationDMLUtility();
        dmlUtility.updateApplication(new List<SSP_Application__c>{objAppl}, objAppl.Id);
        System.assertEquals(acc.Id, objAppl.Account__c);
    }
    @isTest
    private static void shouldUpdateRSSPDCTimeStamp() {
        Contact con = createContact('90333477');
        con.Last_RSSPDC_DateTime__c = '10-09-2020 12:23:00';
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        dmlUtility.updateRSSPDCTimeStamp('90333477', SSP_InterfaceConstants.MODE_INTAKE);
        dmlUtility.updateRSSPDCTimeStamp('90333477', SSP_InterfaceConstants.MODE_RAC);
        Contact updatedConRAC = [Select Last_RSSPDC_DateTime__c, Is_Eligible_For_RSSPDC__c from Contact where Id =: con.Id];
        System.assertEquals(null, updatedConRAC.Last_RSSPDC_DateTime__c, 'Check whether the contact updates correctly');
        System.assertEquals(false, updatedConRAC.Is_Eligible_For_RSSPDC__c, 'Check whether the contact updates correctly');
    }
    @isTest
    private static void shouldProcessResponseData() {
        RSSP_DC_JSON_Object_Mapping__mdt objMapping = [Select 
                                                        External_Id__c, 
                                                        SF_Object_Name__c 
                                                        From RSSP_DC_JSON_Object_Mapping__mdt 
                                                            Where SF_Object_Name__c = 'SSP_Member__c' limit 1];
        Map<String, List<sObject>> mapsObjects = new Map<String, List<sObject>>();
        mapsObjects.put(SSP_InterfaceConstants.SSP_Member, (List<SSP_Member__c>)JSON.deserialize(sSSP_Member, List<SSP_Member__c>.class));
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        Map<String, List<sObject>> result = dmlUtility.processResponseData((List<Object>)mapsObjects.get(SSP_InterfaceConstants.SSP_Member), objMapping, mapsObjects);
        System.assertNotEquals(null, result);
    }
    @isTest
    private static void shouldGetSequentailObjectList() {
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        List<RSSP_DC_JSON_Object_Mapping__mdt> result = dmlUtility.getSequentailObjectList(new set<String> {'SSP_Member__c'});
        System.assertEquals('SSP_Member__c', result[0].SF_Object_Name__c, 'Check the correct entry');
    }
    @isTest
    private static void shouldSetQaulaifiedIndividuals() {
        Map<String, List<sObject>> mapsObjects = new Map<String, List<sObject>>();
        mapsObjects.put(SSP_InterfaceConstants.SSP_Member, (List<SSP_Member__c>)JSON.deserialize(sSSP_Member, List<SSP_Member__c>.class));

        String indivIds = SSP_RSSPDC_IntegrationUtility.setQaulaifiedIndividuals(SSP_InterfaceConstants.QUALIFIED_INDIVIDUAL, 
                                                (Object)mapsObjects);
        System.assertEquals(false, String.isBlank(indivIds));
    }
    @isTest
    private static void shouldGetWrapperResponse() {
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.ELIGIBILITY_SUMMARY);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.KHIPP_PAYMENT_SUMMARY);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.BENEFIT_INFORMATION);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.MEDICAID_MCO_INFORMATION);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.DASHBOARD_CASE_INFORMATION);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.RAC_SELECTION_DETAILS);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.RFI_DETAILS);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.DISQUALIFICATION_DETAILS);
        dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), SSP_InterfaceConstants.PAST_APPLICATIONS);
        RSSP_DC_Wrapper wrappr = dmlUtility.getWrapperResponse(new RSSP_DC_Wrapper(), new Map<String, Object>(), 'test');
        System.assertNotEquals(null, wrappr);
    }
    @isTest
    private static void shouldGetRequestedMappingRecords() {
        SSP_RSSPDC_RequestWrapper req = new SSP_RSSPDC_RequestWrapper();
        req.viewName = SSP_InterfaceConstants.All_Views;
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        List<ReverseSSPViewMapping__mdt> mappingMdt = dmlUtility.getRequestedMappingRecords(req);
        req.viewName = 'IncomeInformation';
        req.mode = SSP_InterfaceConstants.MODE_INTAKE;
        List<ReverseSSPViewMapping__mdt> mappingMdtIntake = dmlUtility.getRequestedMappingRecords(req);
        List<ReverseSSPViewMapping__mdt> mappingMdtRAC = dmlUtility.getRequestedMappingRecords(new SSP_RSSPDC_RequestWrapper());
        System.assertNotEquals(null, mappingMdt, 'Query should build successfully');
    }
    @isTest
    private static void shouldGetFormattedJsonDataMap() {
        String cont = ' { "Contact" : { '+
            '  "FirstName" : "TestName"   '+
            '   }   }';
        Map<String, Object> mapObj = (Map<String, Object>)JSON.deserializeuntyped(cont);
        SSP_RSSPDC_IntegrationUtility dmlUtility = new SSP_RSSPDC_IntegrationUtility();
        Map<String, Object> result = dmlUtility.getFormattedJsonDataMap(mapObj);
        List<String> objNames = new List<String> (result.keySet()); 
        System.assertEquals('CONTACT', ObjNames[0], 'Check formatted sobject Name');
    }

    private static SSP_Transaction__c createTransactionWithStatus(String viewName, Id applicationId, String individualId) {
        
        SSP_Transaction__c transactionData = new SSP_Transaction__c(
            View_Name__c = viewName,
            IndividualId__c = individualId,
            ApplicationId__c = applicationId,
            CaseNumber__c = '123456',
            Mode__c = 'Intake',
            Status__c ='Failed'
        );
        
        insert transactionData;
        return transactionData;
    }

    private static Contact createContact(String indivId) {
        Contact con = new Contact(
            FirstName = 'Test Test con',
            LastName ='Test con ',
            IndividualId__c = indivId);
        insert con;

        return con;
    }
    static String sContact =    '   [  '  + 
                                '           {  '  + 
                                '               "FirstName" : "Test Test con",  '  + 
                                '               "LastName" : "Test con",  '  + 
                                '               "IndividualId__c" : "976543456",  '  + 
                                '               "DCACRId__c" : "456789"  '  + 
                                '           }  '  + 
                                '      ]  ' ;
    static String sSSPNotification = 			'	[  '  + 
                                                '         {  '  + 
                                                '           "Benefind_Id__c": "System Notification,652",  '  + 
                                                '           "messageSubject__c": "Authorized Representative Association",  '  + 
                                                '           "messageSubjectES__c": "test",  '  + 
                                                '           "notificationCode__c": "NOT-016",  '  + 
                                                '           "Notification_Body__c": "test test has been added as your Authorized Representative. You may remove this association by visiting the Reps, Assisters, &amp; Agents section from your Benefind dashboard or by calling DCBS at 1-855-306-8959.",  '  + 
                                                '           "Notification_Body_Es__c": "test test ha sido agregado como su representante autorizado. Usted puede eliminar esta asociaciÃ³n visitando la secciÃ³n Representantes, asistentes y agentes en su panel de Benefind o llamando a DCBS al 1-855-306-8959.",  '  + 
                                                '           "DueDate__c": "",  '  + 
                                                '           "Expiry_Date__c": "2020-06-23",  '  + 
                                                '           "RecordType": {  '  + 
                                                '             "Name": "System Notification"  '  + 
                                                '           } '+
        										'			}	] ';
    static String sResourceOwnership = '[  '  + 
                                        '         {  '  + 
                                        '           "DCResourceOwnershipDetailId__c": "1344",  '  + 
                                        '           "DCId__c": "2986",  '  + 
                                        '           "SSP_Member__r": {  '  + 
                                        '             "IndividualId__c": "999033177"  '  + 
                                        '           },  '  + 
                                        '           "JointOwnerName__c": null,  '  + 
                                        '           "SSP_Asset__r": {  '  + 
                                        '             "DCAssetId__c": "Resource,88572"  '  + 
                                        '           }  '  + 
                                        '         } ]  ';
    static String sRelationship = 		 '   [  '  + 
                                         '     {  '  + 
                                         '       "SSP_Member__r": {  '  + 
                                         '         "IndividualId__c": "999033177"  '  + 
                                         '       },  '  + 
                                         '       "SSP_MemberRelatedTo__r": {  '  + 
                                         '         "IndividualId__c": "999033177"  '  + 
                                         '       },  '  + 
                                         '       "DCId__c": "57107",  '  + 
                                         '       "RelationshipType__c": "UR",  '  + 
                                         '       "IsCareTakerToggle__c": "N",  '  + 
                                         '       "IsActingParentToggle__c": "N",  '  + 
                                         '       "IntendToPursueLegalCustodyToggle__c": "N"  '  + 
                                         '     }  '  + 
                                         '  ]  ' ; 
    static String sACR =    '   [  '  + 
                            '       {  '  + 
                            '         "RepresentativeRelationshipCode__c": "FM",  '  + 
                            '         "DCRepresentativeId__c": 7166,  '  + 
                            '         "PermissionLevel_SNAP__c": "SE",  '  + 
                            '         "ProgramsApplied__c": "SN",  '  + 
        					'		  "DCACRId__c" : "MANUAL AUTHORIZED REPRESENTATIVE,008,764763", '+
                            '         "ContactId": "003r000000LFhM8AAL"  '  + 
                            '       }  '  + 
                            '    ]  ' ; 
    static String sSSP_AlienSponsor =   ' [  {  '  + 
                                        '             "SSP_Member__r" : {  '  + 
                                        '              "IndividualId__c": "999033177"  '  + 
                                        '              },  '  + 
                                        '             "City__c": "Gotham",  ' + 
                                        '             "DCAlienSponsorId__c": 876543456  ' +
                                        '          }  ]' ; 

    static String sSSP_ApplIndiv =  ' [  {  '  + 
                                    '             "IsActiveIEESCasePresent__c": 1,  '  + 
                                    '             "SSP_Member__r" : {  '  + 
                                    '              "IndividualId__c": "999033177"  '  + 
                                    '              },  '  + 
                                    '             "BlockedCaseNumber__c": "100059260",  '  + 
                                    '             "isApplicationBlocked__c": 0,  '  + 
                                    '             "IsHeadOfHousehold__c": 1,  '  + 
                                    '             "ProgramsApplied__c": "KT;SN",  '  +  
                                    '             "DCPrograms__c": "MA"  '  + 
                                    '          }  ]' ; 
    static String sSSP_Asset =  '   [  '  + 
                                '           {  '  + 
                                '             "RecordType": {  '  + 
                                '               "Name" : "Income"  '  + 
                                '             },  '  + 
                                '             "SSP_Member__r": {  '  + 
                                '                 "IndividualId__c" : "999033177"  '  + 
                                '                 },  '  + 
                                '             "DCEmploymentDetailId__c": "29306",  '  + 
                                '             "DCId__c": "212558",  '  + 
                                '             "DCSelfEmploymentIncomeDetailId__c": 568587,  '  + 
                                '             "DCUnearnedIncomeDetailId__c": 5647334,  '  + 
                                '             "IncomeTypeCode__c": "DIR",  '  + 
                                '             "IncomeSubtypeCode__c": "IN",  '  + 
                                '             "EmployerName__c": "delook",  '  + 
                                '             "EIN__c": 76556,  '  + 
                                '             "EmployerAddress__c": "KLDFD",  '  + 
                                '             "EmployerAddressLine2__c": "DLFKJ",  '  + 
                                '             "PrimaryPhoneNumber__c": 987654321,  '  + 
                                '             "PrimaryPhoneExtension__c": "91",  '  + 
                                '             "BusinessTypeCode__c": "SF",  '  + 
                                '             "BusinessTitle__c": "Consultant",  '  + 
                                '             "ActivityType__c": "ST",  '  + 
                                '             "ActivityStartDate__c": "2019-10-01",  '  + 
                                '             "IsSchoolDegreeRequiredToggle__c": "N",  '  + 
                                '             "IsUnempBenefitsRequiredToggle__c": "Y",  '  + 
                                '             "IncomePayFrequency__c": "MO",  '  + 
                                '             "TotalGrossAmount__c": "844.00",  '  + 
                                '             "Tips__c": "4.00",  '  + 
                                '             "IncomePayDetailHoursPerWeek__c": "40",  '  + 
                                '             "ExpenseAmount__c": 789.45,  '  + 
                                '             "EndDate__c": "2020-10-01",  '  + 
                                '             "DCAssetId__c": "Resource,8852"  '  + 
                                '           }  '  + 
                                '        ]  ' ; 
    static String sSSP_InsuranceCovIndiv = '      [  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": null,  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5663"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": null,  '  + 
                                            '           "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '           "DCId__c": 114,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": null,  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": null,  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance External Policy Holder"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5663,114,0"  '  + 
                                            '         },  '  + 
                                            '         {  '  + 
                                            '           "InsuranceInternalPolicyHolder__c": 999033137,  '  + 
                                            '           "SSP_InsurancePolicy__r": {  '  + 
                                            '             "DCId__c": "5667"  '  + 
                                            '           },  '  + 
                                            '           "SSP_Member__r": null,  '  + 
                                            '           "ExtPolicyHolderFirstName__c": "EXTERNL",  '  + 
                                            '           "ExtPolicyHolderMiddleInitial__c": null,  '  + 
                                            '           "ExtPolicyHolderLastName__c": "PHOLDER",  '  + 
                                            '           "SuffixCode__c": null,  '  + 
                                            '           "ExtPolicyHolderSSN__c": "445458454",  '  + 
                                            '           "DCId__c": 114,  '  + 
                                            '           "IsTobbacoConsumerToggle__c": null,  '  + 
                                            '           "Gender__c": null,  '  + 
                                            '           "DateOfBirth__c": null,  '  + 
                                            '           "FirstName__c": null,  '  + 
                                            '           "LastName__c": null,  '  + 
                                            '           "MedicaidId__c": null,  '  + 
                                            '           "RelationshipCode__c": null,  '  + 
                                            '           "RecordType": {  '  + 
                                            '             "Name": "Insurance Covered Individual"  '  + 
                                            '           },  '  + 
                                            '           "DCInsuranceCoveredIndivId__c": "5863,114,0"  '  + 
                                            '         }  '  +
                                            '         ]  '  ; 
    static String sSSP_InsurancyPolicy =    '    [  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "5662",  '  + 
                                            '           "IsEnrolledInInsurance__c": 1,  '  + 
                                            '           "TypeOfCoverageCode__c": "CO",  '  + 
                                            '           "InsuranceCompanyName__c": "INS COMPANY",  '  + 
                                            '           "PhysicalAddressLine1__c": "INS COMPANY",  '  + 
                                            '           "PhysicalCity__c": "KENT",  '  + 
                                            '           "PhysicalCountryCode__c": "",  '  + 
                                            '           "PhysicalCountyCode__c": null,  '  + 
                                            '           "PhysicalStateCode__c": "KY",  '  + 
                                            '           "PhysicalZipCode4__c": null,  '  + 
                                            '           "PhysicalZipCode5__c": "48548",  '  + 
                                            '           "PhysicalAddressLine2__c": "ADD 2",  '  + 
                                            '           "PlanName__c": "IPN jeevan",  '  + 
                                            '           "InsurancePolicyNumber__c": "PID23535          ",  '  + 
                                            '           "InsuranceGroupNumber__c": "PGID4545          ",  '  + 
                                            '           "PolicyBeginDate__c": "2020-01-01",  '  + 
                                            '           "EnrollmentTierLevel__c": "EMSP",  '  + 
                                            '           "IsHealthCareCovPolicyHolderOutSideCase__c": 0,  '  + 
                                            '           "IsHealthCareCoverageApproved__c": 0,  '  + 
                                            '           "DCEmploymentDetailId__c": "293088",  '  + 
                                            '           "EmployerName__c": "delook"  '  + 
                                            '         }  '  +  
                                            '         ]  '  ; 
    static String healthFacilityType = '     [  '  + 
                                            '         {  '  + 
                                            '           "DCId__c": "8",  '  + 
                                            '           "FacilityType__c": "VA",  '  + 
                                            '           "CoverageStartDate__c": "2020-01-16",  '  + 
                                            '           "CoverageEndDate__c": null,  '  + 
                                            '           "SSP_InsuranceCoveredIndiv__r": {"DCInsuranceCoveredIndivId__c":"5663,114,0"}  '  + 
                                            '         }  '  + 
                                            '         ]  '  ;
    static String sSSP_Attendance = '                [      '+
                                    '                {      '+
                                    '                  "SSP_Member__r": {      '+
                                    '          "IndividualId__c" : "999033177"      '+
                                    '          },      '+
                                    '                  "DCId__c": "4518",      '+
                                    '                  "InstitutionSchoolTypeCode__c": "GED",      '+
                                    '                  "ExpectedGraduationDate__c": "2023-01-04",      '+
                                    '                  "EnrollmentTypeCode__c": "HT",      '+
                                    '                  "IsParticipatingInWorkStudyProgramToggle__c": "N",      '+
                                    '                  "IsAssignedToInstitutionProgramToggle__c": "Y",      '+
                                    '                  "PlacedThroughProgramCode__c": "WIA"      '+
                                    '                }      '+
                                    '              ]      ';

    static String sSSP_NonCustodialParentRelationShip = '   [  '  + 
                                                        '     {  '  + 
                                                        '       "SSP_Member__r": {  '  + 
                                                        '         "IndividualId__c": "999033137"  '  + 
                                                        '       },  '  + 
                                                        '       "SSP_NonCustodialParent__r": {  '  + 
                                                        '         "DCNonCustodialParentId__c": "14489"  '  + 
                                                        '       },  '  + 
                                                        '       "DCNonCustodialRelationshipId__c": "5605"  '  + 
                                                        '     }  '  + 
                                                        '  ]  ' ;

    static String sSSP_NonCustodialParent =  '   [  '  + 
                                                '     {  '  + 
                                                '       "SSP_Member__r": {  '  + 
                                                '         "IndividualId__c": "999033137"  '  + 
                                                '       },  '  + 
                                                '       "FirstName__c": "JPLWSA",  '  + 
                                                '       "MiddleInitial__c": " ",  '  + 
                                                '       "LastName__c": "BUECYF",  '  +  
                                                '       "GenderCode__c": "F",  '  + 
                                                '       "SSN__c": " ",  '  + 
                                                '       "IsParentUnknown__c": 1,  '  +  
                                                '       "DCNonCustodialParentId__c": "14488",  '  + 
                                                '       "AbsentParentVerificationCode__c": 0  '  + 
                                                '     }  '  + 
                                                '  ]  ' ;
    static String sSSP_Benefits =  '               [      '+
                                    '                {      '+
                                    '                  "RecordType": {      '+
                                    '        			"Name" : "OutOfStateBenefit"      '+
                                    '        		 },      '+
                                    '                  "SSP_Member__r": {      '+
                                    '          			"IndividualId__c" : "999033177"      '+
                                    '          			},      '+
                                    '                  "DCBenefitsId__c": "7872",      '+
                                    '                  "DCOutOfStateBenefitId__c": "772",      '+
                                    '                  "State__c": "HI",      '+
                                    '                  "BenefitInfoCounty__c": "Canada",      '+
                                    '                  "BenefitPrograms__c": "SN",      '+
                                    '                  "BeginDate__c": "2019-10-01",      '+
                                    '                  "EndDate__c": "2020-10-01"      '+
                                    '                }      '+
                                    '              	]      ';
    static String sSSP_Member =     '   [  '  + 
                                    '           {  '  + 
                                    '			  "Contact__r" : { '+
                                    ' 				"IndividualId__c": "999033137" '+
                                    ' 				}, '+
                                    '             "IndividualId__c": "999033137",  '  + 
                                    '             "FirstName__c": "ERERDFD",  '  + 
                                    '             "LastName__c": "SDSDFSDF",  '  + 
                                    '             "HasAlienSponsorToggle__c": "N",  '  + 
                                    '             "HasLegalImmigrationStatusToggle__c": "Y",  '  + 
                                    '             "IsMilitaryMemberToggle__c": "Y",  '  + 
                                    '             "HasLivedInUsToggle__c": "Y",  '  + 
                                    '             "AlienTypeCode__c": "ACD",  '  + 
                                    '             "ImmigrationDocumentTypeCode__c": "I76",  '  + 
                                    '             "SevisId__c": "546TH",  '  + 
                                    '             "ReceiptNumber__c": "2345678",  '  + 
                                    '             "AlienNumber__c": "6543478",  '  + 
                                    '             "CitizenshipNumber__c": "45688654",  '  + 
                                    '             "CountryOfIssuanceCode__c": "AND",  '  + 
                                    '             "DocumentExpiryDate__c": "2019-02-02",  '  + 
                                    '             "DocumentOtherDescription__c": "Testsys",  '  + 
                                    '             "I94Number__c": "456788765",  '  + 
                                    '             "NaturalizationNumber__c": "456788",  '  + 
                                    '             "PassportNumber__c": "3456789054",  '  + 
                                    '             "IsImmigrationDetailsMatch__c": 0,  '  + 
                                    '             "ImmigrationFirstName__c": "FirstName",  '  + 
                                    '             "ImmigrationMiddleName__c": "T",  '  + 
                                    '             "ImmigrationLastName__c": "LastName",  '  + 
                                    '             "ImmigrationSuffix__c": "TH",  '  + 
                                    '             "ImmigrationDateOfBirth__c": "2019-02-01",  '  + 
                                    '             "DCMemberHighestEducationLevelDetailsId__c": 4589875434,  '  + 
                                    '             "HighestEducationLevelCode__c": "5G",  '  + 
                                    '             "HighestEducationGraduatedDate__c": "2019-05-12",  '  + 
                                    '             "IsFederalRecognizedIndianTribeToggle__c": "Y",  '  + 
                                    '             "IndianTribeCode__c": "AKIA",  '  + 
                                    '             "IndianTribeState__c": "CO",  '  + 
                                    '             "IsEligibleForIHFlagToggle__c": "N",  '  + 
                                    '             "IsEligibleForIndianHealthServicesToggle__c": "N",  '  + 
                                    '             "DCId__c": 5678,  '  + 
                                    '             "Email__c": "test@test.com",  '  + 
                                    '             "PrimaryPhoneNumber__c": "3333333331",  '  + 
                                    '             "PrimaryPhoneExtension__c": "1",  '  + 
                                    '             "PrimaryPhoneTypeCode__c": "LND",  '  + 
                                    '             "IsPrimaryTextPreferred__c": "U",  '  + 
                                    '             "SecondaryPhoneNumber__c": "345875456",  '  + 
                                    '             "SecondaryPhoneExtension__c": "1",  '  + 
                                    '             "PreferredNotificationMethodCode__c": "EE",  '  + 
                                    '             "DCPhysicalAddressId__c": "185680",  '  + 
                                    '             "IsFixedAddressToggle__c": "Y",  '  + 
                                    '             "PhysicalAddressLine1__c": "Frankfort",  '  + 
                                    '             "PhysicalCity__c": "Lexington",  '  + 
                                    '             "PhysicalCountyCode__c": "002",  '  + 
                                    '             "PhysicalStateCode__c": "KY",  '  + 
                                    '             "PhysicalZipCode4__c": "3456789",  '  + 
                                    '             "PhysicalZipCode5__c": "12345",  '  + 
                                    '             "PhysicalAddressLine2__c": "Frankfort",  '  + 
                                    '             "HasDifferentMailingAddressToggle__c": "N",  '  + 
                                    '             "DCMailingAddressId__c": 5679876,  '  + 
                                    '             "MailingAddressLine1__c": "Address1",  '  + 
                                    '             "MailingCity__c": "Amsterdam",  '  + 
                                    '             "MailingCountyCode__c": "003",  '  + 
                                    '             "MailingStateCode__c": "AL",  '  + 
                                    '             "MailingZipCode4__c": "4567890",  '  + 
                                    '             "MailingZipCode5__c": "4569898",  '  + 
                                    '             "MailingAddressLine2__c": "TEERF TGHN",  '  + 
                                    '             "TaxFilerStatusCurrentYear__c": "FJ",  '  + 
                                    '             "CanBuyCookWithHOH__c": 0  '  + 
                                    '           }  '  +
                                    '        ]  ' ;     
}
