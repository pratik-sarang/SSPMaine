/**
 * Context for the request/response. Contains values that need to be used across the application.
 * <p> Context is created and initialized by <i>StandardApplicationController</i> and then passed to all the callback methods. Only one instance of Context is
 * maintained by <i>StandardApplicationController</i> so the values are retained during page navigation.
 *
 * @author Rahman A
 * @date 08/20/2014
 * 
 * @see StandardApplicationController
 * 
 */
public with sharing class Context {
    
    /** Logger instance for all logging requests. */
    public Logger lgr {get; set;}

    /** Language code for the conext. This is used for visualforce page's language attribute for translations. Defaulted to English (en). */
    public String lang {get {
        if(null == this.lang) {
            this.lang = 'Guest'.equalsIgnoreCase(Userinfo.getUserType()) ? 'en' : UserInfo.getLanguage();
        }
        return this.lang;
    }
    set;}

    /** Locale code for various data formatting like date, datetime etc. Defaulted to English-US (en_US). */
    public String locale {get {
        if(null == this.locale) {
            this.locale = 'Guest'.equalsIgnoreCase(Userinfo.getUserType()) ? 'en_US' : UserInfo.getLocale();
        } return this.locale;
    }
    set;}
}