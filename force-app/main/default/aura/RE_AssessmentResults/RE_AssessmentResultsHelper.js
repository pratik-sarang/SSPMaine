({
    doInitHandler: function (component) {
        try {
            component.set("v.isSpinnerActive", true);
            //nandita 26-02-2020: added code to retrieve Assessment Id for Guest User

            var AssessmentId = component.get("v.userAssessmentId");
            if (AssessmentId === '' || AssessmentId === null || AssessmentId === undefined) {
                var url = new URL(document.location.href);
                var urlSplit = url.searchParams.get("Id");
                var decryptedId;
                if (!$A.util.isUndefinedOrNull(urlSplit)) {
                    if (btoa(atob(urlSplit)) === urlSplit) {
                        decryptedId = window.atob(urlSplit);
                    }
                    else {
                        decryptedId = urlSplit;
                    }
                    component.set("v.userAssessmentId", decryptedId);

                }
            }

            var bSuper = component.find("bSuper");
            bSuper.callServer(
                component,
                "c.getAssessmentResourcesResults",
                function (response) {
                    component.set("v.isSpinnerActive", false);
                    if (response.isSuccessful) {
                        var assessResults = response.objectData.lstAssessmentResults;

                        var red = 0;
                        var yellow = 0;
                        var green = 0;
                        if (assessResults.lstDomainBlock !== undefined) {
                            for (var i = 0; i < assessResults.lstDomainBlock.length; i += 1) {
                                var catData = assessResults.lstDomainBlock[i];
                                if (
                                    assessResults.lstDomainBlock[i].sScoreColorStatus === "Red"
                                ) {
                                    red = red + 1;
                                } else if (
                                    assessResults.lstDomainBlock[i].sScoreColorStatus === "Yellow"
                                ) {
                                    yellow = yellow + 1;
                                } else if (
                                    assessResults.lstDomainBlock[i].sScoreColorStatus === "Green"
                                ) {
                                    green = green + 1;
                                }
                                if (!$A.util.isUndefinedOrNull(catData.lstGoalBlock)) {
                                    for (var j = 0; j < catData.lstGoalBlock.length; j += 1) {
                                        var goalData = catData.lstGoalBlock[j];
                                        if (!$A.util.isUndefinedOrNull(goalData.lstResourceTile)) {
                                            for (
                                                var k = 0;
                                                k < goalData.lstResourceTile.length;
                                                k += 1
                                            ) {
                                                var resourceData = goalData.lstResourceTile[k];
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
                                                var weekDay = weekdays[weekdayValue];

                                                //if(!$A.util.isUndefinedOrNull(resourceData.locationIsClosedDay) && resourceData.locationIsClosedDay !== ''){
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationOperatingHours
                                                    ) &&
                                                    resourceData.locationOperatingHours !== ""
                                                ) {
                                                    var objMyResourcesOperatingHours = JSON.parse(
                                                        resourceData.locationOperatingHours
                                                    );
                                                    //var isClosed = resourceData.locationIsClosedDay.split(';');
                                                    var isClosed =
                                                        objMyResourcesOperatingHours[weekDay][2] === "true" //Lightning Valuate - Anuj
                                                            ? true
                                                            : false;
                                                    // if (isClosed.includes(weekDay)) {
                                                    if (isClosed) {
                                                        resourceData.locationIsClosedDay =
                                                            $A.get("$Label.c.referralstatusclosed") +
                                                            " " +
                                                            weekDay;
                                                        resourceData.locationOperatingHours = "";
                                                    } else if (
                                                        objMyResourcesOperatingHours[weekDay][0] !== "" || //Lightning Valuate - Anuj
                                                        objMyResourcesOperatingHours[weekDay][1] !== ""	   // Lightning Valuate - Anuj
                                                    ) {
                                                        resourceData.locationIsClosedDay = "";
                                                        resourceData.locationOperatingHours =
                                                            $A.get("$Label.c.today") +
                                                            " " +
                                                            objMyResourcesOperatingHours[weekDay][0] +
                                                            " " +
                                                            $A.get("$Label.c.to") +
                                                            " " +
                                                            objMyResourcesOperatingHours[weekDay][1];
                                                    } else {
                                                        resourceData.locationOperatingHours = "";
                                                        resourceData.locationIsClosedDay = "";
                                                    }
                                                } else {
                                                    resourceData.locationOperatingHours = "";
                                                    resourceData.locationIsClosedDay = "";
                                                }
                                                var sAddressLine = "";
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationAddress1
                                                    ) &&
                                                    resourceData.locationAddress1 !== ""
                                                ) {
                                                    sAddressLine += resourceData.locationAddress1 + ", ";
                                                }
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationAddress2
                                                    ) &&
                                                    resourceData.locationAddress2 !== ""
                                                ) {
                                                    sAddressLine += resourceData.locationAddress2 + ", ";
                                                }
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationCity
                                                    ) &&
                                                    resourceData.locationCity !== ""
                                                ) {
                                                    sAddressLine += resourceData.locationCity + ", ";
                                                }
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationState
                                                    ) &&
                                                    resourceData.locationState !== ""
                                                ) {
                                                    sAddressLine += resourceData.locationState + " ";
                                                }
                                                if (
                                                    !$A.util.isUndefinedOrNull(
                                                        resourceData.locationZipcode
                                                    ) &&
                                                    resourceData.locationZipcode !== ""
                                                ) {
                                                    sAddressLine += resourceData.locationZipcode;
                                                }
                                                if (
                                                    !$A.util.isUndefinedOrNull(sAddressLine) &&
                                                    sAddressLine !== ""
                                                ) {
                                                    sAddressLine = sAddressLine.trim();
                                                    if (sAddressLine.endsWith(",")) {
                                                        sAddressLine = sAddressLine.substring(
                                                            0,
                                                            sAddressLine.length - 1
                                                        );
                                                    }
                                                    resourceData.locationAddressFinal = sAddressLine;
                                                } else {
                                                    resourceData.locationAddressFinal = "";
                                                }
                                            }
                                        } else {
                                            assessResults.lstDomainBlock[i].lstGoalBlock.splice(j, 1);
                                            j -= 1;
                                        }
                                    }
                                } else {
                                    assessResults.lstDomainBlock.splice(i, 1);
                                }
                            }
                        }
                        component.set("v.assessmentResource", assessResults);
                        component.set("v.residentId", assessResults.sResidentId);
                        component.set("v.isGuest", assessResults.bIsGuestUser);
                        component.set("v.isResident", assessResults.bIsResidentUser);
                        if (component.get("v.isGuest")) {
                            component.set("v.showData", false);
                        } else {
                            component.set("v.showData", true);
                        }

                        component.set("v.ired", red);
                        component.set("v.iyellow", yellow);
                        component.set("v.igreen", green);
                    } else {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast("ERROR", "ERROR", errMsg);
                    }
                },
                {
                    sUserAssessmentId: component.get("v.userAssessmentId"),
                    sGuestAssessmentResponse: JSON.stringify(component.get("v.GuestUserAsessmentRespList"))
                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createReferralsHelper: function (component) {
        var checkboxesChecked = [];
        var checkboxes = [];
        if (!Array.isArray(component.find("checkBox1"))) {
            checkboxes.push(component.find("checkBox1"));
        } else {
            checkboxes = component.find("checkBox1");
        }
        for (var i = 0; i < checkboxes.length; i += 1) {
            var bCheck = checkboxes[i].get("v.value").bisCheckboxCheck;
            // And stick the checked ones onto an array...
            if (bCheck) {
                var resData = checkboxes[i].get("v.value");
                var objWrapper = {};
                objWrapper.sOrgName = resData.accountProviderName;
                objWrapper.sResourceName = resData.resourceName;
                objWrapper.sLocationName = resData.locationName;
                objWrapper.sResourceId = resData.resourceId;
                objWrapper.sLocationId = resData.locationId;
                objWrapper.bOrgIsClaimed = resData.accountIsClaimed;
                objWrapper.sOrgCheck = resData.setBulkReferalStatus;
                objWrapper.sOrgId = resData.accountId;
                checkboxesChecked.push(objWrapper);
                checkboxes[i].get("v.value").bisCheckboxCheck = false;
            }
        }
        component.set("v.bulfReferralTableData", checkboxesChecked);
        component.set("v.isResults", false);
        component.set("v.isCreateReferral", true);
        component.set("v.isViewResponses", false);
    },
    navigateToResourceDetail: function (component, event) {
        var cardKey = event.target.getAttribute("data-cardkey");
        var cardParent = event.target.getAttribute("data-cardparent");
        var cardGrandParent = event.target.getAttribute("data-cardgrandparent");
        var itemResource = component.get("v.assessmentResource.lstDomainBlock")[cardGrandParent].lstGoalBlock[cardParent].lstResourceTile[cardKey];
        var encodeZip = btoa(component.get("v.zipcode"));
        var encodeResourceId = btoa(itemResource.resourceId);
        var encodeLocationId = btoa(itemResource.locationId);
        var url =
            "resource-details?zipcode=" +
            encodeZip +
            "&resourceId=" +
            encodeResourceId +
            "&locationId=" +
            encodeLocationId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            url: url
        });
        urlEvent.fire();
    },
    disableCreateButton: function (component) {
        var buttonCheck = true;
        var checkboxes = [];
        if (!Array.isArray(component.find("checkBox1"))) {
            checkboxes.push(component.find("checkBox1"));
        } else {
            checkboxes = component.find("checkBox1");
        }
        for (var i = 0; i < checkboxes.length; i += 1) {
            var bCheck = checkboxes[i].get("v.value").bisCheckboxCheck;
            // And stick the checked ones onto an array...
            if (bCheck) {
                buttonCheck = false;
            }
        }
        if (!buttonCheck) {
            component.set("v.bCreateRefrral", false);
        } else {
            component.set("v.bCreateRefrral", true);
        }
    },
    openWebsiteHelper: function (component, event) {
        var url = event.target.title;
        if (url.indexOf("http") === -1 && url.indexOf("https") === -1) {
            url = $A.get("$Label.c.https") + "://" + event.target.title;
        }
        window.open(url, "_blank");
    },
    backToOneView: function (component) {
        var contactId = btoa(component.get("v.residentId"));
        window.open("clients?clientId=" + contactId, "_self");
    },
    backToResultsHelper: function (component) {
        component.set("v.isResults", true);
        component.set("v.isCreateReferral", false);
        component.set("v.isViewResponses", false);
        component.set("v.bCreateRefrral", true);
    },
    getOptOutInformation: function (
        component,
        event,
        helper,
        rsAchResReferralStatus
    ) {
        try {
            component.set('v.displayLoader',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(
                component,
                "c.getOptOutInfoSharingDetails",
                function (response) {
                    component.set('v.displayLoader',false);
                    //hide spinner when server response received
                    //component.set("v.isSpinnerActive", false);
                    if (response.isSuccessful) {
                        component.set("v.cartOptIn", response.objectData.OptOutInfoSharing);

                        if (!component.get("v.cartOptIn")) {
                            component.set('v.displayLoader',true);
                            component.set("v.isConsentAgreed", false);
                            if (rsAchResReferralStatus === "Draft")
                                helper.handleAchDraftConnectHelper(component, event, helper);
                            else helper.createReferralOnConnect(component, event);
                        component.set('v.displayLoader',false);
                        }
                    }
                },
                {},
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createReferralOnConnect: function (component) {
        try {
            component.set("v.isSpinnerActive", true);

            var resourceRecord = component.get("v.selectedCardValue");
            var locationID = resourceRecord.locationId;
            var bSuper = component.find("bSuper");
            bSuper.callServer(
                component,
                "c.insertReferralForResident",
                function (response) {
                    if (response.isSuccessful) {
                        var accountName;
                        var resourceName;
                        accountName = resourceRecord.accountProviderName;
                        resourceName = resourceRecord.resourceName;
                        resourceRecord.isConnectButtonDisabled = true;
                        resourceRecord.referralId = response.objectData.referals.Id;

                        //For archetype
                        //  resourceRecord.sArchetypeid = component.get("v.archetypeId");

                        component.set(
                            "v.assessmentResource",
                            component.get("v.assessmentResource")
                        );
                        // component.set("v.isSelectedResConDisabled", true);
                        bSuper.showToast(
                            $A.get("$Label.c.successstatus"),
                            "Success",
                            $A.get("$Label.c.successfully") + ' ' +
                            accountName + ' ' +
                            $A.get("$Label.c.for_resource") + ' ' +
                            resourceName
                        );
                    }
                },
                {
                    strobjResource: JSON.stringify(resourceRecord),
                    locationID: locationID,
                    bConsentAgreed: component.get("v.isConsentAgreed")
                    //   "sArchid" : component.get("v.archetypeId")
                },
                false
            );
        } catch (e) {
            component.set("v.isSpinnerActive", false);
            bSuper.consoleLog(e.stack, true);
        }
    },
    handleAchDraftConnectHelper: function (component) {
        try {
            var selResource = component.get("v.selectedCardValue");
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(
                component,
                "c.connectDraftReferralsFromArcheTypeResults",
                function (response) {
                    //hide spinner when server response received
                    component.set("v.isSpinnerActive", false);
                    //to do
                    if (response.isSuccessful) {
                        var accountName = selResource.accountProviderName;
                        var resourceName = selResource.resourceName;
                        selResource.isConnectButtonDisabled = true;
                        selResource.objReferral.Status__c =
                            response.objectData.resReferralStatus;
                        component.set(
                            "v.assessmentResource",
                            component.get("v.assessmentResource")
                        );
                        bSuper.showToast(
                            $A.get("$Label.c.successstatus"),
                            "Success",
                            $A.get("$Label.c.successfully") + ' ' +
                            accountName + ' ' +
                            $A.get("$Label.c.for_resource") + ' ' +
                            resourceName
                        );
                        var ccEvent = $A.get("e.c:RE_CountEvent");
                        ccEvent.setParams({
                            cartCount: response.objectData.draftReferralCount
                        });
                        ccEvent.fire();
                    } else {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast(
                            $A.get("$Label.c.errorstatus"),
                            $A.get("$Label.c.errorstatus"),
                            errMsg
                        );
                    }
                },
                {
                    sAchReferralId: selResource.objReferral.Id,
                    bAchConsentAgreed: component.get("v.isConsentAgreed")
                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },

    //Nandita: 04/10/2020: added parameters as a part of perf issue# 357266
    loadMoreResources: function (component, event) {
        try {
            var goalItem = event.getSource().get("v.value");
            component.set("v.isSpinnerActive", true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var data = component.get("v.assessmentResource");
            
            
           
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(
                component,
                "c.loadMoreResources",
                function (response) {
                    //hide spinner when server response received
                    component.set("v.isSpinnerActive", false);
                    //to do
                    if (response.isSuccessful) {
                        var assessResults = component.get("v.assessmentResource");//response.objectData.lstAssessmentResults;
                        var goalData = response.objectData.lstAssessmentResults;
                        if (!$A.util.isUndefinedOrNull(goalData.lstResourceTile)) {
                            for (var k = 0; k < goalData.lstResourceTile.length; k += 1) {
                                var resourceData = goalData.lstResourceTile[k];
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
                                var weekDay = weekdays[weekdayValue];
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationOperatingHours
                                    ) &&
                                    resourceData.locationOperatingHours !== ""
                                ) {
                                    var objMyResourcesOperatingHours = JSON.parse(
                                        resourceData.locationOperatingHours
                                    );
                                    var isClosed =
                                        objMyResourcesOperatingHours[weekDay][2] === "true" //Lightning Valuate - Anuj
                                            ? true
                                            : false;
                                    if (isClosed) {
                                        resourceData.locationIsClosedDay =
                                            $A.get("$Label.c.referralstatusclosed") +
                                            " " +
                                            weekDay;
                                        resourceData.locationOperatingHours = "";
                                    } else if (
                                        objMyResourcesOperatingHours[weekDay][0] !== "" || //Lightning Valuate - Anuj
                                        objMyResourcesOperatingHours[weekDay][1] !== ""	   // Lightning Valuate - Anuj
                                    ) {
                                        resourceData.locationIsClosedDay = "";
                                        resourceData.locationOperatingHours =
                                            $A.get("$Label.c.today") +
                                            " " +
                                            objMyResourcesOperatingHours[weekDay][0] +
                                            " " +
                                            $A.get("$Label.c.to") +
                                            " " +
                                            objMyResourcesOperatingHours[weekDay][1];
                                    } else {
                                        resourceData.locationOperatingHours = "";
                                        resourceData.locationIsClosedDay = "";
                                    }
                                } else {
                                    resourceData.locationOperatingHours = "";
                                    resourceData.locationIsClosedDay = "";
                                }
                                var sAddressLine = "";
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationAddress1
                                    ) &&
                                    resourceData.locationAddress1 !== ""
                                ) {
                                    sAddressLine += resourceData.locationAddress1 + ", ";
                                }
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationAddress2
                                    ) &&
                                    resourceData.locationAddress2 !== ""
                                ) {
                                    sAddressLine += resourceData.locationAddress2 + ", ";
                                }
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationCity
                                    ) &&
                                    resourceData.locationCity !== ""
                                ) {
                                    sAddressLine += resourceData.locationCity + ", ";
                                }
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationState
                                    ) &&
                                    resourceData.locationState !== ""
                                ) {
                                    sAddressLine += resourceData.locationState + " ";
                                }
                                if (
                                    !$A.util.isUndefinedOrNull(
                                        resourceData.locationZipcode
                                    ) &&
                                    resourceData.locationZipcode !== ""
                                ) {
                                    sAddressLine += resourceData.locationZipcode;
                                }
                                if (
                                    !$A.util.isUndefinedOrNull(sAddressLine) &&
                                    sAddressLine !== ""
                                ) {
                                    sAddressLine = sAddressLine.trim();
                                    if (sAddressLine.endsWith(",")) {
                                        sAddressLine = sAddressLine.substring(
                                            0,
                                            sAddressLine.length - 1
                                        );
                                    }
                                    resourceData.locationAddressFinal = sAddressLine;
                                } else {
                                    resourceData.locationAddressFinal = "";
                                }
                            }
                            var Data = assessResults.lstDomainBlock;
                            if (Data !== undefined) {
                               
                                for (var i = 0; i < assessResults.lstDomainBlock.length; i += 1) {
                                    var catData = assessResults.lstDomainBlock[i];
                                  
                                    if (!$A.util.isUndefinedOrNull(catData.lstGoalBlock)) {

                                        for (var j = 0; j < catData.lstGoalBlock.length; j += 1) {
                                           
                                            if (catData.lstGoalBlock[j].goalId === goalItem.goalId) {
                                                catData.lstGoalBlock[j].lstResourceTile = goalData.lstResourceTile;
                                            }
                                        }
                                    }
                                }
                                assessResults.lstDomainBlock = Data;
                                component.set("v.assessmentResource", assessResults);
                            }

                        }

                    }

                },
                {
                    sUserAssessId: component.get("v.userAssessmentId"),
                    sGoalId: goalItem.goalId,
                    dblLat: data.dblat,
                    dblLon: data.dblong

                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

    },
    //Nandita: 04/10/2020: added parameters as a part of perf issue# 357266 
    loadLessResources: function (component, event) {
        try {
            var goalItem = event.getSource().get("v.value");
            component.set("v.isSpinnerActive", true);
            ////reference to inherited super component
           
            var bSuper = component.find("bSuper");
            var assessResults = component.get("v.assessmentResource");
            
            bSuper.callServer(
                component,
                "c.loadLessResources",
                function (response) {
                    //hide spinner when server response received
                    component.set("v.isSpinnerActive", false);
                    //to do
                    if (response.isSuccessful) {
                        var goalData = response.objectData.lstAssessmentResults;
                        var Data = assessResults.lstDomainBlock;
                        if (Data !== undefined) {
                           
                            for (var i = 0; i < assessResults.lstDomainBlock.length; i += 1) {
                                var catData = assessResults.lstDomainBlock[i];
                               
                                if (!$A.util.isUndefinedOrNull(catData.lstGoalBlock)) {

                                    for (var j = 0; j < catData.lstGoalBlock.length; j += 1) {
                                     
                                        if (catData.lstGoalBlock[j].goalId === goalItem.goalId) {
                                            catData.lstGoalBlock[j].lstResourceTile = goalData.lstResourceTile;
                                        }
                                    }
                                }
                            }
                            assessResults.lstDomainBlock = Data;
                            component.set("v.assessmentResource", assessResults);
                        }

                    }

                },
                {

                    sGoalId: goalItem.goalId,
                    objGoalBlock: goalItem.lstResourceTile
                },
                false
            );
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
});