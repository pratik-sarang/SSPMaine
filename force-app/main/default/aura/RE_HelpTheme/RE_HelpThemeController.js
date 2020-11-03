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
                var pageUrl = $A.get("$Label.c.RE_Community_Base_URL"); //"/s/"
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
        if((!(component.get("v.isPartner") && component.get("v.isCPOnboardingTrainingDone") === false)) || component.get("v.isAgency") || component.get("v.isAssister")){
            var landingPageUrl = "/landing-page";
            helper.navigateToPageURL(component,event,landingPageUrl);
        }

	},
    handleSearchDropdown : function(component,event) {
        event.stopPropagation();
        document.getElementById('category-search-container').classList.toggle('dropdown-open');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop');
        document.getElementsByClassName('search-overlay')[0].classList.toggle('slds-backdrop_open');
    },
    navigatetoClient : function(component, event) {
        if(document.getElementById("mobileSidenav")){
            document.getElementById("mobileSidenav").style.width = "0";
        }
        var ClientUrl = "clients";
        window.open(ClientUrl,'_top');
    },

    navigateReferralInbox : function() {
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
        if(selectedMenuItemValue === 'Login'){
            //var url='../secur/login.jsp';
            //var url='../s/login';
            //var url =$A.get("$Label.c.CitizenKogLogin");
            //window.open(url,'_top');
            component.set('v.bisLoginModal',true);
        }
        if(selectedMenuItemValue === 'MyPlan'){
            var myPlanUrl = "/my-plan";
        	helper.navigateToPageURL(component,event,myPlanUrl);
        }
        if(selectedMenuItemValue === 'Account'){
            var myAccountUrl = "/my-account";
        	helper.navigateToPageURL(component,event,myAccountUrl);
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
            helper.handleLogOut(component, event, helper);
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
    search: function(component,event) {	
         var bSuper = component.find("bSuper");
        if(event.which === 13){
            if(document.getElementById("mobileSidenav")){
                document.getElementById("mobileSidenav").style.width = "0";
            }
            var searchKey = component.find("search-box").get("v.value");
            if(searchKey){
                //Payal :Bug 396635 - Url Changes
                var baseUrl= decodeURIComponent(window.location.href);
                var optionSelected=baseUrl.split('/s/')[0];
                //var urlEvent = $A.get("e.force:navigateToURL");
                //urlEvent.setParams({
                    //"url": '/s/search-results?searchkey='+searchKey
                //});
                //urlEvent.fire();
                //Siri: Domain URL Changes -Task#389828
                window.open(optionSelected+'/s/search-results?searchkey='+encodeURIComponent(searchKey),'_parent');
                
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
    }
})