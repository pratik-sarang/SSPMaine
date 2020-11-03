@isTest
global class kyHbeMciDatacontractsMock implements WebServiceMock {
    global Boolean isNoMatch=false;
    global Boolean isThrowException=false;
    global void doInvoke(
        Object stub,
        Object request,
        Map<String, Object> response,
        String endpoint,
        String soapAction,
        String requestName,
        String responseNS,
        String responseName,
        String responseType) { 

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
            lstentitySearchMock.add(entitySearchMock);
            schemasDatacontractOrg200407KyHbe.EntitySearchResponse[] EntitySearchResponse = lstentitySearchMock;
            schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse ResultMock = new schemasDatacontractOrg200407KyHbe.ArrayOfEntitySearchResponse();
            ResultMock.EntitySearchResponse = lstentitySearchMock;
            kyHbeMciDatacontracts.MciEntitySearchResponse data = new kyHbeMciDatacontracts.MciEntitySearchResponse();
            data.IsRecordFound = true;
            data.Result = ResultMock;
            kyHbeMci.EntityMciSearchResponse_element resp  = new kyHbeMci.EntityMciSearchResponse_element();
            if(!isThrowException){
                resp.EntityMciSearchResult = data;
            }else{
                resp.EntityMciSearchResult =null;
            }
             
            response.put('response_x',resp); 
            
        }
}