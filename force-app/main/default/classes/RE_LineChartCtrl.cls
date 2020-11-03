public  with sharing class RE_LineChartCtrl {
    @auraEnabled
    public List<LineChartVar> myLineChartVarList;
    
    public class LineChartVar {
        integer mon;
        integer year;
        integer refSent;     
        
        public LineChartVar(integer a, integer b, integer c){
            mon = a;
            year = b;
            refSent = c;
            
        } 
    }    
    @auraEnabled
    public static RE_CreateLightningServerResponse getLineChartMap(){
        Map<String, Object> errorMap = new Map<String, Object>{};
            Map<String, Object> mapResponse = new Map<String, Object>{};
                Map<Boolean, String> mapResponseData = new Map<Boolean, String>();
        Map<String, String> mapQueryParameters = new Map<String, String>(); 
        
        List<AggregateResult> totalReferralSent;
        List<AggregateResult> totalReferralClosed;
        Boolean bSuccess = false;
        String sFieldsApiName;
        String sWhereClause;
        String sQuery;
        String switchCaseKey;
        
        List<LineChartVar> myLineChartSentList = new List<LineChartVar>();
        List<LineChartVar> myLineChartClosedList = new List<LineChartVar>();
        try{
            String loggedInAccountId = GeneralUtility.getLoggedInAccountId();
                        
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela         
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible()
               && Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && loggedInAccountId != null){
                  totalReferralSent=RE_SharingByPassCtrl.getTotalReferralSent(loggedInAccountId);
                   //
               }
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            if(totalReferralSent!=null && !totalReferralSent.isEmpty()){
                for( AggregateResult t : totalReferralSent){
                    myLineChartSentList.add(new LineChartVar(Integer.valueOf(t.get('month')),Integer.valueOf(t.get('year')),Integer.valueOf(t.get('totalref'))));
                }  
            }
            
            if(Referral__c.getSObjectType().getDescribe().isAccessible() &&  Schema.sObjectType.Referral__c.fields.Name.isAccessible() && Schema.sObjectType.Referral__c.fields.DateOfReferral__c.isAccessible() && Schema.sObjectType.Referral__c.fields.Status__C.isAccessible() && Schema.sObjectType.Referral__c.fields.ReferredAccountID__c.isAccessible() && loggedInAccountId!=null){
                totalReferralClosed = [SELECT COUNT(Name) totalref,CALENDAR_MONTH(DateOfReferral__c) month,CALENDAR_year(DateOfReferral__c) Year FROM Referral__c where ReferredAccountID__c=:loggedInAccountId AND (DateOfReferral__c=LAst_N_Months:4 or DateOfReferral__c =THIS_Month ) AND Status__C =: RE_GlobalConstants.REFERRAL_STATUS_CLOSED GROUP BY CALENDAR_YEAR(DateOfReferral__c), CALENDAR_MONTH(DateOfReferral__c) ORDER BY CALENDAR_YEAR(DateOfReferral__c), CALENDAR_MONTH(DateOfReferral__c) ASC ];
                
                //
            }
            //RE_Release 1.2 – ForceReviwer Issues - Payal Dubela 
            if(totalReferralClosed!=null && !totalReferralClosed.isEmpty()){
                for( AggregateResult t : totalReferralClosed){
                    myLineChartClosedList.add(new LineChartVar(Integer.valueOf(t.get('month')),Integer.valueOf(t.get('year')),Integer.valueOf(t.get('totalref'))));
                }  
            }
            //
            mapResponse.put('ReferralSent',JSON.Serialize(myLineChartSentList));
            mapResponse.put('ReferralClosed',JSON.Serialize(myLineChartClosedList));
            bSuccess = true;
            //
            //
            
        }catch(Exception e){
            bSuccess = false; errorMap.put('error', e.getMessage()); LOG_LogMessageUtility.logMessage(LOG_LogMessageUtility.LOG_LogLevel.Error, 'RE_LineChartCtrl','getLineChartMap', e.getMessage(), true);
            //
        }
        
        return new RE_CreateLightningServerResponse(bSuccess,errorMap,mapResponse);
       
    }
    
    
    
}