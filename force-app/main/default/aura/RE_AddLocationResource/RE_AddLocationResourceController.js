({
	doInit : function(component, event, helper) {
        helper.fetchPicklistValues(component);
        
        helper.doInitHandler(component);
    },
    
   onCloseOfAParticularDay : function(component) {
        var loc=component.get("v.LocationResource");
        if(component.get("v.bIsMondayClosed")){
            loc.tlocationResMondayOpen = null;
            loc.tlocationResMondayClose = null;
        }
        
        if(component.get("v.bIsTuesdayClosed")){
            loc.tlocationResTuesdayOpen=null;
            loc.tlocationResTuesdayClose=null;
        }
        
        if(component.get("v.bIsWednesdayClosed")){
            loc.tlocationResWednesdayClose=null;
            loc.tlocationResWednesdayOpen=null;
        }
        
        if(component.get("v.bIsThursdayClosed")){
            loc.tlocationResThursdayOpen=null;
            loc.tlocationResThursdayClose=null;
        }
        
        if(component.get("v.bIsFridayClosed")){
            loc.tlocationResFridayClose=null;
            loc.tlocationResFridayOpen=null;
        }
        if(component.get("v.bIsSaturdayClosed")){
            loc.tlocationResSaturdayClose=null;
            loc.tlocationResSaturdayOpen=null;
        }
        
        if(component.get("v.bIsSundayClosed")){
            
            loc.tlocationResSundayOpen=null;
            loc.tlocationResSundayClose=null;
        }
        component.set("v.LocationResource",loc);
    } , 	
    handleComponentEvent : function(component, event) {
		var selectedLocGetFromEvent = event.getParam("recordByEvent");
        var smryRecords = component.get("v.LocationResource");
        //Lookup to Location
        smryRecords.slocationResOffering = selectedLocGetFromEvent.Id;
        component.set("v.LocationResource",smryRecords);       
        var resrTax = component.find("resLocError");
        $A.util.addClass(resrTax,"slds-hide");
        component.set("v.csLookupRequired", false);
        
       
    },
       
    handleSave : function(component, event,helper){
        
      // var formdata = component.get("v.LocationResource");
        var errMsg;
        var toastEmailEvent = $A.get("e.force:showToast");
        var validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
       
        var validLookupVal = helper.validateLookupValues(component,event,helper);
        
        //create a method to check the validation of the time entered start time and end time
        var valid= helper.validateTimeInputs(component,event,helper);
        var vaildHoursOfOperation = helper.validHoursOfOperation(component,event,helper);
        
      
        var vaildPhone = component.find('stdPhone').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
       
            
        if(validForm && valid && validLookupVal && vaildHoursOfOperation && vaildPhone ){
            helper.checkLocationResource(component,helper)
        }
        else if (!validForm || !vaildPhone){
            errMsg = $A.get("$Label.c.mandatoryfieldserror");
            toastEmailEvent = $A.get("e.force:showToast");  //Lightning Valuate - Anuj
            toastEmailEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": errMsg,
                "type"   : "error"
            });
            
            toastEmailEvent.fire();
        } else if(!validLookupVal){
            errMsg = $A.get("$Label.c.mandatoryfieldserror");
            toastEmailEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": errMsg,
                "type"   : "error"
            });
            
            toastEmailEvent.fire();
        }
        
    },
    backToResource:function(component, event, helper){
        helper.backToResource(component, event);
    },
    
    
    formatPhoneNumber: function(component, event, helper) {
        
        var objWrapper = component.get("v.LocationResource");
               
        var formatedPhone1 = helper.formatPhoneNumber(component, objWrapper.slocationResPhone);
        component.set("v.LocationResource.slocationResPhone",formatedPhone1);
        
        var formatedPhone2 = helper.formatPhoneNumber(component, objWrapper.slocationResFirstPOCPhone);
        component.set("v.LocationResource.slocationResFirstPOCPhone",formatedPhone2);
        
        var formatedPhone3 = helper.formatPhoneNumber(component, objWrapper.slocationResSecondPOCPhone);
        component.set("v.LocationResource.slocationResSecondPOCPhone",formatedPhone3);
        
		var formattedPhone4 = helper.formatPhoneNumber(component, objWrapper.slocationResFax);
		component.set("v.LocationResource.slocationResFax",formattedPhone4);
		
		var tollFreePhone = helper.formatPhoneNumber(component, objWrapper.slocationResTollFree);
		component.set("v.LocationResource.slocationResTollFree",tollFreePhone);
        
        component.set("v.LocationResource", objWrapper);
        
    }, 
    /* assign the selected picklist values to appropriate wrapper mapping  */
    changeHandler : function(component, event) {
        var objWrapper = component.get("v.LocationResource");
        if(event.getSource().get("v.label") === $A.get("$Label.c.status")){
            objWrapper.slocationResStatus = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === "Time Zone"){
            objWrapper.slocationResTimeZone = event.getSource().get("v.value");
        }
    },
    
    onValueChange : function(component, event) {
        var objWrapper = component.get("v.LocationResource");
        if(event.getSource().get("v.label") ===	 $A.get("SNAP")){
            objWrapper.blocationResSNAP = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("TANF")){
            objWrapper.blocationResTANF = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("Medicaid")){
            objWrapper.blocationResMedicaid = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("Child Care")){
            objWrapper.blocationResCCAP = event.getSource().get("v.value");
        }
    },
    handleCancel : function(){
        var sPageURL = new URL(document.URL);
        var sRecordId = sPageURL.searchParams.get("sResourceId") === undefined ? sPageURL.searchParams.get("reslocId") : sPageURL.searchParams.get("sResourceId"); 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/edit-resource?sResourceId="+sRecordId
        });
        urlEvent.fire();
    }
})