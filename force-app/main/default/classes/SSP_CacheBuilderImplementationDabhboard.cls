public with sharing class SSP_CacheBuilderImplementationDabhboard implements Cache.CacheBuilder{
    public String doLoad(String key) {
        String value = '';
        Boolean hasBenefits = false; 
        Boolean hasKhipp = false; 
        Boolean onlyDependent = true;
        Integer onlyDependentCount = 0;
        SSP_LightningResponse resultMap = new SSP_LightningResponse();
        String individualId;
        Set<String> setCaseNumbers = new Set<String>();
        Map<String, Boolean> mapCaseVsHOH = new Map<String, Boolean>();
        Map<String, String> mapCaseVsStatus = new Map<String, String>();
        Map<String, String> mapCaseVsEligibilityRunDate = new Map<String, String>(); //#387346
        List<SSP_BenefitInformationWrapper> benefitData = new  List<SSP_BenefitInformationWrapper>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsActiveBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingInterviewBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsPendingVerificationBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
         Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsAllBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        List<String> lstActiveCases = new List<String>();
        Map<String, Object> mapParamsBenefit = new Map<String, Object>(); 
        Map<String,String> mapCaseVsbenefitStatus = new  Map<String,String>(); 
           Map<String,String> mapCaseVsIndividualId = new  Map<String,String>(); 
        SSP_DashboardController.DashboardCacheWrapper dbCacheWrap = new SSP_DashboardController.DashboardCacheWrapper();////
        Contact individualContact;
        /*	message center changes */
        map<String,Set<String>> authRepAccessForNotices = new map<String,Set<String>>();
        //Shikha -
		Boolean racEnabledFlag = false;
        try{
            /* Added by Shrikant*/
            individualId = SSP_Utility.getIndividualId();
            if(String.isNotBlank(individualId)){
                individualContact = SSP_DashboardService.getIndividualContact(individualId);
            }
            
            benefitData = (individualContact != null && String.isNotBlank(individualContact.CacheBenefitProgramData__c)) ? (List<SSP_BenefitInformationWrapper>)JSON.deserialize(individualContact.CacheBenefitProgramData__c, List<SSP_BenefitInformationWrapper>.class) : benefitData;
            dbCacheWrap = (individualContact != null && String.isNotBlank(individualContact.CacheDashboardData__c)) ? (SSP_DashboardController.DashboardCacheWrapper)JSON.deserialize(String.valueOf(individualContact.CacheDashboardData__c), SSP_DashboardController.DashboardCacheWrapper.Class) : dbCacheWrap;
            mapCaseVsHOH = dbCacheWrap.mapCaseVsHOH != null ? dbCacheWrap.mapCaseVsHOH : new Map<String, Boolean>();
            mapCaseVsStatus = dbCacheWrap.mapCaseVsStatus != null ? dbCacheWrap.mapCaseVsStatus : new Map<String, String>();
            mapCaseVsEligibilityRunDate = dbCacheWrap.mapCaseVsEligibilityRunDate != null ? dbCacheWrap.mapCaseVsEligibilityRunDate : new Map<String, String>(); //#387346
            mapCaseVsIndividualId= dbCacheWrap.mapCaseVsIndividualId != null ? dbCacheWrap.mapCaseVsIndividualId : new Map<String, String>();
            racEnabledFlag = dbCacheWrap.hasRACEnabled != null && dbCacheWrap.hasRACEnabled ? true : false;
            /*	message center changes */
            authRepAccessForNotices = dbCacheWrap.authRepAccessForNotices != null ? dbCacheWrap.authRepAccessForNotices : new map<String,Set<String>>();            
            
            for(SSP_BenefitInformationWrapper objBenefit : benefitData){
                        setCaseNumbers.add(objBenefit.CaseNumber);
            }

            for(String strCaseNumber: setCaseNumbers){
                Boolean isHeadOfHousehold = false;
                if(mapCaseVsHOH.get(strCaseNumber) != null &&  mapCaseVsHOH.get(strCaseNumber)){
                    isHeadOfHousehold = mapCaseVsHOH.get(strCaseNumber);
                }
                
                List<SSP_BenefitInformationWrapper> lstActiveBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstPendingInterviewBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstPendingVerificationBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllActiveBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllPendingInterviewBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllPendingVerificationBenefits = new List<SSP_BenefitInformationWrapper>();
                List<SSP_BenefitInformationWrapper> lstAllBenefits = new List<SSP_BenefitInformationWrapper>();
                
                
                Map<String,List<SSP_BenefitInformationWrapper>> mapStatusVsBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
                for(SSP_BenefitInformationWrapper objBenefit : benefitData){  
                    if(objBenefit.CaseNumber == strCaseNumber){
                        lstAllBenefits.add(objBenefit);
                }
                    if(objBenefit.ProgramCode == SSP_GlobalConstants.KTAP){
                        objBenefit.ProgramCode = system.label.SSP_KTAP;
                    }else if(objBenefit.ProgramCode == SSP_GlobalConstants.MEDICAID){
                        objBenefit.ProgramCode =system.label.SSP_Medicaid;
                    } 
                    else if(objBenefit.ProgramCode == SSP_GlobalConstants.CHILDCARE){
                        objBenefit.ProgramCode = system.label.SSP_ChildCareAssistance;
                    } 
                    else if(objBenefit.ProgramCode == SSP_GlobalConstants.STATE){
                        objBenefit.ProgramCode = system.label.SSP_StateSupplementation;
                    } 
                    else if(objBenefit.ProgramCode ==SSP_GlobalConstants.KHIPP){  
                        objBenefit.ProgramCode = system.label.SSP_KIHIPP;
                    }else if (objBenefit.ProgramCode ==SSP_GlobalConstants.SNAP){
                        objBenefit.ProgramCode = system.label.SSP_SNAP;
                    }
                    if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                        lstActiveBenefits.add(objBenefit);                                
                    }else if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                        lstPendingVerificationBenefits.add(objBenefit);
                    }else if(isHeadOfHousehold && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                        lstPendingInterviewBenefits.add(objBenefit);
                    }
                    if((!isHeadOfHousehold) && objBenefit.IndividualId == individualId && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                        lstActiveBenefits.add(objBenefit);
                    }else if((!isHeadOfHousehold) && objBenefit.IndividualId == individualId && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                        lstPendingVerificationBenefits.add(objBenefit);
                    }else if((!isHeadOfHousehold) && objBenefit.IndividualId ==individualId && objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                        lstPendingInterviewBenefits.add(objBenefit);
                    }
                    if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED && objBenefit.CaseNumber == strCaseNumber){
                        lstAllActiveBenefits.add(objBenefit);
                    }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION && objBenefit.CaseNumber == strCaseNumber){
                        lstAllPendingVerificationBenefits.add(objBenefit);
                    }else if(objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW && objBenefit.CaseNumber == strCaseNumber){
                        lstAllPendingInterviewBenefits.add(objBenefit);
                    }
                    
                    
                     if((objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW || objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION ||
                        objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED) && objBenefit.ProgramCode ==SSP_GlobalConstants.KHIPP  && objBenefit.CaseNumber == strCaseNumber && (!hasKhipp)){
                            hasKhipp = true;
                            
                        }
                    /* Defect 382413 */
                    if(objBenefit.CaseNumber == strCaseNumber){
                        if(!isHeadOfHousehold && onlyDependent){
                            onlyDependent = true;
                            onlyDependentCount = onlyDependentCount + 1;
                        }
                        else if (((objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGINTERVIEW || 
                                   objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_PENDINGVERIFICATION ||
                                   objBenefit.ProgramStatusCode == SSP_GlobalConstants.BENEFIT_STATUS_APPROVED) && 
                                  objBenefit.ProgramCode ==SSP_GlobalConstants.KP_Label  && 
                                  objBenefit.CaseNumber == strCaseNumber) && onlyDependent && isHeadOfHousehold){
                                      onlyDependent = true;
                                  }
                        else{
                            onlyDependent = false;
                        }
                    }/* Defect 382413*/
                }
                /*if(hasKhipp){
                    resultMap.put('hasKihippProgram',true);
                    sessionPart.put('hasKihippProgram',true,3600,Cache.Visibility.ALL,false);
                }*/
                if(!lstActiveBenefits.isEmpty()){                    
                    mapCaseVsActiveBenefits.put(strCaseNumber,lstActiveBenefits);  
                }
                if(!lstPendingInterviewBenefits.isEmpty()){    
                    mapCaseVsPendingInterviewBenefits.put(strCaseNumber,lstPendingInterviewBenefits);
                }
                if(!lstPendingVerificationBenefits.isEmpty()){    
                    mapCaseVsPendingVerificationBenefits.put(strCaseNumber,lstPendingVerificationBenefits);
                }
                if(!lstAllBenefits.isEmpty()){
                    mapCaseVsAllBenefits.put(strCaseNumber,lstAllBenefits);
                }
                if((!lstAllActiveBenefits.isEmpty()) && lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty()){ 
                    if(isHeadOfHousehold){
                        lstActiveCases.add(strCaseNumber);
                    }
                    mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Active);
                    
                }else if(!(lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty())){
                    mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Pending); 
                }else if(lstAllActiveBenefits.isEmpty() && lstAllPendingInterviewBenefits.isEmpty() && lstAllPendingVerificationBenefits.isEmpty()){ 
                    mapCaseVsbenefitStatus.put(strCaseNumber,system.label.SSP_Inactive);
                }                  
            }               
			// Defect 382413            
            if(key == 'onlyKihippHoh'){
                if(onlyDependent && onlyDependentCount > 0){
					return 'true';
                }
                else{
                    return 'false';
                }     
            }
			// Defect 382413
            if(!mapCaseVsAllBenefits.isEmpty() && key == 'AllBenefits'){ 
                //resultMap.put('AllBenefits',JSON.serialize(mapCaseVsAllBenefits));
                //  sessionPart.put('AllBenefits',JSON.serialize(mapCaseVsAllBenefits),3600,Cache.Visibility.ALL,false);
                //sessionPart.put('AllBenefits',JSON.serialize(mapCaseVsAllBenefits));
                return JSON.serialize(mapCaseVsAllBenefits);
            }
            if(!mapCaseVsActiveBenefits.isEmpty() && key == 'ActiveBenefits'){ 
                /*resultMap.put('ActiveBenefits',JSON.serialize(mapCaseVsActiveBenefits));
                sessionPart.put('ActiveBenefits',JSON.serialize(mapCaseVsActiveBenefits));*/
                return JSON.serialize(mapCaseVsActiveBenefits);
            }
            if(!mapCaseVsPendingInterviewBenefits.isEmpty() && key == 'PendingInterviewBenefits'){ 
                /*resultMap.put('PendingInterviewBenefits',JSON.serialize(mapCaseVsPendingInterviewBenefits));
                sessionPart.put('PendingInterviewBenefits',JSON.serialize(mapCaseVsPendingInterviewBenefits));*/
                return JSON.serialize(mapCaseVsPendingInterviewBenefits);
            }
            if(!mapCaseVsPendingVerificationBenefits.isEmpty() && key == 'PendingVerificationBenefits'){ 
                /*resultMap.put('PendingVerificationBenefits',JSON.serialize(mapCaseVsPendingVerificationBenefits));
                sessionPart.put('PendingVerificationBenefits',JSON.serialize(mapCaseVsPendingVerificationBenefits));*/
                return JSON.serialize(mapCaseVsPendingVerificationBenefits);
            }
            /** #387346 */
            if(!mapCaseVsEligibilityRunDate.isEmpty() && key == 'mapCaseVsEligibilityRunDate'){
                return JSON.serialize(mapCaseVsEligibilityRunDate);
            }
            /** */
            if(!mapCaseVsStatus.isEmpty() && key == 'caseVsHOH'){
                return JSON.serialize(mapCaseVsHOH);
            }
            if(!mapCaseVsStatus.isEmpty() && key == 'caseVsStatus'){
                return JSON.serialize(mapCaseVsStatus);
            }
            if(!mapCaseVsIndividualId.isEmpty() && key == 'caseVsIndividualId'){
                return JSON.serialize(mapCaseVsIndividualId);
            }
            /*	message center changes */
            if(!authRepAccessForNotices.isEmpty() && key=='authRepAccessForNotices'){
                return JSON.serialize(authRepAccessForNotices);
            }
             if(key == 'hasKihippProgram' && hasKhipp){
                return 'true';
            }
             if(key == 'racEnabledFlag' && racEnabledFlag){
                return 'true';
            }
           
            else if(key == 'racEnabledFlag'){
                return 'false';
            }
               
        }
        catch(Exception ex){
            value = null;
        }
        return value;
    }
}