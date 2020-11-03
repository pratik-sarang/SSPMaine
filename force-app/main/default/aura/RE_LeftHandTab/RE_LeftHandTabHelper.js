({
    handleOnSelect : function(component, event, helper){
        var optionClicked = event.getParam('name').toLowerCase().replace(' ','-');
        var optionSelected = event.getParam('name');
        component.set("v.optionSelected",optionSelected);
        switch (optionClicked) {
            case "referral-dashboard" :
                helper.gotoURL(component, event, helper, 'referraldashboard');
                break;
            case "our-team" :
                helper.gotoURL(component, event, helper, 'our-team');
                break;
            case "organization-details" :
                helper.gotoURL(component, event, helper, 'organization-details');
                break;
            case "our-resources":
                helper.gotoURL(component, event, helper, 'our-resources');
                break; 
            case "referral-inbox" :
                helper.gotoURL(component, event, helper, 'referral-inbox');
                break;
            case "clients" :
                helper.gotoURL(component, event, helper, 'clients');
                break;
            case "activity-dashboard" :
                helper.gotoURL(component, event, helper, 'activity-dashboard');
                break;
            case "my-favorites" :
                helper.gotoURL(component, event, helper, 'my-favorites');
                break;
            case "report" :
                helper.gotoURL(component, event, helper, 'report');
                break;   
            case "referral-outbox" :
                helper.gotoURL(component, event, helper, 'referral-outbox');
                break; 
            default:
        }
    },
    closetoggle : function(component){
        var toggleText = component.find("verticalNavigation");
        $A.util.addClass(toggleText, "toggleclose");
        $A.util.removeClass(toggleText, "toggleopen");        
    },
    doInitHandler : function(component) {
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getLoggedInUserRole', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                
                if(response.isSuccessful){
                    var bIsAdmin = response.objectData.bIsAdminUser;
                    var sUserProfile = response.objectData.bIsCPUserProfile;
                    var bIsAdminStaff = response.objectData.bIsAdminStaff;
                    var bIsAssister=response.objectData.bIsAssister;
                    var bIsAgencyUserProfile = response.objectData.bIsAgencyUserProfile;
                    var bIsAgencyAdminStaff = response.objectData.bIsAgencyAdminStaff;
                    var bIsAgencyAdminUser = response.objectData.bIsAgencyAdminUser;
                    component.set("v.bIsAgencyUserProfile",bIsAgencyUserProfile);
                    component.set("v.bIsAgencyAdminStaff",bIsAgencyAdminStaff);
                    component.set("v.bIsAdminStaff",bIsAdminStaff);
                    component.set("v.bIsCPUserProfile",sUserProfile);
                    component.set("v.bIsAssister",bIsAssister);
                    if(bIsAssister){
                        var tab=window.location.pathname.split('/s/')[1];
                        if(tab ===''){
                            component.set("v.optionSelected","Clients");   
                        }                     
                    }
                    if(bIsAdmin === true){
                        component.set("v.isAdmin", true);
                    }
                    if(bIsAgencyAdminUser === true){
                        component.set("v.isAgencyAdmin", true);
                    }
                }else{
                    component.set("v.isAgencyAdmin", false); // RE_Release 1.1 - Agency User Capture - Siri
                    component.set("v.isAdmin", false);
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), component_failure);
                }
                
            },null,false);
        }catch (e) {
        }        
    },
    gotoURL : function (component, event, helper, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+url
        });
        urlEvent.fire();
    },
    capitalizeText: function (component, event, helper,str) {
        var strScoped = str;
        strScoped = strScoped.split(" ");      
        for (var i = 0, x = strScoped.length; i < x; i +=1) {
            strScoped[i] = strScoped[i][0].toUpperCase() + strScoped[i].substr(1);
        }       
        return strScoped.join(" ");
    }
})