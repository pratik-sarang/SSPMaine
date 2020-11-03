/**
* Class Name    : RE_ResourceResponseWrapper
* Owner         : DELOITTE
* Created Date  : 04/21/2020
* Description   : 
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  04/21/2020  Payal Dubela       Initial Version
* */
public class RE_ResourceResponseWrapper { 
    
    public List<String> user_id;
    public ResourceData complementary_resource;
    public ResourceData similar_resource;
    public List<String> status;
    public List<String> E_message;
    
    public class ResourceData{
        public Set<String> resource_location_id;  
    }

}