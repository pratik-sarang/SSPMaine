({
	handleAddResource : function(component) {
		$A.createComponent(
        	"c:RE_ResourceSummary",{
                "aura:id":"resourse",
                "resRecordId" : "",
                "typeOfAction" : "create",
                "hideLocationHeaderOnAddResource" : false
            },
            function(newcomponent){
            	if (component.isValid()) {
                	component.get("v.body").length=0;
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
            }            
       );
        document.getElementsByClassName("locationtable-cont")[0].classList.add("slds-hide");
        document.getElementsByClassName("locationtable-body")[0].classList.remove("slds-hide"); 
        document.getElementsByClassName("headingContainer")[0].classList.add("slds-hide");
        document.getElementsByClassName("locationsel-cont")[0].classList.add("slds-hide");
        document.getElementsByClassName("summary-heading")[0].classList.add("slds-hide");
	},
    doInit : function(component, event, helper) {
        helper.doInitHandler(component, event);
    }
})