/**
* Class Name    : RE_CalculateRatingCountSum
* Owner         : DELOITTE
* Created Date  : 08/30/2019
* Description   : This class is called from process builder to calculate rating count 
                and sum on Account, Location and resource objects
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  08/30/2019  Deeksha      Initial Version
*  
**/
public with sharing class RE_CalculateRatingCountSum {

    @InvocableMethod
    public static void calculateRatingCountSum(List<String> setIds){
        String accountId;
        String locationId;
        String resourceId;
        for (String sParam : setIds) {
            List<String> listParams = sParam.split(';');
            if (listParams != null && !listParams.isEmpty() && listParams.size()>0) {
                accountId=listParams[0].trim();
                locationId=listParams[1].trim();
                resourceId=listParams[2].trim();
            }            
        }
        RE_CalculateRatingCountSum.getFeedbackRecords(Id.valueOf(accountId),(!String.isEmpty(locationId))?Id.valueOf(locationId):null,Id.valueOf(resourceId));                                          
    }
    
    public static void getFeedbackRecords(Id accountId, Id locationId, Id resourceId){
        List<Feedback__c> lstFeedbackRecords = RE_SharingByPassCtrl.getPartnerFeedbackRecords(accountId,locationId,resourceId);
        List<Feedback__c> lstFeedbackAccountRecords = new List<Feedback__c>();
        List<Feedback__c> lstFeedbackLocationRecords = new List<Feedback__c>();
        List<Feedback__c> lstFeedbackResourceRecords = new List<Feedback__c>();  
        Integer ratingSumAccount =0;
        Integer ratingSumLocation =0;
        Integer ratingSumResource =0;
        for(Feedback__c feedObj : lstFeedbackRecords){
            if(feedObj.AccountID__c == accountId){
                /*if(feedObj.Rating__c == 1){
                    ratingSumAccount+1;
                }*/
                ratingSumAccount = (feedObj.Rating__c == 1)?ratingSumAccount+1:ratingSumAccount;
                lstFeedbackAccountRecords.add(feedObj);
            }
            if(locationId!=null && feedObj.Referral__r.Location__c == locationId){
                /*if(feedObj.Rating__c == 1){
                    ratingSumLocation+=1;
                }*/
                ratingSumLocation = (feedObj.Rating__c == 1)?ratingSumLocation+1:ratingSumLocation;
                lstFeedbackLocationRecords.add(feedObj);
            }
            if(feedObj.Referral__r.Resource__c == resourceId){
                /*if(feedObj.Rating__c == 1){
                    ratingSumResource+=1;
                }*/
                ratingSumResource = (feedObj.Rating__c == 1)?ratingSumResource+1:ratingSumResource;
                lstFeedbackResourceRecords.add(feedObj);
            }
        }
        Account accObj = new Account(Id =  Id.valueOf(accountId), Rating_Count__c=lstFeedbackAccountRecords.size(),Rating_Sum__c=ratingSumAccount);
        RE_SharingByPassCtrl.updateSobject(Account.getsObjectType(), accObj);
        if(locationId!=null){
           Location__c locObj = new Location__c(Id =  Id.valueOf(locationId), Rating_Count__c=lstFeedbackLocationRecords.size(),Rating_Sum__c=ratingSumLocation);
           RE_SharingByPassCtrl.updateSobject(Location__c.getsObjectType(), locObj);
        }
        Resource__c resObj  = new Resource__c(Id =  Id.valueOf(resourceId), Rating_Count__c=lstFeedbackResourceRecords.size(),Rating_Sum__c=ratingSumResource);
        RE_SharingByPassCtrl.updateSobject(Resource__c.getsObjectType(), resObj);
        
    }
}