({
    doinItCountHandler: function(component) {
        var decodedUrlParam = (component.get("v.sContactId")) ? atob(component.get("v.sContactId")) : '';
        try {
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getMyPlansCount', function(result) {
                    //hide spinner when server response received
                    if (result.isSuccessful) {
                
                    component.set("v.myResourcebadgeCount",result.objectData.inProgressedWrapperCount );
                    component.set("v.myCompletedbadgeCount", result.objectData.completedWrapperCount);
                    component.set("v.myDraftbadgeCount", result.objectData.draftWrapperCount);
                    }
                },
                {
                "strContactId" : decodedUrlParam
            },false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    optedOut : function(component){
        try{
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getOptOutInfoSharingDetails', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){  
                    component.set("v.iscartOptIn", response.objectData.OptOutInfoSharing); 
                }
            }, null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    /* Init handler logic to fetch complete and inprogress referrals */
    doinItHandler: function(component, event, helper) {
        if(this.getURLParam().tab === "Suggested" && component.get("v.isLoadMore")===false && (event.getParam('name') != "MyResources" && event.getParam('name') != "Completed" && event.getParam('name') != "Privacysettings")){
            component.set("v.selectedItem","Suggested");
        }
        var selectedItem = component.get("v.selectedItem");
        var iPageSize;
        var pageNumber;
        if(selectedItem==='MyResources'){
            pageNumber = component.get("v.resOffsetInprogress")           
        }
        else if(selectedItem==='Completed'){
            pageNumber = component.get("v.resOffsetCompleted")        
        }
        else if(selectedItem==='Suggested'){
            pageNumber = component.get("v.resOffsetSuggestedForMe")
        }        
        iPageSize = component.get("v.resLimit")
        var decodedUrlParam = (component.get("v.sContactId")) ? atob(component.get("v.sContactId")) : '';
        try {
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var objNotCompletedReferralResponse = [];
            var objCompletedReferralResponse = [];
            var objDraftReferralResponse = [];
            var weekdayValue;
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getMyPlans', function(result) {
                    //hide spinner when server response received
                    if (result.isSuccessful) {
                        component.set("v.bIsMyCartServiceAvailable",result.objectData.isMyCartServiceAvailable);
                        component.set("v.isLoadMore",false);
                    if (parseInt(pageNumber,10) ===0)
                    {
                        var nop = parseInt(result.objectData.sGlbResLen,10) / parseInt(component.get('v.resLimit'),10);
                        if(selectedItem==='MyResources'){                        
                            component.set('v.resNoPagesInprogress',nop);
                        } else if(selectedItem==='Completed'){
                            component.set('v.resNoPagesCompleted',nop);
                        } else if(selectedItem==='Suggested'){
                            component.set('v.resNoPagesSuggestedForMe',nop);
                        }                                                                      
                    }                             
                    if(selectedItem==='MyResources'){
                        component.set('v.resOffsetInprogress',parseInt(pageNumber,10)+1);
                        component.set('v.initialLoadInProgress',true);                                                
                    } else if(selectedItem==='Completed'){
                        component.set('v.resOffsetCompleted',parseInt(pageNumber,10)+1);
                        component.set('v.initialLoadCompleted',true);                        
                    } else if(selectedItem==='Suggested'){
                        component.set('v.resOffsetSuggestedForMe',parseInt(pageNumber,10)+1);
                        component.set('v.initialLoadSuggestedForMe',true);                        
                        }
                        var disable = [];
                    disable=component.get('v.disableScrollList');
                    if(parseInt(result.objectData.sGlbResLen,10)<parseInt(component.get('v.resLimit'),10)){
                            if (disable.length > 0) {
                            if(disable.indexOf(selectedItem)!==-1){                                                                                                
                                    disable.splice(disable.indexOf(selectedItem), 1);
                                }
                            }
                            component.set("v.disableScroll", true);
                        } else {
                            disable.push(selectedItem);
                            component.set("v.disableScroll", false);
                        }
                    component.set('v.disableScrollList',disable);
                        var userlatAndLong = result.objectData.mylocation;
                        var userLocationAddress = result.objectData.mylocationdata;
                        var arrayMyResource = result.objectData.myresource;
                    var bReadOnly =  (result.objectData.profile !== 'Citizen_Individual') ? true : false;
                    // added by Pankaj as part of defect#343301 
                    if(!$A.util.isEmpty(component.get("v.sContactId")) && bReadOnly === false){
                      helper.displayErrorPage();
                    } 
                        component.set("v.bReadOnly", bReadOnly);
                        component.set("v.usrProfile", result.objectData.profile);
                        component.set("v.userLocation", userlatAndLong);
                        component.set("v.ContactDetails", result.objectData.mylocationdata);
                    objNotCompletedReferralResponse=component.get("v.listNotCompleteReferralWrapper");                    
                    objCompletedReferralResponse=component.get("v.listCompleteReferralWrapper");                    
                    objDraftReferralResponse = component.get("v.listDraftReferralWrapper");                                        
                    //var lstClosedDays;
                        
                        for (var i in arrayMyResource) {
                            if (arrayMyResource.hasOwnProperty(i)) {
                                //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
                                var objMyResourcesOperatingHours = "";
                                var notes= arrayMyResource[i].sLocationResourceNotes;
                                if (arrayMyResource[i].sOperatingHoursData !== null && arrayMyResource[i].sOperatingHoursData !== "" && arrayMyResource[i].sOperatingHoursData !== undefined) {
                                    objMyResourcesOperatingHours = JSON.parse(arrayMyResource[i].sOperatingHoursData);
                                }
                                if(!$A.util.isUndefinedOrNull(arrayMyResource[i].dMiles)){
                                    arrayMyResource[i].dMiles =arrayMyResource[i].dMiles >= 0? Math.round(arrayMyResource[i].dMiles * 100) / 100: "";
                                }else{
                                    arrayMyResource[i].dMiles='';
                                }
                                
                                if (objMyResourcesOperatingHours !== null && objMyResourcesOperatingHours !== "") {
                                    weekdayValue = helper.getDayName();
                                    if(objMyResourcesOperatingHours[weekdayValue][2]==='true' && objMyResourcesOperatingHours[weekdayValue][3]==='true'){
                                        arrayMyResource[i].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objMyResourcesOperatingHours) && objMyResourcesOperatingHours[weekdayValue][3]==='true' && !$A.util.isUndefinedOrNull(objMyResourcesOperatingHours[weekdayValue]) && objMyResourcesOperatingHours[weekdayValue][0] !== '' && objMyResourcesOperatingHours[weekdayValue][1]!==''){
                                        arrayMyResource[i].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objMyResourcesOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objMyResourcesOperatingHours[weekdayValue][1];
                                    }else if(!$A.util.isUndefinedOrNull(notes) && notes !== null && notes!==''){
                                        arrayMyResource[i].location.sOperatingHoursToday='';
                                    }else if(objMyResourcesOperatingHours[weekdayValue][3]==='false' && objMyResourcesOperatingHours[weekdayValue][2]==='true'){
                                        arrayMyResource[i].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objMyResourcesOperatingHours) && objMyResourcesOperatingHours[weekdayValue][3]==='false' && !$A.util.isUndefinedOrNull(objMyResourcesOperatingHours[weekdayValue]) && objMyResourcesOperatingHours[weekdayValue][0] !== '' && objMyResourcesOperatingHours[weekdayValue][1]!==''){
                                        arrayMyResource[i].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objMyResourcesOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objMyResourcesOperatingHours[weekdayValue][1];
                                    }else{
                                        arrayMyResource[i].location.sOperatingHoursToday='';
                                    }  
                                }else {
                                    arrayMyResource[i].location.sOperatingHoursToday = "";
                                }
                                objNotCompletedReferralResponse.push(arrayMyResource[i]);
                            }
                        }
                        var arrayCompletedResource = result.objectData.completed;
                        for (var j in arrayCompletedResource) {
                            if (arrayCompletedResource.hasOwnProperty(j)) {
                                //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
                                if(!$A.util.isUndefinedOrNull(arrayCompletedResource[j].dMiles)){
                                    arrayCompletedResource[j].dMiles =arrayCompletedResource[j].dMiles >= 0? Math.round(arrayCompletedResource[j].dMiles * 100) / 100: "";
                                }else{
                                    arrayCompletedResource[j].dMiles='';
                                }
                                
                                arrayCompletedResource[j].bIsComplete = true;
                                var objCompletedOperatingHours = "";
                                var completednotes= arrayCompletedResource[j].sLocationResourceNotes;
                                if (arrayCompletedResource[j].sOperatingHoursData !== null && arrayCompletedResource[j].sOperatingHoursData !== "" && arrayCompletedResource[j].sOperatingHoursData !== undefined) {
                                    objCompletedOperatingHours = JSON.parse(arrayCompletedResource[j].sOperatingHoursData);
                                }
                                
                                if (objCompletedOperatingHours !== null &&objCompletedOperatingHours !== "") {
                                    weekdayValue = helper.getDayName();
                                    if(objCompletedOperatingHours[weekdayValue][2]==='true' && objCompletedOperatingHours[weekdayValue][3]==='true'){
                                        arrayCompletedResource[j].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objCompletedOperatingHours) && objCompletedOperatingHours[weekdayValue][3]==='true' && !$A.util.isUndefinedOrNull(objCompletedOperatingHours[weekdayValue]) && objCompletedOperatingHours[weekdayValue][0] !== '' && objCompletedOperatingHours[weekdayValue][1]!==''){
                                        arrayCompletedResource[j].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objCompletedOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objCompletedOperatingHours[weekdayValue][1];
                                    }else if(!$A.util.isUndefinedOrNull(completednotes) && completednotes !== null && completednotes!==''){
                                        arrayCompletedResource[j].location.sOperatingHoursToday='';
                                    }else if(objCompletedOperatingHours[weekdayValue][3]==='false' && objCompletedOperatingHours[weekdayValue][2]==='true'){
                                        arrayCompletedResource[j].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objCompletedOperatingHours) && objCompletedOperatingHours[weekdayValue][3]==='false' && !$A.util.isUndefinedOrNull(objCompletedOperatingHours[weekdayValue]) && objCompletedOperatingHours[weekdayValue][0] !== '' && objCompletedOperatingHours[weekdayValue][1]!==''){
                                        arrayCompletedResource[j].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objCompletedOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objCompletedOperatingHours[weekdayValue][1];
                                    }else{
                                        arrayCompletedResource[j].location.sOperatingHoursToday='';
                                    }  
                                } else {    
                                    arrayCompletedResource[j].location.sOperatingHoursToday = "";
                                }
                                objCompletedReferralResponse.push(arrayCompletedResource[j]);
                            }
                        }
                        var arrayDraftResource = result.objectData.suggested;
                        for (var k in arrayDraftResource) {
                            if (arrayDraftResource.hasOwnProperty(k)) {
                                //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
                                if(!$A.util.isUndefinedOrNull(arrayDraftResource[k].dMiles)){
                                    arrayDraftResource[k].dMiles =arrayDraftResource[k].dMiles >= 0? Math.round(arrayDraftResource[k].dMiles * 100) / 100: "";
                                }else{
                                    arrayDraftResource[k].dMiles='';
                                }
                                arrayDraftResource[k].bIsComplete = true;
                                var objDraftOperatingHours = "";
                                var draftnotes= arrayDraftResource[k].sLocationResourceNotes;
                                if (arrayDraftResource[k].sOperatingHoursData !== null && arrayDraftResource[k].sOperatingHoursData !== "" && arrayDraftResource[k].sOperatingHoursData !== undefined) {
                                    objDraftOperatingHours = JSON.parse(arrayDraftResource[k].sOperatingHoursData);
                                }
                                if (objDraftOperatingHours !== null &&objDraftOperatingHours !== "") {
                                    weekdayValue = helper.getDayName();
                                    if(objDraftOperatingHours[weekdayValue][2]==='true' && objDraftOperatingHours[weekdayValue][3]==='true'){
                                        arrayDraftResource[k].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objDraftOperatingHours) && objDraftOperatingHours[weekdayValue][3]==='true' && !$A.util.isUndefinedOrNull(objDraftOperatingHours[weekdayValue]) && objDraftOperatingHours[weekdayValue][0] !== '' && objDraftOperatingHours[weekdayValue][1]!==''){
                                        arrayDraftResource[k].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objDraftOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objDraftOperatingHours[weekdayValue][1];
                                    }else if(!$A.util.isUndefinedOrNull(draftnotes) && draftnotes !== null && draftnotes!==''){
                                        arrayDraftResource[k].location.sOperatingHoursToday='';
                                    }else if(objDraftOperatingHours[weekdayValue][3]==='false' && objDraftOperatingHours[weekdayValue][2]==='true'){
                                        arrayDraftResource[k].location.sOperatingHoursToday = weekdayValue+' '+$A.get('$Label.c.referralstatusclosed');
                                    }else if(!$A.util.isUndefinedOrNull(objDraftOperatingHours) && objDraftOperatingHours[weekdayValue][3]==='false' && !$A.util.isUndefinedOrNull(objDraftOperatingHours[weekdayValue]) && objDraftOperatingHours[weekdayValue][0] !== '' && objDraftOperatingHours[weekdayValue][1]!==''){
                                        arrayDraftResource[k].location.sOperatingHoursToday = $A.get('$Label.c.today') + ' ' +objDraftOperatingHours[weekdayValue][0]+' '+$A.get('$Label.c.to')+' '+objDraftOperatingHours[weekdayValue][1];
                                    }else{
                                        arrayDraftResource[k].location.sOperatingHoursToday='';
                                    } 
                                } else {
                                    arrayDraftResource[k].location.sOperatingHoursToday = "";
                                }
                                objDraftReferralResponse.push(arrayDraftResource[k]);
                            }
                        }
                        component.set("v.listReferralWrapper", arrayMyResource);
                        component.set(
                            "v.listNotCompleteReferralWrapper",
                            objNotCompletedReferralResponse
                        );
                        component.set(
                            "v.listCompleteReferralWrapper",
                            objCompletedReferralResponse
                        );
                        component.set(
                            "v.listDraftReferralWrapper",
                            objDraftReferralResponse
                        );
                        component.set("v.displayLoader", false);
                        // if citizen name is not present/not retrieved from url then set it
                        if (
                            $A.util.isEmpty(
                                component.get("v.citizenName") && userLocationAddress
                            )
                        ) {
                            component.set(
                                "v.citizenName",
                                JSON.parse(userLocationAddress).Name
                            );
                        }
                        helper.getParamValue(component, event, helper);
                    } else {
                        helper.displayErrorPage();
                    }
                },
                {
                    strContactId: decodedUrlParam,
                    sPageType: selectedItem,
                    iPageSize: iPageSize,
                    pageNumber: pageNumber
                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    /* process resource details */
    processResourceDetails: function(component, event, helper) {
        //RE_Release 1.1 – Security Fixes - Payal Dubela  
        var decodedUrlParam = component.get("v.sContactId")
        ? atob(component.get("v.sContactId"))
        : "";
        try {
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(
                component,
                "c.shareMyPlanDetails",
                function(response) {
                    //hide spinner when server response received
                    
                    if (response.isSuccessful) {
                        helper.showToast(
                            component,
                            event,
                            helper,
                            "Success",
                            //$A.get("$Label.c.successstatus"),
                            $A.get("$Label.c.RE_MyPlan_EmailSuccess")
                        );
                        component.set("v.isSpinnerActive", false);
                    } else {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast(
                            $A.get("$Label.c.errorstatus"),
                            $A.get("$Label.c.errorstatus"),
                            errMsg
                        );
                        component.set("v.isSpinnerActive", false);
                    }
                },
                {
                    ContactDetails: decodedUrlParam
                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    /* display toast messages */
    displayToastMessage: function(component, title, msg, variant) {
        component.find("notifLib").showToast({
            title: title,
            message: msg,
            variant: variant
        });
    },
    /* Display toast messages */
    showToast: function(component, event, helper, variant, msg) {
        component.set("v.displayLoader", false);
        switch (variant) {
            case "ValidationFailed":
                helper.displayToastMessage(
                    component,
                    $A.get("$Label.c.errorstatus"),
                    msg,
                    "error"
                );
                break;
            case "Error":
                helper.displayToastMessage(
                    component,
                    $A.get("$Label.c.errorstatus"),
                    msg,
                    "error"
                );
                break;
            case "Success":
                helper.displayToastMessage(
                    component,
                    $A.get("$Label.c.successstatus"),
                    msg,
                    "success"
                );
                break;
            default:
        }
    },
    /* display map data*/
    mapDataHelper: function(
        component,
        event,
        notCompleteReferenceData,
        type,
        userLocation,
        cardIndex,
        resourceCardOpenCloseIndx
    ) {
        var mapData = [];
        for (var i = 0; i < notCompleteReferenceData.length; i += 1) {
            var latLongData = notCompleteReferenceData[i].referral.sReferralLatLong;
            var splitData = latLongData.split("##");
            var markarText =
                notCompleteReferenceData[i].acc.sReferralOrgName + "<br/>";
            if (
                !$A.util.isUndefinedOrNull(
                    notCompleteReferenceData[i].location.sLocationAddress1
                )
            ) {
                markarText +=
                    notCompleteReferenceData[i].location.sLocationAddress1 + ",";
            }
            if (
                !$A.util.isUndefinedOrNull(
                    notCompleteReferenceData[i].location.sLocationAddress2
                )
            ) {
                markarText +=
                    notCompleteReferenceData[i].location.sLocationAddress2 + ",";
            }
            if (
                !$A.util.isUndefinedOrNull(
                    notCompleteReferenceData[i].location.sLocationCity
                )
            ) {
                markarText +=
                    notCompleteReferenceData[i].location.sLocationCity + "<br/>";
            }
            if (
                !$A.util.isUndefinedOrNull(
                    notCompleteReferenceData[i].location.sLocationState
                )
            ) {
                markarText += notCompleteReferenceData[i].location.sLocationState + ",";
            }
            markarText += notCompleteReferenceData[i].location.sLocationZip;
            
            if (
                !isNaN(parseFloat(splitData[0], 10)) &&
                !isNaN(parseFloat(splitData[1], 10))
            ) {
                if (
                    parseInt(cardIndex, 10) === parseInt(i, 10) &&
                    resourceCardOpenCloseIndx === 1
                ) {
                    component.set("v.showMultiPleMarker", false);
                    mapData.push({
                        lat: parseFloat(splitData[0], 10),
                        lng: parseFloat(splitData[1], 10),
                        markerText: markarText,
                        selected: "selectedLocation"
                    });
                } else {
                    component.set("v.showMultiPleMarker", false);
                    mapData.push({
                        lat: parseFloat(splitData[0], 10),
                        lng: parseFloat(splitData[1], 10),
                        markerText: markarText,
                        selected: "None"
                    });
                }
            }
        }
        
        if (!$A.util.isEmpty(userLocation)) {
            var loggedInUserLocation = userLocation.split("##");
        	var mapOptionsCenter = {"lat":parseFloat(loggedInUserLocation[0]), "lng":parseFloat(loggedInUserLocation[1])};
        	mapData.push({"lat":parseFloat(loggedInUserLocation[0]), "lng":parseFloat(loggedInUserLocation[1]), "markerText":'My location',"selected":"My location"})
        }
        
        component.set("v.mapData", mapData);
        component.set("v.mapOptionsCenter", mapOptionsCenter);
        if (type === "NotCompleted") {
            component.set("v.showMultiPleMarker", true);
            component.set("v.showMultiPleMarkerForCompleted", false);
        }
        if (type === "Completed") {
            component.set("v.showMultiPleMarkerForCompleted", false);
            component.set("v.showMultiPleMarker", false);
            component.set("v.showMultiPleMarkerForCompleted", true);
        }
        component.set("v.showSingleMarkerForCompleted", false);
    },
    /* get day name */
    getDayName: function() {
        var weekdays = new Array(7);
        weekdays[0] = "Sunday";
        weekdays[1] = "Monday";
        weekdays[2] = "Tuesday";
        weekdays[3] = "Wednesday";
        weekdays[4] = "Thursday";
        weekdays[5] = "Friday";
        weekdays[6] = "Saturday";
        
        var current_date = new Date();
        var weekdayValue = current_date.getDay();
        return weekdays[weekdayValue];
    },
    /* navigation to oneview */
    backToOneView: function(component) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/clients?clientId="+component.get("v.sContactId")
        });
        urlEvent.fire();
    },
    /* get client Id from URL params */
    getParamValue: function(component, event, helper) {
        var recid = this.getURLParam().sContactId;
        var clientName = this.getURLParam().client;
        var tab = this.getURLParam().tab;
        if(!$A.util.isUndefinedOrNull(recid) && recid !== ''){
            component.set("v.sContactId", recid);
        }
        if(!$A.util.isUndefinedOrNull(clientName) && clientName !== ''){
            component.set("v.citizenName", atob(clientName));
        }
        if(!$A.util.isUndefinedOrNull(tab) && tab !== '' && component.get('v.isInitialLoad')===true){
            if(tab === 'Privacysettings') {
                component.set("v.bIsPrivacySettings", true);
                component.set("v.bIsResourceSection", false);
            } else {
                component.set("v.bIsPrivacySettings", false);
                component.set("v.bIsResourceSection", true);
            }
            component.set("v.selectedItem", tab);
            component.set('v.isInitialLoad',false);
        } 
        else {
            helper.handleBeforeSelectHelper(component, event, helper);
        }
        
        if(tab === "Suggested"){
            helper.handleBeforeSelectHelper(component, event, helper);
        }
        
    },
    /* get URL params */
    getURLParam: function() {
        var query = location.search.substr(1);
        var result = {};
        if(query!==''){
            query.split("&").forEach(function(part) {
                var item = part.split("=");
                result[item[0]] = decodeURIComponent(item[1]);
            });
        }
        return result;
    },
    showAllLoactionsMarker: function(component, event, index, cardOpnCloseIndx) {
        var selectedTab = component.get("v.selectedItem");
        var userLocation = component.get("v.userLocation");
        component.set("v.showSingleMarkerForCompleted", false);
        if(selectedTab === 'Completed'){
            component.set("v.showMultiPleMarkerForCompleted",false)
            this.mapDataHelper(component,event,component.get("v.listCompleteReferralWrapper"),'Completed', userLocation,index,cardOpnCloseIndx);
        }
        if(selectedTab === 'MyResources'){
            this.mapDataHelper(component,event,component.get("v.listNotCompleteReferralWrapper"),'NotCompleted', userLocation,index,cardOpnCloseIndx);
        }
        if(selectedTab === 'Suggested'){
            this.mapDataHelper(component,event,component.get("v.listDraftReferralWrapper"),'Completed', userLocation,index,cardOpnCloseIndx);
        }
    },
    displayErrorPage: function() {
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: $A.get("$Label.c.errorpage")
        });
        urlEvent.fire();*/
        //RE_Release 1.1 – Security Fixes - Payal Dubela
        window.open($A.get("$Label.c.errorpage"), '_self');
    },
    
    handleBeforeSelectHelper: function(component, event, helper) {
        var userLocation = component.get("v.userLocation");
        var valueForType;
        if (document.getElementsByClassName("planMapSection")[0]) {
            document.getElementsByClassName("planMapSection")[0].style.display = "block";
        }
        document.querySelectorAll(".planCardSection .my-plan-card").forEach(
            function getVal(item) {
                if(item.classList.contains('slds-hide')){
                    item.classList.remove('slds-hide'); 
            }
        });
        if(component.get('v.selectedItem')==='MyResources'){            
            component.set("v.bShowResourceModal", false);
            component.set("v.bIsPrivacySettings", false);
            component.set("v.bShowSelectAssessment", false);
            component.set("v.bIsResourceSection", true);
            component.set("v.listReferralWrapper", component.get("v.listNotCompleteReferralWrapper"));            
            if (component.get("v.listNotCompleteReferralWrapper").length === 0) {
                component.set("v.displayCard", false);
                component.set("v.noresourcefound", $A.get("$Label.c.noresourcefound"));
            }
            else{
                component.set("v.displayCard", true);
            }
            helper.mapDataHelper(component,event,component.get("v.listNotCompleteReferralWrapper"),'NotCompleted',userLocation,"");
        }else if(component.get('v.selectedItem')=== 'Completed'){        
            component.set("v.bShowResourceModal", false);
            component.set("v.bIsPrivacySettings", false);
            component.set("v.bShowSelectAssessment", false);
            component.set("v.bIsResourceSection", true);
            component.set("v.listReferralWrapper", component.get("v.listCompleteReferralWrapper"));            
            if (component.get("v.listCompleteReferralWrapper").length === 0) {
                component.set("v.displayCard", false);
                component.set("v.noresourcefound", $A.get("$Label.c.nocompleteresources"));
            }
            else{
                component.set("v.displayCard", true);
            }
            helper.mapDataHelper(component,event,component.get("v.listCompleteReferralWrapper"),'Completed',userLocation,"");
        }else if(component.get('v.selectedItem')=== 'Suggested'){
    $A.util.addClass(component.find("mobile-buttons"),"slds-hide");
            component.set("v.sLblHeading", $A.get("$Label.c.SuggestedForMe"));
            component.set("v.bShowResourceModal", false);
            component.set("v.bIsPrivacySettings", false);
            component.set("v.bShowSelectAssessment", false);
            component.set("v.bIsResourceSection", true);
            component.set(
                "v.listReferralWrapper",
                component.get("v.listDraftReferralWrapper")
            );
            component.set("v.displayCard", true);
            if (
                component.get("v.listDraftReferralWrapper").length === 0 &&
                !component.get("v.displayLoader")
            ) {
                component.set("v.displayCard", false);
                component.set("v.noresourcefound", $A.get("$Label.c.SuggestedCartLabel"));
            }
            console.log(component.get("v.listDraftReferralWrapper").length);
            var valueForType;
            if(component.get("v.listDraftReferralWrapper").length === 0){
                valueForType = "Suggested";
                component.set("v.displayCard", true);
                
            }
            else{
                valueForType = "Completed";
            }
            console.log(userLocation);
            if (userLocation) {
                helper.mapDataHelper(
                    component,
                    event,
                    component.get("v.listDraftReferralWrapper"),
                    valueForType,
                    userLocation,
                    ""
                );
            }
        }else if(component.get('v.selectedItem')==='Privacysettings'){
            component.set("v.bIsPrivacySettings", true);
            component.set("v.bShowResourceModal", false);
            component.set("v.bIsResourceSection", false);
            component.set("v.bShowSelectAssessment", false);
            $A.util.addClass(component.find("mobile-buttons"),"slds-hide");
            component.set("v.sLblHeading", $A.get("$Label.c.privacysettings"));
    } else if (component.get('v.selectedItem') === 'Surveys') { 
            var lst = component.get("v.lstAssessment");   
            component.set("v.bshowassessmentques", false);
            component.set("v.bShowSelectAssessment", true);
            component.set("v.bIsPrivacySettings", false);
            component.set("v.bShowResourceModal", false);
            component.set("v.bIsResourceSection", false);
            if(lst.length>0){
                var childCmp = component.find("selectassessment");
                childCmp.resetsurvey(true);
                component.set("v.bShowtemplate", true);
            }
        }
    }
});
