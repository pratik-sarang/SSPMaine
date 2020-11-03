({
    getLoggedInUser : function(component,helper) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchLoginInUser', function(response) {
                if(response.isSuccessful){
                    component.set("v.isAvailableRoleSizeOne", response.objectData.isAvailableRoleSizeOne);
                    component.set("v.isAnonymous", response.objectData.isGuestUser);
                    component.set("v.isResident", response.objectData.isResidentUser);
                    component.set("v.isPartner", response.objectData.isCpUser);
                    component.set("v.isAgency", response.objectData.isAgencyUser);//RE_Release 1.1 - Agency user capture- Mohan
                    component.set("v.isUserFirstLogin", response.objectData.isUserFirstLogin );
                    component.set("v.draftReferralCount", response.objectData.draftReferralCount);
                    component.set("v.isAssister", response.objectData.isAssisterUser);
                    component.set("v.sOpenReferralsCount", response.objectData.sOpenReferralsCount);
                    // added Condtion by [CHFS Developer Mohan-11/08/19] validating user details profile/role for GA 
                    if(response.objectData.isGuestUser){ 
                        component.set("v.sfUserType", "Guest");
                    }else if(response.objectData.isResidentUser){ 
                        component.set("v.sfUserType", "Citizen");
                    }else if(response.objectData.isCpUser){ 
                        component.set("v.sfUserType", "CommunityPartner");
                    }else if (response.objectData.isAssisterUser){ 
                        component.set("v.sfUserType", "Assister");
                    }
                     else if (response.objectData.isAgencyUser){ 
                        component.set("v.sfUserType", "Agency");
                    }
                       
                    if((response.objectData.isCpUser === true ||response.objectData.isAssisterUser === true) && response.objectData.isUserFirstLogin===false){
                        component.set("v.showheader",response.objectData.isUserFirstLogin);
                    }else if(response.objectData.isCpUser === true || response.objectData.isGuestUser === true || response.objectData.isAssisterUser === true || response.objectData.isAgencyUser === true){
                        component.set("v.showheader",true);
                    }
                    component.set("v.options",response.objectData.availableRoles);
                    component.set("v.selectedValue",response.objectData.SelectedRole[0]);
                    if(response.objectData.isResidentUser === true){
                        component.set("v.showheader",response.objectData.isUserFirstLogin);
                        var firstTimeLoginUrlStrings = $A.get("$Label.c.RE_UrlStrings");
                        var listOfStrings = firstTimeLoginUrlStrings.split(", ");
                        var currentPageUrl = window.location.href;
                        var hasRedirect = true;
                        
         				for(var thisValue = 0; thisValue < listOfStrings.length; thisValue += 1){
                            if(currentPageUrl.includes(listOfStrings[thisValue]))
                            {
                                hasRedirect = false;
                            }
                        }
                        if(!response.objectData.isUserFirstLogin && hasRedirect){
                            var firstTimeResidentUrl = $A.get("$Label.c.RE_Community_Base_URL");
                            helper.navigateToPageURL(component,event,firstTimeResidentUrl);
                        }
                    }
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type" : "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEvent.fire(); 
                }
            },{},false);
        }catch (e) {
        }
    },
    navigateToPageURL : function(component,event,pageUrl) { 
    	var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": pageUrl
        });
        urlEvent.fire();
	},
    getKogURL : function(component, event, helper,navigate) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchKogURL', function(response) {
                
                if(navigate === 'Registration'){
                    window.open(response.objectData.KogRegistrationURL,'_parent');
                }
                if(navigate === 'Login'){
                    window.open(response.objectData.KogLoginURL,'_parent');
	}
            },{},false);
        }catch (e) {
        }
    },
    handleLogOut : function(component) {
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.kogLogout', function(response) {
                window.open(response.objectData.koglogout,'_top');
            },{},false);
        }catch (e) {
        }
    },
    getGuestHelpPage : function(component) {
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.getGuestHelpVideos', function(response) {
                if(response.isSuccessful){
                    component.set("v.helpList", response.objectData.courseList);
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type" : "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEvent.fire(); 
    }
            },{audience : component.get("v.userType")},false);
        } catch (e) {
        }
    }
})