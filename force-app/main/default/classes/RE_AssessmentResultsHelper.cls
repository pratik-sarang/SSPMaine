/**************************************************************************************************
* Class Name    : RE_AssessmentResultsHelper 
* Owner         : Ashwin Kasture
* Created Date  : 11/09/2019
* Description   : Assessment Results Screen
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/09/2019  Ashwin Kasture 	Initial Development
**/
public with sharing class RE_AssessmentResultsHelper
{
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         11/09/2019
    * @methodname   getAssessmentResources()
    * @description  This methods is used to get the Resource data based on User Assessment.
    * @param        String sUserAssessId
    * @return       void 
    **********************************************************************************************/
    public static RE_AssessmentResultsWrapper getAssessmentResources(String sUserAssessId, String sGuestAssessmentResponse)
    {   
        Integer resourceCount = 0;
        Location objResidentLocation;
        Double dblLat;
        Double dblLon;
        String sResidentZipcode = '';
        
        Set<Id> setAnswerChoiceId = new Set<Id>();
        Set<Id> setGoalId = new Set<Id>();
        Set<Id> setTaxonomyId = new Set<Id>();
        Set<Id> setResourceId = new Set<Id>();
        Set<Id> setLocationId = new Set<Id>();
        Set<Id> setLocResId = new Set<Id>();
        Set<Id> setUniqueGoalId = new Set<Id>();
        
        RE_AssessmentResultsWrapper objAssessmentWrapper = new RE_AssessmentResultsWrapper();
        List<AssessmentResponse__c> lstAssessmentResp = new List<AssessmentResponse__c>();
        List<SDOH__c> lstSDOHScore = new List<SDOH__c>();
        List<SDOHDescription__c> lstSDOHDescription = new List<SDOHDescription__c>();
        List<GoalAnswer__c> lstGoalAnswer = new List<GoalAnswer__c>();
        List<RE_Config__c> lstConfigs = new List<RE_Config__c>();
        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy = new List<RE_Resource_Taxonomy__c>();
        List<LocationResource__c> lstLocationResource = new List<LocationResource__c>();
        List<Favorite__c> lstFavoritesRes = new List<Favorite__c>();
        List<Location__c> LstLocation = new List<Location__c>();
        
        List<RE_AssessmentResultsWrapper.QuestionAnswerCls> lstQuestionVsAnswer = new List<RE_AssessmentResultsWrapper.QuestionAnswerCls>();
        Map<String,SDOH__c> mapSDOHDomainVsScore = new Map<String,SDOH__c>();
        Map<String, SDOHDescription__c> mapSDOHDescrip = new Map<String, SDOHDescription__c>();
        Map<String, List<GoalAnswer__c>> mapDomainVsGoalAnswer = new Map<String, List<GoalAnswer__c>>();
        Map<Id,List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo = new Map<Id, List<RE_Resource_Taxonomy__c>>();
        Map<Id,List<RE_Resource_Taxonomy__c>> mapGoalIdLstResTaxo = new Map<Id, List<RE_Resource_Taxonomy__c>>();        
        Map<Id,LocationResource__c> mapResourceWithLocation = new Map<Id, LocationResource__c>();
        Map<Id,Double> mapResourceWithMiles = new Map<Id, Double>();
        Map<Id,Map<String, List<String>>> mapOperatingHours = new Map<Id, Map<String, List<String>>>();
        Map<Id,Favorite__c> mapResourceVsFavorites = new Map<Id,Favorite__c>();
        Map<Id, Referral__c> mapResourceVsReferal = new Map<Id, Referral__c>();
        List<Referral__c> lstReferals = new List<Referral__c>();
       	Map<Id, Location__c> mapLocation = new Map<Id, Location__c>();
        
        objAssessmentWrapper.resourceCount = 0;
        objAssessmentWrapper.sUserAssessmentId = sUserAssessId;
        objAssessmentWrapper.bIsGuestUser = false;
        objAssessmentWrapper.bIsCPUserProfile = false;
        objAssessmentWrapper.bIsAgencyUserProfile = false; //RE_Release 1.1 - Agency User Capture - Siri
        objAssessmentWrapper.bIsResidentUser = false;
        RE_CreateLightningServerResponse objResponeUserRole;
       
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
        
        if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
            //Start check login User Roles
            objResponeUserRole = RE_RDResidentViewCtrl.getLoggedInUserRole();
           
        }
        else{
            objAssessmentWrapper.sAssessTemplateName = System.Label.AssessmentTitleForGuest;
            objAssessmentWrapper.bIsGuestUser=true;
        }
       
        if(objResponeUserRole != null){
            objAssessmentWrapper.bIsGuestUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsGuestUser'));
            objAssessmentWrapper.bIsResidentUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsResidentorGuest'));
            objAssessmentWrapper.bIsCPUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsCPUserProfile'));
            objAssessmentWrapper.bIsAgencyUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsAgencyUserProfile'));
        }
        //End check login User Roles
        String sRecTypeAssessUser = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('User_Assessment').getRecordTypeId();        
        /*lstAssessmentResp = [SELECT Id, Name,Resident__c, AnswerChoice__c, Assessment__c, Question__c, TextAnswer__c, Assessment__r.AssessmentTemplate__r.AssessmentTitle__c,Assessment__r.Resident__r.Name,
                             Assessment__r.Partner__r.Name,Assessment__r.CreatedDate,Assessment__r.Resident__r.ContactGeoLocation__c,Assessment__r.Resident__r.MailingPostalCode,Assessment__r.Resident__r.ZipCode__c,
                             Question__r.Question__c,AnswerChoice__r.Answer__c
                             FROM AssessmentResponse__c 
                             WHERE Assessment__c =:sUserAssessId AND Assessment__r.RecordTypeId =:sRecTypeAssessUser];*/
        
       //Nandita 26-Feb-2020: Bypass Assessment Response query for Assessments by Guest User.
        List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question>) JSON.deserialize(sGuestAssessmentResponse, List<RE_AssessmentQuestionsWrapper.Question>.class);
              
        if(!retVal.isEmpty()){//sGuestAssessmentResponse != null || sGuestAssessmentResponse != '' || sGuestAssessmentResponse != 'undefined'){
          // List<RE_AssessmentQuestionsWrapper.Question> retVal = (List<RE_AssessmentQuestionsWrapper.Question>) JSON.deserialize(sGuestAssessmentResponse, List<RE_AssessmentQuestionsWrapper.Question>.class);
        	 for(RE_AssessmentQuestionsWrapper.Question qs : retVal){
                if (qs.sResponse instanceOf Id ){
                    setAnswerChoiceId.add(qs.sResponse);
                }else if(qs.sResponse!=null && qs.dQuesOrder == 1){
                    String strLatLong = GeneralUtility.getLatLong(qs.sResponse);
                    List<String> lstLatLong = strLatLong.split('##');
                    dblLat = Double.valueOf(lstLatLong[0]);
                    dblLon = Double.valueOf(lstLatLong[1]);
                    objResidentLocation =location.newInstance(dblLat,dblLon);
                
                }
             }
        }
        else{
           
            lstAssessmentResp = RE_AssessmentResultsHelper.getAssessmentResponse(sUserAssessId);
            Boolean bExecuteOnce = true;
            for(AssessmentResponse__c objAssessResp: lstAssessmentResp){
                setAnswerChoiceId.add(objAssessResp.AnswerChoice__c);
                    if(bExecuteOnce){
                    RE_AssessmentResultsHelper.assignAssessmentBlock(objAssessmentWrapper, objAssessResp);
                   //objResidentLocation = objAssessResp.Assessment__r.Resident__r.ContactGeoLocation__c;
                        objResidentLocation = objAssessResp.AssessmentGeolocation__c!=null?objAssessResp.AssessmentGeolocation__c: null;
                   //Not needed since we need to show the resources from the zip code entered in the assessment
                   // sResidentZipcode = objAssessResp.Assessment__r.Resident__r.MailingPostalCode != null? objAssessResp.Assessment__r.Resident__r.MailingPostalCode : String.valueOf(objAssessResp.Assessment__r.Resident__r.ZipCode__c);
                    bExecuteOnce = false;
                }
                RE_AssessmentResultsWrapper.QuestionAnswerCls objQnA = new RE_AssessmentResultsWrapper.QuestionAnswerCls();
                objQnA.sQuestion = objAssessResp.Question__r.Question__c;
                if(objAssessResp.AnswerChoice__c!=null){
                objQnA.sAnswer = objAssessResp.AnswerChoice__r.Answer__c;
                }
                else{
                objQnA.sAnswer = objAssessResp.TextAnswer__c;    
                }
                lstQuestionVsAnswer.add(objQnA);
            }
            objAssessmentWrapper.lstQuestionAnswer = lstQuestionVsAnswer;
            if(objResidentLocation != null){
                dblLat = Double.valueOf(objResidentLocation.latitude);
                dblLon = Double.valueOf(objResidentLocation.longitude);
            }
        }
        objAssessmentWrapper.dblat = dblLat;
        objAssessmentWrapper.dblong = dblLon;
		/* Not needed as part if the new assessment story
        else if(String.isNotBlank(sResidentZipcode))
        {
            String strLatLong = GeneralUtility.getLatLong(sResidentZipcode);
            List<String> lstLatLong = strLatLong.split('##');
            dblLat = Double.valueOf(lstLatLong[0]);
            dblLon = Double.valueOf(lstLatLong[1]);
            objResidentLocation = Location.newInstance(dblLat, dblLon);
        } */
        /*lstGoalAnswer = [SELECT Id, Name, AnswerChoice__c, Goal__c, AnswerChoice__r.Question__r.SDOH__c,AnswerChoice__r.Question__r.Assessment__r.AssessmentTitle__c,Goal__r.Title__c,Goal__r.Description__c//,toLabel(AnswerChoice__r.Question__r.SDOH__c) sdohdomain
                         FROM GoalAnswer__c 
                         WHERE AnswerChoice__c IN:setAnswerChoiceId AND Goal__c != null AND AnswerChoice__r.Question__r.SDOH__c != null];*/
        lstGoalAnswer = RE_AssessmentResultsHelper.getGoalAnswerRecords(setAnswerChoiceId);
        for(GoalAnswer__c objAns: lstGoalAnswer){
            setGoalId.add(objAns.Goal__c);
            mapDomainVsGoalAnswer = RE_AssessmentResultsHelper.getDomainVsGoalAns(objAns, mapDomainVsGoalAnswer);
        }
      
        
        Set<String> setSDOHDmain = mapDomainVsGoalAnswer.keySet();
        /*lstSDOHScore = [SELECT Id, Name, Category__c, Resident__c, Score__c, IsLatest__c, AssessmentDate__c, Assessment__c 
                        FROM SDOH__c 
                        WHERE Assessment__c=:sUserAssessId AND Category__c !=null AND Category__c IN:setSDOHDmain];*/
        lstSDOHScore = RE_AssessmentResultsHelper.getSDOHRecords(sUserAssessId, setSDOHDmain);
        for(SDOH__c objSDOH: lstSDOHScore){
            mapSDOHDomainVsScore.put(objSDOH.Category__c, objSDOH);
        }
        for(String s :mapSDOHDomainVsScore.keyset()){
            if(!mapDomainVsGoalAnswer.containskey(s)){
                mapDomainVsGoalAnswer.put(s,new List<GoalAnswer__c>());
            }
        }
       
        
        /*List<SDOHDescription__c> lstSDOHDescription = [SELECT Id, SDOH__c, Score__c, Description__c 
        												FROM SDOHDescription__c 
                                                        WHERE Assessment_Template__c =:objAssessmentWrapper.sAssessTemplateName AND SDOH__c IN:setSDOHDmain];*/
        lstSDOHDescription = RE_AssessmentResultsHelper.getSDOHDescripCustomSetting(objAssessmentWrapper.sAssessTemplateName, setSDOHDmain);
       
        for(SDOHDescription__c objSDOHDesp: lstSDOHDescription){
            if(mapSDOHDomainVsScore != null && mapSDOHDomainVsScore.containsKey(objSDOHDesp.SDOH__c) && mapSDOHDomainVsScore.get(objSDOHDesp.SDOH__c).Score__c != null 
               && mapSDOHDomainVsScore.get(objSDOHDesp.SDOH__c).Score__c.round(System.RoundingMode.CEILING) == objSDOHDesp.Score__c.round(System.RoundingMode.CEILING)){
                mapSDOHDescrip.put(objSDOHDesp.SDOH__c, objSDOHDesp);
            }
        }
      
        //String goalConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('Goal_Config').getRecordTypeId();
        //lstConfigs = [SELECT Id,Taxonomy__c,Goal__c FROM RE_Config__c WHERE Goal__c IN:setGoalId AND RecordTypeId =: goalConfigRecId AND Taxonomy__c != null];
        lstConfigs = RE_AssessmentResultsHelper.getGoalConfigRecords(setGoalId, null, 'Assessment');
        
        for(RE_Config__c objCon: lstConfigs){
            setTaxonomyId.add(objCon.Taxonomy__c);
        }
       
        
        Map<String,String> mapResTaxoInputParameters=new Map<String,String>();
        mapResTaxoInputParameters.put('sAccountStatus',RE_GlobalConstants.sAccountStatus);
        mapResTaxoInputParameters.put('checkMethodCallFrom','Assessment');
        lstResourceTaxonomy = RE_AssessmentResultsHelper.getResourceTaxonomy(lstResourceTaxonomy, setTaxonomyId, mapResTaxoInputParameters);
        for(RE_Resource_Taxonomy__c objResTax: lstResourceTaxonomy){
            setResourceId.add(objResTax.Resource__c);
            mapTaxoIdLstResTaxo = RE_AssessmentResultsHelper.getTaxoVsResTaxo(objResTax, mapTaxoIdLstResTaxo);
        }
       
       
        
       
       
        
            Map<String, String> mapLocationResInputs = new Map<String, String>();   
            if(dblLat != null && dblLon != null){     
                mapLocationResInputs.put('dblLat',String.valueOf(dblLat));
                mapLocationResInputs.put('dblLon',String.valueOf(dblLon));
            }
            mapLocationResInputs.put('checkMethodCallFrom','Assessment');
            lstLocationResource = RE_AssessmentResultsHelper.getLocationResource(lstLocationResource, setResourceId, mapLocationResInputs);
            //lstLocationResource = RE_ArchetypeDetailCtrl.getLocationResource(lstLocationResource, dblLat, dblLon, setResourceId);
               
       
        for(LocationResource__c objResources:lstLocationResource)
        {                
            setLocResId.add(objResources.Id);
            setLocationId.add(objResources.Location__c);
            mapResourceWithLocation.put(objResources.Resource__c, objResources);
            if(dblLat != null && dblLon != null){
                Double dblMiles = RE_MyPlanHelper.getDistance(objResidentLocation, objResources.Location__r.Geolocation__c, 'mi');
                mapResourceWithMiles.put(objResources.Resource__c, dblMiles);
            }
        }
        
        for(RE_Config__c objCon: lstConfigs){
mapGoalIdLstResTaxo = RE_AssessmentResultsHelper.getGoalVsResTaxo(objCon, mapTaxoIdLstResTaxo, mapGoalIdLstResTaxo);
        }
       
 
      
        
        if(!setLocationId.isEmpty()){
            LstLocation = RE_SharingByPassCtrl.getLocationOperatingHours(setLocationId);
            if(!LstLocation.isEmpty()){
                for(Location__c objLocation :LstLocation){
                    mapLocation.put(objLocation.id,objLocation);
                }
            }
            //mapOperatingHours = GeneralUtility.getLocationOperationHoursList(setLocationId,lstLocationResource);
        }
        
        
        //To get referrals
        if(!objAssessmentWrapper.bIsGuestUser){
            lstReferals = RE_ArchetypeDetailCtrl.getReferralRecords(lstReferals, setResourceId);
            for(Referral__c objReferal: lstReferals){
                mapResourceVsReferal.put(objReferal.Resource__c, objReferal);
            }
        }
        
        
        //To get the Favorites of Resources based on login user & Location Resources
        if(objAssessmentWrapper.bIsCPUserProfile || objAssessmentWrapper.bIsAgencyUserProfile){
           
            lstFavoritesRes = RE_ArchetypeDetailCtrl.getFavoriteResources(setLocResId);
           
            for(Favorite__c objFav: lstFavoritesRes){
                mapResourceVsFavorites.put(objFav.LocationResource__r.Resource__c, objFav);
            }               
        }
        
        /*---Start Assigning the Wrapper data---*/
        List<RE_AssessmentResultsWrapper.DomainBlockCls> lstDomainBlock = new List<RE_AssessmentResultsWrapper.DomainBlockCls>();
        List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstArGoal;
        List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstArRes;
        
        for(String objCategory: mapDomainVsGoalAnswer.keySet())
        {
        
            RE_AssessmentResultsWrapper.DomainBlockCls objDomainBlk = new RE_AssessmentResultsWrapper.DomainBlockCls();
            RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock;
            RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock;            
            List<GoalAnswer__c> lstGoalAnsRecord = mapDomainVsGoalAnswer.get(objCategory);
            if(lstGoalAnsRecord.isEmpty()){
				objDomainBlk.iScore=mapSDOHDomainVsScore.get(objCategory).Score__c.round(System.RoundingMode.CEILING);
				objDomainBlk.sSDOHDomain=objCategory;
                RE_SDOHScores__c cs = RE_SDOHScores__c.getInstance(String.valueOf(objDomainBlk.iScore));
            objDomainBlk.sScoreColorStatus = cs != null ? cs.ScoreColor__c:'';
				objDomainBlk.sSDOHDomainDescriptn = '';
                objDomainBlk.lstGoalBlock=new List<RE_ArchetypeDetailWrapper.GoalBlockCls>();
			}
                
            for(GoalAnswer__c objGoalAnsRecord :lstGoalAnsRecord)
            {
                if(!setUniqueGoalId.contains(objGoalAnsRecord.Goal__c)) //Use to avoid processing on duplicate Goals
                {
                    setUniqueGoalId.add(objGoalAnsRecord.Goal__c);
                    RE_AssessmentResultsHelper.assignSDOHDomainBlock(objDomainBlk, objGoalAnsRecord, mapSDOHDomainVsScore, mapSDOHDescrip, objCategory);
                    //Start Goal Block
                    objGoalBlock = new RE_ArchetypeDetailWrapper.GoalBlockCls();
                    RE_AssessmentResultsHelper.assignGoalBlock(objGoalBlock, objGoalAnsRecord);
                    lstArGoal = new List<RE_ArchetypeDetailWrapper.GoalBlockCls>();                    
                    objDomainBlk.lstGoalBlock = RE_AssessmentResultsHelper.addNewGoalsInExistingGoalList(objGoalBlock, objDomainBlk, lstArGoal);
                    //End Goal Block
                    if(mapGoalIdLstResTaxo.containsKey(objGoalAnsRecord.Goal__c) && mapGoalIdLstResTaxo.get(objGoalAnsRecord.Goal__c) != null)
                    {
                        integer iCount = 2,recount=0;
                        List<RE_Resource_Taxonomy__c> lstResTaxo = mapGoalIdLstResTaxo.get(objGoalAnsRecord.Goal__c);                    
                        for(RE_Resource_Taxonomy__c objResTax: lstResTaxo)
                        {
                           // if(recount < iCount){
                        String switchCaseKey = recount < iCount?'TRUE':'FALSE';
                         switch on (switchCaseKey) {
                            when 'TRUE'{
                            //Start Resource Block
                            objAssessmentWrapper.resourceCount += resourceCount+1;
                         
                            objResblock = new RE_ArchetypeDetailWrapper.ResourceTileBlockCls();
                            if(mapResourceWithLocation != null && mapResourceWithLocation.containsKey(objResTax.Resource__c))
        					{
                                RE_AssessmentResultsHelper.assignResourceBlock(objResblock, objResTax, mapResourceWithLocation, mapLocation);
                                //RE_AssessmentResultsHelper.assignLocationResBlock(objResblock, objResTax, mapResourceWithLocation, mapOperatingHours);
                                RE_AssessmentResultsHelper.assignMilesData(objResblock, objResTax, mapResourceWithMiles);
                                assignFavoritesData(objResblock, objResTax, mapResourceVsFavorites);
                                assignReferalsData(objResblock, objResTax, mapResourceVsReferal);
                                lstArRes = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
                                objGoalBlock.lstResourceTile = RE_AssessmentResultsHelper.addNewResInExistingResList(objResblock, objGoalBlock, lstArRes);                        
                            //End Resource Block
                                recount = recount+1; 
                            }
                            }
                            when 'FALSE'{
                               
                                break;
                            }
                         }
                        }
                    }
                    if(objGoalBlock.lstResourceTile != null && !objGoalBlock.lstResourceTile.isEmpty()){
                            objGoalBlock.lstResourceTile.sort();
                        }
                }
            }
            lstDomainBlock.add(objDomainBlk);
        }
        lstDomainBlock.sort();
        objAssessmentWrapper.lstDomainBlock = lstDomainBlock;
     
        /*---End Assigning Wrapper data ---*/
        return objAssessmentWrapper;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   getDomainVsGoalAns()
    * @description  This methods is used to set SDOH Domain and Goal Answer related to it
    * @param        GoalAnswer__c objAns, Map<String, List<GoalAnswer__c>> mapDomainVsGoalAnswer
    * @return       Map<String, List<GoalAnswer__c>> 
    **********************************************************************************************/
    public static Map<String, List<GoalAnswer__c>> getDomainVsGoalAns(GoalAnswer__c objAns, Map<String, List<GoalAnswer__c>> mapDomainVsGoalAnswer)
    {
        if(mapDomainVsGoalAnswer.containsKey(objAns.AnswerChoice__r.Question__r.SDOH__c))
        {
            List<GoalAnswer__c> lstGoalA = mapDomainVsGoalAnswer.get(objAns.AnswerChoice__r.Question__r.SDOH__c);
            lstGoalA.add(objAns);
            mapDomainVsGoalAnswer.put(objAns.AnswerChoice__r.Question__r.SDOH__c,lstGoalA);
        }
        else{
            mapDomainVsGoalAnswer.put(objAns.AnswerChoice__r.Question__r.SDOH__c, new List<GoalAnswer__c>{objAns});
        }
        return mapDomainVsGoalAnswer;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   getTaxoVsResTaxo()
    * @description  This methods is used to set Taxonomy and Resource Taxonomy related to it
    * @param        RE_Resource_Taxonomy__c objResTax, Map<Id, List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo
    * @return       Map<Id, List<RE_Resource_Taxonomy__c>> 
    **********************************************************************************************/
    public static Map<Id, List<RE_Resource_Taxonomy__c>> getTaxoVsResTaxo(RE_Resource_Taxonomy__c objResTax, Map<Id, List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo)
    {
        if(mapTaxoIdLstResTaxo.containsKey(objResTax.Taxonomy__c))
        {
            List<RE_Resource_Taxonomy__c> lstConfigRecords = mapTaxoIdLstResTaxo.get(objResTax.Taxonomy__c);
            lstConfigRecords.add(objResTax);
            mapTaxoIdLstResTaxo.put(objResTax.Taxonomy__c,lstConfigRecords);
        }
        else{
            mapTaxoIdLstResTaxo.put(objResTax.Taxonomy__c, new List<RE_Resource_Taxonomy__c>{objResTax});
        }
        return mapTaxoIdLstResTaxo;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   getGoalVsResTaxo()
    * @description  This methods is used to set Goal and Resource Taxonomy related to it
    * @param        RE_Config__c objConfig, Map<Id, List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo, Map<Id, List<RE_Resource_Taxonomy__c>> mapGoalIdLstResTaxo
    * @return       Map<Id, List<RE_Resource_Taxonomy__c>> 
    **********************************************************************************************/
    public static Map<Id, List<RE_Resource_Taxonomy__c>> getGoalVsResTaxo(RE_Config__c objConfig, Map<Id, List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo, Map<Id, List<RE_Resource_Taxonomy__c>> mapGoalIdLstResTaxo)
    {
        if(objConfig.Taxonomy__c != null && objConfig.Goal__c != null && mapGoalIdLstResTaxo.containsKey(objConfig.Goal__c) && mapTaxoIdLstResTaxo.containsKey(objConfig.Taxonomy__c))
        {
            List<RE_Resource_Taxonomy__c> lstConfigRecords = mapGoalIdLstResTaxo.get(objConfig.Goal__c);
            lstConfigRecords.addAll(mapTaxoIdLstResTaxo.get(objConfig.Taxonomy__c));
            mapGoalIdLstResTaxo.put(objConfig.Goal__c,lstConfigRecords);
        }
        else if(objConfig.Taxonomy__c != null && objConfig.Goal__c != null && mapTaxoIdLstResTaxo.containsKey(objConfig.Taxonomy__c))
        {
            List<RE_Resource_Taxonomy__c> lstResObj = new List<RE_Resource_Taxonomy__c>();
            lstResObj.addAll(mapTaxoIdLstResTaxo.get(objConfig.Taxonomy__c));
            mapGoalIdLstResTaxo.put(objConfig.Goal__c, lstResObj);
        }
        return mapGoalIdLstResTaxo;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         20/09/2019
    * @methodname   assignAssessmentBlock()
    * @description  This methods is used to set assessment wrapper variables.
    * @param        RE_AssessmentResultsWrapper objAssessmentWrapper, AssessmentResponse__c objAssessResp
    * @return       void 
    **********************************************************************************************/
    public static void assignAssessmentBlock(RE_AssessmentResultsWrapper objAssessmentWrapper, AssessmentResponse__c objAssessResp)
    {
        objAssessmentWrapper.sAssessmentTemplateId = objAssessResp.Assessment__r.AssessmentTemplate__c;
        objAssessmentWrapper.sAssessTemplateName = objAssessResp.Assessment__r.AssessmentTemplate__r.AssessmentTitle__c;
        objAssessmentWrapper.sResidentName = objAssessResp.Assessment__r.Resident__r.Name;
        objAssessmentWrapper.sResidentId = objAssessResp.Assessment__r.Resident__c;
        objAssessmentWrapper.sPartnerName = objAssessResp.Assessment__r.Partner__r.Name;
        objAssessmentWrapper.sDateTaken = objAssessResp.Assessment__r.CreatedDate.month()+'/'+objAssessResp.Assessment__r.CreatedDate.day()+'/'+objAssessResp.Assessment__r.CreatedDate.year();
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignSDOHDomainBlock()
    * @description  This methods is used to set Goal and Resource Taxonomy related to it
    * @param        RE_AssessmentResultsWrapper.DomainBlockCls objDomainBlk,GoalAnswer__c objGoalAnsRecord, Map<String,SDOH__c> mapSDOHDomainVsScore, String objCategory
    * @return       void 
    **********************************************************************************************/
    public static void assignSDOHDomainBlock(RE_AssessmentResultsWrapper.DomainBlockCls objDomainBlk,GoalAnswer__c objGoalAnsRecord, Map<String,SDOH__c> mapSDOHDomainVsScore, Map<String, SDOHDescription__c> mapSDOHDescrip, String objCategory)
    {
        objDomainBlk.sSDOHDomain = objGoalAnsRecord.AnswerChoice__r.Question__r.SDOH__c;
        if(mapSDOHDomainVsScore != null && mapSDOHDomainVsScore.containsKey(objCategory))
        {
            objDomainBlk.iScore = mapSDOHDomainVsScore.get(objCategory).Score__c.round(System.RoundingMode.CEILING);
            RE_SDOHScores__c cs = RE_SDOHScores__c.getInstance(String.valueOf(objDomainBlk.iScore));
            objDomainBlk.sScoreColorStatus = cs != null ? cs.ScoreColor__c:'';
        }
        if(mapSDOHDescrip != null && mapSDOHDescrip.containsKey(objCategory)){
            objDomainBlk.sSDOHDomainDescriptn = mapSDOHDescrip.get(objCategory).Description__c;
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignGoalBlock()
    * @description  This methods is used to assign the Goal wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, GoalAnswer__c objGoalAnsRecord
    * @return       void 
    **********************************************************************************************/
    public static void assignGoalBlock(RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, GoalAnswer__c objGoalAnsRecord)
    {                    
        objGoalBlock.goalId = objGoalAnsRecord.Goal__c;
        objGoalBlock.goal = objGoalAnsRecord.Goal__r.Title__c;
        objGoalBlock.goalDescription = objGoalAnsRecord.Goal__r.Description__c;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignResourceBlock()
    * @description  This methods is used to assign the Resource wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax
    * @return       void 
    **********************************************************************************************/
    public static void assignResourceBlock(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, LocationResource__c> mapResourceWithLocation, Map<Id, Location__c> mapLocation)
    {
       if(mapResourceWithLocation != null && mapResourceWithLocation.containsKey(objResTax.Resource__c))
        {
            objResblock.resourceId = objResTax.Resource__c;
            objResblock.resourceName = objResTax.Resource__r.Name;
           // objResblock.resourceDescription = objResTax.Resource__r.Description__c;
            objResblock.accountId = objResTax.Resource__r.Organization__c;
            objResblock.accountProviderName = objResTax.Resource__r.Organization__r.Name;
            objResblock.accountWebsite = objResTax.Resource__r.Organization__r.Website;
            objResblock.accountStatus = objResTax.Resource__r.Organization__r.Status__c;
            objResblock.accountIsClaimed = objResTax.Resource__r.Organization__r.IsClaimed__c;
            
            //Nandita: Added location resource mapping
            objResblock.locationResourceId = mapResourceWithLocation.get(objResTax.Resource__c).Id;
            objResblock.locationId = mapResourceWithLocation.get(objResTax.Resource__c).Location__c;
            objResblock.locationName = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Name;
            if(mapResourceWithLocation.get(objResTax.Resource__c).Phone__c != null && mapResourceWithLocation.get(objResTax.Resource__c).Phone__c!=''){
                objResblock.locationPhone = GeneralUtility.formatphonenumber(mapResourceWithLocation.get(objResTax.Resource__c).Phone__c);
            }else if(!String.isBlank(mapResourceWithLocation.get(objResTax.Resource__c).TollFree__c)){
                objResblock.locationPhone = GeneralUtility.formatphonenumber(mapResourceWithLocation.get(objResTax.Resource__c).TollFree__c);
            }
            objResblock.locationEmail = String.isBlank(mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Email__c)?mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Account__r.Email__c:mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Email__c;
            objResblock.locationAddress1 = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Address1__c;
            objResblock.locationAddress2 = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Address2__c;
            objResblock.locationCity = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.City__c;
            objResblock.locationState = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.State__c;
            objResblock.locationZipcode = String.valueOf(mapResourceWithLocation.get(objResTax.Resource__c).Location__r.Zip__c);
            objResblock.locationZipcodeExt = String.valueOf(mapResourceWithLocation.get(objResTax.Resource__c).Location__r.ZipExtensionCode__c);    
            Map<String, List<String>> mapLDayOperatingHours = new Map<String, List<String>>();
           	Id LocationId = mapResourceWithLocation.get(objResTax.Resource__c).Location__c;
            
                mapLDayOperatingHours = GeneralUtility.getLocationOperationHours(mapLocation.get(LocationId),mapResourceWithLocation.get(objResTax.Resource__c));//mapOperatingHours.get(mapResourceWithLocation.get(objResTax.Resource__c).Id);
              
                     
            objResblock.locationOperatingHours = JSON.serialize(mapLDayOperatingHours);            
            objResblock.resoucrePOCPhone = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.PointofContactPhone__c;
            objResblock.resourcePOCEmail = mapResourceWithLocation.get(objResTax.Resource__c).Location__r.PointofContactEmail__c;
            if(objResblock.accountStatus == RE_GlobalConstants.sAccountStatus && objResblock.accountIsClaimed){
                objResblock.setBulkReferalStatus = RE_GlobalConstants.STATUS_NEW;
            }else if(!objResblock.accountIsClaimed){
                objResblock.setBulkReferalStatus = RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            }    
            objResblock.resourceDescription = mapResourceWithLocation.get(objResTax.Resource__c).ResourceDescription__c;
        }
    }

    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignMilesData()
    * @description  This methods is used to assign the Miles wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, Double> mapResourceWithMiles
    * @return       void 
    **********************************************************************************************/
    public static void assignMilesData(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, Double> mapResourceWithMiles)
    {
        if(mapResourceWithMiles != null && mapResourceWithMiles.containsKey(objResTax.Resource__c))
        {
            Decimal dMile = Decimal.valueOf(mapResourceWithMiles.get(objResTax.Resource__c));
            objResblock.resourceMiles = dMile.setScale(2, RoundingMode.CEILING);
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignFavoritesData()
    * @description  This methods is used to assign the Favorite wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id,Favorite__c> mapResourceVsFavorites
    * @return       void 
    **********************************************************************************************/
    public static void assignFavoritesData(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id,Favorite__c> mapResourceVsFavorites)
    {	
       
        if(mapResourceVsFavorites != null && mapResourceVsFavorites.containsKey(objResTax.Resource__c)){
            objResblock.favoriteId = mapResourceVsFavorites.get(objResTax.Resource__c).Id;
        }
        else{
            objResblock.favoriteId = '';
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         16/09/2019
    * @methodname   assignReferalsData()
    * @description  This methods is used to assign the Referal wrapper variable.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, Referral__c> mapResourceVsReferal
    * @return       void 
    **********************************************************************************************/
    public static void assignReferalsData(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_Resource_Taxonomy__c objResTax, Map<Id, Referral__c> mapResourceVsReferal)
    {
        if(mapResourceVsReferal != null && mapResourceVsReferal.containsKey(objResTax.Resource__c)){
            objResBlock.referralId = mapResourceVsReferal.get(objResTax.Resource__c).Id;
            objResBlock.objReferral = mapResourceVsReferal.get(objResTax.Resource__c);
            objResBlock.isConnectButtonDisabled = true;
        }
        else{
            objResBlock.referralId='';
            objResBlock.objReferral = null;
            objResBlock.isConnectButtonDisabled = false;
        }
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         19/09/2019
    * @methodname   addNewGoalsInExistingGoalList()
    * @description  This methods is used to check previous Goal list exist and add new Goal to previous list.
    * @param        RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, RE_AssessmentResultsWrapper.DomainBlockCls objDomainBlk, List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstArGoal
    * @return       List<RE_ArchetypeDetailWrapper.GoalBlockCls> 
    **********************************************************************************************/
    public static List<RE_ArchetypeDetailWrapper.GoalBlockCls> addNewGoalsInExistingGoalList(RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock, RE_AssessmentResultsWrapper.DomainBlockCls objDomainBlk, List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstArGoal)
    {        
        if(objDomainBlk.lstGoalBlock != null && !objDomainBlk.lstGoalBlock.isEmpty()){
            lstArGoal = objDomainBlk.lstGoalBlock;
        }
        lstArGoal.add(objGoalBlock);
        return lstArGoal;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         19/09/2019
    * @methodname   addNewResInExistingResList()
    * @description  This methods is used to check previous Resource list exist and add new Resource to previous list.
    * @param        RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstArRes
    * @return       List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> 
    **********************************************************************************************/
    public static List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> addNewResInExistingResList(RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock, RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstArRes)
    {
        if(objGoalBlock.lstResourceTile != null && !objGoalBlock.lstResourceTile.isEmpty()){
            lstArRes = objGoalBlock.lstResourceTile;
        }
        lstArRes.add(objResblock);
        //lstArRes.sort();
        return lstArRes;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         19/09/2019
    * @methodname   getAssessmentResponse()
    * @description  This methods is used to get records of Assessment Response.
    * @param        String sUserAssessId
    * @return       List<AssessmentResponse__c> 
    **********************************************************************************************/
    public static List<AssessmentResponse__c> getAssessmentResponse(String sUserAssessId)
    {   
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
         //Added By Kojashree  -- SSP Merge Fixes
        String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
            
        List<AssessmentResponse__c> lstAssessResponse = new List<AssessmentResponse__c>();
        String sRecTypeAssessUser = Schema.SObjectType.Assessment__c.getRecordTypeInfosByDeveloperName().get('User_Assessment').getRecordTypeId();
        Id sAssessmentRespRecTypeId = Schema.SObjectType.AssessmentResponse__c.getRecordTypeInfosByName().get('Resource Engine Assessment Response').getRecordTypeId();//Nandita: Added cod eto get Assessment Response Record Type Id
        String sFieldsToQueryOnAssessResponseObj = RE_DataBaseQueryFields.sFieldsToQueryOnAssessResponseObj;
        String sWhereClauseOnAssessResponseObj = RE_DataBaseQueryFields.sWhereClauseOnAssessResponseObj;
        sFieldsToQueryOnAssessResponseObj = sFieldsToQueryOnAssessResponseObj;
          // if(loggedinProfile == RE_GlobalConstants.strCitizenProfileName){
            if(selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                    sWhereClauseOnAssessResponseObj=RE_DataBaseQueryFields.sWhereClauseOnAssessResponseObjCitizen;
            }else{
        sWhereClauseOnAssessResponseObj = sWhereClauseOnAssessResponseObj;
            }
        String sOrderby = RE_DataBaseQueryFields.sOrderByNameAsc;
        Map<String,String> mapAssessRespQueryParameters = new Map<String,String>();
        mapAssessRespQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnAssessResponseObj);
        mapAssessRespQueryParameters.put(RE_GlobalConstants.sOrderByKey,sOrderby); 
        Map<Boolean,String> mapAssessRespoQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('AssessmentResponse__c', sFieldsToQueryOnAssessResponseObj, mapAssessRespQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapAssessRespoQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                String sAssessResponseQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('AssessmentResponse__c', sFieldsToQueryOnAssessResponseObj, mapAssessRespQueryParameters);
               
              // if(loggedinProfile == RE_GlobalConstants.strCitizenProfileName){
                if(selectedRole == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                   lstAssessResponse = Database.query(sAssessResponseQuery); 
                }else{
                  lstAssessResponse = RE_SharingByPassCtrl.fetchAssesmentResponseRecords(sAssessResponseQuery,sUserAssessId,sRecTypeAssessUser,sAssessmentRespRecTypeId);
                }
                
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getAssessmentResponse', RE_GlobalConstants.FLS_ERROR + '' + mapAssessRespoQueryResponse.get(false), true);
            }
        }
        return lstAssessResponse;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         19/09/2019
    * @methodname   getGoalAnswerRecords()
    * @description  This methods is used to get records of Goal Answer Junction object.
    * @param        Set<Id> setAnswerChoiceId
    * @return       List<GoalAnswer__c>
    **********************************************************************************************/
    public static List<GoalAnswer__c> getGoalAnswerRecords(Set<Id> setAnswerChoiceId)
    {   
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
        //Added By Kojashree  -- SSP Merge Fixes
        String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
        List<GoalAnswer__c> lstGoalAnswer = new List<GoalAnswer__c>();
        String sFieldsToQueryOnGoalAnswerObj = RE_DataBaseQueryFields.sAssessFieldsToQueryOnGoalAnswerObj;
        String sWhereClauseOnGoalAnswerObj = RE_DataBaseQueryFields.sAssessWhereClauseOnGoalAnswerObj;
        sFieldsToQueryOnGoalAnswerObj = sFieldsToQueryOnGoalAnswerObj;
        sWhereClauseOnGoalAnswerObj = sWhereClauseOnGoalAnswerObj;
        Map<String,String> mapGoalAnswerQueryParameters = new Map<String,String>();
        mapGoalAnswerQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnGoalAnswerObj);
        Map<Boolean,String> mapGoalAnswerQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('GoalAnswer__c', sFieldsToQueryOnGoalAnswerObj, mapGoalAnswerQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapGoalAnswerQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                String sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('GoalAnswer__c', sFieldsToQueryOnGoalAnswerObj, mapGoalAnswerQueryParameters);
               
             // if(loggedinProfile  == RE_GlobalConstants.strCitizenProfileName ){
                if(selectedRole  == RE_GlobalConstants.CITIZEN_INDIVIDUAL ){
                    lstGoalAnswer = Database.query(sQuery);
                }else{
                    lstGoalAnswer = RE_SharingByPassCtrl.fetchGoalAnswerRecords(sQuery, setAnswerChoiceId);
                    // without sharing code
                }
                
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getGoalAnswerRecords', RE_GlobalConstants.FLS_ERROR + '' + mapGoalAnswerQueryResponse.get(false), true);
            }
        }
        return lstGoalAnswer;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         19/09/2019
    * @methodname   getSDOHRecords()
    * @description  This methods is used to get records of SDOH object.
    * @param        String sUserAssessId, Set<String> setSDOHDmain
    * @return       List<SDOH__c >
    **********************************************************************************************/
    public static List<SDOH__c > getSDOHRecords(String sUserAssessId, Set<String> setSDOHDmain)
    {   
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
        //Added By Kojashree  -- SSP Merge Fixes
        String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
             
        List<SDOH__c > lstSDOH = new List<SDOH__c >();
        String sFieldsToQueryOnSDOHObj = RE_DataBaseQueryFields.sAssessFieldsToQueryOnSDOHObj;
        String sWhereClauseOnSDOHObj = RE_DataBaseQueryFields.sAssessWhereClauseOnSDOHObj;
        sFieldsToQueryOnSDOHObj = sFieldsToQueryOnSDOHObj;
        sWhereClauseOnSDOHObj = sWhereClauseOnSDOHObj;
        Map<String,String> mapSDOHQueryParameters = new Map<String,String>();
        mapSDOHQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSDOHObj);
        Map<Boolean,String> mapSDOHQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('SDOH__c', sFieldsToQueryOnSDOHObj, mapSDOHQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapSDOHQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                String sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('SDOH__c', sFieldsToQueryOnSDOHObj, mapSDOHQueryParameters);
             // if(loggedinProfile  == RE_GlobalConstants.strCitizenProfileName){
                if(selectedRole  == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                     lstSDOH = Database.query(sQuery);  
                }else{
                    lstSDOH = RE_SharingByPassCtrl.fetchSDOHRecords(sQuery, sUserAssessId, setSDOHDmain);
                    // without sharing query
                }
               
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getSDOHRecords', RE_GlobalConstants.FLS_ERROR + '' + mapSDOHQueryResponse.get(false), true);
            }
        }
        return lstSDOH;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         26/09/2019
    * @methodname   getSDOHDescripCustomSetting()
    * @description  This methods is used to get records of SDOH Descrition from Custom Setting.
    * @param        String sAssessTemplateName, Set<String> setSDOHDmain
    * @return       List<SDOHDescription__c>
    **********************************************************************************************/
    public static List<SDOHDescription__c> getSDOHDescripCustomSetting(String sAssessTemplateName, Set<String> setSDOHDmain)
    {   
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
          //Added By Kojashree  -- SSP Merge Fixes
        String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
             
        List<SDOHDescription__c> lstSDOH = new List<SDOHDescription__c>();
        String sFieldsToQueryOnSDOHObj = RE_DataBaseQueryFields.sFieldsToQueryOnSDOHObj;
        String sWhereClauseOnSDOHObj = RE_DataBaseQueryFields.sWhereClauseOnSDOHObj;
        sFieldsToQueryOnSDOHObj = sFieldsToQueryOnSDOHObj;
        sWhereClauseOnSDOHObj = sWhereClauseOnSDOHObj;
        Map<String,String> mapSDOHQueryParameters = new Map<String,String>();
        mapSDOHQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnSDOHObj);
        Map<Boolean,String> mapSDOHQueryResponse = RE_DataAccessChecker.getFieldsAccessibility('SDOHDescription__c', sFieldsToQueryOnSDOHObj, mapSDOHQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapSDOHQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                String sQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects('SDOHDescription__c', sFieldsToQueryOnSDOHObj, mapSDOHQueryParameters);
             
               //   if(loggedinProfile  == RE_GlobalConstants.strCitizenProfileName){
                if(selectedRole  == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                     lstSDOH = Database.query(sQuery);
                }else{
                    lstSDOH = RE_SharingByPassCtrl.fetchSDOHDescripCustomSetting(sQuery,sAssessTemplateName,setSDOHDmain);
                }
               
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getSDOHDescripCustomSetting', RE_GlobalConstants.FLS_ERROR + '' + mapSDOHQueryResponse.get(false), true);
            }
        }
        return lstSDOH;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         20/09/2019
    * @methodname   getGoalConfigRecords()
    * @description  This methods is used to get the Config object records of Goal record type
    * @param        List<RE_Config__c> lstConfig
    * @return       List<RE_Config__c>  
    **********************************************************************************************/
    public static List<RE_Config__c> getGoalConfigRecords(Set<Id> setGoalId, List<String> lstDomainsSplit, String checkMethodCallFrom)
    {
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
           //Added By Kojashree  -- SSP Merge Fixes
        String selectedRole = GeneralUtility.getLoggedInUserSelectedRole();
              
        List<RE_Config__c> lstGoalConfig = new List<RE_Config__c>();
        String goalConfigRecId = Schema.SObjectType.RE_Config__c.getRecordTypeInfosByDeveloperName().get('Goal_Config').getRecordTypeId();
        String sConfigQuery='';
        String sFieldsToQueryOnConfig='';
        String sWhereClauseOnConfigObj='';
        if(checkMethodCallFrom.equalsIgnoreCase('Archetype')){
            sFieldsToQueryOnConfig = RE_DataBaseQueryFields.sFieldsToQueryOnConfigObj;
            sWhereClauseOnConfigObj = RE_DataBaseQueryFields.sArchetypeWhereClauseOnConfigObj;    
        }else if(checkMethodCallFrom.equalsIgnoreCase('Assessment')){
            sFieldsToQueryOnConfig = RE_DataBaseQueryFields.sAssessFieldsToQueryOnConfig;
            sWhereClauseOnConfigObj = RE_DataBaseQueryFields.sAssessWhereClauseOnConfigObj;
        }
        String sWhereClauseOnConfig = sWhereClauseOnConfigObj;
        Map<String,String> mapConfigQueryParameters = new Map<String,String>();
        mapConfigQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnConfig);
        Map<Boolean,String> mapConfigQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnConfig, mapConfigQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapConfigQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                if(checkMethodCallFrom.equalsIgnoreCase('Archetype')){
                	sConfigQuery =  RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, RE_DataBaseQueryFields.sFieldsToQueryOnConfigObjToLabel, mapConfigQueryParameters);    
                }else if(checkMethodCallFrom.equalsIgnoreCase('Assessment')){
                    sConfigQuery = RE_DataAccessChecker.getQueryStringforSetupObjects(RE_GlobalConstants.strConfigObjectName, sFieldsToQueryOnConfig, mapConfigQueryParameters);
                }                
              
               //   if(loggedinProfile  == RE_GlobalConstants.strCitizenProfileName){
                if(selectedRole  == RE_GlobalConstants.CITIZEN_INDIVIDUAL){
                   lstGoalConfig = Database.query(sConfigQuery); 
                }else{
                    lstGoalConfig = RE_SharingByPassCtrl.fetchGoalConfigRecords(sConfigQuery, setGoalId, goalConfigRecId);
                }
                
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getGoalConfigRecords', RE_GlobalConstants.FLS_ERROR + '' + mapConfigQueryResponse.get(false), true);
            }
        }
        return lstGoalConfig;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         20/09/2019
    * @methodname   getResourceTaxonomy()
    * @description  This methods is used to get the Resource Taxonomy records
    * @param        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy
    * @return       List<RE_Resource_Taxonomy__c> 
    **********************************************************************************************/
    public static List<RE_Resource_Taxonomy__c> getResourceTaxonomy(List<RE_Resource_Taxonomy__c> lstResourceTaxonomy, Set<Id> setTaxonomyId, Map<String,String> mapResTaxoInputParameters)
    {
        String sAccountStatus = mapResTaxoInputParameters.get('sAccountStatus');
        String checkMethodCallFrom = mapResTaxoInputParameters.get('checkMethodCallFrom');
        String sResTaxonomyQuery='';
        String sFieldsToQueryOnResTaxonomy = RE_DataBaseQueryFields.sFieldsToQueryOnResTaxonomy;
        String sWhereClauseOnResTaxonomy = RE_DataBaseQueryFields.sWhereClauseOnResTaxonomy;
        Map<String,String> mapResTaxonomyQueryParameters = new Map<String,String>();
        mapResTaxonomyQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnResTaxonomy);
        Map<Boolean,String> mapResTaxonomyQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strResTaxonomyObjectName, sFieldsToQueryOnResTaxonomy, mapResTaxonomyQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapResTaxonomyQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sResTaxonomyQuery =  mapResTaxonomyQueryResponse.get(true);
               
                if(checkMethodCallFrom.equalsIgnoreCase('Archetype')){
                    lstResourceTaxonomy = RE_SharingByPassCtrl.getResourceTaxonomy(sResTaxonomyQuery, setTaxonomyId, sAccountStatus);
                }else if(checkMethodCallFrom.equalsIgnoreCase('Assessment')){
                    lstResourceTaxonomy = RE_SharingByPassCtrl.getResourceTaxonomy(sResTaxonomyQuery, setTaxonomyId, sAccountStatus);
                }
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getResourceTaxonomy', RE_GlobalConstants.FLS_ERROR + '' + mapResTaxonomyQueryResponse.get(false), true);
            }
        }
        return lstResourceTaxonomy;
    }
    /********************************************************************************************
    * @author       Ashwin Kasture
    * @date         20/09/2019
    * @methodname   getLocationResource()
    * @description  This methods is used to get the Location Resource records
    * @param        List<LocationResource__c> lstLocationResource
    * @return       List<LocationResource__c> 
    **********************************************************************************************/
    public static List<LocationResource__c> getLocationResource(List<LocationResource__c> lstLocationResource, Set<Id> setResourceId, Map<String, String> mapLocationResInputs)
    {        
        Double dblLon,dblLat;
        if(mapLocationResInputs.containsKey('dblLat') && mapLocationResInputs.containsKey('dblLon')){
        	dblLat = Double.valueOf(mapLocationResInputs.get('dblLat'));
      	     dblLon = Double.valueOf(mapLocationResInputs.get('dblLon'));
        }
        else{
            dblLon=null;dblLat=null;
        }
        
        String checkMethodCallFrom = mapLocationResInputs.get('checkMethodCallFrom');
        
        String sLocResQuery;
        String sFieldsToQueryOnLocRes = RE_DataBaseQueryFields.sFieldsToQueryOnLocRes;
        String sWhereClauseOnLocRes = RE_DataBaseQueryFields.sWhereClauseOnLocRes;
        
        String sOrderByClauseOnLocRes = RE_DataBaseQueryFields.sOrderByClauseOnLocRes;
        If(dblLat == null && dblLon == null){
            sWhereClauseOnLocRes = RE_DataBaseQueryFields.sWhereClauseOnLocResWithoutDistance;
            sOrderByClauseOnLocRes = '';
        }
         //Integer iRadiusMiles = Integer.valueOf(System.Label.searchmilesradius);
        Map<String,String> mapLocResQueryParameters = new Map<String,String>();
        mapLocResQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClauseOnLocRes);
        If(dblLat != null && dblLon != null){
        mapLocResQueryParameters.put(RE_GlobalConstants.sOrderByKey, sOrderByClauseOnLocRes);
        }
        Map<Boolean,String> mapLocResQueryResponse = RE_DataAccessChecker.getFieldsAccessibility(RE_GlobalConstants.strLocResObjectName, sFieldsToQueryOnLocRes, mapLocResQueryParameters);
        RE_GlobalConstants.SWITCH_CONSTANTS switchCaseKey = (mapLocResQueryResponse.get(true) != null) ? RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_SUCCESS : RE_GlobalConstants.SWITCH_CONSTANTS.SWITCH_FAILURE;                                                                                
        switch on (switchCaseKey) {
            when SWITCH_SUCCESS {
                sLocResQuery =  mapLocResQueryResponse.get(true);
                Map<String, String> mapInputs = new Map<String, String>();
                mapInputs.put('sLocResQuery',sLocResQuery);
                If(dblLat != null && dblLon != null){
                	mapInputs.put('dblLat',String.valueOf(dblLat));
                	mapInputs.put('dblLon',String.valueOf(dblLon));
                }
                if(checkMethodCallFrom.equalsIgnoreCase('Archetype')){                    
                    lstLocationResource = RE_SharingByPassCtrl.getLocationResource(mapInputs, setResourceId);
                }else if(checkMethodCallFrom.equalsIgnoreCase('Assessment')){
                    lstLocationResource = RE_SharingByPassCtrl.getLocationResource(mapInputs, setResourceId);
                }
            }
            when SWITCH_FAILURE {
                LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, RE_AssessmentResultsHelper.class.getName(), 'getLocationResource', RE_GlobalConstants.FLS_ERROR + '' + mapLocResQueryResponse.get(false), true);
            }
        }
        return lstLocationResource;
    }
    
    /********************************************************************************************
    * @author       Sai Kiran
    * @date         08/19/2019
    * @methodname   getOptOutInfoSharingDetails()
    * @description  This methods is used to get OptOutInfoSharing Information from Account
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getOptOutInfoSharingDetails(){
        return RE_MyPlanCtrl.getOptOutInfoSharingDetails();
    }
    
    /********************************************************************************************
    * @author       Karthik Gulla
    * @date         08/19/2019
    * @methodname   connectDraftReferralsFromArcheTypeResults()
    * @description  This methods is used to connect Draft Referrals
    * @return       RE_CreateLightningServerResponse
    **********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse connectDraftReferralsFromArcheTypeResults(String sAchReferralId, Boolean bAchConsentAgreed){
        return RE_MyPlanCtrl.connectDraftReferrals(String.escapeSingleQuotes(sAchReferralId), bAchConsentAgreed);
    }
        /********************************************************************************************
	* @author       Ashwin Kasture
	* @date         15/07/2019
	* @methodname   insertReferralForResident()
	* @description  This methods is used to insert the referral
	* @param        String objResource
	* @return       RE_CreateLightningServerResponse  
	**********************************************************************************************/
    @AuraEnabled
    public static RE_CreateLightningServerResponse insertReferralForResident(String strobjResource, String locationID, Boolean bConsentAgreed){//String sArchid){
      GeneralUtility.isAuthenticatedUser();
        String objResource = strobjResource; //String.escapeSingleQuotes(strobjResource);
        Map<String, Object> mapRespone = (Map<String, Object>)JSON.deserializeUntyped(objResource);
            //RE_Release 1.4 - SOQL Injection Issue - Payal Dubela
            locationID=String.isNotBlank(locationID)?String.escapeSingleQuotes(locationID):locationID;
        Boolean bSuccess = false;
        Map<String, Object> errorMap = new Map<String, Object>();
        Map<String, Object> mapLighnResponse = new Map<String, Object>();
        List<Referral__c> referrallst = new List<Referral__c>();
        Boolean accountIsClaimed = false;
        String accountStatus = '';
        
        if(mapRespone.get('accountIsClaimed') != null){
            accountIsClaimed = Boolean.valueOf(mapRespone.get('accountIsClaimed'));
        }
        if(mapRespone.get('accountStatus') != null){
            accountStatus = String.valueOf(mapRespone.get('accountStatus'));
        }
             
        try{
            Referral__c objReferral= new Referral__c();
            
            if(accountIsClaimed && accountStatus == RE_GlobalConstants.sAccountStatus){
                objReferral.Status__c= RE_GlobalConstants.STATUS_NEW;
            }else if(!accountIsClaimed){
                objReferral.Status__c= RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM;
            } 
            Id contactId = GeneralUtility.getLoggedInUserContactId();
            objReferral.Contacts__c = contactId;
            //objReferral.Location__c = (Id)mapRespone.get('locationId');
            objReferral.Location__c = locationID;
            objReferral.Resource__c = (Id)mapRespone.get('resourceId');
            objReferral.ReferredAccountID__c = (Id)mapRespone.get('accountId');
            objReferral.OwnerId = UserInfo.getUserId();
            objReferral.DateOfReferral__c = Date.today();
            objReferral.Source__c= RE_GlobalConstants.ADDED_BY_RESIDENT;
           
            //added for archetype id
           // objReferral.Archetype__c=(Id)mapRespone.get('sArchetypeid');
            
            RE_SharingByPassCtrl.insertReferral(objReferral);   
            bSuccess = true;  
            if(bConsentAgreed){
                Account objAccount = new Account();
                objAccount.Id = GeneralUtility.getLoggedInUserAccountId();
                objAccount.HasOptedOutOfAccount__c = false;
                RE_SharingByPassCtrl.updateSobject(Account.getSObjectType(), objAccount);
            }
            mapLighnResponse.put('referals',objReferral);
        }catch(Exception e){
            errorMap.put('error',e.getMessage());LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error,'RE_ArchetypeCtrl', 'insertReferralForResident', e.getMessage()+' '+e.getStackTraceString(), true);}
 
        
        return new RE_CreateLightningServerResponse(bSuccess, errorMap, mapLighnResponse);        
    }
    /********************************************************************************************
    * @author       Nandita Bapaye
    * @date        04/10/2020
    * @methodname   loadMoreResources
    * @description  query and display goal resources on clickof Show All Resources.
    * @param        String sUserAssessId, String sGoalId,double dblLat,double dblLon
    * @return     RE_ArchetypeDetailWrapper.GoalBlockCls   
    **********************************************************************************************/
    @AuraEnabled
    public static RE_ArchetypeDetailWrapper.GoalBlockCls loadMoreResources(String sUserAssessId, String sGoalId,double dblLat,double dblLon)
    {   
        Integer resourceCount = 0;
        Location objResidentLocation;
        String selectedGoalId = sGoalId;
       
        Set<Id> setGoalId = new Set<Id>();
        Set<Id> setTaxonomyId = new Set<Id>();
        Set<Id> setResourceId = new Set<Id>();
        Set<Id> setLocationId = new Set<Id>();
        Set<Id> setLocResId = new Set<Id>();
       
        
        RE_AssessmentResultsWrapper objAssessmentWrapper = new RE_AssessmentResultsWrapper();
        List<RE_Config__c> lstConfigs = new List<RE_Config__c>();
        List<RE_Resource_Taxonomy__c> lstResourceTaxonomy = new List<RE_Resource_Taxonomy__c>();
        List<LocationResource__c> lstLocationResource = new List<LocationResource__c>();
        List<Favorite__c> lstFavoritesRes = new List<Favorite__c>();
        List<Location__c> LstLocation = new List<Location__c>();
        
        Map<Id,List<RE_Resource_Taxonomy__c>> mapTaxoIdLstResTaxo = new Map<Id, List<RE_Resource_Taxonomy__c>>();
       
        Map<Id,LocationResource__c> mapResourceWithLocation = new Map<Id, LocationResource__c>();
        Map<Id,Double> mapResourceWithMiles = new Map<Id, Double>();
        Map<Id,Map<String, List<String>>> mapOperatingHours = new Map<Id, Map<String, List<String>>>();
        Map<Id,Favorite__c> mapResourceVsFavorites = new Map<Id,Favorite__c>();
        Map<Id, Referral__c> mapResourceVsReferal = new Map<Id, Referral__c>();
        List<Referral__c> lstReferals = new List<Referral__c>();
       	Map<Id, Location__c> mapLocation = new Map<Id, Location__c>();
        
        objAssessmentWrapper.resourceCount = 0;
        objAssessmentWrapper.sUserAssessmentId = sUserAssessId;
        objAssessmentWrapper.bIsGuestUser = false;
        objAssessmentWrapper.bIsCPUserProfile = false;
        objAssessmentWrapper.bIsAgencyUserProfile = false; //RE_Release 1.1 - Agency User Capture - Siri
        
        objAssessmentWrapper.bIsResidentUser = false;
        RE_CreateLightningServerResponse objResponeUserRole;
        
        String loggedinProfile = GeneralUtility.getLoggedInUserProfileName();
        if(loggedinProfile != RE_GlobalConstants.strGuestProfileName){
            objResponeUserRole = RE_RDResidentViewCtrl.getLoggedInUserRole();
        }
        if(objResponeUserRole != null){
            objAssessmentWrapper.bIsGuestUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsGuestUser'));
            objAssessmentWrapper.bIsResidentUser = Boolean.valueOf(objResponeUserRole.objectData.get('bIsResidentorGuest'));
            objAssessmentWrapper.bIsCPUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsCPUserProfile'));
            objAssessmentWrapper.bIsAgencyUserProfile = Boolean.valueOf(objResponeUserRole.objectData.get('bIsAgencyUserProfile'));
        }
        
        objResidentLocation =location.newInstance(dblLat,dblLon);
       
        
        setGoalId.add(selectedGoalId);
        lstConfigs = RE_AssessmentResultsHelper.getGoalConfigRecords(setGoalId, null, 'Assessment');
        
        for(RE_Config__c objCon: lstConfigs){
            setTaxonomyId.add(objCon.Taxonomy__c);
        }
        Map<String,String> mapResTaxoInputParameters=new Map<String,String>();
        mapResTaxoInputParameters.put('sAccountStatus',RE_GlobalConstants.sAccountStatus);
        mapResTaxoInputParameters.put('checkMethodCallFrom','Assessment');
        lstResourceTaxonomy = RE_AssessmentResultsHelper.getResourceTaxonomy(lstResourceTaxonomy, setTaxonomyId, mapResTaxoInputParameters);
        for(RE_Resource_Taxonomy__c objResTax: lstResourceTaxonomy){
            setResourceId.add(objResTax.Resource__c);
            mapTaxoIdLstResTaxo = RE_AssessmentResultsHelper.getTaxoVsResTaxo(objResTax, mapTaxoIdLstResTaxo);    
        }
       
            Map<String, String> mapLocationResInputs = new Map<String, String>(); 
            if(dblLat != null && dblLon != null){       
                mapLocationResInputs.put('dblLat',String.valueOf(dblLat));
                mapLocationResInputs.put('dblLon',String.valueOf(dblLon));
            }
            mapLocationResInputs.put('checkMethodCallFrom','Assessment');
            
            lstLocationResource = RE_AssessmentResultsHelper.getLocationResource(lstLocationResource, setResourceId, mapLocationResInputs);
               
        for(LocationResource__c objResources:lstLocationResource)
        {    
                  
            setLocResId.add(objResources.Id);
            setLocationId.add(objResources.Location__c);
            mapResourceWithLocation.put(objResources.Resource__c, objResources);
            if(dblLat != null && dblLon != null){       
                Double dblMiles = RE_MyPlanHelper.getDistance(objResidentLocation, objResources.Location__r.Geolocation__c, 'mi');
                mapResourceWithMiles.put(objResources.Resource__c, dblMiles);
            }
        }
        if(!setLocationId.isEmpty()){
            LstLocation = RE_SharingByPassCtrl.getLocationOperatingHours(setLocationId);
            if(!LstLocation.isEmpty()){
                for(Location__c objLocation :LstLocation){
                    mapLocation.put(objLocation.id,objLocation);
                }
            }
        }

        if(!objAssessmentWrapper.bIsGuestUser){
            lstReferals = RE_ArchetypeDetailCtrl.getReferralRecords(lstReferals, setResourceId);
            for(Referral__c objReferal: lstReferals){
                mapResourceVsReferal.put(objReferal.Resource__c, objReferal);
            }
        }

        if(objAssessmentWrapper.bIsCPUserProfile || objAssessmentWrapper.bIsAgencyUserProfile){
           
            lstFavoritesRes = RE_ArchetypeDetailCtrl.getFavoriteResources(setLocResId);
            
            for(Favorite__c objFav: lstFavoritesRes){
                mapResourceVsFavorites.put(objFav.LocationResource__r.Resource__c, objFav);
            }               
        }
        
        /*---Start Assigning the Wrapper data---*/
        List<RE_AssessmentResultsWrapper.DomainBlockCls> lstDomainBlock = new List<RE_AssessmentResultsWrapper.DomainBlockCls>();
        List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstArGoal;
        List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> lstArRes;
     

                RE_ArchetypeDetailWrapper.GoalBlockCls objGoalBlock = new RE_ArchetypeDetailWrapper.GoalBlockCls();
                for(Id sTaxoId:mapTaxoIdLstResTaxo.keySet()){
                        List<RE_Resource_Taxonomy__c> lstResTaxo = mapTaxoIdLstResTaxo.get(sTaxoId); 
                        for(RE_Resource_Taxonomy__c objResTax: lstResTaxo)
                        {
                         
                            RE_ArchetypeDetailWrapper.ResourceTileBlockCls objResblock = new RE_ArchetypeDetailWrapper.ResourceTileBlockCls();
                            
                            if(mapResourceWithLocation != null && mapResourceWithLocation.containsKey(objResTax.Resource__c))
        					{
                             
                                RE_AssessmentResultsHelper.assignResourceBlock(objResblock, objResTax, mapResourceWithLocation, mapLocation);
                                RE_AssessmentResultsHelper.assignMilesData(objResblock, objResTax, mapResourceWithMiles);
                                assignFavoritesData(objResblock, objResTax, mapResourceVsFavorites);
                                assignReferalsData(objResblock, objResTax, mapResourceVsReferal);
                                lstArRes = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
                                objGoalBlock.lstResourceTile = RE_AssessmentResultsHelper.addNewResInExistingResList(objResblock, objGoalBlock, lstArRes);                       
                            }
                               
                         
                        }
                    }
                    if(objGoalBlock.lstResourceTile != null && !objGoalBlock.lstResourceTile.isEmpty()){
                            objGoalBlock.lstResourceTile.sort();
                    }
        return objGoalBlock;
    }
/********************************************************************************************
    * @author       Nandita Bapaye
    * @date        04/10/2020
    * @methodname   loadLessResources
    * @description  remove resources for goal resource list on click of See less resources
    * @param        String sGoalId,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> objGoalBlock
    * @return     RE_ArchetypeDetailWrapper.GoalBlockCls   
    **********************************************************************************************/
    @AuraEnabled
    public static RE_ArchetypeDetailWrapper.GoalBlockCls loadLessResources(String sGoalId,List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> objGoalBlock)
    { 
        
        RE_ArchetypeDetailWrapper.GoalBlockCls newObjGoalBlock = new RE_ArchetypeDetailWrapper.GoalBlockCls();
       List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls> newReslist = new List<RE_ArchetypeDetailWrapper.ResourceTileBlockCls>();
        if (!objGoalBlock.isEmpty()) {
            for (integer k = 0; k < 2; k += 1) {                      
                newReslist.Add(objGoalBlock[k]);        
            }
        newObjGoalBlock.lstResourceTile = newReslist;
        newObjGoalBlock.goalId = sGoalId;
        
        }
       return newObjGoalBlock;         
    }
    
    
}