({
	doInit : function(component, event, helper) {
		helper.getOrgDetail(component);
        
	},
    onPicklistChange: function(component, event) {
        var val= event.getSource().get("v.value");
        component.set("v.AccountRec.Status__c",val);
	},
    handleSave: function(component, event, helper) {
        var phoneExtVal = component.find('required_fldExt').get('v.value');
        var phnExt = helper.phoneExtension(phoneExtVal);
        var phoneval;
        //var conphoneId = component.find('stdPhone');
        var conphoneVal = component.find('stdPhone').get('v.value');
        phoneval = conphoneVal;
        var inputFieldPhoneVal = helper.checkPhoneValidity(component, event, phoneval);
        
        //var leadPhone = component.find('required_fldPhone');
        var leadPhoneVal = component.find('required_fldPhone').get('v.value');
        phoneval = leadPhoneVal;
       var inputFielPocPhone = helper.checkPhoneValidity(component,event,phoneval);
        //added by Srikanth - regression defect fix 
        var hasError = false;
         if(component.find('required_fldExt').checkValidity() === false && phnExt === false){
            hasError = true;
        }
        if(component.find('leadEMail').checkValidity() === false){
            hasError = true;
        }
		if(component.find('stdWebsite').checkValidity() === false){
            hasError = true;
        }
        if(component.find('required_fldPhone').checkValidity() === false && inputFielPocPhone === false){
            hasError = true;
        }
        if(component.find('stdPhone').checkValidity() === false && inputFieldPhoneVal === false){
            hasError = true;
        }
        if(component.find('stdFacebook').checkValidity() === false){
            hasError = true;
        }
        if(component.find('stdTwitter').checkValidity() === false){
            hasError = true;
        }        
        if(component.find('zipcode').checkValidity() === false){
            hasError = true;
        }
        if(component.find('stdemail').checkValidity() === false){
            hasError = true;
        }
        if(component.find('stdtaxid').checkValidity() === false){
            hasError = true;
        }        
        if(component.find('required_fld').checkValidity() === false){
            hasError = true;
        }    
        //added by suresh
        var acc = component.get("v.AccountRec");
        if(acc.Name ===''){
            hasError = true;
        }
        /*component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);*/
        /*if(validRequired === true){
            //return false;
            hasError = true;
        }*/
        if(hasError === true){
            var errMsg = $A.get("$Label.c.mandatoryfieldserror");
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "type" : "Error",
                "message": errMsg
            });
            toastEvent.fire();
            return false;
        }
        helper.updateOrgDetail(component,event);
        return true;
        
},
    handleLangUpdateEventNew: function(component, event) {
        var listSelectedLangs = event.getParam("listSelectedfieldValues");
    	component.set("v.lstLanguages",listSelectedLangs);
    	var sLanguagesSemicolonString ='';
    	var i= 0;
    	for(i=0;i < listSelectedLangs.length; i+=1){
    		if(i !== (listSelectedLangs.length -1)){
    			sLanguagesSemicolonString += listSelectedLangs[i] +';'
    		}
    		else{
    			sLanguagesSemicolonString += listSelectedLangs[i];
    		}
    		
    	}
    	
    	var sLocation = component.get("v.AccountRec");
    	sLocation.CountyServed__c = sLanguagesSemicolonString;
    	
    },
    handleEditLocation : function(component, event) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var buttonvalue = event.getSource().get("v.name");
        urlEvent.setParams({
            "url": "/locationdetails?sRecordId="+buttonvalue
        });
        urlEvent.fire();
    },
    //Added by Lagan
    handleAddLocation : function(component) {
        var urlEvent = $A.get("e.force:navigateToURL");
        var Account = component.get("v.AccountRec");
        var AccountId = Account.Id;
        urlEvent.setParams({
            "url": "/newlocation?sRecordId="+AccountId
        });
        urlEvent.fire();
    },
    
    formatPhoneNumber: function(component, event, helper) {
        var fieldType = event.getSource().getLocalId();
        var objAccount = component.get("v.AccountRec");
        var phone;
        if(fieldType === 'stdPhone'){
            phone = objAccount.Phone;
            var formatedPhone = helper.formatPhoneNumber(component, phone);
            formatedPhone = formatedPhone.replace(/^0+/, '');
            objAccount.Phone = formatedPhone;
        }else{
            phone = objAccount.POC_Phone__c;
            var formattedPhone = helper.formatPhoneNumber(component, phone);
            formattedPhone = formattedPhone.replace(/^0+/, '');
            objAccount.POC_Phone__c = formattedPhone;
        }
        
        component.set("v.AccountRec", objAccount);
    }
})