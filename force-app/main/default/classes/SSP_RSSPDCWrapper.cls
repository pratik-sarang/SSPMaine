/**
 * Classname                   :  logMessageWrapper
 * @description                :  LogMessage Wrapper Class
 * @author                     :  Rajeev Kumar
 * @date                       :  03/24/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName               MM/DD/YYYY                 A Brief Description about the Change
 **/
public class SSP_RSSPDCWrapper {
    //public attributes
    public Boolean boolIsDebug;
    public String sScreenNames;
    public String sInterfaceName;
    public List<String> lstAllViews;
    public LogMessageWrapper log;
    public Map<String, List<sObject>> mapsObjectList;
    public SSP_RetryWrapper retry;
    public SSP_RSSPDC_RequestWrapper objRequest;
    public String sFlowType;
    public User objUser;
    //PERF Fix
    public Boolean skipTransaction;
    // Bug- 382061
    public Boolean skipDML;
    public Boolean skipLog;
    public List<Account> lstAccounts;
    
    /**
     * @methodName                  : SSP_RSSPDCWrapper
     * @description                 : Default Constructor
     */
    public SSP_RSSPDCWrapper() {
        objRequest = new SSP_RSSPDC_RequestWrapper();
        log = new LogMessageWrapper();
        log.source= SSP_InterfaceConstants.RSSPDC_INTEGRATION_SERVICE;
        log.sourceFunction= SSP_InterfaceConstants.INVOKE_CALLOUT;
        retry = new SSP_RetryWrapper();
        boolIsDebug = false;
        skipTransaction = false;
        skipDML = false;
        skipLog = false;
    }
}