({
	doInit : function(component, event, helper) {
	    //Send LC Host as parameter to VF page so VF page can send message to LC; make it all dynamic
        component.set('v.lcHost', document.location.hostname);
        //Add message listener
        window.addEventListener("message", function(evt) {
            if(evt.data.state === 'LOADED'){
                //Set vfHost which will be used later to send message
                component.set('v.vfHost', evt.data.vfHost);
                //Send data to VF page to draw map
                helper.sendToVF(component, helper);
            }
        }, false);
	},
    handleBackList:function(){
        if(document.getElementsByClassName('archetype-cards')[0]){
           document.getElementsByClassName('archetype-cards')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
           document.getElementsByClassName('archtype-map-section')[0].classList.add('slds-hide');
        }
        if(document.getElementsByClassName('archetypeBanner')[0]){
            document.getElementsByClassName('archetypeBanner')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-content')[0]){
            document.getElementsByClassName('archtype-content')[0].classList.remove('slds-p-around_none'); 
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
            document.getElementsByClassName('archtype-map-section')[0].classList.remove('slds-p-vertical_none'); 
        }
    }
})