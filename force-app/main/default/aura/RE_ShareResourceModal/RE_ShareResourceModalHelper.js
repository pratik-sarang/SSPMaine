({
    /* closes Modal popup */
    hideResourceModal : function(component){
        component.set("v.showResourceModal",false);
        if (document.getElementsByClassName('archtype-banner')[0] !== undefined)
        document.getElementsByClassName('archtype-banner')[0].classList.remove('display-none');
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.remove('display-none');
        }
        if (document.getElementsByClassName('archtype-header')[0] !== undefined)
        document.getElementsByClassName('archtype-header')[0].classList.remove('display-none');
        if (document.getElementsByClassName('resource-cards-section')[0] !== undefined)
            document.getElementsByClassName('resource-cards-section')[0].classList.remove('display-none');
        if (document.getElementsByClassName('archtype-filter-section')[0] !== undefined)
        document.getElementsByClassName('archtype-filter-section')[0].classList.remove('display-none');
        if (document.getElementsByClassName('archtype-map-section')[0] !== undefined)
        document.getElementsByClassName('archtype-map-section')[0].classList.remove('display-none');
        if(document.getElementsByClassName('rd-residentWrapper')[0] !== undefined){
            document.getElementsByClassName('rd-residentWrapper')[0].classList.remove('slds-hide');
        }
        if(document.getElementsByClassName('resource-details-heading')[0] !== undefined){
            document.getElementsByClassName('resource-details-heading')[0].classList.remove('slds-hide');
        }
        // Search Results
        if (document.getElementsByClassName('headingContainer')[0]) {
            document.getElementsByClassName('headingContainer')[0].classList.remove('slds-hide');
            document.getElementsByClassName('headingContainer')[0].classList.add('slds-show');
        }
        if (document.getElementsByClassName('myPlanLeftTab')[0]) {
            document.getElementsByClassName('myPlanLeftTab')[0].classList.remove('slds-hide');
            document.getElementsByClassName('myPlanLeftTab')[0].classList.add('slds-show');
        }
        document.querySelectorAll(".planCardSection .my-plan-card").forEach(
            function getVal(item) {
                item.classList.remove('slds-hide');
            });
        component.set("v.displayMap", true);
    },
    /* sends resource details */
    shareResourceDetails : function(component, event, helper){
        var inputWrapper = component.get("v.inputWrapper");
        var dataWrapper = component.get("v.resourceWrapper");
        var resourceDetailWrapper = {};
        resourceDetailWrapper.sLocationCity =  dataWrapper.location.sLocationCity;
        resourceDetailWrapper.sLocationState =  dataWrapper.location.sLocationState;
        resourceDetailWrapper.sLocationZip =  dataWrapper.location.sLocationZip;
		resourceDetailWrapper.sLocationId = (dataWrapper.location.sLocationId) ? btoa(dataWrapper.location.sLocationId) : '';
        resourceDetailWrapper.sLocationAddress1 =  dataWrapper.location.sLocationAddress1;
        resourceDetailWrapper.sLocationAddress2 =  dataWrapper.location.sLocationAddress2;
		resourceDetailWrapper.sLocationZipEncode =  (dataWrapper.location.sLocationZip) ? btoa(dataWrapper.location.sLocationZip) : ''; 
        resourceDetailWrapper.sPOCPhone =  dataWrapper.location.sPOCPhone;
        resourceDetailWrapper.sResourceName =  dataWrapper.resource.sResourceName;
		resourceDetailWrapper.resourceId =  (dataWrapper.resource.resourceId) ? btoa(dataWrapper.resource.resourceId) : '';    
        resourceDetailWrapper.sSDOHCategory =  dataWrapper.resource.sSDOHCategory;
        resourceDetailWrapper.sReferralOrgName =  dataWrapper.acc.sReferralOrgName;
        resourceDetailWrapper.sReferralOrgUrl =  dataWrapper.acc.sReferralOrgUrl;
		
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.shareResourceDetailsViaEmail', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                
                if(response.isSuccessful){
                    var successMsg = $A.get("$Label.c.RE_ShareResource_EmailSuccess");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "SUCCESS", successMsg);
                    helper.hideResourceModal(component);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "mapInputWrapper" : inputWrapper,
                "resourceDetailsWrapper" : resourceDetailWrapper
            },false);
        }catch (e) {
           
        }
    },
    shareResourceDetailsonPhone : function(component, event, helper){
        var inputWrapper = component.get("v.inputWrapper");
        //var resourceDetailWrapper = component.get("v.resourceWrapper");
        var phone = inputWrapper.toPhone;
		var dataWrapper = component.get("v.resourceWrapper");
        var resourceDetailWrapper = {};
        resourceDetailWrapper.sLocationCity =  dataWrapper.location.sLocationCity;
        resourceDetailWrapper.sLocationState =  dataWrapper.location.sLocationState;
        resourceDetailWrapper.sLocationZip =  dataWrapper.location.sLocationZip;
        resourceDetailWrapper.sLocationZipExt =  dataWrapper.location.sLocationZipExt;
        resourceDetailWrapper.sLocationAddress1 =  dataWrapper.location.sLocationAddress1;
        resourceDetailWrapper.sLocationAddress2 =  dataWrapper.location.sLocationAddress2;
        resourceDetailWrapper.sPOCEmail =  dataWrapper.location.sPOCEmail;
        resourceDetailWrapper.sPOCPhone =  dataWrapper.location.sPOCPhone;
        resourceDetailWrapper.sOperatingHoursToday =  dataWrapper.location.sOperatingHoursToday;
        resourceDetailWrapper.sResourceDescription =  dataWrapper.resource.sResourceDescription;
        resourceDetailWrapper.sResourceName =  dataWrapper.resource.sResourceName;
        resourceDetailWrapper.resourceId =  dataWrapper.resource.resourceId;
        resourceDetailWrapper.sReferralOrgName =  dataWrapper.acc.sReferralOrgName;
        resourceDetailWrapper.sReferralOrgUrl =  dataWrapper.acc.sReferralOrgUrl;
        phone = "+1 "+phone;
        
        component.set("v.inputWrapper.toPhone",phone);
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.shareResourceDetailsViaPhone', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var successMsg =$A.get("$Label.c.RE_SendSMSQued");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "SUCCESS", successMsg);
                    helper.hideResourceModal(component);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "resourceDetailsWrapper" : resourceDetailWrapper,
                "mapInputWrapper" : inputWrapper
            },false);
        }catch (e) {
        }
    },
    /* hide Resource modal */
    hideResourcePage: function(component){
        document.querySelectorAll(".planCardSection .my-plan-card").forEach(
            function getVal(item) {
                item.style.display="block";
            });
        if(document.getElementsByClassName('planMapSection')[0]){
        document.getElementsByClassName("planMapSection")[0].style.display="block";
        $A.util.addClass(component.find("showResourceModal"),"slds-hide");  
        }
    },
    /* checks email validity */
    checkNameField : function(component){ 
        component.set("v.isDisabled",true);  
        var status = component.get("v.captchaStatus");
	    	var yourName = component.find('yourName');
        var yourNameValue = yourName.get('v.value');
         //RE_Release 1.2 – Lightning valuate - Payal Dubela 
        if(yourNameValue === null || yourNameValue === '' || $A.util.isUndefinedOrNull(yourNameValue)){
            yourNameValue.set('v.validity', {valid:false, badInput :true});
            yourNameValue.showHelpMessageIfInvalid();
        }
        else if(status === "Verified"){
            component.set("v.isDisabled",false);            
        }
    },
    /* checks email validity */
    checkEmailValidity : function(component){ 
        component.set("v.isDisabled",true);  
        var pattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var status = component.get("v.captchaStatus");
        var inputField = component.find('toEmail');
        var value = inputField.get('v.value');
		var yourName = component.find('yourName');
        var yourNameValue = yourName.get('v.value');
        if(!pattern.test(value)){
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
        }
        else if(status === "Verified" && pattern.test(value) && yourNameValue.length >0){
            component.set("v.isDisabled",false);            
        }
    },
    checkPhoneValidity : function(component){
        component.set("v.isDisabled",true);  
        
        var inputField = component.find('toPhone');
        var value = inputField.get('v.value');
        
        var yourName = component.find('yourName');
        var yourNameValue = yourName.get('v.value');
        var patternForName = /^[a-zA-Z][a-zA-Z ]*$/;
        
        // var pattern = /^\+(?:[0-9] ?){6,10}[0-9]$/;
        var pattern = /^\d{10}$/;
        var PatternUSPhone = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
        var status = component.get("v.captchaStatus");
        
        
            if(PatternUSPhone.test(value) ){
                if(status === "Verified" && yourNameValue.length >0 && patternForName.test(yourNameValue)){
                component.set("v.isDisabled",false);  
                }
                else{
                     yourName.set('v.validity', {valid:false, badInput :true});
                    yourName.showHelpMessageIfInvalid();
                }
            }
            
            else if(!PatternUSPhone.test(value)){
                if(pattern.test(value)){
                    var cleaned = ('' + value).replace(/\D/g, '');
                    var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/);
                    if (match) {
                        var intlCode = (match[1] ? '+1 ' : '');
                        value =   [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('');
                    }
                    
                    component.set("v.inputWrapper.toPhone",value); 
                    if(status === "Verified" && yourNameValue.length >0 && patternForName.test(yourNameValue)){
                    component.set("v.isDisabled",false);
                    }
                    else{
                         yourName.set('v.validity', {valid:false, badInput :true});
                         yourName.showHelpMessageIfInvalid();
                    }
                }
                /*else{
                    inputField.set('v.validity', {valid:false, badInput :true});
                    inputField.showHelpMessageIfInvalid();
                }*/
            }
                   
    },
    formatPhoneNumber: function(component, phonenumber) {
        var phone = (""+phonenumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{5})(\d{5})$/);
        if(!formatedPhone){
            return phone;
        } //placeholder="+00 00000 00000"
        return (!formatedPhone) ? null : formatedPhone[1] + formatedPhone[2];
    },
    /* checks if user is citizen user */
    checkIfCitizen : function(component){ 
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);            
            var emptyObj = null;
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.checkIfCitizenUser', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    component.set("v.isCitizenProfileUser", response.objectData.isCitizenProfileUser);
                    component.set("v.inputWrapper.yourName", response.objectData.userName);
                    component.set("v.inputWrapper.yourEmail", response.objectData.userEmail);
                    var phone = response.objectData.userPhone;
                    //
                    var cleaned = ('' + phone).replace(/\D/g, '');
                    var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/);
                    if (match) {
                        var intlCode = (match[1] ? '+1 ' : '');
                        phone =   [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('');
                    }
                    //
                    component.set("v.inputWrapper.yourPhone", phone);
                    component.set("v.inputWrapper.recourceDetailUrl", component.get("v.resourceDetailsUrl"));
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },emptyObj,false);
        }catch (e) {
        }    
    },
    bSuper:{}
})