/**
 * Class Name    : SSP_RSSPDC_RequestWrapper
 * Owner         : DELOITTE
 * Created Date  : 02/10/2020
 * Description   : Class holds the request of Reverse SSPDC Integration Service
 *
 *                            M O D I F I C A T I O N   L O G                                          
 *
 *  Date         Developer          Description                                                         
 *  ----------  --------------     -------------------------------------------------------------------
 *  02/10/2020   Rajeev Kumar       Initial Version
 */
public with sharing class SSP_RSSPDC_RequestWrapper {
    //public attributes
    public Integer caseNumber;
    public String primaryApplicationIndividualId;
    public String viewName;
    public String individualIds;
    public String programCode;
    public String mode;
    public String role;
    public String applicationID;
    public String miscelleanousParameter;
    public List<KeyValueParametersWrapper> KeyValueParameters;
    
    /**
     * @description     : Default Constructor
     */
    public SSP_RSSPDC_RequestWrapper() {
        caseNumber=0;
        primaryApplicationIndividualId='';
        viewName='';
        individualIds='';
        programCode='';
        mode='';
        applicationID='';
        miscelleanousParameter='';
        role = '';
    }
    
    /**
    * Class Name    				: KeyValueParametersWrapper
    * Description         			: Wrapper class for keyValueParmeters
    */
    public class KeyValueParametersWrapper {
        //public attributes
        public String Key;
        public String Value;
        public KeyValueParametersWrapper(String Key, String Value) {
            this.Key = Key;
            this.Value = Value;
        }
    }
}