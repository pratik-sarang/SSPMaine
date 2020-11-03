({
	checkPhoneValidity: function(component, event, phoneval){		
	    var bSuper = component.find("bSuper"); 		
        var pattern1 =/^(\([0]{3}\) |[0]{3}-)[0]{3}-[0]{4}$/ ;		
        var phoneValCorrect;		
        var errMsg;		
        if(pattern1.test(phoneval)){		
             phoneValCorrect = false;		
             errMsg = $A.get("$Label.c.InvalidPhoneValue");                		
             bSuper.showToast('Error', 'Error', errMsg);
             //exit;
        }
        else{
            var pattern2 = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
            if(pattern2.test(phoneval)){
                phoneValCorrect = true;
            }else{
                phoneValCorrect = false;
            }
         }
        return phoneValCorrect;
     },
    phoneExtension: function(phoneExtVal){
        var phnExt;
         var pattern = /\d{3}/;
            if(pattern.test(phoneExtVal)){
                phnExt = true;
            }else{
                phnExt = false;
         }
        return phnExt;
    },
    getOrgDetail : function(component) {
        
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            var emptyObject = null;
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchOrganizationDetails', function(response) {
                component.set("v.showNoResults", false);
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    component.set("v.AccountRec", response.objectData.Account);
                 if(response.objectData.isAdminUser || response.objectData.isAgencyUser){
                        component.set('v.boolval',true);
                    }
                    component.set("v.StrAccValue",response.objectData.Account.Status__c);
                    
                    var custs = [];
                    var myJSON = JSON.stringify(response.objectData.Account.CountyServed__c);
                    if(myJSON!==undefined){
                        var val=myJSON.substring(1, myJSON.length-1);
                        var nameArr = val.split(';');
                        for(var key in nameArr){
                            if(nameArr.hasOwnProperty(key)){
                                custs.push(nameArr[key]);
                            }
                        }
                        component.set("v.showexistcountyvalues",custs);
                    }
                    else{
                        component.set("v.showexistcountyvalues",[]);
                    }
                    var picklistValues = response.objectData.AccountStatus;
                    // Siri: 3/5/2020: Spanish Translation
                    /*var index = picklistValues.indexOf("Inactive");
                    if(index > -1){
                        picklistValues.splice(index, 1);
                    }*/
                    var options = [];
                    
                    for(var i = 0; i < picklistValues.length; i++){
                        if(picklistValues[i].label === "Inactive")
                        {
                            picklistValues.splice(i,1);
                        }
                        if(response.objectData.Account.Status__c === picklistValues[i].value){
                            options.push({ class: "optionClass", 
                                          label: picklistValues[i].label, 
                                          value: picklistValues[i].value,
                                          selected : true
                                         });
                        }else{
                            options.push({ class: "optionClass", 
                                          label: picklistValues[i].label, 
                                          value: picklistValues[i].value
                                         });
                        }
                        
                    }
                    
                    component.set("v.picklistAccStatus", options);
                    component.set("v.AccountLocations",response.objectData.Locations);
                    component.set("v.LocationHead",response.objectData.LocationHeadQuarter);
                    component.set("v.listStateValues",response.objectData.stateValues);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);              }                
            },emptyObject,false);
        }catch (e) {
        }
    },

    
    updateOrgDetail : function(component) {
        
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateOrganizationDetail', function(response) {
                component.set("v.showNoResults", false);
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var successMsg =$A.get("$Label.c.RE_OrgDetailUpdated");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg); 
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);              }                
            },{
                "organizationRec": component.get("v.AccountRec"),
                "locationRec" : component.get("v.LocationHead")
            },false);
        }catch (e) {
        }
    },
    formatPhoneNumber: function(component, phonenumber) {
        var phone = (""+phonenumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    
    bSuper:{}
})