({
    getArchetypeDetails : function(component){
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getCarouselPackages', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){                    
                    component.set("v.lstImageDetails", response.objectData.lstArchetypes);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
            },null,false);
            this.transformSlide(component);  
        }
        catch(e){
            
        }
    },
    
    transformSlide : function(component) {
        setTimeout(function slide(){
            var translateValue = component.get("v.translateValue");
            var lstArchetypeDetails = component.get("v.lstImageDetails");
            var val=-100;
            var transValue = translateValue+val;
            component.set("v.translateValue", translateValue+val);
            component.set("v.transValue", "translateX("+transValue+"%)");
            if(translateValue === (-100*(lstArchetypeDetails.length-1))){
                component.set("v.translateValue", 0);
                component.set("v.transValue", "translateX(0%)");
            }
            setTimeout(slide,8000);
        },8000);
    },
    
    changeLinkAndText : function(component){
        var translateValue = component.get("v.translateValue");
        var comp = component.find("learnMore");
        
        if( translateValue === 0 ){
            comp.set("v.name", component.get("v.buttonLink1"));
        }
        else if( translateValue === -100 ){
            comp.set("v.name", component.get("v.buttonLink2"));
        }
            else if( translateValue === -200 ){
                comp.set("v.name", component.get("v.buttonLink3"));
            }
    },
    
    navigateToUrl : function(component, event, link){        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            //"url": "/archetype?id="+sEncryptId
            "url": link
        });
        urlEvent.fire();
    },
    
    changeImageOnClick : function(component, event){
        var sourceClick = event.currentTarget.id;
        var val=-100;
        var transValue = sourceClick*val;
        component.set("v.translateValue", transValue);
        component.set("v.transValue", "translateX("+transValue+"%)");
    },
    
    showCarouselOnView: function(component, event){
        var showCarousel = event.getParam("showCarousel");
        // set the handler attributes based on event data
        component.set("v.showCarousel", showCarousel);
    }
})