({
    getKogURL : function(component, event, helper,navigate) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchKogURL', function(response) {
                
                if(navigate === 'Registration'){
                    window.open(response.objectData.KogRegistrationURL,'_parent');
                }
                if(navigate === 'Login'){
                    //window.open(response.objectData.KogLoginURL,'_parent');
                    window.open('my-account','_parent');
                }
                
                /*if(response.isSuccessful){
                    window.open(response.objectData.KogRegistrationURL,'_parent');
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "type" : "ERROR",
                        "message": $A.get("$Label.c.component_failure")
                    });
                    toastEvent.fire(); 
                }*/
            },{},false);
        }catch (e) {
        }
    }
})