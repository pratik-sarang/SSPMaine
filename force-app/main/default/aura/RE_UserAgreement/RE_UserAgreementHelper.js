({
    getLoggedInUser : function(component) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchLoginInUser', function(response) {
                if(response.isSuccessful){
                    component.set("v.isAnonymous", response.objectData.isGuestUser);
                    component.set("v.isResident", response.objectData.isResidentUser);
                    component.set("v.isPartner", response.objectData.isCpUser);
                    component.set("v.isAssister", response.objectData.isAssisterUser);
                    component.set("v.isUserFirstLogin", response.objectData.isUserFirstLogin);
                    component.set("v.userAgreementVersion", response.objectData.activeUserAgreementVersion);
                    component.set("v.userAgreementText", response.objectData.activeUserAgreementText);
                    component.set("v.userAgreementHeader", response.objectData.activeUserAgreementHeader);
                    component.set("v.userAgreementLanguage", response.objectData.activeUserAgreementLanguage) 
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
    
    handleOnButtonPressed	: function(component){
        
        if (component.get("v.isUserAgreed") === true) {  
            try{
          component.set('v.isSpinnerActive',true);
                var bSuper = component.find("bSuper"); 
                bSuper.callServer(component, 'c.userAgreementReviewed', function(response) {
                  
                    if(response.isSuccessful){
                     
                    /*    var navigationURL = "/s/";
                         var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": navigationURL
                        });
                  
                        urlEvent.fire();  */
                         var url= $A.get("$Label.c.RE_Community_Base_URL");
                        window.open(url,'_top'); 
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
                },{
                    userAgreementVersion: component.get("v.partnerAgreementVersion")
                },false);
            }catch (e) {
               
            }
            
        } else {
            
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "type" : "ERROR",
                "message": $A.get("$Label.c.RE_terms_Conditions")
            });
            toastEvent.fire(); 
        }
        
    },
    
})