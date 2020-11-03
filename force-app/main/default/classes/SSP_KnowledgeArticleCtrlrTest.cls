/***************************************************************************************************************************
*   Type        :   Knowledge article search logic Test
*   Name        :   SSP_KnowledgeArticleCtrlrTest
*   Create By   :   Tommaso Massari
*   Create Date :   24 Jul 2020
*   Description :   This is a test class for SSP_KnowledgeArticleCtrlr
*   Modification Log:
*   --------------------------------------------------------------------------------------
*    Developer                  Date                    Description
*   --------------------------------------------------------------------------------------
*    Tommaso Massari           Jul-24-2020             Initial Version
*
*****************************************************************************************************************************/

@isTest
public class SSP_KnowledgeArticleCtrlrTest {


    /**
     * searchArticleTestSuccessfulSearchEN - it tests the functionality of search article in english, for all relevant fields of search:
     * Title, Answer and Question
     */
    @isTest static void searchArticleTestSuccessfulSearchEN() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();
        SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'titleTest5', 'en_US', '');

        system.assert(res != null);
        res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'titleQuestion2', 'en_US', '');

        system.assert(res != null);  
        res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'answerTest6', 'en_US', '');
        Test.stopTest();

        system.assert(res != null);
    }

    /**
     * searchArticleTestSuccessfulSearchES - it tests the functionality of search article in spanish, for all relevant fields of search:
     * Title, Answer and Question
     */

    @isTest static void searchArticleTestSuccessfulSearchES() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();
        SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'titleTestEs5', 'es_US', '');

        system.assert(res != null);
        res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'titleQuestionEs2', 'es_US', '');

        system.assert(res != null);

        
        res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'answerTestEs6', 'es_US', '');
        Test.stopTest();

        system.assert(res != null);
    }

    /**
     * searchArticleTestInvalidLanguage - it tests the functionality of search article when an invalid language is passed
     */
    @isTest static void searchArticleTestInvalidLanguage() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();


        try{
            SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'titleTestEs5', 'INVALID', '');
        }

        catch (Exception e){
            system.assertEquals(e.getTypeName(), 'InvalidLanguageCodeException');
        }
        Test.stopTest();
    }

    /**
     * searchArticleTestSuccessfulSearchInCategories - it tests the functionality of search article given a language for initial display.
     */
    @isTest static void searchArticleTestSuccessfulSearchInCategories() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();
        SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('searchArticles', 'kynect', 'es_US', '');
        Test.stopTest();

        system.assert(res != null);
    }

    /**
     * getCategoriesTest - it tests the functionality of retrieving categories
     */
    @isTest static void getCategoriesTest() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();
        SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('getKACategories', '', '', '');
        Test.stopTest();

        system.assert(res != null);
    }

    /**
     * getArticlesTest - it tests the functionality of search article given a category.
     */
    @isTest static void getArticlesTest() {

        Test.startTest();
        List<FAQ__kav> articles = TestDataFactory.createFAQ();
        SSP_LightningResponse res = SSP_KnowledgeArticleCtrlr.exec('getKArticles', '', 'es_US', 'BA_General kynect benefits Information');
        Test.stopTest();

        system.assert(res != null);
    }

}