/*
* classname     : SSP_HealthInformationService
* @description  : This class is use to select the Health selection information
* @author       : Ashwin Kasture
* @date         : 14/11/2019
* MODIFICATION LOG:
* DEVELOPER             DATE            DESCRIPTION
* ---------------------------------------------------------------------------------------------
* Ashwin Kasture        14/11/2019      Initial Version
*/
public with sharing class SSP_HealthInformationService {
    /* 
* method        : getHealthSelectionData
* @description  : This method is use to get the Member data by Application Id
* @author       : Ashwin Kasture
* @param        : String sApplicationId - It is the Application Id
* @return       : List<SSP_HealthInformationWrapper>
* */
    public static List<SSP_HealthInformationWrapper> getHealthSelectionData(String sApplicationId, String sMode) {
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new List<SSP_ApplicationIndividual__c>();
        List<SSP_HealthInformationWrapper> lstHealthInfoWrapper = new List<SSP_HealthInformationWrapper>();
        lstAppIndRecords = getMemberData(sApplicationId, sMode);
        
        if(!lstAppIndRecords.isEmpty()) {
            for(SSP_ApplicationIndividual__c objAppInd: lstAppIndRecords) {
                lstHealthInfoWrapper.add(assignHealthWrapperData(objAppInd));
            }
        }
        return lstHealthInfoWrapper;
    }
    
    /*
* method        : getMemberData
* @description  : This method is use to get the SSP Member data by Application Id
* @author       : Ashwin Kasture
* @param        : String sApplicationId - It is the Application Id
* @return       : List<SSP_ApplicationIndividual__c>
* */
    public static List<SSP_ApplicationIndividual__c> getMemberData(String sApplicationId, String sMode) {
        SSP_Utility.isAuthenticatedUser();
        List<SSP_ApplicationIndividual__c> lstAppIndRecords = new  List<SSP_ApplicationIndividual__c>();
        Map<String, String> detailMap = new Map<String, String>();
        Map<String, String> conditionMap = new Map<String, String>();
        List<String> lstApplnIndFields = new List<String>{'Id','ProgramsApplied__c','SSP_Application__c','SSP_Member__c','MedicaidType__c'};
            List<String> lstSSPMemberFields = new List<String>{'HasEmergencyMedicalConditionToggle__c','IsDisabledToggle__c','IsBlindToggle__c','IsRecoveryFromIllnessOrInjuryToggle__c',
                'IsReceivingMedicareBenefitToggle__c','IsPregnantInLastThreeMonthsToggle__c',
                'FirstName__c','LastName__c','IsUSCitizenToggle__c','GenderCode__c','Age__c','DisabilityVerificationCode__c','BlindnessVerificationCode__c','TBQIndividualVerificationCode__c'};
                    Boolean canViewApplIndFields = ESAPI.accessController().isAuthorizedToView(SSP_ApplicationIndividual__c.getSObjectType(), lstApplnIndFields);
        Boolean canViewSSPMemberFields = ESAPI.accessController().isAuthorizedToView(SSP_Member__c.getSObjectType(), lstSSPMemberFields);
        
        if(canViewApplIndFields && canViewSSPMemberFields) {
            Set<String> allApplIndFieldSet = new Set<String>{'Id','SSP_Application__r.RAC_Selected_Options__c','ProgramsApplied__c','MedicaidType__c','SSP_Application__c','SSP_Member__c',
                'SSP_Member__r.Contact__r.Age__c','SSP_Member__r.HasEmergencyMedicalConditionToggle__c',
                'SSP_Member__r.IsDisabledToggle__c','SSP_Member__r.IsBlindToggle__c',
                'SSP_Member__r.IsRecoveryFromIllnessOrInjuryToggle__c','SSP_Application__r.HasPendingAccidentSettlementToggle__c',
                'SSP_Member__r.IsReceivingMedicareBenefitToggle__c','SSP_Member__r.IsPregnantInLastThreeMonthsToggle__c',
                'SSP_Member__r.FirstName__c','SSP_Member__r.LastName__c','SSP_Member__r.IsUSCitizenToggle__c',
                'SSP_Member__r.GenderCode__c','SSP_Member__r.Age__c','SSP_Member__r.IsRequestingOrReceivingCISToggle__c',
                'SSP_Member__r.IsReceivingCaretakerServicesToggle__c','SSP_Member__r.DisabilityVerificationCode__c',
                'SSP_Member__r.BlindnessVerificationCode__c','SSP_Member__r.TBQIndividualVerificationCode__c','SSP_Member__r.IndividualId__c',
                'SSP_Member__r.DCEMCId__c','SSP_Member__r.EmergencyEndDate__c'}; //#385049 Added SSP_Application__r.RAC_Selected_Options__c field
                    detailMap.put('objectName','SSP_ApplicationIndividual__c');
            conditionMap.put('SSP_Application__c', sApplicationId);
            conditionMap.put('IsTMember__c', String.valueOf(false));
            // Added below condition for addRemoveMember flow
            if(String.isNotBlank(sMode) && SSP_GlobalConstants.MODE.equals(sMode)) {
                detailMap.put('operator', 'AND');
                conditionMap.put('MemberStatus__c', SSP_GlobalConstants.MEMBER_STATUS_New);
            }
            lstAppIndRecords = SSP_ApplicationIndividualSelector.queryApplicationIndividualData (
                detailMap,
                allApplIndFieldSet,
                conditionMap
            );
            
            if(String.isNotBlank(sMode) && SSP_GlobalConstants.SSP_RAC_FLOW.equals(sMode)) {
                lstAppIndRecords = SSP_Utility.filterApplicationIndividualsForRAC(lstAppIndRecords, sApplicationId);
            }
        }
        return lstAppIndRecords;
    }
    
    /*
* method        : setHealthSelectionData
* @description  : This method is use to update the SSP_Member data
* @author       : Ashwin Kasture
* @param        : List<SSP_HealthInformationWrapper> lstMemberHealhSelectionData
* @return       : List<SSP_Member__c>
* */
    public static List<SSP_Member__c> storeHealthSelectionData(String sApplicationId, String lstMemberHealhSelectionData, String sApplicationData) {
        
        SSP_Utility.isAuthenticatedUser();
        List<SSP_Member__c> lstMemberData = new List<SSP_Member__c>();
        List<Object> memberList = (List<Object>)JSON.deserializeUntyped(lstMemberHealhSelectionData);
        List<String> lstAppFields = new List<String>{'HasPendingAccidentSettlementToggle__c'};
            SSP_Application__c objApplication = new SSP_Application__c();
        SSP_HealthInformationWrapper.SSP_ApplicationData objAppWrap = new SSP_HealthInformationWrapper.SSP_ApplicationData();
        List<SSP_Application__c> listObjApplication = new List<SSP_Application__c>(); //Added as part of Performance tuning - Keshav
        if(sApplicationData != NULL){
            objAppWrap = (SSP_HealthInformationWrapper.SSP_ApplicationData)JSON.deserialize(sApplicationData, SSP_HealthInformationWrapper.SSP_ApplicationData.class);
        }
        if(sApplicationId != NULL && objAppWrap != NULL){
            objApplication = new SSP_Application__c(ID = sApplicationId);
            objApplication.HasPendingAccidentSettlementToggle__c = objAppWrap.sHasPendingAccidentSettlement;
            for(Object objMem: memberList) {
                Map<String, Object> memberData = (Map<String, Object>)objMem;
                SSP_Member__c objMemberData = new SSP_Member__c();
                objMemberData.Id = String.valueOf(memberData.get('sMemberId'));
                objMemberData.HasEmergencyMedicalConditionToggle__c = memberData.get('sHasEmergencyMedicalCondition') != null ? String.valueOf(memberData.get('sHasEmergencyMedicalCondition')) : '';
                objMemberData.IsDisabledToggle__c = memberData.get('sIsDisabled') != null ? String.valueOf(memberData.get('sIsDisabled')) : '';
                objMemberData.IsBlindToggle__c = memberData.get('sIsBlind') != null ? String.valueOf(memberData.get('sIsBlind')) : '';
                objMemberData.IsRecoveryFromIllnessOrInjuryToggle__c = memberData.get('sIsRecoveryFromIllnessOrInjury') != null ? String.valueOf(memberData.get('sIsRecoveryFromIllnessOrInjury')) : '';
                objMemberData.IsReceivingMedicareBenefitToggle__c = memberData.get('sIsReceivingMedicareBenefit') != null ? String.valueOf(memberData.get('sIsReceivingMedicareBenefit')) : '';
                objMemberData.IsPregnantInLastThreeMonthsToggle__c = memberData.get('sIsPregnantInLastThreeMonths') != null ? String.valueOf(memberData.get('sIsPregnantInLastThreeMonths')) : '';
                objMemberData.IsRequestingOrReceivingCISToggle__c = memberData.get(
                    'sIsRequestingOrReceivingCIS'
                ) != null
                    ? String.valueOf(memberData.get('sIsRequestingOrReceivingCIS'))
                    : '';
                objMemberData.IsReceivingCaretakerServicesToggle__c = memberData.get(
                    'sIsReceivingCaretakerServices'
                ) != null
                    ? String.valueOf(memberData.get('sIsReceivingCaretakerServices'))
                    : '';
                lstMemberData.add(objMemberData);
            }
            listObjApplication.add(objApplication);
        }
        if(!lstMemberData.isEmpty() && objApplication != NULL) {
            //ESAPI.accessController().updateAsUser(objApplication, lstAppFields);
            //ESAPI.accessController().updateAsUser(new Map<Id, SSP_Application__c>(listObjApplication), lstAppFields); Perf fix - Keshav
            SSP_GenericDMLHelper.updateRecords(listObjApplication,lstAppFields);
            /*ESAPI.accessController().updateAsUser(new Map<Id, SSP_Member__c>(lstMemberData),new List<String>{'HasEmergencyMedicalConditionToggle__c','IsDisabledToggle__c','IsBlindToggle__c',
'IsRecoveryFromIllnessOrInjuryToggle__c','IsReceivingMedicareBenefitToggle__c','IsPregnantInLastThreeMonthsToggle__c',
'IsRequestingOrReceivingCISToggle__c','IsReceivingCaretakerServicesToggle__c'} );*/ //Updated to list of static fields for Perf fix - Keshav SSP_Utility.getFieldsNamesList(lstMemberData)
            SSP_GenericDMLHelper.updateRecords(lstMemberData,new List<String>{'HasEmergencyMedicalConditionToggle__c','IsDisabledToggle__c','IsBlindToggle__c',
                'IsRecoveryFromIllnessOrInjuryToggle__c','IsReceivingMedicareBenefitToggle__c','IsPregnantInLastThreeMonthsToggle__c',
                'IsRequestingOrReceivingCISToggle__c','IsReceivingCaretakerServicesToggle__c'});
            SSP_MemberService.checkMembersAgeBlindDisabledInfo(sApplicationId, null);
        }
        return lstMemberData;
    }
    
    /*
* method        : assignHealthWrapperData
* @description  : This method is use set the health selection wrapper data
* @author       : Ashwin Kasture
* @param        : SSP_ApplicationIndividual__c objAppInd - Contains single application data
* @return       : SSP_HealthInformationWrapper
* */
    public static SSP_HealthInformationWrapper assignHealthWrapperData(SSP_ApplicationIndividual__c objAppInd)
    {
        String sFirstName = '';
        String sLastName = '';
        SSP_HealthInformationWrapper objWrapperData = new SSP_HealthInformationWrapper();
        objWrapperData.sApplId = objAppInd.SSP_Application__c;
        objWrapperData.sMemberId = objAppInd.SSP_Member__c;
        objWrapperData.sProgramsApplied = objAppInd.ProgramsApplied__c;
        objWrapperData.sMedicaidType = objAppInd.MedicaidType__c;
        objWrapperData.sIsUSCitizen = objAppInd.SSP_Member__r.IsUSCitizenToggle__c;
        objWrapperData.sGenderCode = objAppInd.SSP_Member__r.GenderCode__c;
        objWrapperData.iMemberAge = Integer.valueOf(objAppInd.SSP_Member__r.Age__c);
        sFirstName = objAppInd.SSP_Member__r.FirstName__c != null? objAppInd.SSP_Member__r.FirstName__c: '';
        sLastName = objAppInd.SSP_Member__r.LastName__c != null? objAppInd.SSP_Member__r.LastName__c: '';
        objWrapperData.sMemberName = sFirstName + ' ' + sLastName;
        objWrapperData.sHasEmergencyMedicalCondition = objAppInd.SSP_Member__r.HasEmergencyMedicalConditionToggle__c;
        objWrapperData.sIsDisabled = objAppInd.SSP_Member__r.IsDisabledToggle__c;
        objWrapperData.sIsBlind = objAppInd.SSP_Member__r.IsBlindToggle__c;
        objWrapperData.sIsRecoveryFromIllnessOrInjury = objAppInd.SSP_Member__r.IsRecoveryFromIllnessOrInjuryToggle__c;
        objWrapperData.sHasPendingAccidentSettlement = objAppInd.SSP_Application__r.HasPendingAccidentSettlementToggle__c;
        objWrapperData.sIsReceivingMedicareBenefit = objAppInd.SSP_Member__r.IsReceivingMedicareBenefitToggle__c;
        objWrapperData.sIsPregnantInLastThreeMonths = objAppInd.SSP_Member__r.IsPregnantInLastThreeMonthsToggle__c;
        objWrapperData.sIsRequestingOrReceivingCIS = objAppInd.SSP_Member__r.IsRequestingOrReceivingCISToggle__c;
        objWrapperData.sIsReceivingCaretakerServices = objAppInd.SSP_Member__r.IsReceivingCaretakerServicesToggle__c;
        objWrapperData.isDisabilityVerified = objAppInd.SSP_Member__r.DisabilityVerificationCode__c;
        objWrapperData.isBlindnessVerified = objAppInd.SSP_Member__r.BlindnessVerificationCode__c;
        objWrapperData.isMedicareVerified = objAppInd.SSP_Member__r.TBQIndividualVerificationCode__c;
        objWrapperData.isOngoingEmergencyMedicalCondition = objAppInd.SSP_Member__r.DCEMCId__c != null ? true : false;
        objWrapperData.sRACSelectedOptions = objAppInd.SSP_Application__r.RAC_Selected_Options__c; //#385049        
        return objWrapperData;
    }
    
    public static SSP_LightningResponse handleTrackDeletion(
        String applicationId
    ) {
        SSP_LightningResponse toSend = new SSP_LightningResponse();
        try {
            List<SSP_TrackDeletion__c> listTrackDeletion = new List<SSP_TrackDeletion__c>();
            Set<String> memberIdSet = new Set<String>();
            Map<String, Set<String>> memberIdMap_yes = new Map<String, Set<String>>{
                SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID => new Set<String>(),
                    SSP_GlobalConstants.CIS_SCREENID => new Set<String>()
                    };
                        List<SSP_TrackDeletion__c> trackDeletionsToBeDeleted = new List<SSP_TrackDeletion__c>();
            Map<String, Map<String, Integer>> screenToMemberMap = new Map<String, Map<String, Integer>>{
                SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID => new Map<String, Integer>(),
                    SSP_GlobalConstants.CIS_SCREENID => new Map<String, Integer>()
                    };
                        Set<String> appIndvFields = new Set<String>{
                            'DCCareCoordinatorAddressId__c',
                                'DCCISntegrationSupplementationId__c',
                                'DCCareTakerIntegrationSupplementationId__c',
                                'CaretakerServiceIndividualId__c',
                                'DCCareTakerServiceId__c',
                                'SSP_Member__c',
                                'SSP_Member__r.IsReceivingCaretakerServicesToggle__c',
                                'SSP_Member__r.IsRequestingOrReceivingCISToggle__c'
                                };
                                    
                                    for (
                                        SSP_ApplicationIndividual__c appIndv : SSP_ApplicationIndividualSelector.queryApplicationIndividualMemberData(
                                            applicationId,
                                            appIndvFields
                                        )
                                    ) {
                                        
                                        if (
                                            appIndv != null &&
                                            appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c != null &&
                                            appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c.equals(
                                                SSP_GlobalConstants.NO
                                            ) &&
                                            (appIndv.CaretakerServiceIndividualId__c != null ||
                                             appIndv.DCCareTakerServiceId__c != null)
                                        ) {
                                            screenToMemberMap.get(SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID)
                                                .put(
                                                    appIndv.SSP_Member__c,
                                                    Integer.valueOf(appIndv.DCCareTakerServiceId__c)
                                                );
                                            memberIdSet.add(appIndv.SSP_Member__c);
                                        } else if (
                                            appIndv != null &&
                                            appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c != null &&
                                            appIndv.SSP_Member__r.IsReceivingCaretakerServicesToggle__c.equals(
                                                SSP_GlobalConstants.YES
                                            )
                                        ) {
                                            memberIdMap_yes.get(SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID)
                                                .add(appIndv.SSP_Member__c);
                                        }
                                        
                                        if (
                                            appIndv != null &&
                                            appIndv.SSP_Member__r.IsRequestingOrReceivingCISToggle__c != null &&
                                            appIndv.SSP_Member__r.IsRequestingOrReceivingCISToggle__c.equals(
                                                SSP_GlobalConstants.NO
                                            ) &&
                                            (appIndv.DCCareCoordinatorAddressId__c != null ||
                                             appIndv.DCCISntegrationSupplementationId__c != null ||
                                             appIndv.DCCareTakerIntegrationSupplementationId__c != null)
                                        ) {
                                            screenToMemberMap.get(SSP_GlobalConstants.CIS_SCREENID)
                                                .put(
                                                    appIndv.SSP_Member__c,
                                                    Integer.valueOf(
                                                        appIndv.DCCareTakerIntegrationSupplementationId__c
                                                    )
                                                );
                                            memberIdSet.add(appIndv.SSP_Member__c);
                                        } else if (
                                            appIndv != null &&
                                            appIndv.SSP_Member__r.IsRequestingOrReceivingCISToggle__c != null &&
                                            appIndv.SSP_Member__r.IsRequestingOrReceivingCISToggle__c.equals(
                                                SSP_GlobalConstants.YES
                                            )
                                        ) {
                                            memberIdMap_yes.get(SSP_GlobalConstants.CIS_SCREENID)
                                                .add(appIndv.SSP_Member__c);
                                        }
                                        
                                    }
            
            if (
                (memberIdSet != null && !memberIdSet.isEmpty()) ||
                ((memberIdMap_yes != null && !memberIdMap_yes.isEmpty()))
            ) {
                Set<String> cominedMemberIdSet = memberIdSet != null
                    ? memberIdSet
                    : new Set<String>();
                for (String key : memberIdMap_yes.keySet()) {
                    cominedMemberIdSet.addAll(memberIdMap_yes.get(key));
                }
                
                for (
                    SSP_TrackDeletion__c tdel : (List<SSP_TrackDeletion__c>) SSP_Utility.fetchRecords(
                        new Map<String, String>{
                            SSP_GlobalConstants.SSP_OBJECT_NAME => 'SSP_TrackDeletion__c',
                                SSP_GlobalConstants.SSP_OPERATOR => SSP_GlobalConstants.OPERATOR_AND,
                                'IN' => 'SSP_Member__c,Source__c'
                                },
                        new Set<String>{ 'Id', 'DCId__c', 'Source__c', 'SSP_Member__c' },
                        new Map<String, String>{
                            SSP_GlobalConstants.KEY_LIMIT => '100',
                                'SSP_Member__c' => String.join(
                                    new List<String>(cominedMemberIdSet),
                                    ','
                                ),
                                'SSP_Application__c' => applicationId,
                                'Source__c' => SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID +
                                ',' +
                                SSP_GlobalConstants.CIS_SCREENID
                                }
                    )
                ) {
                    if (
                        tdel.Source__c.equals(
                            SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID
                        ) &&
                        screenToMemberMap.get(
                            SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID
                        )
                        .containsKey(tDel.SSP_Member__c)
                    ) {
                        screenToMemberMap.get(
                            SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID
                        )
                            .remove(tDel.SSP_Member__c);
                    } else if (
                        tdel.Source__c.equals(SSP_GlobalConstants.CIS_SCREENID) &&
                        screenToMemberMap.get(SSP_GlobalConstants.CIS_SCREENID)
                        .containsKey(tDel.SSP_Member__c)
                    ) {
                        screenToMemberMap.get(SSP_GlobalConstants.CIS_SCREENID)
                            .remove(tDel.SSP_Member__c);
                    } else if (
                        (tdel.Source__c.equals(
                            SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID
                        ) &&
                         memberIdMap_yes.get(SSP_GlobalConstants.CARETAKER_SERVICES_SCREENID)
                         .contains(tDel.SSP_Member__c)) ||
                        (tdel.Source__c.equals(SSP_GlobalConstants.CIS_SCREENID) &&
                         memberIdMap_yes.get(SSP_GlobalConstants.CIS_SCREENID)
                         .contains(tDel.SSP_Member__c))
                    ) {
                        SSP_TrackDeletion__c tmpTrackDeletion = new SSP_TrackDeletion__c(
                            Id = tdel.Id
                        );
                        trackDeletionsToBeDeleted.add(tmpTrackDeletion);
                    }
                }
                
                for (String screenId : screenToMemberMap.keySet()) {
                    Map<String, Integer> memMap = screenToMemberMap.get(screenId);
                    if (memMap != null && !memMap.isEmpty()) {
                        //create track deletion
                        for (String memId : memMap.keySet()) {
                            SSP_TrackDeletion__c trackDelRec = new SSP_TrackDeletion__c();
                            trackDelRec.Source__c = screenId;
                            trackDelRec.SSP_Application__c = applicationId;
                            trackDelRec.SSP_Member__c = memId;
                            trackDelRec.SFObject__c = 'SSP_ApplicationIndividual__c';
                            listTrackDeletion.add(trackDelRec);
                        }
                    }
                }
                
                if (
                    trackDeletionsToBeDeleted != null &&
                    !trackDeletionsToBeDeleted.isEmpty()
                ) {
                    //delete trackDeletionsToBeDeleted;
                    ESAPI.accessController().deleteAsUser(trackDeletionsToBeDeleted);
                }
                
                if (listTrackDeletion != null && !listTrackDeletion.isEmpty()) {
                    //insert listTrackDeletion;
                    ESAPI.accessController().insertAsUser(listTrackDeletion, SSP_Utility.getFieldsNamesList (listTrackDeletion));
                }
            }
            toSend.put('listTrackDeletion', JSON.serialize(listTrackDeletion));
            toSend.put(
                'listTrackDeletionDelete',
                JSON.serialize(trackDeletionsToBeDeleted)
            );
        } catch (Exception ex) {
            toSend.put('bIsSuccess', false);
            toSend.put('error', ex.getMessage());
            //List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_PregnancyScreenController', 'createTrackDeletion', ex.getMessage() , true);
        }
        return toSend;
    }
    public static wrapperFlowMaps getFlowPageMap (List<String> lstFlowNames){
        wrapperFlowMaps wrapObj = new wrapperFlowMaps();
        Map<String,Set<String>> flowPageMap = new Map<String,Set<String>>();     
        Map<String, Integer> flowPageIntMap = new Map<String,Integer>();
        List<NavFlowPageConfig__mdt> lstNavFlowObj = [SELECT Id, ListenerPageNames__c, NavigationFlowDetail__r.FlowName__c, NavFlowRule__c, NavFlowRule__r.RuleName__c, PageInfo__c, toLabel(Page_Config_Display_Name_View__c),Programs__c,
                                                      PageInfo__r.PageName__c, toLabel(PageInfo__r.Page_Display_Name_View__c), PageInfo__r.URL__c, PageInfo__r.LightningComponentName__c, SectionGroupName__c, SequenceNumber__c,
                                                      NavFlowRule__r.RuleApexClassName__c 
                                                      FROM NavFlowPageConfig__mdt
                                                      WHERE IsActive__c = TRUE                                  
                                                      AND NavigationFlowDetail__r.FlowName__c IN :lstFlowNames
                                                      order by SequenceNumber__c];  
        for(NavFlowPageConfig__mdt flowPgConfig : lstNavFlowObj){
            flowPageIntMap.put(flowPgConfig.PageInfo__r.PageName__c,(Integer)flowPgConfig.SequenceNumber__c - 1);
            if(flowPageMap.containsKey(flowPgConfig.NavigationFlowDetail__r.FlowName__c)){
                flowPageMap.get(flowPgConfig.NavigationFlowDetail__r.FlowName__c).add(flowPgConfig.PageInfo__r.PageName__c);                
            }
            else{
                flowPageMap.put(flowPgConfig.NavigationFlowDetail__r.FlowName__c,new Set<String> {flowPgConfig.PageInfo__r.PageName__c});                
            }
        }
        wrapObj.flowPageMap = flowPageMap;
        wrapObj.flowPageIntegerMap = flowPageIntMap;
        return wrapObj;
    }
    
    public class wrapperFlowMaps{
        Map<String,Set<String>> flowPageMap;
        Map<String,Integer> flowPageIntegerMap;
    }
    
    public static void createNavFlowStatuses (List<SSP_HealthInformationWrapper> lstHealthInfoWrapper, String appId, Map<String, Boolean> questionMap){
        //Map<String,Set<String>> disabilityMap = new Map<String,Set<String>>();
        String Disability = SSP_GlobalConstants.DISABILITY_SCREEN;
        String blindness = SSP_GlobalConstants.BLINDNESS_SCREEN;
        String healthCondition = SSP_GlobalConstants.EMC_SCREEN;
        String cisScreen = SSP_GlobalConstants.CIS_SCREEN;
        String cisCareTaker = SSP_GlobalConstants.CIS_CARETAKER;
        Set<String> disabilityMemberId = new Set<String>();
        Set<String> BlindMemberId = new Set<String>();
        Set<String> HealthMemberId = new Set<String>();
        Set<String> cisMemberId = new Set<String>();
        Set<String> careTakerMemberId = new Set<String>();
        String flowName = SSP_GlobalConstants.FLOWNAME_HEALTH;
        Set<String> memberIdSet = new Set<String>();    
        for(SSP_HealthInformationWrapper healthObj : lstHealthInfoWrapper){            
            memberIdSet.add(healthObj.sMemberId);
            if(healthObj.sIsDisabled != null && healthObj.sIsDisabled == SSP_GlobalConstants.YES){
                disabilityMemberId.add(healthObj.sMemberId);                                
            }
            if(healthObj.sIsBlind != null && healthObj.sIsBlind == SSP_GlobalConstants.YES){
                BlindMemberId.add(healthObj.sMemberId);                                
            }
            if((healthObj.sIsRecoveryFromIllnessOrInjury != null || healthObj.sHasEmergencyMedicalCondition != null) && (healthObj.sIsRecoveryFromIllnessOrInjury == SSP_GlobalConstants.YES || healthObj.sHasEmergencyMedicalCondition == SSP_GlobalConstants.YES)){
                HealthMemberId.add(healthObj.sMemberId);                                
            }
            if(healthObj.sIsRequestingOrReceivingCIS != null && healthObj.sIsRequestingOrReceivingCIS == SSP_GlobalConstants.YES){
                cisMemberId.add(healthObj.sMemberId);
            }
            if(healthObj.sIsReceivingCaretakerServices != null && healthObj.sIsReceivingCaretakerServices == SSP_GlobalConstants.YES){
                careTakerMemberId.add(healthObj.sMemberId);
            }        
        }    
        Map<String,NavFlowStatus__c> memberFlowStatusMap = new Map<String,NavFlowStatus__c>();
        //String contactId = [SELECT Id, ContactId from User where Id = :UserInfo.getUserId()].ContactId;
        //Start - Added the FR fixes
        List<User> userList = SSP_UserSelector.queryUserData (
            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
            new Set<String>{'Id','ContactId'},
            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()});
        String contactId = userList[0].ContactId;
        //End - Added the FR fixes
        wrapperFlowMaps wrapperObj = getFlowPageMap(new List<String> {flowName});
        List<String> FlowNameList = new List<String> {flowName};
            List<NavFlowStatus__c> lstFlowStatus = new List<NavFlowStatus__c>();
        List<NavFlowStatus__c> lstExistingFlowStatus = [SELECT Id, FlowPageStatus__c, Screen_Status__c, FlowDupStatus__c, NavFlowName__c, Member__c FROM NavFlowStatus__c
                                                        WHERE SSPApplication__c =:appId and NavFlowName__c IN : FlowNameList];    
        Map<String,NavFlowSTatus__c> mapMemberStatusMap = new Map<String,NavFlowStatus__c>();
        Map<String,NavFlowStatus__c> reviewRequiredMap = new Map<String, NavFlowStatus__c>();
        Boolean reviewRequired = false;
        for(NavFlowStatus__c nav : lstExistingFlowStatus){
            if(nav.Screen_Status__c != null){
                Map<String,Object> screenStatusMap = (Map<String,Object>)JSON.deserializeUntyped(nav.Screen_Status__c); 
                for(String screenObj : screenStatusMap.keySet()){
                    SSP_RulesEngine.ScreenStatus objReview = (SSP_RulesEngine.ScreenStatus)JSON.deserialize(JSON.serialize(screenStatusMap.get(screenObj)),SSP_RulesEngine.ScreenStatus.CLASS);
                    if(objReview.isReviewRequired){
                        reviewRequiredMap.put(nav.Member__c+';'+nav.NavFlowName__c,nav);
                    } 
                }
            }
            mapMemberStatusMap.put(nav.Member__c+';'+nav.NavFlowName__c,nav);
        }    
        for(String member : memberIdSet){            
            SSP_ReviewRequiredRuleService.contactId = contactId;
            NavFlowStatus__c flowStatus;
            if(mapMemberStatusMap.containsKey(member+';'+flowName)){
                flowStatus = mapMemberStatusMap.get(member+';'+flowName);
            }
            else{
                flowStatus = SSP_ReviewRequiredRuleService.initNavFlowReviewRequiredStatus(appId,member,flowName,wrapperObj.flowPageMap);               
            }            	
            String[] flowStatusArray = flowStatus.FlowPageStatus__c.split('');
            String[] flowDupStatusArray = flowStatus.FlowDupStatus__c.split('');        
            Integer idx;                   
            for(Integer i=0; i < flowStatusArray.size(); i++){     
                if(questionMap != null && questionMap.containsKey('showMedicalQuestions') && questionMap.get('showMedicalQuestions')){
                    idx = wrapperObj.flowPageIntegerMap.get(Disability);
                    if(disabilityMemberId.contains(member)){                 	                    
                        if(!flowDupStatusArray[idx].contains(SSP_GlobalConstants.FLOWSTATUS_C)){                    
                            flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                     
                            flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                                               
                        }
                    }  
                    else{                    
                        flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;      
                        flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N; 
                    }
                    idx = wrapperObj.flowPageIntegerMap.get(blindness); 
                    if(BlindMemberId.contains(member)){                 	
                        
                        if(!flowDupStatusArray[idx].contains(SSP_GlobalConstants.FLOWSTATUS_C)){
                            
                            flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;  
                            flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R; 
                        }
                    }  
                    else{
                        flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;                    
                        flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N; 
                    }
                    idx = wrapperObj.flowPageIntegerMap.get(healthCondition);
                    if(HealthMemberId.contains(member)){                 	                                       
                        if(!flowDupStatusArray[idx].contains(SSP_GlobalConstants.FLOWSTATUS_C)){                    
                            flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                             
                            flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R; 
                        }
                    } 
                    else{
                        flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;                   
                        flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;
                    }
                }
                if(questionMap != null && questionMap.containsKey('showCommunityQuestions') && questionMap.get('showCommunityQuestions')){
                    idx = wrapperObj.flowPageIntegerMap.get(cisScreen);
                    if(cisMemberId.contains(member)){                 	                    
                        if(!flowDupStatusArray[idx].contains(SSP_GlobalConstants.FLOWSTATUS_C)){                    
                            flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                     
                            flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                                               
                        }
                    }  
                    else{                    
                        flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;      
                        flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N; 
                    }
                    
                    idx = wrapperObj.flowPageIntegerMap.get(cisCareTaker);
                    if(careTakerMemberId.contains(member)){                 	                    
                        if(!flowDupStatusArray[idx].contains(SSP_GlobalConstants.FLOWSTATUS_C)){                    
                            flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                     
                            flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_R;                                               
                        }
                    }  
                    else{                    
                        flowStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N;      
                        flowDupStatusArray[idx] = SSP_GlobalConstants.FLOWSTATUS_N; 
                    }
                }
            }
            String flowUpdatedStatus = String.join(flowStatusArray,'');
            String flowUpdatedDupStatus = String.join(flowDupStatusArray,'');        
            flowStatus.FlowPageStatus__c = flowUpdatedStatus;
            flowStatus.FlowDupStatus__c = flowUpdatedDupStatus;
            /*if(flowStatus.FlowDupStatus__c != null && !(flowStatus.FlowDupStatus__c).split('').contains('C')){
flowStatus.FlowDupStatus__c = flowUpdatedStatus;
} */                
            if((flowStatus.FlowPageStatus__c.contains(SSP_GlobalConstants.FLOWSTATUS_R) || flowStatus.FlowPageStatus__c.contains(SSP_GlobalConstants.FLOWSTATUS_C))&& flowStatus.Id == null) {
                memberFlowStatusMap.put(member,flowStatus);   
            }        
            else if(flowStatus.Id != null){
                memberFlowStatusMap.put(member,flowStatus);   
            }            
        }            
        for(String member : memberFlowStatusMap.keyset()){
            NavFlowStatus__c flowStatus = memberFlowStatusMap.get(member);
            if(reviewRequiredMap.containsKey(member+';'+flowName)){
                flowStatus = reviewRequiredMap.get(member+';'+flowName);
            }
            lstFlowStatus.add(flowStatus);
        }
        if(!lstFlowStatus.isEmpty()){
            upsert lstFlowStatus;   
        }        
    }
}