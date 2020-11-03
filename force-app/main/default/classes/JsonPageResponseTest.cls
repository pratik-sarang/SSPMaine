@isTest
private class JsonPageResponseTest {
    @isTest
    public static void testJsonPageResponse() {
        Test.startTest();
        List<JsonPageResponse.ValidationMessage> vMessages = new List<JsonPageResponse.ValidationMessage>();
        JsonPageResponse.ValidationMessage newMessage = new JsonPageResponse.ValidationMessage();
        newMessage.fieldName = 'testFieldName';
        newMessage.errCode = 'testErrCode';
        newMessage.errMsg = 'testErrMsg';
        vMessages.add(newMessage);

        JsonPageResponse jsonPageResponse1 = new JsonPageResponse();

        jsonPageResponse1.pageObjectData = vMessages;

        jsonPageResponse1.sObj = new Contact();

        jsonPageResponse1.vMessages = vMessages;

        NavFlowDetail__mdt navFlowDetail = [SELECT Id FROM NavFlowDetail__mdt LIMIT 1];

        NavFlowPageConfig__mdt navFlowPageConfig = [SELECT Id FROM NavFlowPageConfig__mdt LIMIT 1];

        PageInfo__mdt pageInfoMdt = [SELECT Id FROM PageInfo__mdt LIMIT 1];

        JsonPageResponse.PageInfo pageInf = new JsonPageResponse.PageInfo(navFlowPageConfig);
        pageInf.pageInfoMdt = pageInfoMdt;
        pageInf.objectSchema = 'testObjectSchema';
        pageInf.layoutSchema = 'testLayoutSchema';
        pageInf.picklistsRecordTypeId = 'CCO0983948931AI';

        JsonPageResponse.PageInfo pageInf1 = new JsonPageResponse.PageInfo(pageInfoMdt);
        JsonPageResponse.PageInfo pageInf2 = new JsonPageResponse.PageInfo('testObjectSchema', 'testLayoutSchema');

        JsonPageResponse.PageConfData pageConfData = new JsonPageResponse.PageConfData();
        pageConfData.navFlowDetail = navFlowDetail;
        pageConfData.pageInf = pageInf;

        jsonPageResponse1.pageConfData = pageConfData;

        JsonPageResponse.JsonPageException jsonPageException = new JsonPageResponse.JsonPageException('9878', 'testMessage');

        try {
            String str = null;
            Integer i = str.length();
        } catch(Exception ex) {
            jsonPageException = new JsonPageResponse.JsonPageException('9878', 'testMessage', ex);
        }

        JsonPageResponse.SobjectInfo sobjectInfo = new JsonPageResponse.SobjectInfo();
        sobjectInfo.objectName = 'Contact';
        sobjectInfo.fieldName = 'Email';
        sobjectInfo.recordTypeName = 'testRecordTypeName';

        JsonPageResponse.ObjectSchema objectSchema = new JsonPageResponse.ObjectSchema();
        objectSchema.sobjectInfo = sobjectInfo;
        objectSchema.controller = 'testController';
        objectSchema.isSaveOnSubmit = true;
        Test.stopTest();
    }
}