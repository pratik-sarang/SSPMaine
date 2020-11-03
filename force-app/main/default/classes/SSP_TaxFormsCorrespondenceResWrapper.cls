/*
 * Classname                            :  SSP_TaxFormsCorrespondenceResWrapper
 * @description                         :  Wrapper to read Tax Forms Correspondence Response
 * @author                              :  Rajeev Kumar
 * @date                                :  07/17/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_TaxFormsCorrespondenceResWrapper {
    // public attributes
    public List<SaveResultResponseWrapper> SaveResultResponse;
    public SSP_AckResponseWrapper AckResponse;
   
    /**
     * ClassName            : SaveResultResponseWrapper
     * @description         : Save Result Response Wrapper
     */
    public class SaveResultResponseWrapper {
        // public attributes
        public String IsSuccess;
        public List<MessagesWrapper> Messages;
    }

    /**
     * ClassName            : MessagesWrapper
     * @description         : Messages Wrapper
     */
    public class MessagesWrapper {
        //public attributes
        public String Message;
    }

    /**
    * method                : SSP_TaxFormsCorrespondenceResWrapper
    * @description          : Default Constructor
    * @author               : Rajeev Kumar
    * @return               : SSP_TaxFormsCorrespondenceResWrapper
    * */
    public SSP_TaxFormsCorrespondenceResWrapper() {
    }

    /**
    * method                : parseTAXCorrespondenceResponse
    * @description          : This method is to parse Tax Correspondence Response
    * @author               : Rajeev Kumar
    * @param sJSON           : Response body of Tax Corresponde call
    * @return               : SSP_TaxFormsCorrespondenceResWrapper
    * */
    public static SSP_TaxFormsCorrespondenceResWrapper parseTAXCorrespondenceResponse(String sJSON){
        return (SSP_TaxFormsCorrespondenceResWrapper) System.JSON.deserialize(sJSON, SSP_TaxFormsCorrespondenceResWrapper.class);
    }
}