({
    saveClaimRec : function(component) {
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var objClaimRequest = component.get("v.objClaimRequest");
            var val = component.get("v.radiobtnval")
            if(val === 'Other'){
                objClaimRequest.HearAboutRE__c = component.get("v.radiobtnOtherval");
            }
            else{
                objClaimRequest.HearAboutRE__c = val;
            }
            objClaimRequest.Organization__c = component.get("v.organizationId");
            var otherRoleValue = component.get("v.radiobtnOtherRoleVal");
            if(otherRoleValue !== null && otherRoleValue !== ""){
                objClaimRequest.OtherRole__c = otherRoleValue;
            }
            objClaimRequest.UniqueIdentificationNo__c = component.get("v.organizationUniqueId");
            objClaimRequest.RequestingOrganizationName__c = component.get("v.organizationName");
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.saveClaimSiteRequest', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    component.set("v.isOpen",true);
                    setTimeout(function(){//JAWS Fix
                        document.getElementsByClassName("modal-lg-heading")[0].focus(); 
                    },1000);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
            },{
                "claimRecord": objClaimRequest
            },false);
        }catch (e) {
        }
    },
    
    formatPhoneNumber: function(component,phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    
    checkAcceptTermsAndConditions : function(component) {
        var retVal = true;
        var formdata = component.get("v.objClaimRequest");
        var bSuper = component.find("bSuper"); 
        if(formdata.TermsAndConditionsCheck__c === false || formdata.TermsAndConditionsCheck__c === undefined){
            var errMsg = $A.get("$Label.c.RE_CheckTerms");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            retVal = false;
        }
        return retVal;
    },
    
    handleCancel: function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/searchorganization"
        });
        urlEvent.fire();
    },
    
    closeSuccessModel: function() {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/landing-page"
        });
        urlEvent.fire();
    },
    
    doInitMethod: function(component) {
        try{
        //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            var emptyObject = null;
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchOrgRolePickValues', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var picklistValues = response.objectData.OrganizationRole;
                    var options = [];
                    for(var i in picklistValues){
                        if(picklistValues.hasOwnProperty(i)){
                       options.push(picklistValues[i]);
                        }
                    }
                    component.set("v.picklistOrgRole",options);
                    //component.set("v.picklistOrgRole",response.objectData.OrganizationRole);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
            },emptyObject,false);
        }catch (e) {
        }
       
    },
    createColumnData:function(component){
        var optionsData=[];
        optionsData.push({'label': $A.get("$Label.c.RE_FromState"), 'value': 'From a State'},
                         {'label': $A.get("$Label.c.RE_FromAssister"), 'value': 'From an Assister'},
                         {'label': $A.get("$Label.c.RE_FromCommunity"), 'value': 'From another community'},
                         {'label': $A.get("$Label.c.RE_FromCommonwealth"), 'value': 'From Commonwealth'},
                         {'label': $A.get("$Label.c.Other"), 'value': 'Other'})
        component.set("v.options",optionsData);
    },
    
    validateInputs : function(component) {
        var formdata = component.get("v.objClaimRequest");
        var allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        
        var validationError = false;
        if(formdata.FirstName__c === null  || formdata.LastName__c === null 
           || formdata.Email__c === null || formdata.PhoneNumber__c === null ){
            validationError = true;
        }else{
            if($A.util.isEmpty(formdata.FirstName__c.trim()) || $A.util.isEmpty(formdata.LastName__c.trim()) 
               ||$A.util.isEmpty(formdata.Email__c.trim()) || $A.util.isEmpty(formdata.PhoneNumber__c.trim())){
                validationError = true;
            }
        }
        if(allValid === false){
            validationError = true;
        }
        return validationError;
    },
    otherRoleSelected: function(component, event, val){
        if(val === 'Other'){
            component.set("v.isDisabledOther",false);
        }else{
            component.set("v.radiobtnOtherRoleVal",'');
            component.set("v.isDisabledOther",true);
        }
    },
    
    bSuper:{}
    
    
})