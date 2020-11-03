({
	 backtoclientpage : function() {
        
        var sPageURL = decodeURIComponent(document.URL);
                    var baseURL = sPageURL.split("consentupdate")[0]; //Split by ? so that you get the key value pairs separately in a list
                    var urlEvent = $A.get("e.force:navigateToURL");
                    
                    urlEvent.setParams({
                        "url": baseURL +"clients"
                    });
                    urlEvent.fire();
        
        
    }
})