/*
* Classname                 :  SSP_ContactInfoUpdateResponseWrapper
* @description              :  This class is response Wrapper for SSP-DC Contact Info Update
* @author                   :  Rajeev Kumar
* @date                     :  03/04/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
**/
public with sharing class SSP_ContactInfoUpdateResponseWrapper {
    //public attributes
    public Boolean status;
    public Integer intStatusCode;
    public SSP_AckResponseWRapper AckResponse;
     
    /**
    * method                : parseContactUpdateResponse
    * @description          : This method is to parse the contact udpate response
    * @author               : Rajeev Kumar
    * @param json           : Response body of Update Contact Info
    * @return               : SSP_VCIResponseWrapper
    * */
    public static SSP_ContactInfoUpdateResponseWrapper parseContactUpdateResponse(String json){
        return (SSP_ContactInfoUpdateResponseWrapper) System.JSON.deserialize(json, SSP_ContactInfoUpdateResponseWrapper.class);
    }

    /**
     * @description         : Default Constructor
     */
    public SSP_ContactInfoUpdateResponseWrapper() {
        status = false;
        AckResponse = new SSP_AckResponseWRapper();

    }
}