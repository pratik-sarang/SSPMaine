({
	doInit : function(component, event, helper) {
        helper.getParam(component, event, helper);
         helper.doInitHandler(component, event, helper);
        helper.decryptionMethod(component, event, helper);
        if(sessionStorage.getItem('isFromOneView') === "true")
        {
            component.set("v.isFromOneView", true);
        }
	},
    callDataTableMethod: function(component, event, helper)
    {
        var decryptedCaseNumber = component.get("v.caseNumber");
        var decryptedIndividualId = component.get("v.individualID");
        
        if((!$A.util.isUndefinedOrNull(decryptedCaseNumber) && !$A.util.isEmpty(decryptedCaseNumber)) 
            || (!$A.util.isUndefinedOrNull(decryptedIndividualId) && !$A.util.isEmpty(decryptedIndividualId)))
        {
            var dataTableMethod = component.find("searchFromIEES");
            dataTableMethod.getURLParams(decryptedCaseNumber, decryptedIndividualId);
        }
    },
    allClientDetailsEvent : function(component, event, helper) {
		 helper.allClientDetailsEventHelper(component, event);
	},
    showDataClients: function(component, event) {
        if(event.type === "click" || (event.type === "keydown" && (event.code === "Enter" || event.code === "Space"))){//JAWS Fixes
        document.getElementsByClassName("all-clients")[0].classList.add("slds-hide");
        document.getElementsByClassName("favorite-clients")[0].classList.add("slds-hide");
        document.getElementsByClassName("my-clients")[0].classList.remove("slds-hide");
        document.getElementById("myClients").classList.add("active-tab");
        document.getElementById("allClients").classList.remove("active-tab");
        document.getElementById("favoriteClients").classList.remove("active-tab");
        }
    },
    showDataAll: function(component, event) {
        if(event.type === "click" || (event.type === "keydown" && (event.code === "Enter" || event.code === "Space"))){//JAWS Fixes
        if(component.get("v.bIsAgencyUser"))
        {
            document.getElementsByClassName("all-clients")[0].classList.remove("slds-hide");
            document.getElementsByClassName("favorite-clients")[0].classList.add("slds-hide");
            document.getElementById("favoriteClients").classList.remove("active-tab");
            document.getElementById("allClients").classList.add("active-tab");
        }
        else{
            document.getElementsByClassName("all-clients")[0].classList.remove("slds-hide");
            document.getElementsByClassName("my-clients")[0].classList.add("slds-hide");
            document.getElementsByClassName("favorite-clients")[0].classList.add("slds-hide");
            document.getElementById("myClients").classList.remove("active-tab");
            document.getElementById("favoriteClients").classList.remove("active-tab");
            document.getElementById("allClients").classList.add("active-tab");
        }
    }
    },
    showDataFavClients: function(component, event) {
        if(event.type === "click" || (event.type === "keydown" && (event.code === "Enter" || event.code === "Space"))){//JAWS Fixes
        if(component.get("v.bIsAgencyUser"))
        {
            document.getElementsByClassName("all-clients")[0].classList.add("slds-hide");
            document.getElementsByClassName("favorite-clients")[0].classList.remove("slds-hide");
            document.getElementById("allClients").classList.remove("active-tab");
            document.getElementById("favoriteClients").classList.add("active-tab");
        }
        else{
            document.getElementsByClassName("my-clients")[0].classList.add("slds-hide");
            document.getElementsByClassName("all-clients")[0].classList.add("slds-hide");
            document.getElementsByClassName("favorite-clients")[0].classList.remove("slds-hide");
            document.getElementById("myClients").classList.remove("active-tab");
            document.getElementById("allClients").classList.remove("active-tab");
            document.getElementById("favoriteClients").classList.add("active-tab");
        }
    }
    },
    
    hideNote: function(component) {
        component.set("v.onLoadCheck",true);
    },
    // 20Dec LV issue
    closeReferralBarredModal:function(component){  
        component.set("v.showReferralBarredModal", false); 
    },
    moveFocusToTop: function(){
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },100);
    }
})