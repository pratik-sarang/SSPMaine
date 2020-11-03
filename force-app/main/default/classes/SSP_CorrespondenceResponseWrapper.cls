/**
* Class Name    : SSP_CorrespondenceResponseWrapper
* Owner         : DELOITTE
* Created Date  : 11/12/2019
* Description   : Class that holds request for SSP_CorrespondenceUtilityService
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer          			Description                                                         
*  ----------  -------------------------   -------------------------------------------------------------------
*  11/12/2019  Kommana Lova Durga Prasad   Initial Version
*/
public class SSP_CorrespondenceResponseWrapper {

    public Integer StatusCode;
    public boolean isSuccess;
    public string LogId;
    public AckResponse AckResponse;
    public Integer ProcessRequestTrigger;	
    public String ImproperRequest;	
    public String GenerateCorrName;	
    public String GenerateCorrByteString;	
    public class AckResponse{
        public String AckResponseCode;
        public String AckResponseDescription;
        
    }
    
   
	public static SSP_CorrespondenceResponseWrapper parse(String json){
		return (SSP_CorrespondenceResponseWrapper) System.JSON.deserialize(json, SSP_CorrespondenceResponseWrapper.class);
	}

}