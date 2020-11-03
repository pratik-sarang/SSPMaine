/**
 * Class Name    : SSP_WDT_IntegrationUtility
 * Owner         : DELOITTE
 * Created Date  : 20/04/2020
 * Description   : This class will have Utility methods for Waiver Data Transfer Integration Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  20/04/2020  Ragunathan          Initial Version
 */
public class SSP_WDT_IntegrationUtility {

    /**
     * method                                   : processRequestDetails
     * @description                             : Method to prepare for the request for the callout
     * @author                                  : Ragunathan
     * @param inputParams                       : Map of String SSP_WDT_GenerateWrapper request.
     * @return Map<String, String>              : Map of processed string request.
     */
    public static Map<String, Object> processRequestDetails(Map<String, Object> inputParams) {
        SSP_WDT_GenerateWrapper inputDetails = (SSP_WDT_GenerateWrapper) JSON.deserialize(
                                                                                (String)inputParams.get(SSP_InterfaceConstants.JSON_BODY),
                                                                                SSP_WDT_GenerateWrapper.Class);
        SSP_WDT_GenerateRequestWrapper generateRequest = new SSP_WDT_GenerateRequestWrapper();
        generateRequest.KogId = inputDetails.kogId;
        generateRequest.TokenAttributes = prepareTokenAttributesForGenerate(inputDetails.attributeMap);
        generateRequest.SourceApplication = inputDetails.sourceApplication;
        generateRequest.TargetApplication = inputDetails.targetApplication;
        generateRequest.RequestType = inputDetails.RequestType;

        return new Map<String, Object> {SSP_InterfaceConstants.JSON_BODY => JSON.serialize( generateRequest )};
    }

    /**
     * method                                                       : prepareTokenAttributesForGenerate
     * @description                                                 : Helper method to prepare List<SSP_WDT_GenerateRequestWrapper.TokenAttributes>
     * @author                                                      : Ragunathan
     * @param attributeMap                                          : Map of attribute tokens
     * @return List<SSP_WDT_GenerateRequestWrapper.TokenAttributes> : List of SSP_WDT_GenerateRequestWrapper.TokenAttributes data.
     */
    private static List<SSP_WDT_GenerateRequestWrapper.TokenAttributes> prepareTokenAttributesForGenerate(Map<String, String> attributeMap) {
        SSP_WDT_GenerateRequestWrapper.TokenAttributes tknAttributes = new SSP_WDT_GenerateRequestWrapper.TokenAttributes();
        List<SSP_WDT_GenerateRequestWrapper.TokenParams> tknParams = new List<SSP_WDT_GenerateRequestWrapper.TokenParams>();
        for(String tokenAttribute: attributeMap.keySet()) {
            SSP_WDT_GenerateRequestWrapper.TokenParams tknParam = new SSP_WDT_GenerateRequestWrapper.TokenParams();
            tknParam.KeyName    = tokenAttribute;
            tknParam.KeyValue   = attributeMap.get(tokenAttribute);

            tknParams.add(tknParam);
        }
        tknAttributes.TokenParams = tknParams;

        return new List<SSP_WDT_GenerateRequestWrapper.TokenAttributes> {tknAttributes} ;
    }    

    /**
     * method                                                       : processConsumeResponse
     * @description                                                 : Method to prepare SSP_WDT_ConsumeResponseWrapper for WDT Consume
     *                                                                Service class.
     * @author                                                      : Ragunathan
     * @param jsonResponse                                          : HttpResponse Body of Consume service.
     * @return SSP_WDT_ConsumeResponseWrapper                       : SSP_WDT_ConsumeResponseWrapper class data.
     */
    public static SSP_WDT_ConsumeResponseWrapper processConsumeResponse(String jsonResponse) {
        SSP_WDT_ConsumeWrapper response = (SSP_WDT_ConsumeWrapper) JSON.deserialize(jsonResponse, SSP_WDT_ConsumeWrapper.class);
        SSP_WDT_ConsumeResponseWrapper wrapResponse = new SSP_WDT_ConsumeResponseWrapper();
        wrapResponse.kogId             = response.KogId;
        wrapResponse.tokenId           = response.TokenId;
        wrapResponse.sourceApplication = response.SourceApplication;
        wrapResponse.targetApplication = response.TargetApplication;
        wrapResponse.tokenAttributes   = prepareTokenAttributesForConsume (response.TokenAttributes);

        return wrapResponse;
    }

    /**
     * method                                                       : prepareTokenAttributesForConsume
     * @description                                                 : Helper method to prepare attribute map from Response's attribute tokens
     * @author                                                      : Ragunathan
     * @param attributes                                            : SSP_WDT_ConsumeWrapper.TokenAttributes
     * @return Map<String, String>                                  : Map of token attributes.
     */
    private static Map<String, String> prepareTokenAttributesForConsume(SSP_WDT_ConsumeWrapper.TokenAttributes attributes) {
        List<SSP_WDT_ConsumeWrapper.TokenParams> attributeParams = attributes.TokenParams;
        Map<String, String> attributeMap = new Map<String, String>();
        for(Integer i = 0; i<attributeParams.size(); i++) {
            SSP_WDT_ConsumeWrapper.TokenParams tp = attributeParams[i];
            attributeMap.put(tp.KeyName, tp.KeyValue);
        }

        return attributeMap;
    }
}