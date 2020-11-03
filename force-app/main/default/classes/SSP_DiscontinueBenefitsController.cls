/*
* classname     :  SSP_DiscontinueBenefitsController
* @description  :  Controller class for Discontinue Benefits Screen
* @author       :  Kireeti Gora   
* @date         :  06/03/2020
* MODIFICATION LOG: 
* DEVELOPER                     DATE                               DESCRIPTION
* ---------------------------------------------------------------------------------------------

**/

public class SSP_DiscontinueBenefitsController {
    /*    
* @method       : getActiveBenefitsDetails
* @description  : This method returns the details required for waiver  screening questioons screen
* @author       : Kireeti Gora
* @return       : SSP_LightningResponse
* */
    @AuraEnabled
    public static SSP_LightningResponse getActiveBenefitsDetails(String caseId){
        SSP_LightningResponse response = new SSP_LightningResponse();       
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsActiveBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsAllBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();

        Map<String,List<SSP_BenefitInformationWrapper>> mapProgramVsIndividuals = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        List<SSP_BenefitInformationWrapper> lstBenefitInformation = new List<SSP_BenefitInformationWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstMedicaidBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstSNAPBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstKTAPBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstKHIPPBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstStateBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
        List<SSP_DiscontinueBenefitsController.picklistWrapper> lstChildCareBenefitInformation = new List<SSP_DiscontinueBenefitsController.picklistWrapper>();
         set<String> lstSNAPIndividualIds = new set<String>();
         set<String> availablePrograms = new set<String>();
        List<SSP_DiscontinueBenefitsController.benfitsWrapper> lstBenfits = new List<SSP_DiscontinueBenefitsController.benfitsWrapper>();
        String strActiveBenefits= '';
        //Added by Shivam 
       String strAllBenefits = '';
        try{ 
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            //strActiveBenefits = sessionpart.get('ActiveBenefits') != null ? String.valueOf(sessionpart.get('ActiveBenefits')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'ActiveBenefits'));
            strAllBenefits = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')):String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
            availablePrograms = ssp_utility.getAvailableProgramsByRole();         
            //mapCaseVsActiveBenefits =(Map<String,List<SSP_BenefitInformationWrapper>>)JSON.deserialize(strActiveBenefits,  Map<String,List<SSP_BenefitInformationWrapper>>.class);
            mapCaseVsAllBenefits = (Map<String,List<SSP_BenefitInformationWrapper>>)JSON.deserialize(strAllBenefits,  Map<String,List<SSP_BenefitInformationWrapper>>.class);
            
            if(mapCaseVsAllBenefits.get(caseId) != null){
                List<SSP_BenefitInformationWrapper> tempList = mapCaseVsAllBenefits.get(caseId);
                for(SSP_BenefitInformationWrapper benefit : tempList){
                    if(benefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION || benefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW || benefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED){
                        lstBenefitInformation.add(benefit);
                    }
                }
            }

          /* if(mapCaseVsActiveBenefits.get(caseId) != null){
                lstBenefitInformation= mapCaseVsActiveBenefits.get(caseId);
                
            }*/
            for(SSP_BenefitInformationWrapper objBenefit: lstBenefitInformation){
                if(objBenefit.ProgramCode == system.label.SSP_KTAP){
                    objBenefit.ProgramCode =  SSP_GlobalConstants.KTAP;
                    SSP_DiscontinueBenefitsController.picklistWrapper objValue = new SSP_DiscontinueBenefitsController.picklistWrapper(objBenefit.IndividualName,objBenefit.IndividualId);                  
                    lstKTAPBenefitInformation.add(objValue);
                }else if(objBenefit.ProgramCode == system.label.SSP_Medicaid){
                    objBenefit.ProgramCode =  SSP_GlobalConstants.MEDICAID;
                    SSP_DiscontinueBenefitsController.picklistWrapper objValue = new SSP_DiscontinueBenefitsController.picklistWrapper(objBenefit.IndividualName,objBenefit.IndividualId);
                    lstMedicaidBenefitInformation.add(objValue);
                } 
                else if(objBenefit.ProgramCode ==system.label.SSP_ChildCareAssistance){
                    objBenefit.ProgramCode =  SSP_GlobalConstants.CHILDCARE;
                    SSP_DiscontinueBenefitsController.picklistWrapper objValue = new SSP_DiscontinueBenefitsController.picklistWrapper(objBenefit.IndividualName,objBenefit.IndividualId);
                    lstChildCareBenefitInformation.add(objValue);
                } else if (objBenefit.ProgramCode ==system.label.SSP_SNAP){
                    objBenefit.ProgramCode =  SSP_GlobalConstants.SNAP;
                    SSP_DiscontinueBenefitsController.picklistWrapper objValue = new SSP_DiscontinueBenefitsController.picklistWrapper(objBenefit.IndividualName,objBenefit.IndividualId);
                    lstSNAPBenefitInformation.add(objValue);
                    lstSNAPIndividualIds.add(objBenefit.IndividualId);
                }
            }
            if((!lstKTAPBenefitInformation.isEmpty()) && availablePrograms.contains(SSP_GlobalConstants.KTAP)){
                SSP_DiscontinueBenefitsController.benfitsWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsWrapper(system.label.SSP_KTAP,lstKTAPBenefitInformation,false,SSP_GlobalConstants.KTAP);
                lstBenfits.add(objBenefit);
            }
            if((!lstMedicaidBenefitInformation.isEmpty()) && availablePrograms.contains(SSP_GlobalConstants.MEDICAID)){
                SSP_DiscontinueBenefitsController.benfitsWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsWrapper(system.label.SSP_Medicaid,lstMedicaidBenefitInformation,false,SSP_GlobalConstants.MEDICAID);
                lstBenfits.add(objBenefit);
            }
            if((!lstChildCareBenefitInformation.isEmpty()) && availablePrograms.contains(SSP_GlobalConstants.CHILDCARE)){
                SSP_DiscontinueBenefitsController.benfitsWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsWrapper(system.label.SSP_ChildCareAssistance,lstChildCareBenefitInformation,false,SSP_GlobalConstants.CHILDCARE);
                lstBenfits.add(objBenefit);
            }               
            if((!lstSNAPBenefitInformation.isEmpty()) && availablePrograms.contains(SSP_GlobalConstants.SNAP)){
                SSP_DiscontinueBenefitsController.benfitsWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsWrapper(system.label.SSP_SNAP,lstSNAPBenefitInformation,true,SSP_GlobalConstants.SNAP);
                lstBenfits.add(objBenefit);
            }           
            if(!lstBenfits.isEmpty()){
                response.put('Benefits',JSON.serialize(lstBenfits));
            } 
             if(!lstSNAPIndividualIds.isEmpty()){
                response.put('snapIndividuals',JSON.serialize(lstSNAPIndividualIds));
            } 
            
            
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('Disc_Benefits',selectedRole);
            
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                response.put('showScreen',true);
            }
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_DiscontinueBenefitsController', 'getActiveBenefitsDetails', 'Failed to fetch Details in getActiveBenefitsDetails Method', true);  
        }
        return response;
    }
    
    @AuraEnabled
    public static SSP_LightningResponse triggerDiscontinueBenefitsCallout(String benefitJSON){
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        SSP_DiscontinueBenefitsController.benfitsResponseWrapper objBenefit = new SSP_DiscontinueBenefitsController.benfitsResponseWrapper();
       
        List<Object> objList = new   List<Object>();
        set<String> lstIndividualId = new   set<String>();
        Map<String,List<String>> mapIndividualIdVsProgram = new Map<String,List<String>>();
        List<Object> serviceResponses = new  List<Object>();
        SSP_DatacontractOrg.AdhocServiceResponse response = new  SSP_DatacontractOrg.AdhocServiceResponse();
        try{
            objBenefit = (SSP_DiscontinueBenefitsController.benfitsResponseWrapper)JSON.deserialize(benefitJSON, SSP_DiscontinueBenefitsController.benfitsResponseWrapper.class);
            for(SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper objProgram : objBenefit.benefitIndividuals ){
                
                lstIndividualId.addAll(objProgram.individualId);
            }
            for(String strIndividualId: lstIndividualId){
                List<string> lstPrograms = new  List<string>();
                for(SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper objProgram : objBenefit.benefitIndividuals ){
                    if(objProgram.individualId.contains(strIndividualId)){
                        lstPrograms.add(objProgram.program);
                    }
                }
                if(!lstPrograms.isEmpty()){
                    mapIndividualIdVsProgram.put(strIndividualId,lstPrograms);
                }
            }
            if(!mapIndividualIdVsProgram.isEmpty()){
                SSP_DatacontractOrg.DiscontinueRequestModel objRequest = new SSP_DatacontractOrg.DiscontinueRequestModel();
                Map<String, Object> mapParams = new Map<String, Object>();
                objRequest.Address = new SSP_DatacontractOrg.AddressToUpdate();
                objRequest.Address.AddressLine1 =objBenefit.AddressLine1 != null? objBenefit.AddressLine1:'';
                objRequest.Address.AdderssLine2 =objBenefit.AddressLine2 != null? objBenefit.AddressLine2:'';
                objRequest.Address.AddressTypeCode = '';
                objRequest.Address.CertifiedNoStatIndicator = '';
                objRequest.Address.City = objBenefit.City != null? objBenefit.City:'';
                objRequest.Address.CountyCode = objBenefit.CountyCode != null? objBenefit.CountyCode:'';
                objRequest.Address.MailDeliveryCode = '';
                objRequest.Address.ResidentialDeliveryIndicator = '';
                objRequest.Address.StateCode = objBenefit.StateCode != null? objBenefit.StateCode:'';
                objRequest.Address.VacancyIndicator = '';
                objRequest.Address.ZipCode4 = objBenefit.ZipCode4 != null? objBenefit.ZipCode4:'';
                objRequest.Address.ZipCode5 = objBenefit.ZipCode5 != null? objBenefit.ZipCode5:'';
                objRequest.Address.isValidated = '';
                objRequest.CaseNumber=  Integer.valueOf(objBenefit.CaseNumber);
                objRequest.Reason = objBenefit.reason != null? objBenefit.reason:'';
                objRequest.isSFTransaction = true;
                objRequest.IndividualsToDiscontinue = new SSP_DatacontractOrg.ArrayOfDetailsOfIndividualToDiscontinue();
                objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue =  new List<SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue>();
                
                for(String strIndividualId:mapIndividualIdVsProgram.keyset()){
                    SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue objBenfit1 = new SSP_DatacontractOrg.DetailsOfIndividualToDiscontinue();
                    obJBenfit1.IndividualId = Integer.valueOf(strIndividualId);
                    SSP_SerializationArray.ArrayOfstring objArray1 = new SSP_SerializationArray.ArrayOfstring();
                    objArray1.string_x = mapIndividualIdVsProgram.get(strIndividualId);
                    obJBenfit1.ProgramCodes = objArray1;
                    objRequest.IndividualsToDiscontinue.DetailsOfIndividualToDiscontinue.add(obJBenfit1);
                }
              
                mapParams.put(SSP_InterfaceConstants.JSON_BODY, objRequest);
                serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.DISCONTINUE_BENEFITS, mapParams);              
                  
                if(serviceResponses != null && (!serviceResponses.isEmpty())){
                    response = (SSP_DatacontractOrg.AdhocServiceResponse) serviceResponses[0];
                }
                if(response != null && response.result != null  &&  response.result == 'P'){
                      resultMap.put('success',true);
                    
                }else if(response != null && response.ExceptionDetails != null ){
                   
                    if(response.ExceptionDetails.Exceptionid != null){
                        resultMap.put('ERROR',response.ExceptionDetails.Exceptionid);
                    }else if(response.ExceptionDetails.ErrorCode != null){
                        resultMap.put('ERROR',response.ExceptionDetails.ErrorCode);
                    }else {
                        resultMap.put('ERROR','');
                    }
                }else{
                     resultMap.put('ERROR','');
                }
                
                
            }
            
        }catch(Exception e){
            LOG_LogMessageUtility.logMessage(e, 'SSP_DiscontinueBenefitsController', 'triggerDiscontinueBenefitsCallout', 'Failed to fetch Details in triggerDiscontinueBenefitsCallout Method', true);  
        }
        
        
        return resultMap;
    }
    public class benfitsWrapper{    
        
        @AuraEnabled
        public String programName{get;set;}
        @AuraEnabled
        public List<SSP_DiscontinueBenefitsController.picklistWrapper> benefitIndividuals{get;set;}        
        @AuraEnabled
        public Boolean isSnap{get;set;}     
        @AuraEnabled
        public String programValue{get;set;}     
        public benfitsWrapper(String programName,List<SSP_DiscontinueBenefitsController.picklistWrapper> benefitIndividuals,Boolean isSnap,String programValue){            
            
            this.programName = programName;
            if(benefitIndividuals != null){
                this.benefitIndividuals = benefitIndividuals;
            }
            
            this.isSnap = isSnap;
            this.programValue = programValue;
            
        }
    }
    public class benfitsResponseProgramWrapper{    
        
        @AuraEnabled
        public String program{get;set;}
        @AuraEnabled
        public List<String> individualId{get;set;}        
        
    }
    
    
    
    public class benfitsResponseWrapper{    
        
        @AuraEnabled
        public String program{get;set;}
        @AuraEnabled
        public List<SSP_DiscontinueBenefitsController.benfitsResponseProgramWrapper> benefitIndividuals{get;set;}        
        @AuraEnabled
        public String reason{get;set;}     
        @AuraEnabled
        public String AddressLine1{get;set;} 
        @AuraEnabled
        public String AddressLine2{get;set;} 
        @AuraEnabled
        public String City{get;set;} 
        @AuraEnabled
        public String CountyCode{get;set;} 
        @AuraEnabled
        public String StateCode{get;set;} 
        @AuraEnabled
        public String ZipCode5{get;set;} 
        @AuraEnabled
        public String ZipCode4{get;set;} 
        @AuraEnabled
        public String caseNumber{get;set;} 
        
    }
     /***************************************************************************************************
* @author       Kireeti Gora
* @date         01/13/2020
* @className   picklistWrapper
* @description  This is Wrapper class for picklist options.
*****************************************************************************************************/
    public class PicklistWrapper{    
        
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}        
        public picklistWrapper(String label,String value){            
            
            this.label = label;
            this.value = value;
            
            
        }
    }
}