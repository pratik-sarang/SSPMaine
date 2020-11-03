({
    doinIt: function (component, event, helper) {
        helper.doInitHandler(component);

    },
    handleCategoryClick: function (component, event) {
        var generalId = event.currentTarget.id.split('_')[1];
        document.getElementById('category_' + generalId).classList.toggle('category-closed');
    },
    handleAccordionClick: function (component, event, helper) {
        //var generalId=event.getSource().get("v.id").split('_')[1];
        var generalId = event.target.id.split('_')[1];
        var cardArray = document.getElementsByClassName('resource-card');
        for (var i = 0; i < cardArray.length; i += 1) {
            if (cardArray[i].id.split('_')[1] !== generalId) {
                cardArray[i].classList.remove('card-opened');
            }
        }
        document.getElementById('card_' + generalId).classList.toggle('card-opened');
        //var data = event.getSource().get("v.title");
        var data = event.target.name;
        var isCardOpened = document.getElementsByClassName('card-opened');
        if (isCardOpened.length === 1) {
            helper.handleMapAccordianClickHelper(component, event, data, 1, generalId);
        } else {
            helper.handleMapAccordianClickHelper(component, event, data, 0, generalId);
        }
    },
    loadMoreResource: function (component, event, helper) {
        var generalId = event.getSource().get("v.name").split('_')[1];
        document.getElementById('goal_' + generalId).classList.toggle('goal-expanded');

        helper.loadMoreResources(component, event); //Nandita: 04/10/2020: added parameters as a part of perf issue# 357266
    },
    //Nandita: 04/10/2020: added parameters as a part of perf issue# 357266
    loadLessResource: function (component, event, helper) {
        var generalId = event.getSource().get("v.name").split('_')[1];
        document.getElementById('goal_' + generalId).classList.toggle('goal-expanded');
        helper.loadLessResources(component, event);
    },
    viewResponses: function (component) {
        component.set("v.isResults", false);
        component.set("v.isCreateReferral", false);
        component.set("v.isViewResponses", true);
    },
    navigateToUrl: function (component, event, helper) {
        helper.navigateToResourceDetail(component, event);
    },
    openWebsite: function (component, event, helper) {
        helper.openWebsiteHelper(component, event);
    },
    onCheck: function (component, event, helper) {
        var val = event.getSource().get("v.value");
        if (event.getSource().get("v.checked")) {
            val.bisCheckboxCheck = true;
        }
        else {
            val.bisCheckboxCheck = false;
        }
        helper.disableCreateButton(component, event);
    },
    createReferrals: function (component, event, helper) {
        helper.createReferralsHelper(component);
    },
    backToResults: function (component, event, helper) {
        helper.backToResultsHelper(component);
    },
    backToOneView: function (component, event, helper) {
        helper.backToOneView(component);
    },

    addRemoveFavorites: function (component, event, helper) {
        if(event.keyCode === 13 || event.type === "click"){
            var cmpId = component.find("favorite-selected");
            $A.util.toggleClass(cmpId, "slds-is-selected");
            // console.log('event archetype:'+ JSON.stringify(event));  
            var locResId = event.currentTarget.dataset.locresid;
            var orgName = event.currentTarget.dataset.orgname;
            var resName = event.currentTarget.dataset.resname;
            //  var archData=component.get("v.archetypeResource");
            component.set("v.LocResourceId", locResId);
            component.set("v.sResourceName", resName);
            component.set("v.sOrganisationName", orgName);
            var imgId = event.currentTarget.getElementsByTagName("img")[0];
            if (imgId.src.indexOf("heartred") > -1) {
                imgId.src = imgId.src.replace("heartred", "heartgray");
                helper.deleteFavoritesHelper(component);
                //Fix for bug: 347208
                /* for(var i in archData.lstCategoryBlock)
                {	
                    for(var j in archData.lstCategoryBlock[i].lstGoalBlock ){
                        for(var k in archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile ){
                            
                            if(archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].locationResourceId==locResId){
                                archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].favoriteId='';
                            } 
                        }
                    }
                } */

            }
            else {
                imgId.src = imgId.src.replace("heartgray", "heartred");
                helper.createFavoritesHelper(component);
                //Fix for bug: 347208
                /* for(var i in archData.lstCategoryBlock)
                {	
                    for(var j in archData.lstCategoryBlock[i].lstGoalBlock ){
                        for(var k in archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile ){
                            if(archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].locationResourceId==locResId){
                                archData.lstCategoryBlock[i].lstGoalBlock[j].lstResourceTile[k].favoriteId='abc';
                            } 
                        }
                    }
                }
                
            }
            component.set("v.archetypeResource",archData);
            var z=1; */
                //component.set("v.archetypeResource",component.get("v.archetypeResource"));
            }
        }
    },
    handleConnect: function (component, event, helper) {
        var eventValue = event.getSource().get("v.value");
        var eventName = event.getSource().get("v.name");
        component.set("v.selectedCardValue", eventValue);
        component.set("v.selectedCardName", eventName);
        //RE_Release 1.3 – Connect Button Issue - Payal Dubela  
        if(!$A.util.isUndefinedOrNull(eventValue)){
        eventValue.isDisabled = true;
        }
        component.set("v.selectedCardValue", eventValue);
        var assmnts = component.get("v.assessmentResource");
        component.set("v.assessmentResource", assmnts);
        var rsAchReferralStatus = '';
        if (component.get("v.isGuest")) {
            component.set("v.bShowLoginModal", true);
        } else {
            if (!$A.util.isUndefinedOrNull(eventValue.objReferral)
                && eventValue.objReferral.Status__c === 'Draft') {
                rsAchReferralStatus = eventValue.objReferral.Status__c;
            }
            helper.getOptOutInformation(component, event, helper, rsAchReferralStatus);
        }
    },
    modalParametersHandler: function (component, event, helper) {
        var isConsAgreed = event.getParam("isConsentAgreed");
                var isModalClosed=event.getParam("isModalClosed");
        if (isConsAgreed) {
            component.set("v.isConsentAgreed", isConsAgreed);
            var selCardAchValue = component.get("v.selectedCardValue");

            if (!$A.util.isUndefinedOrNull(selCardAchValue.objReferral)
                && selCardAchValue.objReferral.Status__c === 'Draft') {

                helper.handleAchDraftConnectHelper(component, event, helper);
            } else {
                helper.createReferralOnConnect(component, event);
            }
        }
                //RE_Release 1.3 – Connect Button Issue - Payal Dubela 
                if(isModalClosed){
                    component.set("v.selectedCardValue.isDisabled", false);
                    var assmnts = component.get("v.assessmentResource");
                    component.set("v.assessmentResource", assmnts);
                }
                
    },

})