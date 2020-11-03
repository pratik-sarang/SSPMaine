({
	showToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type : 'error',
            duration : '5000'
        });
        toastEvent.fire();
    }
})