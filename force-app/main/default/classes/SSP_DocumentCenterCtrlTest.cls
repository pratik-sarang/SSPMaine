/*
* classname     : SSP_EnrollmentDetailsCtrlTest
* @description  : Test class for document center
* @author       : Aniket Shinde
* @date         : 7/5/2020
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
*/
@isTest(seeAllData=false)
public class SSP_DocumentCenterCtrlTest {

    /*
	* method        : setup
	* @description  : setup data for tests
	* @author       : Aniket
	* @return       : user
	* */
    @testSetup static void setup() { 
        SSP_TestDataFactory.setupTestData();    

    }    
    
    /*
	* method        : fetchCitizenUser
	* @description  : citizen user
	* @author       : Aniket
	* @return       : user
	* */
    private static User fetchCitizenUser() {
        return ((List<User>)SSP_Utility.fetchRecords(new Map<String, String>{'objectName'=>'User'}, new Set<String>{'Id'}, new Map<String, String>{'UserName'=>'citizen@abc.xyz','limit'=>'1'}))[0];        
    }
    
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testSaveChunk() {
        String base64Str = '%2F9j%2F4AAQSkZJRgABAQAAAQABAAD%2F2wBDABALDA4MChAODQ4SERATGCgaGBYWGDEjJR0oOjM9PDkzODdASFxOQERXRTc4UG1RV19iZ2hnPk1xeXBkeFxlZ2P%2F2wBDARESEhgVGC8aGi9jQjhCY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2NjY2P%2FwAARCAK8BBoDASIAAhEBAxEB%2F8QAGwAAAwEBAQEBAAAAAAAAAAAAAAECAwQFBgf%2FxABHEAACAgECBQIDBQUFBgUCBwAAAQIRAwQSBSExQVETYRRxgQYiMlKRFUJDocFTgpLR4SMzRGKx8BYkNFTxk9IHZKKjssLi%2F8QAGgEBAQEBAQEBAAAAAAAAAAAAAAECAwQFBv%2FEACURAQEBAAICAwADAAMBAQAAAAABEQISEyEDMVEiQWEUMnEEgf%2FaAAwDAQACEQMRAD8A4cvORpgj95Ez5yN8C5nw%2BVyP0Ent1448kaoiJZ5a6VnkMX1NZvmYt8zfFw5qiWiY9C0SpFIGCB9DLSWS%2Bo5Evqaiw0UiUVEVtaRoiIlnOoBgJkDEwEzcWIkZTZpIykajTHI%2BZKfMJ9SV1Os%2BmK0RSJRSRKGWlyJotdDKtcRsjHEbGKlNsyyPkW2Y5HyMz3Wb9MMz%2B4zzMj5s9DM%2FuM83I%2BZ6%2Fijz8658jswmzaZjLoe7g89ZPqaYzN9TSB1v0nF26fseji7HnYOx6WJdDw%2FL9vX8brxG5jiN%2Bx53oY5eh5%2Bb8R6GXozz8%2F4i8ftnk7NH2Pc0r6Hg6N9D3dK%2BSPTHn5%2FT0I9DRGcS4nWPFWgCA2wAAQAACIoABAAAIigAAKQABAgAAoEABQIYiAAAAAAAoAAAAAAhgIZAAAAAAAAAAAwAAgAAAYCGQAAAQwAAAYhgBSJJlKgma0uiXkSMJZTGWUzeTc%2BPXTLN7mM83uc8sjYuvU53k6z45FyyNiXPqJDRhvMUuRSIHuSCLRVpdTmlnSObLq0u5m8pFnx2vQlnjE5sut2rrR5eTWuX4TnlOUn95mLytbnx8Y7c%2BvbtR5nHPLOf4pfQhsmySNGyWFks0gYCGaQAkAyCWSyu5LLFJK2UhJFJFqyO3hmPfqk%2B0T3TzOD4%2Fuzm%2FkeojEY532hrfqMWPy7%2FAE%2F%2BT1sipRj4R52hj6mvb%2FIkv6no5Oc2er45nC15Plv8pGTIaNGS0ZrMrNollslojcQ0SWxUZblfCLJczrwTPGxZvvHZiz0dOfxvbw%2BR68ciG8tI874gmep5dTz%2BKt35HZPN7mfq8zglqOfUSz8%2Bp1nxPPee16ccposp5cc5os5m%2FEs5vSWT3H6h5yz8uoPUe5nxVru73kJ9Tn1OB5%2Fccc%2FMvjJzegp8yozPP9f3Ljn9zN%2BNvu9KMyt6OBZ%2Fcr1%2Fc5346vZ3qSE5HGs%2FuNZ%2BfUnStTlHZZLkjm9deRPMvInGtbG05GUnzMZ5uZlLN7nScKXlFzf3gi%2BZzPLzHHKdetc%2BzrVFo5VlLjlXkxeNWcnSX2RzLKWsvLqYxrXXiNjlxZORp6piwaSZz5XyHLKY5cqocY58qxzv7jOCbuzq1GT7hwymqPX8c9PNzrOZjMuc0ZSkezhHGo7muMxvmbY2jpfo4u3B2PRw9jzsDXI9DE0eL5ft6%2BDtxG3YwxyN75HneiMsvQ8%2FP1O%2FK1R5%2Bd8y8ftjk6tH2Pd0vRHg6N9D3dI%2BSPTHDl9PRiaIyi%2BRpE6R4%2BTRAJAacwACCgAEQAAIKAAAoEAEAIYgoABAAAAUgAAAAAAAAIAAAAAAABiGAAAAAAAAAAQMAAIAAAAAABgABAAAQMAABSdIwyTo0m%2BRy5ZGOVdOHHUTyEc31EM5V6cw0MlySIllSIY1uhPIkcmTUpdzly61LuS1ZxehPOl3ObLrEu55mTVyn0MtzfNuzPutZI7MmrlLoYObl1ZCY7JhapMLFYmxiabYrFYWXEDYmwsCoBiQwAAAKTF3HadiQD69C0uRKNsacpJEtbj2uHQ2aWPLqdfYiEdmOMfCFlbWKVdapDjPTz33XXwmP3J5H%2B827Opk6SHp6OKXSi2ezM4yPHyu8rUMlotks51YhollslmW4zaEWySNR%2BY44M6IJpHVHSexqtN7Hp5XXrnDHGkyJJno%2FDX2D4V%2BDC3g8zYwUGemtJ7FLSew7VnxvNWNj2M9NaT2K%2BE9ibV8bzNrQnBnqfCew%2Fg%2FYm08byXCQlGR63wfsHwfsXavjeXtkUlI9P4L2H8H7E2nR5qchuUj0fg%2FYT0fsReleepyGskjuejfgXwnsMXrXIsjJeWR2vSPwJ6R%2BBIuV58srM5ZXTPRejfgzlom%2BxuYzZXm%2Bo7KjlZ2PQvwNaF%2BDXpjK5VlZccxv8E%2FA%2Fg34M2RfbL1uZfrdOY%2FhJeA%2BEfgz1i%2B2uPPS6l%2FEe5lHTSoHp5HO8Iu1UtR7mOXUe43p5Mxnpp33N8eEc%2BVqM%2Ba4nNLJaNsmmmzJ6WZ6OEkjjy1hLJZDmbS0s%2FBm9LPwd5jnZWW7mbY50kR8NPwXHDNdi3DjsdeHJ0O%2FFl5LmeXCE12OiG9djy%2FJx16OHLHrYsyvqb%2BtyPJxykmbPLKjzXhdd5zdWXPyZwZs1snJkkcmSbtHTh8bHPm9nQzuj6HSO0j5Xh8naPptE%2BSOlmMbsepFmsTCDNoljzco0QCQzbmAAQUCGIgAAAoEAEAACCgAABAABQIYgAAAAAACgAAAAACGIAAAGBAAAAAAAAAAADACAAACAAABgABAAAAAwEyKyyM48r5nVkOPKc%2BTv8AGlzSM55kjmz5tj5s4cusS7nOu8jvyalLucebWJdzgyaic34RlfMdbftXTk1Mp9Ohldvm7ZCY0XMGiY0yEykSpq0UiEyjKKsTCwIgbEAihghABVhfIVisYG2JsTZLYwVY0Si4itxcep26DHv1MV72ckVa6HqcIx%2F7SU%2FCOd9ryucdeo0Z5Funjh%2BaXP5f90ahpo%2BprUu0EdeM248tuTXptVCMfYkuXOTJPXz%2B3iiWSymJnKtxDJaLZLM1qIYqKYqMtvn1pF4KWlXg9VYClgXg7PXfmjylpV4GtKvB6ywIawoYz53lfC%2Bw1pfY9VYUP0UMTzvK%2BF9h%2FC%2Bx6vpIfpLwMTz15XwvsHwvset6S8B6S8F6p568r4X2D4X2PW9JeA9NeB1Tz15XwvsHwvser6S8B6S8DqeevJ%2BF9g%2BG9j1fSXgPSXgdV89eT8N7C%2BG9j1vRQeih1PPXkfDewfDex6%2FooPQQ6r53j%2FCrwJ6ReD2PQQeghlPO8b4ReA%2BEXg9n0EL4dDKed4%2Fwi8C%2BEXg9n4dB8OhlPO8X4NeBfBrwe18OHw4yr548X4NeA%2BDXg9l6cXw%2FsMp5o8Z6NeCHoV4Pc%2BH9hPT%2BwynljwHoL7Evh68H0D0%2FsL4f2Hs8nF88%2BHr8pEuHJ9j6N6f2Jen9i7TtxfNvhq%2FKT%2Bzl%2BU%2BlemXgXwy8F7U3i%2Bc%2FZ%2FsP4H2PoHpl4E9MvBNXY8D4OuwPSex7r0y8EvTexNa2Pn56P2OeehbfQ%2Bmel9iHo%2BfQ1LjNyvL0Wj21yPd02LYhYtOorodMYkt1m1cUaxIijRFjjyWmAhmnMAAgAAEFMQAAAAiKAAAAQAAAABQIYgAAAAAAAAAAAAAAGAAIYAAAAAAAAAAAQAxDCAAAgAAAAYgAYAAATJlGc2SrGU2cmbudM3yOPPKkzm9HF4nFJtSUUzz7N%2BIZN%2Bqa8HLZJHQ7CyWwT5msFopEIpGaLRSJRSMUUikSMiKAkdkAArEAwEBUMGITAGxA2CKRSRpFERRtAzXWNIR7ntcMht0zl5Z48ebSfyPodPHZghGuxznusfLf44s24XG55Mnu%2FwDIwm9sJPwjt4fD09HH3R6vhn83k%2BW5wbvmJjEdK85MllCZmrEMTKZLM1qIYDYjLYSGkJFHdAOhDKh0FABUOgACh0FABUFDoAKgoKGACoKGAwKgoYFwKgooBhqdobShjE1O0NpQF6mp2htLFY6w1O0W0uwGQ1G0W00ETquo2i2mlComGs9obS6FRMXUbRbTShNExdZ7ULajShUTF1ntQnFGlBQxrWTivAnFeDWhbSYusXFeBOBttFtJjXZkolpFbR0XEvIJFIEhlZoAAKgAAAQAAAIACgAEQAAAAAAFAgAAAAAAAAAAAAAAAAAAAYhgAAAAAAAAAAAAAAAAQMBDCAAAgAAAAAAAZlNmj6GM2ZrXGMsj5HBqp7YtnZlZ5XEsuzDN%2Bxl6OLwcst2WcvchsVktlxo7GiLKQFplohFxM0WikSijFFBYgIh2FiABgIAGIQwATYWSwgsaJKiWrGsehrBGcEbwVHLk7Rvpob88F7n0CPI4ZDdn3flVnronFx%2BW%2B8Z5lujGC%2FekkevBbcMI%2Bx5eOLyauEe0eb%2FoerPqev4pkteP5r9QhDEacSYmMTI0liZTJZmtRLEUxGWkoolFI7AGgGVAMQyoBiGVAMQygGIZUAAMoQDAqAAAAALCwGBLkTuJ2MXYORm5EPIl3JebU4tXIlzOeedLuYS1aXcxebpx%2BK137hqRwQ1Kfc6oTUlyE5Jy4WOhMZnFlo6yuVgEUIBCGBFIQxEUgGIgQDEFIRQiKQUMQUUAAAAAAAAIAAAAAAApAAEAACAAAAoEAAAAAAAAAAAAAAAAAAAAAFAMQyAAAAAAAAAAAGIAGIBkCAYBCGIYAAAAAAEEy6GE2bTZz5GZrpxYZX1PB4zl';
        SSP_LightningResponse objResp;
        Test.startTest();
        objResp = SSP_DocumentCenterCtrl.saveChunk('', 'testFile.jpg', base64Str, 'jpg', '', '');
        SSP_DocumentCenterCtrl.saveChunk('', '%2', 'test', 'pdf', (string)objResp.mapResponse.get('fileId'), '');
        SSP_DocumentCenterCtrl.saveChunk(null, null, null, null, '', null);
        system.assert(objResp.bIsSuccess, true); 
        Test.stopTest();
    }
    
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testDeleteContent() {
    	ContentVersion testContentInsert =new ContentVersion();          
        testContentInsert.Title ='Google.com'; 
	testContentInsert.PathOnClient = 'Google.jpg'; 
        testContentInsert.VersionData = Blob.valueOf('Test Data');
         insert testContentInsert; 
         SSP_LightningResponse objResp = new SSP_LightningResponse();
         Test.startTest();
        SSP_DocumentCenterCtrl.getMapContentVerToContentDoc(new list<string>{testContentInsert.Id});
        objResp = SSP_DocumentCenterCtrl.deleteDocuments(new list<string>{testContentInsert.Id});
        SSP_DocumentCenterCtrl.deleteDocuments(null);
        system.assert(objResp.bIsSuccess, true); 
        Test.stopTest();
    }
    
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testProofs() {
        SSP_LightningResponse objResp = new SSP_LightningResponse();
        Test.startTest();
        System.runAs(fetchCitizenUser()) {
            objResp = SSP_DocumentCenterCtrl.getTypeOfProofs();
            SSP_DocumentCenterCtrl.getFormOfProofsWizard('V001');
            SSP_DocumentCenterCtrl.getFormOfProofs('V001');
            SSP_DocumentCenterCtrl.getFormOfProofsWizard(null);
            SSP_DocumentCenterCtrl.getFormOfProofs(null);
            SSP_DocumentCenterCtrl.getFormOfProofsWizard('X');
            SSP_DocumentCenterCtrl.getFormOfProofs('X');
            system.assert(objResp.bIsSuccess, true); 
        }
        Test.stopTest();
    }
    
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testWizardProcessUpload() {
    	ContentVersion testContentInsert =new ContentVersion(); 

        testContentInsert.Title ='Google.com'; 
	testContentInsert.PathOnClient = 'Google.jpg';
        testContentInsert.VersionData = Blob.valueOf('Test Data');
        insert testContentInsert; 
        String conVerId = testContentInsert.id;
        String conDoc = ([select contentDocumentId from ContentVersion where id = :conVerId]).contentDocumentId;
        List<Object> wrapDocList = (List<Object>)JSON.deserializeUntyped('[{"description":"rt","fileId":"'+conVerId+'","contentDocumentId":"'+conDoc+'","fileName":"file_example_JPG_100kB.jpg","fileType":"jpg","caseNumber":100016796,"individualId":650000798,"proofCode":"V003","proof":"US Citizenship","formOfProof":"CSE","proofName":"Civil Service Employment Document","selectDocumentTitle":"Select file_example_JPG_100kB.jpg","taskCode":""}]');
        List<String> docIdLst = new List<String>{conVerId};
        SSP_LightningResponse objResp = new SSP_LightningResponse();
        SSP_LightningResponse objResp1 = new SSP_LightningResponse();
        SSP_LightningResponse objResp2 = new SSP_LightningResponse();
        Test.startTest();
        System.runAs(fetchCitizenUser()) {
            objResp = SSP_DocumentCenterCtrl.wizardProcessUpload(wrapDocList,docIdLst);
            objResp1 = SSP_DocumentCenterCtrl.identityWizardProcessUpload(wrapDocList,docIdLst);
            objResp2 = SSP_DocumentCenterCtrl.hearingWizardProcessUpload(wrapDocList,docIdLst);
            SSP_DocumentCenterCtrl.wizardProcessUpload(new list<object>(),new list<string>());
            SSP_DocumentCenterCtrl.wizardProcessUpload(null,null);
            SSP_DocumentCenterCtrl.getPickListValues('DocumentDetail__c', 'DocumentType__c', '');
        }
        Test.stopTest();
    }
    @isTest
    public static void testWizardProcessUpload1() {
    	ContentVersion testContentInsert =new ContentVersion(); 

        testContentInsert.Title ='Google.com'; 
	testContentInsert.PathOnClient = 'Google.tiff';
        testContentInsert.VersionData = Blob.valueOf('Test Data');
        insert testContentInsert; 
        String conVerId = testContentInsert.id;
        String conDoc = ([select contentDocumentId from ContentVersion where id = :conVerId]).contentDocumentId;
        List<Object> wrapDocList = (List<Object>)JSON.deserializeUntyped('[{"description":"rt","fileId":"'+conVerId+'","contentDocumentId":"'+conDoc+'","fileName":"file_example_JPG_100kB.tiff","fileType":"tiff","caseNumber":100016796,"individualId":650000798,"proofCode":"V003","proof":"US Citizenship","formOfProof":"CSE","proofName":"Civil Service Employment Document","selectDocumentTitle":"Select file_example_JPG_100kB.jpg","taskCode":"","isEligibleForRenewal":"Y"}]');
        List<String> docIdLst = new List<String>{conVerId};
        SSP_LightningResponse objResp = new SSP_LightningResponse();
        SSP_LightningResponse objResp1 = new SSP_LightningResponse();
        SSP_LightningResponse objResp2 = new SSP_LightningResponse();
        Test.startTest();
        objResp = SSP_DocumentCenterCtrl.wizardProcessUpload(wrapDocList,docIdLst);
        objResp1 = SSP_DocumentCenterCtrl.identityWizardProcessUpload(wrapDocList,docIdLst);
        objResp2 = SSP_DocumentCenterCtrl.hearingWizardProcessUpload(wrapDocList,docIdLst);
        SSP_DocumentCenterCtrl.wizardProcessUpload(new list<object>(),new list<string>());
        SSP_DocumentCenterCtrl.wizardProcessUpload(null,null);
        Test.stopTest();
    }
        
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testDownloadDocument() {
    	ContentVersion testContentInsert =new ContentVersion(); 
        
        testContentInsert.Title ='Google.com'; 
	testContentInsert.PathOnClient = 'Google.jpg';  
        testContentInsert.VersionData = Blob.valueOf('Test Data');
        insert testContentInsert; 
        SSP_LightningResponse objResp = new SSP_LightningResponse();
        String inputStr = JSON.serialize(new map<string,string>{'contentDocumentId' => testContentInsert.Id});
        String inputForService = JSON.serialize(new map<string,string>{'documentMetaDataId' => testContentInsert.Id});
        Test.startTest();
        System.runAs(fetchCitizenUser()) {
            objResp = SSP_DocumentCenterCtrl.downloadDocumentMethod(inputStr);
            SSP_DocumentCenterCtrl.downloadDocumentMethod(null);
            SSP_DocumentCenterCtrl.downloadDocumentMethod('test');
            SSP_DocumentCenterCtrl.downloadDocumentMethod('{}');
            SSP_DocumentCenterCtrl.downloadDocumentMethod(inputForService);
            system.assert(objResp.bIsSuccess, true); 
        }
        Test.stopTest();
    }

    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testWrittenStatement() {
        SSP_LightningResponse objResp = new SSP_LightningResponse();
        Test.startTest();
        System.runAs(fetchCitizenUser()) {
            objResp = SSP_DocumentCenterCtrl.downloadWrittenStatement();
            system.assertEquals(objResp.bIsSuccess, true); 
        }
        Test.stopTest();
    }

    /*
    * method        : testGetConfig
    * @description  : test configurations fetching
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testGetConfig() {
        List<AppConfig__c> lstUpsert = new list<AppConfig__c>();
        AppConfig__c mapsConfigA = new AppConfig__c();
        mapsConfigA.Name = 'SSPDocumentCenterCompressionConvert';
        mapsConfigA.Value__c = '3145728';
        lstUpsert.add(mapsConfigA);
        AppConfig__c mapsConfigB = new AppConfig__c();
        mapsConfigB.Name = 'SSPDocumentCenterCompressionQuality';
        mapsConfigB.Value__c = '0.5';
        lstUpsert.add(mapsConfigB);
        upsert lstUpsert;
        Test.startTest();
        System.runAs(fetchCitizenUser()) {
            SSP_LightningResponse objResp = new SSP_LightningResponse();
            objResp = SSP_DocumentCenterCtrl.getConfigValues();
            system.assert(objResp.bIsSuccess, true); 
        }
        Test.stopTest();
    }    
    
    /*
    * method        : testMethod
    * @description  : testMethod for document center controllers
    * @author       : Aniket   
    * @return       : void
    * */
    @isTest
    public static void testInit() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        System.runAs(fetchCitizenUser()) {
            SSP_LightningResponse objResp = new SSP_LightningResponse();
            objResp = SSP_DocumentCenterCtrl.initDocumentCenter();
            system.assert(objResp.bIsSuccess, true); 
        }
        Test.stopTest();
    }

    /*
    * method        : MockHttpResponseGenerator
    * @description  : mock response
    * @author       : Aniket   
    * @return       : void
    * */
    public class MockHttpResponseGenerator implements HttpCalloutMock
    {
        public HTTPResponse respond(HTTPRequest req) {
            httpResponse response = new HttpResponse();
            response.setStatusCode(200);
            //res.setHeader('Content-Type', 'application/json');
            
            
            
            Map<String, Object> reqBody = (Map<String, Object>) JSON.deserializeUntyped(req.getBody());
            response.setBody(sRFIInformation);
            
            return Response;
        }
        String sRFIInformation =                    '   {  '  + 
                                                '     "individualIds": "999015978",  '  + 
                                                '     "applicationID": "a0Xr00000011S6hEAE",  '  + 
                                                '     "miscelleanousParameter": "",  '  + 
                                                '     "viewName": "RFIDetails",  '  + 
                                                '     "caseNumber": "100049980",  '  + 
                                                '     "primaryApplicantIndividualId": "999015976",  '  + 
                                                '     "programCode": "MA",  '  + 
                                                '     "mode": "RAC",  '  + 
                                                '     "Payload": {  '  + 
                                                '       "RFIInformation": [  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015978",  '  + 
                                                '           "FullName": "BENN GELLERR",  '  + 
                                                '           "TypeOfProof": "Age",  '  + 
                                                '           "DueDate": "2019-12-23",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "MA",  '  + 
                                                '           "TypeOfProofRefCode": "V001",  '  + 
                                                '           "UniqueIdentifier": null  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "FullName": "ROSSS GELLERS",  '  + 
                                                '           "TypeOfProof": "Elective Abortion",  '  + 
                                                '           "DueDate": "2019-07-01",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP",  '  + 
                                                '           "TypeOfProofRefCode": "KHIPP_ELE_ABO",  '  + 
                                                '           "UniqueIdentifier": "KP1485492249"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "FullName": "ROSSS GELLERS",  '  + 
                                                '           "TypeOfProof": "KI-HIPP Enrollment",  '  + 
                                                '           "DueDate": "2019-07-01",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP",  '  + 
                                                '           "TypeOfProofRefCode": "KHIPP_ENRL",  '  + 
                                                '           "UniqueIdentifier": "KP-1347488412"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "FullName": "ROSSS GELLERS",  '  + 
                                                '           "TypeOfProof": "KI-HIPP Good Cause",  '  + 
                                                '           "DueDate": "2019-07-01",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP",  '  + 
                                                '           "TypeOfProofRefCode": "KHIPP_GOOD_CAUSE",  '  + 
                                                '           "UniqueIdentifier": "KP206563039"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "FullName": "ROSSS GELLERS",  '  + 
                                                '           "TypeOfProof": "KI-HIPP Monthly Verification",  '  + 
                                                '           "DueDate": "2020-04-30",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP",  '  + 
                                                '           "TypeOfProofRefCode": "KHIPP_MON_VER",  '  + 
                                                '           "UniqueIdentifier": "KP-585622298"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "FullName": "ROSSS GELLERS",  '  + 
                                                '           "TypeOfProof": "KI-HIPP Preferred Payment Method",  '  + 
                                                '           "DueDate": "2019-07-01",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP",  '  + 
                                                '           "TypeOfProofRefCode": "KHIPP_OOP_EXP",  '  + 
                                                '           "UniqueIdentifier": "KP-1115997687"  '  + 
                                                '         }  '  + 
                                                '       ],  '  + 
                                                '       "DocumentMetaData": [  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "IndividualName": "ROSSS GELLERS",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "DocumentMetaDataId": "4A1DFE47-9D87-1B8D-0DDC-39F02DA09C60",  '  + 
                                                '           "DocumentName": "Test",  '  + 
                                                '           "Extension": "tif",  '  + 
                                                '           "MimeType": "image/tiff",  '  + 
                                                '           "DocumentType": "29",  '  + 
                                                '           "SubmittedDate": "2019-09-10"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "IndividualName": "ROSSS GELLERS",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "DocumentMetaDataId": "AA7D8B9A-CE62-F3AF-D2C4-39F02DA12E20",  '  + 
                                                '           "DocumentName": "Test",  '  + 
                                                '           "Extension": "tif",  '  + 
                                                '           "MimeType": "image/tiff",  '  + 
                                                '           "DocumentType": "APE",  '  + 
                                                '           "SubmittedDate": "2019-09-10"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "IndividualName": "ROSSS GELLERS",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "DocumentMetaDataId": "B61AE0E0-F5CA-D6E3-7B1B-39F02DA172AB",  '  + 
                                                '           "DocumentName": null,  '  + 
                                                '           "Extension": "tif",  '  + 
                                                '           "MimeType": "image/tiff",  '  + 
                                                '           "DocumentType": "29",  '  + 
                                                '           "SubmittedDate": "2019-09-10"  '  + 
                                                '         }  '  + 
                                                '       ],  '  + 
                                                '       "CaseInformation": [  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015976",  '  + 
                                                '           "CaseNumber": "100049980",  '  + 
                                                '           "ProgramCode": "KP;MA",  '  + 
                                                '           "FullName": "ROSSS GELLERS"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015977",  '  + 
                                                '           "CaseNumber": "100049989",  '  + 
                                                '           "ProgramCode": "MA",  '  + 
                                                '           "FullName": "RACHEL G"  '  + 
                                                '         },  '  + 
                                                '         {  '  + 
                                                '           "IndividualId": "999015978",  '  + 
                                                '           "CaseNumber": "100049989",  '  + 
                                                '           "ProgramCode": "MA",  '  + 
                                                '           "FullName": "BENN GELLERR"  '  + 
                                                '         }  '  + 
                                                '       ]  '  + 
                                                '     }  '  + 
                                                '  }  ' ;
    }
}