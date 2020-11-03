({
    doinIt : function(component,event,helper){
        var baseUrl= decodeURIComponent(window.location.href);
        var optionSelected=baseUrl.split('/s/')[0];
        var captchaURL = optionSelected + "/apex/RE_CaptchaV2";
        component.set("v.captchaURL", captchaURL);
        document.documentElement.scrollTop=0;
        component.set("v.displayLoader",true);
        var resourceData = component.get("v.resourceDetailWrapper");
        component.set("v.resourceWrapper",resourceData);
        component.set("v.isDisabled",true);
        var bSuper = component.find("bSuper"); 
        window.addEventListener("message",function(evt){
            if(evt.data === "Unlock"){
                component.set("v.captchaStatus","Verified");
                component.set("v.displayLoader",false);
                var sendmail  = component.get("v.bShowEmail");
                var sendPhone = component.get("v.bShowPhone");
                if(sendmail)
                {
                    var sToEmail = component.get("v.inputWrapper.toEmail");
                    if(sToEmail.length !== 0)
                        helper.checkEmailValidity(component);
                    else{
                        var errMsg = $A.get("$Label.c.RE_EnterToEmailError");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                }
                if(sendPhone){
                    var sToPhone = component.get("v.inputWrapper.toPhone");
                    if(sToPhone.length !== 0)
                        helper.checkPhoneValidity(component);
                    else{
                        var errMsgforPhone = $A.get("$Label.c.RE_EntercorrectPhone");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsgforPhone);
                    }
                }
            }
            document.getElementsByClassName("iframe-captcha")[0].style.height="5rem";
            document.querySelectorAll(".iframe-captcha iframe")[0].style.height="8rem";
            if(evt.data === 'Loaded'){
                document.querySelectorAll(".iframe-captcha iframe")[0].style.height="40rem";
                document.getElementsByClassName("iframe-captcha")[0].style.height="40rem";
                component.set("v.displayLoader",false);
            }
            /*JAWS Fixes*/
            setTimeout(function(){
                document.getElementsByClassName("showResourceModal")[0].focus();
            },200);
        },false);
        helper.checkIfCitizen(component);
    },
    hideResourceModal : function(component,event, helper){
        helper.hideResourceModal(component);
       	helper.hideResourcePage(component);       
        //component.set("v.showResourceModal",false);
        //archetype
        if(document.getElementsByClassName('archtype-banner')[0]){
            document.getElementsByClassName('archtype-banner')[0].classList.remove('display-none');
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.remove('display-none');
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
        //resource details
        if(document.getElementsByClassName('rd-residentWrapper')[0]){
           document.getElementsByClassName('rd-residentWrapper')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('flash-text')[0]){
           document.getElementsByClassName('flash-text')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('resource-details-heading')[0]){
          document.getElementsByClassName('resource-details-heading')[0].classList.remove('slds-hide');  
        }
        
        // search Results
        if (document.getElementsByClassName('headingContainer')[0]) {
            document.getElementsByClassName('headingContainer')[0].classList.remove('slds-hide');
            document.getElementsByClassName('headingContainer')[0].classList.add('slds-show');
        }
        if(document.getElementsByClassName('load-more-btn')[0]){
            document.getElementsByClassName('load-more-btn')[0].classList.remove('slds-hide');
        }
    },
    onSend : function(component, event, helper){
        component.set("v.isDisabled",true);
        var sendmail  = component.get("v.bShowEmail");
        var showPhone  = component.get("v.bShowPhone");
        
        if(sendmail){
            helper.shareResourceDetails(component, event, helper);
            helper.hideResourcePage(component);
            //component.set("v.showResourceModal",false);      
            //to Show Resource -Details Page back
            if(document.getElementsByClassName('rd-residentWrapper')[0] !== undefined){
             document.getElementsByClassName('rd-residentWrapper')[0].classList.remove('slds-hide');
            }
            if(document.getElementsByClassName('flash-text')[0] !== undefined){
                document.getElementsByClassName('flash-text')[0].classList.remove('slds-hide'); 
            }
            if(document.getElementsByClassName('resource-details-heading')[0] !== undefined){
                document.getElementsByClassName('resource-details-heading')[0].classList.remove('slds-hide');
            }
        }
        if(showPhone){            
            helper.shareResourceDetailsonPhone(component, event,helper);
            helper.hideResourcePage(component);
        }
    },
    checkInputs : function(component, event, helper){
        component.set("v.isDisabled",true);
        var sendmail  = component.get("v.bShowEmail");
        var showPhone  = component.get("v.bShowPhone");
        helper.checkNameField(component);
        if(sendmail){
            helper.checkEmailValidity(component);     
        }
        if(showPhone){
            helper.checkPhoneValidity(component);    
        }
    },
    /*showEmailForm : function(component,event,helper){
        component.set("v.bShowEmail",true);
        component.set("v.bShowPhone",false);
        helper.checkEmailValidity(component);  
    },
    showPhoneForm : function(component,event,helper){
        component.set("v.bShowPhone",true);
        component.set("v.bShowEmail",false);
         helper.checkPhoneValidity(component);    
    },*/
    formatPhoneNumber: function(component, event, helper) {
        var bSuper = component.find("bSuper");
        component.set("v.isDisabled",true); 
        var yourPhone = component.get("v.inputWrapper.yourPhone");
        if(yourPhone !== null && yourPhone !== '' && yourPhone !== undefined){
            var pattern = /^\d{10}$/;
            var PatternUSPhone = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
            if(PatternUSPhone.test(yourPhone)){
                component.set("v.isDisabled",false); 
                helper.checkPhoneValidity(component);   
            }
            else if(pattern.test(yourPhone)){
                var cleaned = ('' + yourPhone).replace(/\D/g, '');
                var match = cleaned.match(/^(1|)?(\d{3})(\d{3})(\d{4})$/);
                if (match) {
                    var intlCode = (match[1] ? '+1 ' : '');
                    yourPhone =   [intlCode, '(', match[2], ') ', match[3], '-', match[4]].join('');
                }
                component.set("v.inputWrapper.yourPhone",yourPhone); 
                component.set("v.isDisabled",false); 
                helper.checkPhoneValidity(component);   
            }
                else {
                    var errMsgforPhone = $A.get("$Label.c.RE_EntercorrectPhone");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsgforPhone);
                }
        } else {
            helper.checkPhoneValidity(component);
        }
        
        
        
        
        
    },
    checkifrightPhone : function(component){
        component.set("v.isDisabled",true); 
        var toPhone = component.get("v.inputWrapper.toPhone");
        if(toPhone !== null && toPhone !== '' && toPhone !== undefined){
           
            var PatternUSPhone = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
            if(PatternUSPhone.test(toPhone)){
                component.set("v.isDisabled",false); 
            }
        }
    }
    
})