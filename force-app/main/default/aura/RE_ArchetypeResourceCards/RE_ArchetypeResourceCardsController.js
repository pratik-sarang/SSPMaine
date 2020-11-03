({
    doinIt : function(component, event, helper) { 
        helper.getResourceDetails(component, event, helper);
        var domainObj=component.get('v.domainObj');
        if(!domainObj){
            domainObj={}; 
        }
        var domainInfo=component.get("v.archetypeResource.lstCategoryBlock");
        for(var i=0;i<domainInfo.length;i+=1){
            if(domainObj[domainInfo[i].strDomain]){
                domainObj[domainInfo[i].strDomain]=domainObj[domainInfo[i].strDomain];
                domainInfo[i].collapsed=domainObj[domainInfo[i].strDomain];
            }
            else{
                domainObj[domainInfo[i].strDomain]=false;
                domainInfo[i].collapsed=false;
            }
        }
        component.set('v.domainObj',domainObj);
    },
    handleAccordionClick : function(component, event, helper) { 
        if(event.keyCode === 13 || !event.keyCode){
            var generalId=event.target.id.split('_')[1];
            var cardArray=document.getElementsByClassName('resource-card');
            window.setTimeout(
                $A.getCallback(function() {
                    if(document.getElementById('desc-'+generalId)){
                        document.getElementById('desc-'+generalId).focus(); 
                    }
                }), 0
            );
            for(var i=0;i<cardArray.length;i+=1){
                if(cardArray[i].id.split('_')[1] !== generalId){
                    cardArray[i].classList.remove('card-opened'); 
                }
            }
            document.getElementById('card_'+generalId).classList.toggle('card-opened');
            var data = event.target.name;
            var isCardOpened=document.getElementsByClassName('card-opened');
            if(isCardOpened.length === 1){
                helper.handleMapAccordianClickHelper(component,event,data,1,generalId);
            }else{
                helper.handleMapAccordianClickHelper(component,event,data,0,generalId);
            }
        }
    },
    loadMoreResource : function(component, event, helper) { 
        //var showmore = true;
        var generalId=event.getSource().get("v.name").split('_')[1];
        document.getElementById('goal_'+generalId).classList.toggle('goal-expanded');
        if($A.util.hasClass(event.getSource(),'see-all')){
            helper.loadMoreResourceHelper(component, event);
        }else{
            helper.loadLessResourceHelper(component, event);
        }
    },
    init: function(component,event,helper){
        helper.getResourceDetails(component, event, helper);
    },
    viewResourceDetails:function(component, event){
        var archId = component.get("v.archetypeId");
        var zipcode = component.get("v.zipcode");
        var data = event.getSource().get("v.value");
        window.open('resource-details?resourceId='+btoa(data.resourceId)+
                    '&locationId='+btoa(data.locationId)+'&zipcode='+btoa(zipcode)+ //data.locationZipcode
                    '&returl=archetype?Id='+btoa(archId), '_blank');
    },
    showResourceModal : function(component, event) {
        component.set("v.currentUrl", document.URL);
        
        if(document.getElementsByClassName('archtype-banner')[0]){
            document.getElementsByClassName('archtype-banner')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-header')[0]){
            document.getElementsByClassName('archtype-header')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('resource-cards-section')[0]){
            document.getElementsByClassName('resource-cards-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-filter-section')[0]){
            document.getElementsByClassName('archtype-filter-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
            document.getElementsByClassName('archtype-map-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.add('display-none');
        }
        var data = event.getSource().get("v.value");
        component.set("v.resourceName", data.resourceName);

        var shareResourceWrapper = {'acc' : '','location':'','resource':''};
        var accWrapper = {'sReferralOrgName':'','sReferralOrgUrl':''};
        accWrapper.sReferralOrgName = data.accountProviderName;
        accWrapper.sReferralOrgUrl = data.accountWebsite;
        shareResourceWrapper.acc = accWrapper;
        var locWrapper = {'sLocationAddress1':'','sLocationAddress2':'','sLocationCity':'','sLocationState':'','sLocationZip':'','sPOCPhone':''};
        locWrapper.sLocationAddress1 = data.locationAddress1;
        locWrapper.sLocationAddress2 = data.locationAddress2;
        locWrapper.sLocationCity = data.locationCity;
        locWrapper.sLocationState = data.locationState;
        locWrapper.sLocationId = data.locationId;
        locWrapper.sLocationZip = (data.locationZipcode)?data.locationZipcode:'';
        locWrapper.sPOCPhone = data.locationPhone;
        shareResourceWrapper.location = locWrapper;
        var resWrapper = {'sResourceName':'','sSDOHCategory':''};
        resWrapper.sResourceName = data.resourceName;
        resWrapper.sSDOHCategory = data.resourceSdohCategory;
        resWrapper.resourceId = data.resourceId;
        shareResourceWrapper.resource = resWrapper;
        component.set("v.wrapdata", shareResourceWrapper);
        component.set("v.showResourceModal",true);
    },
    operatingHoursDayValue : function(component, weekdayValue, locTimeData){
        var sOperatingHoursDataValue;
        if(weekdayValue === "Monday"){
            if(component.get("v.mondayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.MondayOpen+ ' to ' + locTimeData.MondayClose;
            }
        }
        if(weekdayValue === "Tuesday"){
            if(component.get("v.tuesdayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.TuesdayOpen+ ' to ' + locTimeData.TuesdayClose;
            }
        }
        if(weekdayValue === "Wednesday"){
            if(component.get("v.wednesdayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.WednesdayOpen+ ' to ' + locTimeData.WednesdayClose;
            }
        }
        if(weekdayValue === "Thursday"){
            if(component.get("v.thursdayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.ThursdayOpen+ ' to ' + locTimeData.ThursdayClose;
            }
        }
        if(weekdayValue === "Friday"){
            if(component.get("v.fridayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.FridayOpen+ ' to ' + locTimeData.FridayClose;
            }
        }
        if(weekdayValue === "Saturday"){
            if(component.get("v.saturdayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.SaturdayOpen+ ' to ' + locTimeData.SaturdayClose;
            }
        }
        if(weekdayValue === "Sunday"){
            if(component.get("v.sundayClose")){
                sOperatingHoursDataValue = $A.get('$Label.c.Closed');
            }else{
                sOperatingHoursDataValue = $A.get('$Label.c.today')+ ' ' +locTimeData.SundayOpen+ ' to ' + locTimeData.SundayClose;
            }
        }
        return sOperatingHoursDataValue;
    },
    openWebsite: function(component, event){
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
            url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank"); 
    },
    openDrivingDirectionMap:function(component,event){
        var latLong=event.target.name;
        //var latLongReplaced=latLong.replace("##",",");
        var replaceWithPlus=latLong.replace(/ /g,"+");
        var latLongReplaced=replaceWithPlus.replace(/\,/g,"");
        var redirectUrl=$A.get("$Label.c.googlemapurl")+latLongReplaced;
        window.open(redirectUrl, "_blank");
    },
    modalParametersHandler : function(component, event, helper){        
        var isConsAgreed = event.getParam("isConsentAgreed");
        var isModalClosed=event.getParam("isModalClosed");
        if(isConsAgreed){
            component.set("v.isConsentAgreed", isConsAgreed);
            var selCardAchValue = component.get("v.selectedCardValue");
            
            if(!$A.util.isUndefinedOrNull(selCardAchValue.objReferral) 
               && selCardAchValue.objReferral.Status__c === 'Draft'){
                
                helper.handleAchDraftConnectHelper(component);
            } else {
                helper.createReferralOnConnect(component, event);
            }
        }
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
        if(isModalClosed){
            component.set("v.selectedCardValue.isDisabled", false);
            var assmnts = component.get("v.archetypeResource");
            component.set("v.archetypeResource", assmnts);
        }

    },
    handleConnect : function(component, event, helper) {
        var eventValue = event.getSource().get("v.value");
        var eventName	=	event.getSource().get("v.name");
        component.set("v.selectedCardValue",eventValue);
        component.set("v.selectedCardName",eventName);
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela  
        if(!$A.util.isUndefinedOrNull(eventValue)){
        eventValue.isDisabled = true;
        }
        component.set("v.selectedCardValue",eventValue);
        var assmnts = component.get("v.archetypeResource");
        component.set("v.archetypeResource", assmnts);
        var rsAchReferralStatus = '';
        if(component.get("v.isGuest")){
            component.set("v.bShowLoginModal", true);
        }else{
            if(!$A.util.isUndefinedOrNull(eventValue.objReferral)
               && eventValue.objReferral.Status__c === 'Draft'){
                rsAchReferralStatus = eventValue.objReferral.Status__c;
            }
            helper.getOptOutInformation(component, event, helper, rsAchReferralStatus);
        }
    },
    createReferral:function(component,event){
        //Open create referral page
        var eventValue = event.getSource().get("v.value");
        component.set("v.selectedResourceId", eventValue.resourceId);
        component.set("v.selectedResourceAccountId",eventValue.accountId);
        component.set("v.selectedLocation",eventValue.locationId);
        
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
        
        if(document.getElementsByClassName('archtype-banner')[0]){
            document.getElementsByClassName('archtype-banner')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-header')[0]){
            document.getElementsByClassName('archtype-header')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('resource-cards-section')[0]){
            document.getElementsByClassName('resource-cards-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-filter-section')[0]){
            document.getElementsByClassName('archtype-filter-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
            document.getElementsByClassName('archtype-map-section')[0].classList.add('display-none');
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.add('display-none');
        }
        component.set('v.bShowResourceDetail',false);
    },
    navigateToUrl : function(component, event, helper){
        helper.navigateToResourceDetail(component, event);
    },
    handleCategoryClick:function(component, event){
        var generalId=event.currentTarget.id.split('_')[1];
        var categoryClicked=event.target.getAttribute("data-category");
        var domainObj=component.get('v.domainObj');
        domainObj[categoryClicked]=!domainObj[categoryClicked];  
        document.getElementById('category_'+generalId).classList.toggle('category-closed');
        component.set('v.domainObj',domainObj); 
    },
    addRemoveFavorites:function(component, event, helper){
        if(event.keyCode === 13 || event.type === "click"){
            var cmpId = component.find("favorite-selected");
            $A.util.toggleClass(cmpId,"slds-is-selected");
            var locResId = event.currentTarget.dataset.locresid;
            var orgName = event.currentTarget.dataset.orgname;
            var resName = event.currentTarget.dataset.resname;
            var archData=component.get("v.archetypeResource");
            component.set("v.LocResourceId",locResId);
            component.set("v.sResourceName",resName);
            component.set("v.sOrganisationName",orgName);
            var imgId= event.currentTarget.getElementsByTagName("img")[0];
            if(imgId.src.indexOf("heartred") > -1){
                imgId.src = imgId.src.replace("heartred","heartgray");
                helper.deleteFavoritesHelper(component);  
                //Fix for bug: 347208
                for(var i in archData.lstCategoryBlock){
                if(archData.lstCategoryBlock.hasOwnProperty(i)){	
                    for(var j in archData.lstCategoryBlock[i].lstGoalBlock ){
                    if(archData.lstCategoryBlock[i].lstGoalBlock.hasOwnProperty(j)){
                        for(var k in archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile ){
                        if(archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile.hasOwnProperty(k)){
                            if(archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].locationResourceId===locResId){
                                archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].favoriteId='';
                            } 
                        }
                    }
                    }
                    }
                }
            }
                
            }
            else{
                imgId.src = imgId.src.replace("heartgray","heartred");            
                helper.createFavoritesHelper(component);
                //Fix for bug: 347208
                for(var x in archData.lstCategoryBlock){
                if(archData.lstCategoryBlock.hasOwnProperty(x)){
                    for(var y in archData.lstCategoryBlock[x].lstGoalBlock ){
                    if(archData.lstCategoryBlock[x].lstGoalBlock.hasOwnProperty(y)){
                        for(var z in archData.lstCategoryBlock[x].lstGoalBlock[y].lstResourceTile ){
                        if(archData.lstCategoryBlock[x].lstGoalBlock[y].lstResourceTile.hasOwnProperty(z)){
                            if(archData.lstCategoryBlock[x].lstGoalBlock[y].lstResourceTile[z].locationResourceId===locResId){
                                archData.lstCategoryBlock[x].lstGoalBlock[y].lstResourceTile[z].favoriteId='abc';
                            } 
                        }
                    }
                    }
                    }
                }
                }
                
            }
            component.set("v.archetypeResource",archData);
        }
    }
})