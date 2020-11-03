/*
* Classname 		:  SSP_TMemberTest
* @description 	:  This class is the test class of SSP_TMemberIntegrationService
* @author 		:  Rijia Khatun
* @date 		:  19/2/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName	      MM/DD/YYYY	      A Brief Description 
						       about the Change
**/

@isTest
public class SSP_TMemberTest {
    @isTest 
    static void tMemberTest() {
        Test.setMock(WebServiceMock.class, new SSP_TMemberMockClass());
        Test.startTest();
        SSP_TMemberStubClass.ArrayOfint objArrayofInt = new SSP_TMemberStubClass.ArrayOfint();
        objArrayofInt.int_x = new List<Integer>();
        SSP_TMemberDataContract objDataContact = new SSP_TMemberDataContract();
        SSP_TMemberDataContract.SSPCaseRequest objReq = new SSP_TMemberDataContract.SSPCaseRequest();
        objReq.ApplicationNumber = 123233;
                
        SSP_TMemberDataContract.SSPProgram objPro = new SSP_TMemberDataContract.SSPProgram();
        objPro.ProgramCode = 'Program';
        SSP_TMemberDataContract.ArrayOfSSPIndividual objArrayOfSSP = new SSP_TMemberDataContract.ArrayOfSSPIndividual();
        objArrayOfSSP.SSPIndividual  = new List<SSP_TMemberDataContract.SSPIndividual>();
        SSP_TMemberDataContract.SSPIndividual objSSPInd = new SSP_TMemberDataContract.SSPIndividual();
        objSSPInd.AppliedForCC = true;
        objSSPInd.AppliedForKC = true;
        objSSPInd.AppliedForKTAP = true;
        objSSPInd.AppliedForMA = true;
        objSSPInd.AppliedForQP = true;
        objSSPInd.AppliedForSAFE = true;
        objSSPInd.AppliedForSNAP = true;
        objSSPInd.AppliedForSS = true;
        objSSPInd.DependentIndividualId = 34;
        objSSPInd.HouseholdStatus = 'true';
        objSSPInd.IndividualAge = 23;
        objSSPInd.IndividualId = 232424;
        objSSPInd.IsHeadOfHousehold = true;
        objSSPInd.LivingArrangement = 'True';
        objSSPInd.PurchasesAndPreparesTogether = true;
        objSSPInd.Relationship = new SSP_TMemberDataContract.ArrayOfSSPRelationship();
        objSSPInd.TaxFilingStatus = '';
        
        SSP_TMemberDataContract.CaseRequest objCaseReq = new SSP_TMemberDataContract.CaseRequest();
        objCaseReq.CaseNumber = 1;
        objCaseReq.EdbcRunDate = Datetime.newInstance(1960, 2, 17);
        objCaseReq.IndividualIds = new SSP_TMemberStubClass.ArrayOfint();
        SSP_TMemberDataContract.SSPRelationship objRel = new SSP_TMemberDataContract.SSPRelationship();
        objRel.IndividualId = 24;
        objRel.ReferenceIndividualId = 24;
        objRel.RelationshipTypeCode = '24';
        SSP_TMemberDataContract.ArrayOfSSPProgram objArrayOfPro = new SSP_TMemberDataContract.ArrayOfSSPProgram();
        objArrayOfPro.SSPProgram = new list<SSP_TMemberDataContract.SSPProgram>();
        
        SSP_TMemberDataContract.CaseProgramMemeberStatus objCaseProStat = new SSP_TMemberDataContract.CaseProgramMemeberStatus();
        objCaseProStat.IndividualID =34;
        objCaseProStat.MemberReason ='34';
        objCaseProStat.MemberStatus ='34';
        objCaseProStat.ProgramCode ='34';
        
        
        SSP_TMemberDataContract.CaseResponse objCaseRes = new SSP_TMemberDataContract.CaseResponse();
        objCaseRes.CaseMemeberStatusModels = new SSP_TMemberDataContract.ArrayOfCaseMemeberStatus();
        objCaseRes.CaseNumber = 45;
        objCaseRes.CaseProgramMemeberStatusModels = new SSP_TMemberDataContract.CaseProgramMemeberStatus();
        objCaseRes.EligibilityTransactionID = 34;
        objCaseRes.ErrorDetails = new SSP_TMemberDataContract.EDExceptionDetails();
        objCaseRes.IsSuccess = true;
        objCaseRes.Message = '34';
        
        SSP_TMemberDataContract.CaseMemeberStatus objCaseStat = new SSP_TMemberDataContract.CaseMemeberStatus();
        objCaseStat.CaseNumber = 12;
        objCaseStat.IndividualID = 12;
        objCaseStat.MemberStatus = '12';
        objCaseStat.MemberStatusReasonCode = '12';
        objCaseStat.MemberStatusReasonDescription = '12';
        
        SSP_TMemberDataContract.EDCustomDictionary objCustomDic = new SSP_TMemberDataContract.EDCustomDictionary();
        objCustomDic.Key = '122';
        objCustomDic.Value = '122';
        SSP_TMemberDataContract.ArrayOfEDCustomDictionary objArray = new SSP_TMemberDataContract.ArrayOfEDCustomDictionary();
        objArray.EDCustomDictionary = new list<SSP_TMemberDataContract.EDCustomDictionary>();
        
        SSP_TMemberCalloutClass.DetermineMemberResponse_element objDet = new SSP_TMemberCalloutClass.DetermineMemberResponse_element();
        objDet.DetermineMemberResult = new SSP_TMemberDataContract.CaseResponse();
        
        SSP_TMemberCalloutClass.DetermineMember_element objDetMember = new  SSP_TMemberCalloutClass.DetermineMember_element();
        objDetMember.caseRequest = new SSP_TMemberDataContract.CaseRequest(); 
        Map<String, Object> objResponse = new Map<String, Object>{
            SSP_InterfaceConstants.JSON_BODY=> JSON.serialize(objReq), 
                SSP_InterfaceConstants.IS_DEBUG => true
                };
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPTMember_METADATANAME, objResponse);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();
    }
    @isTest 
    static void tMemberTestExcep() {
       Test.setMock(WebServiceMock.class, new SSP_TMemberMockClass());
        Test.startTest();
        SSP_TMemberStubClass.ArrayOfint objArrayofInt = new SSP_TMemberStubClass.ArrayOfint();
        objArrayofInt.int_x = new List<Integer>();
        SSP_TMemberDataContract objDataContact = new SSP_TMemberDataContract();
        SSP_TMemberDataContract.SSPCaseRequest objReq = new SSP_TMemberDataContract.SSPCaseRequest();
        objReq.ApplicationNumber = 123233;
        Map<String, Object> objResponse = new Map<String, Object>{'body'=> JSON.serialize(objReq)};
        List<Object> lstData = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.SSPTMember_METADATANAME, objResponse);
        System.assertEquals(1,lstData.size(),'Wrong Output');
        Test.stopTest();
     }
}