({
	doInit : function(component,event, helper) {
		helper.getRelatedResources(component);
	},
    
    modalParametersHandler : function(component, event, helper){        
        var isConsAgreed = event.getParam("isConsentAgreed");
        var isModalClosed=event.getParam("isModalClosed");
        if(isConsAgreed){
            component.set("v.isConsentAgreed", isConsAgreed);
            var selCardRRValue = component.get("v.selectedCardValue");
            //var rsOptReferralStatus = '';
            if(!$A.util.isUndefinedOrNull(selCardRRValue.objResource.Referrals__r) 
                && selCardRRValue.objResource.Referrals__r.records[0].Status__c === 'Draft'){
               // rsOptReferralStatus = selCardRRValue.objResource.Referrals__r.records[0].Status__c;
                helper.handleRRDraftConnectHelper(component, event, helper);
            } else {
                helper.createReferralOnConnect(component, event);
            }
        }
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
        if(isModalClosed){
            component.set("v.selectedCardValue.isDisabled", false);
            var carslItmSmlrRsrces = component.get("v.carouselItemSimilarRes");
            component.set("v.carouselItemSimilarRes",carslItmSmlrRsrces);
            var carslItms = component.get("v.carouselItem");
            component.set("v.carouselItem",carslItms);
        }
    },

	handleConnect : function(component, event, helper) {
        //var bSuper = component.find("bSuper"); 
        /* Added By Sai for OptOutSharing Logic */
        var eventValue = event.getSource().get("v.value");
        var eventName	=	event.getSource().get("v.name");
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela
        if(!$A.util.isUndefinedOrNull(eventValue) && !component.get("v.isGuest")){
        eventValue.isDisabled = true;
        }
        component.set("v.selectedCardValue",eventValue);
        component.set("v.selectedCardName",eventName);
        var carslItmSmlrRsrces = component.get("v.carouselItemSimilarRes");
        component.set("v.carouselItemSimilarRes",carslItmSmlrRsrces);
        var carslItms = component.get("v.carouselItem");
        component.set("v.carouselItem",carslItms);
        /* ------End ------ */
        if(component.get("v.isGuest")){
            component.set("v.bShowLoginModal", true);
            //bSuper.showToast('ERROR', 'ERROR', 'Please log in to connect with a community partner for this resource.');
        }else{
            helper.getOptOutInformation(component, event, helper);
        }
	},
	
	gotoResourceDetails : function(component,event) {

		var locationId = event.currentTarget.id;
		var resourceRecordId = event.target.name;
		
        window.open('resource-details?resourceId='+btoa(resourceRecordId)+
                    '&locationId='+btoa(locationId)+'&zipcode='+btoa(component.get("v.zipcode")), '_blank');
	},
	
	createReferral : function(component,event){

		
		var resourceRecord = event.getSource().get("v.value");
        var eventName	=	event.getSource().get("v.name");
        var isfrequentlyPaired =false;
        var isSimilarResource=false;
        if(eventName==='similarResourceRefer'){
            isSimilarResource=true;
        }else if(eventName==='frequentlyPariedRefer'){
            isfrequentlyPaired=true;
        }

        var cmpEvent = component.getEvent("CreateReferralEvent");
        cmpEvent.setParams({"createReferralScreen" : true,"resourceId" : resourceRecord.sResourceId,"AccountId" : resourceRecord.sResourceAccountId,
         "LocationId" : resourceRecord.sLocationId,"isFrequentlyPaired" : isfrequentlyPaired,"isRelatedServices":isSimilarResource}); 
		
		cmpEvent.fire(); 

	},
})