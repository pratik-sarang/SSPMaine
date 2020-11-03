/*********************************************************************************************************************************
* Class Name    : RE_GetReportsCtrl 
* Owner         : Arun 
* Created Date  : 08/23/2019 
* Description   : get report from the folder
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     ----------------------------------------------------------------------------------------------------
*
**/
public with sharing class RE_GetReportsCtrl {
    @AuraEnabled
    public static RE_CreateLightningServerResponse getReports(){
        GeneralUtility.isAuthenticatedUser();
        Boolean bSuccess = false;
        List<Report> reportList;
        Map<String, Object> errorMap = new Map<String, Object>{};
        Map<String, Object> mapResponse = new Map<String, Object>{};
        String reportFolderName=RE_GlobalConstants.sfolderName;
        Id myFolderId;
        try{
            // Query creation for folder
            String sFieldsToQueryOnFolder = RE_DataBaseQueryFields.sFieldsToQueryOnFolder;
            String sWhereClauseOnFolder = RE_DataBaseQueryFields.sWhereClauseOnFolder;
            Map<String,String> mapFolderQueryParameters = new Map<String,String>();
            mapFolderQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnFolder);
            Map<Boolean,String> mapFolderQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Folder', sFieldsToQueryOnFolder, mapFolderQueryParameters);
            // Query creation for report
            String sFieldsToQueryOnReport = RE_DataBaseQueryFields.sFieldsToQueryOnReport;
            String sWhereClauseOnReport = RE_DataBaseQueryFields.sWhereClauseOnReport;
            Map<String,String> mapReportQueryParameters = new Map<String,String>();
            mapReportQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnReport);
            Map<Boolean,String> mapReportQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('Report', sFieldsToQueryOnReport, mapReportQueryParameters);
            String switchFolderKey = (mapFolderQueryResponse.get(true) != null) ? 'success' : 'failure'; 
            switch on (switchFolderKey) {
                when 'success' {
                    String sFolderQuery = mapFolderQueryResponse.get(true);
                    List<Folder> lstFolder= (List<Folder>)Database.query(sFolderQuery);
                    myFolderId=lstFolder[0].Id;
                    String switchReportKey = (mapReportQueryResponse.get(true) != null) ? 'success' : 'failure'; 
                    switch on (switchReportKey) {
                        when 'success' {
                            String sReportQuery = mapReportQueryResponse.get(true);
                            reportList= (List<Report>)Database.query(sReportQuery);
                            bSuccess = true;
                    		mapResponse.put('reportsName', reportList);
                        }
                        when 'failure' {
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GetReportsCtrl','getReports','Some Fields doesn\'t have the required access :: '+mapReportQueryResponse.get(false), true);
                        }
                    }
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GetReportsCtrl','getReports','Some Fields doesn\'t have the required access :: '+mapFolderQueryResponse.get(false), true);
                }
            }
        }catch(Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_GetReportsCtrl','getReports', e.getMessage(), true);
        }
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }
}