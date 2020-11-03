/**
 * Class Name    : SSP_WDT_ConsumeWrapper
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
public class SSP_WDT_ConsumeWrapper {

    public String TokenId;
    public String KogId;
    public TokenAttributes TokenAttributes;
    public String SourceApplication;
    public String TargetApplication;

    public class TokenParams {
        public String KeyName;
        public String KeyValue;
    }

    public class TokenAttributes {
        public List<TokenParams> TokenParams;
    }

    public SSP_WDT_ConsumeWrapper() {
        
    }
}