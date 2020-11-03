({
	getTableData : function(component,jsonData) {
		try{ 

            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getTableData', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);

                //to do 
                
                if(response.isSuccessful){

                  
                   var arrayMyResource =  JSON.parse(response.objectData.tabledata);

                   component.set('v.tableData',arrayMyResource);

                    var objectData = response.objectData.loggedinuserdata;
                    var parsedvalue = JSON.parse(objectData);
                    var Name=parsedvalue.FirstName+' '+parsedvalue.LastName;
                    component.set("v.userPhone",parsedvalue.Phone);
                    component.set("v.userEmail",parsedvalue.Email);
                    component.set("v.userName",Name);
                    
               
				}
                
                 else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast( $A.get("$Label.c.errorstatus"),  $A.get("$Label.c.errorstatus"), errMsg);
                }
			},{ strJsonData : jsonData
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
	},
    createColumnData:function(component){
        var columnsData=[];
        columnsData.push({ label: $A.get("$Label.c.organization"), fieldName: 'Organization', type: 'text'},
                         { label: $A.get("$Label.c.RE_Location"), fieldName: 'Location', type: 'text'},
                         { label: $A.get("$Label.c.RE_Resource"), fieldName: 'Resource', type: 'text'})
        component.set("v.coloumnsTableData",columnsData);
    },
    handleSubmitFromHelper :  function(component,jsonData) {
       
        var wrapObject = {};
        
        wrapObject.sClientId = component.get("v.contactId");
        wrapObject.sNotes =  component.get("v.notes");
        wrapObject.sPhone =  component.get("v.userPhone");
        wrapObject.sEmail =  component.get("v.userEmail");
        var jsonDataScreenVariables = JSON.stringify(wrapObject);
        
        var self = this;
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var clientId = component.get("v.contactId");
            var email = component.get("v.userEmail");
            var phone = component.get("v.userPhone");
            
            if(clientId !== undefined && clientId.length !==0 
               &&  email !== undefined && email.length !==0
                &&  phone !== undefined && phone.length !==0 ){
                //reference to inherited super component
                var bSuper = component.find("bSuper");  
                //override the method in super class and write your own logic with the response received
                bSuper.callServer(component, 'c.createReferrals', function(response) {
                    //hide spinner when server response received
                    component.set('v.isSpinnerActive',false);
                    
                    //to do 
                    
                    if(response.isSuccessful){
                        var result = response.objectData.referralexist;
                        var sizeRefcreated = response.objectData.NumberRefsCreated;
                       
                        if(sizeRefcreated > 0){
                          var successmsg;
                            if(component.get("v.bassessresult")){               
								              successmsg = $A.get("$Label.c.RE_Connected_Resource")+" "+component.get("v.clientName")+" "+ $A.get("$Label.c.to") +" "+sizeRefcreated +" "+ $A.get("$Label.c.RE_Resource")+(sizeRefcreated > 1 ? "s." : ".");
                            }else{
                              successmsg = $A.get("$Label.c.RE_Connected_Resource")+" "+component.get("v.selectedLookUpRecordContact.Name")+" "+ $A.get("$Label.c.to")+" "+sizeRefcreated +" "+$A.get("$Label.c.RE_Resource")+(sizeRefcreated > 1 ? "s." : ".");
                            }
                        	self.showToast(component, event, 'Success',successmsg);
                        }
                        
                        if(result.length > 0){
                            var sResourcesString ='';
                            for(var i=0;i < result.length; i +=1){
                                if(i !== result.length -1){
                                    sResourcesString +='[' + result[i] + '], ';
                                }
                                else {
                                    sResourcesString +='[' + result[i] + ']';
                                }
                            }
                        
                        
                        	var msg = $A.get("$Label.c.RE_Duplicate_referral_error") +sResourcesString;
                        
                        	self.showToast(component, event,'Info' , msg);
                        }
                        
                        var compEvent = component.getEvent("backtoFavoritesScreen");
                        // set the Selected sObject Record to the event attribute.  
                        compEvent.setParams({"bBacktoBulkReferral" : "true"
                                            });  
        
                        compEvent.fire();
                        
                        var methodRef = component.get("v.methodRef");
                        $A.enqueueAction(methodRef);
                        
                    }
                },{ strJsonData : jsonData,
                   strScreenVariablesJson : jsonDataScreenVariables
                  },false);
            }else{
                var errMsg =  $A.get("$Label.c.RE_ClientDetails_error");
                this.showToast(component, event, $A.get("$Label.c.errorstatus"),errMsg);
                component.set('v.isSpinnerActive',false);
            }
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
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
            else if(variant === 'Info'){
                component.find('notifLib').showToast({
                "title": $A.get("$Label.c.RE_Info"),
                "message": msg,
                "variant": "Info"
            });
            }
    },
    validateInput : function(component, event, helper) {
        var objWrapper = component.get("v.referralObj");
        
        var allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        
        var phone =component.get("v.userPhone");
        if(!objWrapper.Contact || !objWrapper.Organization || !objWrapper.Location || !objWrapper.Resource || !objWrapper.Email || !phone){
            if(component.get("v.bshowClientLookup")){
                var contactemptymsg =  $A.get("$Label.c.contactemptymsg");  
                helper.showToast(component, event, 'Error', contactemptymsg);   
            }else{ 
                helper.showToast(component, event, 'Error', $A.get("$Label.c.referralcreationerror"));
            }
            return false;
        }
        else if (allValid === false){
            var emailphoneerror =  $A.get("$Label.c.emailphoneerror"); 
            helper.showToast(component, event, 'Error', emailphoneerror);   
            return false;
        }else{
            return true;
        }
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
    formatPhoneNumber: function(component, phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    
})