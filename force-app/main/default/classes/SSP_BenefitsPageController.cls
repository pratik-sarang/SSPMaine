/*
* classname 	: SSP_BenefitsPageController
* @description 	: This is controller class for Benefits screen.
* @author 		: Shivam Tiwari
* @date 		: June-25-2020
* MODIFICATION LOG:
* DEVELOPER 			DATE 			DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Shivam Tiwari 		June-25-2020		Initial Version
*/
public class SSP_BenefitsPageController {

    /***************************************************************************************************
    * @author       Shivam Tiwari
    * @date         June-25-2020
    * @methodname   getDashboardRefreshFlag
    * @description  This methods is used to get Benefits related data
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getDashboardRefreshFlag(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try{
            String individualId = SSP_Utility.getIndividualId();
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);
            
            if(individualContact != null && individualContact.IsDashboardRefreshNeeded__c){
                toSend.put('refreshNeeded', true);
            }
            else{
                toSend.put('refreshNeeded', false);
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_BenefitsPageController', 'getDashboardRefreshFlag', ex.getMessage() , true);
        }
        return toSend;
    }
    
    
    /***************************************************************************************************
    * @author       Shivam Tiwari
    * @date         June-25-2020
    * @methodname   getBenefitsData
    * @description  This methods is used to get Benefits related data from cache
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getBenefitsData(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        List<SSP_BenefitInformationWrapper> lstAllBenefits = new List<SSP_BenefitInformationWrapper>();
        Map<String,List<SSP_BenefitInformationWrapper>> mapCaseVsAllBenefits = new  Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        Set<String> renewalCaseNumbersSet = new Set<string>();
        List<caseDataWrapper> caseWrapperList = new List<caseDataWrapper>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        String mapCaseVsAllBenefitsString = sessionpart.get('AllBenefits') != null ? String.valueOf(sessionpart.get('AllBenefits')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'AllBenefits'));
        String mapCaseVsStatusString = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
        String isHeadOfHousehold = String.valueOf(sessionpart.get('isHeadOfHousehold'));
        String hasRenewalListString = String.valueOf(sessionpart.get('hasMedicaidRenewals'));
        List<SSP_DashboardCaseInformation.Renewal> medicaidRenewalCacheList = new List<SSP_DashboardCaseInformation.Renewal>();
        List<caseDataWrapper> activeCasesList = new List<caseDataWrapper>();
        List<caseDataWrapper> inactiveCasesList = new List<caseDataWrapper>();
        
        Map<String,List<SSP_BenefitInformationWrapper>> activeCaseMap = new Map<String,List<SSP_BenefitInformationWrapper>>();
        Map<String,List<SSP_BenefitInformationWrapper>> inactiveCaseMap = new Map<String,List<SSP_BenefitInformationWrapper>>();
        
        toSend.put('isHeadOfHousehold', true);
        
        try{
            String selectedRole =(sessionPart != null && sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE) != null) ? String.valueOf(sessionpart.get(SSP_GlobalConstants.SELECTED_ROLE)) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementation.class,SSP_GlobalConstants.SELECTED_ROLE)) ;
            SSP_Utility.SecurityMatrixWrapper objMatrix = SSP_Utility.getScreenAccessDetails('BENEFITS', selectedRole);
            
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission !='NotAccessible'){
                toSend.put('showScreen',true);
                
                if(String.isNotBlank(mapCaseVsStatusString)){
                    mapCaseVsStatus = (Map<String,String>)JSON.deserialize(String.valueOf(mapCaseVsStatusString), Map<String,String>.class);
                }
                toSend.put('CaseVsStatus', JSON.serialize(mapCaseVsStatus));
                
                if(String.isNotBlank(hasRenewalListString)){
                    medicaidRenewalCacheList = (List<SSP_DashboardCaseInformation.Renewal>) JSON.deserialize(String.valueOf(hasRenewalListString), List<SSP_DashboardCaseInformation.Renewal>.class);
                }
                
                if(String.isNotBlank(mapCaseVsAllBenefitsString) ){
                    mapCaseVsAllBenefits = (Map<String,List<SSP_BenefitInformationWrapper>>)JSON.deserialize(String.valueOf(mapCaseVsAllBenefitsString), Map<String,List<SSP_BenefitInformationWrapper>>.class);
                                        
                    if(mapCaseVsAllBenefits != null && mapCaseVsAllBenefits.size() > 0){
                        //to prepare a list of all applicable benefits.
                        for(String caseNumber : mapCaseVsAllBenefits.keyset()){
                            lstAllBenefits.addAll(mapCaseVsAllBenefits.get(caseNumber));
                        }
                                                
                        //Adds Case Numbers to a set if MEDICAID benefit is due for RENEWAL.
                        if(lstAllBenefits != null && lstAllBenefits.size() > 0){
                            for(SSP_BenefitInformationWrapper benefit : lstAllBenefits){
                                if( benefit.ProgramCode == system.label.SSP_Medicaid && benefit.RenewalDueDate != null && Date.valueOf(benefit.RenewalDueDate) > SSP_Utility.today() && medicaidRenewalCacheList != null && medicaidRenewalCacheList.size() > 0){
                                    renewalCaseNumbersSet.add(benefit.CaseNumber);
                                }
                            }
                        }
                        toSend.put('renewalCaseNumbersSet', renewalCaseNumbersSet);
                        
                        
                        for(String caseNumber : mapCaseVsAllBenefits.keyset()){
                            List<SSP_BenefitInformationWrapper> caseBenefitsList = mapCaseVsAllBenefits.get(caseNumber);
                            if(caseBenefitsList != null && caseBenefitsList.size() > 0){
                                caseDataWrapper wrap = new caseDataWrapper();
                                //Multiple EDGNumber related changes for Kinship and KTAP benefits.
                                Map<String, List<SSP_BenefitInformationWrapper>> mapKTAP_EDGvsBenefits = new Map<String, List<SSP_BenefitInformationWrapper>>();		
                                Map<String, List<SSP_BenefitInformationWrapper>> mapKinship_EDGvsBenefits = new Map<String, List<SSP_BenefitInformationWrapper>>();		
                                
                                wrap.caseNumber = caseNumber;
                                for(SSP_BenefitInformationWrapper benefit : caseBenefitsList){
                                    if(benefit.ProgramCode == system.label.SSP_SNAP){
                                        wrap.SNAPBenefitsList.add(benefit);
                                    }
                                    else if(benefit.ProgramCode == system.label.SSP_KTAP){
                                        //Adding null key check for Scenarios where EDGNumber can be null. If null passing a temporary 'null' key
                                        String EDGNumberKey = benefit.EdgNumber == null ? 'null' : benefit.EdgNumber;
                                        if(!mapKTAP_EDGvsBenefits.keySet().contains(EDGNumberKey)){
                                            mapKTAP_EDGvsBenefits.put(EDGNumberKey, new List<SSP_BenefitInformationWrapper>());
                                        }
                                        List<SSP_BenefitInformationWrapper> tempList = mapKTAP_EDGvsBenefits.get(EDGNumberKey);
                                        tempList.add(benefit);
                                        mapKTAP_EDGvsBenefits.put(EDGNumberKey, tempList);
                                    }
                                    else if(benefit.ProgramCode == SSP_GlobalConstants.ChildCareAssistance || benefit.ProgramCode == SSP_GlobalConstants.ChildCareSpanish){  
                                        wrap.CCBenefitsList.add(benefit);
                                    }
                                    
                                    else if((benefit.ProgramCode != null) && (benefit.ProgramCode.contains(SSP_GlobalConstants.Kinship) || benefit.ProgramCode == SSP_GlobalConstants.KC_Code)){
                                        //Adding null key check for Scenarios where EDGNumber can be null. If null passing a temporary 'null' key
                                        String EDGNumberKey = benefit.EdgNumber == null ? 'null' : benefit.EdgNumber;
                                        if(!mapKinship_EDGvsBenefits.keySet().contains(EDGNumberKey)){
                                            mapKinship_EDGvsBenefits.put(EDGNumberKey, new List<SSP_BenefitInformationWrapper>());
                                        }
                                        List<SSP_BenefitInformationWrapper> tempList = mapKinship_EDGvsBenefits.get(EDGNumberKey);
                                        tempList.add(benefit);
                                        mapKinship_EDGvsBenefits.put(EDGNumberKey, tempList);
                                    }
                                    else{
                                        wrap.otherBenefitsList.add(benefit);
                                    }
                                    
                                }
                                wrap.KTAPBenefitsMap = mapKTAP_EDGvsBenefits;
                                wrap.KinshipBenefitsMap = mapKinship_EDGvsBenefits;
                                caseWrapperList.add(wrap);
                            }
                        }                        
                        
                        if(caseWrapperList != null && caseWrapperList.size() > 0){
                            for(caseDataWrapper wrapCase : caseWrapperList){
                                List<benefitsWrapper> KTAPBenWrapperList = new List<benefitsWrapper>();
                                List<benefitsWrapper> KinshipBenWrapperList = new List<benefitsWrapper>();
                                List<benefitsWrapper> otherBenWrapperList = new List<benefitsWrapper>();
                                List<benefitsWrapper> MedicaidBenWrapperList = new List<benefitsWrapper>();
                                List<benefitsWrapper> SSBenWrapperList = new List<benefitsWrapper>();
                                List<benefitsWrapper> KIHIPPBenWrapperList = new List<benefitsWrapper>();
                                benefitsWrapper SNAPBenWrap = new benefitsWrapper();
                                benefitsWrapper CCBenWrap = new benefitsWrapper();
                                if(wrapCase.SNAPBenefitsList != null && (wrapCase.SNAPBenefitsList).size() > 0){
                                    for(SSP_BenefitInformationWrapper ben : wrapCase.SNAPBenefitsList){
                                            SNAPBenWrap.fullName = String.isBlank(SNAPBenWrap.fullName) ? ben.IndividualName : SNAPBenWrap.fullName + ', ' + ben.IndividualName;
                                            SNAPBenWrap.programCode = ben.ProgramCode;
                                            SNAPBenWrap.isSNAPProgram = true;
                                            SNAPBenWrap.benefitCombined = ben;
                                    }
                                }
                                
                                if(wrapCase.KTAPBenefitsMap.keyset() != null && (wrapCase.KTAPBenefitsMap.keyset()).size() > 0){
                                    for(String EDGNumber : wrapCase.KTAPBenefitsMap.keyset()){
                                        benefitsWrapper KTAPBenWrap = new benefitsWrapper();
                                        for(SSP_BenefitInformationWrapper ben : wrapCase.KTAPBenefitsMap.get(EDGNumber)){
                                            KTAPBenWrap.fullName = String.isBlank(KTAPBenWrap.fullName) ? ben.IndividualName : KTAPBenWrap.fullName + ', ' + ben.IndividualName;
                                            KTAPBenWrap.programCode = ben.ProgramCode;
                                            KTAPBenWrap.isKTAPProgram = true;
                                            KTAPBenWrap.benefitCombined = ben;
                                        }
                                        KTAPBenWrapperList.add(KTAPBenWrap);
                                    }
                                }

                                if(wrapCase.KinshipBenefitsMap.keyset() != null && (wrapCase.KinshipBenefitsMap.keyset()).size() > 0){
                                    for(String EDGNumber : wrapCase.KinshipBenefitsMap.keyset()){
                                        benefitsWrapper KinshipBenWrap = new benefitsWrapper();
                                        for(SSP_BenefitInformationWrapper ben : wrapCase.KinshipBenefitsMap.get(EDGNumber)){
                                            KinshipBenWrap.fullName = String.isBlank(KinshipBenWrap.fullName) ? ben.IndividualName : KinshipBenWrap.fullName + ', ' + ben.IndividualName;
                                            KinshipBenWrap.programCode = SSP_GlobalConstants.KinshipCare;
                                            KinshipBenWrap.isKinshipProgram = true;
                                            KinshipBenWrap.benefitCombined = ben;
                                        }
                                        KinshipBenWrapperList.add(KinshipBenWrap);
                                    }
                                }
                                
                                if(wrapCase.CCBenefitsList != null && (wrapCase.CCBenefitsList).size() > 0){
                                    for(SSP_BenefitInformationWrapper ben : wrapCase.CCBenefitsList){
                                            if(String.isNotBlank(ben.ActiveEnrollmentCount) || String.isNotBlank(ben.PendingEnrollmentCount)){
                                                CCWrapper ccWrap = new CCWrapper();
                                                ccWrap.fullName = ben.IndividualName;
                                                ccWrap.activeEnrollments = ben.ActiveEnrollmentCount == null ? SSP_GlobalConstants.zeroValue : ben.ActiveEnrollmentCount;
                                                ccWrap.pendingEnrollments = ben.PendingEnrollmentCount == null ? SSP_GlobalConstants.zeroValue : ben.PendingEnrollmentCount;
                                                ccWrap.individualId = ben.IndividualId;
                                                CCBenWrap.CCWrapperList.add(ccWrap);
                                            }
                                            CCBenWrap.fullName = String.isBlank(CCBenWrap.fullName) ? ben.IndividualName : CCBenWrap.fullName + ', ' + ben.IndividualName;
                                            CCBenWrap.programCode = ben.ProgramCode;
                                            CCBenWrap.isCCProgram = true;
                                            CCBenWrap.benefitCombined = ben;
                                    }
                                }
                                
                                if(wrapCase.otherBenefitsList != null && (wrapCase.otherBenefitsList).size() > 0){
                                    for(SSP_BenefitInformationWrapper ben : wrapCase.otherBenefitsList){
                                        benefitsWrapper otherBenWrap = new benefitsWrapper();
                                        if(ben.ProgramCode == system.label.SSP_Medicaid){
                                            otherBenWrap.fullName = ben.IndividualName;
                                            otherBenWrap.programCode = ben.ProgramCode;
                                            otherBenWrap.benefitCombined = ben;
                                            MedicaidBenWrapperList.add(otherBenWrap);
                                        }
                                        if(ben.ProgramCode == system.label.SSP_StateSupplementation){
                                            otherBenWrap.fullName = ben.IndividualName;
                                            otherBenWrap.programCode = ben.ProgramCode;
                                            otherBenWrap.benefitCombined = ben;
                                            SSBenWrapperList.add(otherBenWrap);
                                        }
                                        if(ben.ProgramCode == system.label.SSP_KIHIPP){
                                            otherBenWrap.fullName = ben.IndividualName;
                                            otherBenWrap.programCode = ben.ProgramCode;
                                            otherBenWrap.benefitCombined = ben;
                                            KIHIPPBenWrapperList.add(otherBenWrap);
                                        }
                                        
                                    }
                                }
                                
                                wrapCase.SNAPBenefit = SNAPBenWrap;
                                wrapCase.CCBenefit = CCBenWrap;
                                wrapCase.otherBenefits = otherBenWrapperList;
                                wrapCase.MedicaidBenefits = MedicaidBenWrapperList;
                                wrapCase.SSBenefits = SSBenWrapperList;
                                wrapCase.KIHIPPBenefits = KIHIPPBenWrapperList;
                                wrapCase.KTAPBenefitsPerEDGList = KTAPBenWrapperList;
                                wrapCase.KinshipBenefitsPerEDGList = KinshipBenWrapperList;
                            }
                        }
                        
                        toSend.put('caseWrapperList', JSON.serialize(caseWrapperList));
                        
                        //To segregate "Active&Pending" and "Inactive" Cases.
                        for(caseDataWrapper wrap : caseWrapperList){
                            String currentCaseStatus = mapCaseVsStatus.get(wrap.caseNumber);
                            
                            if(currentCaseStatus == SSP_GlobalConstants.PE_Code || currentCaseStatus == SSP_GlobalConstants.AP_Code || currentCaseStatus == SSP_GlobalConstants.PI_Code){
                                activeCasesList.add(wrap);
                            }
                            else{
                                inactiveCasesList.add(wrap);
                            }
                        }
                    }
                    toSend.put('activeCases', JSON.serialize(activeCasesList));
                    toSend.put('inactiveCases', JSON.serialize(inactiveCasesList));

                    // Logic to Call and pass data for Waiver Programs to LWC
                    SSP_LightningResponse response = getWaiverProgramsData();
                    toSend.put('mapWaiverDetails', JSON.serialize(response.mapResponse.get('mapWaiverDetails')));
                    toSend.put('mapWaiverStatus', JSON.serialize(response.mapResponse.get('mapWaiverStatus')));
                    toSend.put('listWaiverStatus', JSON.serialize(response.mapResponse.get('listWaiverStatus')));
                }
                else {
                    toSend.put('NoData', 'No data recieved!!');
                }
            }
            else if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='NotAccessible'){
                toSend.put('showScreen',false);
            }
            if(objMatrix != null && objMatrix.screenPermission!=null && objMatrix.screenPermission =='ReadOnly'){
                toSend.put('disabled',true);
            }
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_BenefitsPageController', 'getBenefitsData', ex.getMessage() , true);
        }
        return toSend;
    }


    /***************************************************************************************************
    * @author       Shivam Tiwari
    * @date         July-28-2020
    * @methodname   getWaiverProgramsData
    * @description  This methods is used to get data for Waiver Programs from Service call.
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse getWaiverProgramsData(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        RSSP_DC_Wrapper responseWrapper = new RSSP_DC_Wrapper();
        Map<String, SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> mapWaiverApplications = new Map<String, SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>();
        Map<String, SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> mapWaiverCase = new Map<String, SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>();
        Map<String, waiverDetailsFormattedWrapper> mapIndividualId_WaiverDetailWrapper = new Map<String, waiverDetailsFormattedWrapper>();
        Map<String, List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>> mapIndividualId_WaiverStatusListWrapper = new Map<String, List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>>();
        List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> listAllWaiverStatus = new List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>();
        try{
            //Waiver Program Service callout
            Map<String, Object> mapParams = new Map<String, Object>();
            SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
            reqWrapper.viewName = SSP_InterfaceConstants.WAIVER_DETAILS;
            //reqWrapper.primaryApplicationIndividualId = 800003384; // HOH Indiviudal Id - Not sending confirmed with Rajeev.
            reqWrapper.individualIds = ssp_utility.getCurrentUserAllIndividualIds(); //';' seperated string of all individual Ids from Contact Mapping.
            //reqWrapper.individualIds = '700005170;100201332;700009679;550007502;1251007998;700040110;810204131';
            mapParams.put(SSP_InterfaceConstants.JSON_BODY, reqWrapper);
            List<Object> serviceResponses = IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams);
            responseWrapper = (RSSP_DC_Wrapper) serviceResponses[0];

            if(responseWrapper != null && responseWrapper.waiverDetailsPayload != null){
                SSP_WaiverDetailsPayloadWrapper waiverResponseDataWrapper = responseWrapper.waiverDetailsPayload;
                //Waiver Details wrapper Data
                if(waiverResponseDataWrapper.WaiverDetails != null && (waiverResponseDataWrapper.WaiverDetails).size() > 0){
                    List<SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper> wrapperDetailsList = waiverResponseDataWrapper.WaiverDetails;
                    for(SSP_WaiverDetailsPayloadWrapper.WaiverDetailsWrapper detail : wrapperDetailsList){
                        waiverDetailsFormattedWrapper waiverWrapper = new waiverDetailsFormattedWrapper();
                        waiverWrapper.fullName = detail.IndividualName;
                        waiverWrapper.individualId = detail.IndividualId;
                        if(detail.HasBrainInjury == 'Y' || detail.IsVentilatorDependent == 'Y' || detail.RequireAssistance == 'Y' || detail.HasDevelopmentalDisability == 'Y' || detail.WillContinueServices == 'Y'){
                            waiverWrapper.atleastOneAnsweredYes = true;
                        }
                        else{
                            waiverWrapper.atleastOneAnsweredYes = false;
                        }
                        mapIndividualId_WaiverDetailWrapper.put(detail.IndividualId, waiverWrapper);
                    }
                }

                //Waiver Status wrapper Data
                if(waiverResponseDataWrapper.WaiverStatuses != null && (waiverResponseDataWrapper.WaiverStatuses).size() > 0){
                    List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> wrapperStatusList = waiverResponseDataWrapper.WaiverStatuses;
                    for(SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper status : wrapperStatusList){
                        if(!mapIndividualId_WaiverStatusListWrapper.keyset().contains(status.IndividualId)){
                            mapIndividualId_WaiverStatusListWrapper.put(status.IndividualId, new List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper>());
                        }
                        List<SSP_WaiverDetailsPayloadWrapper.WaiverStatusesWrapper> tempList = mapIndividualId_WaiverStatusListWrapper.get(status.IndividualId);
                        tempList.add(status);
                        mapIndividualId_WaiverStatusListWrapper.put(status.IndividualId, tempList);

                        //Prepare seperate maps for Application, Program and Cases
                        if(status.ApplicationStatus != null && status.ApplicationStatus != 'COM'){
                            mapWaiverApplications.put(status.ApplicationNumber, status);
                        }
                        else if(status.ProgramStatusCode != null && (status.ProgramStatusCode == 'EN' || status.ProgramStatusCode == 'WL')){
                            listAllWaiverStatus.add(status);
                        }
                        else if(status.WaiverCaseStatus != null){
                            mapWaiverCase.put(status.WavierCaseNumber, status);
                        }
                    }
                }

                //Add Waiver Case Status record to All records list
                if(mapWaiverCase != null && mapWaiverCase.keyset().size() > 0){
                    for(String waiverCase : mapWaiverCase.keyset()){
                        listAllWaiverStatus.add(mapWaiverCase.get(waiverCase));
                    }
                }

                //Add Waiver Application Status record to All records list
                if(mapWaiverApplications != null && mapWaiverApplications.keyset().size() > 0){
                    for(String waiverApp : mapWaiverApplications.keyset()){
                        listAllWaiverStatus.add(mapWaiverApplications.get(waiverApp));
                    }
                }
            }
            toSend.put('mapWaiverDetails', mapIndividualId_WaiverDetailWrapper);
            toSend.put('mapWaiverStatus', mapIndividualId_WaiverStatusListWrapper);
            toSend.put('listWaiverStatus', listAllWaiverStatus);

            //Added to store in Session Cache to do Security Checks in Waiver Screening questions screen.
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            sessionPart.put('listIndividualIds', reqWrapper.individualIds.split(';'));
            sessionPart.put('mapWaiverDetails', mapIndividualId_WaiverDetailWrapper);
            sessionPart.put('mapWaiverStatus', mapIndividualId_WaiverStatusListWrapper);
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_BenefitsPageController', 'getWaiverProgramsData', ex.getMessage() , true);
        }
        return toSend;
    }
    
    /***************************************************************************************************
    * @author       Shivam Tiwari
    * @date         June-25-2020
    * @methodname   applicationButtonDetails
    * @description  This methods is used to get Benefits related data from cache
    * @return       SSP_LightningResponse
    *****************************************************************************************************/
    @AuraEnabled
    public static SSP_LightningResponse applicationButtonDetails(){
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        Map<String,String> mapCaseVsStatus = new Map<String,String>();
        List<String> activeCaseNumberList = new List<String>();
        List<String> inactiveCaseNumberList = new List<String>();
        List<SSP_ApplicationIndividual__c> lstAppIndividual = new List<SSP_ApplicationIndividual__c>();
        Map<String, List<string>> mapApplicationVsPrograms = new Map<String, List<string>>();
        List<String> lstUnsubmittedApps = new List<String>();
        Map<String,List<failureDataWrapper>> mapCasevsData = new Map<String,List<failureDataWrapper>>();
        List<caseDataWrapper> underReviewCasesList = new List<caseDataWrapper>();
        String selectedRole = '';
        String mapCaseVsStatusString = '';
        Set<id> applicationIdsSet = new Set<id>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        try{
            mapCaseVsStatusString = sessionpart.get('caseVsStatus') != null ? String.valueOf(sessionpart.get('caseVsStatus')) : String.valueOf(sessionpart.get(SSP_CacheBuilderImplementationDabhboard.class,'caseVsStatus'));
            selectedRole = SSP_Utility.getSelectedRole();
            Map<String,String> map_RoleLabelValue = SSP_Utility.getPickListValues('User', 'ApplicableRoles__c', null);
            if(selectedRole != null && selectedRole != ''){
                selectedRole = map_RoleLabelValue.get(selectedRole);
            }
            toSend.put('selectedRole', selectedRole);
            
            if(String.isNotBlank(mapCaseVsStatusString)){
                mapCaseVsStatus = (Map<String,String>)JSON.deserialize(String.valueOf(mapCaseVsStatusString), Map<String,String>.class);
            }
            
            String individualId = SSP_Utility.getIndividualId();
            toSend.put('individualId', individualId);
            Contact individualContact = SSP_DashboardService.getIndividualContact(individualId);
            String memberId = SSP_DashboardService.getMemberId(individualContact.Id);
            if(memberId != null){
                lstAppIndividual =SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                                                   new Set<String>{'Id','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','IsHeadOfHousehold__c','toLabel(ProgramsApplied__c)','SSP_Application__c','SSP_Member__r.Name','SSP_Application__r.name','SSP_Application__r.RecordType.DeveloperName','SSP_Application__r.SignatureDate__c','SSP_Application__r.dccasenumber__c','SSP_Application__r.Status__c','SSP_Application__r.ApplicationReceivedDateTime__c','createdDate','SSP_Application__r.ApplicationCreationInSSP__c','toLabel(SSP_Application__r.ProgramsApplied__c)'}, 
                                                                                                   new Map<String, String>{'limit'=>'1000','SSP_Member__c'=> memberId/*,'SSP_Application__r.Status__c'=>'UN'*/,'SSP_Application__r.RecordType.DeveloperName'=>'SSP_Application'});

                //App indvs logic start here
                if(lstAppIndividual != null && lstAppIndividual.size() > 0){
                    for(SSP_ApplicationIndividual__c appInd: lstAppIndividual){
                        applicationIdsSet.add(appInd.SSP_Application__c);
                    }
                }
                
                if(applicationIdsSet != null && applicationIdsSet.size() > 0){
                    String appId = (String)(new List<Id>(applicationIdsSet))[0];
                    lstAppIndividual =SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND','hasToLabel'=>'true'}, 
                                                                                                   new Set<String>{'Id','SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','IsHeadOfHousehold__c','toLabel(ProgramsApplied__c)','SSP_Application__c','SSP_Member__r.Name','SSP_Application__r.name','SSP_Application__r.RecordType.DeveloperName','SSP_Application__r.SignatureDate__c','SSP_Application__r.dccasenumber__c','SSP_Application__r.Status__c','SSP_Application__r.ApplicationReceivedDateTime__c','createdDate','SSP_Application__r.ApplicationCreationInSSP__c','toLabel(SSP_Application__r.ProgramsApplied__c)'}, 
                                                                                                   new Map<String, String>{'limit'=>'1000','SSP_Application__c'=> appId/*,'SSP_Application__r.Status__c'=>'UN'*/,'SSP_Application__r.RecordType.DeveloperName'=>'SSP_Application'});
                }
            }
            //App indvs logic ends here

            if(lstAppIndividual != null && lstAppIndividual.size() > 0){
                for(SSP_ApplicationIndividual__c objAppIndividual: lstAppIndividual){
                    if((objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c != null && (8 - (objAppIndividual.SSP_Application__r.ApplicationCreationInSSP__c.daysBetween(SSP_utility.today())) >= 0)  && (objAppIndividual.SSP_Application__r.RecordType.DeveloperName=='SSP_Application')  && (objAppIndividual.ssp_application__r.Status__c == 'UN'))){
                        lstUnsubmittedApps.add(objAppIndividual.SSP_Application__c);
                    }
                    if(objAppIndividual.SSP_Application__r.Status__c=='P' && objAppIndividual.SSP_Application__r.dccasenumber__c == null && mapCaseVsStatus.keyset().size() == 0 && lstUnsubmittedApps.size() == 0){
                        String underReviewApplicationNumber;   
                        List<String> underReviewPrograms =  new List<String>();
                        underReviewApplicationNumber = objAppIndividual.SSP_Application__r.name;
                        if(objAppIndividual.IsHeadOfHousehold__c && objAppIndividual.SSP_Application__r.ProgramsApplied__c != null){
                            underReviewPrograms = objAppIndividual.SSP_Application__r.ProgramsApplied__c.split(';');
                        }else if((!objAppIndividual.IsHeadOfHousehold__c) && objAppIndividual.ProgramsApplied__c != null){
                            underReviewPrograms = objAppIndividual.ProgramsApplied__c.split(';');
                        }
                        //Logic starts
                        if(underReviewPrograms != null && underReviewPrograms.size() > 0){
                            for(String prog : underReviewPrograms){
                                String reviewDate = objAppIndividual.SSP_Application__r.SignatureDate__c != null ? String.valueof(objAppIndividual.SSP_Application__r.SignatureDate__c+30):null;
                                failureDataWrapper wp = new failureDataWrapper(objAppIndividual.SSP_Member__r.FirstName__c + ' ' + objAppIndividual.SSP_Member__r.LastName__c, prog,reviewDate);
                                if(!mapCasevsData.keyset().contains(underReviewApplicationNumber)){
                                    mapCasevsData.put(underReviewApplicationNumber, new List<failureDataWrapper>());
                                }
                                List<failureDataWrapper> tempList = mapCasevsData.get(underReviewApplicationNumber);
                                tempList.add(wp);
                                mapCasevsData.put(underReviewApplicationNumber, tempList);
                            }
                        }
                        //Logic ends
                    }
                }
                toSend.put('mapUnderReviewApplicationVsPrograms', mapCasevsData);
                
                if(lstUnsubmittedApps != null && lstUnsubmittedApps.size() > 0){
                    toSend.put('hasPendingApplication', true);
                    toSend.put('listPendingApps', lstUnsubmittedApps);
                }
                else{
                    toSend.put('hasPendingApplication', false);
                }
            }
            
            if(mapCasevsData.keyset().size() > 0){
                for (String caseNumber : mapCasevsData.keyset()) {
                    if(mapCasevsData.get(caseNumber) != null && mapCasevsData.get(caseNumber).size() > 0){
                        caseDataWrapper wrap = new caseDataWrapper();
                        wrap.caseNumber = caseNumber;
                        wrap.isFailureScenario = true;
                        for(failureDataWrapper data : mapCasevsData.get(caseNumber)){
                            SSP_BenefitInformationWrapper benWrap = new SSP_BenefitInformationWrapper();
                            benWrap.ProgramCode = data.programName;
                            benWrap.IndividualName = data.fullName;
                            benWrap.ReviewDate = data.reviewDate;
                            benWrap.ProgramStatusCode = SSP_GlobalConstants.UR_Code;
                            if(data.programName == system.label.SSP_SNAP || data.programName.contains('SNAP')){
                                wrap.SNAPBenefitsList.add(benWrap);
                            }
                            else if(data.programName == system.label.SSP_KTAP || data.programName.contains('KTAP')){
                                wrap.KTAPBenefitsList.add(benWrap);
                            }
                            else if(data.programName == system.label.SSP_ChildCareAssistance || data.programName.contains('Child Care Assistance')){
                                wrap.CCBenefitsList.add(benWrap);
                            }
                            else{
                                wrap.otherBenefitsList.add(benWrap);
                            }
                        }
                        underReviewCasesList.add(wrap);
                    }
                }
                
                if(underReviewCasesList != null && underReviewCasesList.size() > 0){
                    for(caseDataWrapper wrapCase : underReviewCasesList){
                        List<benefitsWrapper> MedicaidBenWrapperList = new List<benefitsWrapper>();
                        List<benefitsWrapper> SSBenWrapperList = new List<benefitsWrapper>();
                        List<benefitsWrapper> KIHIPPBenWrapperList = new List<benefitsWrapper>();
                        benefitsWrapper SNAPBenWrap = new benefitsWrapper();
                        benefitsWrapper KTAPBenWrap = new benefitsWrapper();
                        benefitsWrapper KinshipBenWrap = new benefitsWrapper();
                        benefitsWrapper CCBenWrap = new benefitsWrapper();
                        if(wrapCase.SNAPBenefitsList != null && (wrapCase.SNAPBenefitsList).size() > 0){
                            for(SSP_BenefitInformationWrapper ben : wrapCase.SNAPBenefitsList){
                                    SNAPBenWrap.fullName = String.isBlank(SNAPBenWrap.fullName) ? ben.IndividualName : SNAPBenWrap.fullName + ', ' + ben.IndividualName;
                                    SNAPBenWrap.programCode = ben.ProgramCode;
                                    SNAPBenWrap.isSNAPProgram = true;
                                    SNAPBenWrap.benefitCombined = ben;
                            }
                        }
                        if(wrapCase.KTAPBenefitsList != null && (wrapCase.KTAPBenefitsList).size() > 0){
                            for(SSP_BenefitInformationWrapper ben : wrapCase.KTAPBenefitsList){
                                    KTAPBenWrap.fullName = String.isBlank(KTAPBenWrap.fullName) ? ben.IndividualName : KTAPBenWrap.fullName + ', ' + ben.IndividualName;
                                    KTAPBenWrap.programCode = ben.ProgramCode;
                                    KTAPBenWrap.isKTAPProgram = true;
                                    KTAPBenWrap.benefitCombined = ben;
                            }
                        }
                        if(wrapCase.KinshipBenefitsList != null && (wrapCase.KinshipBenefitsList).size() > 0){
                            for(SSP_BenefitInformationWrapper ben : wrapCase.KinshipBenefitsList){
                                    KinshipBenWrap.fullName = String.isBlank(KinshipBenWrap.fullName) ? ben.IndividualName : KinshipBenWrap.fullName + ', ' + ben.IndividualName;
                                    KinshipBenWrap.programCode = SSP_GlobalConstants.KinshipCare;
                                    KinshipBenWrap.isKinshipProgram = true;
                                    KinshipBenWrap.benefitCombined = ben;
                            }
                        }
                        if(wrapCase.CCBenefitsList != null && (wrapCase.CCBenefitsList).size() > 0){
                            for(SSP_BenefitInformationWrapper ben : wrapCase.CCBenefitsList){
                                    CCBenWrap.fullName = String.isBlank(CCBenWrap.fullName) ? ben.IndividualName : CCBenWrap.fullName + ', ' + ben.IndividualName;
                                    CCBenWrap.programCode = ben.ProgramCode;
                                    CCBenWrap.isCCProgram = true;
                                    CCBenWrap.benefitCombined = ben;
                            }
                        }
                        if(wrapCase.otherBenefitsList != null && (wrapCase.otherBenefitsList).size() > 0){
                            for(SSP_BenefitInformationWrapper ben : wrapCase.otherBenefitsList){
                                benefitsWrapper otherBenWrap = new benefitsWrapper();
                                if(ben.ProgramCode == system.label.SSP_Medicaid){
                                    otherBenWrap.fullName = ben.IndividualName;
                                    otherBenWrap.programCode = ben.ProgramCode;
                                    otherBenWrap.benefitCombined = ben;
                                    MedicaidBenWrapperList.add(otherBenWrap);
                                }
                                if(ben.ProgramCode == system.label.SSP_StateSupplementation || ben.ProgramCode == 'State Supplementation'){
                                    otherBenWrap.fullName = ben.IndividualName;
                                    otherBenWrap.programCode = ben.ProgramCode;
                                    otherBenWrap.benefitCombined = ben;
                                    SSBenWrapperList.add(otherBenWrap);
                                }
                                if(ben.ProgramCode == system.label.SSP_KIHIPP || ben.ProgramCode.contains('KI-HIPP')){
                                    otherBenWrap.fullName = ben.IndividualName;
                                    otherBenWrap.programCode = ben.ProgramCode;
                                    otherBenWrap.benefitCombined = ben;
                                    KIHIPPBenWrapperList.add(otherBenWrap);
                                }
                            }
                        }
                        wrapCase.SNAPBenefit = SNAPBenWrap;
                        wrapCase.KTAPBenefit = KTAPBenWrap;
                        wrapCase.KinshipBenefit = KinshipBenWrap;
                        wrapCase.CCBenefit = CCBenWrap;
                        wrapCase.MedicaidBenefits = MedicaidBenWrapperList;
                        wrapCase.SSBenefits = SSBenWrapperList;
                        wrapCase.KIHIPPBenefits = KIHIPPBenWrapperList;
                    }
                }
            }
            toSend.put('listUnderReviewApplicationVsPrograms', JSON.serialize(underReviewCasesList));
            
            if(mapCaseVsStatus.size() > 0){
                for(String caseNumber : mapCaseVsStatus.keyset()){
                    if(mapCaseVsStatus.get(caseNumber) == SSP_GlobalConstants.DN_Code || mapCaseVsStatus.get(caseNumber) == SSP_GlobalConstants.DC_Code){
                        inactiveCaseNumberList.add(caseNumber);
                    }
                    else{
                        activeCaseNumberList.add(caseNumber);
                    }
                }
                
            }
            
            toSend.put('hasActiveCases', (activeCaseNumberList != null && activeCaseNumberList.size() > 0));
            toSend.put(SSP_GlobalConstants.SCREEN_PERMISSION_KEY, SSP_Utility.getScreenAccessDetails('BENEFITS', null));
            toSend.put('programLevelAccess', SSP_Utility.getAvailableProgramsByRole());
            toSend.put('hasRACCases', String.valueOf(sessionpart.get('hasActiveCase')));
        }
        catch(Exception ex){
            LOG_LogMessageUtility.logMessage(ex, 'SSP_BenefitsPageController', 'applicationButtonDetails', ex.getMessage() , true);
        }
        return toSend;
    }
    
    
    public class caseDataWrapper{
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String programCode;
        @AuraEnabled public Boolean isFailureScenario = false;
        @AuraEnabled public benefitsWrapper SNAPBenefit = new benefitsWrapper();
        @AuraEnabled public benefitsWrapper CCBenefit = new benefitsWrapper();
        @AuraEnabled public benefitsWrapper KTAPBenefit = new benefitsWrapper();
        @AuraEnabled public benefitsWrapper KinshipBenefit = new benefitsWrapper();
        @AuraEnabled public Map<String, List<SSP_BenefitInformationWrapper>> KTAPBenefitsMap = new Map<String, List<SSP_BenefitInformationWrapper>>();
        @AuraEnabled public Map<String, List<SSP_BenefitInformationWrapper>> KinshipBenefitsMap = new Map<String, List<SSP_BenefitInformationWrapper>>();
        @AuraEnabled public List<benefitsWrapper> otherBenefits = new List<benefitsWrapper>();
        @AuraEnabled public List<benefitsWrapper> MedicaidBenefits = new List<benefitsWrapper>();
        @AuraEnabled public List<benefitsWrapper> SSBenefits = new List<benefitsWrapper>();
        @AuraEnabled public List<benefitsWrapper> KIHIPPBenefits = new List<benefitsWrapper>();
        @AuraEnabled public List<benefitsWrapper> KTAPBenefitsPerEDGList = new List<benefitsWrapper>();
        @AuraEnabled public List<benefitsWrapper> KinshipBenefitsPerEDGList = new List<benefitsWrapper>();

        @AuraEnabled public List<SSP_BenefitInformationWrapper> SNAPBenefitsList = new List<SSP_BenefitInformationWrapper>();
        @AuraEnabled public List<SSP_BenefitInformationWrapper> CCBenefitsList = new List<SSP_BenefitInformationWrapper>();
        @AuraEnabled public List<SSP_BenefitInformationWrapper> KTAPBenefitsList = new List<SSP_BenefitInformationWrapper>();
        @AuraEnabled public List<SSP_BenefitInformationWrapper> KinshipBenefitsList = new List<SSP_BenefitInformationWrapper>();
        @AuraEnabled public List<SSP_BenefitInformationWrapper> otherBenefitsList = new List<SSP_BenefitInformationWrapper>();
    }
    
    public class benefitsWrapper{
        @AuraEnabled public String fullName;
        @AuraEnabled public String programCode;
        @AuraEnabled public String benefitBeginDate;
        @AuraEnabled public String benefitEndDate;
        @AuraEnabled public Boolean isSNAPProgram = false;
        @AuraEnabled public Boolean isKTAPProgram = false;
        @AuraEnabled public Boolean isKinshipProgram = false;
        @AuraEnabled public Boolean isCCProgram = false;
        @auraEnabled public List<CCWrapper> CCWrapperList = new List<CCWrapper>();
        @AuraEnabled public SSP_BenefitInformationWrapper benefitCombined = new SSP_BenefitInformationWrapper();
    }
    
    public class CCWrapper{
        @AuraEnabled public String fullName;
        @AuraEnabled public String activeEnrollments;
        @AuraEnabled public String pendingEnrollments;
        @AuraEnabled public String individualId;
    }
    
    public class benefitDetailsWrapper{
        @AuraEnabled public String programCode;
        @AuraEnabled public String programStatus;
        @AuraEnabled public String renewalDueDate;
        @AuraEnabled public String programType;
        @AuraEnabled public String benefitPeriod;
    }
    
    public class failureDataWrapper{
        @AuraEnabled public String fullName;
        @AuraEnabled public String programName;
        @AuraEnabled public String reviewDate;
        
        public failureDataWrapper(String fullName, String programName, String reviewDate){
            this.fullName = fullName;
            this.programName = programName;
            this.reviewDate = reviewDate;
        }
    }

    public class waiverDetailsFormattedWrapper{
        @AuraEnabled public String fullName;
        @AuraEnabled public String individualId;
        @AuraEnabled public Boolean atleastOneAnsweredYes = false;
    }
    
}