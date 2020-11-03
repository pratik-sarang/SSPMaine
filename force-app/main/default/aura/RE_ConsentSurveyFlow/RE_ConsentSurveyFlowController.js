({
    init : function (component) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        //You get the whole decoded URL of the page.
		
        var sURLVariables = sPageURL.split('&'); //Split by = so that you get the key value pairs separately in a list
       
        var sParameterName;
        var i;
        var InvitationId;
        var PrefMethod;
        var ConsentProvidedBy;

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
                        
            if (sParameterName[0] === 'invitationId') { //lets say you are looking for param name - firstName
                InvitationId = sParameterName[1]; 
            }
            if(sParameterName[0] === 'prefMethod'){
                PrefMethod = sParameterName[1];
            }
            if(sParameterName[0] === 'consType'){
                ConsentProvidedBy = sParameterName[1];
            }
            
        }
	
       
        // Find the component whose aura:id is "flowData"
        var flow = component.find("flowData");
        
    var inputVariables = [
            { 
                name : "InvitationId", 
                type : "String", 
                value: InvitationId },
            {
                name : "PrefMethod", 
                type : "Boolean", 
                value: PrefMethod
            },
            {
                    name : "consType", 
                    type : "String", 
                    value: ConsentProvidedBy
            }
    
        ];
        
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("Consent_Survey_Flow",inputVariables);

    }
	

})