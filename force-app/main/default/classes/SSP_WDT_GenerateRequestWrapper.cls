/**
 * Class Name    : SSP_WDT_GenerateRequestWrapper
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
public with sharing class SSP_WDT_GenerateRequestWrapper {

    public String KogId;
    public List<TokenAttributes> TokenAttributes;
    public String SourceApplication;
    public String TargetApplication;
    public String RequestType;

    public class TokenParams {
        public String KeyName;
        public String KeyValue;
    }

    public class TokenAttributes {
        public List<TokenParams> TokenParams;
    } 

    public SSP_WDT_GenerateRequestWrapper() {
        
    }
}