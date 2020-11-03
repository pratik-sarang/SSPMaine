({
    loginToPortal : function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "login"
        });
        urlEvent.fire();
    }
})