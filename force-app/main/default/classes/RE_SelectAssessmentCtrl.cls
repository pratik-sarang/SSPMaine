public with sharing class RE_SelectAssessmentCtrl {
    
    @AuraEnabled
    public static RE_CreateLightningServerResponse fetchrec(){        
       GeneralUtility.isAuthenticatedUser();
       RE_CreateLightningServerResponse cplocresponse=RE_ClientDetailsCtrl.fetchAssessmentRecords();       
       return cplocresponse;        
      /*  GeneralUtility.isAuthenticatedUser();
        List<Assessment__c> lstAssessment ;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                try{
                    Id assessmentRecordTypeId = GeneralUtility.getRecrodTypeIdBySobjectAndDevName(RE_GlobalConstants.sAssessmentObjectName, RE_GlobalConstants.sAssessmentDeveloperName);
                    String sFieldsToQueryOnAssessment = RE_DataBaseQueryFields.sFieldsToQueryOnAssessment;
                    String sOrderby = RE_DataBaseQueryFields.sOrderByNameAsc;
                    String sWhereClauseOnAssessment = RE_DataBaseQueryFields.sWhereClauseOnAssessment;
                    Map<String,String> mapAssessmentQueryParameters = new Map<String,String>();
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby);
                    mapAssessmentQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAssessment);
                    Map<Boolean,String> mapAssessmentQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sAssessmentObjectName, sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                    String switchCaseKey = (mapAssessmentQueryResponse.get(true) != null) ? 'success' : 'failure'; 
                    switch on (switchCaseKey) {
                        when 'success' {
                            String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sAssessmentObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnAssessment, mapAssessmentQueryParameters);
                            lstAssessment = Database.query(sQuery); 
                            bSuccess = true;
                            mapResponse.put('assessmentRecords', lstAssessment);
                        }
                        when 'failure' {
                            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapAssessmentQueryResponse.get(false), true);
                        }
                    }
                }catch(Exception e){errorMap.put('error', e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords', e.getMessage(), true);}
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse); */
    } 
    }