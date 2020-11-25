
	/***************************************************************************************************************************
*   Type         :   Service Class
*   Name         :   SSP_HouseHoldSummaryService
*   Created By   :   Suyash Singhal
*   Created Date :   11/13/2019
*   Description  : 
*  
*   Modification Log
*   --------------------------------------------------------------------------------------
*   * Developer                   Date          Description
*   * ------------------------------------------------------------------------------------                 
*     Suyash                    11/13/2019        Initial Version
*****************************************************************************************************************************/

public without sharing class SSP_HouseHoldSummaryService {
    
    public static Boolean MCIcalloutstatuscheck=false;
    public static Boolean programRemoved=false;
    
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   getHouseholdDetails
* @description  This method gets all the Household details as an init method
* @param        sApplicationId
* @return       SSP_LightningResponse
********************************************************************************************/
    
    public static map<String,Object>  getHouseholdDetail(List<String> lstApplicationId , Boolean sMode) {

        Map<String,String> mapForASNatinality = new MAP<String,String>();
        Map<String,String> mapForHIPNatinality = new MAP<String,String>();
        Map<String,Object> objResponse = new Map<String,Object>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        map<String,SSP_ApplicationIndividual__c> mapMemberVsAppIndiv = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper> lstWrapper = new List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper>();
        List<SSP_Application__c> lstApps = new List<SSP_Application__c>();           
        set<String> sUnassignedPrograms = new set<String>();
        Map<String,Object> mapResult = getHouseHoldMembers(lstApplicationId[0]);
        if(!(Boolean)mapResult.get('applicationComplete')){
            objResponse.put('bIsSuccess', true);  
            objResponse.put('applicationComplete', false);  
            return objResponse;
        }
        lstMembers = (List<SSP_Member__c>)mapResult.get('lstMembers');
        lstApps =  (List<SSP_Application__c>)mapResult.get('lstApps');        
        mapMemberVsAppIndiv = (map<String,SSP_ApplicationIndividual__c>)mapResult.get('mapMemberVsAppIndiv');
        sUnassignedPrograms = (set<String>)mapResult.get('sUnassignedPrograms');
        
        
        String sHOHId;
        for (SSP_Member__c objMember : lstMembers){
            if(null!=lstApps && lstApps.size()>0){
                SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrapper = buildWrapperObject(objMember,mapMemberVsAppIndiv.get(objMember.Id),lstApps, sMode);                        
                if (mapMemberVsAppIndiv.get(objMember.Id).IsHeadOfHousehold__c){
                    sHOHId = objMember.IndividualId__c; 
                    objWrapper.sHOHMCIId =sHOHId;
                    objResponse.put('headOfHousehold',JSON.serialize(objWrapper));
                } 
                lstWrapper.add(objWrapper);
            }
        }
        
        for ( SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objwrp  : lstWrapper){
            objwrp.sHOHMCIId = sHOHId;
        }
        
        Map<String,String> recordList=  SSP_Utility.getPickListValues('SSP_Member__C' , 'NationalityCode__c', null);
        for (String key : recordList.keySet())
            if(SSP_GlobalConstants.NATIONALITY_AS.contains(key)){                
                mapForASNatinality.put(key,recordList.get(key));
            }
        else mapForHIPNatinality.put(key,recordList.get(key));
        
        String sAPPPrograms = buildProgramsString(lstApps[0].ProgramsApplied__c);
        
        Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId()); //CD2 2.5	Security Role Matrix and Program Access.
        userDetails.put('appPrograms', lstApps[0].ProgramsApplied__c); //CD2 2.5	Security Role Matrix and Program Access.
        objResponse.put('bIsSuccess', true);  
        objResponse.put('unassignedprograms',JSON.serialize(sUnassignedPrograms));  
        objResponse.put('sAPPPrograms',sAPPPrograms); // KI-HIPP,SNAP;
        objResponse.put('sAPPProgramsCodes',lstApps[0].ProgramsApplied__c);  
        objResponse.put('Result',String.valueOf(JSON.serialize(lstWrapper)));
        objResponse.put('applicationComplete', true);
        objResponse.put('mapforasnatinality', mapForASNatinality); 
        objResponse.put('mapforhpinatinality', mapForHIPNatinality); 
        objResponse.put('userDetails', SSP_Utility.getUserDetails(UserInfo.getUserId()));//added by Shrikant - CD2             


        return objResponse;
    }
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   getHouseHoldMembers
* @description  This method gets all the Household Members 
* @param        sApplicationId
* @return       SSP_LightningResponse
********************************************************************************************/
    
    public static map<String,Object> getHouseHoldMembers(String sApplicationId) {
        map<String,Object> mapResult = new map<String,Object>(); 
        List<SSP_Application__c> lstApps = new List<SSP_Application__c>();
        set<String> setAllProgramsAssigned = new set<String>();
        map<String,SSP_ApplicationIndividual__c> mapMemberVsAppIndiv = new Map<String,SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>();
        set<Id> setMemberIds = new set<Id>();
        set<String> sUnassignedPrograms = new set<String>();
        List<SSP_ApplicationIndividual__c> applicationIndivs = new  List<SSP_ApplicationIndividual__c> ();
        map<String,string> mapProgramsPicklistValues = SSP_Utility.getPickListValues(SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0] , 'ProgramsApplied__c',null);
        
        if (String.isNotBlank(sApplicationId)){
            
            lstApps =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{SSP_GlobalConstants.OBJECT_NAME => SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0]}, 
                                                                    SSP_GlobalConstants.SSP_APPLICATION_FIELDS_HH_SUMMARY, 
                                                                    new Map<String, String>{SSP_GlobalConstants.SSP_APPLICATION_WHERE_CONDITIONS_FIELDS[0] => sApplicationId}); 
            
            List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{SSP_GlobalConstants.OBJECT_NAME => SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[1]}, 
                                                                                                                                    SSP_GlobalConstants.SSP_APPLICATION_INDIV_FIELDS_HH_SUMMARY, 
                                                                                                                                    new Map<String, String>{SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0]=> sApplicationId});
            
            
            if (!lstAppIndividuals.isEmpty()){
                for (SSP_ApplicationIndividual__c objAppIndiv : lstAppIndividuals){                    
                    applicationIndivs.add(objAppIndiv);
                    setMemberIds.add(objAppIndiv.SSP_Member__c);
                    mapMemberVsAppIndiv.put(objAppIndiv.SSP_Member__c,objAppIndiv);
                    if (objAppIndiv.MemberProgramsApplied__c != null ){
                        setAllProgramsAssigned.addAll(objAppIndiv.MemberProgramsApplied__c.split(';'));
                    }                    
                }
            }
            else {
                mapResult.put('applicationComplete' , false);
                return mapResult;
            }
            
            // Logic to collect all unassigned programs which was selected from get started screen
            if(null!=lstApps && !lstApps.isEmpty()){
                if (lstApps[0].ProgramsApplied__c != null){    
                    for (String str : lstApps[0].ProgramsApplied__c.split(';')){
                        if (!setAllProgramsAssigned.contains(str)){
                            sUnassignedPrograms.add(mapProgramsPicklistValues.get(str));
                        }
                    }
                }
            }
        }
        
        lstMembers =  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, 
                                                         SSP_GlobalConstants.SSP_MEMBER_FIELDS_HH_SUMMARY, 
                                                         new Map<String, String>{'Id'=> String.join(new List<Id>(setMemberIds), ',')}); 
        
        
        
        mapResult.put('lstAppIndividuals',applicationIndivs);
        mapResult.put('lstMembers',lstMembers);
        mapResult.put('lstApps',lstApps);
        mapResult.put('mapMemberVsAppIndiv',mapMemberVsAppIndiv);
        mapResult.put('sUnassignedPrograms',sUnassignedPrograms);
        mapResult.put('applicationComplete' , true);
        
        
        return mapResult;
        
    }
    
    
   /********************************************************************************************
   * @author       Suyash Singhal
   * @date         11/13/2019
   * @methodname   buildWrapperObject
   * @description  This methodbuild the wrapperobj
   * @param        SSP_Member__c objMember, SSP_ApplicationIndividual__c objAppIndividual,List<SSP_Application__c> lstApps
   * @return       SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper
   ********************************************************************************************/

   public static SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper buildWrapperObject(SSP_Member__c objMember, SSP_ApplicationIndividual__c objAppIndividual,List<SSP_Application__c> lstApps , Boolean sMode){
       

       SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap = new SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper(); 
       try{
           map<String,string> mapProgramsPicklistValues = SSP_Utility.getPickListValues(SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0] , 'ProgramsApplied__c',null);
            objWrap.bisHOH = objAppIndividual.IsHeadOfHousehold__c; 
           objWrap.sName = objMember.Name;
           objWrap.sRecordId = objMember.Id;
           objWrap.sFirstName = objMember.FirstName__c;
           objWrap.sMiddleName =objMember.MiddleInitial__c;
           objWrap.sAliasFirstName =  objMember.Alias_First_Name__c;
           objWrap.sAliasLastName =  objMember.Alias_Last_Name__c;
           objWrap.sLastName = objMember.LastName__c;
           objWrap.dDOB = objMember.BirthDate__c;
           objWrap.sSSN = objMember.SSN__c;
           objWrap.sGender = objMember.GenderCode__c;
           objWrap.sDeathDateVerification= objMember.DeathDateVerificationCode__c;//CR Changes
           objWrap.sIdentityMethod = objMember.Identify_verification_method__c; //CD2 Identity verfication
           objWrap.referenceNumber = objMember.Reference_Number__c; //CD2 Identity verfication
           objWrap.nonCitizenVerificationFlag = objMember.Non_Citizen_Verification_Flag__c; //Added as part of Defect - 378463
           objWrap.matchType = objMember.MatchType__c;
           if(null==objMember.SSN__c && null==objMember.NoReasonSSNCode__c){
               objWrap.bSSNPresent  = null;
           }
           if(null!=objMember.SSN__c){
               objWrap.bSSNPresent = SSP_GlobalConstants.YES;    
           }
           if(null!=objMember.NoReasonSSNCode__c){
               objWrap.bSSNPresent =SSP_GlobalConstants.NO;
           }
           objWrap.bisUSCitizen = objMember.IsUSCitizenToggle__c;
           objWrap.bKentuckyResident = objMember.IsIntendToResideToggle__c;
           objWrap.bServedInUSMilitary = objMember.IsMilitaryMemberToggle__c;
           objWrap.sRace = objMember.RaceCode__c;
           objWrap.sSufficeCode  = objMember.SuffixCode__c;
           objWrap.bisHispanicLatino = objMember.IsHispanicLatinoSpanishToggle__c;
           objWrap.sEthnicityCode = objMember.EthnicityCode__c;
           objWrap.dDeathDate = objMember.DeathDate__c;
           objWrap.sNationalityCode = objMember.NationalityCode__c;
           objWrap.sNoReasonSSNCode = objMember.NoReasonSSNCode__c;
           objWrap.sSpecialNeedIndicator = objMember.SpecialNeedIndicatorToggle__c;
           objWrap.bSSNVerified = objMember.SSNVerified__c;
           objWrap.sIsFileCleared = objMember.IsFileCleared__c;
           objWrap.sAppIndividualId = objAppIndividual.id;
           objWrap.buttonAltText = system.label.SSP_ButtonAltText + ' ' +  objMember.FirstName__c +' '+ objMember.LastName__c;
           objWrap.isUSCitizenValidated = objMember.IsUSCitizenValidated__c;
           objWrap.isHOHDetailsCompleted= objAppIndividual.isHOHDetailsCompleted__c;
           objWrap.bIsRACMealsRuleTriggered = objAppIndividual.IsRACSNAPMealsRuleTriggered__c;
           objWrap.appSectionStatus= lstApps[0].SectionStatus__c;
           objWrap.sApplicationNumber = null!=lstApps[0].Name ? Integer.valueOf(lstApps[0].Name) : null;
           if(null!=objAppIndividual.IsActiveIEESCasePresent__c && objAppIndividual.IsActiveIEESCasePresent__c){
           objWrap.isFullMatch =  objAppIndividual.IsActiveIEESCasePresent__c; // this field is used to show if it is MCI data
           }
       	   objWrap.MemberStatus= objAppIndividual.MemberStatus__c;
           objWrap.bIsDODVerified = objMember.IsDateOfDeathValidated__c; 
           //MCI request params
           objWrap.sApplicationId = lstApps[0].id;
           objWrap.memberIndividualId= objMember.IndividualId__c;
            objWrap.sTaxFilerMemberCurrent = objMember.TaxFilerStatusCurrentYear__c;
            objWrap.sTaxFilerMemberNext = objMember.TaxFilerStatusNextYear__c;
           if(null != lstApps[0].DCCaseNumber__c){
                objWrap.sCaseNumber = String.valueOf(lstApps[0].DCCaseNumber__c);
           }
            if(null==objMember.FirstName__c || null==objMember.LastName__c || null==objMember.BirthDate__c || null== objMember.GenderCode__c ||objAppIndividual.isHOHDetailsCompleted__c==false ){
                objWrap.showEdit = false; 
           }
           else
               objWrap.showEdit = true;
           
           if (String.isNotBlank(objAppIndividual.MemberProgramsApplied__c)){
               objWrap.sProgramsRequested = buildProgramsString(String.valueOf(objAppIndividual.MemberProgramsApplied__c));
           }    
           if(null!=lstApps[0].ProgramsApplied__c){
           objWrap.sPrograms =  buildProgramsString(String.valueOf(lstApps[0].ProgramsApplied__c)); 
           }
           if(null!=objMember.Age__c){
               objWrap.sAge= Integer.valueOf(objMember.Age__c)<=0 ?SSP_GlobalConstants.DEFAULT_AGE: String.valueOf(objMember.Age__c);
           }
           else 
               objWrap.sAge=SSP_GlobalConstants.DEFAULT_AGE;
           
           if(null!=sMode && sMode==true){
               objWrap.showEdit = true;
           }

            objWrap.everyoneInHouseholdHaveSameAddress = objMember.SameAddressInfoAsHOHToggle__c == SSP_GlobalConstants.YES;
            objWrap.mailingAddressLine1 = objMember.MailingAddressLine1__c;
            objWrap.physicalAddressLine1 = objMember.PhysicalAddressLine1__c;
            objWrap.isTMember = objAppIndividual.IsTMember__c;
       } catch (Exception ex){           
          
           List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldSummaryService', 'buildWrapperObject', ex.getMessage() , true);
       }
      
       
       return objWrap;

   }
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   createMemberInstance
* @description  This method is used add records necessary when HOH adds new member

* @param        MemberDetailsWrapper objWrap ,SSP_Member__c objMember
* @return       none
********************************************************************************************/
    
    public static SSP_Member__c createMemberInstance(SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap, SSP_Member__c objMember){
        
        try{
            if (String.isNotBlank(objWrap.sMiddleName)){
                objMember.Name  =  objWrap.sFirstName + ' '+ objWrap.sMiddleName + ' '+ objWrap.sLastName;
            }else {
                objMember.Name  =  objWrap.sFirstName +' '+ objWrap.sLastName;
            }
            objMember.id = objWrap.sRecordId !=null ? objWrap.sRecordId : null;
            objMember.FirstName__c = objWrap.sFirstName;
            objMember.MiddleInitial__c = objWrap.sMiddleName==''||objWrap.sMiddleName==null? '':objWrap.sMiddleName;
            objMember.LastName__c = objWrap.sLastName ;
            objMember.BirthDate__c =  objWrap.dDOB;
            objMember.SSN__c = objWrap.sSSN ;
            objMember.Alias_First_Name__c =objWrap.sAliasFirstName;// CR Changes
            objMember.Alias_Last_Name__c =objWrap.sAliasLastName;// CR Changes
            objMember.GenderCode__c = objWrap.sGender ;
            objMember.HasSSN__c =  objWrap.sSSN  == null || objWrap.sSSN =='' ? false : true;
            objMember.IsUSCitizenToggle__c = objWrap.bisUSCitizen;
            objMember.IsIntendToResideToggle__c = objWrap.bKentuckyResident ;
            objMember.IsMilitaryMemberToggle__c = objWrap.bServedInUSMilitary;
            objMember.RaceCode__c =  objWrap.sRace;
            objMember.SuffixCode__c =  objWrap.sSufficeCode;
            objMember.IsHispanicLatinoSpanishToggle__c =  objWrap.bisHispanicLatino;
            objMember.EthnicityCode__c = objWrap.sEthnicityCode;
            objMember.DeathDate__c =  objWrap.dDeathDate;
            objMember.NationalityCode__c = objWrap.sNationalityCode;
            objMember.NoReasonSSNCode__c = objWrap.sNoReasonSSNCode;
            objMember.SpecialNeedIndicatorToggle__c = objWrap.sSpecialNeedIndicator;
            objMember.Identify_verification_method__c = objWrap.sIdentityMethod;//CD2 identity verification
            objMember.Reference_Number__c = objWrap.referenceNumber;//CD2 identity verification
            if(objWrap.nonCitizenVerificationFlag != null) {
				objMember.Non_Citizen_Verification_Flag__c = objWrap.nonCitizenVerificationFlag;
            }
            if(objWrap.matchType != null) {
				objMember.MatchType__c = objWrap.matchType;
            }
            
            
        }catch (Exception ex){           
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldSummaryService', 'createMemberInstance', ex.getMessage() , false);
        }
        
        
        
        return objMember;
        
    }
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   removeUnassignedProgramsOnAPP
* @description  This method removes all the Unassigned prog from the Application record of Household
* @param        sApplicationId
* @return       SSP_LightningResponse
********************************************************************************************/
    
    public static Map<String,Object> removeUnassignedProgramsOnAPP(List<String> lstAppIds,String sUnassignedProgramsJson){


        Map<String,Object> objResponse = new Map<String,Object>();

        try{
            map<String,string> mapProgramsPicklistValues = SSP_Utility.getPickListValues(SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0] , 'ProgramsApplied__c',null);
            String sFinalPrograms =SSP_GlobalConstants.DEFAULT_EMPTY_STRING; 
            if (!lstAppIds.isEmpty() && String.isNotBlank(sUnassignedProgramsJson)){
                String sApplicationId = lstAppIds[0];
                set<String> setUnassignedProgNames = (set<String>)System.JSON.deserialize(sUnassignedProgramsJson, set<String>.class);
                
                List<SSP_Application__c>  lstApps =  SSP_ApplicationSelector.queryApplicationData(new Map<String, String>{'objectName'=>'SSP_Application__c'}, 
                                                                                                  new Set<String>{'Id','ProgramsApplied__c','Account__c'}, 
                                                                                                  new Map<String, String>{'Id'=> sApplicationId});
                
                for (String str : lstApps[0].ProgramsApplied__c.split(';') ){
                    if (!setUnassignedProgNames.contains(mapProgramsPicklistValues.get(str))){
                        sFinalPrograms += str +';';
                    }
                    
                }
                sFinalPrograms = sFinalPrograms.removeEnd(';');
                lstApps[0].ProgramsApplied__c =  sFinalPrograms; 
                update lstApps[0];
                objResponse.put('bIsSuccess', true); 
            }
        }catch (Exception ex){           
            objResponse.put('bIsSuccess', false); 
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldSummaryService', 'removeUnassignedProgramsOnAPP', ex.getMessage() , true);
        }
        
        return objResponse;
    }
    
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   buildProgramsString
* @description  
* @param        sProgramApiValue
* @return       String
********************************************************************************************/ 
    
    public static String buildProgramsString(String sProgramApiValue){
        
        String sProgramNames =SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        
        if (String.isNotBlank(sProgramApiValue)){
            map<String,string> mapProgramsPicklistValues = SSP_Utility.getPickListValues(SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0] , 'ProgramsApplied__c',null);
            for (String str : sProgramApiValue.split(';')){
                if (mapProgramsPicklistValues.get(str) !=null){
                    if(!sProgramNames.contains(mapProgramsPicklistValues.get(str)))
                        sProgramNames += mapProgramsPicklistValues.get(str) + ';'; 
                }
            }
            
            sProgramNames = sProgramNames.removeEnd(';');
        }
        return sProgramNames;
    }
    
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   buildProgramsAPIValueString
* @description  
* @param        sProgramApiValue
* @return       String
********************************************************************************************/
    public static String buildProgramsAPIValueString(String sProgramApiValue){
        
        string sProgramNames =SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        
        if (String.isNotBlank(sProgramApiValue)){
            List<String> lstProgramsRequested = sProgramApiValue.split(';');
            map<String,string> mapProgramsPicklistValues = SSP_Utility.getPickListValues(SSP_GlobalConstants.HH_SUMM_OBJECTS_APINAMES[0] , 'ProgramsApplied__c',null);
            for (String str : mapProgramsPicklistValues.keyset()){
                if (mapProgramsPicklistValues.get(str) !=null && lstProgramsRequested.contains(mapProgramsPicklistValues.get(str))){
                    sProgramNames += str + ';'; 
                }
            }
            
            sProgramNames = sProgramNames.removeEnd(';');
        }
        return sProgramNames;
    }
    
    
    /********************************************************************************************
* @author       Suyash Singhal
* @date         11/13/2019
* @methodname   saveDataService
* @description  This method upsert member data 
* @param        SSP_Member__c objMember
* @return       SSP_LightningResponse
********************************************************************************************/
    public static Map<String,Object> saveDataService(String sJSON, Boolean bSSNRetryFlag, Boolean sMode){
        
        Map<String,Object> objResponse = new Map<String,Object>();       
        Boolean bIsDuplicate = false,callMCIService = true ,updateCountForMCI = false , callSSNVerification= false;
        List<object> slist = new List<object>();
        List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper> lstWrapperMembers = new List<SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper>();
        List<SSP_Member__c> lstMembers = new List<SSP_Member__c>(); 
        Map<String,Object> mapResult = new Map<String,Object>();
        List<LOG_LogMessage__c> lstLogMessag = new List<LOG_LogMessage__c>();
        SSP_Member__c objMember = new SSP_Member__c();
        SSP_MCIMergedServiceResponeWrapper resp = new SSP_MCIMergedServiceResponeWrapper();
        Map<Id,SSP_Member__c> mapSSPMember = new Map<Id,SSP_Member__c>();
        Map<Id,SSP_ApplicationIndividual__c> mapMemberVsIndiv = new Map<Id,SSP_ApplicationIndividual__c>();
        Map<String,Object> mapHouseholdData = new Map<String,Object>();
        List<SSP_Member__c> lstExistingMembers = new List<SSP_Member__c> ();
        List<ssp_applicationIndividual__c> applicationIndiv = new List<ssp_applicationIndividual__c>();
        List<SSP_Application__c> lstApps = new List<SSP_Application__c> ();
        List<SSP_ApplicationIndividual__c>  lstAppIndividuals = new  List<SSP_ApplicationIndividual__c> ();
        String mergeCaseNumber=SSP_GlobalConstants.DEFAULT_EMPTY_STRING, blockedMembers=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        Boolean applicationBlocked = false;
        String applicationRecordId = Schema.getGlobalDescribe().get('SSP_Application__c').getDescribe().getRecordTypeInfosByName().get('Case').getRecordTypeId();
        SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap = new SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper();
        try { 
            system.debug('------------------------1-------------------');
            //get the data entered from the user and store in the wrapper 
            if(sJSON!=null){
                objWrap = (SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper)System.JSON.deserialize(sJSON, SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper.class);
            }
            if(objWrap!=null){   
                mapHouseholdData = getHouseHoldMembers(objWrap.sApplicationId);     //get existing member and application data       
                lstExistingMembers = (List<SSP_Member__c>)mapHouseholdData.get('lstMembers');
                lstApps = (List<SSP_Application__c>)mapHouseholdData.get('lstApps');  
                lstAppIndividuals = (List<SSP_ApplicationIndividual__c>)mapHouseholdData.get('lstAppIndividuals');
                
                if(null!=lstAppIndividuals && lstAppIndividuals.size()>0 ){
                    for(SSP_ApplicationIndividual__c appIndvs:lstAppIndividuals)
                        mapMemberVsIndiv.put(appIndvs.SSP_Member__c,appIndvs); 
                }
                
                if(null!=lstExistingMembers && lstExistingMembers.size()>0 ){
                    for(SSP_Member__c sspMember:lstExistingMembers)
                        mapSSPMember.put(sspMember.id, sspMember);
                }
                
            }
            system.debug('------------------------2-------------------');
            
            // Check if Duplicate Member is getting added - Logic Starts  (New Member will have objWrap.sRecordId = null).
            // First Name , Last Name, Gender and DOB mendatory for New Member added from the screen : So no Null check needed - Will be checked on UI
            if (objWrap != null && String.isBlank(objWrap.sRecordId)){                  
                String sNewMemberUniqueKey = objWrap.sFirstName.trim() + objWrap.sLastName.trim()+ objWrap.sGender.trim()+ objWrap.dDOB;               
                for (SSP_Member__c objDupMemCheck : lstExistingMembers){
                    String sUniqueKey;
                    if(null!=objDupMemCheck.Firstname__c && null!=objDupMemCheck.LastName__c && null!=objDupMemCheck.GenderCode__c && null!=objDupMemCheck.BirthDate__C){
                        sUniqueKey = objDupMemCheck.Firstname__c.trim() + objDupMemCheck.LastName__c.trim() + objDupMemCheck.GenderCode__c.trim()+ objDupMemCheck.BirthDate__C ; 
                    }
                    if (sNewMemberUniqueKey.equalsIgnoreCase(sUniqueKey)){
                        bIsDuplicate = true;  
                    }
                    
                }
                objWrap.mciCallCount = 0;
            }
            system.debug('------------------------3-------------------');
            Boolean isChangedDemographicalInfo = true;
            list<String> hohProgramsRequested= new List<String>();
            Map<String,list<String>> mapIndividualVsProgram= new  Map<String,list<String>>();
            Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());
            Boolean isNonCitizenUser = userDetails.get('profileName').equals(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && String.isNotBlank(userDetails.get('userRole')) && !userDetails.get('userRole').equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE);
            list<String> finalProgramList=new list<String>();               
            Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
            Boolean mciCallDocUPload=sessionPart.get('MCICallDocUPload')!=null?true:false;        
            Boolean mciCallRIDP=sessionPart.get('MCICallRIDP')!=null?true:false; 
            if (objWrap != null && !bIsDuplicate ){
                objMember = createMemberInstance(objWrap, objMember); // Create ssp_member record from the ObjWrap
                SSP_Member__c sspMember = new SSP_Member__c ();
                if(null!=objMember.Id && null!=mapSSPMember.get(objMember.Id)){ // If existing member then check if we need to call MCI or not: MCI will be called only when there is any demographical changes : First Name , Last Name , DOB , Gender and SSN  
                    sspMember= mapSSPMember.get(objMember.Id);
                    SSP_ApplicationIndividual__c appIndiv = new ssp_applicationIndividual__c();  
                    //check if the applicationIndividual is present for the member && MCIcount__c on appIndv is not null
                    if(null!=mapMemberVsIndiv.get(objMember.Id) && null!=mapMemberVsIndiv.get(objMember.Id).MCIcount__c)
                    {
                        objWrap.mciCallCount =Integer.valueOf(mapMemberVsIndiv.get(objMember.Id).MCIcount__c);
                        appIndiv =mapMemberVsIndiv.get(objMember.Id); //get corresponding appIndv
                        
                        // New Change : check if BlockedCaseNumber  and/or Application blocked is already populated for the individual 
                        if(null!=appIndiv && null!=appIndiv.BlockedCaseNumber__c){
                            mergeCaseNumber=appIndiv.BlockedCaseNumber__c;
                        }
                        if(null!=appIndiv && null!=appIndiv.isApplicationBlocked__c && appIndiv.isApplicationBlocked__c){
                            applicationBlocked=true;
                            blockedMembers= objMember.FirstName__c +' '+ objMember.LastName__c;
                        }
                    }
                    String currentDataForMember= SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
                    if(null!=sspMember.Firstname__c && null!=sspMember.LastName__c && null!=sspMember.GenderCode__c && null!=sspMember.BirthDate__C){
                        currentDataForMember = sspMember.Firstname__c+sspMember.LastName__c+sspMember.GenderCode__c+sspMember.BirthDate__C ;                    
                    }
                    String dataInputByUser =  objWrap.sFirstName+objWrap.sLastName+ objWrap.sGender + objWrap.dDOB;

                    //Compare the data entered by user (updated data) with one already present on member record, if there is no change, flip  callMCIService to false so that no MCI call is made
                    if(sspMember.IsFileCleared__c){// defect 368781 - Added by Sanchita - As discussed with Srinath, this field will always be false for first time user
                        callMCIService=false;
                        if(!sspMember.SSNVerified__c && objWrap.sSSN!=null ){
                            callSSNVerification= true;
                        }
                    }
                    else if(currentDataForMember==dataInputByUser && sspMember.SSNVerified__c){
                           callMCIService=false;
                    }

                    if(currentDataForMember==dataInputByUser){
                        isChangedDemographicalInfo = false;
                    }
                    // delete navflow when changed deceased to living to trigger review required.
                    if(null!=sspMember.DeathDate__c && objWrap.dDeathDate==null && null!=lstApps[0].id){
                        List<Object> navFlowResult= deleteNavFlowRecordForMember(sspMember.id,lstApps[0].id);
                        if(null!=navFlowResult){
                            lstLogMessag.add((LOG_LogMessage__c)navFlowResult[0]);
                        }
                    }
                }
                system.debug('------------------------4-------------------');
                SSP_MCIMergedServiceRequestWrapper objRequestWrapper = createServiceCallWrapper(objWrap, lstApps,sMode,bSSNRetryFlag);
                objRequestWrapper.isMemberFileCleared = sspMember.IsFileCleared__c;
                if(null==objRequestWrapper){
                    objResponse.put('bIsSuccess', false); 
                    objResponse.put('error', SSP_GlobalConstants.DATA_PARSE_ERROR);  
                    return objResponse;
                }
                
                Map<String,object> obj = new Map<string,object>();
                obj.put('jsonbody',JSON.serialize(objRequestWrapper));
                /*if(callMCIService)
                {
                    callMCIService=  (objWrap.bisHOH != null && objWrap.bisHOH) ? checkMCIApplicable(objWrap.sRecordId) : true; //#377690
                }*/
                if(String.isNotBlank(objRequestWrapper.program)){
                    hohProgramsRequested=objRequestWrapper.program.split(';');
                }
                
                /*if(callMCIService  || callSSNVerification ){
                    slist = IntegrationFactory.invokeCallout(SSP_GlobalConstants.MCI_SERVICE,obj); 
                    if(null!=slist && slist.size()>0 ){
                       resp = (SSP_MCIMergedServiceResponeWrapper) slist[0]; 
                    }                   
                    if(isNonCitizenUser && (userDetails.get('userRole').contains('Mail')||mciCallDocUPload|| mciCallRIDP) && String.isBlank(userDetails.get('impersonatedIndividualId')) && objWrap.bisHOH){
                       mapIndividualVsProgram =SSP_NonCitizenRAC.triggerBenefitsServiceCall(resp.IndividualId, objWrap.sRecordId);
                    }
                    
                    if(slist==null || slist.isEmpty()){
                        objResponse.put('bIsSuccess', false); 
                        objResponse.put('error', SSP_GlobalConstants.NO_RECORD_FROM_MCI);  
                        return objResponse;
                    }

                    // Code for Defect#- 398172 - below block is executed in case MCI call happens- so we read data from response.
                    Boolean waiverRole=false;
                    if(SSP_GlobalConstants.waiverRoles.contains(SSP_Utility.getSelectedRole())){
                        waiverRole=true;
                    }

                    if(waiverRole && ((resp.isApplicationBlocked!=null && resp.isApplicationBlocked) || resp.MatchStatus == SSP_GlobalConstants.FULL_MATCH ) && null!=lstApps && lstApps.size()>0 ){
                        String applicationId = objWrap.sApplicationId;
                        Contact memberContact= new Contact();
                        String indvId = '';
                        SSP_ApplicationIndividual__c hohIndividual;

                        mapResult.put('bIsSuccess', false);
                        mapResult.put('error', SSP_GlobalConstants.Cannot_Apply);  
                        mapResult.put('BlockedMember',blockedMembers);
                        mapResult.put('CaseNumber', null== objWrap.sCaseNumber?lstApps[0].name: objWrap.sCaseNumber); //blocked case number
                        lstApps[0].Status__c=SSP_GlobalConstants.STATUS_INACTIVE;
                        upsert lstApps[0] ;

                        if( resp.IndividualId != null){
                            indvId = resp.IndividualId;
                        }
                    
                        memberContact.FirstName=objMember.FirstName__c;
                        memberContact.LastName=objMember.LastName__c;
                        memberContact.MiddleName=objMember.MiddleInitial__c;     
                        memberContact.IndividualId__c=indvId;
                        mapResult.put('selectedRole', SSP_Utility.getSelectedRole());
                        mapResult.put('isFullMatch', true);
                        mapResult.put('memberContact',JSON.serialize(memberContact));
                        mapResult.put('waiverRole',waiverRole);
                        mapResult.put('individualId', indvId);
                        return mapResult;
                    }
                }                
                else*/ if(!callMCIService){  // We will call MCI only when there is any change in demographical information or not isFileCleared
                    system.debug('-----------inside if(!callMCIService)-------');
                    if(sspMember.IsFileCleared__c && isChangedDemographicalInfo){
                        objMember.IsMCICreateUpdateRequired__c = SSP_GlobalConstants.YES;
                    }
                    mapResult = handleNoMatchScenario(null,objMember,objWrap,mapHouseholdData,sMode);
                    if(mergeCaseNumber!='' && !applicationBlocked && null!= lstApps && lstApps[0].RecordTypeId!=applicationRecordId) // match found modal should open 
                    {
                        mapResult.put('MergeCaseNumber', mergeCaseNumber);
                        mapResult.put('CaseNumber', null== objWrap.sCaseNumber?lstApps[0].name: objWrap.sCaseNumber);
                    }
                    /// Code for Defect#- 398172 - below block is executed when MCI doesnt happen- so we read data from existing records.
                    Boolean waiverRole=false;
                    if(SSP_GlobalConstants.waiverRoles.contains(SSP_Utility.getSelectedRole())){
                        waiverRole=true;
                    }
                    if((applicationBlocked  && null!=lstApps && lstApps.size()>0) || (waiverRole && resp.MatchStatus == SSP_GlobalConstants.FULL_MATCH)){ // open application block
                        mapResult.put('bIsSuccess', false);
                        mapResult.put('error', SSP_GlobalConstants.Cannot_Apply);  
                        mapResult.put('BlockedMember',blockedMembers);
                        mapResult.put('CaseNumber', null== objWrap.sCaseNumber?lstApps[0].name: objWrap.sCaseNumber); //blocked case number
                        lstApps[0].Status__c=SSP_GlobalConstants.STATUS_INACTIVE;
                        upsert lstApps[0] ;

                        if(waiverRole){
                            String applicationId = objWrap.sApplicationId;
                            Contact memberContact= new Contact();
                            String indvId = '';
                            SSP_ApplicationIndividual__c hohIndividual;

                            if(null!=lstAppIndividuals && lstAppIndividuals.size()>0 ){
                                for(SSP_ApplicationIndividual__c appInd : lstAppIndividuals){
                                    if(appInd.IsHeadOfHousehold__c){
                                        hohIndividual = appInd;
                                    }
                                }
                            }

                            if( hohIndividual != null){
                                indvId = hohIndividual.SSP_Member__r.IndividualId__c;
                            }
                        
                            memberContact.FirstName=objMember.FirstName__c;
                            memberContact.LastName=objMember.LastName__c;
                            memberContact.MiddleName=objMember.MiddleInitial__c;     
                            memberContact.IndividualId__c=indvId;

                            mapResult.put('selectedRole', SSP_Utility.getSelectedRole());
                            mapResult.put('isFullMatch', true);
                            mapResult.put('memberContact',JSON.serialize(memberContact));
                            mapResult.put('waiverRole',waiverRole);
                            mapResult.put('individualId', indvId);
                        }
                    }
                    return mapResult;
                }                          
                system.debug('------------------------5-------------------');
                if(null!=slist && slist.size()>0 ){
                    resp = (SSP_MCIMergedServiceResponeWrapper) slist[0]; 
                }
                
                if(null!=resp){
                     if (( null!=resp.isApplicationBlocked && !resp.isApplicationBlocked && (String.isBlank(resp.ErrorCode))) || (resp.ErrorCode == SSP_GlobalConstants.ERROR_CODE_SSN_VALIDATION && ((objWrap.mciCallCount==0 && !bSSNRetryFlag)||objWrap.mciCallCount>0 )) || (resp.isMemberFileCleared!=null && resp.isMemberFileCleared && resp.ErrorCode == SSP_GlobalConstants.ERROR_CODE_SSN_VALIDATION && ((objWrap.mciCallCount==0 && !bSSNRetryFlag)||objWrap.mciCallCount>0 )  )){
                      // 375521 manually take fields as other fields will be blank in this scenario
                      if(null!=resp.isMemberFileCleared && resp.isMemberFileCleared && objMember!=null && objMember.Id!=null && null!=resp.lstOfSSPMembers && resp.lstOfSSPMembers.size()==1 ){
                        objMember.SSN__c = resp.lstOfSSPMembers[0].SSN__c;
                        objMember.SSNVerified__c =  resp.lstOfSSPMembers[0].SSNVerified__c;
                        objMember.SSNVerificationCode__c = resp.lstOfSSPMembers[0].SSNVerificationCode__c;
                        mapResult = handleNoMatchScenario(null,objMember,objWrap,mapHouseholdData,sMode);
                        objResponse = mapResult;
                         
                    }
                   else  if (resp.MatchStatus == SSP_GlobalConstants.FULL_MATCH && null!=resp.lstOfSSPMembers)
                        { 
                            //Start - check for exiting program and selected program for full match in MCI Call
                            if(isNonCitizenUser && (userDetails.get('userRole').contains('Mail')||mciCallDocUPload|| mciCallRIDP) && String.isBlank(userDetails.get('impersonatedIndividualId')) && objWrap.bisHOH && mapIndividualVsProgram!=null){
                                finalProgramList=getRequriedProgramHoh(hohProgramsRequested, mapIndividualVsProgram.get(resp.IndividualId));
                                if(!finalProgramList.isEmpty() && finalProgramList!=null){
                                    //objResponse.put('finalProgramListSize',finalProgramList.size()>0?true:false); 
                                    Map<String,String> programOptions = new Map<String,String>();
                                    Map<String, Schema.SObjectType> schemaDescribe = Schema.getGlobalDescribe();
                                    Schema.DescribeFieldResult fieldResult = schemaDescribe.get('SSP_ApplicationIndividual__c').getDescribe().fields.getMap().get('ProgramsApplied__c').getDescribe()       ;
                                    List<Schema.PicklistEntry> pickListEntries = fieldResult.getPicklistValues();
                                    for (Schema.PicklistEntry pickListEntry: pickListEntries){
                                        programOptions.put(pickListEntry.getValue(),pickListEntry.getLabel());
                                    }
                                    String programRequested='';
                                    for(String programs:finalProgramList){
                                        programRequested+=programOptions.get(programs)+';';
                                    }
                                    programRequested.removeEnd(';');
                                    programRequested.removeEnd('null');
                                    objWrap.sProgramsRequested=programRequested;
                                    sessionPart.put('finalProgramList', finalProgramList); 
                                    sessionPart.put('removedProgram',mapIndividualVsProgram.get(resp.IndividualId));
                                    sessionPart.put('programRemoved', programRemoved);
                                    sessionPart.put('finalProgramListSize',finalProgramList.size()>0?true:false); 
                                }
                            }
                            //End - check for exiting program and selected program for full match in MCI Call
                            mapResult = handleFullMatchScenario(resp, objMember, objWrap, mapHouseholdData, sMode); // Happy Path Scenario
                            if(null!=mapResult.get('sAppIndividual')){
                                SSP_ApplicationIndividual__c indivs= (SSP_ApplicationIndividual__c)mapResult.get('sAppIndividual');
                                applicationIndiv.add(indivs);
                                
                            } 
                            objResponse = mapResult;
                            objResponse.put('programRemoved', programRemoved);
                            objResponse.put('finalProgramListSize',finalProgramList.size()>0?true:false);
                        } 
                        else if (resp.MatchStatus == SSP_GlobalConstants.PARTIAL_MATCH || resp.MatchStatus == SSP_GlobalConstants.NO_MATCH || resp.MatchStatus ==''){
                            mapResult = handleNoMatchScenario(resp,objMember,objWrap,mapHouseholdData,sMode);
                            if(null!=mapResult.get('sAppIndividual')){
                                applicationIndiv.add((ssp_applicationIndividual__C) mapResult.get('sAppIndividual'));
                            }
                            objResponse = mapResult;
                        }                        
                        if(objWrap.sSSN!=null && objWrap.sSSN!=''){
                            updateCountForMCI=true; 
                        }
                        else if(resp.MatchStatus == SSP_GlobalConstants.FULL_MATCH && null==resp.lstOfSSPMembers){
                            objResponse.put('bIsSuccess', false); 
                            objResponse.put('error', SSP_GlobalConstants.BizTalk_Error); 
                        }
                        
                    }
                    else {
                        if (null!=resp.ErrorCode && String.isNotBlank(resp.ErrorCode) && resp.ErrorCode == SSP_GlobalConstants.ERROR_CODE_SSN_VALIDATION){ // SSA/SOLQ called and failed for the first time
                            if(null!=mapMemberVsIndiv && !String.isBlank(objWrap.sRecordId) ){
                                lstAppIndividuals.add(mapMemberVsIndiv.get(objWrap.sRecordId));
                                updateCountForMCI=true;
                            }
                            
                            objResponse.put('error', 'SSN_Verification_Error');
                        } 
                        else if(null!=resp.ErrorCode && String.isNotBlank(resp.ErrorCode) && resp.ErrorCode ==SSP_GlobalConstants.ERROR_CODE_SSN_VERIFICATION ){ // Any validation error that comes from SSA/SOLQ
                            updateCountForMCI=false;
                            objResponse.put('error', resp.ErrorMessage);
                        }
                       else if(null!=resp.ErrorCode && String.isNotBlank(resp.ErrorCode) && resp.ErrorCode==SSP_GlobalConstants.SFCalloutException){
                            LOG_LogMessage__c objLogMessage = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Info, 'SSP_HouseHoldSummaryService', 'saveDataService', 'Timed out Exception' , true);
                            if (Schema.sObjectType.LOG_LogMessage__c.isAccessible()) {
                                LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:objLogMessage.Id LIMIT 1];
                                objResponse.put('error', objLog.Name);
                            } 
                        }
                        else if ( null!=resp.ErrorCode && String.isNotBlank(resp.ErrorCode) && (resp.ErrorCode.contains(SSP_GlobalConstants.SOURCE_SYSTEM_INT)||resp.ErrorCode.contains(SSP_GlobalConstants.SOURCE_SYSTEM_NAME))){
                            objResponse.put('error', SSP_GlobalConstants.BizTalk_Error);  
                        }                         
                        else if(null!=resp.isApplicationBlocked && resp.isApplicationBlocked) {
                            objResponse.put('error', SSP_GlobalConstants.Cannot_Apply);  
                            objResponse.put('CaseNumber', resp.BlockedCaseNumber );
                            objResponse.put('BlockedMember',objWrap.sFirstName + ' '+ objWrap.sLastName);
                            lstApps[0].Status__c=SSP_GlobalConstants.STATUS_INACTIVE;
                            upsert lstApps[0] ;
                        }
                        else{
                            objResponse.put('error', SSP_GlobalConstants.BizTalk_Error+resp.ErrorCode + resp.ErrorMessage);
                            objResponse.put('BlockedMember',objWrap.sFirstName + ' '+ objWrap.sLastName);
                        }
                        
                        
                        objResponse.put('bIsSuccess', false);     
                    }
                }
                else {
                    objResponse.put('bIsSuccess', false); 
                    objResponse.put('error', SSP_GlobalConstants.BizTalk_Error); 
                }
            }
            else {
                if (bIsDuplicate){
                    objResponse.put('bIsSuccess', false); 
                    objResponse.put('error', SSP_GlobalConstants.Cannot_Apply); 
                    objResponse.put('reason', SSP_GlobalConstants.MEMBER_ADDED_TWICE); 
                    objResponse.put('BlockedMember',objWrap.sFirstName + ' '+ objWrap.sLastName);
                }
            }
            if(null!=applicationIndiv && applicationIndiv.size()>0){
                updateApplicationIndividualWithCount(applicationIndiv , updateCountForMCI);
            }
            if(null!=resp.lstofLogMessages && resp.lstofLogMessages.size()>0){
                LOG_LogMessageUtility.logMessage(resp.lstofLogMessages);
            }   
            system.debug('------------------------end-------------------');         
        }
        
        catch (Exception ex){ 
            system.debug('------------------------inside catch-------------------');
            if(null!=resp.lstofLogMessages && resp.lstofLogMessages.size()>0){
                LOG_LogMessageUtility.logMessage(resp.lstofLogMessages);
            }
             
            objResponse.put('bIsSuccess', false); 
            objResponse.put('error', ex.getLineNumber() + ex.getMessage());  
        }
        
        system.debug('------------------------before return-------------------'+objResponse);
        return objResponse;
        
        
    }
    
   /********************************************************************************************
   * @author       Suyash Singhal
   * @date         11/13/2019
   * @methodname   removeMember
   * @description  This method is used to delete the member record  from the SSP_Member object
                  
   * @param        sMemberId
   * @return       none
   ********************************************************************************************/

   @AuraEnabled
   public static Map<String,Object>  deleteMember(String sMemberId, String sApplicationIndividualId){
	
       String sApplicationId = SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
       Map<String,Object>  mapResponse = new Map<String,Object> ();
       String screenId = SSP_GlobalConstants.SSP_APP_HHMembersSummary;
       List<SSP_ApplicationIndividual__c> updateIndiv = new List<SSP_ApplicationIndividual__c> ();
       List<SSP_TrackDeletion__c> trackDelRecList = new List<SSP_TrackDeletion__c>();

       try {
           if (String.isNotBlank(sMemberId) && String.isNotBlank(sApplicationIndividualId)){
               List<String> lstTrackDeletionFields = new List<String>{'SSP_Application__c','DCId__c','EndDate__c','EndReason__c','SSP_Member__c','OtherReason__c','ParentDCId__c','SalesforceId__c','Source__c', 'SFObject__c'};
               Boolean bViewTrackDeletionFields = ESAPI.accessController().isAuthorizedToView(SSP_TrackDeletion__c.getSObjectType(), lstTrackDeletionFields);
       
               List<SSP_ApplicationIndividual__c> lstAppIndividuals = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                                                                       new Set<String>{'Id','MemberStatus__c','SSP_Member__c','SSP_Application__c','SSP_Member__r.DCId__c','SSP_Member__r.Name', 'SSP_Member__r.Id','IsActiveIEESCasePresent__c', 'SSP_Member__r.IndividualId__c'  }, 
                                                                                                                                       new Map<String, String>{'Id'=> sApplicationIndividualId }); 
               
                for(SSP_ApplicationIndividual__c rec:lstAppIndividuals){
                    rec.MemberStatus__c=SSP_GlobalConstants.MEMBER_REMOVE_STATUS  ;
                    sApplicationId = rec.SSP_Application__c;
                    mapResponse.put('applicationId', sApplicationId);
                    if( rec.IsActiveIEESCasePresent__c && bViewTrackDeletionFields && null!=rec.SSP_Member__r.IndividualID__c){   
                        SSP_TrackDeletion__c trackDelRec = new  SSP_TrackDeletion__c();
                        trackDelRec.DCId__c= Decimal.valueOf(rec.SSP_Member__r.IndividualID__c);
                        trackDelRec.Source__c=SSP_GlobalConstants.SOURCE_MEMBER;
                        trackDelRec.SSP_Application__c=rec.SSP_Application__c;
                        trackDelRec.SSP_Member__c= rec.SSP_Member__c;
                        trackDelRec.SalesforceId__c= rec.SSP_Member__r.Id;
                        trackDelRec.SFObject__c=SSP_GlobalConstants.SF_OBJECT_MEMBER;
                        trackDelRecList.add(trackDelRec);
                    }
                    updateIndiv.add(rec);
                    
                }
               
               
               if(null!=trackDelRecList && trackDelRecList.size()>0){
                   ESAPI.accessController().insertAsUser(trackDelRecList, lstTrackDeletionFields);
               }
                  
               if(null!=updateIndiv && updateIndiv.size()>0){
                   ESAPI.accessController().upsertasUser(updateIndiv, SSP_Utility.getFieldsNamesList (updateIndiv));
               }
                                
               // Below Condition is use to stamp MAGI/Non-MAGI for newly added Member satisfying ABD check.
               if(String.isNotBlank(sApplicationId)) {
                    SSP_MemberService.checkMembersAgeBlindDisabledInfo(sApplicationId, null);
               }
               
            
               mapResponse.put('bIsSuccess', true);
          
               }         
               
           
       }
       catch(Exception ex){
           mapResponse.put('bIsSuccess', false); 
           mapResponse.put('error', ex.getMessage()); 
           List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseholdMembersSummaryCtrl', 'deleteMember', ex.getMessage() , true);
       }
       
   
   return mapResponse;

   }
    
    public static SSP_MCIMergedServiceRequestWrapper createServiceCallWrapper(SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap , List<SSP_Application__c> lstApps, Boolean sMode , Boolean nSSNRetryFlag){
        
        SSP_MCIMergedServiceRequestWrapper objRequestWrapper = new SSP_MCIMergedServiceRequestWrapper(); 
        try{
            Map<String, String> progTypesMap = new Map<String, String>();    
            progTypesMap = SSP_Utility.getPickListValue('SSP_ApplicationIndividual__c','ProgramsApplied__c', null);
            String appliedProgramListCode;
            objRequestWrapper.sourceSystemName = SSP_GlobalConstants.SOURCE_SYSTEM_NAME;           
            if(null!=objWrap.memberIndividualId && objWrap.memberIndividualId!='' )
                objRequestWrapper.sourceIndividualId =Integer.valueOf(objWrap.memberIndividualId);  
            objRequestWrapper.firstName = objWrap.sFirstName;
            objRequestWrapper.middleName = objWrap.sMiddleName;
            objRequestWrapper.lastName =  objWrap.sLastName;
            objRequestWrapper.DOB =  String.valueOf(objWrap.dDOB);
            objRequestWrapper.SSN =  objWrap.sSSN;
            objRequestWrapper.gender =  objWrap.sGender;      
            if(null!=objWrap.sHOHMCIId ){
                String temHOHID = objWrap.sHOHMCIId;
                if(temHOHID!='')
                    objRequestWrapper.HOHId =Integer.valueOf(temHOHID); 
            }               
            objRequestWrapper.isHeadOfHousehold = objWrap.bisHOH ==null||objWrap.bisHOH==false?false:true;
            objRequestWrapper.IscitizenshipVerified =objWrap.bisUSCitizen=='Y'? true:false;
            objRequestWrapper.isSSNValidated = objWrap.bSSNVerified==null || objWrap.bSSNVerified == false? false:true;
            
            List<String> appliedProgs= objWrap.sProgramsRequested.split(';');    
            for(String programs:appliedProgs){
                if(null!=appliedProgramListCode){
                    appliedProgramListCode = appliedProgramListCode + ';'+ progTypesMap.get(programs);
                }
                else 
                    appliedProgramListCode= progTypesMap.get(programs);
            }      
            objRequestWrapper.program = appliedProgramListCode;           
            objRequestWrapper.screenName = SSP_GlobalConstants.SCREEN_ID_HH_DETAIL;            
            objRequestWrapper.mode = smode==true?SSP_GlobalConstants.SSP_RAC_FLOW:SSP_GlobalConstants.SSP_INTAKE_FLOW;           

            if(null!=smode && smode && null!= lstApps && null!=lstApps[0].DCCaseNumber__c){      
                objRequestWrapper.caseNumber = Integer.valueOf(lstApps[0].DCCaseNumber__c); 
            }
            
            else if (null!=sMode && !sMode  && null!=objWrap.sApplicationNumber){
                objRequestWrapper.applicationNumber = objWrap.sApplicationNumber;
            }
            
            if(objWrap.mciCallCount==0 && !nSSNRetryFlag ){
                objRequestWrapper.ssnRetryFlag = true; 
            }
            else 
                objRequestWrapper.ssnRetryFlag= objWrap.mciCallCount >1?false:true;
        }
        catch(Exception e){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_HouseholdSummaryService', 'createServiceCallWrapper', e.getMessage() , true);
            return null;
        }
        
        return objRequestWrapper;
        
    }
   
    
    public static void createConMapping (Set<Integer> indivIds , List<Contact> contactId) { 
        Set<Integer> createdContactList  = new   Set<Integer>();
        if(contactId==null){
            createdContactList =  SSP_SharingBypassFetcher.getContactsToInsert(indivIds);
        }  
        else {
            createdContactList =  getContactsToInsert(indivIds, contactId);
        }
        if(null!=createdContactList && createdContactList.size()>0){ 
            SSP_SharingBypassFetcher.insertConMappingRecords(indivIds);
        } 
    }
   

    public static MCIDataWrapper mciWrap = new MCIDataWrapper();
    public Static Map<String,Object> handleFullMatchScenario(SSP_MCIMergedServiceResponeWrapper responseData , SSP_Member__c objMember, SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap,Map<String,Object> mapHouseholdData, Boolean sMode){
        Map<String, String> userDetails = SSP_Utility.getUserDetails(UserInfo.getUserId());
        Boolean isNonCitizenUser = userDetails.get('profileName').equals(SSP_GlobalConstants.NON_CITIZEN_PROFILE) && String.isNotBlank(userDetails.get('userRole')) && !userDetails.get('userRole').equalsIgnoreCase(SSP_GlobalConstants.CITIZEN_ROLE);//Added by Shrikant - CD2  
        mciWrap.isNonCitizenUser =  isNonCitizenUser;  
        mciWrap.contactId =  userDetails.get('contactId');  
        SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper = new SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper(); //Added by Shrikant - CD2
        List<SSP_Member__c> lstMembersToUpsert = new List<SSP_Member__c>();
        List<String> indivIds = new List<String>();
        List<SSP_ApplicationIndividual__c> lstAppIndivsToUpsert = new List<SSP_ApplicationIndividual__c>();
        Map<String,Object> mapResponse = new Map<String,Object>();
        List<Account> lstAccountToInsert = new List<Account>();
        List<Contact> lstContactsToInsert = new List<Contact>();
        List<String> individualContactCreated = new List<String>();
        List<String> lstContactFields = new List<String>{'Account__c','RecordTypeId','FirstName','LastName'};
        Map<String,SSP_Member__c> mapExstIndivIdVsMemRecord = new Map<String,SSP_Member__c>();
        Map<Id,SSP_Member__c> mapExstMemIdVsMemRecord = new Map<Id,SSP_Member__c>();
        Map<Id,SSP_ApplicationIndividual__c> mapExtMemberIdVsAppIndivId = new Map<Id,SSP_ApplicationIndividual__c>();                                
        Map<String, Object> dummyMemberDetails = new Map<String, Object>(); //Added by Shrikant - CD2 
        Map<String, SSP_Member__C> extMemberIndvIdToId = new Map<String, SSP_Member__C>(); //Added by Shrikant - CD2 
        List<SSP_ApplicationIndividual__c> lstAppIndividuals =  (List<SSP_ApplicationIndividual__c>)mapHouseholdData.get('lstAppIndividuals');
        List<SSP_Application__C> lstApps = (List<SSP_Application__C>)mapHouseholdData.get('lstApps');
        List<SSP_Member__C> listAppMembers=  (List<SSP_Member__c>)mapHouseholdData.get('lstMembers');
        String applicationRecordId = Schema.getGlobalDescribe().get('SSP_Application__c').getDescribe().getRecordTypeInfosByName().get('Case').getRecordTypeId();
        Map<ID,String> updateContactList = new  Map<ID,String>();
        Map<String,object> mapRestResult = new  Map<String,object>();
		Boolean hohWithBlockedCaseNumber = false;        
        List<SSP_ApplicationIndividual__c> deleteApplicationIndivRec = new List<SSP_ApplicationIndividual__c>();
      //  Map<String ,ID> deleteConMapping = new Map<String , ID>();
        List<SSP_Member__C> deleteCurrentMemberRecord = new List<SSP_Member__C>();
        Set<String> makeApplicationBlocked = new  Set<String>();
        Cache.SessionPartition sessionPart = Cache.Session.getPartition(SSP_GlobalConstants.CACHE_PARTITION_NAME);
        try{
            Map<String, String> progTypesMap = new Map<String, String>();            
            progTypesMap = SSP_Utility.getPickListValue('SSP_ApplicationIndividual__c','ProgramsApplied__c',null);
            if(null!=objWrap.sProgramsRequested ){               
                for(String programName: objWrap.sProgramsRequested.split(';')){
                    if(mciWrap.appliedProgramList!=''){
                        mciWrap.appliedProgramList = mciWrap.appliedProgramList+';'+ progTypesMap.get(programName);
                    }
                    else
                        mciWrap.appliedProgramList=progTypesMap.get(programName);
                }
            }
            
            if(null!=responseData && null!=responseData.lstOfSSPMembers)
                for (SSP_Member__c objIEESMemberData : responseData.lstOfSSPMembers){
                    indivIds.add(objIEESMemberData.IndividualId__c);
                }             
            if(null!=lstApps && lstApps.size()>0){
                mciWrap.applicationDetail=lstApps[0];
            }
           
			// method to get Contact + Con-Mapping + Members 
            fetchRequiredData(indivIds);
            
            List<SSP_Member__C> lstMembers  = new List<SSP_Member__C>();
            lstMembers.addAll(mciWrap.allMembersWithID.values());
           
            extMemberIndvIdToId = constructExtMemDetailMap(lstMembers, listAppMembers);//Added by Shrikant - CD2
            listAppMembers.addAll(lstMembers);
            if(null!=listAppMembers && listAppMembers.size()>0)	{
                for(SSP_Member__C members :listAppMembers){
                    if(members.IndividualId__c!=null && mapExstIndivIdVsMemRecord!=null && null==mapExstIndivIdVsMemRecord.get(members.IndividualId__c)){
                        mapExstIndivIdVsMemRecord.put(members.IndividualId__c, members);
                    }
                    mapExstMemIdVsMemRecord.put(members.id,members);
                }
            }
            
            if(null!=lstAppIndividuals && !lstAppIndividuals.isEmpty()){
                for (SSP_ApplicationIndividual__c objApIndiv : lstAppIndividuals){
                    mapExtMemberIdVsAppIndivId.put(objApIndiv.SSP_Member__c,objApIndiv);                    
                } 
            }

            //Added by Shrikant - CD 2
            detailsWrapper.member = objMember;
            detailsWrapper.applicationIndividual = new SSP_ApplicationIndividual__c();
            
            Map<String,SSP_ApplicationIndividual__c> mapRespIndivIdVSAppIndiv = new Map<String,SSP_ApplicationIndividual__c> ();
            if(null!=responseData.lstOfApplicationIndividuals)
                for(SSP_ApplicationIndividual__c indivs: responseData.lstOfApplicationIndividuals){
                    if(mapRespIndivIdVSAppIndiv.get(String.valueOf(indivs.ssp_member__c))==null){
                        mapRespIndivIdVSAppIndiv.put(String.valueOf(indivs.ssp_member__c),indivs );
                    }
                }      
            if(null!=responseData && null!=responseData.lstOfSSPMembers){
                // existing member is edited / HOH is edited  / Data returned from MCI is 1 
                if( responseData.lstOfSSPMembers.size()==1 && String.isNotBlank(objWrap.sRecordId) && null!=mapExstMemIdVsMemRecord.get(objWrap.sRecordId)){
                    if(null!=responseData.MatchStatus && responseData.MatchStatus!=''){
                        responseData.lstOfSSPMembers[0].MatchType__c=responseData.MatchStatus;
                    }
                    if(!isNonCitizenUser || (objWrap.memberIndividualId != null )){ //Added by Shrikant - CD2
                        responseData.lstOfSSPMembers[0]= saveValueEnteredFromUser(objMember,responseData.lstOfSSPMembers[0]); 
                         if(extMemberIndvIdToId.containsKey(responseData.lstOfSSPMembers[0].IndividualId__c)) 
                        {  
                            responseData.lstOfSSPMembers[0].id= extMemberIndvIdToId.get(responseData.lstOfSSPMembers[0].IndividualId__c).id;
                            if(null!=mapExtMemberIdVsAppIndivId.get(objWrap.sRecordId)){
                                deleteApplicationIndivRec.add(mapExtMemberIdVsAppIndivId.get(objWrap.sRecordId));
                                deleteCurrentMemberRecord.add(mapExstMemIdVsMemRecord.get(objWrap.sRecordId));
                                mapExtMemberIdVsAppIndivId.remove(objWrap.sRecordId);
                             }
                            // Changes to for reparenting 
                            if(mapRespIndivIdVSAppIndiv.get(responseData.lstOfSSPMembers[0].IndividualId__c).IsHeadOfHousehold__c){
                                
                                if(isNonCitizenUser){
                                    responseData.lstOfSSPMembers[0].Contact__c = mciWrap.createdContact.get(responseData.lstOfSSPMembers[0].IndividualId__c)!=null ?  mciWrap.createdContact.get(responseData.lstOfSSPMembers[0].IndividualId__c) : mapExstMemIdVsMemRecord.get(objWrap.sRecordId).contact__c;
                                 }
                                else {
                                     makeApplicationBlocked.add(String.valueOf(extMemberIndvIdToId.get(responseData.lstOfSSPMembers[0].IndividualId__c).id));
                                    responseData.lstOfSSPMembers[0].Contact__c = mapExstMemIdVsMemRecord.get(objWrap.sRecordId).contact__c;        
                                }
                                
                                //deleteConMapping.put(responseData.lstOfSSPMembers[0].IndividualId__c, extMemberIndvIdToId.get(responseData.lstOfSSPMembers[0].IndividualId__c).Contact__c);
                                updateContactList.put(responseData.lstOfSSPMembers[0].Contact__c ,responseData.lstOfSSPMembers[0].IndividualId__c);
                               }
                            else {
                               updateContactList.put(extMemberIndvIdToId.get(responseData.lstOfSSPMembers[0].IndividualId__c).Contact__c ,responseData.lstOfSSPMembers[0].IndividualId__c);
						    }
                        }
                        else{ 
                            responseData.lstOfSSPMembers[0].id=objWrap.sRecordId;
                            updateContactList.put(mapExstMemIdVsMemRecord.get(responseData.lstOfSSPMembers[0].id).Contact__c ,responseData.lstOfSSPMembers[0].IndividualId__c);
                        }
                        
                        //update application individual data
                        if(null!=mapExtMemberIdVsAppIndivId.get(responseData.lstOfSSPMembers[0].Id) ){              
                            mapExtMemberIdVsAppIndivId.get(responseData.lstOfSSPMembers[0].Id).isHOHDetailsCompleted__c=true;                     
                            if(mciWrap.appliedProgramList!='' && null!=mapRespIndivIdVSAppIndiv.get(responseData.IndividualId)){
                                mapRespIndivIdVSAppIndiv.get(responseData.IndividualId).MemberProgramsApplied__c= mciWrap.appliedProgramList;   
                            }
                        }     
                        if(null!=mapRespIndivIdVSAppIndiv.get(responseData.lstOfSSPMembers[0].IndividualId__c)){
                            mapRespIndivIdVSAppIndiv.get(responseData.IndividualId).MemberProgramsApplied__c= mciWrap.appliedProgramList;   
                            mapRespIndivIdVSAppIndiv.get(responseData.lstOfSSPMembers[0].IndividualId__c).isHOHDetailsCompleted__c=true;
                        }
                  
                     lstMembersToUpsert.add(responseData.lstOfSSPMembers[0]); 
                       
                    }       
                    /*For Non Citizen user - Added by Shrikant - CD2*/                           
                    else if(mapRespIndivIdVSAppIndiv.get(responseData.lstOfSSPMembers[0].IndividualId__c).IsHeadOfHousehold__c){
						 hohWithBlockedCaseNumber = mapRespIndivIdVSAppIndiv.get(responseData.lstOfSSPMembers[0].IndividualId__c).BlockedCaseNumber__c!=null ? true:false;
                        detailsWrapper = constructQICallData(objWrap, detailsWrapper, responseData.IndividualId, responseData.lstOfSSPMembers[0]);
                    }
                     
                }                               
                else{
                    for (SSP_Member__c objIEESMemberData : responseData.lstOfSSPMembers)
                    {  
                        if(null!=responseData.MatchStatus && responseData.MatchStatus!=''){
                            objIEESMemberData.MatchType__c=responseData.MatchStatus;
                        }
                        
                        // HOH data is found in Response
                        if ((mapRespIndivIdVSAppIndiv.size()>0 && null!=mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c) && mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).IsHeadOfHousehold__c) ){
                                // for HOH member data is already created 
                            if(!isNonCitizenUser ||  (objWrap.memberIndividualId != null )){//Added by Shrikant - CD2               
                                 objIEESMemberData = saveValueEnteredFromUser(objMember,objIEESMemberData);                               
                                if (String.isNotBlank(objWrap.sRecordId) && !extMemberIndvIdToId.containsKey(objIEESMemberData.IndividualId__c)){
                                    objIEESMemberData.Id =  objWrap.sRecordId;
                                    updateContactList.put(mapExstMemIdVsMemRecord.get(objWrap.sRecordId).contact__c ,objIEESMemberData.IndividualId__c);
                                  }                                
                                else if (String.isNotBlank(objWrap.sRecordId) && extMemberIndvIdToId.containsKey(objIEESMemberData.IndividualId__c)){
                                    objIEESMemberData.Id =  extMemberIndvIdToId.get(objIEESMemberData.IndividualId__c).id;
                                    if(null!=mapExtMemberIdVsAppIndivId.get(objWrap.sRecordId)){
                                        deleteApplicationIndivRec.add(mapExtMemberIdVsAppIndivId.get(objWrap.sRecordId));
                                        deleteCurrentMemberRecord.add(mapExstMemIdVsMemRecord.get(objWrap.sRecordId));
                                        mapExtMemberIdVsAppIndivId.remove(objWrap.sRecordId);  
                                         // Changes to for reparenting 
                                        if(isNonCitizenUser){
                                            objIEESMemberData.Contact__c =  mciWrap.createdContact.get(objIEESMemberData.IndividualId__c)!=null ?  mciWrap.createdContact.get(objIEESMemberData.IndividualId__c) : mapExstMemIdVsMemRecord.get(objWrap.sRecordId).contact__c;
                                        }
                                        else {
                                            makeApplicationBlocked.add(extMemberIndvIdToId.get(objIEESMemberData.IndividualId__c).id);
                                            objIEESMemberData.Contact__c = mapExstMemIdVsMemRecord.get(objWrap.sRecordId).contact__c;        
                                        }
                                       // deleteConMapping.put(objIEESMemberData.IndividualId__c, extMemberIndvIdToId.get(objIEESMemberData.IndividualId__c).Contact__c);
                                    }
                                    updateContactList.put(objIEESMemberData.Contact__c ,objIEESMemberData.IndividualId__c);
                                 }
                                lstMembersToUpsert.add(objIEESMemberData);                                
                                if(null!=mapExtMemberIdVsAppIndivId.get(objIEESMemberData.Id))
                                { mapExtMemberIdVsAppIndivId.get(objIEESMemberData.Id).isHOHDetailsCompleted__c=true;
                                 if(mciWrap.appliedProgramList!='' ){
                                     mapExtMemberIdVsAppIndivId.get(objIEESMemberData.Id).MemberProgramsApplied__c=mciWrap.appliedProgramList;  
                                 }
                                }
                                mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).isHOHDetailsCompleted__c=true;
                                if(mciWrap.appliedProgramList!='' ){
                                    mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).MemberProgramsApplied__c=mciWrap.appliedProgramList; 
                                }
                            }
                            /*For Non Citizen user - Added by Shrikant - CD2*/
                            else{
                                detailsWrapper = constructQICallData(objWrap, detailsWrapper, null, objIEESMemberData);
                                 hohWithBlockedCaseNumber = mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).BlockedCaseNumber__c!=null ? true:false;
                            }
                            
                        }                        
                        // for existing Member with Individual Id  
                        else  if (mapExstIndivIdVsMemRecord.size()>0 && null!=mapExstIndivIdVsMemRecord.get(String.valueOf(objIEESMemberData.IndividualId__c))) 
                        {
                            objIEESMemberData.Id= mapExstIndivIdVsMemRecord.get(String.valueOf(objIEESMemberData.IndividualId__c)).id;
                            updateContactList.put(mapExstIndivIdVsMemRecord.get(objIEESMemberData.IndividualId__c).Contact__c ,objIEESMemberData.IndividualId__c);  
                            if(responseData.lstOfSSPMembers.size()==1){
                                objIEESMemberData= saveValueEnteredFromUser(objMember,objIEESMemberData);
                                if(mciWrap.appliedProgramList!='' ){
                                    mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).MemberProgramsApplied__c=mciWrap.appliedProgramList; 
                                }
                            }
                            lstMembersToUpsert.add(objIEESMemberData);
                        }
                        else if(!detailsWrapper.triggerQualifiedCall){ //#377137
                            // Create Member Logic
                            if(!mciWrap.createdContact.containsKey(objIEESMemberData.IndividualId__c)){
                            ResponseWrapper response = constructMemberData(objIEESMemberData);
                            if(response != null && response.account != null){ lstAccountToInsert.add(response.account);}                            
                            if(response != null && response.contact != null){ lstContactsToInsert.add(response.contact);}
                            }
                            else {
                                individualContactCreated.add(objIEESMemberData.individualId__c);
                            }
                            
                        }
                    }
                }
            }
            
            if ( (!lstAccountToInsert.isEmpty() && lstAccountToInsert.size()>0 ) || (individualContactCreated!=null && individualContactCreated.size()>0)){     
               
                String sContactId = [Select id,Contactid from User where id=: userinfo.getUserId()].ContactId;
                List<String> lstIndividualId = new  List<String>();
                List<Contact> lstContactsToUpdate = new  List<Contact>();
                List<Contact> finalListContactsToInsert = new  List<Contact>();
                for(Contact objContact : lstContactsToInsert){
                    if(objContact.IndividualId__c != NULL){
                       lstIndividualId.add(objContact.IndividualId__c);
                     }
                }
                lstIndividualId.addAll(individualContactCreated);
              
               if(!lstIndividualId.isEmpty()){
                lstContactsToUpdate = [SELECT Id,IndividualId__c FROM Contact WHERE IndividualId__c IN :lstIndividualId];
                }
                for(Contact objContactToUpdate :lstContactsToUpdate){
                  //  deleteConMapping.put(objContactToUpdate.IndividualId__c, objContactToUpdate.Id);
                    objContactToUpdate.IndividualId__c = null;
                 }
                if(!lstContactsToUpdate.isEmpty()){
                    UPDATE lstContactsToUpdate;
                }
                mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccountToInsert,lstContactsToInsert,sContactId);
                
                if(null!=mapRestResult && mapRestResult.size()>0) {
                    lstAccountToInsert = (List<Account>)mapRestResult.get('lstAccounts');
                    lstContactsToInsert = (List<Contact>)mapRestResult.get('lstContacts'); 
                }
                
                updateOwner(lstAccountToInsert, lstContactsToInsert); 

                Map<String,String> mapConNameVsConId = new Map<String,String>();
                if (lstContactsToInsert != null && !lstContactsToInsert.isEmpty()){
                    for (Contact con : lstContactsToInsert){
                        mapConNameVsConId.put(con.FirstName+ con.LastName,con.Id);
                    }
                }
                
                for (SSP_Member__c objIEESMemberData : responseData.lstOfSSPMembers){
                    // add logic to create Member record for existingcontacts 
                    if ( (mapConNameVsConId.size()>0 && mapConNameVsConId.keyset().contains(objIEESMemberData.FirstName__c+objIEESMemberData.LastName__c)) || (individualContactCreated.contains(objIEESMemberData.IndividualId__c))){
                        if(mciWrap.createdContact.containsKey(objIEESMemberData.IndividualId__c))
                        {
                            objIEESMemberData.Contact__c =  mciWrap.createdContact.get(objIEESMemberData.IndividualId__c);
                          }
                        else {
                            objIEESMemberData.Contact__c = mapConNameVsConId.get(objIEESMemberData.FirstName__c+objIEESMemberData.LastName__c) ;
                          }
                        if(null!=responseData.MatchStatus && responseData.MatchStatus!=''){
                            objIEESMemberData.MatchType__c=responseData.MatchStatus;
                        }
                        if(responseData.lstOfSSPMembers.size()==1){
                            objIEESMemberData= saveValueEnteredFromUser(objMember,objIEESMemberData);
                            if(mciWrap.appliedProgramList!='' ){
                                mapRespIndivIdVSAppIndiv.get(objIEESMemberData.IndividualId__c).MemberProgramsApplied__c=mciWrap.appliedProgramList; 
                            }
                        }
                           lstMembersToUpsert.add(objIEESMemberData);
                        updateContactList.put(objIEESMemberData.Contact__c,objIEESMemberData.IndividualId__c);
                    }
                }
            } 

            // Method to make Application Blocked if Non-Citizen has created 
            if(makeApplicationBlocked!=null && makeApplicationBlocked.size()>0){
                 identifyAndMarkUNApplications(makeApplicationBlocked);
            }
                       
            if(null!=lstMembersToUpsert && lstMembersToUpsert.size()>0 )   {
               upsert lstMembersToUpsert;
            }
            
            if(null!=deleteApplicationIndivRec && deleteApplicationIndivRec.size()>0){
                delete deleteApplicationIndivRec;
            }
            if(null!=deleteCurrentMemberRecord && deleteCurrentMemberRecord.size()>0){
                delete deleteCurrentMemberRecord;
            }
            
            
            if (!lstMembersToUpsert.isEmpty()){
                Boolean isAppIndivPresent = false;
                for (SSP_Member__c objUpsertMember : lstMembersToUpsert){
                    SSP_ApplicationIndividual__c objAppIndiv;
                    objAppIndiv = null!= mapRespIndivIdVSAppIndiv.get(String.valueOf(objUpsertMember.IndividualId__c)) ?mapRespIndivIdVSAppIndiv.get(String.valueOf(objUpsertMember.IndividualId__c)):new SSP_ApplicationIndividual__c();
                   if (mapExtMemberIdVsAppIndivId.containsKey(objUpsertMember.Id)) // when Application Individual not present
                    { objAppIndiv.id= mapExtMemberIdVsAppIndivId.get(objUpsertMember.Id).id;
                        objAppIndiv.isHOHDetailsCompleted__c = mapExtMemberIdVsAppIndivId.get(objUpsertMember.Id).isHOHDetailsCompleted__c;
                        isAppIndivPresent=true;
                    }
                    else if (null!=lstApps && lstApps.size()>0){
                        if(null!=mapRespIndivIdVSAppIndiv && mapRespIndivIdVSAppIndiv.size()==1){
                            objAppIndiv.isHOHDetailsCompleted__c=true; }
                        objAppIndiv.SSP_Application__c = lstApps[0].id; 
                        objAppIndiv.SSP_Member__c = objUpsertMember.id;
                    }
                    
                    objAppIndiv = parseApplicationDetails(objAppIndiv, objUpsertMember);
                    if(!isAppIndivPresent){
                        //New AppIndiv Added
                        if(null!= mciWrap.applicationDetail.SectionStatus__C){
                            for(String section : mciWrap.applicationDetail.SectionStatus__C.split(','))
                                if(section.contains( SSP_GlobalConstants.SSP_APP_HHMembersSummary)&& section.contains(SSP_GlobalConstants.SECTION_STATUS_Complete)){
                                    objAppIndiv.MemberStatus__c=SSP_GlobalConstants.MEMBER_STATUS_New; 
                                }
                        }
                        
                        if(null!=sMode && sMode==true){
                            objAppIndiv.MemberStatus__c=SSP_GlobalConstants.MEMBER_STATUS_New;
                        }
                        
                    }                   
                    lstAppIndivsToUpsert.add(objAppIndiv);                    
                }
            }
            //Added by Shrikant
            if(detailsWrapper.responseMemberData != null && mapRespIndivIdVSAppIndiv.containsKey(String.valueOf(detailsWrapper.responseMemberData.IndividualId__c))){
                parseApplicationDetails(mapRespIndivIdVSAppIndiv.get(String.valueOf(detailsWrapper.responseMemberData.IndividualId__c)), detailsWrapper.responseMemberData);
            }

            if(null!=lstAppIndivsToUpsert && lstAppIndivsToUpsert.size()>0){
                upsert lstAppIndivsToUpsert;
            }
            List<Contact> updateContact = new List<Contact>();
            List<Contact> lstUpdateContactIndividualId = new List<Contact>();
            If(!updateContactList.isEmpty()){
                lstUpdateContactIndividualId = [SELECT Id,IndividualId__c FROM Contact Where IndividualId__c IN :updateContactList.values() 
                                                AND Id NOT IN :updateContactList.KeySet()];
            }
            for( Contact objContact :lstUpdateContactIndividualId){
               // deleteConMapping.put(objContact.IndividualId__c, objContact.id);
                objContact.IndividualId__c = null;
            }
            if(!lstUpdateContactIndividualId.isEmpty()){
                UPDATE lstUpdateContactIndividualId;
            }
            SET<Integer> indivIdSet = new SET<Integer> ();
            for( ID conID :updateContactList.keySet()){
                Contact c = new Contact();
                c.Id =conID;
                c.IndividualId__c = updateContactList.get(conID);
                updateContact.add(c);
                indivIdSet.add(Integer.valueOf(c.IndividualId__c));
            }
            if(null!=updateContact && updateContact.size()>0){
                upsert updateContact;
                 createConMapping(indivIdSet , updateContact);
            }            
            
            if(null != mciWrap.applicationDetail ){
                upsert mciWrap.applicationDetail;
            }
            
            for(SSP_ApplicationIndividual__c appIndiv :lstAppIndividuals){
                if(appIndiv.IsHeadOfHousehold__c){
                    mapResponse.put('sAppIndividual',appIndiv);  
                    mapResponse.put('Member',appIndiv.SSP_Member__c );
                }
                else if(responseData.lstOfApplicationIndividuals.size()==1){
                    mapResponse.put('sAppIndividual',appIndiv);
                    mapResponse.put('Member',appIndiv.SSP_Member__c );
                    mapResponse.put('validAbsentParent',checkAbsentParentRule(responseData.lstOfApplicationIndividuals));  
                }      
            }
            
            if(mciWrap.isApplicationBlocked && mciWrap.cannotApplyModal){ //open application blocked modal 
                mapResponse.put('bIsSuccess', false);
                mapResponse.put('error', SSP_GlobalConstants.Cannot_Apply);  
                mapResponse.put('BlockedMember', mciWrap.blockedIndividuals);
                mapResponse.put('CaseNumber', null==responseData.CaseNumber?responseData.Applicationnumber: responseData.CaseNumber); //blocked case number
                return mapResponse;
            }
            mapResponse.put('bIsSuccess',true);
            if(sMode){
                if(null!=responseData.CaseNumber && responseData.CaseNumber!=''){
                    mapResponse.put('CaseNumber', responseData.CaseNumber);  // current case number 
                }
            }              
            else {
                if(null!=responseData.Applicationnumber && responseData.Applicationnumber!=''){
                    mapResponse.put('CaseNumber', responseData.Applicationnumber);
                }
            }            
            //merge case popup will be visible only in case of Intake 
            if(mciWrap.mergeCaseNumbers!='' && lstApps[0].RecordTypeId!=applicationRecordId){
                mapResponse.put('MergeCaseNumber', mciWrap.mergeCaseNumbers);}
            else if (null!=responseData.BlockedCaseNumber  && responseData.BlockedCaseNumber!='' && lstApps[0].RecordTypeId!=applicationRecordId){
                mapResponse.put('MergeCaseNumber', responseData.BlockedCaseNumber);}
            
            
            
            // open merge case found modal
            

            if(dummyMemberDetails != null && !dummyMemberDetails.isEmpty()){
                updateContactInfo(dummyMemberDetails, null, null);
            }
            
            //Added by Shrikant - CD2
            if(isNonCitizenUser && objWrap.bisHOH && detailsWrapper.triggerQualifiedCall){
                //deleteRecords(mciWrap.membersToBeDeleted);
                detailsWrapper.isCitizenUser = !isNonCitizenUser;
				//CD2 - Driver Navigation - start
                String userRole = (SSP_Utility.getUserDetails(UserInfo.getUserId())).get(SSP_GlobalConstants.USER_ROLE);
                Set<String> driverNavRoles = new Set<String>{SSP_GlobalConstants.ASSISTER_ROLE, SSP_GlobalConstants.ORGANISATION_AUTH_REP, SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING};
                List<SSP_ApplicationIndividual__c> existingMemList;
				if(mciWrap.hohIndividualId != null){
					existingMemList = SSP_SharingBypassFetcher.fetchRecords (
                            new Map<String, String> {'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND' , 'SSP_Application__c'=>'!='},
                            new Set<String> {'Id'},
                            new Map<String, String> {'SSP_Member__r.IndividualId__c'=> mciWrap.hohIndividualId,'SSP_Application__r.Status__c'=>'UN' , 'SSP_Application__c' => lstApps[0].id }
                    );
                }
                 // Found Member in SF : Assister, Auth Rep
                /** #382177 */
                if(existingMemList != null && !existingMemList.isEmpty() && driverNavRoles.contains(userRole)){
                    List<SSP_ApplicationIndividual__c> memListAccessCheck = (List<SSP_ApplicationIndividual__c>)SSP_Utility.fetchRecords (
                            new Map<String, String> {'objectName'=>'SSP_ApplicationIndividual__c','operator'=>'AND'},
                            new Set<String> {'Id','SSP_Application__c','SSP_Application__r.Account__c','SSP_Application__r.Name'}, //Added SSP_ApplicationId__c & SSP_Application__r.Account__c & SSP_Application__r.Name #381823
                            new Map<String, String> {'SSP_Member__r.IndividualId__c'=> mciWrap.hohIndividualId,'SSP_Application__r.Status__c'=>'UN'}
                    );
                    if(mciWrap.applicationDetail != null && mciWrap.applicationDetail.Id != null){
                        mciWrap.applicationDetail.Status__c = SSP_GlobalConstants.APPLICATION_STATUS_BLOCKED;
                        update mciWrap.applicationDetail;
                    }                    
                    if(memListAccessCheck != null && !memListAccessCheck.isEmpty()){
                        
                        List<AccountContactRelation> acrList = SSP_AccountContactRelationSelector.queryACRData(new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND'}, 
                                                                new Set<String>{'Id','contactId','AccountId'}, 
                                                                new Map<String, String>{'limit'=>'1','ContactId'=> userDetails.get('contactId'), 'AccountId' => memListAccessCheck[0].SSP_Application__r.Account__c});  

                        // Has Access to Record
                        if(acrList != null && !acrList.isEmpty()){
                            mapResponse.put('existingApplicationPresent',true);
                            sessionPart.remove('removedProgram');//Added as Part of CD2 changes
                        }
                        // No Access   
                        else{
                            mapResponse.put('applicationNumber',memListAccessCheck[0].SSP_Application__r.Name);
                            mapResponse.put('applicationId',memListAccessCheck[0].SSP_Application__c);
                            mapResponse.put('individualIdForConsent',mciWrap.hohIndividualId);
                            mapResponse.put('redirectForConsent',true);
                        }                                                             

                    }                    
                }
                /** */
                // Found Member in SF : Other roles ( Exluding - Assister, Auth Rep )
                else if(existingMemList != null && !existingMemList.isEmpty()){
                    if(mciWrap.applicationDetail != null && mciWrap.applicationDetail.Id != null){
                        mciWrap.applicationDetail.Status__c = SSP_GlobalConstants.APPLICATION_STATUS_BLOCKED;
                        update mciWrap.applicationDetail;
                    }
                    mapResponse.put('existingApplicationPresent',true);
                    sessionPart.remove('removedProgram');//Added as Part of CD2 changes
                }
                // No Application Found
                else{
                    if(hohWithBlockedCaseNumber){
                        mapResponse.put('existingApplicationPresent',false);
                        mapResponse.put('redirectForConsent',false);
                        deleteRecords(mciWrap.membersToBeDeleted);
                        triggerQualifiedCall(mciWrap.applicationDetail.Id, mciWrap.hohIndividualId, detailsWrapper);
                    }
                    else {            
                       Boolean deleteRecord = false;
                        SSP_Member__c newMember = saveValueEnteredFromUser(detailsWrapper.member, detailsWrapper.responseMemberData);
                        if(mapExstIndivIdVsMemRecord.get(mciWrap.hohIndividualId)!= null){
                            newMember.id = mapExstIndivIdVsMemRecord.get(mciWrap.hohIndividualId).id;
                            deleteRecord= true;
                        }
                        else {
                             newMember.id = detailsWrapper.member.id; 
                            if(mciWrap.createdContact!=null && mciWrap.createdContact.containsKey(mciWrap.hohIndividualId)){
                                newMember.Contact__c = mciWrap.createdContact.get(mciWrap.hohIndividualId);
                                
                            }
                            
                        }     
                        upsert newMember;  
                                             
                        if(deleteRecord){
                            SSP_ApplicationIndividual__c appIndiv= (SSP_ApplicationIndividual__c)mapResponse.get('sAppIndividual');
                            appIndiv.id=null;
                            appIndiv.SSP_Member__c = newMember.id;
                            insert appIndiv; 
                            deleteRecords(mciWrap.membersToBeDeleted);
                        }                                              
                        createAccountContactRelation(lstApps[0].id ,true);                      
                        mapResponse.put('existingApplicationPresent',false); 
                        mapResponse.put('redirectForConsent',false);
						
                    }
                }
                //CD2 - Driver Navigation - end
            }
            //Bug 389924
            Boolean waiverRole=false;
            if(SSP_GlobalConstants.waiverRoles.contains(SSP_Utility.getSelectedRole())){
                waiverRole=true;
            }
            Contact memberContact= new Contact();
            memberContact.FirstName=objMember.FirstName__c;
            memberContact.LastName=objMember.LastName__c;
            memberContact.MiddleName=objMember.MiddleInitial__c;     
            memberContact.IndividualId__c=mciWrap.hohIndividualId; 
            // Bug 389924
            mapResponse.put('selectedRole', SSP_Utility.getSelectedRole());
            mapResponse.put('isFullMatch', true);
            mapResponse.put('memberContact',JSON.serialize(memberContact));// Bug 389924
            mapResponse.put('waiverRole',waiverRole);// Bug 389924
            mapResponse.put('individualId', mciWrap.hohIndividualId);
            createAccountContactRelation(lstApps[0].Id , false);
        } 
        catch(Exception e){
            mapResponse.put('bIsSuccess', false);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_HouseholdSummaryService', 'handleFullMatchScenario', e.getMessage() , true);
            if (Schema.sObjectType.LOG_LogMessage__c.isAccessible() && lstLogMessages!=null && !lstLogMessages.isEmpty()) {
                LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:lstLogMessages[0].Id LIMIT 1];
                mapResponse.put('error',objLog.Name);
            }
            return mapResponse;
        }
        
                
        return mapResponse;
        
    }

    /*
    * @author       Shrikant Raut 
    * @date         04/28/2020 
    * @methodname   constructQICallData
    * @description  This methods is used to construct wrapper for QualifiedIndividual call
    * @return       SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper
    **/
    @TestVisible
    private static SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper constructQICallData(SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap, SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper, String individualId, SSP_Member__c member){
        ResponseWrapper response = new ResponseWrapper();        
        SSP_Application__c appRecord = new SSP_Application__c();      
        if(objWrap != null && detailsWrapper != null && member != null){
                individualId = individualId != null ? individualId : member.individualId__c;
                //add memberId tp membersToBeDeleted list only for the first time when dummy data is to be deleted
                if(objWrap.memberIndividualId == null || (objWrap.memberIndividualId != null && String.isBlank(objWrap.memberIndividualId))){
                    mciWrap.membersToBeDeleted.add(objWrap.sRecordId);
                    String selectedRole = SSP_Utility.getSelectedRole();
                    /** #377137 */
                    List<SSP_Member__c> memberList = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c'}, 
                    new Set<String>{'Contact__c','Non_Citizen_Verification_Flag__c',
                    'PhysicalAddressLine1__c','PhysicalAddressLine2__c','PhysicalCity__c','PhysicalCountyCode__c','PhysicalStateCode__c','PhysicalCountryCode__c','PhysicalZipCode4__c','PhysicalZipCode5__c',
                    'MailingAddressLine1__c','MailingAddressLine2__c','MailingCity__c','MailingCountyCode__c','MailingStateCode__c','MailingCountryCode__c','MailingZipCode4__c','MailingZipCode5__c',
                    'IsFixedAddressToggle__c','SameAddressOfHoh__c','SameAddressInfoAsHOHToggle__c','PhysicalGeolocation__Latitude__s','PhysicalGeolocation__Longitude__s',
                    'MailingGeolocation__Latitude__s','MailingGeolocation__Longitude__s',
                    'Email__c','PrimaryPhoneNumber__c','PrimaryPhoneExtension__c','SecondaryPhoneNumber__c','SecondaryPhoneExtension__c','PrimaryPhoneTypeCode__c','PreferredSpokenLanguageCode__c',
                    'PreferredWrittenLanguageCode__c','IsPrimaryTextPreferred__c','PreferredNotificationMethodCode__c'}, 
                    new Map<String, String>{'Id'=>objWrap.sRecordId });
                    if(memberList != null && !memberList.isEmpty() && String.isNotBlank(memberList[0].Contact__c)){
                        //set non citizen verification flag
                        member.Non_Citizen_Verification_Flag__c = memberList[0].Non_Citizen_Verification_Flag__c;
                        if(selectedRole.contains('Contact_Center') && member.Non_Citizen_Verification_Flag__c ){//#384698 start
                            member.Email__c = memberList[0].Email__c;
                            member.PrimaryPhoneNumber__c = memberList[0].PrimaryPhoneNumber__c;
                            member.PrimaryPhoneExtension__c = memberList[0].PrimaryPhoneExtension__c;
                            member.SecondaryPhoneNumber__c = memberList[0].SecondaryPhoneNumber__c;
                            member.SecondaryPhoneExtension__c = memberList[0].SecondaryPhoneExtension__c;
                            member.PrimaryPhoneTypeCode__c = memberList[0].PrimaryPhoneTypeCode__c;
                            member.PreferredSpokenLanguageCode__c = memberList[0].PreferredSpokenLanguageCode__c;
                            member.PreferredWrittenLanguageCode__c = memberList[0].PreferredWrittenLanguageCode__c;
                            member.IsPrimaryTextPreferred__c = memberList[0].IsPrimaryTextPreferred__c;
                            member.PreferredNotificationMethodCode__c = memberList[0].PreferredNotificationMethodCode__c;

                            member.PhysicalAddressLine1__c = memberList[0].PhysicalAddressLine1__c;
                            member.PhysicalAddressLine2__c = memberList[0].PhysicalAddressLine2__c;
                            member.PhysicalCity__c = memberList[0].PhysicalCity__c;
                            member.PhysicalCountyCode__c = memberList[0].PhysicalCountyCode__c;
                            member.PhysicalStateCode__c = memberList[0].PhysicalStateCode__c;
                            member.PhysicalCountryCode__c = memberList[0].PhysicalCountryCode__c;
                            member.PhysicalZipCode4__c = memberList[0].PhysicalZipCode4__c;
                            member.PhysicalZipCode5__c = memberList[0].PhysicalZipCode5__c;
                            member.PhysicalGeolocation__Latitude__s = memberList[0].PhysicalGeolocation__Latitude__s;
                            member.PhysicalGeolocation__Longitude__s = memberList[0].PhysicalGeolocation__Longitude__s;
                            
                            member.MailingAddressLine1__c = memberList[0].MailingAddressLine1__c;
                            member.MailingAddressLine2__c = memberList[0].MailingAddressLine2__c;
                            member.MailingCity__c = memberList[0].MailingCity__c;
                            member.MailingCountyCode__c = memberList[0].MailingCountyCode__c;
                            member.MailingStateCode__c = memberList[0].MailingStateCode__c;
                            member.MailingCountryCode__c = memberList[0].MailingCountryCode__c;
                            member.MailingZipCode4__c = memberList[0].MailingZipCode4__c;
                            member.MailingZipCode5__c = memberList[0].MailingZipCode5__c;
                            member.MailingGeolocation__Latitude__s = memberList[0].MailingGeolocation__Latitude__s;
                            member.MailingGeolocation__Longitude__s = memberList[0].MailingGeolocation__Longitude__s;
                            
                            member.IsFixedAddressToggle__c = memberList[0].IsFixedAddressToggle__c;
                            member.SameAddressOfHoh__c = memberList[0].SameAddressOfHoh__c;
                            member.SameAddressInfoAsHOHToggle__c = memberList[0].SameAddressInfoAsHOHToggle__c;
                            //member.Non_Citizen_Verification_Flag__c = memberList[0].Non_Citizen_Verification_Flag__c;

                             List<SSP_ApplicationIndividual__c> listAppIndRecord = (List<SSP_ApplicationIndividual__c>) SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c', 'operator'=>'AND'}, 
                                                                                                                        new Set<String>{'Id','SSP_Application__c','SSP_Application__r.SectionStatus__c'},
                                                                                                                        new Map<String, String>{'limit'=>'1','SSP_Member__c'=>objWrap.sRecordId,'SSP_Application__r.Status__c'=>'UN'});

                            if(listAppIndRecord != null && listAppIndRecord.size()>0){
                                appRecord.Id = listAppIndRecord[0].SSP_Application__c;
                                string statusValue = String.valueOf(listAppIndRecord[0].SSP_Application__r.SectionStatus__c);
                                statusValue = statusValue.removeEnd('}}') +',"Contact_Information":"COMPLETED"}}';
                                appRecord.SectionStatus__c =statusValue;
                            }
                        }//#384698 End
                        
                        
                        Contact con = new Contact(Id = memberList[0].Contact__c);


                        /** 10-13 */
                        List<Contact> extConList = [SELECT Id FROM Contact WHERE IndividualId__c = :individualId LIMIT 1];
                        List<Contact> conListToUpdate = new List<Contact>();
                        if(mciWrap.createdContact != null && mciWrap.createdContact.containsKey(individualId)){
                            mciWrap.deleteContact = true;                                                        
                            if(extConList != null && !extConList.isEmpty() && extConList[0].id != mciWrap.createdContact.get(individualId)){
                                extConList[0].IndividualId__c = '';
                                conListToUpdate.add(extConList[0]);
                                conListToUpdate.add( new Contact(id= mciWrap.createdContact.get(individualId) , IndividualId__c =individualId));
                           
                            }
                            else{
                                Contact matchCon = new Contact(Id = mciWrap.createdContact.get(individualId));
                                matchCon.IndividualId__c =  individualId;
                                conListToUpdate.add(matchCon);
                            }
                        }
                        else{
                            if(extConList != null && !extConList.isEmpty()){
                                extConList[0].IndividualId__c = '';
                                conListToUpdate.add(extConList[0]);
                            }
                            con.IndividualId__c = individualId;
                            conListToUpdate.add(con);
                            
                        }

                        if(!conListToUpdate.isEmpty()){
                            update conListToUpdate;
                             createConMapping( new SET<Integer> {Integer.valueOf(individualId)} ,conListToUpdate );
                        }
                                                                     
                       
                    }    
                    /** */                                                    
                }
                mciWrap.hohIndividualId = individualId;
                detailsWrapper.triggerQualifiedCall = objWrap.memberIndividualId == null || (objWrap.memberIndividualId != null && objWrap.memberIndividualId != individualId);
                detailsWrapper.applicationIndividual.isHOHDetailsCompleted__c = true;
                detailsWrapper.applicationIndividual.MemberProgramsApplied__c = mciWrap.appliedProgramList;
                detailsWrapper.responseMemberData = member;    
                detailsWrapper.applicationData = appRecord;//#384678

                
        }
        
        return detailsWrapper;
    }

    /*
    * @author       Shrikant Raut 
    * @date         04/28/2020 
    * @methodname   constructMemberData
    * @description  This methods is used to construct contact and member records for creating member.
    * @return       SSP_ApplicationIndividual__c
    **/
   @TestVisible
    private static ResponseWrapper constructMemberData(SSP_Member__c objIEESMemberData){
        ResponseWrapper response = new ResponseWrapper();
        if(objIEESMemberData != null ){
            String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Citizen').getRecordTypeId();
            String contRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Citizen').getRecordTypeId();
            List<String> name= getTrimFirstAndLastName(objIEESMemberData.Firstname__c ,objIEESMemberData.lastname__c );
            if(null!=name && name.size()>0){
                Account objAcc = new Account();
                objAcc.recordtypeId = recordTypeId;
                objAcc.Name =name[0].trim() + ' ' + name[1].trim(); 
                response.account = objAcc;
                
                Contact objCon = new Contact();
                objCon.recordtypeId = contRecordTypeId;
                objCon.Firstname = name[0].trim();  
                objCon.Lastname = name[1].trim();          
                objCon.IndividualId__c = objIEESMemberData.IndividualId__c.trim() ;                        
                response.contact = objCon;
            }
        }
        return response;
    }

    /*
    * @author       Shrikant Raut 
    * @date         04/28/2020 
    * @methodname   parseApplicationDetails
    * @description  This methods is used to parse application related flags (isApplicationBlocked, blockedIndividuals, cannotApplyModal, BlockedCaseNumber__c) from response Application Individual
    * @return       SSP_ApplicationIndividual__c
    **/
    @TestVisible
    private static SSP_ApplicationIndividual__c parseApplicationDetails(SSP_ApplicationIndividual__c objAppIndiv, SSP_Member__c objUpsertMember){
        if(objAppIndiv != null ){
            if(objAppIndiv.isApplicationBlocked__c != null && objAppIndiv.isApplicationBlocked__c){
                mciWrap.isApplicationBlocked=true; 
                mciWrap.cannotApplyModal = true;
                
                mciWrap.blockedIndividuals = mciWrap.blockedIndividuals+ objUpsertMember.FirstName__c + ' ' +objUpsertMember.LastName__c;
                objAppIndiv.isHOHDetailsCompleted__c = false;
                mciWrap.applicationDetail.Status__c=SSP_GlobalConstants.STATUS_INACTIVE;    
                
            } 
            
            if(objAppIndiv.BlockedCaseNumber__c != null && mciWrap.mergeCaseNumbers!= objAppIndiv.BlockedCaseNumber__c){
                mciWrap.mergeCaseNumbers = mciWrap.mergeCaseNumbers+ objAppIndiv.BlockedCaseNumber__c ;
            }
        }
        return objAppIndiv;
    }
	
    @TestVisible
    private static void updateOwner(List<Account> lstAccountToInsert, List<Contact> lstContactsToInsert){
        try{
            List<Account> actsToUpdate = new List<Account>();
            List<Contact> consToUpdate = new List<Contact>();
            List<user> lstUser = SSP_SharingBypassFetcher.getUserList('System Auto Process');
            if(!lstAccountToInsert.isEmpty() && !lstUser.isEmpty()){
                for(Account objAccount : lstAccountToInsert){
                    if(objAccount != null && String.isNotBlank(objAccount.Id)){
                        objAccount.ownerId = lstUser[0].Id;
                        actsToUpdate.add(objAccount);
                    }

                }
                if(!actsToUpdate.isEmpty()){
                    update actsToUpdate;
                }
            }
            if(!lstContactsToInsert.isEmpty() && !lstUser.isEmpty()){
                for(Contact objContact : lstContactsToInsert){
                    if(objContact != null && String.isNotBlank(objContact.Id)){
                        objContact.ownerId = lstUser[0].Id;
                        consToUpdate.add(objContact);
                    }
                }
                if(!consToUpdate.isEmpty()){
                    update consToUpdate;
                }
            }
        }
        catch(Exception ex){}
    }
    
    public static Map<String,Object> handleNoMatchScenario(SSP_MCIMergedServiceResponeWrapper responseData, SSP_Member__c objMember,SSP_HouseholdMembersSummaryCtrl.MemberDetailsWrapper objWrap,Map<String,Object> mapHouseholdData, Boolean sMode){
        List<String> membersToDelete = new List<String>();//Added by Shrikant - CD2
        List<SSP_Member__c> lstMembersToUpdate = new List<SSP_Member__c>();
        Boolean createAppIndivRec = false;
        Map<String,Object> mapResponse = new Map<String,Object>();
        SSP_ApplicationIndividual__c objAppIndiv = new SSP_ApplicationIndividual__c();
        List<Account> lstAccountToInsert = new List<Account>();
        List<Contact> lstContactsToInsert = new List<Contact>();
        List<SSP_ApplicationIndividual__c> lstAppIndividuals = new List<SSP_ApplicationIndividual__c>();
        List<SSP_Member__c> lstmembers = new List<SSP_Member__c>();
        Map<Id,SSP_ApplicationIndividual__c> appIndivData = new  Map<Id,SSP_ApplicationIndividual__c>();
        SSP_Application__c applicationDetail = new SSP_Application__c();
        Account objAcc = new Account();
        Contact objCon = new Contact();
      try{   
        List<SSP_Application__c> lstApps = (List<SSP_Application__c>)mapHouseholdData.get('lstApps');  
        List<SSP_ApplicationIndividual__c>  appIndividualsLst = (List<SSP_ApplicationIndividual__c>)mapHouseholdData.get('lstAppIndividuals');
        
        if(null!=appIndividualsLst && appIndividualsLst.size()>0 ){
            for(SSP_ApplicationIndividual__c appIndvs:appIndividualsLst)
                appIndivData.put(appIndvs.SSP_Member__c,appIndvs); 
        }
        
        if(null!=lstApps && lstApps.size()>0 ){          
            applicationDetail = lstApps[0];
        }
    
        //get data filled by the user in UI and update that to data received.            
        String ObjMemberId= null!=objMember.id?objMember.id:null;
       
        if(  null!=responseData &&   null!=responseData.IndividualId){
           // added as part of multiple Individual Id changes 
         
            // Check if member already present for this individual Id 
            List<SSP_Member__C> lstMember =  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'IndividualId__c'}, 
                                                                                SSP_GlobalConstants.SSP_MEMBER_FIELDS_HH_SUMMARY, 
                                                                                new Map<String, String>{'IndividualId__c'=> responseData.IndividualId}); 
            if(null!=lstMember && lstMember.size()>0){  
               responseData.lstOfSSPMembers[0].id=lstMember[0].id;
                if(null==appIndivData.get(lstMember[0].id)){
                    createAppIndivRec=true; //create New Application Individual Record
                }

            }    

        } 
        SSP_Member__c paramMember = objMember;
        if(null!=responseData && null!=responseData.lstOfSSPMembers && responseData.lstOfSSPMembers.size()>0 ){  
            //objMember = responseData.lstOfSSPMembers[0];
            objMember= saveValueEnteredFromUser(objMember,responseData.lstOfSSPMembers[0]);
            objMember.SuffixCode__c=paramMember.SuffixCode__c;
        }    
       objMember.id = objMember.id==null ? ObjMemberId : objMember.id ;
        
        if(null!=responseData && null!=responseData.lstOfApplicationIndividuals && responseData.lstOfApplicationIndividuals.size()>0 ){
            objAppIndiv =responseData.lstOfApplicationIndividuals[0];
        }    

        if (objMember.id == null){

            String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Citizen').getRecordTypeId();
            String conRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Citizen').getRecordTypeId();
            
            List<String> names =getTrimFirstAndLastName(objMember.FirstName__c ,objMember.LastName__c);           
            if(names!=null && names.size()>0){
                objAcc.recordtypeId = recordTypeId;
                objAcc.Name =names[0].trim() + ' ' + names[1].trim();            
                lstAccountToInsert.add(objAcc);               
                objCon.recordtypeId = conRecordTypeId;
                objCon.FirstName = names[0].trim();
                objCon.LastName= names[1].trim();          
                if(null!=responseData && null!=responseData.IndividualId)
                    objCon.IndividualId__c = responseData.IndividualId;                
                lstContactsToInsert.add(objCon);
            }
            String sContactId = [Select id,Contactid from User where id=: userinfo.getUserId()].ContactId;
            List<String> lstIndividualId = new  List<String>();
            List<Contact> lstContactsToUpdate = new  List<Contact>();
            for(Contact objContact : lstContactsToInsert){
                IF(objContact.IndividualId__c != NULL){
                    lstIndividualId.add(objContact.IndividualId__c);
                }
            }
            if(!lstIndividualId.isEmpty()){
            lstContactsToUpdate = [SELECT Id,IndividualId__c FROM Contact WHERE IndividualId__c IN :lstIndividualId];
            }
            for(Contact objContactToUpdate :lstContactsToUpdate){
                objContactToUpdate.IndividualId__c = null;
            }
            if(!lstContactsToUpdate.isEmpty()){
                UPDATE lstContactsToUpdate;
            }
            
            Map<String,object> mapRestResult = SSP_ProgramSelectionService.invokeAccountCreationService(lstAccountToInsert,lstContactsToInsert,sContactId);
            
            if(null!=mapRestResult && mapRestResult.size()>0) {
                lstAccountToInsert = (List<Account>)mapRestResult.get('lstAccounts');
                lstContactsToInsert = (List<Contact>)mapRestResult.get('lstContacts'); 
            }
            else {
                mapResponse.put('error','Account Creation Unsuccessfull');
                mapResponse.put('bIsSuccess', false);
                return mapResponse;
            }
            List<user> lstUser = SSP_SharingBypassFetcher.getUserList('System Auto Process');
            if(!lstAccountToInsert.isEmpty() && !lstUser.isEmpty()){
                for(Account objAccount : lstAccountToInsert){
                    objAccount.ownerId = lstUser[0].Id;
                }
                update lstAccountToInsert;
            }
            if(!lstContactsToInsert.isEmpty() && !lstUser.isEmpty()){
                for(Contact objContact : lstContactsToInsert){
                    objContact.ownerId = lstUser[0].Id;
                }
                update lstContactsToInsert;
            }
            if (lstContactsToInsert != null && !lstContactsToInsert.isEmpty()){
                objMember.Contact__c = lstContactsToInsert[0].id;                
            }
            
            createAppIndivRec=true;
        }
        else {
            if(!createAppIndivRec){
                 objAppIndiv = appIndivData.get(objWrap.sRecordId);
            }           
            if(responseData != null && 	responseData.IndividualId != null){
                List<Contact> lstContactsToUpdate =  new List<Contact>();
                lstContactsToUpdate = [SELECT Id,IndividualId__c from Contact where IndividualId__c=:responseData.IndividualId];
                for(Contact objContact : lstContactsToUpdate){
                    objContact.IndividualId__c = null;
                }
                if(!lstContactsToUpdate.isEmpty()){
                    UPDATE lstContactsToUpdate;
                }
            }
            updateContactInfo(mapHouseholdData, objMember, (responseData != null && responseData.IndividualId != null) ? responseData.IndividualId : null);//added by Shrikant to copy details to contact
           
        }
        if(createAppIndivRec) {
            objAppIndiv.Id = null;//Added by Shrikant
            objAppIndiv.SSP_Application__c = lstApps[0].id;
            if(null!=applicationDetail.SectionStatus__C){
                for(String section:applicationDetail.SectionStatus__C.split(','))
                    if(section.contains( SSP_GlobalConstants.SSP_APP_HHMembersSummary)&& section.contains(SSP_GlobalConstants.SECTION_STATUS_Complete)){
                        objAppIndiv.MemberStatus__c=SSP_GlobalConstants.MEMBER_STATUS_New; 
                    }
            }
            
            if(null!=sMode && sMode==true){
                objAppIndiv.MemberStatus__c=SSP_GlobalConstants.MEMBER_STATUS_New;
            }
        }
        if(null!=responseData ){
            if(null!=responseData.MatchStatus && responseData.MatchStatus!=''){
                objMember.MatchType__c=responseData.MatchStatus;
            }
            if(null!=responseData.IndividualId){
                objMember.IndividualId__c = responseData.IndividualId;
            }
        }
        lstmembers.add(objMember);
        upsert lstmembers;
         if(responseData != null && responseData.IndividualId != null){
             createConMapping( new SET<Integer> {(Integer.valueOf(responseData.IndividualId))} ,null);
         }
         
            if (objAppIndiv.id == null){
                objAppIndiv.SSP_Member__c = objMember.Id;
            }
            
            objAppIndiv.MemberProgramsApplied__c = buildProgramsAPIValueString(objWrap.sProgramsRequested);        
            objAppIndiv.isHOHDetailsCompleted__c=true;           //Added this to show start button when record is loaded. make this changes for Full match and other scenarios too
            lstAppIndividuals.add(objAppIndiv);
            // ESAPI.accessController().upsertAsUser(lstAppIndividuals, SSP_Utility.getFieldsNamesList (lstAppIndividuals));
            upsert lstAppIndividuals;  
            // Below Condition is use to stamp MAGI/Non-MAGI for newly added Member satisfying ABD check.
            if(objWrap.sApplicationId != null) {
                SSP_MemberService.checkMembersAgeBlindDisabledInfo(objWrap.sApplicationId, null);
            }
            createAccountContactRelation(lstApps[0].Id ,false);
        }        
        catch(Exception e){
           mapResponse.put('bIsSuccess', false);
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_HouseholdSummaryService', 'handleNoMatchScenario', e.getMessage() , true);
            if (Schema.sObjectType.LOG_LogMessage__c.isAccessible() && lstLogMessages!=null && !lstLogMessages.isEmpty()) {
                LOG_LogMessage__c objLog = [Select ID, Name FROM LOG_LogMessage__c Where ID =:lstLogMessages[0].Id LIMIT 1];
                mapResponse.put('error',objLog.Name);
            }
            return mapResponse;
        }        
        mapResponse.put('selectedRole', SSP_Utility.getSelectedRole());
        mapResponse.put('bIsSuccess',true);
        mapResponse.put('Member',objMember);
        mapResponse.put('sAppIndividual',lstAppIndividuals[0]);
	    mapResponse.put('validAbsentParent',checkAbsentParentRule(lstAppIndividuals));

        return mapResponse;
    }
    
    
    
    public static List<LOG_LogMessage__c> deleteNavFlowRecordForMember(Id sspMemberId , Id applicationId ){
        List<LOG_LogMessage__c> lstofLogs = new List<LOG_LogMessage__c>();
        try{
            List<NavFlowStatus__c> navFlowrec= [Select id, member__r.firstname__c, NavFlowName__c from NavFlowStatus__c where member__c = :sspMemberId and SSPApplication__c= :applicationId];
            if(null!=navFlowrec){
                delete navFlowrec;
            }
        }
        catch(Exception e){
            LOG_LogMessage__c lstLogMessag = LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,null,'SSP_HouseHoldSummaryService','SSP_HouseHoldSummaryService','deleteNavFlowRecordForMember',
                                                                              String.valueof(SSP_InterfaceConstants.SSPINT_ERRORCAUSE+e.getCause() +SSP_InterfaceConstants.SSPINT_ERRORMSG+e.getMessage()+SSP_InterfaceConstants.SSPINT_ERRORTRACE+e.getStackTraceString()+SSP_InterfaceConstants.SSPINT_ERRORLINENO+e.getLineNumber()),
                                                                              null,null,null,null,null, false);            
            lstofLogs.add(lstLogMessag);
            return lstofLogs;
        }
        return null;
    }
    
    public static List<String> getTrimFirstAndLastName(String firstName , String lastName){
        if(null!=firstName){
            if(firstName.length() >= 40 ){
                firstName = firstName.substring(0, 40).trim(); 
            }
            else firstName= firstName.trim();
        }
        else  firstName=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        
        if(null!=lastName){
            if(lastName.length() >= 80 ){
                lastName =lastName.substring(0, 80).trim(); 
            }
            else lastName = lastName.trim();
        }
        else  lastName=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        
        return new List<String> {firstName, lastName};
            }
    
    public static void  updateApplicationIndividualWithCount(List<SSP_ApplicationIndividual__c> listIndividuals , Boolean updatecount){
        try{
            for(SSP_ApplicationIndividual__c individualsToUpdate : listIndividuals)  {   
                if(updatecount && null!=individualsToUpdate.MCIcount__c){
                    individualsToUpdate.MCIcount__c = individualsToUpdate.MCIcount__c+1;
                }
                else if(updatecount && null==individualsToUpdate.MCIcount__c) {
                    individualsToUpdate.MCIcount__c=2;
                }
            }
            if(updatecount && null!=listIndividuals && listIndividuals.size()>0){
                upsert listIndividuals; 
            }
            // ESAPI.accessController().upsertAsUser(listIndividuals, SSP_Utility.getFieldsNamesList (listIndividuals));
        }
        catch(Exception e ){
            List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(e, 'SSP_HouseholdSummaryService', 'updateApplicationIndividualWithCount', e.getMessage() , true);
        }
        
    }
    
    @TestVisible
    private static Boolean deleteRecords(List<String> memberIdList){
        Boolean result= true;
        List<SSP_Member__c> membersToBeDeleted = new List<SSP_Member__c>();
        try{
            if(memberIdList != null && !memberIdList.isEmpty()){
                if(mciWrap.deleteContact){
                    List<Contact> contactsToBeDeleted = new List<Contact>();    
                    for(SSP_Member__c member :  SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','IN'=>'Id'}, new Set<String>{'Contact__c'}, 
                        new Map<String, String>{'Id'=> String.join(memberIdList, ',')})){
                        if(member!=null && member.Contact__c != null){                            
                            Contact con = new Contact(Id = member.Contact__c);
                            contactsToBeDeleted.add(con);
                        }                
                    } 
                    if(!contactsToBeDeleted.isEmpty()){
                        delete contactsToBeDeleted;                
                    }
                }
                else{
                    /** #377137 */
                    for(String memId : memberIdList){
                        if(String.isNotBlank(memId)){
                            membersToBeDeleted.add(new SSP_Member__c(Id = memId));
                        }
                    }
                    if(!membersToBeDeleted.isEmpty()){
                        delete membersToBeDeleted;
                    }
                    /** */
                }
            }
        }
        catch(Exception ex){
            result= false;
            
        }
        return result;

    }
	
    @TestVisible
    private static void triggerQualifiedCall(String applicationId, String individualId, SSP_ProgramSelectionService.QualifiedIndividualDetailWrapper detailsWrapper){
        try{
            if(applicationId != null && applicationId != '' && individualId != null && applicationId != ''){
                String programsApplied = SSP_ApplicationSelector.queryApplicationDataById(applicationId, new List<String>{'ProgramsApplied__c'}).ProgramsApplied__c;
                SSP_ProgramSelectionService.invokeQualifiedIndividualCall(new Map<String, String>{
                    SSP_GlobalConstants.SSP_PROGRAMS => programsApplied,
                    SSP_GlobalConstants.SSP_INDV_ID => individualId, 
                    SSP_GlobalConstants.SSP_APP_ID => applicationId,
                    'detailsWrapper' => JSON.serialize(detailsWrapper)
                }, null);	
            }
        }
        catch(Exception ex){
            
        }	
        
    }

    private static Map<String, SSP_Member__C> constructExtMemDetailMap(List<SSP_Member__c> existingMemberList, List<SSP_Member__c> appSpecificMemberList){
        Map<String, SSP_Member__C> memberMap = new Map<String, SSP_Member__C>();
        Map<ID, SSP_Member__c> appSpecificIdToMemMap = new Map<ID, SSP_Member__c>();
        if(appSpecificMemberList != null && !appSpecificMemberList.isEmpty()){
            appSpecificIdToMemMap = new Map<ID, SSP_Member__c>(appSpecificMemberList);
        }
        if(existingMemberList != null && !existingMemberList.isEmpty()){
            for(SSP_Member__c mem : existingMemberList){
                if(mem.Id != null && !appSpecificIdToMemMap.containsKey(mem.Id)){
                    memberMap.put(mem.IndividualId__c, mem);
                }
            }
        }
        
        return memberMap;
    }
    @TestVisible
    private static Boolean isDummyMember(SSP_Member__c memberObj){
        return (memberObj != null && 
                memberObj.Contact__c != null && 
                memberObj.Contact__r.FirstName != null && 
                memberObj.Contact__r.FirstName.equals(SSP_GlobalConstants.DUMMY_KEY) && 
                memberObj.Contact__r.LastName != null && 
                memberObj.Contact__r.LastName.equals(SSP_GlobalConstants.DUMMY_KEY));
    }
    
    /*
    * @author       Shrikant Raut 
    * @date         04/18/2020 
    * @methodname   updateContactInfo
    * @description  This methods is used to update individualId and details to respective hoh contact
    * @return       void
    **/
    @testVisible
    private static void updateContactInfo(Map<String,Object> mapHouseholdData, SSP_Member__c memberObj, String individualId){  
        String contactId;        
        try{
            if(mapHouseholdData != null && !mapHouseholdData.isEmpty() && mapHouseholdData.containsKey('lstMembers')){
                List<SSP_Member__c> lstExistingMembers = (List<SSP_Member__c>)mapHouseholdData.get('lstMembers');
                if(lstExistingMembers != null && !lstExistingMembers.isEmpty()){
                    for(SSP_Member__c mem : lstExistingMembers){
                        if(mem.Id.equals(memberObj.Id)){
                            contactId = mem.Contact__c;
                            break;
                        }
                    }
                }
                else if(mapHouseholdData != null && !mapHouseholdData.isEmpty() && mapHouseholdData.containsKey('memberObj')){
                    //query contact of memberObj
                    memberObj = (SSP_Member__c)mapHouseholdData.get('memberObj');
                    contactId = String.valueOf(mapHouseholdData.get('contactId'));
                    individualId = String.valueOf(mapHouseholdData.get('individualId'));
                }
                
                if(contactId != null && contactId != ''){
                    Contact con = new Contact();
                    List<Contact> contactList = (List<Contact>)SSP_ContactSelector.queryContactData(new Map<String, String>{'objectName'=>'Contact', 'operator'=>'AND'}, 
                                                                                                    new Set<String>{'Id','FirstName', 'AccountId', 'Account.Name', 'MiddleName', 'LastName', 'GenderCode__c', 'BirthDate','IndividualId__c'}, 
                                                                                                    new Map<String, String>{'limit'=>'1','Id'=>contactId});
                    Boolean copyMemberToContact =   contactList[0].FirstName.equals(SSP_GlobalConstants.DUMMY_KEY) && contactList[0].LastName.equals(SSP_GlobalConstants.DUMMY_KEY);                                                                                              
                    con.FirstName = (copyMemberToContact && (memberObj.FirstName__c != null && memberObj.FirstName__c != '')) ? getTrimFirstAndLastName(memberObj.FirstName__c, null)[0] : contactList[0].FirstName;
                    con.MiddleName = (copyMemberToContact && (memberObj.MiddleInitial__c != null && memberObj.MiddleInitial__c != '')) ? memberObj.MiddleInitial__c : contactList[0].MiddleName;
                    con.LastName = (copyMemberToContact && (memberObj.LastName__c != null && memberObj.LastName__c != '')) ? getTrimFirstAndLastName(memberObj.FirstName__c, memberObj.LastName__c)[1] : contactList[0].LastName;
                    con.GenderCode__c = (copyMemberToContact && (memberObj.GenderCode__c != null && memberObj.GenderCode__c != '')) ? memberObj.GenderCode__c : contactList[0].GenderCode__c;
                    con.BirthDate = (copyMemberToContact && memberObj.BirthDate__c != null) ? memberObj.BirthDate__c : contactList[0].BirthDate;
                    con.IndividualId__c = (individualId != null && individualId != '' ) ? individualId : contactList[0].IndividualId__c;
                    con.Id = contactId;
                    //ESAPI.accessController().updateAsUser(new Map<ID, Contact>(new List<Contact>{con}), SSP_Utility.getFieldsNamesList (new List<Contact>{con}));
                    SSP_GenericDMLHelper.updateRecords(new List<Contact>{con}, new List<String>{'FirstName','MiddleName','LastName','GenderCode__c','BirthDate','IndividualId__c'});//Perf fix - Keshav/Sajan
                    if(copyMemberToContact && contactList[0].AccountId != null){
                        List<Account> actList = new List<Account>{new Account(Id = contactList[0].AccountId, Name = 'Contact Account for '+con.FirstName+' '+con.LastName)};
                            //ESAPI.accessController().updateAsUser(new Map<ID, Account>(actList), SSP_Utility.getFieldsNamesList (actList));
                            SSP_GenericDMLHelper.updateRecords(actList, new List<String>{'Name'});//Perf fix - Keshav/Sajan
                    }      
                    
                }
            }
        }
        catch(Exception ex){
            
        }
    }
    
    public static boolean checkAbsentParentRule(List<SSP_ApplicationIndividual__c> appIndiv){
        ContextData ctxData = new ContextData();
        ctxData.MemberId=appIndiv[0].SSP_Member__c;
        ctxData.ApplicationId = appIndiv[0].SSP_Application__c ;
        return new SSP_AbsentParentQueueingRule().isRequired(null,ctxData);
    }
    public static SSP_Member__c saveValueEnteredFromUser(SSP_Member__c objMember , SSP_Member__c resposeData){ 
        String SSN_Reason=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        String SSN =SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        Date deseasedDate = objMember.DeathDate__c!=null ?objMember.DeathDate__c : null;
        if(objMember.SSN__c==null){
            SSN_Reason =objMember.NoReasonSSNCode__c!=null ? objMember.NoReasonSSNCode__c : SSN_Reason;
        }
        else {
            SSN = objMember.SSN__c;
        }
        
        resposeData.IsIntendToResideToggle__c = null!=resposeData.IsIntendToResideToggle__c?resposeData.IsIntendToResideToggle__c:objMember.IsIntendToResideToggle__c;
        resposeData.IsMilitaryMemberToggle__c = null!=resposeData.IsMilitaryMemberToggle__c ?resposeData.IsMilitaryMemberToggle__c:objMember.IsMilitaryMemberToggle__c;
        resposeData.RaceCode__c = null!= resposeData.RaceCode__c? resposeData.RaceCode__c:objMember.RaceCode__c;
        resposeData.NationalityCode__c = null!=resposeData.NationalityCode__c ? resposeData.NationalityCode__c:objMember.NationalityCode__c;
        resposeData.IsHispanicLatinoSpanishToggle__c= null!=resposeData.IsHispanicLatinoSpanishToggle__c? resposeData.IsHispanicLatinoSpanishToggle__c:objMember.IsHispanicLatinoSpanishToggle__c;
        resposeData.SpecialNeedIndicatorToggle__c = null!=resposeData.SpecialNeedIndicatorToggle__c?resposeData.SpecialNeedIndicatorToggle__c:objMember.SpecialNeedIndicatorToggle__c;
        resposeData.EthnicityCode__c = null!=resposeData.EthnicityCode__c ? resposeData.EthnicityCode__c:objMember.EthnicityCode__c;
        resposeData.IsUSCitizenToggle__c = (resposeData.IsUSCitizenValidated__c != null && resposeData.IsUSCitizenValidated__c  && resposeData.IsUSCitizenToggle__c != null) ? resposeData.IsUSCitizenToggle__c : objMember.IsUSCitizenToggle__c;
        resposeData.BirthDate__c = (resposeData.IsDateOfBirthValidated__c != null && resposeData.IsDateOfBirthValidated__c  && resposeData.BirthDate__c != null) ? resposeData.BirthDate__c : objMember.BirthDate__c;
        resposeData.Alias_First_Name__c = objMember.Alias_First_Name__c;
        resposeData.Alias_Last_Name__c = objMember.Alias_Last_Name__c; 
        resposeData.Identify_verification_method__c = objMember.Identify_verification_method__c; 
        resposeData.Reference_Number__c = objMember.Reference_Number__c; 
        if(null==resposeData.SSN__c && SSN!='' ){
            resposeData.SSN__c=SSN;
        }
        if(null==resposeData.SSN__c && SSN_Reason!='' ){
            resposeData.NoReasonSSNCode__c = SSN_Reason;
        }
        if(null!=deseasedDate && null!=resposeData.IsDateOfDeathValidated__c && !resposeData.IsDateOfDeathValidated__c){
            resposeData.DeathDate__c = null!=resposeData.DeathDate__c?resposeData.DeathDate__c : deseasedDate;
        }
        
        return resposeData;    
    }

    //added by Prasanth
    public static Boolean checkMCIApplicable(String memberId)
    {
        //SELECT Id, IndividualId__c FROM SSP_Member__c where IndividualId__c='';// we can get memberid from here
        Boolean status=false;
        
        String selectedrole= SSP_Utility.getSelectedRole();
        /*String IdentityVerificationMethod=SSP_RIDPServices.getData(memberId).mapResponse.containsKey('IdentityVerificationMethod') ? String.valueOf(SSP_RIDPServices.getData(memberId).mapResponse.get('IdentityVerificationMethod')):null;*/
        Boolean nonCitizenVerificationFlag = (Boolean)SSP_RIDPServices.getData(memberId).mapResponse.get('NonCitizenVerificationFlag');
        String IdentityVerificationMethod=valueToStringOrEmpty(SSP_RIDPServices.getData(memberId).mapResponse,'IdentityVerificationMethod');
        
        Id userId = userinfo.getUserId();
        User userDetails =[SELECT Id, Name, Email, Profile.Name, ImpersonatedIndividualId__c FROM User where Id=:userId ];
        
        String profile=userDetails.Profile.Name;
        
        
        if(selectedrole=='Mail_Center_Supervisor' || selectedrole=='Mail_Center_Worker' || profile=='RE Citizen Profile'
            // 397543, Remove Identity Document Upload for MWMA Users
            || SSP_GlobalConstants.waiverRoles.contains(selectedrole)
        )        
        {
            status=true;
        }
        if(nonCitizenVerificationFlag!=null && nonCitizenVerificationFlag) // added null check : vishakha
        {
            status=true;
        }
        if(userDetails.ImpersonatedIndividualId__c!=null)
        {
            status=true;
        }
        if(MCIcalloutstatuscheck)
        {
            status=MCIcalloutstatuscheck;
        }
        
        return status;
        
    }
    // added by Prasanth
    public static String valueToStringOrEmpty(Map<String, Object> mp, String k) {
        Object value = mp.get(k);
        return value == null ? '' : value.toString();
    }
    /***************************************************************************************************
* @author       Chandra Shekhar
* @date         06/22/2020
* @methodname   getRequriedProgramHoh
* @description  this method returns the final list of program that HOH has to create application for
* @return       boolean
*****************************************************************************************************/
    public static List<String> getRequriedProgramHoh(List<String> requestedProgram, List<String> programFromCallout){
        
        List<String> programLeft=new List<String>();        
        Set<String> requestedProgramsSet=new Set<String>();        
       try{
           if(requestedProgram!=null && requestedProgram.size()>0 && programFromCallout!=null && programFromCallout.size()>0 ){
               requestedProgramsSet.addAll(requestedProgram);
                for(String programCallout:programFromCallout){              
                    if(requestedProgramsSet.contains(programCallout)){
                        requestedProgramsSet.remove(programCallout);
                        programRemoved=true;
                    }
                }

           }                      
        }
        catch(Exception ex){} 
        programLeft.addAll(requestedProgramsSet);        
        return programLeft;
    }
    
    //Added by Shrikant
    public class MCIDataWrapper{
        public Map<String,ID> createdContact;// = SSP_Utility.getCreatedContact(indivIds);
        public Boolean  isNonCitizenUser = false; //10-13
        public String contactId; //10-13   
        public Set<Id> conIdForAppReq = new Set<Id>(); //10-13             
        public Map<Decimal,SSP_Member__C> allMembersWithID;// = SSP_Utility.getExistingMemberData(indivIds);
        public String blockedCaseNumber ;
        public String blockedIndividuals=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        public String mergeCaseNumbers=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;   
        public Boolean isApplicationBlocked=false ;
        public Boolean cannotApplyModal = false;
        public List<String> membersToBeDeleted = new List<String>();
        public String hohIndividualId;
        public String appliedProgramList=SSP_GlobalConstants.DEFAULT_EMPTY_STRING;
        public SSP_Application__c applicationDetail = new SSP_Application__c();
        public Boolean deleteContact = false; 
    }

    // Added by Shrikant
    public class ResponseWrapper{
        public Account account ;
        public Contact contact;
        public SSP_Member__c member;   
        public SSP_ApplicationIndividual__c applicationIndividual;
        public SSP_Application__c application;        
    }
    /*
	* method 		: checkExistingPermission
	* @description  : This method checks the existing Permission of Auth Reps/Assister
	* @author 		: Ashwin Kasture
	* @return 		: Map<String, Object>
	* */
    @AuraEnabled
    public static Map<String, Object> checkExistingPermission(String sCaseNumber, String sProgramApplied, String sRoleType, String sApplicationId) {
    	Map<String, Object> objResponse = new Map<String, Object>();
        Set<Boolean> setHasPer = new Set<Boolean>();
        String sExistPrgm = '';
        String sDCDataId = '';
        Boolean hasPer = false;
        List<User> userList = SSP_UserSelector.queryUserData (
                                                            new Map<String, String>{'objectName'=>'User','operator'=>'AND'},
                                                            new Set<String>{'Id','ContactId','Contact.FirstName','Contact.LastName'},
                                                            new Map<String, String>{'limit'=>'1','Id'=> UserInfo.getuserId()}
        );
        
        String sCurrentRole = sRoleType == SSP_GlobalConstants.RoleType_Assister ? SSP_GlobalConstants.RoleType_Assister: SSP_GlobalConstants.RoleType_AuthRep;
        List<AccountContactRelation> lstCurrentUserACR = SSP_SharingBypassFetcher.fetchRecords (
                                                            new Map<String, String>{'objectName'=>'AccountContactRelation','operator'=>'AND','DCContactId__c'=>'!='}, 
                                                            new Set<String>{'Id','DCContactId__c','Account.DCDataId__c','Roles'}, 
                                                            new Map<String, String>{'ContactId'=> userList[0].ContactId, 'Account.RecordType.DeveloperName'=>'Resource_Engine','DCContactId__c'=>'#null#'}
                                                          );
        sDCDataId = lstCurrentUserACR != null && lstCurrentUserACR.size()>0 && lstCurrentUserACR[0].DCContactId__c != null ? String.valueOf(lstCurrentUserACR[0].DCContactId__c) : '';
        
        Map<String, Object> objRevSSPDCResp = SSP_AuthRepAccessRequestService.reverseSSPDCService(null, sCaseNumber, sCurrentRole);
        
        SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper objWrapperData = (SSP_AuthRepAccessRequestCtrl.ReverseSSPDCResponseWrapper)objRevSSPDCResp.get('reverseSSPDCDetails');
        
        if(objWrapperData != null && objWrapperData.AuthrepandAssiterClientInfo != null && !objWrapperData.AuthrepandAssiterClientInfo.isEmpty()) {
        	for(SSP_AuthRepAccessRequestCtrl.AuthRepAndAssiterClientInfoWrapper objAuthRepInfo: objWrapperData.AuthrepandAssiterClientInfo) {
                
                if(String.isNotBlank(objAuthRepInfo.CaseNumber) && String.isNotBlank(objAuthRepInfo.UserId) && objAuthRepInfo.CaseNumber.equals(sCaseNumber) && objAuthRepInfo.UserId.equals(sDCDataId)) {
                    if(sRoleType == SSP_GlobalConstants.ASSISTER_ROLE || sRoleType == SSP_GlobalConstants.AGENCY_ADMIN_ROLE){
                        hasPer=true;
                    }
                    else{
                        sExistPrgm = String.isNotBlank(objAuthRepInfo.PermissionLevelMedicaid) ?  SSP_GlobalConstants.MEDICAID+';' : '';
                        sExistPrgm += String.isNotBlank(objAuthRepInfo.PermissionLevelSNAP) ? SSP_GlobalConstants.SNAP+';' : '';
                        sExistPrgm += String.isNotBlank(objAuthRepInfo.PermissionLevelStateSupp) ? SSP_GlobalConstants.STATE+';' : '';
                        sExistPrgm += String.isNotBlank(objAuthRepInfo.PermissionLevelKIHIPP) ? SSP_GlobalConstants.KHIPP+';' : '';
                        sExistPrgm += String.isNotBlank(objAuthRepInfo.PermissionLevelKTAP) ? SSP_GlobalConstants.KTAP+';' : '';
                        sExistPrgm += String.isNotBlank(objAuthRepInfo.PermissionLevelCCAP) ? SSP_GlobalConstants.CHILDCARE+';' : '';
                    }
                }
            }
            
        } 
        
        if(objWrapperData != null && objWrapperData.CaseInfo != null && !objWrapperData.CaseInfo.isEmpty() && objWrapperData.CaseInfo[0].ProgramCode!=null ) {
           
            objResponse.put('hasReverseSSPDCResponse', true);
        } 
        else{
            objResponse.put('hasReverseSSPDCResponse', false);
        }
            
        List<String> lstReqPrgm = sProgramApplied.split(';');
        if(sRoleType == SSP_GlobalConstants.ORGANISATION_AUTH_REP || 
           sRoleType == SSP_GlobalConstants.INDIVDIUDAL_AUTH_REP_ROLE_STRING){
               if(sExistPrgm!=''){
                   List<String> lstExistPrgm = sExistPrgm.split(';');
                   Set<String> setExistPrgm = new Set<String>(lstExistPrgm);
                   for(String sPrgm: lstReqPrgm) {
                       if(setExistPrgm.contains(sPrgm)) {
                           setHasPer.add(true);
                       } else {
                           setHasPer.add(false);
                       }
                   }
                   if(!setHasPer.contains(false)) {
                       hasPer=true;
                   }
               }
        }
        //Defect 391232
        if((sRoleType == SSP_GlobalConstants.ASSISTER_ROLE || sRoleType == SSP_GlobalConstants.AGENCY_ADMIN_ROLE) && 
          	sApplicationId != null)
        {
           	SSP_Application__c app = [Select Id, Account__c from SSP_Application__c where Id = :sApplicationId limit 1];            
           	List<AccountContactRelation> lstAccCon = [Select Id from AccountContactRelation where AccountId = :app.Account__c and ContactId = :userList[0].ContactId and (Roles = :SSP_GlobalConstants.ASSISTER_ROLE OR Roles = :SSP_GlobalConstants.AGENCY_ADMIN_ROLE) and DCContactId__c = :Integer.valueOf(sDCDataId)];
            if(lstAccCon!=null && lstAccCon.size()>0){
                hasPer=true;
            }
        }
        if(hasPer){
            invokeRepsAssistersAgents(sApplicationId, sCaseNumber);
        }
        objResponse.put('hasPermission', hasPer);
        return objResponse;
    } 
    
    /*
	* method 		: createAccountContactRelation
	* @description  : This method is to create Account Contact Relation.
	* @author 		: Sai Kiran Velpula
	* @return 		: Void
	* */
    public static void createAccountContactRelation(String sAppId, boolean acrForHOH){
        //AccountContactRelation objACR;
        ID sHOHContactId,sApplicationAccountId, sHOHAccountId;
        Set<ID> setContactIds = new Set<ID>();
        Set<ID> setAccountIds = new Set<ID>();
        List<SSP_ApplicationIndividual__c> lstAppInd = new List<SSP_ApplicationIndividual__c>();
        List<AccountContactRelation> lstAcrTobeCreate = new List<AccountContactRelation>();
        Map<ID,AccountContactRelation> mapACR = new Map<ID,AccountContactRelation>();
        Map<ID,AccountContactRelation> mapACRHOH = new Map<ID,AccountContactRelation>();
        Map<ID,AccountContactRelation> mapACRUser = new Map<ID,AccountContactRelation>();
        Set<String> existingAppACRForNonCitizen = new Set<String>();
        try{
          
            if(sAppId != NULL){
                lstAppInd = SSP_ApplicationIndividualSelector.queryApplicationIndividualData(new Map<String, String>{'objectName'=>'SSP_ApplicationIndividual__c'}, 
                                                                                             new Set<String>{'Id','IsHeadOfHousehold__c','SSP_Application__r.Account__c','SSP_Member__r.Contact__c','SSP_Member__r.Contact__r.AccountId'}, 
                                                                                             new Map<String, String>{'SSP_Application__c'=> sAppId});
                if(lstAppInd != NULL && !lstAppInd.isEmpty()){               
                    for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                        sApplicationAccountId = objAppInd.SSP_Application__r.Account__c;
                        if(objAppInd.IsHeadOfHousehold__c == True){
                            sHOHContactId = objAppInd.SSP_Member__r.Contact__c;
                            sHOHAccountId = objAppInd.SSP_Member__r.Contact__r.AccountId;
                        }else{
                            setContactIds.add(objAppInd.SSP_Member__r.Contact__c);
                            setAccountIds.add(objAppInd.SSP_Member__r.Contact__r.AccountId);
                        }
                    }
                }
            }
            //adding hoh account to the list
            setAccountIds.add(sHOHAccountId);
           

            
            Set<Id> qSetContact =  setContactIds;
            Set<Id> qSetAccount =  setAccountIds;

            qSetContact.add(sHOHContactId);
            if(mciWrap.isNonCitizenUser){
                qSetContact.add(mciWrap.contactId);
            }
            qSetAccount.add(sApplicationAccountId);

            if(!mciWrap.conIdForAppReq.isEmpty()){
                qSetContact.addAll(mciWrap.conIdForAppReq);
            }

            for(AccountContactRelation acr : [SELECT ID,AccountId,ContactId FROM AccountContactRelation WHERE ContactId IN : qSetContact AND AccountId IN : qSetAccount]){
                
                if(mciWrap.conIdForAppReq.contains(acr.ContactId) && sApplicationAccountId!=null && sApplicationAccountId.equals(acr.AccountId)){
                    existingAppACRForNonCitizen.add(acr.ContactId);
                }

                //Application account with member contacts (HH members access to Application)
                if(setContactIds!=null && setContactIds.contains(acr.ContactId) && sApplicationAccountId!=null && sApplicationAccountId.equals(acr.AccountId)){                    
                    mapACR.put(acr.ContactId, acr);                    
                }

                //HOH contact with member accounts (HOH access to other HH members)
                if(sHOHContactId!=null && sHOHContactId.equals(acr.ContactId) && setAccountIds!=null && setAccountIds.contains(acr.AccountId)){                    
                    mapACRHOH.put(acr.AccountId, acr);                    
                }

                //Non Citizen Contact with member accounts (Non citizen access to members)
                if(mciWrap.isNonCitizenUser && (acr.ContactId).equals(mciWrap.contactId)){                    
                    mapACRUser.put(acr.AccountId, acr);
                }
            }

            for(String contactId : mciWrap.conIdForAppReq){
                if(!existingAppACRForNonCitizen.contains(contactId)){
                    lstAcrTobeCreate.add(constructACR(contactId, sApplicationAccountId));
                }
            }
            
           
            
            if(lstAppInd != NULL && !lstAppInd.isEmpty()){
                for(SSP_ApplicationIndividual__c objAppInd : lstAppInd){
                    if(objAppInd.IsHeadOfHousehold__c != True && mapACR.get(objAppInd.SSP_Member__r.Contact__c) == NULL){
                        lstAcrTobeCreate.add(constructACR(objAppInd.SSP_Member__r.Contact__c, sApplicationAccountId));
                        if((mapACRHOH == NULL || mapACRHOH.get(objAppInd.SSP_Member__r.Contact__r.AccountId) == NULL) && sHOHContactId!=null){
                            lstAcrTobeCreate.add(constructACR(sHOHContactId, objAppInd.SSP_Member__r.Contact__r.AccountId));
                        }
                    }

                    if(mciWrap.isNonCitizenUser && mapACRUser!=null && !mapACRUser.isEmpty() && !mapACRUser.containsKey(objAppInd.SSP_Member__r.Contact__r.AccountId) && mciWrap.contactid!=null){                        
                        lstAcrTobeCreate.add(constructACR(mciWrap.contactid, objAppInd.SSP_Member__r.Contact__r.AccountId));
                    }
                }

                //10-13
                if(sHOHContactId!=null && ( mapACRHOH == null || mapACRHOH.isEmpty() || (!mapACRHOH.isEmpty() && !mapACRHOH.containsKey(sApplicationAccountId))) ){
                    lstAcrTobeCreate.add(constructACR(sHOHContactId, sApplicationAccountId));
                }
            }
            if(lstAcrTobeCreate.size()>0){    
                Database.upsert(lstAcrTobeCreate,false);
            }
        }
        catch(Exception ex){
             List<LOG_LogMessage__c> lstLogMessages = LOG_LogMessageUtility.logMessage(ex, 'SSP_HouseHoldSummaryService', 'createAccountContactRelation', ex.getMessage() , true);
      
        }
    }

    //10-13
    private static AccountContactRelation constructACR(String contactId, String AccountId){
        AccountContactRelation acr = new AccountContactRelation();
        acr.ContactId = contactId; 
        acr.AccountId = accountId;
        return acr;
    }

    @future(callout = true)
    public static void invokeRepsAssistersAgents(String applicationId, String caseNumber){
        Map<String, Object> mapParams = new Map<String, Object>();
        SSP_RSSPDC_RequestWrapper reqWrapper = new SSP_RSSPDC_RequestWrapper();
        reqWrapper.viewName = SSP_InterfaceConstants.AUTHREPS_ASSISTERS;                    
                  
        reqWrapper.caseNumber = Integer.valueOf(caseNumber);  
        reqWrapper.applicationID = applicationId;
        mapParams.put(SSP_InterfaceConstants.JSON_BODY,reqWrapper);
        IntegrationFactory.invokeCallout(SSP_InterfaceConstants.REVERSE_SSP_DC, mapParams); 
    }


    /** 
		This method will get Map<IndividualId , Contact> where conMapping is present.
		Also give MAP <IndividualId, Member> record for the above contact

		As Discussion with Rahuman+ Partha + Rajiv Only these Contact and Members should be considered. If No Member is returned from this method then 
		New Member will be created.
		Any Member that has same Individual Id but has no-conMapping should not be used and so method updateMemberRecordsWithIndividualIds deletes such members.
		
	**/
    @testVisible
    public static void fetchRequiredData(List<String> lstIndividualId){
        List<contact_Mapping__c> lstConMapping =  new List<contact_Mapping__c>();
        Map<String,Decimal> mapContactVsIndividualId = new Map<String,Decimal>();
        List<SSP_Member__c> lstMember =  new List<SSP_Member__c>();
        Map<String, String> indivIdToCon = new Map<String, String>();
        List<String> contactList = new List<String>();
        Map<Decimal,SSP_Member__C> mapIndividualIdVsMember = new Map<Decimal,SSP_Member__C>();
        
        //Query contact mapping
        if(!lstIndividualId.isEmpty()){
            lstConMapping = SSP_ContactMappingSelector.queryContactMappingData(new Map<String, String>{'objectName'=>'contact_Mapping__c','operator'=>'AND','IN'=>'IEES_Id__c'}, 
                                                                            new Set<String>{'Id', 'Contact__c','IEES_Id__c'}, 
                                                                            new Map<String, String>{'limit'=>'100','IEES_Id__c'=> String.join(lstIndividualId ,',')}); 
        }
        
        //construct
        //Map<ContactId, IndvId>
        //Map<IndvId, ContactId>
        for(contact_Mapping__c objConMapping : lstConMapping){
            if(indivIdToCon.get(String.valueOf(objConMapping.IEES_Id__c))==null){
                indivIdToCon.put(String.valueOf(objConMapping.IEES_Id__c), objConMapping.Contact__c );
            }else if (indivIdToCon.get(String.valueOf(objConMapping.IEES_Id__c))!=null && indivIdToCon.get(String.valueOf(objConMapping.IEES_Id__c))!=objConMapping.Contact__c){
                // more than one contact present with same con-mapping  
                contactList.add(objConMapping.Contact__c);
            }
            mapContactVsIndividualId.put(objConMapping.Contact__c, objConMapping.IEES_Id__c);
        }

        if(contactList!=null && !contactList.isEmpty()){
           List<User> conUserList = [SELECT Id, ContactId, Contact.IndividualId__c FROM User WHERE ContactId IN :contactList LIMIT 1000];
           
            if(conUserList!=null && !conUserList.isEmpty()){
                for(User u :conUserList){
                     String individualId = String.isNotBlank(u.Contact.IndividualId__c) ? u.Contact.IndividualId__c : String.valueOf(mapContactVsIndividualId.get(u.ContactId));
                     indivIdToCon.put(individualId, u.Contact.id);
                     mapContactVsIndividualId.put(u.Contact.id, Decimal.valueOf(individualId));
                }
               
            }
        }

        if(!indivIdToCon.values().isEmpty()){
            lstMember = SSP_MemberSelector.queryMemberData(new Map<String, String>{'objectName'=>'SSP_Member__c','operator'=>'AND','IN'=>'Contact__c'}, 
                                                           new Set<String>{'Id', 'Contact__c' , 'IndividualId__c'}, 
                                                           new Map<String, String>{'limit'=>'100','Contact__c'=> String.join(indivIdToCon.values(),',')});   
        }
        for(SSP_Member__c objMember:lstMember){
            mapIndividualIdVsMember.put(mapContactVsIndividualId.get(objMember.Contact__c),objMember);
        }


        mciWrap.createdContact = indivIdToCon;
        mciWrap.allMembersWithID = mapIndividualIdVsMember;
     }

    //10-13 
    /**
	If HOH gets individual Id on HH page and not on Dashboard.
	Then a new application is started by HOH. In this scenarion Application started by Non-citizen should be marked blocked and reparenting of Member record should be done.
	**/
    @TestVisible
    private static void identifyAndMarkUNApplications(Set<String> memberSet){
        Map<Id, SSP_Application__c> appMap = new Map<Id, SSP_Application__c>();
        String nonCitizenId;
        if(!mciWrap.isNonCitizenUser){
            for(SSP_ApplicationIndividual__c appIndv : [SELECT Id, SSP_Application__c , SSP_Application__r.CreatedById FROM SSP_ApplicationIndividual__c WHERE SSP_Application__r.Status__c = 'UN' AND SSP_Member__c IN :memberSet AND SSP_Application__r.CreatedBy.Profile.Name = :SSP_GlobalConstants.SSP_Non_Citizen_Profile LIMIT 1000]){
                if(appMap != null && !appMap.containsKey(appIndv.SSP_Application__c)){
                    appMap.put(appIndv.SSP_Application__c, new SSP_Application__c(Id = appIndv.SSP_Application__c, Status__c = 'Blocked'));
                    nonCitizenId = appIndv.SSP_Application__r.CreatedById;
                }
            }

            if(appMap != null && !appMap.values().isEmpty()){
                update appMap.values();
            }

            if(String.isNotBlank(nonCitizenId)){
                for(User u : [SELECT Id, ContactId FROM User WHERE Id  = :nonCitizenId LIMIT 1]){
                    mciWrap.conIdForAppReq.add(u.ContactId);
                }
            }
        }
    }
    
    public static Set<Integer> getContactsToInsert(Set<Integer> setIndividuals , List<Contact> ContactId) {
        List<Contact_Mapping__c> listConMap = [SELECT Id, Group_Id__c, IEES_Id__c, Contact__c,Contact__r.IndividualId__c  from Contact_Mapping__c WHERE IEES_Id__c IN :setIndividuals and Contact__c IN :ContactId ];
        for(Contact_Mapping__c objConMapping : listConMap) {
            if(objConMapping.IEES_Id__c!=null && setIndividuals!=null && setIndividuals.size()>0 && setIndividuals.contains(Integer.valueOf(objConMapping.IEES_Id__c))){
                setIndividuals.remove(Integer.valueOf(objConMapping.IEES_Id__c));
            }
        }
        return setIndividuals;
    }
}