/*
* Classname     :  SSP_CCProviderSearch_RequestWrapper
* @description  :  This class is holds the request data for SSP child care ProviderSearch
* @author       :  Ragunathan
* @date         :  05/14/2020
* MODIFICATION LOG:
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------
* DeveloperName       MM/DD/YYYY          A Brief Description about the Change
* Ragunathan		  05/14/2020			Initial creation
**/

public with sharing class SSP_CCProviderSearch_RequestWrapper {
    
    public String SubmitType;
    public ChildCareProviderDetailsRequest ChildCareProviderDetailsRequest;
    public SSP_CCProviderSearch_RequestWrapper() {
        
    }

    public class ChildCareProviderDetailsRequest {
        public String AddressLattitude;
        public String AddressLongitude;
        public String ProviderName;
        public String LicenseNumber;
        public String ProviderIDValues;
        public Boolean IsFavoriteSearch;

        public ChildCareProviderDetailsRequest() {

        }
    }
}