({
    doinIt : function(component) {
        var sPageURL = decodeURIComponent(document.URL); //You get the whole decoded URL of the page.
        var sconsentId = sPageURL.split('consentId=')[1]; 
        var consnetprovided = sPageURL.split('+')[0].split('?')[1]; 
        var accessgiven = component.get("v.bAccessgiven");
        if(consnetprovided === "yes"){
            accessgiven = true;
        }
        
        component.set("v.sConsentId",sconsentId);
        component.set("v.bAccessgiven",accessgiven);
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var toastEvent = $A.get("e.force:showToast");
                    var baseURL = sPageURL.split("consentupdate")[0];
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": baseURL
                    });
            
            if(component.get("v.sConsentId")){
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, "c.updateConsentFromEmail", function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                   toastEvent.setParams({  
                    "title": $A.get("$Label.c.successstatus"), 
                        "message": $A.get("$Label.c.RE_ConsentUpdated"),
                        "type": "success"
                    });  
                    toastEvent.fire(); 
                    
                    urlEvent.fire();
                    
                    
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "consentId" : component.get("v.sConsentId"),
                "accessgiven" : component.get("v.bAccessgiven")
            },false);
        }
            else{
                component.set('v.isSpinnerActive',false);
                toastEvent.setParams({  
                    "title": $A.get("$Label.c.errorstatus"), 
                        "message": $A.get("$Label.c.RE_NoPendingConsentFound"),
                        "type": "error"
                    }); 
                toastEvent.fire();
                urlEvent.fire();
                 
            }
        }
        
        catch (e) {
        }
        
    }
})