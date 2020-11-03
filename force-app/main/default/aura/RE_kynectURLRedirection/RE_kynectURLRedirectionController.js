({
	doInit : function(component, event, helper) {
       /* var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            'url': 'https://sspdev-benefind-reci.cs32.force.com/resources'
        });
        urlEvent.fire();*/
        var url = ($A.get("$Label.c.RE_CommunityBaseUrl")) +'resources';
        window.open(url, '_self');
	}
})