({
    doinIt : function(component, event, helper) {
        helper.getParam(component);
        helper.fetchPicklistValues(component,event,helper);
        helper.fetchconsent(component, event,helper);
        helper.getContact(component, event, helper);
        var baseURL= decodeURIComponent(document.URL);
        var url = new URL(baseURL);
        var baseOrigin = url.searchParams.get("origin");
        component.set("v.origin", baseOrigin);
        var conId = url.searchParams.get("clientid");
        component.set("v.conId",conId);
    },
    
    closeModal : function(component) {
        component.set("v.bisRequestModal",false);
    },
    handleChange: function(component,event,helper) {
        helper.handleChange(component,event,helper);
    },
    checkValidForm: function(component,event,helper) {
        helper.checkValidForm(component,event,helper);
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   handleSubmit()
* @description  This methods is used to check screen validations, and
				then insert the consent record, or update an already existing pending consent.
********************************************************************/
    handleSubmit: function(component,event,helper) {
        if(helper.checkValidForm(component,event,helper)){
            //do whatever is to be written on submit
            var bSuper = component.find("bSuper");
            var objWrap = component.get("v.objwrapper");  
            var commPref = objWrap.CommunicationPref;
            var bConsentToText = objWrap.bConsentToText;
            var consentToTextValue = component.get("v.consentToText");

            var mobLabel = $A.get("$Label.c.MobilePhone");
            if(commPref === mobLabel && consentToTextValue === false){
                var errMsg = $A.get("$Label.c.ConsentToTextErrorMsg");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                
            }else{
                helper.handleSubmit(component,event,helper);
                component.set('v.bDisableSubmitButton',false); 
            }
         
        }
        else{
            var toastEmailEvent = $A.get("e.force:showToast");  
            toastEmailEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": $A.get("$Label.c.fill_required_fields"),
                "type"   : "error"
            });
            toastEmailEvent.fire();   
            
        }
        
    },
    
    // Release 1.1 
    handleConsentToText : function(component,event,helper){
		var objWrap = component.get("v.objwrapper");  
        var commPref = objWrap.CommunicationPref;
        var bConsentToText = objWrap.bConsentToText;
        var mobLabel = $A.get("$Label.c.MobilePhone");
        if(commPref === mobLabel && bConsentToText === false){
            var errMsg = $A.get("$Label.c.ConsentToTextErrorMsg");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            component.set('v.bDisableSubmitButton',true);
        }else{
            component.set('v.bDisableSubmitButton',false);
        }
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   formatPhoneNumber()
* @description  This methods is used format phone number to US phone format (xxx) xxx-xxxx
********************************************************************/
    
    formatPhoneNumber: function(component, event, helper) {
        var objWrap = component.get("v.objwrapper");
        if (objWrap) {
            var phone = objWrap.Phone;
            var formatedPhone = helper.formatPhoneNumber(component, phone);
            formatedPhone = formatedPhone.replace(/^0+/, '');
            objWrap.Phone = formatedPhone;
            component.set("v.objwrapper", objWrap);
        }
        helper.checkValidForm(component,event,helper);
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   backToClients()
* @description  This methods is used to navigate back to clients page
********************************************************************/
    backToClients : function(component) {
        var sPageURL = decodeURIComponent(document.URL);
        var baseURL = sPageURL.split("verbal")[0]; //Split by ? so that you get the key value pairs separately in a list
        var urlEvent = $A.get("e.force:navigateToURL");
        var origin = component.get("v.origin");
        if(origin === "clientoneview"){
            var contactId=btoa(component.get("v.conId"));
        	window.open('clients?clientId='+contactId,'_self');
        }else{
            urlEvent.setParams({
                "url": baseURL +"clients"
            });
            urlEvent.fire();
        }
        
    }
})