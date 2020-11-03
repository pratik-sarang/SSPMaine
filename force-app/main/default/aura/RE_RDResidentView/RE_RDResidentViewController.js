({ 
    doInit : function(component, event, helper) {
        helper.getParam(component);
        helper.getAllLocations(component);
        helper.isResidentUser(component);
        helper.getData(component,event,helper);        
    },
    
    gotoResourceDetails : function(component,event) {
        var updatedResourceRecordId = event.target.name;
        window.open($A.get("$Label.c.rdresourceid")+btoa(updatedResourceRecordId)+
                    $A.get("$Label.c.andlocationid")+btoa(component.get("v.locationId"))+$A.get("$Label.c.andzipcode")+btoa(component.get("v.zipcode")), '_blank');
    },
    openWebsite : function(component,event) {
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank");
    },
    openDrivingDirectionMap : function(component) {
        //var loction = event.target.name;
        var latLong = component.get("v.locGeolocation");
        var latLongReplaced=latLong.replace("##",",");
        var redirectUrl=$A.get("$Label.c.googlemapurl")+latLongReplaced;
        window.open(redirectUrl, "_blank");
    },
    
    handleLocationChange : function(component,event,helper) {
        component.set("v.mondayClose",false); 
        component.set("v.tuesdayClose",false); 
        component.set("v.wednesdayClose",false); 
        component.set("v.thursdayClose",false); 
        component.set("v.fridayClose",false); 
        component.set("v.saturdayClose",false); 
        component.set("v.sundayClose",false); 
        component.set("v.selectedLocation",component.find("location").get("v.value")); 
        var updatedLocation = component.get("v.selectedLocation");
        component.set("v.locationId",updatedLocation);
        helper.getData(component,event,helper);
        
    },
    
    modalParametersHandler : function(component, event, helper){        
        var isConsAgreed = event.getParam("isConsentAgreed");
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
        var isModalClosed=event.getParam("isModalClosed");
        if(isConsAgreed){
            component.set("v.isConsentAgreed", isConsAgreed);
            var rsOptReferralStatus = helper.getReferralStatus(component);
            if(rsOptReferralStatus === 'Draft')
                helper.handleDraftConnectHelper(component, event, helper);
            else
                helper.createReferralOnConnect(component, event);
        }
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
        if(isModalClosed){
            var evtValue = component.get("v.selectedCardValue");
            var eventName = component.get("v.selectedCardName");
            if(eventName === "othResConn"){
                evtValue.isDisabled = false;
                var rldResources = component.get("v.relatedResourcesWrapper");
                component.set("v.relatedResourcesWrapper", rldResources);
            }else{
                component.set("v.isSelectedResConDisabled", false);
                component.set("v.isDisabled", false);
            }

        }
    },
    handleRsrcStlsConnect : function(component, event, helper) {
        var eventValue = event.getSource().get("v.value");
        var eventName = event.getSource().get("v.name");
        var resReferralStatus = '';
        component.set("v.isSelectedResConDisabled", true);
        component.set("v.selectedCardValue",eventValue);
        component.set("v.selectedCardName",eventName);
        if(component.get("v.isGuest")){
            component.set("v.bShowLoginModal", true);
        }else{
            //RE_Release 1.3 – Connect Button Issue - Payal Dubela
            component.set("v.isDisabled", true);
            resReferralStatus = helper.getReferralStatus(component);
            helper.getOptOutInformation(component, event, helper, resReferralStatus);
        }
    },
	
    handleConnect : function(component, event, helper) {
        var eventValue = event.getSource().get("v.value");
        var eventName = event.getSource().get("v.name");
        var resReferralStatus = '';
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela
        if(!$A.util.isUndefinedOrNull(eventValue)){
        eventValue.isDisabled = true;
        }
        var rldResources = component.get("v.relatedResourcesWrapper");
        component.set("v.relatedResourcesWrapper", rldResources);
        component.set("v.selectedCardValue",eventValue);
        component.set("v.selectedCardName",eventName);
        if(component.get("v.isGuest")){
            component.set("v.bShowLoginModal", true);
        }else{
            resReferralStatus = helper.getReferralStatus(component);
            helper.getOptOutInformation(component, event, helper, resReferralStatus);
        }
    },

    createReferral:function(component,event){
        //Open create referral page 
        var eventValue = event.getSource().get("v.value");
        if(event.getSource().get("v.name") === 'othResRef' ){
            component.set("v.selectedResourceId", eventValue.objResource.Id);
            component.set("v.selectedResourceAccountId",eventValue.objResource.Organization__c);
        }else{
            component.set("v.selectedResourceId", eventValue.Id);
            component.set("v.selectedResourceAccountId", eventValue.Organization__c);
        }
        component.set('v.bShowResourceDetail',false);
        
    },
    
    openDoc: function() {
        var profUrl = $A.get('$Resource.RE_RefferalDoc');
        window.open(profUrl);
    },
    onSend : function(component, event, helper) {
        helper.processResourceDetails(component, event, helper);   
    },
    handleAccordionClick : function() {
        document.getElementsByClassName('resource-details-card')[0].classList.toggle('card-opened');
    },
    showResourceModal : function(component, event) {
        component.set("v.currentUrl", document.URL);
        var wrapdata = event.getSource().get("v.value");
        component.set("v.wrapdata", wrapdata);
        component.set("v.showResourceModal",true);
        document.getElementsByClassName('rd-residentWrapper')[0].classList.add('slds-hide');
        if(document.getElementsByClassName('flash-text')[0]){
           document.getElementsByClassName('flash-text')[0].classList.add('slds-hide'); 
        }
        document.getElementsByClassName('resource-details-heading')[0].classList.add('slds-hide');
    },
    closeFlashText: function(component) {
        component.set("v.selectedLocRecord.AnnouncementStatus__c",false);
    },
    
    handleCreateReferralEvent : function(component,event) {
        var bCreateReferral = event.getParam("createReferralScreen");
        if(event.getParam("resourceId") !==undefined && event.getParam("resourceId") !== null){
        	component.set("v.selectedResourceId", event.getParam("resourceId"));
        	component.set("v.selectedResourceAccountId",event.getParam("AccountId"));
            component.set("v.selectedLocation", event.getParam("LocationId"));
            component.set("v.bShowResourceDetail",!bCreateReferral);
            component.set("v.isFrequentlyPaired",event.getParam("isFrequentlyPaired"));
            component.set("v.isRelatedServices",event.getParam("isRelatedServices"));
    	}
    
        
    },
    
    addToFavorites : function(component,event,helper){
        var cmpId = component.find("favorite-selected");        
        $A.util.toggleClass(cmpId,"slds-is-selected");
		
        component.set("v.LocResourceId",component.get("v.sLocResourceId"));
        var sResource = component.get("v.resourceRecords");
        component.set("v.sResourceName",sResource.Name);
        
        component.set("v.sOrganisationName",sResource.Organization__r.Name);
        var imgId = document.getElementById("favorite-selected-img");
        if(imgId.src.indexOf("heartred") > -1){
            component.set('v.isFavoriteIconRed',false);
            imgId.src = imgId.src.replace("heartred","heartgray");
            imgId.title=$A.get("$Label.c.add_favorite");
            helper.deleteFavoritesHelper(component);           
        }
        else{ 
            component.set('v.isFavoriteIconRed',true);
             imgId.src = imgId.src.replace("heartgray","heartred"); 
             imgId.title=$A.get("$Label.c.remove_favourite");
             helper.createFavoritesHelper(component);            
        }
    },
   /* addToFavoritesUnopened : function(component, event){
        var generalId=event.getSource().get("v.id").split('_')[1];
        var cardArray=document.getElementsByClassName('details-card');
        for(var i=0;i<cardArray.length;i+=1){
            if(cardArray[i].id.split('_')[1] !== generalId){
               document.getElementById("favorite-selected_"+generalId).classList.toggle("slds-is-selected")
            }
        }
    },*/
    navigateToSuggestEdit : function(component){
        var urlEvent = $A.get("e.force:navigateToURL");
        var backurl=window.location.href;
        
        var resource=component.get("v.resourceRecords");
		var location=component.get("v.selectedLocRecord");
       // var locationname=location.Address1__c+', '+location.City__c;
        var locationname = location.Address1__c+' '+(location.Address2__c !== undefined || null ? location.Address2__c : '')+', '+location.City__c+ (location.State__c !== undefined || null ? ', '+location.State__c : '');
      //  !m.Address1__c+' '+m.Address2__c+', '+m.City__c+ (m.State__c != undefined || null ? ', '+m.State__c : '')
        urlEvent.setParams({
            // added by Prashant for US - 137
            "url": '/suggest-edit?resourceId='+btoa(resource.Id)+'&resourceName='+btoa(resource.Name)+'&accountId='+btoa(resource.Organization__c)+'&accountName='+btoa(resource.Organization__r.Name)+'&locationId='+btoa(location.Id)+'&locationName='+btoa(locationname)+'&backURL='+btoa(backurl)
        }); 
        urlEvent.fire();
    }
    
})