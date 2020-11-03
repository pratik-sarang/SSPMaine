/**************************************************************************************************
* Class Name    : RE_AssessmentQuestionsWrapper 
* Owner         : Prashant
* Created Date  : 09/12/2019
* Description   : User wrapper to wrap Questions and answers
*
*                            M O D I F I C A T I O N   L O G                                          
*
*  Date        Developer       Description                                                         
*  ----------  -----------     -------------------------------------------------------------------
*
**/

public with sharing class RE_AssessmentQuestionsWrapper {
  /*  @AuraEnabled
    public Map<Question,List<AnswerChoice>> questionsAnswersMap{get;set;}
   	@AuraEnabled
    public Map<Question,AnswerChoice> selectedAnswersMap{get;set;}
    
    @AuraEnabled
    public String sJSONQuestion{get;set;}
	*/
    //ID should be string or ID attribute
    
    @AuraEnabled 
    public static Boolean bIsAnonymous{get;set;}
    
   
    public class Question{
        @AuraEnabled public ID questionId {get; set;}
        // @AuraEnabled public String sAssessmentTemplateId {get; set;}
        @AuraEnabled public Boolean bTextAnswerType {get; set;}
        @AuraEnabled public String sAssessment {
            get{if(sAssessment!= null) return String.escapeSingleQuotes(sAssessment);
            else return sAssessment;} set;}
        @AuraEnabled public String sQuestion {
        get{if(sQuestion!= null) return String.escapeSingleQuotes(sQuestion);
            else return sQuestion;} 
            set;}
        @AuraEnabled public String sResponse {
            get{if(sResponse!= null)  return String.escapeSingleQuotes(sResponse);
            else return sResponse; } set;}
        //  @AuraEnabled public String sResponseId {get; set;}
        @AuraEnabled public String sSDOH {
            get{if(sSDOH!= null) return String.escapeSingleQuotes(sSDOH);
            else return sSDOH;} set;}
        @AuraEnabled public Decimal dQuesOrder {get; set;}
        @AuraEnabled public Boolean bIsRequired {get; set;}
        @AuraEnabled public String sAnswerType {
            get{if(sAnswerType!= null)return String.escapeSingleQuotes(sAnswerType);
            else return sAnswerType;} set;}
        //  @AuraEnabled public List<RE_AssessmentQuestionsWrapper.AnswerChoice> lstAnswerChoices {get; set;}
        //    @AuraEnabled public Map<String,String> mapResponseValue {get; set;}
        //    @AuraEnabled public Map<Decimal,String> mapResponseId {get; set;}
        @AuraEnabled public List<RE_AssessmentQuestionsWrapper.OptionsWrapper> lstOptions {get; set;}
        
        public Question(Question__c objques){
            this.questionId = objques.Id;
            this.sAnswerType = objques.AnswerType__c; 
            this.sAssessment = objques.Assessment__c;
            this.sQuestion = objques.Question__c;
            this.sSDOH = objques.SDOH__c;
            this.dQuesOrder=objques.QuestionOrder__c;
            this.bIsRequired = objques.IsRequired__c;
            if(objques.AnswerType__c=='Free Text'){
                this.bTextAnswerType=true;
            }else{
                this.bTextAnswerType=false;
            }
            
        }
        
    }
    
    public class AnswerChoice{
        @AuraEnabled public ID answerChoiceId {get; set;}
        @AuraEnabled public String sQuestion {
            get{if(sQuestion!= null) return String.escapeSingleQuotes(sQuestion);
                else return sQuestion;} set;}
        @AuraEnabled public Decimal dScore {get; set;} 
        @AuraEnabled public String sAnswer {
            get{if(sAnswer!= null)return String.escapeSingleQuotes(sAnswer);
            else return sAnswer;} set;}
        
        public AnswerChoice(AnswerChoice__c objans){
            this.answerChoiceId = objans.Id;
            this.sQuestion = objans.Question__c; 
         	this.dscore = objans.Score__c;
            this.sAnswer=objans.Answer__c;
        }
    }
     public class OptionsWrapper{
        @AuraEnabled public String label {
            get{if(label!= null)return String.escapeSingleQuotes(label);
            else return label;} set;}
         @AuraEnabled public String value {
            get{if(value!= null) return String.escapeSingleQuotes(value);
            else return value;} set;}
     }
    
}