({
    createFavoritesHelper : function(component) {
		
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var successfullyadded = $A.get('$Label.c.succesfully_added');
            var at = $A.get('$Label.c.at');
            var to_your_favorite_list = $A.get('$Label.c.to_your_favorite_list');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.createFavorite', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);

                //to do 
               
                if(response.isSuccessful){
                  
                    var sSuccessmsg = '';
                    sSuccessmsg = successfullyadded + ' ' + component.get("v.sResourceName") + ' ' + at + ' ' + component.get("v.sOrganisationName") + ' ' + to_your_favorite_list;
                    bSuper.showToast($A.get("$Label.c.successstatus"), 'success', sSuccessmsg);
                }

            	},{
					strLocationResId : component.get("v.LocResourceId")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    deleteFavoritesHelper : function(component) {
	
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var successfullyremoved = $A.get('$Label.c.successfully_removed');
            var at = $A.get('$Label.c.at');
            var from_fav_list = $A.get('$Label.c.from_fav_list');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.deleteFavorite', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);

                //to do 
                
                if(response.isSuccessful){
                    
                 	var sSuccessmsg = '';
                    sSuccessmsg = successfullyremoved + ' ' + component.get("v.sResourceName") + ' ' + at + ' ' + component.get("v.sOrganisationName") + ' ' + from_fav_list;
                    bSuper.showToast($A.get("$Label.c.successstatus"),'success', sSuccessmsg);

				}

            	},{
					strLocationResId : component.get("v.LocResourceId")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    }
})