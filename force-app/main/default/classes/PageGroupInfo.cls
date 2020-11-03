public with sharing class PageGroupInfo {

    /** group name */ 
    @AuraEnabled
    public String groupName {get; set;}
    
    /** Page to load. Used onclick of group/section header from progress bar */
    @AuraEnabled
    public String goToPageConfigId {get; set;}
    
    @AuraEnabled
    public String pageConfigIdToLoad {get; set;}
    
    /** Flag to indicate if the group/section is completed.
     *  Possible values : Completed, Incomplete, Disabled, Hidden
     *  
     *  Completed means all the pages in the group are completed.
     *  Incomplete means one or more pages are incomplete. User can click and navigate to the group from progress bar/path. Clicking on the group name will load the first page in the group.
     *  Disabled means none of the page in the group is complete. User cannot click on this group.
     *  Hidden means none of the page is required from the group hence do not show.
     *  
     *  TODO may be use enum to restrict values??
     *  */ 
    @AuraEnabled
    public String groupStatus {get; set;}
    
    /** Flag to indicate if the group/section is current. */  
    @AuraEnabled
    public boolean isCurrent	 {get; set;}
    
    /** pages' status character within the group. Used to determine group status.
     *  R (required) -> 82
     *  N (not required) -> 78
     *  C (completed) -> 67
     *  */
    public transient Set<Integer> pageStatuses {get; set;}
    
    /** pages' status character within the group. Used to determine group status duplicate.
     *  R (required) -> 82
     *  N (not required) -> 78
     *  C (completed) -> 67
     *  */
    public transient Set<Integer> pageDupStatuses {get; set;}
    @AuraEnabled
    public Set<PageInfo> pageInfos {get; set;}
    
    public PageGroupInfo(String groupName) {
        this.groupName = groupName;
        this.isCurrent = false;
        this.pageStatuses = new Set<Integer>();
        this.pageInfos = new Set<PageInfo>();
        this.pageDupStatuses = new Set<Integer>();
    }
    
    
    public class PageInfo {
        
        @AuraEnabled
    	public String pageName {get; set;}
        
        @AuraEnabled
    	public String pageDispName {get; set;}
        
        @AuraEnabled
    	public String pageConfigId {get; set;}
        
        @AuraEnabled
    	public Integer pageStatus {get; set;}
        
        //Shikha - added a new a property
        @AuraEnabled
    	public Integer pageDupStatus {get; set;}
        
        
        public PageInfo(String pageName, String pageDispName, String pageConfigId, Integer pageStatus, Integer pageDupStatus){
            this.pageName = pageName;
            this.pageDispName = pageDispName;
            this.pageConfigId = pageConfigId;
            this.pageStatus = pageStatus;
            this.pageDupStatus = pageDupStatus;
        }
        
    }
    
}