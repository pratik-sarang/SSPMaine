/*
* Classname     :  SSP_MCIForBenefitMockClass
* @description  :  This class is to mock the response for SSP_MCIForBenefitIntegrationService
* @author       :  Ragunathan
* @date         :  26/06/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan          26/06/2020            Initial Creation
**/
public class SSP_MCIForBenefitMockClass implements WebServiceMock {
    public Boolean isNoMatch=false;
    public Boolean isThrowException=false;

public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
    String soapAction,String requestName,String responseNS,String responseName,String responseType) {

        List<kyHbeMciDatacontracts.SourceSystem> lstkyhbss = new List<kyHbeMciDatacontracts.SourceSystem>();
        kyHbeMciDatacontracts.SourceSystem kyhbss = new kyHbeMciDatacontracts.SourceSystem();
        kyhbss.SourceSystemName = 'HBE';
        kyhbss.SourceIndividualId = '234567788';
        kyHbeMciDatacontracts.SourceSystem kyhbss1 = new kyHbeMciDatacontracts.SourceSystem();
        kyhbss1.SourceSystemName = 'HBE';
        kyhbss1.SourceIndividualId = '546789023';
        kyHbeMciDatacontracts.SourceSystem kyhbss2 = new kyHbeMciDatacontracts.SourceSystem();
        kyhbss2.SourceSystemName = 'HBE';
        kyhbss2.SourceIndividualId = '546734567';
        if(!isNoMatch){
            lstkyhbss.add(kyhbss2);
            lstkyhbss.add(kyhbss1);
            lstkyhbss.add(kyhbss);
        }
        kyHbeMciDatacontracts.ArrayOfSourceSystem sourceSystemResp = new kyHbeMciDatacontracts.ArrayOfSourceSystem();
        sourceSystemResp.SourceSystem = lstkyhbss;
        List<schemasDatacontractOrg200407KyHbe.EntitySearchResponse> lstentitySearchMock = new List<schemasDatacontractOrg200407KyHbe.EntitySearchResponse>();
        schemasDatacontractOrg200407KyHbe.EntitySearchResponse entitySearchMock = new schemasDatacontractOrg200407KyHbe.EntitySearchResponse();
        entitySearchMock.Source = sourceSystemResp;
        entitySearchMock.MatchStatus=SSP_GlobalConstants.FullMatch_Label;
        lstentitySearchMock.add(entitySearchMock);
        schemasDatacontractOrg200407KyHbe.EntitySearchResponse[] EntitySearchResponse = lstentitySearchMock;
        schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse ResultMock = new schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse();
        ResultMock.EntitySearchResponse = lstentitySearchMock;
        kyHbeMciDatacontracts.MciEntitySearchResponse entityResponse = new kyHbeMciDatacontracts.MciEntitySearchResponse();
        if(!isNoMatch){
            entityResponse.IsRecordFound = true;
        }else{
            entityResponse.IsRecordFound = false;
        }
        if(!isThrowException){
            entityResponse.Result=ResultMock;
        }else{
            entityResponse.Result=null;
        }
        kyHbeMci.EntityMciSearchResponse_element mciResponse = new kyHbeMci.EntityMciSearchResponse_element();
        mciResponse.EntityMciSearchResult = entityResponse;
        response.put('response_x', mciResponse);
    }
}