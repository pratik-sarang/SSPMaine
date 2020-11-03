({
	getLoggedInUser : function(component) {
		try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchUserType', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do                               
                if(response.isSuccessful){
                    component.set("v.isLoggedInUser", response.objectData.isLoggedIn);
                }else{                    
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), component_failure);
                }
                                
            },null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }        
	}
})