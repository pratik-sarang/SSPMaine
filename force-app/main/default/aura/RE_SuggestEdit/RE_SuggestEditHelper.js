({
    
    getParam : function(component) {
        var locationID = (this.getURLParam().locationId) ? atob(this.getURLParam().locationId) : ''; 
        var resourceID = (this.getURLParam().resourceId) ? atob(this.getURLParam().resourceId) : ''; 
        var resourceName = (this.getURLParam().resourceName) ? atob(this.getURLParam().resourceName) : ''; 
        var accountId = (this.getURLParam().accountId) ? atob(this.getURLParam().accountId) : ''; 
        var accountName = (this.getURLParam().accountName) ? atob(this.getURLParam().accountName) : ''; 
        var locationName = (this.getURLParam().locationName) ? atob(this.getURLParam().locationName) : ''; 
        var backToURL = (this.getURLParam().backURL) ? atob(this.getURLParam().backURL) : ''; 
        
        component.set('v.backToURL',backToURL);
        component.set('v.accountName',accountName);
        component.set('v.locationName',locationName);
        component.set('v.resourceName',resourceName);
        
        component.set('v.accountId',accountId);
        component.set('v.locationID',locationID);
        component.set('v.resourceID',resourceID);
        
        
        //var zipcode = (this.getURLParam().zipcode) ? atob(this.getURLParam().zipcode) : '';
        
        
        /* if(!$A.util.isUndefinedOrNull(resourceID) && resourceID !== '' && !$A.util.isUndefinedOrNull(locationID) && locationID !== '' && !$A.util.isUndefinedOrNull(zipcode) && zipcode !== ''){
            component.set("v.resourceId", resourceID);
            component.set("v.locationId", locationID); 
            component.set("v.zipcode", zipcode);
            component.set("v.myplanurl","/s/my-plan?sContactId="+contactId);
        }  */
        
    },
    getURLParam : function() {
        var query = location.search.substr(1);
        var result = {};
        if(query!==''){
            query.split("&").forEach(function(part) {
                var item = part.split("=");
                result[item[0]] = decodeURIComponent(item[1]);
            }); 
        }
        return result;   
    },
    
    fetchData : function(component) {
        
        try{ 
            //show spinner when request sent
            //component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchUserProfile', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
					var objectData = response.objectData.records;
                    var parsedvalue = JSON.parse(objectData);
                    var baseUrl= decodeURIComponent(window.location.href);
                    var optionSelected=baseUrl.split('/s/')[0];
                    var captchaURL = optionSelected + "/apex/RE_CaptchaV2";
                    component.set("v.captchaURL", captchaURL);
                    component.set("v.bshowcontactinfo", parsedvalue);
                    component.set("v.reportconcernObj.isGuest", parsedvalue);
                    
					/*var Name=parsedvalue.FirstName+' '+parsedvalue.LastName;
					component.set("v.userPhone",parsedvalue.Phone);
					component.set("v.referralObj.Email",parsedvalue.Email);
					component.set("v.referralObj.Name",Name); */
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR', 'ERROR', errMsg);
                }
            },{
                //"sRecordId": component.get("v.sRecordID")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    createReportConcern : function(component) {
        
        
        var objWrapper = component.get("v.reportconcernObj");
        objWrapper.accountid=component.get("v.accountId");
        objWrapper.locationid=component.get("v.locationID");
        objWrapper.resourceid=component.get("v.resourceID");
        
        objWrapper.category=JSON.stringify(component.get("v.selectedcategorylst"));
        
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.insertReportConcern', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    
                    var objectData = response.objectData.records;
                    var parsedData = JSON.parse(objectData);
                    //set the name here
                    component.set("v.refName", parsedData);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR', 'ERROR', errMsg);
                }
                
                
            },{
                "objwrapper": objWrapper
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        
        
    },
    validate : function(component,event,helper){
        var objWrapper = component.get("v.reportconcernObj");
        var category =component.get("v.selectedcategorylst");
        var allValid=true;
        var showcontact=component.get("v.bshowcontactinfo");
        if(showcontact){
         allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        }
        
        if(!objWrapper.details || category.length===0){
        helper.showToast(component, event, 'Error', $A.get("$Label.c.mandatoryfieldserror")); 
            return false;
        }else if (allValid === false){
            return false;
        }else{
            return true;
        }
    },
    showToast : function(component, event, variant, msg){
        if(variant === 'Success'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.successstatus"),
                "message": msg,
                "variant": "success"
            });
        }else if(variant === 'Error'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },
    navigateBack : function(component){
        
        var backURL= component.get('v.backToURL');
        //window.open('/s/client-one-view?referralid='+contactId,'_blank');
        window.open(backURL,'_self');
    },   
    formatPhoneNumber: function(component, phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    /* check eail validation */
    checkEmailValidity : function(component, event, OriginalEmailId) {
        var pattern = /^([a-zA-Z0-9_+-])+([a-zA-Z0-9_+.-])*\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9])+$/;
        var inputField = OriginalEmailId;
        var value = inputField.get('v.value');
        
        if(!pattern.test(value)){
            inputField.set('v.validity', {valid:false, badInput :true});
            inputField.showHelpMessageIfInvalid();
        }
    },  
    
    
})