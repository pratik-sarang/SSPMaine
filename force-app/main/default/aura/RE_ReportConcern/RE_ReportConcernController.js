({
    doInit : function(component, event, helper) {
        helper.fetchPicklistValues(component,event,helper);
        helper.fetchData(component);
        helper.getParam(component);
        var statusobj=[];
        //statusobj.push({ Name: "Address", Id: "Address"});
        statusobj.push({ Name: "Facility Conditions", Id: "Facility Conditions"});
        statusobj.push({ Name: "Facility Staff", Id: "Facility Staff"});
      //  statusobj.push({ Name: "Hours", Id: "Hours"});
       // statusobj.push({ Name: "Phone/Email", Id: "Phone/Email"});
        statusobj.push({ Name: "Other", Id: "Other"});
        
        
        
        component.set("v.categorylst", statusobj);
        
        /*var initialstatus=[];
        initialstatus.push({ Name: "New", Id: "New"});
        //   initialstatus.push({ Name: "In Progress - Org in System", Id: "In Progress - Org in System"});
        initialstatus.push({ Name: "In Progress", Id: "In Progress"});
        component.set("v.initialcategorylst", initialstatus); */
        component.set("v.bshowcategory", "true");
        
       // var bshowcaptcha=component.get("v.bshowcontactinfo");
      //  if(bshowcaptcha){
           window.addEventListener("message",function(evt){
            if(evt.data === "Unlock"){
                component.set("v.captchaStatus","Verified");
                //component.set("v.displayLoader",false);
                                
             
            }
            document.getElementsByClassName("iframe-captcha")[0].style.height="5rem";
            document.querySelectorAll(".iframe-captcha iframe")[0].style.height="8rem";
            if(evt.data === 'Loaded'){
                document.querySelectorAll(".iframe-captcha iframe")[0].style.height="40rem";
                document.getElementsByClassName("iframe-captcha")[0].style.height="40rem";
               // component.set("v.displayLoader",false);
            }
        },false);
        //}
        
        
    },
	
    
    handleSubmit : function(component,event,helper) {
         
        var valid=helper.validate(component,event,helper);
        
        if(valid){
       // var bshowcaptcha=component.get("v.bshowcontactinfo");
            var bshowcaptcha=component.get("v.bshowcontactinfo");
            var captchastatus=component.get("v.captchaStatus");
            if(bshowcaptcha && captchastatus==='Verified'){
       		helper.createReportConcern(component);
                component.set("v.bisSubmitted",true);
            }else if(bshowcaptcha && captchastatus!=='Verified'){
                helper.showToast(component, event, 'Error', $A.get("$Label.c.complete_captcha")); 
            }else if(!bshowcaptcha){
            	helper.createReportConcern(component);
                component.set("v.bisSubmitted",true);
            }
        	
        }
    },
    backToPreviouspage : function(component,event,helper){
        //check if there is entered data
      /*  var objWrapper = component.get("v.reportconcernObj");
        var category =component.get("v.selectedcategorylst");
        if(objWrapper.name || objWrapper.email || objWrapper.phone || objWrapper.details || category.length!==0){
            component.set("v.bshowModal",true);
        }
        else{
            helper.navigateBack(component,event,helper);
        }
        */
        helper.navigateBack(component,event,helper);
        /*var backURL= component.get('v.backToURL');
        //window.open('/s/client-one-view?referralid='+contactId,'_blank');
        window.open(backURL,'_self'); */
    },
    navigateBack : function(component,event,helper){
        
      helper.navigateBack(component,event,helper);
    },
    /* format phone number */
    formatPhoneNumber: function(component, event, helper) {
       // var objWrapper = component.get("v.referralObj");
        var objWrapper = component.get("v.reportconcernObj");
        var phone = objWrapper.phone;
     // var phone = component.get("v.userPhone");
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        objWrapper.phone = formatedPhone;
       // component.set("v.userPhone", formatedPhone);
       component.set("v.reportconcernObj", objWrapper);
       
    },
    validateEmail : function(component, event, helper){
        
        
        var objWrapper = component.get("v.reportconcernObj");
        var email = objWrapper.email;
        var isValid = helper.checkEmailValidity(component, event, email);
        if(isValid !== true){
            return false;
        }
        else{
            return true;
        }
    },
    handleStatusChange:function (component, event) {
        var fieldName = event.getSource().getLocalId();
        var changeValue = component.find(fieldName).get("v.value");
        
        var objWrapper = component.get("v.reportconcernObj");
       
         if(fieldName === 'identity'){
            objWrapper.identity = changeValue;
        }
        
    },
})