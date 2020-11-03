({
    doInit : function(component, event, helper) {
		helper.getLoggedInUser(component);
    },
    handleChange : function(component, event) {
        console.log('******'+component.get("v.selectedValue"));
        var action = component.get("c.roleChange");
        action.setParams({ newRole : component.get("v.selectedValue")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('****** success');
                    var pageUrl = $A.get("$Label.c.RE_Community_Base_URL");
                    /*var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": pageUrl
                    });
                    urlEvent.fire();*/
                    window.open(pageUrl,'_top');
            }
            else{
                console.log('call failed')
            }
        });
        $A.enqueueAction(action);
    },
    handleMobileSideNavHelp: function(component,event,helper) {
        var helpUrl = "/help";
        helper.navigateToPageURL(component,event,helpUrl);
    },
    handleHelp : function(component,event,helper) {
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
        var helpUrl = "/help";
        helper.navigateToPageURL(component,event,helpUrl);
    },
	goToLandingPage : function(component, event, helper) {
            
        if(!((component.get("v.isPartner")) && component.get("v.isCPOnboardingTrainingDone") === false) || component.get("v.isAgency") || component.get("v.isAssister")){
            var landingPageUrl = "/landing-page";
            helper.navigateToPageURL(component,event,landingPageUrl);
        }

	},
    handleSearchDropdown : function(component,event) {
        event.stopPropagation();
        document.getElementById('category-search-container').classList.toggle('dropdown-open');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop_open');
        document.getElementsByClassName("dropdown-categories")[0].classList.add("check-class");
    },
    navigatetoClient : function() {
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
        var ClientUrl = "clients";
        window.open(ClientUrl,'_top');
        //helper.navigateToPageURL(component,event,ClientUrl);
    },
    navigatetoLMSPage : function() {
       // var ClientUrl = "/clients";
       // helper.navigateToPageURL(component,event,ClientUrl);
    },
    navigateReferralInbox : function() {
        //var referralInboxUrl = "/referral-inbox";
        //helper.navigateToPageURL(component,event,referralInboxUrl);
        var url='referral-inbox';
        window.open(url,'_top');
    },
    toggleOverlay: function(component,event) {
        var targetId=event.target.id;
        var currentTargetId=event.currentTarget.id;
        event.stopPropagation();
        if(targetId===currentTargetId){
            var categoryArray=document.getElementsByClassName('category');
            for(var i=0;i<categoryArray.length;i+=1){
                if(categoryArray[i].classList.contains('category-active')){
                    categoryArray[i].classList.remove('category-active'); 
                }
            }
            if(document.getElementsByClassName('menu-container')[0]){
                document.getElementsByClassName('menu-container')[0].classList.add('slds-hide');
            }
            document.getElementById('category-search-container').classList.remove('dropdown-open');
            document.getElementsByClassName('search-overlay')[0].classList.remove('slds-backdrop');
            document.getElementsByClassName('search-overlay')[0].classList.remove('slds-backdrop_open'); 
        }
    },
    handleSelect: function(component,event,helper) {
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue === 'Logout'){
            helper.handleLogOut(component, helper);
        }
        if(selectedMenuItemValue === 'Help'){
            var helpUrl = "/help";
            helper.navigateToPageURL(component,event,helpUrl);
        }
        if(selectedMenuItemValue === 'Account'){
            var myAccountUrl = "my-account";
            window.open(myAccountUrl,"_self");
            //helper.navigateToPageURL(component,event,myAccountUrl);
        }
        if(selectedMenuItemValue === 'UserAgreement'){
            var myUserAgreementUrl = "user-agreement";
            window.open(myUserAgreementUrl,'_blank');
        }
    },
    search: function(component,event) {	
         var bSuper = component.find("bSuper");
        if(event.which === 13){
            if(document.getElementById("mobileSidenav")){
                document.getElementById("mobileSidenav").style.width = "0";
            }
            var searchKey = component.find("search-box").get("v.value");
            if(searchKey){
                //var urlEvent = $A.get("e.force:navigateToURL");
                //urlEvent.setParams({
                    //"url": '/s/search-results?searchkey='+searchKey
                //});
                //urlEvent.fire();
                window.open('search-results?searchkey='+encodeURIComponent(searchKey),'_parent');
            }else{
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.enter_value"));
            }        
        }
    },
    openSideNav: function(){
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "100%";  
        }
    },
    closeSideNav: function(){
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
    },
    searchByCatMobile:function(component){
        component.set("v.bisMobileMenuVisible",!component.get("v.bisMobileMenuVisible"));
    },
    navigateToMyPlan:function(){
        var myPlanUrl = "my-plan";
        window.open(myPlanUrl,'_parent')
    },
    handleTrainingComplete: function(component,event,helper) {
	 helper.getCPUserTrainingStatus(component);
    },
    moveFocusToOptions: function(component, event){//JAWS Fixes
        if(event.type === "blur"){         
            if(document.getElementsByClassName("dropdown-categories")[0].classList.contains("check-class")){
                document.getElementsByClassName("dropdown-categories")[0].classList.remove("check-class");
                document.getElementsByClassName("category")[0].focus();
            }
        }
    }
})