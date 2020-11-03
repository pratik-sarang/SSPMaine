/*
 * Classname         :  SSP_AckResponseWRapper
 * @description  :  Wrapper to handle error code and error message
 * @author       :  Rajeev Kumar
 * @date         :  03/10/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_AckResponseWRapper {
    // public attributes
    public String AckResponseCode;
    public string AckResponseDescription;
    
    /*
     * @method Name                     : SSP_AckResponseWRapper  
     * @descripton                      : Default Constructor
     */
    public SSP_AckResponseWRapper() {
        
    }
    /*
     * @method Name                     : SSP_AckResponseWRapper  
     * @descripton                      : parameterized Constructor
     * @param AckResponseCode           : Ack Response Code
     * @param AckResponseDescription    : Ack Response Description
     */
    public SSP_AckResponseWRapper(String AckResponseCode, String AckResponseDescription) {
        this.AckResponseCode = AckResponseCode;
        this.AckResponseDescription = AckResponseDescription;        
    }
}