({
    
    doInit : function(component, event, helper){
        var url = new URL(window.location.href);
        var isOpenForm = url.searchParams.get("isOpenClaimRequest");
        var unclaimedOrgId = atob(url.searchParams.get("orgId"));
        if(isOpenForm !== '' && isOpenForm === "true"){
            component.set("v.isOpenClaimRequest", isOpenForm);
            component.set("v.isOpenOrgSearch", false);
            component.set("v.orgId",unclaimedOrgId);
            helper.getOrgDetail(component);
        }
    },
    
	searchAction : function(component, event, helper) {
        var orgName = component.get("v.organizationName");
        var orgCity = component.get("v.organizationCity");
        component.set("v.dataResults",[]);
        helper.searchAction(component, event, helper, orgName, orgCity); 
        
	},
    handleButtonClick: function(component) {
        component.set("v.isOpen",true);
        //JAWS FIXES
        setTimeout(function(){
           document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },1000);
	},
    closeModel: function(component) {
        component.set("v.isOpen",false);
	},
    moveFocusToTop: function() {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },100)
    },
    handleClaimButton: function(component, event, helper) {
        helper.handleClaimButton(component, event, helper);
        component.set("v.isOpenClaimRequest",true);
        component.set("v.isOpenOrgSearch",false);
        
	},
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        var generalId=pageNumber*5;
        component.set("v.currentPageNumber", pageNumber+1);
        if(!component.get("v.disableScroll")){
            component.set("v.disableScroll",true);
            helper.buildData(component, helper);
            window.setTimeout(
                $A.getCallback(function() {
                    if(document.getElementById('orgname-'+generalId)){
                        document.getElementById('orgname-'+generalId).focus();
                    }
                }), 0
            );
        }   
    },
    openWebsite: function(component, event){
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank"); 
    }
})