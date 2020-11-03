/*
* Classname     :  SSP_FraudSubmission_ResponseWrapper
* @description  :  This class is to hold response data of Fraud Submission service
* @author       :  Ragunathan
* @date         :  07/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  07/14/2020			Initial creation
**/
public class SSP_FraudSubmission_ResponseWrapper {
    
    public SubmitFraudResult SubmitFraudResult;
    public AckResponse AckResponse;
    public String logName;
    
    public class SubmitFraudResult {
        public String FraudReportId;
        public String ExceptionId;
        public boolean showVerbiage; 
        
        public SubmitFraudResult() {
            
        }
    }
    
    public class AckResponse {
        public String AckResponseCode;
        public String AckResponseDescription;
        public AckResponse (){
            
        }
    }
    
    public SSP_FraudSubmission_ResponseWrapper () {
        
    }
}