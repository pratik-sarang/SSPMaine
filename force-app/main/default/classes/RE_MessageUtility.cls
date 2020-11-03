public with sharing class RE_MessageUtility {
    @future(callout=true)
    public static void referralClosureSMS(String surveylink,String objrefId, String objrefName, String phone, String resName, String refaccountId)
    {  
        Map<String, String> mapInputWrapper = new Map<String, String>();
        Map<String, Object> mapObjects = new Map<String, Object>();
        
        mapInputWrapper.put('toPhone', phone);
        mapObjects.put('resourceId', objrefId);
        mapObjects.put('sResourceName', objrefName);
        String shortlink = RE_URLShortener.getShortenedURL(surveylink,'RebrandlyShortURL');
        
        String templateBody = String.format(Label.Follow_Up_Text_Message, new List<String>{resName,refaccountId,shortlink});
        RE_ShareEmailCtrl.triggerSmsFramework(templateBody, mapInputWrapper, mapObjects);
    }
    
    
    @future(callout=true)
    public static void consentSMS(String surveylink,String objId, string objName,String sUserName, String sPhone, String sEmail, String toPhone )
    {   
        Map<String, String> mapInputWrapper = new Map<String, String>();
        Map<String, Object> ObjectDetailsWrapper = new Map<String, Object>();
        
        mapInputWrapper.put('yourName',sUserName);
        mapInputWrapper.put('yourEmail',UserInfo.getUserEmail());
        mapInputWrapper.put('yourPhone',sPhone);
        mapInputWrapper.put('toEmail',sEmail);
        mapInputWrapper.put('toPhone',toPhone);
        ObjectDetailsWrapper.put('resourceId',objId);
        ObjectDetailsWrapper.put('sResourceName',objName);
        String shortlink = RE_URLShortener.getShortenedURL(surveylink,'RebrandlyShortURL');
        String strPhoneTemplateBody = String.format(Label.RE_SendConsentText, new List<String>{ sUserName,shortlink});
        RE_ShareEmailCtrl.triggerSmsFramework(strPhoneTemplateBody,mapInputWrapper,ObjectDetailsWrapper);
    }
}