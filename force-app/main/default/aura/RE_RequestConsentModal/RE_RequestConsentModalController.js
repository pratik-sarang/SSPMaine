({
    doInit: function(component, event, helper) {
        //Added else if condition to solve SIT Error logs --Payal Dubela(25/03/2020)
        if($A.util.isUndefinedOrNull(component.get("v.clientId")) 
           && !$A.util.isUndefinedOrNull(component.get("v.clientWrapper.IEESId"))){
            component.set("v.isIEESData",true);
            component.set("v.isModalOpen", true);
            component.set("v.hasNoActiveConsent",true);
            component.set("v.clientDetails.Name",component.get("v.clientWrapper.FirstName")+" "+component.get("v.clientWrapper.LastName"));
        }else if(!$A.util.isUndefinedOrNull(component.get("v.clientId")) && !$A.util.isEmpty(component.get("v.clientId"))){
            component.set("v.isIEESData",false);
        helper.doInit(component, event, helper);
        }
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },2000);
        
    },
    openModel: function(component) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        var cmpTarget = component.find('ReqConsentModal');        
        var cmpBack = component.find('ModalReqConsent');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
		var cmpEvent = component.getEvent("CloseModalevent");
        cmpEvent.setParams({
            "closed":true,
            "ClientId":component.get('v.clientId'),
            "callDoInit":false }); 
        cmpEvent.fire();
        
    },
    
    sendText: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        helper.sendConsentText(component, event, helper);
        component.set("v.isModalOpen", false);
    },
    sendEmail: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        helper.checkDataForConsent(component,event,helper);
    },
/*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   handleVerbalConsent()
* @description  This methods is to open Verbal consent page with contactId and 
				consentId appended to the URL				
********************************************************************/
    handleVerbalConsent: function(component,event,helper){
        helper.handleVerbalConsentHelper(component,event,helper);
    },
        closeEmailModal:function(component){  
        component.set("v.bHasNoEmail", false);
        var cmpTarget = component.find('NoEmailModal');
        var cmpBack = component.find('ModalbackdropEmail');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
        /*var sPageURL = decodeURIComponent(document.URL);
        if(component.get("v.isClientDetail")){
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": sPageURL+  "?clientId="+window.btoa(component.get("v.clientId"))
            });
            urlEvent.fire();
        } */
        var cmpEvent = component.getEvent("CloseModalevent");
        if(component.get("v.isClientDetail")){
            cmpEvent.setParams({
            "closed":true,
            "ClientId":component.get('v.clientId'),
            "callDoInit":component.get("v.isIEESData")});
        }                
        cmpEvent.fire();
    },
    moveFocusToTop: function(){
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },100);
    },
    navigateToRegistration : function(component, event, helper) {
        helper.getKogURL(component);
    }
})