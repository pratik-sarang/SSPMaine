({
    doInit: function (component, event, helper) {
        //To get picklist values
        helper.getPicklistValues(component, helper);

    },
    submitInfo: function (component, event, helper) {
        var bSuper = component.find("bSuper");
        var validPhone2 = false;
        var inputField; //20Dec LV issue 
        var errorrec; //20Dec LV issue
        var errorRecPhone;//20Dec LV issue
        var inputFieldPhoneVal; //20Dec LV issue

        //To check field validity
        //To submit resident info if form is valid
            if(component.get("v.isCPUser")===true || component.get("v.isAgencyUser")===true ){
                inputField = component.find('required_fld');                
                errorrec=false;
                errorRecPhone=false;
                inputField.forEach(function(selVal){ 
                    if(selVal.get('v.validity').valid === false){  
                        selVal.showHelpMessageIfInvalid();                                  
                        errorrec=true;
                    }                
                });
              
        var inputFieldPhoneVal2 = component.find("required_fldPhone2");   
                
            if ((!$A.util.isUndefinedOrNull(inputFieldPhoneVal2)) && inputFieldPhoneVal2.get("v.value") !== null) {
                inputFieldPhoneVal = inputFieldPhoneVal2.get("v.value");
                validPhone2 = helper.checkPhoneValidity(component, event, inputFieldPhoneVal);
            }

            if ((!$A.util.isUndefinedOrNull(component.find('required_fldPhone2'))) && component.find('required_fldPhone2').checkValidity() === false && validPhone2 === false) {
                component.find('required_fldPhone2').showHelpMessageIfInvalid();
                errorRecPhone = true;
            } else {
                errorRecPhone = false;
            }
            if (errorrec === true || errorRecPhone === true) {
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.mandatoryfieldserror"));
            }
            else {
                helper.updateCPUserProfile(component);
            }
        } else {
            inputField = component.find('required_fld');  // 20Dec LV
            var inputFieldPhoneVal1 = component.find('required_fldPhone1');
            errorrec = false;
            errorRecPhone = false;
            if (!$A.util.isUndefinedOrNull(inputField)) {
                inputField.forEach(function (selVal) {
                    if (selVal.get('v.validity').valid === false) {
                        selVal.showHelpMessageIfInvalid();
                        errorrec = true;
                    }
                });
            }
            if ((!$A.util.isUndefinedOrNull(inputFieldPhoneVal1)) && ($A.util.isUndefinedOrNull(inputFieldPhoneVal1.get("v.value")) || inputFieldPhoneVal1 === "")) {
                inputFieldPhoneVal = inputFieldPhoneVal1.get("v.value");
                validPhone2 = helper.checkPhoneValidity(component, event, inputFieldPhoneVal);
            }
            if ((!$A.util.isUndefinedOrNull(component.find('required_fldPhone1'))) && component.find('required_fldPhone1').checkValidity() === false && validPhone2 === false) {
                component.find('required_fldPhone1').showHelpMessageIfInvalid();
                errorRecPhone = true;
            } else {
                errorRecPhone = false;
            }
            //RE_Release 1.1 - Defect 357793 - Kojashree 
            var errorCommPref = false;
            var commPref = component.get("v.contactinformation.PreferredCommunicationMethod__c");
            var mobLabel = $A.get("$Label.c.MobilePhone");
            var commPrefMap = component.get("v.communicationMethodMap");

            for(var key in commPrefMap){
                if(commPrefMap[key].value === commPref){
                    commPref = commPrefMap[key].label;
                    
                }
            }
           
            var consentCheckVal = component.get("v.consentToText");
   
            if (commPref === mobLabel && consentCheckVal === false) {

                errorCommPref = true;
            }
            if (errorrec === true || errorRecPhone === true) {
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.mandatoryfieldserror"));
            } else if (errorCommPref === true) {
                var errMsg = $A.get("$Label.c.ConsentToTextErrorMsg");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            }
            else if (errorrec === false && errorRecPhone === false && errorCommPref === false) {
                helper.submitResidentInfo(component);
            }

        }
        return true;
    },
    /* format phone number */
    formatPhoneNumber: function (component, event, helper) {
        //format phone number
        var phone = component.get("v.contactinformation.Phone");
        var formatedPhone = helper.formatPhoneNumber(phone);
        formatedPhone = formatedPhone.replace(/^0+/, '');
        component.set("v.contactinformation.Phone", formatedPhone);
    },
    validateEmail: function (component, event, helper) {
        //Check email validity
        var email = component.get("v.contactinformation.Email");
        var isValid = helper.checkEmailValidity(email);
        if (isValid !== true) {
            return false;
        }
        return true;
    },
    logout: function () {
        //Logout functionality
        var url = '../secur/logout.jsp';
        window.open(url, '_top');

    },
    handleNext: function (component, event, helper) {
        var hasError = helper.validateInputs(component);
        var bSuper = component.find("bSuper");
        if (hasError === true) {
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.mandatoryfieldserror"));
            return false;
        }
        component.set('v.isNextVisible', false);
        component.set('v.isNextClicked', true);
        return true;
    }
})