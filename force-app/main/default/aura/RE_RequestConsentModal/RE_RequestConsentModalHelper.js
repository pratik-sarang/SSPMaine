({
    doInit : function(component, event, helper) {
        component.set('v.isSpinnerActive',true);
        try{
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchClientDetails', function(response) {
                //hide spinner when server response received
                if(response.isSuccessful){
                    component.set("v.isModalOpen", true);
                    component.set('v.isSpinnerActive',false);
                    var clientDetails=response.objectData.objContact;
                    var consentDetails = response.objectData.objConsent;
                    var hasConsent = response.objectData.hasConsentToView;
                    var hasActiveConsent = response.objectData.hasActiveConsent;
                    var hideTextMSGBtn = response.objectData.hideSendTextBtn;

      				component.set("v.hideTextBtn",hideTextMSGBtn);
                    if(!hasActiveConsent){
                        component.set("v.hasNoActiveConsent",true);  
                    }
                    component.set("v.clientDetails",clientDetails);
                    component.set("v.consentDetails",consentDetails);
                    component.set("v.hasConsentToView",hasConsent);
                    component.set("v.hasActiveConsent",hasActiveConsent);
                    if(consentDetails.LastTextDate__c){
                        component.set("v.consentDetails.LastTextDate__c",helper.dateFormatConverter(component,consentDetails.LastTextDate__c));  
                    }
                    if(consentDetails.LastEmailDate__c){
                        component.set("v.consentDetails.LastEmailDate__c",helper.dateFormatConverter(component,consentDetails.LastEmailDate__c));  
                    }
                    if($A.util.isUndefinedOrNull(clientDetails)){
                        
                    }
                    
                }
                
            },{
                "strClientId" : component.get("v.clientId")
            },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    dateFormatConverter : function(component, consentDetailsDate){
        var lastTextDate="";
        if(consentDetailsDate){
            var date = new Date(consentDetailsDate);
            var year = date.getFullYear();
            var month = date.getMonth()+1;
            var dt = date.getDate();
            var hours=date.getHours();
            var minutes=date.getMinutes();
            var ampm="am";
            if (hours === 12) {
                ampm = 'pm';
            } else if (hours === 0) {
                hours = 12;
            } else if (hours > 12) {
                hours -= 12;
                ampm = 'pm';
            } 
            
            if(hours<10){
                hours="0"+hours; 
            }
            if(minutes<10){
                minutes="0"+minutes; 
            }
            
            if (dt < 10) {
                dt = '0' + dt;
            }
            if (month < 10) {
                month = '0' + month;
            }
            
            lastTextDate=(month+'/'+dt+'/'+year+' '+hours+':'+minutes+ampm);
            return lastTextDate;
        }
        return lastTextDate;
    },
    sendConsentText : function(component){
        var clientDetails = component.get("v.clientDetails");
        var consentDetails = component.get("v.consentDetails");
        var consentId;
        if(consentDetails !== undefined){
            consentId = consentDetails.Id;
        }

        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.sendConsentForText', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                component.set("v.isModalOpen", false);
                //to do
                if(response.isSuccessful){
                    var successMsg =$A.get("$Label.c.RE_SendConsentTextSuccessToast");
                    bSuper.showToast($A.get("$Label.c.successstatus"),"success", successMsg);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), "error", errMsg);
                }
            },{
                "objContact" : clientDetails,
                "strConsentId" : consentId
             },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    sendConsentEmail : function(component){
        var clientDetails = component.get("v.clientDetails");
        var consentDetails = component.get("v.consentDetails");
        var consentId;
        if(consentDetails !== undefined){
            consentId = consentDetails.Id;
        }
        

        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.sendConsentForEmail', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                component.set("v.isModalOpen", false);
                if(response.isSuccessful){
                    var successMsg =$A.get("$Label.c.RE_SendConsentEmailSuccessToast");
                    bSuper.showToast($A.get("$Label.c.successstatus"),"SUCCESS", successMsg);
                    var sPageURL = decodeURIComponent(document.URL);
                    
                    if(!component.get("v.isClientDetail")){
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": sPageURL
                        });
                        urlEvent.fire();
                    }else{
                        var cmpEvent = component.getEvent("CloseModalevent");
                            cmpEvent.setParams({
                            "closed":true,
                            "ClientId":component.get('v.clientId'),
                            "callDoInit":component.get("v.isIEESData") });                                    
                        cmpEvent.fire();
                    }
                    
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "objContact" : clientDetails,
                "strConsentId" : consentId
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    checkDataForConsent : function(component,event,helper){
        var isIEESData=component.get("v.isIEESData");
        if(!isIEESData){
            helper.sendEmailForConsent(component,event,helper);
        }else{
            try{ 
                var bSuper = component.find("bSuper"); 
                component.set('v.isSpinnerActive',true);
                //override the method in super class and write your own logic with the response received
                bSuper.callServer(component, 'c.createContactForIEESData', function(response) {
                    component.set('v.isSpinnerActive',false);
                    //hide spinner when server response received
                    if(response.isSuccessful){
                        var clientDetails=response.objectData.objContact;
                        component.set("v.clientDetails",clientDetails);
                        component.set("v.clientId",clientDetails.Id);
                        
                        helper.sendEmailForConsent(component,event,helper);
                    }else{
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                },{
                    "IEESData" : JSON.stringify(component.get("v.clientWrapper"))
                },false);
            }catch (e) {
                bSuper.consoleLog(e.stack, true);
            }
            
        }
        
    },
    sendEmailForConsent: function(component,event,helper){
        var clientDetails = component.get("v.clientDetails");
        if(clientDetails.Email){
            helper.sendConsentEmail(component, event, helper);
        }
        else{
            component.set("v.isModalOpen", false);
            component.set("v.bHasNoEmail", true);
        }
    },
    handleVerbalConsentHelper: function(component,event,helper){
        var isIEESData=component.get("v.isIEESData");
        if(!isIEESData){
            helper.redirectToVerbalConsent(component,event,helper);
        }else{
            try{ 
                var bSuper = component.find("bSuper"); 
                component.set('v.isSpinnerActive',true);
                //override the method in super class and write your own logic with the response received
                bSuper.callServer(component, 'c.createContactForIEESData', function(response) {
                    component.set('v.isSpinnerActive',false);
                    //hide spinner when server response received
                    if(response.isSuccessful){
                        var clientDetails=response.objectData.objContact;
                        component.set("v.clientDetails",clientDetails);
                        var consentDetails = response.objectData.objConsent;
                        component.set("v.consentDetails",consentDetails);
                        component.set("v.clientId",clientDetails.Id);
                        
                        helper.redirectToVerbalConsent(component,event,helper);
                    }else{
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                },{
                    "IEESData" : JSON.stringify(component.get("v.clientWrapper"))
                },false);
            }catch (e) {
                bSuper.consoleLog(e.stack, true);
            }
            
        }
        
    },
    redirectToVerbalConsent: function(component){
        var consentDetails = component.get("v.consentDetails");
        var consentId;
        if(consentDetails !== undefined){
            consentId = consentDetails.Id;
        }
        var clientId=component.get('v.clientId');
        var origin= component.get('v.sverbalConsentOrigin');
        var sPageURL = decodeURIComponent(document.URL);
        var baseURL = sPageURL.split("clients")[0]; 
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": baseURL + "verbal-consent?clientid="+clientId+"&consentId="+consentId+"&origin="+origin
        });
        urlEvent.fire();
        
    },
    getKogURL : function(component) { 
        try{
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.fetchKogURL', function(response) {
                    window.open(response.objectData.KogRegistrationURL,'_parent');
            },{},false);
        }catch (e) {
        }
    }
})