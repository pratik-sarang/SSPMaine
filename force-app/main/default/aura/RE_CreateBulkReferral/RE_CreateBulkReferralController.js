({
    doinIt : function(component, event, helper) {
        
        var tbdata = component.get("v.bulfReferralTableData");
        var jsonData = JSON.stringify(tbdata);
        helper.getTableData(component,jsonData);
       
    },
    
    handleSubmit : function(component,event, helper){
    	var tbdata = component.get("v.bulfReferralTableData");
        var jsonData = JSON.stringify(tbdata);
		helper.handleSubmitFromHelper(component,jsonData);    
	},
    
    /* format phone number */
    formatPhoneNumber: function(component, event, helper) {
      //  var objWrapper = component.get("v.referralObj");
       // var phone = objWrapper.Phone;
      var phone = component.get("v.userPhone");
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        formatedPhone = formatedPhone.replace(/^0+/, '');//Added by Megha to handle leading 0s in Phone number
        //objWrapper.Phone = formatedPhone;
        component.set("v.userPhone", formatedPhone);
       //component.set("v.referralObj", objWrapper);
       
    },
    validateEmail : function(component, event, helper){
        //var objWrapper = component.get("v.referralObj");
        var email = component.get("v.userEmail");;
        var isValid = helper.checkEmailValidity(component, event, email);
        if(isValid !== true){
            return false;
        }
        else{
            return true;
        }
    },
    
    handleComponentEvent : function(component, event) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var objName = event.getParam("lookupObjName");
        
        
        if(selectedAccountGetFromEvent !== 'cleared' && objName==='Contact'){
            component.set("v.contactId",selectedAccountGetFromEvent.Id);
          
        }else if(objName==='Contact'){
            component.set("v.contactId",'');
        }
    	
    },
    
    backToDataTable : function(component){
        
        var compEvent = component.getEvent("backtoFavoritesScreen");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"bBacktoBulkReferral" : "true"
                            });  
        
        compEvent.fire();
        $A.get('e.force:refreshView').fire();
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
       
    },
})