/**
 * Class Name                : SSP_ProviderSearchResponseWrapper
 * Owner                     : DELOITTE
 * Created Date              : 02/10/2020
 * Description               : Wrapper for Provider Search Interface
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/10/2020  Rajeev Kumar         Initial Version
 */
public class SSP_ProviderSearchResponseWrapper {
    // public Attributes
    public ResultsWrapper  Results;
    public Integer sStatusCode;
    public SSP_AckResponseWRapper AckResponse;
    
    /**
     * @description         : Defeault Constructor
     */
    public SSP_ProviderSearchResponseWrapper(){
        AckResponse = new SSP_AckResponseWRapper();
    }
    
    /**
     * @description         : Wrapper Class
     */
    public class ResultsWrapper {
        public List<ProviderSearchResultWrapper> ProviderSearchResult;

    }

    /**
     * @description         : Wrapper Class
     */
    public class ProviderSearchResultWrapper {
        public Integer OrganizationId;
        public String OrganizationName;
        public String OrganizationAddress;
    }

    /**
    * method                : parseProviderSearch
    * @description          : Method to parse json response
    * @author               : Rajeev Kumar
    * @param json           : Response for deserialization
    * @param mapParams      : Parameters to build request
    * @return               : SSP_ProviderSearchResponseWrapper
    * */
    public static SSP_ProviderSearchResponseWrapper parseProviderSearch(String json) {
        return (SSP_ProviderSearchResponseWrapper) System.JSON.deserialize(json, SSP_ProviderSearchResponseWrapper.class);
    }
}