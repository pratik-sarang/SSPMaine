/**
 * Contains information about the page that needs to be loaded. 
 *
 * @author Rahman A
 * @date 08/20/2014
 */
public with sharing class PageToLoad {

    /** Page information from <i>NavFlowPageConfig__mdt</i> sObject. */
	@AuraEnabled
    public NavFlowPageConfig__mdt pageConfig {get; set;}
	
	/** Page information from <i>PageInfo__mdt</i> sObject. */
	// some reasons accessing parent fields like PageInfo__r.PageDisplayName__c not returning actual value. So used this.
	@AuraEnabled
    public PageInfo__mdt pageInfo {get; set;}
    
    /** Currently loaded navigation workflow name. NavFlowDetail__mdt.FlowName__c */ 
	@AuraEnabled
    public String flowName {get; set;}
    
    /** Navigation flow page's flow name. Used for displaying in the visualforce page. NavFlowDetail__mdt.FlowDisplayName__c */
	@AuraEnabled
    public String flowDispName {get; set;}
    
    /** Currently loaded flow's unique ID. NavFlowDetail__mdt.Id */
	@AuraEnabled
    public String flowUniqueId {get; set;}

    /** Currently loaded flow status NavFlowStatus__c.Id */
	@AuraEnabled
    public String navFlowStatusId {get; set;}
	
	/** Currently loaded flow status NavFlowStatus__c.Name */
	@AuraEnabled
	public String navFlowStatusName {get; set;}

    /** Contact Id for whom the page/flow is executed. Contact.Id */ 
	@AuraEnabled
    public String contactId {get; set;}
    
    /** sObject ID that can be used to fetch/load next page */ 
	@AuraEnabled
    public String recordId {get; set;}

	/** Currenlty loaded workflow's group names. Used for display purpose in the visualforce page in "progress bar / wayfinder" component */
	@AuraEnabled
    public List<PageGroupInfo> pageGroupInfos {get; set;}
	
	/** group name */ 
	@AuraEnabled
    public String curGroupName {get; set;}

    /** Navigation flow page's navigation buttons list. Used to display in header/footer navigation bar. */
	@AuraEnabled
    public List<Button> navButtons {get; set;}

    /** Flag to indicate if the view should be retained from previous step. */
	@AuraEnabled
    public boolean isSameView {get { if(null == isSameView) {isSameView = false;} return isSameView;} set;}

    /** Page (URL) parameters that will be appended to the page to load URL. This can be used to pass the information between pages.
     Do not pass sensitive information in the URLs. */
    @AuraEnabled
    public Map<String, String> pageParams {get; set;}
     @AuraEnabled
    public Boolean Editable {get; set;}
    
    //Shikha: added applicationId and Member Id
    @AuraEnabled
    public String applicationId {get;set;}
    @AuraEnabled
    public String memberId{get;set;}
    
    
    //Shrikant: adding currentPageNo to store seq No of current page/section
    @AuraEnabled
    public String currentPageNo {get;set;}

    //Shrikant: adding totalPageCount to store the count of total required pages
    @AuraEnabled
    public String totalPageCount {get;set;}

    //Shrikant: adding isLastPage - evaluates to true if current page is the last page
    @AuraEnabled
    public Boolean isLastPage {get;set;}
    
    @AuraEnabled
    public String flowStatus {get;set;}

    @AuraEnabled
    public String flowPageStatus {get;set;}

    //CD2 2.5 Security Role Matrix and Program Access.
    @AuraEnabled
    public String screenPermission {get;set;}

    //#379955
    @AuraEnabled
    public Boolean navigateToSummary {get;set;}
    @AuraEnabled
    public Boolean hasNoAccess {get;set;}
    
    //Set applicable Flow Page name from Member Flow
    @AuraEnabled
    public String applicableMemberFlow {get;set;}
}