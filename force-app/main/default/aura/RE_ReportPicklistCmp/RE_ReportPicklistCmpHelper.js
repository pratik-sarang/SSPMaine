({
	getReportsHelper : function(component) {
        try{
        	var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.getReports', function(response) {
                if(response.isSuccessful){
                    var objectData = response.objectData.reportsName;
                    component.set("v.listReport",objectData);
                }
                else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            });
        }
        catch (e) { 
            bSuper.consoleLog(e.stack, true);
        }
    },
    gotoURL : function (component,event, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/'+url
        });
        urlEvent.fire();
        
    }
})