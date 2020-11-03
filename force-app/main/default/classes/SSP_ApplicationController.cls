/*
* classname     :  SSP_ApplicationController
* @description  :  This class contains all methods to fetch data of applications.
* @author       :  Yathansh Sharma   
* @date         :  12/23/2019
* MODIFICATION LOG:
* DEVELOPER                     DATE                                DESCRIPTION
* ---------------------------------------------------------------------------------------------
  Yathansh Sharma               12/23/2019                          Created.
**/
public with sharing class SSP_ApplicationController {
    
    public static String caseApplicationRecordTypeId = Schema.describeSObjects(New String[]{'SSP_Application__c'}).get(0).getRecordTypeInfosByDeveloperName().get('Case').getRecordTypeId();
    
    /***************************************************************************************************
     * @author       Yathansh Sharma
     * @date         12/23/2019
     * @methodname   fetchApplicationList
     * @description  This method takes a list of application ids and uses it to query the relevant data for the applications.
     * @return       ssp_LightningResponse
     *****************************************************************************************************/
    @auraEnabled(cacheable=true)
    public static ssp_LightningResponse fetchApplicationList(String memberId, String callingComponent,String sspApplicationId,String roleType){ //Defect-392986 Added roleType param
        SSP_Utility.isAuthenticatedUser();
        List<String> idList = new List<String>();
        if(memberId == null || memberId == ''){
           // memberId = SSP_Utility.getCurrentUserMemberId(true);
            
        }
        if(sspApplicationId != null && sspApplicationId != ''){
              List<SSP_ApplicationIndividual__c> applicationIndividuals = SSP_ApplicationIndividualSelector.queryApplicationPrimaryIndividualData(sspApplicationId,new set<string>{});
                if(applicationIndividuals != null && !applicationIndividuals.isEmpty()){
                    memberId = applicationIndividuals[0].SSP_Member__c;
                }
        }else{
        memberId = SSP_RepsAssistersAgentsController.getMemberId(false);
        }
        ssp_LightningResponse response = new ssp_LightningResponse();
        list<SSP_ApplicationIndividual__c> individuals;

        List<SSP_ApplicationIndividual__c> applicationIndividualList;
        if(callingComponent == 'sspAssisterOrAgentModal'){
            applicationIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualCaseData(new Set<String>{'Id', 'SSP_Application__r.ProgramsApplied__c','ProgramsApplied__c', 'SSP_Application__r.Account__c','SSP_Application__r.Status__c','SSP_Application__r.DCCaseNumber__c','SSP_Application__r.Name','IsHeadOfHousehold__c'}, memberID, false, null);
        }else{
            applicationIndividualList = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'}, 
                                                                   new Set<String>{'id','SSP_Application__c'}, 
                                                                   new Map<String, String>{'SSP_Member__c'=>memberID, 'SSP_Application__r.Status__c'=>'AP'});
        }

        for(SSP_ApplicationIndividual__c app: applicationIndividualList){
           if(callingComponent == 'sspAssisterOrAgentModal' && app.IsHeadOfHousehold__c && app.SSP_Application__r.ProgramsApplied__c != null && (app.SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.MEDICAID) || app.SSP_Application__r.ProgramsApplied__c.contains(SSP_GlobalConstants.KHIPP))
             && ((app.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (app.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) >= 0)  && (app.SSP_Application__r.RecordType.DeveloperName=='SSP_Application')  && (app.ssp_application__r.Status__c == 'UN')) ||
                           ((app.SSP_Application__r.RecordType.DeveloperName=='Case') && app.ssp_application__r.DCCaseNumber__c != null))){
            idList.add(app.SSP_Application__c);
            }
        else if(callingComponent != 'sspAssisterOrAgentModal'){
             idList.add(app.SSP_Application__c);   
            }
        }
        Set<String> fieldSet = new Set<String>{'id', 'name', 'ProgramsApplied__c','DCCaseNumber__c', '(select id, SSP_Member__r.Name from SSP_ApplicationIndividuals__r)'};
            List<SSP_Application__c> applicationList = new List<SSP_Application__c>();
        Map<String, String> conditionMap = new Map<String, String>{'limit'=>'1000','id'=> String.join(idList,',')};
        if(callingComponent == null){
            conditionMap.put('RecordTypeId', SSP_ApplicationController.caseApplicationRecordTypeId);
        }
         Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
           String selectedRole =(sessionPart != null && sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionPart.get(SSP_GlobalConstants.SELECTED_ROLE)) :String.valueOf(sessionPart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
             SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('REPS_Home', selectedRole);
			 if(objMatrix != null && objMatrix.fieldPermissions != null && objMatrix.fieldPermissions.get('REPS_HOME_Assister') != null
                   && objMatrix.fieldPermissions.get('REPS_HOME_Assister') != 'NotAccessible' && String.isNotBlank(roleType) && SSP_GlobalConstants.ASSISTER_ROLE.equalsIgnoreCase(roleType)){ //Defect-392986 Added only roleType condition
                response.put('showAddButton',true);
            }
            //Start- Added as part of Defect 392986
            else if(objMatrix != null && objMatrix.fieldPermissions != null && objMatrix.fieldPermissions.get('REPS_HOME_Agent') != null
                   && objMatrix.fieldPermissions.get('REPS_HOME_Agent') != 'NotAccessible' && String.isNotBlank(roleType) && SSP_GlobalConstants.RoleType_Agent.equalsIgnoreCase(roleType)) {
                response.put('showAddButton',true);
            }
            //End - Added as part of Defect 392986
            if(idList != null ){
                try{
                    applicationList = SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c','operator'=>'AND', 'IN'=>'id'}, 
                                                                   fieldSet, 
                                                                   conditionMap);
                    if(!applicationList.isEmpty()){
                        response.put('responseData',applicationList);
                        response.put('defaultCase', evaluateDefaultCase(applicationList)); //#387346
                    }
                    response.bIsSuccess = true;
                }catch(Exception ex){
                    response.bIsSuccess = false;
                     List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationController', 'handleMedicaidRenewal', ex.getMessage() , true);    
                    
                    
                }
            }
        return response;
    }

    //#387346
    private static String evaluateDefaultCase(List<SSP_Application__c> applicationList){
        String defaultCase;
        DateTime defaultCaseDateTime;
        Map<String, String> caseNoToAppId = new Map<String, String>();
        try{
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);       
            String mapCaseVsEligibilityRunDateStr = sessionPart.get('mapCaseVsEligibilityRunDate') != null ? String.valueOf(sessionPart.get('mapCaseVsEligibilityRunDate')) : String.isNotBlank(String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'mapCaseVsEligibilityRunDate'))) ?
                                        String.valueOf(sessionPart.get(SSP_CacheBuilderImplementationDabhboard.class,'mapCaseVsEligibilityRunDate')) : '';
                                    
            if(String.isNotBlank(mapCaseVsEligibilityRunDateStr) && applicationList != null && !applicationList.isEmpty()){
                Map<String, String> mapCaseVsEligibilityRunDateMap = (Map<String, String>) JSON.deserialize(mapCaseVsEligibilityRunDateStr, Map<String, String>.class);
                Set<String> caseNos = new Set<String>();
                for(SSP_Application__c app : applicationList){
                    if(app != null && app.DCCaseNumber__c != null){
                        caseNos.add(String.valueOf(app.DCCaseNumber__c));
                        caseNoToAppId.put(String.valueOf(app.DCCaseNumber__c), app.Id);
                    }
                }
                for(String caseNo : mapCaseVsEligibilityRunDateMap.keySet()){
                    if(caseNos != null && caseNos.contains(caseNo)){
                        Datetime dateTimeValue = DateTime.ValueofGMT(mapCaseVsEligibilityRunDateMap.get(caseNo).replace('T', ' '));

                        defaultCaseDateTime = defaultCaseDateTime != null ? defaultCaseDateTime : dateTimeValue;
                        defaultCase = defaultCase != null ? defaultCase : caseNo;

                        if(dateTimeValue > defaultCaseDateTime){
                            defaultCaseDateTime = dateTimeValue;
                            defaultCase = caseNo;   
                        }
                    }
                }                                   
            }
        }
        catch(Exception ex){
            //LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationController', 'evaluateDefaultCase', ex.getMessage(), true);
        }
        return caseNoToAppId.containsKey(defaultCase) ? caseNoToAppId.get(defaultCase) : null;
    }


    @AuraEnabled
    public static ssp_LightningResponse handleMedicaidRenewal(String caseNo){ 
        SSP_Utility.isAuthenticatedUser();
        SSP_LightningResponse response = new SSP_LightningResponse();
        try{           
            if(caseNo != null){
                response = SSP_ProgramSelectionCtrl.updatePrograms(new Map<String, String>{
                    SSP_GlobalConstants.SSP_MODE => SSP_GlobalConstants.SSP_RENEWAL_FLOW,
                    SSP_GlobalConstants.SSP_CASE_NO => caseNo
                }, SSP_GlobalConstants.MEDICAID);
            }
            else{
                response.put('ERROR','CaseNo is NULL');
            }            
        } 
        catch(Exception ex){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_ApplicationController', 'handleMedicaidRenewal', ex.getMessage() , true);            
            response.addException(ex, lstLogMessages[0].Id);
        }
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static ssp_LightningResponse getProgramFromCache(){
        ssp_LightningResponse response = new ssp_LightningResponse();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        response.put('cacheResponse', sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits')));
        return response;
    }

    @AuraEnabled
    public static ssp_LightningResponse getRenewalWrapperData(Id applicationId){
        SSP_Utility.isAuthenticatedUser();
        ssp_LightningResponse response = new ssp_LightningResponse();

        SSP_RenewalDataWrapper responseWrapper = new SSP_RenewalDataWrapper();
        List<Contact> currentContactData;
        Id accountId;
      
        try{
            /**2.5 Security Role Matrix and Program Access. */
            String screenPermission = SSP_Utility.getScreenAccessDetails(SSP_GlobalConstants.GET_STARTED_RENEWAL_SCREENID, null).screenPermission;
            response.put('isNotAccessible', String.isNotBlank(screenPermission) && screenPermission.equalsIgnoreCase(SSP_GlobalConstants.NOT_ACCESSIBLE) ? true : false);                
            /** */


            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            if(sessionpart.get('hasMedicaidRenewals')!=null) {
                List<SSP_DashboardCaseInformation.Renewal> listMedicaidRenewal = (List<SSP_DashboardCaseInformation.Renewal>) System.JSON.deserialize(String.valueOf(sessionPart.get('hasMedicaidRenewals')), List<SSP_DashboardCaseInformation.Renewal>.class);
                if(listMedicaidRenewal != null && !listMedicaidRenewal.isEmpty()){
                    
                    responseWrapper.applicationNumber = listMedicaidRenewal[0].CaseNumber;
                    Date dueDate = SSP_Utility.today().addDays(Integer.valueOf(listMedicaidRenewal[0].RenewalDueDate));
                    responseWrapper.applicationDate = dueDate.format();
                    responseWrapper.programList = listMedicaidRenewal[0].RenewalProgramCode;
                    String individualId = ssp_utility.getIndividualId(); 
                    SSP_ReportChangeSelectionCtrl.updateIndividualId(listMedicaidRenewal[0].CaseNumber,individualId);
                }else{
                    response.put('error', 'Invalid Application Id');
                    return response;
                }
            }
        }catch(ListException e){
            
            
        }catch(NullPointerException e){
            
            
        }
        response.put('responseData', JSON.serialize(responseWrapper));
        return response;
    }

    public class SSP_RenewalDataWrapper{
        public String programList { get; set;}
        public String applicationDate { get; set;}
        public String applicationNumber { get; set;}
    }
}