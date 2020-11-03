/*********************************************************************************************************************************
* Class Name    : CPMFAController 
* Owner         : Deloitte
* Created Date  : 12/16/2019
* Description   : 
*/
public class RE_CPMFAController {
    
    public  String  SSOAttributeValues {get;set;}
    public  String  getPageCountValue {get;set;}
    public  String  MFACP {get;set;}
    public  String  MFANONCP {get;set;}
    
    public RE_CPMFAController(){
        Cookie counter = ApexPages.currentPage().getCookies().get('counter');
        if (counter == null) {
            counter = new Cookie('counter','1',null,-1,false);
        } else {
            Integer count = Integer.valueOf(counter.getValue());
            counter = new Cookie('counter', String.valueOf(count+1),null,-1,false);
        }
        ApexPages.currentPage().setCookies(new Cookie[]{counter});
        String urlValue = ApexPages.currentPage().getUrl();
        String headerValue = ApexPages.currentPage().getHeaders().get('Referer');
        getPageCountValue = counter.getValue();
        if(headerValue != null) {
            String val;
            List<String> parseUrlValues = urlValue.split('%');
            String fileName = parseUrlValues[parseUrlValues.size()-1];
            String outputName = fileName.removeStart('3A');
            String DisplayParseValues = outputName.replace('+' , ' ');
            List<String> parseValues = DisplayParseValues.split('-');
            String filenameVals = parseValues[0];
            //SSOAttributeValues = parseValues[parseValues.size()-1];
            val = parseValues[parseValues.size()-1];
            SSOAttributeValues = val.trim();
        }
        MFANONCP = 'MFARequiredCP';
        MFACP = 'MFARequired';
    }
    
    public PageReference redirectToMFAPage(){
        String MFARedirectPage = MFA_Router_Page__c.getValues('RedirectURL').MFARedirectURL__c;
        PageReference pgref = new PageReference(MFARedirectPage);
        pgref.setRedirect(true);
        return pgref;
    }
    
    public PageReference redirectToMFAPageCPUser(){
        String MFARedirectPage = MFA_Router_Page__c.getValues('RedirectURLCP').MFARedirectURL__c;
        PageReference pgref = new PageReference(MFARedirectPage);
        pgref.setRedirect(true);
        return pgref;
    }
    
}