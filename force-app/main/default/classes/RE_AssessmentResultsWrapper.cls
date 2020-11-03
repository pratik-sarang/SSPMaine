/**************************************************************************************************
* Class Name    : RE_AssessmentResultsHelper 
* Owner         : Ashwin Kasture
* Created Date  : 11/09/2019
* Description   : Assessment Results Wrapper class
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*  11/09/2019  Ashwin Kasture 	Initial Development
**/
public with sharing class RE_AssessmentResultsWrapper 
{
    @AuraEnabled public String sUserAssessmentId {get;set;}
    @AuraEnabled public String sAssessmentTemplateId {get;set;}    
    @AuraEnabled public String sAssessTemplateName {get;set;}
    @AuraEnabled public String sResidentName {get;set;}
    @AuraEnabled public String sResidentId {get;set;}
    @AuraEnabled public String sPartnerName {get;set;}
    @AuraEnabled public String sDateTaken {get;set;}
    @AuraEnabled public Integer resourceCount {get;set;}
    @AuraEnabled public Boolean bIsGuestUser {get;set;}
    @AuraEnabled public Boolean bIsResidentUser {get;set;}
    @AuraEnabled public Boolean bIsCPUserProfile {get;set;}
    @AuraEnabled public Boolean bIsAgencyUserProfile {get;set;}  //RE_Release 1.1 - Agency User Capture - Siri
    @AuraEnabled public List<DomainBlockCls> lstDomainBlock {get;set;}    
    @AuraEnabled public List<QuestionAnswerCls> lstQuestionAnswer {get;set;}
    @AuraEnabled public double dblat{get;set;}//Nandita: 04/10/2020: added parameters as a part of perf issue# 357266
    @AuraEnabled public double dblong{get;set;}//Nandita: 04/10/2020: added parameters as a part of perf issue# 357266
    public class DomainBlockCls implements Comparable
    {
        @AuraEnabled public String sSDOHDomain {get;set;}
        @AuraEnabled public Decimal iScore {get;set;}
        @AuraEnabled public String sDomainQuestion {get;set;}
        @AuraEnabled public String sSDOHDomainDescriptn {get;set;}
        @AuraEnabled public String sScoreColorStatus {get;set;}
        @AuraEnabled public List<RE_ArchetypeDetailWrapper.GoalBlockCls> lstGoalBlock {get; set;}
        
        //to compare
           public Integer compareTo(Object compareTo) {
            DomainBlockCls compareToEmp = (DomainBlockCls)compareTo;
            if (iScore == compareToEmp.iScore){
                return 0;
            }
            if (iScore == null || iScore > compareToEmp.iScore){
                return 1;
            }            
            return -1;
        }
    
        
    }
    public class QuestionAnswerCls
    {
        @AuraEnabled public String sQuestion {get;set;}
        @AuraEnabled public String sAnswer {get;set;}
    }
}