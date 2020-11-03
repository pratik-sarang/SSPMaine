({
    /* fetch the picklist Values based on the API names */
    fetchPicklistValues : function(component) {
        try{ 
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            var flds = component.get("v.picklistValues");
            bSuper.callServer(component, 'c.getPickListValues', function(response) {
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    var pickListFlds = flds.split(',');
                    var result = response.objectData.picklistvalues;
                    for( var index in pickListFlds){
                        if (pickListFlds.hasOwnProperty(index)) {
                            var options = [];
                            var keys = Object.keys(result[pickListFlds[index]]);
                            for(var i in keys){
                                if (keys.hasOwnProperty(i)) {
                                options.push({ class: "optionClass", 
                                              label: keys[i], 
                                              value: result[pickListFlds[index]][keys[i]] 
                                             });
                                }
                            }
                            if(pickListFlds[index] === "TrainingLevel__c"){
                                component.set("v.traininglevel", options);   
                            }else if(pickListFlds[index] === "PermissionsLevel__c"){
                                component.set("v.permissionlevel", options);
                            }else if(pickListFlds[index] === "Status__c"){
                                component.set("v.status", options);
                            }
                        }
                    }
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);                }
            },{
                "strObjectName":'Contact',
                "strLstFields": component.get("v.picklistValues")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    /* Initialize the wrapper */
    initializeWrapper : function(component) {
        try{ 
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            var recId = component.get("v.recId");
            bSuper.callServer(component, 'c.getWrapper', function(response) {
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                    var objResponse = JSON.parse(response.objectData.userdata);
                    if(!$A.util.isUndefinedOrNull(objResponse) && !$A.util.isUndefinedOrNull(objResponse.Status)){
                         component.set("v.initialStatus",objResponse.Status);
                    }
                    if(!$A.util.isUndefinedOrNull(objResponse.Id)){
                        component.set("v.isEdit", true);
                    }
                    if((!$A.util.isUndefinedOrNull(objResponse.userdata) && objResponse.userdata.length !== 0)||objResponse.isUserActive===false){
                        component.set('v.objwrapper', objResponse);   
                        if(objResponse.bIsAdmin === true ){ 
                            component.set("v.userdata", objResponse.userdata);
                            if(objResponse.PermissionsLevel !== null){
                                var permissionlevel = component.get("v.permissionlevel");
                                for(var index in permissionlevel){
                                    if (permissionlevel.hasOwnProperty(index)) {
                                        if(permissionlevel[index].value === objResponse.PermissionsLevel){
                                            permissionlevel[index].selected = true;
                                            component.set("v.bDisplayTrainingComplete", true);
                                        }
                                    }
                                }
                                component.set("v.permissionlevel", permissionlevel);
                            }
                            if(objResponse.Status !== null){
                                var status = component.get("v.status");
                                for(var m in status){
                                    if(status[m].value === objResponse.Status){
                                        status[m].selected = true;
                                    }
                                }
                                component.set("v.status", status);
                            }
                            if(objResponse.TrainingLevel !== null){
                                if(objResponse.TrainingLevel === 'Complete'){
                                    component.set("v.trainingComplete", true);
                                }else{
                                    component.set("v.trainingComplete", false);
                                }
                            }
                            var options = [];
                            for(var n in objResponse.lstLocations){
                                if(objResponse.lstLocations[n].Id === objResponse.PrimaryLocation){
                                    options.push({
                                        class: "optionClass",
                                        label: objResponse.lstLocations[n].Name,
                                        value: objResponse.lstLocations[n].Id,
                                        selected: true
                                    });
                                }else{
                                    options.push({
                                        class: "optionClass",
                                        label: objResponse.lstLocations[n].Name,
                                        value: objResponse.lstLocations[n].Id
                                    });
                                }
                            }
                            component.set("v.primarylocation", options);
                        }else{
                            var errMsg = $A.get("$Label.c.servererror");
                            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                        }
                    }else{
                        var errMsg1 = $A.get("$Label.c.RE_NoUserForContact");;
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg1);
                        
                    }
                    
                }else{
                    var errMsg2 = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg2);
                    
                }
            },{
                "strContactId" : recId
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
        /* submit action */
    submitHandler : function(component, event, helper) {
            try{ 
                component.set('v.displayLoader',true);
                var bSuper = component.find("bSuper"); 
                var formdata = component.get("v.objwrapper");
                formdata.Id = component.get("v.recId");
                formdata.TrainingLevel = (formdata.TrainingLevel) ? formdata.TrainingLevel : $A.get("$Label.c.notcomplete");
                bSuper.callServer(component, 'c.upsertContact', function(response) {
                    component.set('v.displayLoader',false);
                    if(response.isSuccessful){
                        var userdata = component.get("v.userdata");
                        // for user update
                        if(!$A.util.isEmpty(component.get("v.recId")) && !$A.util.isUndefinedOrNull(userdata)){
                            helper.updateUser(component, event, helper,component.get("v.objwrapper"), userdata[0].Id )
                        }else{ // contact insert
                            var successMsg = $A.get("$Label.c.teammembersuccessmsg");
                            bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                        helper.closeEditModal(component);
                        }
                    }else{
                        var errMsg;
                        component.set("v.clicked", false);
                        var duplicateError = $A.get("$Label.c.contactmatchfounderror");
                        if(response.mapErrorInfo.error.indexOf(duplicateError) > -1){
                            errMsg = $A.get("$Label.c.contactmatchfounderror");
                        }else{
                            errMsg = $A.get("$Label.c.servererror");
                        }
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                    
                },{
                    "objWrapper" : formdata, 
                    "bIsUpdate" : ($A.util.isEmpty(component.get("v.recId"))) ? false : true
                },false);
            }catch (e) {
                bSuper.consoleLog(e.stack, true);
            }
    },
    /* close the Modal */
    closeEditModal : function(component){
        component.find("editmodal").destroy();
        var closebtn = component.getEvent("CloseModalEvt");
        closebtn.setParams({"closeModal" : false, "sObjectName" :"Contact"});
        closebtn.fire();
    },
    /* format phone number */
    formatPhoneNumber: function(component, phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    /* validate the form inputs */
    validateInputs : function(component, formdata) {
      //  var formdata = component.get("v.objwrapper"); //20Dec LV issue
        var allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var validationError = false;
		//var inputFieldPhone = component.find("required_fldPhone");				
        var inputFieldPhoneVal = component.find("required_fldPhone").get("v.value");		
        		
        if(inputFieldPhoneVal !== null){		
            var checkPh = this.checkPhoneValidity(component, event,inputFieldPhoneVal);		
            if(checkPh){		
                validationError = false;		
            }else{		
                validationError = true;		
            }			
        }
        if(formdata.FirstName === null  || formdata.LastName === null 
           || formdata.Email === null || formdata.Status === null 
           || formdata.Phone === null || formdata.PermissionsLevel === null 
           || formdata.PrimaryLocation === null){
            validationError = true;
        }else{
            if($A.util.isEmpty(formdata.FirstName.trim()) || $A.util.isEmpty(formdata.LastName.trim()) 
               ||$A.util.isEmpty(formdata.Email.trim()) || $A.util.isEmpty(formdata.Status.trim()) 
               ||$A.util.isEmpty(formdata.Phone.trim()) || $A.util.isEmpty(formdata.PermissionsLevel.trim()) 
               ||$A.util.isEmpty(formdata.PrimaryLocation.trim())){
                validationError = true;
            }
        }
        if(allValid === false){
            validationError = true;
        }
        return validationError;
    },
   /* display toast messages */
    displayToastMessage : function(component, title, msg, variant) {
        component.find('notifLib').showToast({
                    "title": title,
                    "message": msg,
                    "variant": variant
                });
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
    checkPhoneValidity : function(component, event, inputFieldPhoneVal) {
        var bSuper = component.find("bSuper"); 
        var pattern1 =/^(\([0]{3}\) |[0]{3}-)[0]{3}-[0]{4}$/ ;
        var phoneValCorrect;
        var errMsg;
        if(pattern1.test(inputFieldPhoneVal)){
             phoneValCorrect = false;
             errMsg = $A.get("$Label.c.InvalidPhoneValue");                
             bSuper.showToast('Error', 'Error', errMsg);
             //exit;
        }
        else{
            var pattern2 = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
            if(pattern2.test(inputFieldPhoneVal)){
                phoneValCorrect = true;
            }else{
                phoneValCorrect = false;
            }
        }
        return phoneValCorrect;
    },   
    
    /* update user */
    updateUser : function(component, event, helper, contact, userId) {
        try{ 
            component.set('v.displayLoader',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.updateUser', function(response) {
                component.set('v.displayLoader',false);
                if(response.isSuccessful){
                    var successMsg = $A.get("$Label.c.teammembersuccessmsg");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                    helper.closeEditModal(component);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "userId" : userId,
                "objWrapper" : contact
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        } 
    },
    /* update user active/inactive flag */
    updateUserStatus : function(component){
        try{ 
            //show spinner when request sent
            component.set('v.displayLoader',true);
            var formdata = component.get("v.objwrapper");
            formdata.Id = component.get("v.recId");
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.updateUserStatusToActive', function(response) {
                component.set('v.displayLoader',false);
                if(!response.isSuccessful){
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "strContactId" : formdata.Id
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },

    bSuper:{}
    
})