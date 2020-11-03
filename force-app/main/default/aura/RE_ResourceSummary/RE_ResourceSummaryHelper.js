({
    doInitHandler : function(component) {
        var sPageURL = new URL(document.URL);
        var sRecordId = sPageURL.searchParams.get("sResourceId");
        if(!$A.util.isUndefinedOrNull(sRecordId)){
             component.set("v.resRecordId", sRecordId);
             component.set("v.hideLocationHeaderOnAddResource", true);
        }
        var recId = component.get("v.resRecordId");
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getResourceSummary', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                
                if(response.isSuccessful){                    
                    
                    component.set("v.summaryrecords", response.objectData.summarydata);
                    if(response.objectData.isAdminUser || response.objectData.isAgencyUser){
                        component.set('v.boolval',true);
                        } 
                    component.set("v.resourceRecordName", response.objectData.summarydata.Name);
                    
                    if(response.objectData.summarydata.resourceLocations.length !== 0){
                    	component.set("v.hasLocations",true);
                    }
                    else{
                        component.set("v.hasLocations",false);
                    }
                    component.set("v.resourceLocations", response.objectData.summarydata.resourceLocations);
                    var objrResponse = component.get("v.summaryrecords");
                    var selectedAgeServedlst;
                    if(!$A.util.isUndefinedOrNull(objrResponse.AgesServed)){
                        selectedAgeServedlst = objrResponse.AgesServed.split(';'); 
                    }
                    
                    var optList = [];
                    if(!$A.util.isUndefinedOrNull(selectedAgeServedlst)){
                        for(var i in selectedAgeServedlst){
                            if(selectedAgeServedlst.hasOwnProperty(i)){
                                optList.push({ class: "optionClass", 
                                              label: selectedAgeServedlst[i], 
                                              value: selectedAgeServedlst[i] 
                                             });
                            }
                        }
                    }
                    component.set("v.agesServedSelectedList", optList);
                    component.set("v.check", "true");
                    if(objrResponse.Status !== null){
                        var status = component.get("v.status");
                        for(var index in status){
                            if(status[index].value === objrResponse.Status){
                                status[index].selected = true;
                            }
                        }
                        component.set("v.status", status);
                    }
                }else{
                    var errMsg = '';
                    errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('Error', 'Error', errMsg);
                }
            },{
                "resourceRecId" : recId                
            },false);
        }catch (e) {
        }        
    },
    checkPhoneValidity : function(component, event,helper,phoneval) {
        var bSuper = component.find("bSuper"); 
        var pattern1 =/^(\([0]{3}\) |[0]{3}-)[0]{3}-[0]{4}$/ ;
        var phoneValCorrect;
        var errMsg;
        if(!$A.util.isUndefinedOrNull(phoneval) && phoneval !== ''){
        if(pattern1.test(phoneval)){
            phoneValCorrect = false;
            errMsg = $A.get("$Label.c.InvalidPhone");                
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
        }else{
            phoneValCorrect = true;
        }
        return phoneValCorrect;
       
       
    },   
    fetchPicklistValues : function(component) {
        var flds = component.get("v.picklistValues");
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getPickListValues', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){                    
                    var pickListFlds = flds.split(',');
                    var result = response.objectData.picklistvalues;
                    for( var index in pickListFlds){
                        if(pickListFlds.hasOwnProperty(index)){                    
                            var options = [];
                            // var obj = result[pickListFlds[index]];
                            var keys = Object.keys(result[pickListFlds[index]]);
                            for(var i in keys){
                                if(keys.hasOwnProperty(i)){
                                    options.push({ class: "optionClass", 
                                                  label: keys[i], 
                                                  value: result[pickListFlds[index]][keys[i]] 
                                                 });
                                }
                            }
                            if(pickListFlds[index] === "SdohDomain__c"){
                                component.set("v.sdohcategory", options);
                            }
                        }
                    }
                }else{
                    var errMsg = $A.get("$Label.c.servererror");;
                    bSuper.showToast('Error', 'Error', errMsg);
                    
                }
            },{
                "objectName":'Resource__c',
                "lstFields": flds                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }        
    },    
    saveData : function(component) {
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var oldval=component.get("v.summaryrecords");
            if($A.util.isUndefinedOrNull(oldval.Status)){
                oldval.Status='Active';
            }
            var summRecord = component.get("v.summaryrecords");
            var successMsg;
            if($A.util.isUndefinedOrNull(summRecord.Id)){
                 successMsg = $A.get("$Label.c.Create_Resource_Success_Message");
             }
             else{
               successMsg = $A.get("$Label.c.Update_Resource_Success_Message");
             }
                    
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 

            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateResourceDetails', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                var summRecords = component.get("v.summaryrecords");
                if(response.isSuccessful){                    
                    if(!$A.util.isUndefinedOrNull(response.objectData.updatedResourceID)){
                        summRecords.Id = response.objectData.updatedResourceID;
                    }
                    component.set("v.summaryrecords",component.get("v.summaryrecords"));
                    component.set("v.resourceRecordName", summRecords.Name);
                    component.set("v.resRecordId", summRecords.Id);
                   	component.set("v.hideLocationHeaderOnAddResource", true);
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                    
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast('Error', 'Error', errMsg);
                } 
            },{
                "strResourceInputs"	    :	JSON.stringify(component.get("v.summaryrecords")),
                "lstSelectedValues"	    :	JSON.stringify(component.get("v.selectedItems")),
                "lstUnselectedValues"	:	JSON.stringify(component.get("v.unselectedItems"))              
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }               
    },
    backToDataTable:function(component, event){
        /* Event is not used directly here, but navigateToURL Event is fired , Hence not Removed*/
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/our-resources"
        });
        urlEvent.fire();
    },
    validateInputs:function(component){
        var resrName = component.find("resName");
        var returnNameVal;
        //var returnDescVal;
        //var returnLocVal;
        var returnTaxVal;
        var returnDomainVal;        
        if(resrName.get("v.validity").valid) {
            returnNameVal = true;
        } else {
            resrName.showHelpMessageIfInvalid();
            returnNameVal = false;
        }
        /*
        var resrDesc = component.find("resDesc");
        if(resrDesc.get("v.validity").valid) {
            returnDescVal = true;
        } else {
            resrDesc.showHelpMessageIfInvalid();
            returnDescVal = false;
        } */
        
        var domain = component.find("sdohdomain");
        if(domain.get("v.validity").valid) {
            returnDomainVal = true;
        } else {
            domain.showHelpMessageIfInvalid();
            returnDomainVal = false;
        }      
        var summRecords = component.get("v.summaryrecords");
        
        var resrTax = component.find("resTaxerror");
        if($A.util.isUndefinedOrNull(summRecords.TaxonomyId)){
            $A.util.removeClass(resrTax,"slds-hide");
            component.set("v.csLookupRequired", true);
            returnTaxVal = false;
        }else{
            $A.util.addClass(resrTax,"slds-hide");
            returnTaxVal = true;
        }
        
        if(returnNameVal && returnTaxVal && returnDomainVal)/*returnDescVal && returnLocVal*/
            return true;
        else 
            return false;
    },
    formatPhoneNumber: function(component, phonenumber) {
        var phone = (""+phonenumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    }
})