({
    doInit : function(component, event, helper) {
        helper.fetchPicklistValues(component, event);
        helper.doInitHandler(component);
    },   
    handleEditLocation : function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var resourceId = component.get("v.resRecordId");
        var recId = event.target.getAttribute("data-recId");
        //var buttonvalue = event.getSource().get("v.name");
        var parameters = "?reslocId="+recId+"&sResourceId="+resourceId;
        urlEvent.setParams({
            "url": "/edit-resource-location"+parameters,
           	"resourceId":resourceId
        });
        urlEvent.fire();
    },
    saveData : function(component, event, helper) {
        var dataValid = helper.validateInputs(component);
        /*returnPhoneVal = component.get("v.isValidPhone");
        if(!returnPhoneVal){
			var bSuper = component.find("bSuper"); 	   
            var errMsgforPhone = $A.get("$Label.c.RE_EntercorrectPhone");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsgforPhone);
        }*/
        var returnEmailVal;
        var returnPhoneVal;
       // var stdPhone = component.find("stdPhone");
        //var phoneval = component.find("stdPhone").get("v.value");   
        var errMsg;
        var bSuper;
       // var phoneValCorrect = helper.checkPhoneValidity(component,event,helper,phoneval);
        //console.log(phoneValCorrect);
        
        /*if(stdPhone.get("v.validity").valid && phoneValCorrect) {
            returnPhoneVal = true;
        } else {
            stdPhone.showHelpMessageIfInvalid();
            returnPhoneVal = false;
        }*/
       /* var pocEmail = component.find("pocEmail");        
        if(pocEmail.get("v.validity").valid) {
            returnEmailVal = true;
        } else {
            pocEmail.showHelpMessageIfInvalid();
            returnEmailVal = false;
        }*/
        if(dataValid ){//&& returnEmailVal && returnPhoneVal
            helper.saveData(component, event);
        }
        else{
            if(dataValid===false){
                bSuper = component.find("bSuper"); 
                errMsg = $A.get("$Label.c.mandatoryfieldserror");
                bSuper.showToast('Error', 'Error', errMsg);
            }
            else if(returnEmailVal===false && returnPhoneVal===true){
                bSuper = component.find("bSuper"); 
                errMsg = $A.get("$Label.c.invalidemailaddress");
                bSuper.showToast('Error', 'Error', errMsg);
            }
                else if(returnEmailVal===true && returnPhoneVal===false){
                    bSuper = component.find("bSuper"); 
                    errMsg = $A.get("$Label.c.InvalidPhone");                
                    bSuper.showToast('Error', 'Error', errMsg);
                }
                    else if(returnEmailVal===false && returnPhoneVal===false){
                        bSuper = component.find("bSuper"); 
                        errMsg = $A.get("$Label.c.InvalidPhone") +'\n'+ $A.get("$Label.c.invalidemailaddress");
                        bSuper.showToast('Error', 'Error', errMsg);
                    }
        }
    }, 
    backToDataTable:function(component, event, helper){
        helper.backToDataTable(component, event);
    },
    /* assign the selected picklist values to appropriate wrapper mapping  */
    changeHandler : function(component, event) {
        var objWrapper = component.get("v.summaryrecords");
        if(event.getSource().get("v.label") === $A.get("$Label.c.status")){
            objWrapper.Status = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === "Domain"){
            objWrapper.SDOHCategory = event.getSource().get("v.value");
        }
    },
    
    onValueChange : function(component, event) {
        var objWrapper = component.get("v.summaryrecords");
        if(event.getSource().get("v.label") ===	 $A.get("SNAP")){
            objWrapper.EligibilitySNAP = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("TANF")){
            objWrapper.EligibilityTANF = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("Medicaid")){
            objWrapper.EligibilityMedicaid = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("Child Care")){
            objWrapper.EligibilityCCAP = event.getSource().get("v.value");
        }
    },
    
    handleComponentEvent : function(component, event) {
        var selectedTaxonomyGetFromEvent = event.getParam("recordByEvent");
        var smryRecords = component.get("v.summaryrecords");
        smryRecords.TaxonomyId = selectedTaxonomyGetFromEvent.Id;
        component.set("v.summaryrecords",smryRecords);
        var resrTax = component.find("resTaxerror");
        $A.util.addClass(resrTax,"slds-hide");
        component.set("v.csLookupRequired", false);
    },
    formatPhoneNumber: function(component, event, helper) {
        var fieldType = event.getSource().getLocalId();
        var pocPhone = component.get("v.summaryrecords.POCPhone");
        var pattern = /^(?!0+$)[0-9]{10}$/;        
        if(fieldType === 'stdPhone' && pattern.test(pocPhone)){
            var formatedPhone = helper.formatPhoneNumber(component, pocPhone);
            component.set("v.summaryrecords.POCPhone",formatedPhone);
            
        }
    },
    handleAddLocation : function(component) {
        component.set("v.addLocation", true);
        var urlEvent = $A.get("e.force:navigateToURL");
        var resourceId = component.get("v.resRecordId");
        //var AccountId = Account.Id;
        urlEvent.setParams({
            "url": "/add-location-resource?sResourceId="+resourceId
        });
        urlEvent.fire(); 
        }
    
})