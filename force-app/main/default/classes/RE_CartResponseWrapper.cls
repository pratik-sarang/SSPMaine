/**
* Class Name    : RE_CartResponseWrapper
* Owner         : DELOITTE
* Created Date  : 04/23/2020
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/23/2020  Srikanth         Initial Version
* */
public class RE_CartResponseWrapper {
    
    public List<String> user_id;
	public ResourceLocationID resourceLocationID;
	public List<String> status;
	public List<String> E_message;
	public List<String> model_version;
   
	public class ResourceLocationID {
		public List<String> resource_location_id;
	}

	
}