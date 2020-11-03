({
    /* fetch the picklist values and initialize the wrapper on load */
    doinIt : function(component, event, helper) {
        helper.fetchPicklistValues(component);
        helper.initializeWrapper(component);
        setTimeout(function(){//JAWS Fixes
            if(document.getElementsByClassName("modal-lg-heading")[1]){
                document.getElementsByClassName("modal-lg-heading")[1].focus();
            }else{
                document.getElementsByClassName("modal-lg-heading")[0].focus();
            }
         },2000);
    },
    moveFocusToTop: function(component, event, helper) {//JAWS FIXES
        if(event.keyCode === 9) {
            setTimeout(function(){
               document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10)
        }
    },
    /* close the modal */
    openCloseEditModal : function(component, event, helper) {
        helper.closeEditModal(component);
    },
    /* submit the form data */
    submit : function(component, event, helper) {
        var formdata = component.get("v.objwrapper");
        if($A.util.isEmpty(formdata.Status)){
            formdata.Status = 'Active';
            component.set("v.objwrapper", formdata);
        }
        var hasError = helper.validateInputs(component, formdata);
        var bSuper = component.find("bSuper"); 
        if(hasError === true){
            component.set("v.displayLoader", false);
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.mandatoryfieldserror"));
            return false;
        }
        if(component.get("v.initialStatus")!==formdata.Status){
            component.set("v.objwrapper.isStatusChanged",true);
        }
        var userdata = component.get("v.userdata");
        if(formdata.isUserActive === false && formdata.Status === 'Active'){
             helper.updateUserStatus(component);
        }  
        helper.submitHandler(component, event, helper);
        return true;
    },
    /* assign the selected picklist values to appropriate wrapper mapping  */
    changeHandler : function(component, event) {
        var objWrapper = component.get("v.objwrapper");
        if(event.getSource().get("v.label") === $A.get("$Label.c.permissions")){
            objWrapper.PermissionsLevel = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("$Label.c.status")){
            objWrapper.Status = event.getSource().get("v.value");
        }else if(event.getSource().get("v.label") === $A.get("$Label.c.primarylocation")){
            objWrapper.PrimaryLocation = event.getSource().get("v.value");
        }
    },
    /* checkbox handler to handle the checkbox selection */
    checkboxHandler : function (component) {  
        var objWrapper = component.get("v.objwrapper");
        if(component.find("training").get("v.value") === true){
            objWrapper.TrainingLevel = $A.get("$Label.c.complete");
        }else{
            objWrapper.TrainingLevel = $A.get("$Label.c.notcomplete");
        }
        component.set("v.objwrapper", objWrapper); 
    },
    /* format phone number */
    formatPhoneNumber: function(component, event, helper) {
        var objWrapper = component.get("v.objwrapper");
        var phone = objWrapper.Phone;
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        formatedPhone = formatedPhone.replace(/^0+/, '');                
        objWrapper.Phone = formatedPhone;
       
        component.set("v.objwrapper", objWrapper);
    },
  
    validateEmail : function(component, event, helper){
        var objWrapper = component.get("v.objwrapper");
        var email = objWrapper.Email;
        var isValid = helper.checkEmailValidity(component, event, email);
        if(isValid !== true){
            return false;
        }
        return true;
    }
})