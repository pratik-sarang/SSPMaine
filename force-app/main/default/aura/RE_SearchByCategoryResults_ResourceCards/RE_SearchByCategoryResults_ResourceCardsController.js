({
    doInit :function(component) {
        component.set("v.currentPageURL", document.location.href);
        var connectButtonLabel = $A.get("$Label.c.connect");
        component.set("v.connectButtonLabel", connectButtonLabel);
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
            var data=event.target.name;
            var isCardOpened=document.getElementsByClassName('card-opened');
            if(isCardOpened.length === 1){
                helper.handleMapAccordianClickHelper(component,event,data,1,generalId);
            }else{
                helper.handleMapAccordianClickHelper(component,event,{},0,generalId);
            }
        }
    },
    viewResourceDetails:function(component, event){
        var zipcode = component.get("v.zipCode");
        var itemIndex = event.target.getAttribute("data-card");
        var data = component.get("v.searchresults")[itemIndex];
        var locationId = data.lstResourceLocations[0].id;
        window.open($A.get("$Label.c.rdresourceid")+btoa(data.resourceId)+
                    $A.get("$Label.c.andlocationid")+btoa(locationId)+$A.get("$Label.c.andzipcode")+btoa(zipcode), '_blank');
    },
    shareResource:function(component, event){
        var data = event.getSource().get("v.value");
        var account = data.account;
        component.set("v.resourceName", data.resourceName);

        var shareResourceWrapper = {'acc' : '','location':'','resource':''};
        var accWrapper = {'sReferralOrgName':'','sReferralOrgUrl':''};
        accWrapper.sReferralOrgName = account.accName;
        accWrapper.sReferralOrgUrl = data.url;
        shareResourceWrapper.acc = accWrapper;
        var locWrapper = {'sLocationAddress1':'','sLocationAddress2':'','sLocationCity':'','sLocationState':'','sLocationZip':'','sPOCPhone':''};
        locWrapper.sLocationAddress1 = data.lstResourceLocations[0].locationAddress1;
        locWrapper.sLocationAddress2 = data.lstResourceLocations[0].locationAddress2;
        locWrapper.sLocationCity =data.lstResourceLocations[0].locationCity;
        locWrapper.sLocationState = data.lstResourceLocations[0].locationState;        
        locWrapper.sLocationId = data.lstResourceLocations[0].id;
        locWrapper.sLocationZip = (data.lstResourceLocations[0].locationZip)?data.lstResourceLocations[0].locationZip:'';
        locWrapper.sPOCPhone = data.lstResourceLocations[0].pointOfContactPhone;
        shareResourceWrapper.location = locWrapper;
        var resWrapper = {'sResourceName':'','sSDOHCategory':''};
        resWrapper.sResourceName = data.resourceName;
        resWrapper.sSDOHCategory = data.lstDomains[0].domainName;        
        resWrapper.resourceId = data.resourceId;
        shareResourceWrapper.resource = resWrapper;
        component.set("v.wrapdata", shareResourceWrapper);
        component.set("v.showResourceModal", true);
        component.set("v.displayMap", false);
        if (document.getElementsByClassName('headingContainer')[0]) {
            document.getElementsByClassName('headingContainer')[0].classList.remove('slds-show');
            document.getElementsByClassName('headingContainer')[0].classList.add('slds-hide');
        }
        if (document.getElementsByClassName('myPlanLeftTab')[0]) {
            document.getElementsByClassName('myPlanLeftTab')[0].classList.remove('slds-show');
            document.getElementsByClassName('myPlanLeftTab')[0].classList.add('slds-hide');
        }
        if(document.getElementsByClassName('load-more-btn')[0]){
           document.getElementsByClassName('load-more-btn')[0].classList.add('slds-hide');
        }
    },
    modalParametersHandler : function(component, event, helper){        
        var isConsAgreed = event.getParam("isConsentAgreed");
        var isModalClosed=event.getParam("isModalClosed");
        if(isConsAgreed){
            component.set("v.isConsentAgreed", isConsAgreed);
            var selCardSchValue = component.get("v.selectedCardValue");
            //var rsSchReferralStatus = '';
            //RE_Release 1.4 – Bug 376577 - Payal Dubela 
            if(selCardSchValue.objResource && !$A.util.isUndefinedOrNull(selCardSchValue.objResource.Referrals__r) 
               && selCardSchValue.objResource.Referrals__r[0].Status__c === 'Draft'){
                //rsSchReferralStatus = selCardSchValue.objResource.Referrals__r[0].Status__c;
                helper.handleSchDraftConnectHelper(component, event, helper);
            } else {
                helper.createReferralOnConnect(component, event);
            }
        }
         //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
         if(isModalClosed){
            component.set("v.selectedCardValue.isDisabled", false);
            var srchRslt = component.get("v.searchresults");
            component.set("v.searchresults", srchRslt);
         }
    },
    handleConnect : function(component, event, helper) {
        var eventValue = event.getSource().get("v.value");
        var eventName	=	event.getSource().get("v.name");
        component.set("v.selectedCardValue",eventValue);
        component.set("v.selectedCardName",eventName);
        var srchRslt = component.get("v.searchresults");
        eventValue.isDisabled = true;
        component.set("v.selectedCardValue",eventValue);
        component.set("v.searchresults", srchRslt);
        var rsSchReferralStatus = '';
        var isGuest = eventValue.isGuest;
        if(isGuest){
            component.set("v.bShowLoginModal", true);
        }else{
            if(eventValue.objResource && !$A.util.isUndefinedOrNull(eventValue.objResource.Referrals__r)
               && eventValue.objResource.Referrals__r[0].Status__c === 'Draft'){
                rsSchReferralStatus = eventValue.objResource.Referrals__r[0].Status__c;
            }
            helper.getOptOutInformation(component, event, helper, rsSchReferralStatus);
        }   
    },
    createReferral:function(component,event){
        //Open create referral page
        var eventValue = event.getSource().get("v.value");
        component.set("v.selectedResourceId", eventValue.resourceId);
        component.set("v.selectedResourceAccountId",eventValue.accountId);
        component.set("v.selectedLocation",eventValue.lstResourceLocations[0].id);
        component.set("v.isCreateRefferell", true);
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
        
        document.getElementsByClassName('myPlanLeftTab')[0].classList.add('slds-hide');
        document.getElementsByClassName('planMapSection')[0].classList.add('slds-hide');
        document.getElementsByClassName('search-results-cards')[0].classList.add('slds-hide');
        /*document.getElementsByClassName('archtype-filter-section')[0].classList.add('display-none');
        document.getElementsByClassName('archtype-map-section')[0].classList.add('display-none');*/	

        component.set('v.bShowReferralPage',true);
        if(document.getElementsByClassName('load-more-btn')[0]){
            document.getElementsByClassName('load-more-btn')[0].classList.add('slds-hide');
        }
    },
    handleEventFromChild: function (component) {
        component.set('v.bShowReferralPage',false);
        component.set("v.isCreateRefferell", false);
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
    },
    openWebsite : function (component,event) {
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank");
    },
    addToFavoritesUnopened : function(component, event, helper){
        if(event.keyCode === 13 || event.type === "click"){
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
                imgId.title=$A.get("$Label.c.remove_favourite");
                helper.createFavoritesHelper(component); 
            }else{             
                imgId.src = imgId.src.replace("heartred","heartgray");
                imgId.title=$A.get("$Label.c.add_favorite");
                helper.deleteFavoritesHelper(component);
            }
        }
    },
    openDrivingDirectionMap:function(component,event){
        var resourceClickedIndex=event.target.getAttribute("data-attriVal");
        var wrapperData=component.get("v.searchresults")[resourceClickedIndex];
        var resourceAddress1=wrapperData.lstResourceLocations[0].locationAddress1;
        var resourceCity=wrapperData.lstResourceLocations[0].locationCity;
        var resourceState=wrapperData.lstResourceLocations[0].locationState;
        var address1=resourceAddress1!==undefined?resourceAddress1.split(' ').join('+'):'';
        var cityadd=resourceCity!==undefined?resourceCity.split(' ').join('+'):'';
        var stateadd=resourceState!==undefined?resourceState.split(' ').join('+'):'';
        var resCompAddress=address1+'+'+cityadd+'+'+stateadd;
        var redirectUrl=$A.get("$Label.c.googlemapurl")+resCompAddress;
        window.open(redirectUrl, "_blank");
    }
})