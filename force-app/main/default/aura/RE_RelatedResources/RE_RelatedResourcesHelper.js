({
	getRelatedResources : function(component) {
		try{ 
            var geolocation=component.get("v.Geolocation");
            if(!$A.util.isUndefinedOrNull(geolocation) && geolocation.length===2 && 
                geolocation[0]!=='null'
                && geolocation[1]!=='null'){ 
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchRelatedResources', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do 
               if(true){
                    //Populate Frequently paired resources list
                    if(!$A.util.isUndefinedOrNull(response.objectData.relatedresources)){
                        var result =  JSON.parse(response.objectData.relatedresources);
                        component.set("v.carouselItem",result);
                          
                    }else{
                        component.set("v.carouselItem",[]);
                        component.set("v.noSuggestedResourceFrequently",true);
                    }
                     
                    //Populate Similar Resources List
                    if(!$A.util.isUndefinedOrNull(response.objectData.similarresources)){
                        var similarResources =  JSON.parse(response.objectData.similarresources);
                        component.set("v.carouselItemSimilarRes",similarResources);
                        
                    }else{
                        component.set("v.carouselItemSimilarRes",[]);
                        component.set("v.noSuggestedResourceRelated",true);
                    }
                    component.set("v.isLoading",false);
                    component.set("v.bisCheck",true);
				}

            	},{
					strResourceId : component.get("v.sResourceId"),
					geoLocation : component.get("v.Geolocation")
            },false);
         }else{
            component.set("v.carouselItem",[]);
            component.set("v.noSuggestedResourceFrequently",true);
            component.set("v.carouselItemSimilarRes",[]);
            component.set("v.noSuggestedResourceRelated",true);
            component.set("v.isLoading",false);
            component.set("v.bisCheck",true);
         }
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
     //}, 2000);

	},
    getOptOutInformation: function(component, event, helper){
        try{
            component.set('v.displayLoader',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getOptOutInfoSharingDetails', function(response) {
                //hide spinner when server response received
                component.set('v.displayLoader',false); 
                if(response.isSuccessful){ 
                  
                    component.set("v.cartOptIn", response.objectData.OptOutInfoSharing); 
                    
                    if(!component.get("v.cartOptIn")){
                        component.set('v.displayLoader',true);
                        component.set("v.isConsentAgreed", false);
                        helper.createReferralOnConnect(component,event);
                        component.set('v.displayLoader',false);
                    }
                }
            }, null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
	createReferralOnConnect: function(component){
      
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
          

            var evtValue = component.get("v.selectedCardValue");
           // var eventName = component.get("v.selectedCardName");
           
            var sJsonWrap = JSON.stringify(evtValue);
        
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.insertReferralForResident', function(response) {
                if(response.isSuccessful){
                    var accountName;
                    var resourceName;
                   
					accountName = evtValue.sResourceAccountName;
					resourceName = evtValue.sResourceName;
					evtValue.bdisableConnect = true;
					bSuper.showToast($A.get("$Label.c.successstatus"),"SUCCESS", $A.get("$Label.c.successfully") +' '+ accountName+ $A.get("$Label.c.for_resource") +' '+ resourceName);
                    component.set("v.carouselItem",component.get("v.carouselItem"));
                    component.set("v.carouselItemSimilarRes",component.get("v.carouselItemSimilarRes"));
                    
                }
                else{
                    bSuper.showToast('Error', 'Error', $A.get("$Label.c.RE_Cannotconnect"));  
                }
                
            },{
                "strwrapperObj" : sJsonWrap,
                "bConsentAgreed" : component.get("v.isConsentAgreed"),
                "referralSource": component.get("v.selectedCardName")
                
            },false); 
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }    
        
    }
})