({
    getConsentDetails: function (component) {
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            var toastEvent;
            bSuper.callServer(component, 'c.fetchConsentDetails', function (response) {
                if (response.isSuccessful) {
                    component.set("v.displayLoader", false);
                    component.set("v.lstConsent", response.objectData.consentDetails);
                    component.set("v.lstConsentCpDetails", response.objectData.consentOptCp);
                    component.set("v.lstConsentAssisters", response.objectData.consentOptAssisters);
                    component.set("v.lstConsentActive", response.objectData.consentOptActive);
                    component.set("v.consentToText", response.objectData.consentToText);
                    component.set("v.prefCommunicationMethod", response.objectData.prefCommMethod);

                    var boolValue;
                    if (response && response.objectData && response.objectData.consentDetails && response.objectData.consentDetails.length > 0) {
                        toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": $A.get("$Label.c.RE_Info"),
                            "type": "INFO",
                            "message": $A.get('$Label.c.Action_Needed_Desc')
                        });
                        toastEvent.fire();
                    }
                    if (response.objectData.optInvalue === true) {
                        boolValue = false;
                    }
                    if (response.objectData.optInvalue === false) {
                        boolValue = true;
                    }
                    component.set("v.withDatatable", boolValue);
                    component.set("v.userAccountId", response.objectData.userAccountId);
                }
                else {
                    toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEvent.fire();
                }
            }, {}, false);
        } catch (e) {
        }
    },
    handleDeny: function (component, event, helper) {
        try {
            var denyBtnValue = event.getSource().get("v.name");
            var displayToastMessage;
            if (denyBtnValue.ConsentLevel__c === 'Organization') {
                displayToastMessage = denyBtnValue.Organization__r.Name;
            }
            if (denyBtnValue.ConsentLevel__c === 'Assister') {
                displayToastMessage = denyBtnValue.Assister__r.Name;
            }
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.updateConsentStatus', function (response) {
                if (response.isSuccessful) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.successstatus"),
                        "type": "SUCCESS",
                        "message": $A.get("$Label.c.RE_Access") + " " + displayToastMessage
                    })
                    toastEvent.fire();
                    helper.getConsentDetails(component, event, helper);
                }
                else {
                    var toastEventFailure = $A.get("e.force:showToast");
                    toastEventFailure.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventFailure.fire();
                }

            }, {
                "objConsent": denyBtnValue,
                "strStatusValue": "Deny"
            }, false);
        } catch (e) {
        }
    },
    handleApprove: function (component, event, helper) {
        try {
            var approveBtnValue = event.getSource().get("v.name");
            var displayToastMessage;
            if (approveBtnValue.ConsentLevel__c === 'Organization') {
                displayToastMessage = approveBtnValue.Organization__r.Name;
            }
            if (approveBtnValue.ConsentLevel__c === 'Assister') {
                displayToastMessage = approveBtnValue.Assister__r.Name;
            }
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.updateConsentStatus', function (response) {
                if (response.isSuccessful) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.successstatus"),
                        "type": "SUCCESS",
                        "message": $A.get("$Label.c.RE_Access_Granted") + " " + displayToastMessage
                    })
                    toastEvent.fire();
                    helper.getConsentDetails(component, event, helper);
                }
                else {
                    var toastEventFailure = $A.get("e.force:showToast");
                    toastEventFailure.setParams({
                        "title": "ERROR",
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventFailure.fire();
                }
            }, {
                "objConsent": approveBtnValue,
                "strStatusValue": "Active"
            }, false);
        } catch (e) {
        }
    },
    handleOptIn: function (component, event, helper) {
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.updateAccountOpt', function (response) {
                if (response.isSuccessful) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.successstatus"),
                        "type": "SUCCESS",
                        "message": $A.get("$Label.c.RE_Connect_CP_ASST")
                    })
                    toastEvent.fire();
                    helper.getConsentDetails(component, event, helper);
                }
                else {
                    var toastEventFailure = $A.get("e.force:showToast");
                    toastEventFailure.setParams({
                        "title": "ERROR",
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventFailure.fire();
                }
            }, {
                "hasAccountOpt": false,
                "strUserAccountId": component.get("v.userAccountId")
            }, false);
        } catch (e) {
        }
    },
   
    handleOptOut: function (component, event, helper) {
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.updateAccountOpt', function (response) {
                if (response.isSuccessful) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.successstatus"),
                        "type": "SUCCESS",
                        "message": $A.get("$Label.c.RE_optedout")
                    })
                    toastEvent.fire();
                    helper.getConsentDetails(component, event, helper);
                }
                else {
                    var toastEventFailure = $A.get("e.force:showToast");
                    toastEventFailure.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventFailure.fire();
                }
            }, {
                "hasAccountOpt": true,
                "strUserAccountId": component.get("v.userAccountId")
            }, false);
        } catch (e) {
        }
    },
    handleRemove: function (component, event, helper, objectvalue) {
        var displayToastMessage;
        if (objectvalue.ConsentLevel__c === 'Organization') {
            displayToastMessage = objectvalue.Organization__r.Name;
        }
        if (objectvalue.ConsentLevel__c === 'Assister') {
            displayToastMessage = objectvalue.Assister__r.Name;
        }
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.updateConsentStatus', function (response) {
                if (response.isSuccessful) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": $A.get("$Label.c.successstatus"),
                        "type": "SUCCESS",
                        "message": $A.get("$Label.c.RE_Access_Remove") + " " + displayToastMessage
                    })
                    toastEvent.fire();
                    helper.getConsentDetails(component, event, helper);
                } else {
                    var toastEventFailure = $A.get("e.force:showToast");
                    toastEventFailure.setParams({
                        "title": $A.get("$Label.c.errorstatus"),
                        "type": "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEventFailure.fire();
                }
            }, {
                "objConsent": objectvalue,
                "strStatusValue": "Inactive"
            }, false);
        } catch (e) {
        }
    },
    focusModalHeading: function(){
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },1000);
    }
})