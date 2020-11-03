/*
* Classname         :  SSP_CreateHearingIntegrationServiceMock
* @description  :  This class is to mock the response for SSP_CreateHearingIntegrationServiceTest
* @author       :  Rijia Khatun
* @date         :  08/3/2020 
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description 
                               about the Change
**/
public class SSP_CreateHearingIntegrationServiceMock  implements WebServiceMock {
    public void doInvoke (Object stub, Object request,Map<String, Object> response,String endpoint,
        String soapAction,String requestName,String responseNS,String responseName,String responseType) {
            SSP_HearingDataContractOrg.CitizenHearingResponse objResponse = new SSP_HearingDataContractOrg.CitizenHearingResponse();
            objResponse.Status = true;
            objResponse.HearingId = 'qw434';
            objResponse.Error = new SSP_HearingDataContractOrg.SFHearingCommonError();
            objResponse.Error.CHFSExceptionId = '123';
            response.put('response_x',objResponse);
        }
        
}

