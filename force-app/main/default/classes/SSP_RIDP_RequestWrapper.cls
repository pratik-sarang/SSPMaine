/**
 * Class Name    : SSP_RIDP_RequestWrapper
 * Owner         : DELOITTE
 * Created Date  : 05/26/2020
 * Description   : This class will hold the request information for SSP RIDP service call.
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date        Developer          Description                                                         
 *  ----------  --------------     ------------------------------------------------------------------
 *  05/26/2020  Ragunathan		   Initial Version
 */
public with sharing class SSP_RIDP_RequestWrapper {
    //Check Resume Request
    public SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserResume RIDPUserResume;
    //Get Question Details Request
    public SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserInfo RIDPUserInfo;
    //Post Answers Request
    public SSP_RIDP_DatacontractOrg200407Kogserv.RIDPUserReply RIDPUserReply;
    public String userKOGID;
    
    public SSP_RIDP_RequestWrapper() {
        
    }
}