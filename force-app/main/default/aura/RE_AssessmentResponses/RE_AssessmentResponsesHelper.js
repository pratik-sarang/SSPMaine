({
    backToOneView : function(component){
        var contactId = btoa(component.get("v.assessmentResourceData").sResidentId);
        window.open('clients?clientId='+contactId,'_self');
    }    
})