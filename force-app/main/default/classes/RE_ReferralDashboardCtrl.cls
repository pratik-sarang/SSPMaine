/*
* Component Name    : RE_ReferralDashboardCtrl
* Owner             : Sai Kiran Velpula
* Created Date      : 09/11/2019
* Description       : Referral Dashboard Controller
*/

public with sharing class RE_ReferralDashboardCtrl {
    
    /*
* Method Name    	: getStatisticsData
* Description       : return Report Statistics Data
*/
    @AuraEnabled
    public static RE_CreateLightningServerResponse getStatisticsData(){
        GeneralUtility.isAuthenticatedUser();
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        Set<String> referralStatus = new Set<String>();
        referralStatus.add(RE_GlobalConstants.STATUS_NEW);
        referralStatus.add(RE_GlobalConstants.STATUS_INPROGRESS_ORG_IN_SYSTEM);
        referralStatus.add(RE_GlobalConstants.STATUS_INPROGRESS_ORG_NOT_IN_SYSTEM);
     
        Boolean bSuccess = false;
        String sFieldsApiName;
        String sWhereClause;
        String sQuery;
        String switchCaseKey;
        Decimal orgRating;
        Integer dayDifference = 0;
        Integer avgDaysToClose;
        
        List<AggregateResult> totalClientsServed;
        List<AggregateResult> mostReferredByOrg;
        List<AggregateResult> mostReferredToOrg;
        List<AggregateResult> referralsReceived;
        List<AggregateResult> referralsOpen;
        List<AggregateResult> referralsClosed;
        List<AggregateResult> referralsMade;
        try{
            String loggedInAccountId = GeneralUtility.getLoggedInAccountId();
           
            //To get the Org Rating to display on the Report.
            //Account objAccount = [SELECT ID, Rating_Count__c, Rating_Sum__c FROM Account Where ID =:loggedInAccountId ];
            //Account objAccount;
            List<Account> objAccount = new List<Account>();
            sFieldsApiName = RE_DataBaseQueryFields.sAccountFieldsReferralDashboardCtrl;
            sWhereClause = RE_DataBaseQueryFields.sAccountWhereClauseReferralDashboardCtrl;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Account', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    objAccount = Database.query(sQuery); 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDashboardCtrl','getStatisticsdata','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            // Force Reviewer Fixes : Kojashree Kakariya
           if(objAccount.size()>0){
                switchCaseKey = (objAccount[0].Rating_Sum__c!= NULL && objAccount[0].Rating_Count__c >0)== TRUE ? 'TRUE' : 'FALSE';
                switch on (switchCaseKey) {
                    when 'TRUE' {
                        orgRating = (objAccount[0].Rating_Sum__c/objAccount[0].Rating_Count__c)*100; 
                    	orgRating = orgRating.setScale(0); 
                    }
                    when 'FALSE' {
                      orgRating = 0;  
                    }
                }
               
            }
            
            
            
            //To get the Avg Days to Close a Referral to display on the Report.
            //List<Referral__c> objReferralList = [SELECT DateClosed__c, DateOfReferral__c FROM Referral__c Where Status__c ='Closed' AND DateOfReferral__c !=NULL AND DateClosed__c!=NULL];
           //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            List<Referral__c> objReferralList= new List<Referral__c>();
            sFieldsApiName = RE_DataBaseQueryFields.sReferralFieldsReferralDashboardCtrl;
            sWhereClause = RE_DataBaseQueryFields.sReferralWhereClauseReferralDashboardCtrl;
            mapQueryParameters.put(RE_GlobalConstants.sWhereClauseKey, sWhereClause);
            mapResponseData = RE_DataAccessChecker.getFieldsAccessibility('Referral__c', sFieldsApiName, mapQueryParameters);
            switchCaseKey = (mapResponseData.get(true) != null) ? 'success' : 'failure';                                                                                
            switch on (switchCaseKey) {
                when 'success' {
                    sQuery =  mapResponseData.get(true);
                    objReferralList = Database.query(sQuery); 
                }
                when 'failure' {
                    LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDashboardCtrl','getStatisticsdata','Some Fields doesn\'t have the required access :: '+mapResponseData.get(false), true);
                }
            }
            for(Referral__c objReferral : objReferralList){
                dayDifference = dayDifference + objReferral.DateOfReferral__c.daysBetween(objReferral.DateClosed__c);
            }
            if(!objReferralList.isEmpty()){
                avgDaysToClose = dayDifference/objReferralList.size();
            }
            //Aggregate Query to get the Count of Most Reffered by Ogr to the Current Org in Last 6 MonthsGroup By Reffered by Org
            //Nupoor: Added object and field accessibility check
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible()
               && Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible()
               && Schema.sObjectType.Referral__c.fields.ReferredByAccountID__c.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && loggedInAccountId!=null){
               		mostReferredByOrg=RE_SharingByPassCtrl.getMostReferredByOrg(loggedInAccountId);
               }
            //Aggregate Query to get the Count of Most Reffered to Ogr from the Current Org  in Last 6 Months Group By Reffered to Org
        
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible()
               && Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible()){
                   mostReferredToOrg = RE_SharingByPassCtrl.mostReferralsReferredToOrg();
               }
            //Aggregate Query to get the Count of total Clients Served in the Current Org in Last 6 Months
            //Nupoor: Added object and field accessibility check
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Contacts__c.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && loggedInAccountId!=null ){
                //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                totalClientsServed = [SELECT COUNT(Contacts__c),COUNT(Name) FROM Referral__c where ReferredAccountID__c != null AND ReferredAccountID__c=:loggedInAccountId and (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month)]; 
            }
            //Aggregate Query to get the Count of Referral Received to the Current Org in Last 6 Months
            //Nupoor: Added object and field accessibility check
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && loggedInAccountId!=null){
               //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                referralsReceived=totalClientsServed;
            }
            //Aggregate Query to get the Count of Referral Open in the Current Org in Last 6 Months
            //Nupoor: Added object and field accessibility check
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Status__C.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && referralStatus!=null && loggedInAccountId!=null){
                //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                referralsOpen=getOpenReferrralCount(referralStatus,loggedInAccountId);
            }
            //Aggregate Query to get the Count of Referral Closed in the Current Org in Last 6 Months
            //Nupoor: Added object and field accessibility check
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Status__C.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && loggedInAccountId!=null){
                //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
                referralsClosed=getClosedReferrralCount(loggedInAccountId);
            }
            //Aggregate Query to get the Count of Referral Made from the Current Org in Last 6 Months
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredByAccountID__c.isAccessible() && loggedInAccountId!=null){
            	referralsMade=RE_SharingByPassCtrl.getReferralsMade(loggedInAccountId);
            }
            
            
            StatisticsWrapper statisticsData = New StatisticsWrapper();
            statisticsData.mostReferredByOrg = mostReferredByOrg;
            statisticsData.mostReferredToOrg = mostReferredToOrg;
            statisticsData.orgRating = orgRating;
            statisticsData.totalClientsServed = totalClientsServed;
            statisticsData.avgDaysToClose = avgDaysToClose;
            statisticsData.referralsOpen = referralsOpen;
            statisticsData.referralsReceived = referralsReceived;
            statisticsData.referralsClosed = referralsClosed;
            statisticsData.referralsMade = referralsMade;
            
            bSuccess = true;
            mapResponse.put('statisticsData',statisticsData);        
        }catch(Exception e) {
            bSuccess = false; errorMap.put('error', e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_ReferralDashboardCtrl','getStatisticsData', e.getMessage(), true);
        }
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
    }

    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    public static List<AggregateResult> getOpenReferrralCount(Set<String> referralStatus,String loggedInAccountId){
        return [SELECT COUNT(Name) FROM Referral__c where  ReferredAccountID__c != null AND ReferredAccountID__c=:loggedInAccountId AND (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month) AND Status__C IN : referralStatus];
    }
    //RE_Release 1.1 –ForceReviewer Changes- Payal Dubela
    public static List<AggregateResult> getClosedReferrralCount(String loggedInAccountId){
       return [SELECT COUNT(Name) FROM Referral__c where ReferredAccountID__c != null AND ReferredAccountID__c=:loggedInAccountId AND (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month) AND Status__C =: RE_GlobalConstants.REFERRAL_STATUS_CLOSED];
    }
    public class StatisticsWrapper{
        @AuraEnabled public List<sObject> mostReferredByOrg;
        @AuraEnabled public List<sObject> mostReferredToOrg;
        
        @AuraEnabled public Decimal orgRating;
        @AuraEnabled public List<sObject> totalClientsServed;
        @AuraEnabled public Integer avgDaysToClose;
        
        @AuraEnabled public List<sObject> referralsOpen;
        @AuraEnabled public List<sObject> referralsReceived;
        @AuraEnabled public List<sObject> referralsClosed;
        @AuraEnabled public List<sObject> referralsMade;
        
    }
    
    
    
}