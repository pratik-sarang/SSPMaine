/*
 * Classname             : SSP_PastApplicationsController
 * @description          : This is controller class for Past Application widget
 * @author               : Anuja Ingole
 * @date                 : 06/09/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_PastApplicationsController {
    public static Map<String,String> prgCodeToPrgmName = new Map<String, String>();
    public SSP_PastApplicationsController() {

    }

    @AuraEnabled
   public static SSP_LightningResponse fetchPastApplications(){
    prgCodeToPrgmName.put('MA', System.Label.SSP_MedicaidDisqualification); //'Medicaid/KCHIP'
    prgCodeToPrgmName.put('SN', System.Label.SSP_SnapDisqualification); //'SNAP (Food Assistance)'
    prgCodeToPrgmName.put('KT', System.Label.SSP_CashDisqualification);//'KTAP (Cash Assistance)'
    prgCodeToPrgmName.put('CC', System.Label.SSP_ChildCareDisqualification );//'Child Care Assistance'
    prgCodeToPrgmName.put('KP', System.Label.SSPHealthInsuranceDisqualifiaction);//'KI-HIPP (Health Insurance Premium Payments)'
    prgCodeToPrgmName.put('SS', System.Label.SSP_StateDisqualification);   //'State Supplementation'
    SSP_LightningResponse response = new SSP_LightningResponse();
    List<SSP_PastApplicationsPayloadWrapper.SSP_PastApplicationsWrapper> result = null;
    Map<Integer, List<SSP_PastApplicationsWrapper>> mapData = new Map<Integer, List<SSP_PastApplicationsWrapper>>();
    String individualId = SSP_Utility.getIndividualId();
    if(individualId != null){
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.PAST_APPLICATIONS;
        reqWrapper.primaryApplicationIndividualId = individualId; //650000808;
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);             
        
        if(serviceResponses!= null){
            RSSP_DC_Wrapper dCWrapper = (RSSP_DC_Wrapper) serviceResponses.get(0);
            SSP_PastApplicationsPayloadWrapper pastAppsWrapper = new SSP_PastApplicationsPayloadWrapper();
            pastAppsWrapper = (SSP_PastApplicationsPayloadWrapper) dCWrapper.PastApplicationsPayload ;
            if(pastAppsWrapper != null){
                result = pastAppsWrapper.PASTAPPLICATIONS;
            }
        }
        if(result != null){
            

            for(SSP_PastApplicationsPayloadWrapper.SSP_PastApplicationsWrapper app: result){
                SSP_PastApplicationsWrapper pastApp = new SSP_PastApplicationsWrapper();
                pastApp.individualId = app.IndividualId;
                pastApp.caseNumber = app.CaseNumber;
                pastApp.applicationNumber = app.ApplicationNumber;
                pastApp.caseStatus = app.CaseStatusCode;
                if(app.ProgramAppliedFor != null){
                    for(String prgCode: app.ProgramAppliedFor.split(';')){
                        if(pastApp.programsApplied != null && pastApp.programsApplied != ''){
                            pastApp.programsApplied = pastApp.programsApplied + ', '+ prgCodeToPrgmName.get(prgCode);
                        }
                        else{
                            pastApp.programsApplied = prgCodeToPrgmName.get(prgCode);
                        }
                        
                    }
                }
                pastApp.dmsId = app.DMSId;
                
                //Format application submitted date as per MM/DD/YYYY
                if(app.ApplicationReceivedDate != null){
                    List<String> lstStartDate = app.ApplicationReceivedDate.split('-');
                    //received format YYYY-MM-DD. Expected Format - MM/DD/YYYY.
                    String startDate = lstStartDate[1]+'/'+lstStartDate[2]+'/'+lstStartDate[0];
                    pastApp.submittedDate = startDate;
                    pastApp.submittedDateDate = Date.parse(startDate);
                }

                if(!mapData.isEmpty() && mapData.containsKey(app.CaseNumber)){
                    List<SSP_PastApplicationsWrapper> apps = mapData.get(app.CaseNumber);
                    apps.add(pastApp);
                    apps.sort();// This will sort in ascending order. 
                    List<SSP_PastApplicationsWrapper> appsDesc = new List<SSP_PastApplicationsWrapper>();
                    for(Integer i=apps.size()-1; i>=0; i--){
                        appsDesc.add(apps.get(i));
                    }
                    mapData.put(app.CaseNumber, appsDesc);
                }
                else{
                    mapData.put(app.CaseNumber, new List<SSP_PastApplicationsWrapper>{pastApp});
                }
            }


            if(mapData.size()>0){
                response.put('mapData',JSON.serialize(mapData));
            }

        }
    }
    Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
          
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('BEN_PAPP',selectedRole);
           
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                response.put('showScreen',true);
            }else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
                response.put('showScreen',false);
                
            }
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='ReadOnly'){
                response.put('showScreen',true);
            }

    return response;
    }

    public class SSP_PastApplicationsWrapper implements Comparable {
        // public attributes
        public Integer individualId;
        public Integer caseNumber;
        public Integer applicationNumber;
        public String submittedDate;
        public String programsApplied;
        public String dmsId;
        public Date submittedDateDate;
        public String caseStatus;

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            SSP_PastApplicationsWrapper pastApp = (SSP_PastApplicationsWrapper)compareTo;
            if (submittedDateDate == pastApp.submittedDateDate) return 0;
            if (submittedDateDate > pastApp.submittedDateDate) return 1;
            return -1;        
        }
    }
}