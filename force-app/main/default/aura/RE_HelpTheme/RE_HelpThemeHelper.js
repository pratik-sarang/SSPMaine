({ 
    getLoggedInUser : function(component) { 
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
                    component.set("v.isAssister", response.objectData.isAssisterUser);
                    component.set("v.isUserFirstLogin", response.objectData.isUserFirstLogin);  
                    component.set("v.draftReferralCount", response.objectData.draftReferralCount);
                    component.set("v.isCPOnboardingTrainingDone", response.objectData.isCPOnboardingTrainingDone); 
                    component.set("v.showheader",true);
                    component.set("v.options",response.objectData.availableRoles);
                    component.set("v.selectedValue",response.objectData.SelectedRole[0]);
                    if(response.objectData.isCpUser === true && response.objectData.isCPOnboardingTrainingDone === false){
                        component.set("v.hasSideNavBar", false);
                          var planId = response.objectData.planId;  
                          var navigationURL = "/learning-plan-detail-standard?ltui__urlRecordId="+planId;            
                          var urlEvent = $A.get("e.force:navigateToURL");
                                    urlEvent.setParams({
                                        "url": navigationURL
                                    });
                                    urlEvent.fire();
                    } 
                    component.set("v.bFirstLoad", true);
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
    handleLogOut : function(component,helper,event) {
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.kogLogout', function(response) {
                window.open(response.objectData.koglogout,'_top');
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
    //Siri: checking the status of user and navigating back to LMs page if not completed.
    getCPUserTrainingStatus : function(component) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchCPUserTrainingStatus', function(response) {
                if(response.isSuccessful){
                    component.set("v.isCPOnboardingTrainingDone", response.objectData.isCPOnboardingTrainingDone); 
                    if(response.objectData.isCPOnboardingTrainingDone === true){
                        
                        component.set("v.showheader",true);
                        component.set("v.hasSideNavBar", true);
                        component.set("v.bFirstLoad", true);    
                        var url= $A.get("$Label.c.RE_Community_Base_URL");
                        window.open(url,'_top'); 
                    } 
                    else
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title":  $A.get("$Label.c.LMS_ErrorMessageTitle"),
                            "type" : "Error",
                            "message": $A.get("$Label.c.LMS_ErrorMessage")
                        });
                        toastEvent.fire(); 
                    } 
                }
                else{
                    var toastEventb = $A.get("e.force:showToast"); 
                    toastEventb.setParams({ 
                        "title": $A.get("$Label.c.errorstatus"),
                        "type" : "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventb.fire(); 
                }
            },{},false);
        } catch (e) {
        }
    }
})