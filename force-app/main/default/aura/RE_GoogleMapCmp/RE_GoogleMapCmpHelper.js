({
    sendToVF : function(component, helper) {
        //console.log('be:='+JSON.stringify(component.get('v.mapData')));
        //Prepare message in the format required in VF page
        var message = {
			            "loadGoogleMap" : true,
            			"mapData": component.get('v.mapData'), 
            			"mapOptions": component.get('v.mapOptions'),  
                       	'mapOptionsCenter': component.get('v.mapOptionsCenter')
        		} ;
        
        //Send message to VF
        helper.sendMessage(component, message);
    },
    sendMessage: function(component, message){
        //Send message to VF
        message.origin = document.location.hostname;
        var vfWindow = component.find("vfFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.vfHost"));
    }
})