public with sharing class RE_SDOHScore {
    /**************************************************************************************
    * @author       Arun Garg
    * @date         09/17/2019
    * @methodname   calculateSDOHScoreAndSaveCat
    * @description  This methods is used to calculate average SDOH score and create SDOH records and updating IsLatest of previous records of particular client
    * @param        @userAssessmentTempId,@clientId
    * @return       
    ******************************************************************************************/
    public static void calculateSDOHScoreAndSaveCat(String userAssessmentTempId,String clientId){
        Map<String, Object> errorMap    = new Map<String, Object>();
        try {            
            List<AssessmentResponse__c> lstAssessmentResponse ;
            Map<String,List<sObject>> mapSDOHWithAssRes=new Map<String,List<sObject>>();
            String sFieldsToQueryOnAssessmentRes = RE_DataBaseQueryFields.sFieldsToQueryOnAssessmentRes;
            String sWhereClauseOnAssessmentRes = RE_DataBaseQueryFields.sWhereClauseOnAssessmentRes;
            Map<String,String> mapAssessmentResQueryParameters = new Map<String,String>();
            mapAssessmentResQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAssessmentRes);
            
            String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
           
            String sQuery;
            Map<Boolean,String> mapAssessmentQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sAssessmentResponseObjectName, sFieldsToQueryOnAssessmentRes, mapAssessmentResQueryParameters);
            String switchCaseKey = (mapAssessmentQueryResponse.get(true) != null) ? 'success' : 'failure'; 
            switch on (switchCaseKey) {
                when 'success' {
                    
                    sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sAssessmentResponseObjectName, sFieldsToQueryOnAssessmentRes, mapAssessmentResQueryParameters);
                    
                    if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
                        
                       lstAssessmentResponse = Database.query(sQuery);  
                    }else{
                        
                       lstAssessmentResponse = RE_SharingByPassCtrl.fetchAssesmentResp(sQuery,userAssessmentTempId,clientId);
                        
                    }
                    
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapAssessmentQueryResponse.get(false), true);
                }
            }
            RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyAssessmentRes = (lstAssessmentResponse.size()>0 && lstAssessmentResponse!=null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
            switch on (switchCaseKeyAssessmentRes) {
             when SWITCH_SUCCESS {  
                for(AssessmentResponse__c assRes:lstAssessmentResponse){
                    //Force Reviewer Changes - Payal Dubela - 08/28
                    RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeyAnsChoice = (assRes.AnswerChoice__c!=null)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
                    switch on (switchCaseKeyAnsChoice) {
                    when SWITCH_SUCCESS {  
                        if(!mapSDOHWithAssRes.containsKey(assRes.Question__r.SDOH__c)){
                            mapSDOHWithAssRes.put(assRes.Question__r.SDOH__c, new List<sObject>{assRes});
                            
                        }else{
                            List<sObject> listAssResObj=mapSDOHWithAssRes.get(assRes.Question__r.SDOH__c);
                            listAssResObj.add(assRes);
                            mapSDOHWithAssRes.put(assRes.Question__r.SDOH__c, listAssResObj);
                        }
                    }
                 }
              }
                
                List<SDOH__c> lstSDOH=new List<SDOH__c>();
                if(mapSDOHWithAssRes!=null){
                    Set<String> setSDOHCat=mapSDOHWithAssRes.keyset();
                    for(String category:setSDOHCat){
                        SDOH__c objSDOH=new SDOH__c();
                        List<sObject> lstAssResObj=mapSDOHWithAssRes.get(category); 
                        objSDOH.Score__c=calucateAverageScore(lstAssResObj);
                        objSDOH.IsLatest__c=true;
                        objSDOH.Assessment__c=userAssessmentTempId;
                        objSDOH.AssessmentDate__c=Date.today();
                        objSDOH.Category__c=category;
                        objSDOH.Resident__c=clientId;
                        lstSDOH.add(objSDOH);
                    }
                    if(lstSDOH.size()>0 && lstSDOH!=null){
                        Boolean isrecordUpdated=updatePreviousIsLatestCheckRecords(setSDOHCat,clientId);
                        if(isrecordUpdated){
                            RE_SharingByPassCtrl.insertSobjects(SDOH__c.sObjectType, lstSDOH);
                        }
                        
                    }
                }
                
            }
         }
        } 
        catch (Exception e) {
            errorMap.put('error', e.getMessage());
            LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'calculateSDOHScoreAndSaveCat', 'calculateScore', e.getMessage()+'**Line='+e.getLineNumber(), true);
        }
    }
    /**************************************************************************************
    * @author       Arun Garg
    * @date         09/17/2019
    * @methodname   calucateAverageScore
    * @description  This methods is used to calculate average SDOH score and rounded off to set scale 1
    * @param        @lstAssResObj
    * @return       average calculates score
    ******************************************************************************************/
    public static Decimal calucateAverageScore(List<sObject> lstAssResObj){
        Decimal avgScore=0;
        Integer sizeAnsweredQuestion=lstAssResObj.size();
        for(AssessmentResponse__c  obj:(List<AssessmentResponse__c >)lstAssResObj){
            avgScore=avgScore+obj.AnswerChoice__r.Score__c;
        }
        avgScore=avgScore/sizeAnsweredQuestion;
        Decimal rounded = Math.round(avgScore * 100) / 100.0;
        return rounded.setScale(1);
    }
    /**************************************************************************************
    * @author       Arun Garg
    * @date         09/17/2019
    * @methodname   updatePreviousIsLatestCheckRecords
    * @description  This methods is used to updating IS_Latest field of previous records of particular client
    * @param        @setSDOHCats,@clientId
    * @return       Boolean
    ******************************************************************************************/
    public static Boolean updatePreviousIsLatestCheckRecords(Set<String> setSDOHCats,String clientId){
        List<SDOH__c> listupdatSDOH;
        List<Id> listSuccessIds=new List<Id>();
        Boolean isUpdated;
        String sFieldsToQueryOnSDOH = RE_DataBaseQueryFields.sFieldsToQueryOnSDOH;
        String sWhereClauseOnSDOH = RE_DataBaseQueryFields.sWhereClauseOnSDOH;
        Map<String,String> mapSDOHQueryParameters = new Map<String,String>();
        mapSDOHQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSDOH);
        Map<Boolean,String> mapSDOHQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.sSDOHObjectName, sFieldsToQueryOnSDOH, mapSDOHQueryParameters);
        String switchCaseKey = (mapSDOHQueryResponse.get(true) != null) ? 'success' : 'failure'; 
        switch on (switchCaseKey) {
            when 'success' {
                String sQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.sSDOHObjectName, sFieldsToQueryOnSDOH, mapSDOHQueryParameters);
                listupdatSDOH = RE_SharingByPassCtrl.getClientSDOH(clientId,sQuery,setSDOHCats); 
                
            }
            when 'failure' {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ClientDetailsCtrl','fetchAssessmentRecords','Some Fields doesn\'t have the required access :: '+mapSDOHQueryResponse.get(false), true);
            }
        }
        //Force Reviewer Changes - Payal Dubela - 08/28
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKeySdoh = (listupdatSDOH.size()>0)? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                            
        switch on (switchCaseKeySdoh) {
         when SWITCH_SUCCESS {  
            for(SDOH__c sdoh:listupdatSDOH){
                if(sdoh.IsLatest__c){
                    sdoh.IsLatest__c=false;
                }
            }
            isUpdated=RE_SharingByPassCtrl.updateSobjects(SDOH__c.sObjectType, listupdatSDOH);
        }
        when SWITCH_FAILURE { 
            isUpdated=true;
          }
        }
        return isUpdated;
    }
}