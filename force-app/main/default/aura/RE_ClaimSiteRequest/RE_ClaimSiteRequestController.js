({
    handleSubmit : function(component, event, helper) {
        var hasError = helper.validateInputs(component, event, helper);
        var bSuper = component.find("bSuper"); 
        if(hasError === true){
            var errorMsg = $A.get("$Label.c.mandatoryfieldsClaimSite");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errorMsg);
            return false;
        }
        var termsAndCondions = helper.checkAcceptTermsAndConditions(component, event,helper);
        
        
        if(termsAndCondions === false){
            return false;
        }
        helper.saveClaimRec(component, event);
        return true;
    },
    handleCancel : function(component, event, helper){
        helper.handleCancel(component, event, helper);
    },
    doInit: function(component, event, helper){
        component.set("v.objClaimRequest.OrganizationRole__c","Manager");
        helper.doInitMethod(component, event, helper);
    },
    onPicklistChange: function(component, event, helper) {
        var val= event.getSource().get("v.value");
        component.set("v.objClaimRequest.OrganizationRole__c",val);

        helper.otherRoleSelected(component, event, val);
    },
    closeModel: function(component) {
        component.set("v.isOpen",false);
    },
    closeSuccessModel: function(component, event, helper) {
        helper.closeSuccessModel(component, event, helper);
    },
    changedValues: function(component, event){
        var currentValue = event.getSource().get("v.value");
        if(currentValue === 'Other'){
            component.set("v.isDisabled",false);
        }else{
            component.set("v.radiobtnOtherval",'');
            component.set("v.isDisabled",true);
        }
    },
    formatPhoneNumber: function(component, event, helper) {
        var objClaimRequest = component.get("v.objClaimRequest");
        var phone = objClaimRequest.PhoneNumber__c;
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        objClaimRequest.PhoneNumber__c = formatedPhone;
        formatedPhone = formatedPhone.replace(/^0+/, '');//Added by Megha to handle leading 0s in Phone number
        component.set("v.objClaimRequest", objClaimRequest);
    },
    openWebsite: function(component, event){
        var url=event.target.title;
        if(url.indexOf('http')===-1 && url.indexOf('https')===-1){
           url=$A.get("$Label.c.https")+"://" + event.target.title;
        }
        window.open(url,"_blank");  
    },
    openPrivacyPolicy: function(){
        var url="privacy-policy";
        window.open(url,'_blank');
    },
    openTerms: function(){
        var url="terms-of-use";
        window.open(url,'_blank');
    },
    moveFocusToTop: function(component){//JAWS Fix
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },100);
    }    
})