({
    doInit : function(){
        setTimeout(function(){//JAWS Fix
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },1000);
    },
    closeCartOptIn : function(component){
        component.set("v.showModal",false);
        var parametersEvent = component.getEvent("Modal_ParametersEvent");
    	parametersEvent.setParams({
            isConsentAgreed : false,
            isModalClosed : true 
        });
        parametersEvent.fire(); 
    },
    moveFocusToTop: function(component, event) {//JAWS Fix
        if(event.keyCode === 9) {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10);
        }else if(event.keyCode === 32 || event.keyCode === 13){
            document.getElementsByClassName("btn-yes")[0].click();
        }
    },
    cartOptIn : function(component){
        component.set("v.showModal",false);
    	var parametersEvent = component.getEvent("Modal_ParametersEvent");
    	parametersEvent.setParams({
            isConsentAgreed : true
        });
        parametersEvent.fire();   
    }
})