/**
 * Class Name    : SSP_UpdateDCRepResponseWrapper
 * Owner         : DELOITTE
 * Created Date  : 23/04/2020
 * Description   : This class will hold the response data for Update DC Representative service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  23/04/2020  Ragunathan          Initial Version
 */
public class SSP_UpdateDCRepResponseWrapper {
    public AckResponse AckResponse;
    public class Error {
        public String ErrorCode;
        public String ErrorDescription;
        public String CHFSExceptionId;
    }
    
    public class AckResponse {
        public Boolean Success;
        public Error Error;
    }
}