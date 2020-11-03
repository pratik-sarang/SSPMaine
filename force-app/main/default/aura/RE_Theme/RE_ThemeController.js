({
    doInit : function(component, event, helper) {
       
        helper.getLoggedInUser(component,helper);
        helper.getGuestHelpPage(component,helper,event);
      
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
    navigatetoClient : function() {
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
        var ClientUrl = "clients";
        window.open(ClientUrl,'_top');
        //helper.navigateToPageURL(component,event,ClientUrl);
    },
    navigateReferralInbox : function() {
        //var referralInboxUrl = "/referral-inbox";
        //helper.navigateToPageURL(component,event,referralInboxUrl);
        var url='referral-inbox';
        window.open(url,'_top');
    },
    handleLogin : function(component) {
        component.set('v.bisLoginModal',true);
        //var url='../s/login';
        //window.open(url,'_top');
       	//window.open('my-account','_parent');
        setTimeout(function(){//JAWS Fix
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },1000);
    },
    navigateToRegistration : function(component, event, helper) {
        var navigate = 'Registration';
        helper.getKogURL(component, event, helper,navigate);
    },
    closeModel: function(component) {
        component.set('v.bisLoginModal',false);
    },
    handleMobileSideNavHelp: function(component,event,helper) {
        var helpUrl = "/help";
        helper.navigateToPageURL(component,event,helpUrl);
    },
    handleHelp : function(component,event) {
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
        var selectedHelpUrl = event.getParam("value");
 		window.open(selectedHelpUrl, '_blank');
    },
    handleSearchDropdown : function(component,event) {
        event.stopPropagation();
        document.getElementById('category-search-container').classList.toggle('dropdown-open');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop_open');
        document.getElementsByClassName("dropdown-categories")[0].classList.add("check-class");
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
    goToLandingPage : function(component) {	
        if(component.get("v.isUserFirstLogin") === true || component.get("v.isAnonymous") === true || component.get("v.isAgency") === true || component.get("v.isPartner") === true || component.get("v.isAssister") === true){
            var url='landing-page';
            window.open(url,'_top');
        }
    },
    goToGetStarted: function(component,helper) {	
        var getStartedUrl = "/get-started";
        helper.navigateToPageURL(component,getStartedUrl);
    },
    handleSelect: function(component,event,helper) {	
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue === 'Login'){
            component.set('v.bisLoginModal',true);
        }
        if(selectedMenuItemValue === 'MyPlan'){
            var myPlanUrl = "/my-plan";
        	helper.navigateToPageURL(component,event,myPlanUrl);
        }
        if(selectedMenuItemValue === 'Account'){
            var myAccountUrl = "my-account";
            window.open(myAccountUrl,"_self");
        	//helper.navigateToPageURL(component,event,myAccountUrl);
        }
        if(selectedMenuItemValue === 'Help'){
            var helpUrl = "/help";
        	helper.navigateToPageURL(component,event,helpUrl);
        }
        if(selectedMenuItemValue === 'Privacy'){
            var privacySettingUrl = "/my-plan?tab=Privacysettings";
        	helper.navigateToPageURL(component,event,privacySettingUrl);
        }
        if(selectedMenuItemValue === 'UserAgreement'){
            var myUserAgreementUrl = "user-agreement";
            window.open(myUserAgreementUrl,'_blank');
        }
        if(selectedMenuItemValue === 'Log Out'){
            sessionStorage.removeItem("zipCodeVal");
            helper.handleLogOut(component, event, helper);
            
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
                bSuper.showToast('ERROR', 'ERROR', $A.get("$Label.c.enter_value"));
            }        
        }
    },
    navigateToSuggested: function(component, event, helper){
        var suggestedSettingUrl = "/my-plan?tab=Suggested";
        helper.navigateToPageURL(component,event,suggestedSettingUrl);
    },
    handleCountApplicationEvent : function(component, event){
        var vCount = event.getParam("cartCount");
        component.set("v.draftReferralCount", vCount);
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
    /*added by Pankaj*/
    navigateToLogin:function(component, event, helper){
        
        var navigate = 'Login';
        
        helper.getKogURL(component, event, helper,navigate);
    },
    moveFocusToTop: function(component){//JAWS Fix
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },10);
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