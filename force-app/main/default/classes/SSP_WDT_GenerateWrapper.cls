/**
 * Class Name    : SSP_WDT_GenerateWrapper
 * Owner         : DELOITTE
 * Created Date  : 20/04/2020
 * Description   : This class will hold request information to Waiver Data Transfer Generate Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  20/04/2020  Ragunathan          Initial Version
 */
public class SSP_WDT_GenerateWrapper {
    public String kogId;
    public Map<String, String> attributeMap;
    public String sourceApplication;
    public String targetApplication;
    public String requestType;

    public SSP_WDT_GenerateWrapper() {

    }
}