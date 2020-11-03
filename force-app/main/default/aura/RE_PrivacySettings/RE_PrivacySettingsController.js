({
    doInit: function (component, event, helper) {
        helper.getConsentDetails(component, event, helper);
    },
    handleOptOut: function (component, event, helper) {
        component.set("v.bIsOptOut", true);
        helper.focusModalHeading(component, event);//JAWS Fixes
    },
    handleOptOutPopup: function (component, event, helper) {
        component.set("v.bIsOptOut", false);
        component.set("v.withDatatable", false);
        helper.handleOptOut(component, event, helper);
    },
    handleOptIn: function (component, event, helper) {
        component.set("v.bIsSharingInfo", true);
        //helper.handleOptIn(component,event, helper);
        helper.focusModalHeading(component, event);//JAWS Fixes

    },
    handleDeny: function (component, event, helper) {
        helper.handleDeny(component, event, helper);
    },
    handleApprove: function (component, event, helper) {
        helper.handleApprove(component, event, helper);
    },
    handleConsentToText: function (component, event, helper) {
        helper.handleConsentToText(component, event, helper);
    },
    handleRemoveForCP: function (component, event, helper) {
        var removeBtnValue = event.getSource().get("v.name");
        var partnerName;
        if (removeBtnValue.ConsentLevel__c === 'Organization') {
            partnerName = removeBtnValue.Organization__r.Name;
        }
        if (removeBtnValue.ConsentLevel__c === 'Assister') {
            partnerName = removeBtnValue.Assister__r.Name;
        }
        component.set("v.removeAccessOrgName", partnerName);
        component.set("v.objConsent", removeBtnValue);
        component.set("v.bIsRemoveAccess", true);
        helper.focusModalHeading(component, event);//JAWS Fixes
    },
    handleRemoveForAssisters: function (component, event, helper) {
        var removeBtnValue = event.getSource().get("v.name");
        component.set("v.removeAccessOrgName", removeBtnValue.Assister__r.Name);
        component.set("v.objConsent", removeBtnValue);
        component.set("v.bIsRemoveAccess", true);
        helper.focusModalHeading(component, event);//JAWS Fixes
    },
    handleRemoveAccessSubmit: function (component, event, helper) {
        component.set("v.bIsRemoveAccess", false);
        var objvalue = component.get("v.objConsent");
        helper.handleRemove(component, event, helper, objvalue);
    },
    closeRemoveAccessModal: function (component) {
        component.set("v.bIsRemoveAccess", false);
    },
    closeSharingInfoModal: function (component) {
        component.set("v.bIsSharingInfo", false);
    },
    closeOptOutModal: function (component) {
        component.set("v.bIsOptOut", false);
    },
    handleSharingInfo: function (component, event, helper) {
        component.set("v.bIsSharingInfo", false);
        component.set("v.withDatatable", true);
        helper.handleOptIn(component, event, helper);
    },
    focusHeading: function(){//JAWS Fixes
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },10);
    }
})