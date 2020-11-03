/**
* Class Name    : ClaimTriggerHandler
* Owner         : DELOITTE
* Created Date  : 08/10/2020
* Description   : Helper class for ClaimTrigger
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  08/10/2020  Payal Dubela    Initial Version
********************************************************************
* 	
**/
public with sharing class ClaimTriggerHandler extends TriggerHandler  {

    public static void checkDuplicateEntry(List<ClaimMySiteRequest__c> newList,Map<Id,ClaimMySiteRequest__c> oldMap){
        List<String> lstEmail = new List<String>();
        List<ClaimMySiteRequest__c> claimsToCheck= new List<ClaimMySiteRequest__c>();
        List<ClaimMySiteRequest__c> claimsToCheckWithEmail= new List<ClaimMySiteRequest__c>();
        String switchCaseKey;
        for(ClaimMySiteRequest__c claim:newList){
            if(claim.Status__c !=oldMap.get(claim.Id).Status__c && 
               claim.Status__c== RE_GlobalConstants.CLAIM_STATUS_APPROVED && String.isNotBlank(claim.Email__c)){
                lstEmail.add(claim.Email__c);
                claimsToCheck.add(claim);
            }
        }

        if(!claimsToCheck.isEmpty()){
            Map<String, Integer> mapEmailDuplicate = GeneralUtility.checkDuplicateUser(lstEmail);
            for(ClaimMySiteRequest__c claim:claimsToCheck){
                // Force Reviewer Fixes : Kojashree Kakariya
                switchCaseKey = (mapEmailDuplicate!=null && mapEmailDuplicate.get(claim.Email__c) > 0)?'TRUE':'FALSE';
                switch on (switchCaseKey){
                    when 'TRUE'{
                        claim.addError(System.Label.contactmatchfounderror);  
                    }
                    when 'FALSE'{
                         claimsToCheckWithEmail.add(claim);
                    }
                }
            }
            if(!claimsToCheckWithEmail.isEmpty()){
                Map<String,List<Contact>> mapEmailWithContact= RE_SharingByPassCtrl.getDuplicateContacts(lstEmail);
                for(ClaimMySiteRequest__c claim:claimsToCheckWithEmail){
                   switchCaseKey = (mapEmailWithContact!=null && mapEmailWithContact.containsKey(claim.Email__c) &&  mapEmailWithContact.get(claim.Email__c).size()>1)? 'TRUE': 'FALSE';
                    switch on (switchCaseKey){
                        WHEN 'TRUE'{
                           claim.addError(System.Label.contactmatchfounderror);  
                        }
                    } // Force Reviewer Fixes : Kojashree Kakariya
                }

            }

        }

    }

}