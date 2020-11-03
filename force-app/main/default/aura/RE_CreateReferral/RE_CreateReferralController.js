({	 
    doinIt : function(component, event, helper) {
        var accid=component.get('v.accountId');
        if(accid){
            var objWrapper = component.get("v.referralObj");
            objWrapper.Organization=accid;
            helper.getLocation(component,event,helper);
            helper.getResource(component,event,helper);
        }
        helper.fetchData(component, event);
		helper.fetchFavorites(component);
    },
    backToDataTable: function(component) {
        component.set('v.bShowClientTable',true);
        component.set('v.showClientDetail',true);
        component.set('v.showreferral',false);
        component.set('v.bShowResourceDetail',true);
        //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020)
        component.set("v.isFrequentlyPaired",false);
        component.set("v.isRelatedServices",false);
        var methodRef = component.get("v.methodRef");
        $A.enqueueAction(methodRef);
        
        if(document.getElementsByClassName('archtype-banner')[0]){
            document.getElementsByClassName('archtype-banner')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('archtype-header')[0]){
            document.getElementsByClassName('archtype-header')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('resource-cards-section')[0]){
            document.getElementsByClassName('resource-cards-section')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('archtype-filter-section')[0]){
            document.getElementsByClassName('archtype-filter-section')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('archtype-map-section')[0]){
            document.getElementsByClassName('archtype-map-section')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.remove('display-none');
        }
        
        // Search Results
        
        if (document.getElementsByClassName('myPlanLeftTab')[0]) {
            document.getElementsByClassName('myPlanLeftTab')[0].classList.remove('slds-hide');
            document.getElementsByClassName('myPlanLeftTab')[0].classList.add('slds-show');
        }
        if (document.getElementsByClassName('planMapSection')[0]) {
            document.getElementsByClassName('planMapSection')[0].classList.remove('slds-hide');
            document.getElementsByClassName('planMapSection')[0].classList.add('slds-show');
        }
        if (document.getElementsByClassName('search-results-cards')[0]) {
            document.getElementsByClassName('search-results-cards')[0].classList.remove('slds-hide');
            document.getElementsByClassName('search-results-cards')[0].classList.add('slds-show');
        }
        if(document.getElementsByClassName('load-more-btn')[0]){
            document.getElementsByClassName('load-more-btn')[0].classList.remove('slds-hide');
        }
        
    },
    
    handleSubmit:function(component, event, helper) {
        // Check for the validations
        var objWrapper = component.get("v.referralObj");
        objWrapper.Contact=component.get("v.contactId");
        var valid= helper.validateInput(component,event,helper);
        if(valid){
            helper.submitReferral(component,event,helper);
        }
    },
    handleComponentEvent : function(component, event, helper) {
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var objName = event.getParam("lookupObjName");

        var objWrapper = component.get("v.referralObj");
        
        if(selectedAccountGetFromEvent !== 'cleared' && objName==='Account'){
            component.set("v.accountId",selectedAccountGetFromEvent.Id);
            component.set("v.bIsresourcedisabled",true);
            //component.set("referralObj.Location",'');
            //  var objWrapper = component.get("v.referralObj");
            objWrapper.Organization=selectedAccountGetFromEvent.Id;
            objWrapper.Location='';
            helper.getLocation(component,event,helper);
        }else if(objName==='Account'){
            // objWrapper.Location='';
            //objWrapper.Resource='';
            component.set("v.referralObj.Location",'');
            component.set("v.referralObj.Resource",'');
            objWrapper.Organization='';
        }
        
        if(selectedAccountGetFromEvent !== 'cleared' && objName==='Contact'){
            component.set("v.contactId",selectedAccountGetFromEvent.Id);
            objWrapper.Contact=selectedAccountGetFromEvent.Id;
            //  var cid=component.get("v.contactId");
            //   console.log('contactid is :'+cid);
        }else if(objName==='Contact'){
            component.set("v.contactId",'');
            objWrapper.Contact='';


        }
        
    },
    handleStatusChange:function (component, event,helper) {
        var fieldName = event.getSource().getLocalId();
        var changeValue = component.find(fieldName).get("v.value");
        var objWrapper = component.get("v.referralObj");
        if(fieldName === 'location'){
            objWrapper.Location = changeValue;
            if(changeValue === ''){
                component.set("v.bIsresourcedisabled",true);
                
            }else{
                component.set("v.bIsresourcedisabled",false);
            }
            objWrapper.Resource = '';
            component.set("v.locationId",changeValue);
            helper.getResource(component,event,helper);
        }else if(fieldName === 'resource'){
            objWrapper.Resource = changeValue; 
        } 
    },
    /* format phone number */
    formatPhoneNumber: function(component, event, helper) {
        var objWrapper = component.get("v.referralObj");
       // var phone = objWrapper.Phone;
      var phone = component.get("v.userPhone");
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        objWrapper.Phone = formatedPhone;
        formatedPhone = formatedPhone.replace(/^0+/, '');//Added by Megha to handle leading 0s in Phone number
        component.set("v.userPhone", formatedPhone);
       //component.set("v.referralObj", objWrapper);
       
    },
    validateEmail : function(component, event, helper){
        var objWrapper = component.get("v.referralObj");
        var email = objWrapper.Email;
        var isValid = helper.checkEmailValidity(component, event, email);
        if(isValid !== true){
            return false;
        }
        else{
            return true;
        }
    },
	handleFavoriteChange : function(component, event, helper){		
    	helper.handleFavoriteChange(component,event, helper);		
    }
})