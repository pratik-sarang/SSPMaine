({
    handleRemoveHandler : function(component, event, helper){
        var value = event.getSource().get("v.value");
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.removeFromMyPlans', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    $A.get('e.force:refreshView').fire();
                    helper.displayToastMessage(component,  $A.get("$Label.c.successstatus"), $A.get('$Label.c.removeresource'),"success");

                    var ccEvent = $A.get("e.c:RE_CountEvent");
                    ccEvent.setParams({
                        "cartCount" :  response.objectData.draftReferralCount
                    });
                    ccEvent.fire();
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "strReferralId" : value
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    /* display toast messages */
    displayToastMessage : function(component, title, msg, variant) {
        component.find('notifLib').showToast({
            "title": title,
            "message": msg,
            "variant": variant
        });
    },
    handleMapAccordianClickHelper:function(component,event,resourceIndexData,generalId,clickedIndex){
        var appEvent = $A.get("e.c:RE_LightningMapEvent");
        appEvent.setParams({
            "mapMarkersData" :  [],
            "mapMarkerSingleData":resourceIndexData,
            "index":generalId,
            "resourceClickedIndex":clickedIndex
        });
        appEvent.fire();
    },

    navigateToResourceDetail: function(component, event){
        var itemIndex = event.target.getAttribute("data-card");
        var itemResource = component.get("v.listReferralWrapper")[itemIndex];
        var encodeZip = btoa(itemResource.sContactZipCode);
        var encodeResourceId = btoa(itemResource.resource.resourceId);
        var encodeLocationId = btoa(itemResource.location.sLocationId);
        var url = 'resource-details?zipcode='+encodeZip+'&resourceId='+encodeResourceId+'&locationId='+encodeLocationId;
        /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();*/
        /* Fix for IE to make it open in New Tab */
        
        window.open(url,'_blank');
    },
    // can not remove event, as it is breaking functionality
    handleConnectHelper: function(component){
        var referralRecord = component.get("v.selectedCard");
        try{
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.connectDraftReferrals', function(response) {
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    $A.get('e.force:refreshView').fire();
                    //var accountName = referralRecord.referral.sReferralOrgName;
                    var accountName=referralRecord.resource.resourceOrgName;
                    var resourceName = referralRecord.resource.sResourceName; 
                    bSuper.showToast( $A.get("$Label.c.successstatus"), "success", $A.get('$Label.c.successfully') +' ' +accountName + ' ' +$A.get('$Label.c.for_resource')+' ' +resourceName);
                    
                    var ccEvent = $A.get("e.c:RE_CountEvent");
                    ccEvent.setParams({
                        "cartCount" :  response.objectData.draftReferralCount
                    });
                    ccEvent.fire();
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "strReferralId" : referralRecord.referral.referralId,
                "bConsentAgreed" : component.get("v.isConsentAgreed")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getOptOutInformation: function(component, event, helper, refRecord, btnHandlerValue){
      component.set("v.cartOptIn", component.get("v.iscartOptIn")); 
      if(!component.get("v.cartOptIn")){
        component.set("v.isConsentAgreed", false);
        var btnHandlerValue = "Connect";
        helper.connectSuggestedResource(component, event, helper,refRecord,btnHandlerValue);
        }
    },
    connectSuggestedResource: function(component, event, helper, refRecord,btnHandlerValue){
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.suggestedToConnect', function(response) {
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    if(btnHandlerValue === 'NoThanks'){
                        $A.get('e.force:refreshView').fire();
                        
                        var suggestedSettingUrl = "/my-plan?tab=Suggested";
                        helper.navigateToPageURL(component,event,suggestedSettingUrl);
                        helper.displayToastMessage(component,  $A.get("$Label.c.successstatus"), $A.get('$Label.c.removeresource'),"success");
                       
                        var ccEvent = $A.get("e.c:RE_CountEvent");
                        ccEvent.setParams({
                            "cartCount" : response.objectData.draftReferralCount
                        });
                        ccEvent.fire();
                        
                    }
                    if(btnHandlerValue === 'Connect'){
                        $A.get('e.force:refreshView').fire();
                        var accountName=refRecord.resource.resourceOrgName;
                        var resourceName = refRecord.resource.sResourceName; 
                        bSuper.showToast( $A.get("$Label.c.successstatus"), "success", $A.get('$Label.c.successfully') +' ' +accountName + ' ' +$A.get('$Label.c.for_resource')+' ' +resourceName);
                        
                        var suggestedSettingUrl = "/my-plan?tab=Suggested";
                        helper.navigateToPageURL(component,event,suggestedSettingUrl);
                        
                        var ccEvent = $A.get("e.c:RE_CountEvent");
                        ccEvent.setParams({
                            "cartCount" : response.objectData.draftReferralCount
                        });
                        ccEvent.fire();
                    }
                }
                else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "strJson" : JSON.stringify(refRecord),
                "strValueHandler" : btnHandlerValue,
                "bAchConsentAgreed" : component.get("v.isConsentAgreed")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    ShowMeMore: function(component, event, helper) {
        var decodedUrlParam = component.get("v.sContactId") ? atob(component.get("v.sContactId")): "";
        var emptyObject = null;
        component.set("v.displayLoader", true);
        
        try{
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.showMeMore', function(response) {
                if (response.isSuccessful) {
                    
                    
                    $A.get('e.force:refreshView').fire();
                    component.set("v.displayLoader", false);
                    
                    var ccEvent = $A.get("e.c:RE_CountEvent");
                        ccEvent.setParams({
                            "cartCount" : response.objectData.draftReferralCount
                        });
                        ccEvent.fire();
                    
                }
                else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },
           emptyObject,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    navigateToPageURL : function(component,event,pageUrl) { 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": pageUrl
        });
        urlEvent.fire();
    }
})