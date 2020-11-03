/**
 * Contains key information w.r.t to the session. Framework attributes such as current page, action code from visualforce page, 
 * logged in user info etc are set.
 * <p> ContextData is created and initialized by <i>StandardApplicationController</i> and then passed to all the callback methods. Only one instance of Context is
 * maintained by <i>StandardApplicationController</i> so the values are retained during page navigation.
 *
 * @author Rahman A
 * @date 08/20/2014
 * 
 * @see StandardApplicationController
 * 
 */
//Shikha: added New argument to store the List<String> to store the changed screens
public with sharing class ContextData {

    /** Logged in user name */
    public String loggedInUserName {get {
        if(null == this.loggedInUserName) {
            this.loggedInUserName = 'Guest'.equalsIgnoreCase(Userinfo.getUserType()) ? null : UserInfo.getUserName();
        }
        return this.loggedInUserName;
    }
    set;}
    
    /** Page action like next, back or finish. */ 
    public String action {get; set;}

    /** Currently loaded navigation workflow name. NavFlowDetail__mdt.FlowName__c */ 
    public String flowName {get; set;}

    /** Currently loaded flow status NavFlowStatus__c.Id */
    public String navFlowStatusId {get; set;}
    
    /** Currently loaded flow status NavFlowStatus__c.Name */
    public String navFlowStatusName {get; set;}

    /** sObject ID that can be used to fetch/load next page */ 
    public String recordId {get;set;}
    
    /** Contact Id for whom the page/flow is executed. Contact.Id */ 
    public String contactId {get;set;}

    /** Current page NavFlowPageConfig__mdt.Id */
    public String curNavFlowPageConfigId {get; set;}

    /** Currenlty loaded workflow's group names. Used for display purpose in the visualforce page in "wayfinder" component */
    public List<PageGroupInfo> pageGroupInfos {get; set;}

    /** Current visualforce component name */
    public String curCompName {get; set;}

    /** Current page's group name in the flow */
    public String curPageGroupName {get; set;}

    /** Current page's display name */
    public String pageDispName {get; set;}

    /** Current flow display name */
    public String flowDispName {get; set;}

    /**  Currenlty loaded workflow configuration */
    public transient NavFlowDetail__mdt navFlowDetail {get; set;}
    
    /** Page to load. Used onclick of group/section header from progress bar */
    public String goToPageConfigId {get; set;}
    
    /** Page to load. Used onclick of group/section header from progress bar */
    public String pageConfigIdToLoad {get; set;}
    
    /**  
     * Navigation flow status. Used only during first time flow load where the status is not stored in the database yet.
     *
     * @see NavFlowManager.loadFlow
     **/
    public transient NavFlowStatus__c navFlowStatus {get; set;}
    
    /** Objects that are used during navigation flow processing. Useful to send objects that contain navigation flow rule condition values. In general, object fomr 
     * the current page from the next/back button is clicked */
    public transient Object[] objs {get; set;}
    
    //Shikha: added New List<String> to show only those screens which are selected
    public List<String> SelectedScreen {get;set;}
    
    //Ashwin: added New List<String> to show only those screens based on selected programs
    public List<String> SelectedPrograms {get;set;}
    
    //Ashwin: added strPageName to get the current Page Name.
    public String strCurrPageName {get;set;}
    
    //Shikha: adding ApplicationId to store context of Application
    public String ApplicationId {get;set;}
    
    //Shikha: adding Member Id to store context of Member
    public String MemberId {get;set;}

    //Shrikant: adding currentPageNo to store seq No of current page/section
    public String currentPageNo {get;set;}

    //Shrikant: adding totalPageCount to store the count of total required pages
    public String totalPageCount {get;set;}

    //Shrikant: adding isLastPage - evaluates to true if current page is the last page
    public Boolean isLastPage {get;set;}
 //Shikha:added modeName
    public String modeValue {get;set;}
    
    //Shikha
    public String flowDuplicateStatus {get;set;}
    
    //Adding Queuing Rule Property
    public QueuingWrapper queueObject;
        
    //Adding property to store list of review required pages when navFlowStatus is not created
    public List<String> noFlowStatusRRPages;
}