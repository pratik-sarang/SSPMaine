/*
* classname 	: SSP_HealthSelectionCtrlTest
* @description 	: This class is use to cover class of Health Selection screen
* @author 		: Ashwin Kasture
* @date 		: 13/11/2019
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_HealthSelectionCtrlTest {
    
    /*
	* method        : setup()
	* @description  : This method is use to set up the Test Data.
	* @author       : Ashwin Kasture	
	* @return       : Void
	* */
    @TestSetup static void setup() {
    	SSP_TestDataFactory.setupTestData();
        
        List<Account> lstAcc = SSP_TestDataFactory.createAccounts(1, false);
        lstAcc[0].Name = 'HealthSelectionCtrl';
        lstAcc = ESAPI.accessController().insertAsUser(lstAcc, SSP_Utility.getFieldsNamesList (lstAcc)).getInsertedObjects();
        
        List<Contact> lstCon = (List<Contact>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'Contact','operator'=>'AND'}, new Set<String>{'Id', 'FirstName', 'LastName'}, new Map<String, String>{'FirstName'=>'Citizen','LastName'=>'User'});
        
        AccountContactRelation acr = new AccountContactRelation(); 
        acr.Accountid = lstAcc[0].Id;
        acr.Contactid = lstCon[0].Id;
        acr.IsActive = true;
        acr = (AccountContactRelation)ESAPI.accessController().insertAsUser(new List<AccountContactRelation>{acr}, SSP_Utility.getFieldsNamesList (new List<AccountContactRelation>{acr})).getInsertedObjects()[0];       
        
        List<SSP_Application__c> lstAppln = SSP_TestDataFactory.createSSPApplications(1, false);
        lstAppln[0].Account__c=lstAcc[0].Id;        
        lstAppln[0].Contact__c = lstCon[0].Id;
        lstAppln= ESAPI.accessController().insertAsUser(lstAppln, SSP_Utility.getFieldsNamesList (lstAppln)).getInsertedObjects();
        
        List<SSP_Member__c> lstMem = SSP_TestDataFactory.createSSPMembers(1, false);
        lstMem[0].contact__c=lstCon[0].Id;
        lstMem[0].PrimaryPhoneExtension__c ='7348789790';
        lstMem[0].PrimaryPhoneNumber__c ='8983838290';
        lstMem[0].IsRequestingOrReceivingCISToggle__c='N';
        lstMem[0].IsReceivingCaretakerServicesToggle__c='N';
        lstMem = ESAPI.accessController().insertAsUser(lstMem, SSP_Utility.getFieldsNamesList (lstMem)).getInsertedObjects();
        
        List<SSP_ApplicationIndividual__c> lstAppInd = SSP_TestDataFactory.createApplicationIndividuals(1, false); 
        lstAppInd[0].SSP_Application__c=lstAppln[0].Id;
        lstAppInd[0].SSP_Member__c=lstMem[0].Id;
        lstAppInd[0].CaretakerServiceIndividualId__c=12345;
        lstAppInd[0].DCCareTakerServiceId__c=1234.5;
        
        lstAppInd[0].MemberStatus__c = SSP_GlobalConstants.MEMBER_STATUS_New;
        lstAppInd = ESAPI.accessController().insertAsUser(lstAppInd, SSP_Utility.getFieldsNamesList (lstAppInd)).getInsertedObjects();        
    	list<SSP_TrackDeletion__c> trackDeletionList= new List<SSP_TrackDeletion__c>();
        SSP_TrackDeletion__c trackDeletion = new SSP_TrackDeletion__c();
            trackDeletion.SSP_Application__c = lstAppln[0].Id;
            trackDeletion.SSP_Member__c=lstMem[0].id;
            trackDeletion.SalesforceId__c =  acr.Id;
            trackDeletion.SFObject__c =  'AccountContactRelation';
            trackDeletion.Source__c =  SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID;
            trackDeletionList.add(trackDeletion);
        
        //insert ;
        SSP_TrackDeletion__c trackDeletion1 = new SSP_TrackDeletion__c();
            trackDeletion1.SSP_Application__c = lstAppln[0].Id;
            trackDeletion1.SalesforceId__c =  acr.Id;
            trackDeletion1.SSP_Member__c=lstMem[0].id;
            trackDeletion1.SFObject__c =  'AccountContactRelation';
            trackDeletion1.Source__c =  SSP_GlobalConstants.CIS_SCREENID;
            trackDeletionList.add(trackDeletion1);
		SSP_TrackDeletion__c trackDeletion2 = new SSP_TrackDeletion__c();
            trackDeletion2.SSP_Application__c = lstAppln[0].Id;
            trackDeletion2.SalesforceId__c =  acr.Id;
            trackDeletion2.SSP_Member__c=lstMem[0].id;
            trackDeletion2.SFObject__c =  'AccountContactRelation';
            trackDeletion2.Source__c =  SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID+','+SSP_GlobalConstants.CIS_SCREENID;
            trackDeletionList.add(trackDeletion2);

        trackDeletionList=ESAPI.accessController().insertAsUser(trackDeletionList, SSP_Utility.getFieldsNamesList (trackDeletionList)).getInsertedObjects();
        //insert ;
		
        NavFlowStatus__c nfs = new NavFlowStatus__c();
        nfs.NavFlowName__c = SSP_GlobalConstants.FLOWNAME_HEALTH;
        nfs.FlowPageStatus__c = 'NNRNNNN';
        nfs.FlowDupStatus__c = 'NNCNNNN';
        nfs.SSPApplication__c = lstAppln[0].Id;
        nfs.SSP_Application__c = lstAppln[0].Id;
        nfs.SSP_Member__c = lstMem[0].Id;
        nfs.Member__c = lstMem[0].Id;
        nfs.Contact__c = lstCon[0].Id;
        //nfs.Screen_Status__c='{"sHasPendingAccidentSettlement":"Test value"}';
        nfs.Screen_Status__c='{"SSP_APP_MD_CS":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false},"SSP_APP_MD_CIS":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false},"SSP_APP_Details_MedicareCoverageSummary":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false},"SSP_APP_Details_HealthCondition":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false},"SSP_APP_Details_Blindness":{"Status":"C","reviewReqScreens":null,"oldStatus":"R","isReviewRequired":false},"SSP_APP_Details_Disability":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false},"SSP_APP_Details_Pregnancy":{"Status":"N","reviewReqScreens":null,"oldStatus":"N","isReviewRequired":false}}	';
        insert nfs;        
    }
    
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    /*
	* method 		: testHealthSelectionMethod
	* @description  : This method is use to cover "getHealthSelectionData" & "storeHealthSelectionData" method
	* @author 		: Ashwin Kasture	
	* @return 		: void
	* */
    @isTest
    public static void testHealthSelectionMethod() {
        
        List<SSP_Application__c> lstAppInd = [Select Id from SSP_Application__c];
        List<SSP_Member__c> lstMember = [Select Id,IsReceivingCaretakerServicesToggle__c,IsRequestingOrReceivingCISToggle__c from SSP_Member__c];
        lstMember[0].IsReceivingCaretakerServicesToggle__c= 'N';
        update lstMember;
        NavFlowStatus__c flowStatus = [SELECT Id, FlowPageStatus__c, FlowDupStatus__c, Screen_Status__c FROM NavFlowStatus__c LIMIT 1];
        List<SSP_ApplicationIndividual__c> listOfApplicationIndividual = [select id,SSP_Member__r.IsReceivingCaretakerServicesToggle__c,SSP_Member__r.IsRequestingOrReceivingCISToggle__c,CaretakerServiceIndividualId__c,SSP_Application__c,SSP_Member__c,IsHeadOfHousehold__c,MedicaidType__c,IsTMember__c from SSP_ApplicationIndividual__c];
        List<SSP_TrackDeletion__c> lstTrackDel= [SELECT Id ,DCId__c ,Source__c ,SSP_Member__c,SSP_Application__c,ownerId FROM SSP_TrackDeletion__c  LIMIT 1];
        lstTrackDel[0].ownerId = fetchCitizenUser().Id;
        update lstTrackDel;
        SSP_LightningResponse objGetHealthResponse = new SSP_LightningResponse();
        System.runAs(fetchCitizenUser()) {
            List<SSP_TrackDeletion__c> lstTrackDel1= [SELECT Id ,DCId__c ,Source__c ,SSP_Member__c,SSP_Application__c FROM SSP_TrackDeletion__c  LIMIT 100];
            List<SSP_ApplicationIndividual__c> listOfApplicationIndividual1 = [select id,SSP_Member__r.IsReceivingCaretakerServicesToggle__c,SSP_Member__r.IsRequestingOrReceivingCISToggle__c,CaretakerServiceIndividualId__c,SSP_Application__c,SSP_Member__c,IsHeadOfHousehold__c,MedicaidType__c,IsTMember__c from SSP_ApplicationIndividual__c];            
            Test.startTest();
            objGetHealthResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(String.valueOf(lstAppInd[0].Id),'RAC');
            System.assertEquals(true, objGetHealthResponse.bIsSuccess);
            String sMemberHealhSelectionData = '[{"sMemberId":"'+lstMember[0].Id+'","sHasEmergencyMedicalCondition":"Y","sHasPendingAccidentSettlement":"N","sIsBlind":"N","sIsDisabled":"N","sIsReceivingMedicareBenefit":"N","sIsRequestingOrReceivingCIS":"Y","sIsReceivingCaretakerServices":"Y"}]';
            String sApplicationData = '{"sHasPendingAccidentSettlement":"N"}';
            SSP_LightningResponse objStoreHealthResponse = new SSP_LightningResponse();
            objStoreHealthResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(String.valueOf(lstAppInd[0].Id), sMemberHealhSelectionData, sApplicationData);
            Map<String, Boolean> questionMap = new Map<String, Boolean>{
                        'showMedicalQuestions' => true,
                        'showCommunityQuestions' => true
                    };
                        
                        List<SSP_HealthInformationWrapper> sspHealthInformationWapper= new List<SSP_HealthInformationWrapper>();
            SSP_HealthInformationWrapper sppHealth = new SSP_HealthInformationWrapper();
            sppHealth.sMemberId=lstMember[0].Id;
            sppHealth.sHasEmergencyMedicalCondition='Y';
            sppHealth.sHasPendingAccidentSettlement='N';
            sppHealth.sIsBlind='Y';
            sppHealth.sIsDisabled='Y';
            sppHealth.sIsReceivingMedicareBenefit='N';
            sppHealth.sIsRequestingOrReceivingCIS='Y';
            sppHealth.sIsReceivingCaretakerServices='Y';
            sspHealthInformationWapper.add(sppHealth);
            SSP_HealthInformationService.createNavFlowStatuses(sspHealthInformationWapper,String.valueOf(lstAppInd[0].Id),questionMap);
            system.assertEquals(true, objStoreHealthResponse.bIsSuccess);
            
            //To cover the exception part
            SSP_LightningResponse objGetHealthExceptionResponse = new SSP_LightningResponse();
            objGetHealthExceptionResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(null,'RAC');
            system.assertEquals(false, objGetHealthExceptionResponse.bIsSuccess);
            SSP_LightningResponse objStoreHealthExceptionResponse = new SSP_LightningResponse();
            objStoreHealthExceptionResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(null,'', null);
            system.assertEquals(false, objStoreHealthExceptionResponse.bIsSuccess);
            Test.stopTest();
        }
    } 
    @isTest
    public static void testHealthSelectionMethod1() {
        System.runAs(fetchCitizenUser()) {          
            List<SSP_Application__c> lstAppInd = [Select Id from SSP_Application__c];
            NavFlowStatus__c flowStatus = [SELECT Id, FlowPageStatus__c, FlowDupStatus__c, Screen_Status__c FROM NavFlowStatus__c LIMIT 1];
            List<SSP_Member__c> lstMember = [Select Id,IsReceivingCaretakerServicesToggle__c,IsRequestingOrReceivingCISToggle__c from SSP_Member__c];
            lstMember[0].IsReceivingCaretakerServicesToggle__c='N';
            lstMember[0].IsRequestingOrReceivingCISToggle__c='N';
            Update lstMember;
            List<SSP_ApplicationIndividual__c> listOfApplicationIndividual = [select id,SSP_Member__r.IsReceivingCaretakerServicesToggle__c,SSP_Member__r.IsRequestingOrReceivingCISToggle__c,CaretakerServiceIndividualId__c,SSP_Application__c,SSP_Member__c,IsHeadOfHousehold__c,MedicaidType__c,IsTMember__c from SSP_ApplicationIndividual__c];
            Test.startTest();
            SSP_LightningResponse objGetHealthResponse = new SSP_LightningResponse();
			objGetHealthResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(String.valueOf(lstAppInd[0].Id),'RAC');
        	System.assertEquals(true, objGetHealthResponse.bIsSuccess);
            String sMemberHealhSelectionData = '[{"sMemberId":"'+lstMember[0].Id+'","sHasEmergencyMedicalCondition":"Y","sHasPendingAccidentSettlement":"N","sIsBlind":"N","sIsDisabled":"N","sIsReceivingMedicareBenefit":"N","sIsRequestingOrReceivingCIS":"Y","sIsReceivingCaretakerServices":"Y"}]';
            String sApplicationData = '{"sHasPendingAccidentSettlement":"N"}';
            SSP_LightningResponse objStoreHealthResponse = new SSP_LightningResponse();
            objStoreHealthResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(String.valueOf(lstAppInd[0].Id), sMemberHealhSelectionData, sApplicationData);
        	system.assertEquals(true, objStoreHealthResponse.bIsSuccess);
            
            //To cover the exception part
            SSP_LightningResponse objGetHealthExceptionResponse = new SSP_LightningResponse();
            objGetHealthExceptionResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(null,'RAC');
        	system.assertEquals(false, objGetHealthExceptionResponse.bIsSuccess);
            SSP_LightningResponse objStoreHealthExceptionResponse = new SSP_LightningResponse();
            objStoreHealthExceptionResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(null,'', null);
        	system.assertEquals(false, objStoreHealthExceptionResponse.bIsSuccess);
            Test.stopTest();
        }
	}   
    @isTest
    public static void testmodeHealthSelectionMethod() {
        System.runAs(fetchCitizenUser()) {          
            List<SSP_Application__c> lstAppInd = [Select Id from SSP_Application__c];
        	List<SSP_Member__c> lstMember = [Select Id,IsReceivingCaretakerServicesToggle__c from SSP_Member__c];
            List<SSP_ApplicationIndividual__c> listOfApplicationIndividual = [select id,SSP_Member__r.IsReceivingCaretakerServicesToggle__c,SSP_Member__r.IsRequestingOrReceivingCISToggle__c,CaretakerServiceIndividualId__c,SSP_Application__c,SSP_Member__c,IsHeadOfHousehold__c,MedicaidType__c,IsTMember__c from SSP_ApplicationIndividual__c];
                        List<SSP_TrackDeletion__c> lstTrackDeletion = [Select Id from SSP_TrackDeletion__c];

            Test.startTest();
            SSP_LightningResponse objGetHealthResponse = new SSP_LightningResponse();
			objGetHealthResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(String.valueOf(lstAppInd[0].Id),'mode');
        	System.assertEquals(true, objGetHealthResponse.bIsSuccess);
            String sMemberHealhSelectionData = '[{"sMemberId":"'+lstMember[0].Id+'","sHasEmergencyMedicalCondition":"Y","sHasPendingAccidentSettlement":"N","sIsBlind":"N","sIsDisabled":"N","sIsReceivingMedicareBenefit":"N","sIsRequestingOrReceivingCIS":"Y","sIsReceivingCaretakerServices":"Y"}]';
            String sApplicationData = '{"sHasPendingAccidentSettlement":"N"}';
            SSP_LightningResponse objStoreHealthResponse = new SSP_LightningResponse();
            objStoreHealthResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(String.valueOf(lstAppInd[0].Id), sMemberHealhSelectionData, sApplicationData);
        	system.assertEquals(true, objStoreHealthResponse.bIsSuccess);
            
            //To cover the exception part
            SSP_LightningResponse objGetHealthExceptionResponse = new SSP_LightningResponse();
            objGetHealthExceptionResponse = SSP_HealthSelectionCtrl.getHealthSelectionData(null,'mode');
        	system.assertEquals(false, objGetHealthExceptionResponse.bIsSuccess);
            SSP_LightningResponse objStoreHealthExceptionResponse = new SSP_LightningResponse();
            objStoreHealthExceptionResponse = SSP_HealthSelectionCtrl.storeHealthSelectionData(null,'', null);
        	system.assertEquals(false, objStoreHealthExceptionResponse.bIsSuccess);
            Test.stopTest();
        }
	}    
}