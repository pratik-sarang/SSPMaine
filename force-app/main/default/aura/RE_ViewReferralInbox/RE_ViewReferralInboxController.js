({
	doInit : function(component, event, helper) {
        var retUrl = sessionStorage.getItem("retUrl");
        if(retUrl){
            window.location = retUrl;
            sessionStorage.removeItem("retUrl");
            return false;
        }
        helper.doInitHandler(component, event, helper);
		return true;
    }
})