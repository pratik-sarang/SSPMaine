/*
* Classname     	:  SSP_CCReport_RequestWrapper
* @description  	:  This class is holds the request data for SSP child care Provider Report service
* @author       	:  Ragunathan
* @date         	:  05/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  05/14/2020			Initial creation
**/
public class SSP_CCReport_RequestWrapper {

    public String SubmitType;
    public ChildCareProviderDetailsFileRequest ChildCareProviderDetailsFileRequest;
    public SSP_CCReport_RequestWrapper () {
        
    }
    public class ChildCareProviderDetailsFileRequest {
        public String Source;
        public String ReportName;
        public String ReportType;
        public String InspectionId;
        public String PlanOfCorrectionID;

        public ChildCareProviderDetailsFileRequest() {

        }
    }
}