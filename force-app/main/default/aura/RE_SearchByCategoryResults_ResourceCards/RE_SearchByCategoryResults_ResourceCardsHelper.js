({
	handleMapAccordianClickHelper:function(component,event,data,generalId,clickedIndex){
        var appEvent = $A.get("e.c:RE_LightningMapEvent");
        appEvent.setParams({
            "mapMarkersData" :  [],
            "mapMarkerSingleData":data,
            "index":generalId,
            "resourceClickedIndex":clickedIndex
        });
        appEvent.fire();
    },
    getOptOutInformation: function(component, event, helper, rsSchResReferralStatus){
        try{
            component.set('v.displayLoader',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getOptOutInfoSharingDetails', function(response) {
                //hide spinner when server response received
                component.set('v.displayLoader',false); 
                if(response.isSuccessful){ 
                    component.set("v.cartOptIn", response.objectData.OptOutInfoSharing); 
                    
                    if(!component.get("v.cartOptIn")){
                        component.set('v.displayLoader',true);
                        component.set("v.isConsentAgreed", false);
                        if(rsSchResReferralStatus === 'Draft')
                            helper.handleSchDraftConnectHelper(component, event, helper);
                        else
                            helper.createReferralOnConnect(component,event);
                            component.set('v.displayLoader',false); 
                    }
                }
            }, null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createReferralOnConnect: function(component){
        try{
            component.set('v.isSpinnerActive',true);
            var resourceRecord = component.get("v.selectedCardValue");
            var locationID = resourceRecord.lstResourceLocations[0].id;
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.insertReferralForResident', function(response) {
                if(response.isSuccessful){
                    component.set("v.isResident", false);
                    var accountName = resourceRecord.accountName;
                    var resourceName = resourceRecord.resourceName;
                    resourceRecord.referralId = response.objectData.referals.Id;
                    component.set("v.searchresults", component.get("v.searchresults"));
                    bSuper.showToast($A.get("$Label.c.successstatus"),"SUCCESS", 
                                     $A.get("$Label.c.successfully") +' '+ accountName + ' '+ $A.get("$Label.c.for_resource") + ' '+ resourceName);
                }
            },
            {
                "objResource" : JSON.stringify(resourceRecord),
                "locationID" : locationID,
                "bConsentAgreed" : component.get("v.isConsentAgreed")
            },false); 
        }catch (e) {
            component.set('v.isSpinnerActive',false);
            bSuper.consoleLog(e.stack, true);
        }
    },
    handleSchDraftConnectHelper: function(component){
        try{
            var selResource = component.get("v.selectedCardValue");
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.connectDraftReferralsFromSearchResults', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    $A.get('e.force:refreshView').fire();
                    var accountName = selResource.accountName;
                    var resourceName = selResource.resourceName; 
                    bSuper.showToast($A.get("$Label.c.successstatus"), "SUCCESS", 
                                     $A.get("$Label.c.successfully") +' '+ accountName + ' '+ $A.get("$Label.c.for_resource") + ' '+ resourceName);
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
                "sSchReferralId" : selResource.objResource.Referrals__r[0].Id,
                "bSchConsentAgreed" : component.get("v.isConsentAgreed")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    }
})