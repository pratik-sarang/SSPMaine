({
	showToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
             type : $A.get("$Label.c.errorstatus"),
            duration : '5000'
        });
        toastEvent.fire();
    }
})