({
	doInit : function(component) {        		
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getResourcePackages', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do                               
                if(response.isSuccessful){
                    component.set("v.showExtraPackages", false);
                    //component.set("v.lstArchetypes", response.objectData.lstArchetypesWrapper);
                    var archetypeArray=response.objectData.lstArchetypesWrapper;
                    archetypeArray.splice(4, 0, {});
                    component.set("v.lstArchetypes", archetypeArray);
                if ( $A.get("$Label.c.LandingPageVideo") == 'VideoNotRequired' ){
                        component.set("v.bShowMeVideo", false);
                    }   
                    
                }else{                    
                    bSuper.showToast('Error', 'Error', component_failure);
                }
                                
            },null,false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }         
	},
    viewAll : function(component, event, helper) {
        component.set("v.showExtraPackages", true);
        var methodRef = component.get("v.method");
        helper.fireCarouselEvent(component, event, false);
        //fire event from child and capture in parent
        $A.enqueueAction(methodRef);
        component.set("v.isLessResourceLink", true);
    },
    viewLess: function(component, event, helper) {
        component.set("v.showExtraPackages", false);
        var methodRef = component.get("v.method");
        helper.fireCarouselEvent(component, event, true);
        $A.enqueueAction(methodRef);
        component.set("v.isLessResourceLink", false);
    },
    navigateToArchetype : function(component, event) {

        var archetypeId = event.currentTarget.id; 
        var encryptArchetypeId = btoa(archetypeId);
        var urlEvent = $A.get("e.force:navigateToURL");
        window.localStorage.removeItem('roleArchCombination');
        urlEvent.setParams({
            "url": "/archetype?id="+encryptArchetypeId
        });
        urlEvent.fire();
    },
     openSelectAssesment: function(component,event,helper){
        helper.getGuestAssessment(component,event);
     	
        
    },
    openPopup:function(component){
        document.getElementById("iframe-container").classList.add("video-expanded");
        document.getElementById("iframe-container").classList.add("slds-backdrop");
        document.getElementById("iframe-container").classList.add("slds-backdrop_open");
        $A.util.removeClass(component.find("modal-close"),"slds-hide");
    },
    hidePopup:function(component){
        document.getElementById("iframe-container").classList.remove("video-expanded");
        document.getElementById("iframe-container").classList.remove("slds-backdrop");
        document.getElementById("iframe-container").classList.remove("slds-backdrop_open"); 
        $A.util.addClass(component.find("modal-close"),"slds-hide");
    },
})