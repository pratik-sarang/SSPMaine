({
    doInit : function(component) {
        component.set("v.isRegistered", true);
		var orgIsListed=$A.get("$Label.c.RE_OrgIsListed");
        var orgNotListed=$A.get("$Label.c.RE_OrgIsNotListed");
        var optionsList = component.get("v.options");
        optionsList.push({'label': orgIsListed, 'value': 'Yes'},
                         {'label': orgNotListed, 'value': 'No'}
                        );
    },
    
    handlePrevious : function() {
        window.history.back();
    },
    
    handleContinue : function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/searchorganization"
        });
        urlEvent.fire();
    },
    
    handleChange : function(component) {
        var isListed = component.get("v.value");
        if(isListed === "No"){
            component.set("v.isRegistered", false);
        }else{
           component.set("v.isRegistered", true);
        }
    }
    
})