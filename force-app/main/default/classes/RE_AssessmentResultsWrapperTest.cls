@isTest
public class RE_AssessmentResultsWrapperTest {
    
    @isTest
    public static void DomainBlockCls(){
        RE_AssessmentResultsWrapper obj= new RE_AssessmentResultsWrapper();
        obj.sUserAssessmentId= 'Test';
        obj.sAssessmentTemplateId='Test1';
        obj.sAssessTemplateName='Test2';
        obj.sResidentName='Test3';
        obj.sResidentId='Test4'; 
        obj.sPartnerName='Test5';  
        obj.sDateTaken='Test6';
        obj.resourceCount=5;
        obj.bIsGuestUser= true;
        obj.bIsResidentUser= true; 
        obj.bIsCPUserProfile= true;
        obj.bIsAgencyUserProfile= true;
        obj.dblat=5.1;
        obj.dblong=5.2;     
        RE_AssessmentResultsWrapper.DomainBlockCls objDomain = new RE_AssessmentResultsWrapper.DomainBlockCls();
        objDomain.sDomainQuestion ='Test7';
        objDomain.sSDOHDomainDescriptn ='Test8';
        objDomain.sScoreColorStatus ='Test9';
        objDomain.sSDOHDomain ='Test10';
        RE_AssessmentResultsWrapper.DomainBlockCls objDomainComp = new RE_AssessmentResultsWrapper.DomainBlockCls();  
        objDomain.iScore = 1.1;
        objDomainComp.iScore= 1.1;
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        Integer diff=objDomain.compareTo(objDomainComp);
        System.assertEquals(diff, 0,'Positive Scenario'); 
    }
    @isTest
    public static void DomainBlockCls1(){
        RE_AssessmentResultsWrapper.DomainBlockCls objDomain = new RE_AssessmentResultsWrapper.DomainBlockCls();
        RE_AssessmentResultsWrapper.DomainBlockCls objDomainComp = new RE_AssessmentResultsWrapper.DomainBlockCls();     
        objDomain.iScore = 2.1;
        objDomainComp.iScore= 1.1;
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        Integer diff=objDomain.compareTo(objDomainComp);
        System.assertEquals(diff,1,'Positive Scenario');
    }
    
    @isTest
    public static void DomainBlockCls2(){
        RE_AssessmentResultsWrapper.DomainBlockCls objDomain = new RE_AssessmentResultsWrapper.DomainBlockCls();
        RE_AssessmentResultsWrapper.DomainBlockCls objDomainComp = new RE_AssessmentResultsWrapper.DomainBlockCls();     
        objDomain.iScore = 1.1;
        objDomainComp.iScore= 2.1;
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        Integer diff=objDomain.compareTo(objDomainComp);
        System.assertEquals(diff,-1,'Positive Scenario');
    }
    @isTest
    public static void DomainBlockCls3(){
        RE_AssessmentResultsWrapper.QuestionAnswerCls objQuesAns = new RE_AssessmentResultsWrapper.QuestionAnswerCls();
        objQuesAns.sQuestion= 'Test11';
        objQuesAns.sAnswer= 'Test12';
        //RE_Release 1.3 – ForceReviewer - Payal Dubela
        System.assertEquals(objQuesAns.sQuestion,'Test11','Positive Scenario');
    }
}