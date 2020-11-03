/**
 * Class Name    : SSP_WDT_ConsumeResponseWrapper
 * Owner         : DELOITTE
 * Created Date  : 21/04/2020
 * Description   : This class will hold response information to Waiver Data Transfer Consume Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer            Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  21/04/2020  Ragunathan          Initial Version
 */
public with sharing class SSP_WDT_ConsumeResponseWrapper {

    public String tokenId;
    public String kogId;
    public Map<String, String> tokenAttributes;
    public String sourceApplication;
    public String targetApplication; 

    public SSP_WDT_ConsumeResponseWrapper() {
        
    }
}