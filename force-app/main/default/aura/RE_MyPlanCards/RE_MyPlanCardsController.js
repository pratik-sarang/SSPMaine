({
    doinIt : function(component) {
        var data = component.get("v.listReferralWrapper");
        if(data.lstNotes){
            component.set("v.displayNotes", true);
        }
        setTimeout(function(){
                document.getElementsByClassName("my-plan-cards")[0].focus();
        },5000);
    },
    handleAccordionClick : function(component, event, helper) {
        if(event.keyCode === 13 || !event.keyCode){
            var generalId=event.target.id.split('-')[1];
            var cardArray=document.getElementsByClassName('my-plan-card');
            var toggleArray=document.getElementsByClassName('card-toggle-section');
            var collapsedArray=document.getElementsByClassName('collapsed-section');
            window.setTimeout(
                $A.getCallback(function() {
                    if(document.getElementById('desc-'+generalId)){
                      document.getElementById('desc-'+generalId).focus(); 
                    }
                }), 0
            );
            for(var i=0;i<toggleArray.length;i += 1){
                if(toggleArray[i].id.split('-')[1] !== generalId){
                    cardArray[i].classList.remove('card-opened');
                    toggleArray[i].classList.add('slds-hide');
                    collapsedArray[i].classList.add('myPlanCard-hover');
                }
            }
            document.getElementById('card-'+generalId).classList.toggle('card-opened');
            document.getElementById("toggle-" + generalId).classList.toggle('slds-hide');
            document.getElementById('collapsed-'+generalId).classList.toggle('myPlanCard-hover');
            // Start Application event 
            var isCardOpened=document.getElementsByClassName('card-opened');
            var wrapperData=component.get("v.listReferralWrapper"); // Variable added by Arun
            if(isCardOpened.length === 1){
                var resourceIndexData=wrapperData[parseInt(generalId, 10)];
                helper.handleMapAccordianClickHelper(component,event,resourceIndexData,1,generalId);
            }
            if(isCardOpened.length === 0){ 
                //var resourceIndexData=wrapperData[parseInt(generalId, 10)];
                helper.handleMapAccordianClickHelper(component,event,{},0,generalId);
            }
        }
    },
    handleRate: function(component, event) {
        var button = event.getSource().getLocalId();
        var wrapdata = event.getSource().get("v.value");
        var labeldata = event.getSource().get("v.label");
        var feedbackdata = {};
        feedbackdata.referralId = wrapdata.referral.referralId;
        feedbackdata.sReferralOrgId = wrapdata.referral.sReferralOrgId;
        feedbackdata.bOrgIsClaimed = wrapdata.acc.bOrgIsClaimed;
        
        component.set("v.feedbackModalData",feedbackdata); 
        if(button === "markascomplete" || labeldata==="Rate"){
            component.set("v.isRadioSectionVisible",true);
        } else{
            component.set("v.isRadioSectionVisible",false); 
        }
        component.set("v.feedbackConditionalMsg",button);
        component.set("v.showFeedbackModal",true); 
    },
    closeFeedbackModal : function(component) {
        component.set("v.showFeedbackModal",false);
    },
    showResourceModal : function(component, event) {
        var wrapdata = event.getSource().get("v.value");
        component.set("v.wrapdata", wrapdata);
        component.set("v.resourceName",wrapdata.resource.sResourceName);
        // Added by Lagan for URL fecthing for the Send SMS functionality
        var url =window.location.href.split('/s')[0]+'/s/resource-details?resourceId='+btoa(wrapdata.resourceId)+
            '&locationId='+btoa(wrapdata.sLocationId)+'&zipcode='+btoa(wrapdata.sContactZipCode)+
            '&sContactId='+btoa(wrapdata.sResidentId);
        component.set("v.ResourceDetailURL", url);
        
        // End Lagan's changes
        component.set("v.showResourceModal",true);
        document.querySelectorAll(".planCardSection .my-plan-card").forEach(
            function getVal(item) {
                 item.classList.add('slds-hide');
            });
        document.getElementsByClassName("planMapSection")[0].style.display = "none";
    },
    handleRemove: function(component, event, helper) {
        var refRecord = event.getSource().get("v.value");
        component.set("v.selectedCard",refRecord);
        var btnHandlerValue = "NoThanks";
        if($A.util.isUndefinedOrNull(refRecord.referral.referralId)){
            helper.connectSuggestedResource(component, event, helper,refRecord,btnHandlerValue);
        }
    },
    handleDelete: function(component, event, helper) {
        helper.handleRemoveHandler(component, event, helper);
    },
    openWebsite: function(component, event){
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank");
    },
    viewResourceDetails :function(component, event, helper) {
        helper.viewResourceDetailsHandler(event);
    },
    navigateToUrl : function(component, event, helper){
        helper.navigateToResourceDetail(component, event);
    },
    handleConnect : function(component, event, helper){
        var refRecord = event.getSource().get("v.value");
        refRecord.resource.isDisabled = true;
        component.set("v.selectedCard",refRecord);
        var rscCard = component.get("v.listReferralWrapper");
		component.set("v.listReferralWrapper",rscCard);
        var btnHandlerValue = "Connect";
        helper.getOptOutInformation(component, event, helper,refRecord, btnHandlerValue);
        //helper.getOptOutInformation(component, event, helper,refRecord);
    },
    modalParametersHandler : function(component, event, helper){        
        var isConsAgreed = event.getParam("isConsentAgreed");
        var isModalClosed=event.getParam("isModalClosed");
        if(isConsAgreed){
            component.set("v.isConsentAgreed", isConsAgreed);
            var referralRecord = component.get("v.selectedCard");
            var btnHandlerValue = "Connect";
            helper.connectSuggestedResource(component, event, helper, referralRecord, btnHandlerValue);
        }
        if(isModalClosed){
            component.set("v.selectedCard.resource.isDisabled", false);
            var srchRslt = component.get("v.listReferralWrapper");
            component.set("v.listReferralWrapper", srchRslt);
            console.table(component.get("v.listReferralWrapper"));
         }
    },
    //RE_Release 1.1 – Defect 359141- Payal Dubela– Removing Favorite Functionality from My Plan
    /*,
    addToFavoritesUnopened : function(component, event, helper){
        var imgId= event.currentTarget.getElementsByTagName("img")[0];
        var data = event.currentTarget.getAttribute("data-info");
        if(data){
            var dataArray = data.split('#');
            component.set("v.LocResourceId", dataArray[0]);
            component.set("v.sResourceName",dataArray[1]);
            component.set("v.sOrganisationName",dataArray[2]);
        }
        if(imgId.src.indexOf("heartgray") > -1){
            imgId.src = imgId.src.replace("heartgray","heartred");
            helper.createFavoritesHelper(component); 
        }else{ 
            imgId.src = imgId.src.replace("heartred","heartgray");
            helper.deleteFavoritesHelper(component);
        }
    }*/
    openDrivingDirectionMap:function(component,event){
        var resourceClickedIndex=event.target.getAttribute("data-attriVal");
        var wrapperData=component.get("v.listReferralWrapper")[resourceClickedIndex];
        var resourceAddress1=wrapperData.location.sLocationAddress1;
        var resourceCity=wrapperData.location.sLocationCity;
        var resourceState=wrapperData.location.sLocationState;
        var resourceCountry=wrapperData.location.sLocationCountry;

        var address1=resourceAddress1!==undefined?resourceAddress1.split(' ').join('+'):'';
        var cityadd=resourceCity!==undefined?resourceCity.split(' ').join('+'):'';
        var stateadd=resourceState!==undefined?resourceState.split(' ').join('+'):'';
        var countryadd=resourceCountry!==undefined?resourceCountry.split(' ').join('+'):'';
        var resCompAddress=address1+'+'+cityadd+'+'+stateadd+'+'+countryadd;
        var redirectUrl=$A.get("$Label.c.googlemapurl")+resCompAddress;
        window.open(redirectUrl, "_blank");
    },
    ShowMeMore : function(component,event, helper){
        helper.ShowMeMore(component, event, helper);
    }
})