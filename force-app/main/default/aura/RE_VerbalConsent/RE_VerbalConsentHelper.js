({
    
    getParam : function(component) {
        //var backToURL = (this.getURLParam().origin) ? atob(this.getURLParam().origin) : ''; 
        //  component.set('v.backToURL',backToURL);
        //var sContactId = (this.getURLParam().clientid) ? atob(this.getURLParam().clientid) : ''; 
        var sContactId = (this.getURLParam().clientid) ? (this.getURLParam().clientid) : ''; 
        
        //console.log("sContactId is"+sContactId);
        component.set('v.conId',sContactId);
        //var sPageURL = decodeURIComponent(document.URL); 
        var consentId = this.getURLParam().consentId;        
        //console.log("consentId is",consentId);
        component.set("v.consentId",consentId);
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
    fetchconsent : function(component) {
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getConsents', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    // var retVal = response.getReturnValue();
                    var objectData = response.objectData.records;
                    var optionsList = [];
                    var additionalOptionsList = [];
                    for (var i =0; i< objectData.length ;i+=1)
                    {
                        if(objectData[i].isAdditionalOption)
                        {
                            additionalOptionsList.push(objectData[i]);
                        }else{
                            optionsList.push(objectData[i]);
                        }
                    }
                    component.set("v.options",optionsList);
                    component.set("v.additionalOptions",additionalOptionsList);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('Error', 'Error', errMsg);
                }
                
                
            },{
                //"sRecordId": component.get("v.sRecordID")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        
        
        
    },
    /* fetch the picklist Values based on the API names */
    fetchPicklistValues : function(component) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            
            var flds = component.get("v.picklistValues");
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getPickListValues', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var pickListFlds = flds.split(',');
                    var result = response.objectData.picklistvalues;
                    for(var index in pickListFlds){
                        if(pickListFlds.hasOwnProperty(index)){
                            var options = [];
                            var keys = Object.keys(result[pickListFlds[index]]);
                            
                            
                            for(var i in keys){
                                if(keys.hasOwnProperty(i)){
                                    options.push({ class: "optionClass", label: keys[i], value: result[pickListFlds[index]][keys[i]] });
                                }
                                
                            }
                            
                            if(pickListFlds[index] === "PreferredCommunicationMethod__c"){
                                component.set("v.communmap", options);   
                            }
                        }
                    }
                    
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','ERROR',errMsg);
                }
            },
                              {
                                  'objectName':'Contact',
                                  'lstFields': component.get("v.picklistValues")
                              },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    getContact : function(component,event,helper) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var errMsg;
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var conId = component.get("v.conId");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getContactDetails', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){                    
                    var objectData = response.objectData.records;
                    var objwrapper = JSON.parse(objectData);
                  if(!response.objectData.hasActiveConsent){                     
                    if(objwrapper.Phone){
                        var formatedPhone = helper.formatPhoneNumber(component,objwrapper.Phone);
                        objwrapper.Phone = formatedPhone;
                    }
                    
                    component.set('v.objwrapper', objwrapper); 
                    
                    if(objwrapper.CommunicationPref !== null){
                        var communmap = component.get("v.communmap");
                        for(var indexstatusmap in communmap){
                            if(communmap[indexstatusmap].value === objwrapper.CommunicationPref){
                                communmap[indexstatusmap].selected = true;
                            }
                        }
                        component.set("v.communmap", communmap);
                    }
                    component.set("v.consentToText",objwrapper.bConsentToText);

                    if(objwrapper.LoggedInUserName !== null){
                        component.set("v.LoggedInUserName",objwrapper.LoggedInUserName);
                    }
                }else{
                    errMsg=$A.get("$Label.c.Already_Active_Consent")+' '+objwrapper.ClientName;
                    bSuper.showToast($A.get("$Label.c.RE_Warning"),'Warning',errMsg);
                    var url='';
                    if(component.get("v.origin")==='clientoneview'){
                        url='/clients?clientId='+btoa(conId); 
                    }else{
                        url='/clients';
                    }
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": url
                    });
                    urlEvent.fire(); 
                }
                }
                else{
                    errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },
                              {
                                  'sContactId' : conId
                              },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   formatPhoneNumber()
* @description  This methods is used format phone number to US phone format (xxx) xxx-xxxx
********************************************************************/
    formatPhoneNumber: function(component, phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   handleSubmit()
* @description  This methods is used to check screen validations, and
				then insert the consent record, or update an already existing pending consent.
********************************************************************/
    handleSubmit : function(component,event) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var objWrap = component.get("v.objwrapper");
            //var phone = objWrap.Phone;
            
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var conId = component.get("v.conId");
            var consentId = component.get("v.consentId");
            var consentToTextValue = component.get("v.consentToText");

            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateConsentOnVerbalRequest', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){ 
                    //Fixing navigation after verbal consent submit(341852)
                    if(component.get("v.origin")==='clientoneview'){
                        window.open('clients?clientId='+btoa(conId),'_self'); 
                    }else{
                        window.open('clients','_self');
                    }                   
                    
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },
                              {
                'sConsentId' : consentId,
                                  'accessgiven' : true,
                'strContactId': conId,
                'strEmail' :objWrap.Email,
                'strPhone':objWrap.Phone,
                'strPrefComm':objWrap.CommunicationPref,
                                  'consentToText':consentToTextValue
                              },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    navigateBack : function(){        
        //var backURL= component.get('v.backToURL');
        //window.open('/s/clients?clientId='+contactId,'_self');
        //  window.open(backURL,'_self');
        window.open('clients','_self'); 
    }, 
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   handleChange()
* @description  This methods is used to submit the verbal consent form.
********************************************************************/
    handleChange: function(component,event,helper) {
        var sourceName = event.getSource().get('v.name');
        var valueArrayLength = event.getParam("value").length;
        component.set('v.bisAllChecked',false); 
        component.set('v.bDisableSubmitButton',true);
        if(sourceName === "Checkbox Group")
        {
            var optionArrayLength = component.get('v.options').length;
            component.set('v.isOptionsChecked',false);
            if(valueArrayLength === optionArrayLength)
            {
                component.set('v.isOptionsChecked',true);
            }
        }
        
        if(sourceName === "Additional Checkbox Group")
        {
            var additionalOptionArrayLength = component.get('v.additionalOptions').length;
            component.set('v.isAdditionalOptionsChecked',false);
            if(valueArrayLength === additionalOptionArrayLength)
            {
                component.set('v.isAdditionalOptionsChecked',true);
            }
        }
        
        var isOptionsChecked = component.get('v.isOptionsChecked');
        var isAdditionalOptionsChecked = component.get('v.isAdditionalOptionsChecked');
        if(isOptionsChecked && isAdditionalOptionsChecked)
        {
            component.set('v.bisAllChecked',true); 
            if(helper.checkValidForm(component,event,helper))
            {
            	component.set('v.bDisableSubmitButton',false); 
            }else
            {
            	component.set('v.bisAllChecked',false); 
            	component.set('v.bDisableSubmitButton',true);                 
        	}
        }
    },
    /*******************************************************************
* @author       Lagan Kankane
* @date         10/28/2019
* @methodname   checkValidForm()
* @description  This methods is used to check screen validations
********************************************************************/
    checkValidForm: function(component,event) {
        var validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        if(validForm && component.get('v.isOptionsChecked') && component.get('v.isAdditionalOptionsChecked')){
            component.set('v.bDisableSubmitButton',false); 
        }
        else{
            component.set('v.bDisableSubmitButton',true); 
        }
        return validForm;
    }
    
})