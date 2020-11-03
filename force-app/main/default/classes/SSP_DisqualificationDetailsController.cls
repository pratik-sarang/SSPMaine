/*
 * Classname             : SSP_DisqualificationDetailsController
 * @description          : This is controller class for Disqualification Details widget
 * @author               : Anuja Ingole
 * @date                 : 06/01/2020
 * MODIFICATION LOG:
 * DEVELOPER                     DATE                               DESCRIPTION
 * ---------------------------------------------------------------------------------------------
 * DeveloperName       MM/DD/YYYY          A Brief Description about the Change
 **/
public with sharing class SSP_DisqualificationDetailsController {
    public static Map<String,String> prgCodeToPrgmName = new Map<String, String>();
    public static Map<String,String> mapDisqTypeCodeToLabel = new Map<String, String>();
    

   @AuraEnabled
   public static SSP_LightningResponse fetchDisqualificationData(String individualId){
    SSP_LightningResponse response = new SSP_LightningResponse();
        prgCodeToPrgmName.put('MA', System.Label.SSP_MedicaidDisqualification); //'Medicaid/KCHIP'
        prgCodeToPrgmName.put('SN', System.Label.SSP_SnapDisqualification); //'SNAP (Food Assistance)'
        prgCodeToPrgmName.put('KT', System.Label.SSP_CashDisqualification);//'KTAP (Cash Assistance)'
        prgCodeToPrgmName.put('CC', System.Label.SSP_ChildCareDisqualification );//'Child Care Assistance'
        prgCodeToPrgmName.put('KP', System.Label.SSPHealthInsuranceDisqualifiaction);//'KI-HIPP (Health Insurance Premium Payments)'
        prgCodeToPrgmName.put('SS', System.Label.SSP_StateDisqualification);   //'State Supplementation'

        //populate map of disqualification type refrrence to label to support translations
        mapDisqTypeCodeToLabel.put('ETPNC',System.Label.SSP_DIsqualificationNonCooperation);
        mapDisqTypeCodeToLabel.put('CSDP',System.Label.SSP_DisqualificationDelinquent);
        mapDisqTypeCodeToLabel.put('RE',System.Label.SSP_DisqualificationRecertification);
        mapDisqTypeCodeToLabel.put('CE',System.Label.SSP_DisqualificationPath);
        mapDisqTypeCodeToLabel.put('VW',System.Label.SSP_DisqualificationVoluntary);
        mapDisqTypeCodeToLabel.put('CS',System.Label.SSP_DisqualificationNonPayment);
        mapDisqTypeCodeToLabel.put('NWEMP',System.Label.SSP_DisqualificationQualify);
        mapDisqTypeCodeToLabel.put('WF',System.Label.SSP_DisqualificationWaiverForm);
        mapDisqTypeCodeToLabel.put('HR',System.Label.SSP_DisqualificationHearing);
        mapDisqTypeCodeToLabel.put('RH',System.Label.SSP_DisqualificationReductionHours);
        mapDisqTypeCodeToLabel.put('RJ',System.Label.SSP_DisqualificationRefusedJob);
        mapDisqTypeCodeToLabel.put('UIB',System.Label.SSP_DisqualificationFailureCooperate);
        mapDisqTypeCodeToLabel.put('TRSNFIAMEX',System.Label.SSP_DisqualificationSnapTrade);
        mapDisqTypeCodeToLabel.put('BUSETRSNBE',System.Label.SSP_DisqualificationTradingBuying);
        mapDisqTypeCodeToLabel.put('FALSESNTFMA',System.Label.SSP_DisqualificationFalsifiedInformation);
        mapDisqTypeCodeToLabel.put('PV',System.Label.SSP_DisqualificaitonParole);
        mapDisqTypeCodeToLabel.put('FE',System.Label.SSP_DisqualificationFleeing);
        mapDisqTypeCodeToLabel.put('PPC',System.Label.SSP_DisqualificationPCooperation);
        mapDisqTypeCodeToLabel.put('TPL',System.Label.SSP_DisqualificationThirdLiability);
        mapDisqTypeCodeToLabel.put('HEQ',System.Label.SSP_DisqualificationHomeStead);
        mapDisqTypeCodeToLabel.put('NPAYPRE',System.Label.SSP_DisqualificationPayPremium);
        mapDisqTypeCodeToLabel.put('NSCH',System.Label.SSP_DisqualificationNotSchool);
        mapDisqTypeCodeToLabel.put('MAKWP',System.Label.SSP_DisqualificationMAKWP);
        mapDisqTypeCodeToLabel.put('COPKWP',System.Label.SSP_DisqualificationCooperate);
        mapDisqTypeCodeToLabel.put('DCSE',System.Label.SSP_DisqualificationCooperateDCSE);
        mapDisqTypeCodeToLabel.put('STABEN',System.Label.SSP_DisqualificationRefuseStatutory);
        mapDisqTypeCodeToLabel.put('LSUM',System.Label.SSP_DisqualificationLump);
        mapDisqTypeCodeToLabel.put('APPFRA',System.Label.SSP_DisqualificationApplicationFraud);
        mapDisqTypeCodeToLabel.put('TRAADMIN',System.Label.SSP_DisqualificationTrafficking);
        mapDisqTypeCodeToLabel.put('FIRTRA',System.Label.SSP_DisqualificationFirearms);
        mapDisqTypeCodeToLabel.put('DRUGTRA',System.Label.SSP_DisqualificationDrugTrafficking);
        mapDisqTypeCodeToLabel.put('DRUGFE',System.Label.SSP_DisqualificationDrugFelony);
        mapDisqTypeCodeToLabel.put('FDBFTS',System.Label.SSP_DisqualificationDuplicateBenefits);
        mapDisqTypeCodeToLabel.put('TRA',System.Label.SSP_DisqualificationCourt);
        mapDisqTypeCodeToLabel.put('IPV',System.Label.SSP_DisqualificationIntentional);
        mapDisqTypeCodeToLabel.put('VQRHRS',System.Label.SSP_DisqualificationVoluntaryQuit);
        mapDisqTypeCodeToLabel.put('CWDQC',System.Label.SSP_DisqualificationQualityControl);
        mapDisqTypeCodeToLabel.put('KWPUIB',System.Label.SSP_DisqualificationRefuseSanction);
        mapDisqTypeCodeToLabel.put('ETPREQ',System.Label.SSP_DisqualificationRequirement);
        mapDisqTypeCodeToLabel.put('ETPREV',System.Label.SSP_DisqualificationAssessment);
        mapDisqTypeCodeToLabel.put('FRWREG',System.Label.SSP_DisqualificationWorkRegister);
        mapDisqTypeCodeToLabel.put('NCPRG',System.Label.SSP_DisqualificationNonComply);
        mapDisqTypeCodeToLabel.put('TROFRES',System.Label.SSP_DisqualificationTransferResources);
        mapDisqTypeCodeToLabel.put('FFS',System.Label.SSP_DisqualificationFamilySanction);
        mapDisqTypeCodeToLabel.put('Suspension',System.Label.SSP_DisqualificationSuspension);

       Map<String,List<DisqualificationWrapper>> mapPrgToDisqualification = new Map<String,List<DisqualificationWrapper>>();
       String resultString;
        List<SSP_DisqualificationPayloadWrapper.DisqualificationDetailsWrapper> result = null;
        if(individualId != null){
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.DISQUALIFICATION_DETAILS;
            reqWrapper.primaryApplicationIndividualId= individualId; //Integer.valueOf(individualId); //890010780;
            reqWrapper.caseNumber = 0;
            mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
            List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            if(serviceResponses!= null){
                RSSP_DC_Wrapper dCWrapper = (RSSP_DC_Wrapper) serviceResponses.get(0);
                SSP_DisqualificationPayloadWrapper disqWrapper = new SSP_DisqualificationPayloadWrapper();
                disqWrapper = (SSP_DisqualificationPayloadWrapper) dCWrapper.DisqualificationPayload ;
                if(disqWrapper != null){
                    result = disqWrapper.DisqualificationDetails;
                    
                }
                
            }
        }
        if(result != null){
            for(SSP_DisqualificationPayloadWrapper.DisqualificationDetailsWrapper detail: result){
                String prgmName = prgCodeToPrgmName.get(detail.ProgramCode);
                DisqualificationWrapper disqualification = new DisqualificationWrapper();
                disqualification.ProgramCode = detail.ProgramCode;
                disqualification.PenaltyDisqualificationType = mapDisqTypeCodeToLabel.get(detail.PenaltyDisqualificationType); //detail.PenaltyDisqualificationType
                if(detail.EffectiveStartDate != null){
                    List<String> lstStartDate = detail.EffectiveStartDate.split('-');
                    //received format YYYY-MM-DD. Expected Format - MM/DD/YYYY.
                    String startDate = lstStartDate[1]+'/'+lstStartDate[2]+'/'+lstStartDate[0];
                    disqualification.EffectiveStartDate = startDate;
                }
                if(detail.EffectiveEndDate == null || detail.EffectiveEndDate == ''){
                    disqualification.EffectiveEndDate = System.Label.SSP_DisqualificationOnGoing;
                }
                else{
                    //received format YYYY-MM-DD. Expected Format - MM/DD/YYYY.
                    List<String> lstEndDate = detail.EffectiveEndDate.split('-');
                    String endDate = lstEndDate[1]+'/'+lstEndDate[2]+'/'+lstEndDate[0];
                    disqualification.EffectiveEndDate = endDate;
                }
                
                disqualification.DMSId = detail.DMSId;
                if(!mapPrgToDisqualification.isEmpty() && mapPrgToDisqualification.containsKey(prgmName)){
                    List<DisqualificationWrapper> wrapper = mapPrgToDisqualification.get(prgmName);
                    wrapper.add(disqualification);
                    mapPrgToDisqualification.put(prgmName,wrapper);
                }
                else{
                    mapPrgToDisqualification.put(prgmName,new List<DisqualificationWrapper>{disqualification});
                }
            }
            //temp code for checking multiple disqualifications for one program
            // DisqualificationWrapper disqualification = new DisqualificationWrapper();
            //     disqualification.ProgramCode = 'KT';
            //     disqualification.PenaltyDisqualificationType = 'Suspension';
            //     disqualification.EffectiveStartDate = '07/01/2018';
            //     disqualification.EffectiveEndDate = 'On-going';
            //     disqualification.DMSId = '';
            // List<DisqualificationWrapper> wrapperTemp = mapPrgToDisqualification.get(System.Label.SSP_CashDisqualification);
            //         wrapperTemp.add(disqualification);
            //         mapPrgToDisqualification.put(System.Label.SSP_CashDisqualification,wrapperTemp);
            //temp code

        }
        resultString = JSON.serialize(mapPrgToDisqualification);
        //return resultString;
        response.put('resultString',resultString);

        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);  
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
          
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('BEN_DQD',selectedRole);
           
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

    
    public class DisqualificationWrapper{
        public Integer caseNumber;
        public String ProgramCode;
        public String PenaltyDisqualificationType;
        public String EffectiveStartDate;
        public String EffectiveEndDate;
        public String DMSId;
    }
}