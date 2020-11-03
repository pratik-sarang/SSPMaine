({
    doInitHandler : function(component, event, helper) {
        var url_string = window.location.href;
        var url = new URL(url_string);
        var resourceId = url.searchParams.get("sResourceId");
        component.set("v.sResourceId",resourceId);
        var resourceLocationId = url.searchParams.get("reslocId");
        var sRecordId = resourceLocationId === null ? resourceId : resourceLocationId; 
        //var sRecordId = sPageURL.split('sResourceId=')[1] === undefined ? sPageURL.split('reslocId=')[1] : sPageURL.split('sResourceId=')[1]; 
        //var sRecordId = sPageURL.split('resourceId=')[1]; 
        component.set("v.sResourceId",sRecordId);
        sRecordId=component.get("v.sResourceId");
        var formatedPhone;
       // debugger;
        try{ 
            if(sRecordId !== null && sRecordId !== '' && sRecordId !== undefined){
                component.set('v.isSpinnerActive',true);
                
                var bSuper = component.find("bSuper"); 
                bSuper.callServer(component, 'c.getResourceLocationDetails', function(response) {
                    component.set('v.isSpinnerActive',false);
                    if(response.isSuccessful){
                        var sLocationResource = JSON.parse(response.objectData.result);
                        if(response.objectData.isAdminUser || response.objectData.isAgencyUser){
                            component.set("v.bMakeReadOnly",true); 
                        }
                        component.set("v.LocationResource",sLocationResource);

                            if(sLocationResource.sDaysLocationClosed !== null && sLocationResource.sDaysLocationClosed !== ''){
                                var lstDaysLocClosed = sLocationResource.sDaysLocationClosed.split(";");
                                for(var i=0;i<lstDaysLocClosed.length; i += 1){
                                    if(lstDaysLocClosed[i] === "Monday"){
                                        component.set("v.bIsMondayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Tuesday"){
                                        component.set("v.bIsTuesdayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Wednesday"){
                                        component.set("v.bIsWednesdayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Thursday"){
                                        component.set("v.bIsThursdayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Friday"){
                                        component.set("v.bIsFridayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Saturday"){
                                        component.set("v.bIsSaturdayClosed",true);
                                    }
                                    if(lstDaysLocClosed[i] === "Sunday"){
                                        component.set("v.bIsSundayClosed",true);
                                    }
                        		}
                    		 }
                        
                        if ( sLocationResource !== undefined) {
                            var selectedAgeServedlst;
                            if(!$A.util.isUndefinedOrNull(sLocationResource.slocationResAgesServed)){
                                selectedAgeServedlst = sLocationResource.slocationResAgesServed.split(';'); 
                                component.set("v.agesServedSelectedList", selectedAgeServedlst);
                            }
                            
                       
                            if(resourceLocationId === '' || resourceLocationId === null || resourceLocationId === undefined){
                                component.set("v.check",true);
                            }else{
                                 //component.set("v.LocationResource.slocationResOffering",sLocationResource.slocationResOffering);
                            
                                 component.set("v.check", false);
                            }
                            
                            if(sLocationResource.slocationResFirstPOCPhone !== null && sLocationResource.slocationResFirstPOCPhone !== ''){
                                formatedPhone = helper.formatPhoneNumber(component, sLocationResource.slocationResFirstPOCPhone);                            
                                sLocationResource.slocationResFirstPOCPhone = formatedPhone;
                            }
                            if(sLocationResource.slocationResSecondPOCPhone !== null && sLocationResource.slocationResSecondPOCPhone !== ''){
                                formatedPhone = helper.formatPhoneNumber(component, sLocationResource.slocationResSecondPOCPhone);                            
                                sLocationResource.slocationResSecondPOCPhone = formatedPhone;
                            }
                            if(sLocationResource.slocationResPhone !== null && sLocationResource.slocationResPhone !== ''){
                                formatedPhone = helper.formatPhoneNumber(component, sLocationResource.slocationResPhone);                            
                                sLocationResource.slocationResPhone = formatedPhone;
                            }
                        }
                    }
                },
                                  { 
                                      "strRecordId": sRecordId
                                  },false);
            }
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        
    },
   
    addLocationResourceDetails : function(component){
       // component.set("v.LocationResource.slocationResStatus","Active");
        var lookupval  = component.get("v.selectedLookUpRecord");
        var loc = component.get("v.LocationResource");
        component.set("v.LocationResource.slocationResOffering",lookupval.Id);
        if($A.util.isUndefinedOrNull(loc.slocationResStatus)){
            loc.slocationResStatus = 'Active';
        }
        if($A.util.isUndefinedOrNull(loc.slocationResTimeZone)){
            loc.slocationResTimeZone = 'EST';
        }
        //debugger;
        
        var DaysLocationsClosed = [];
        if(component.get("v.bIsMondayClosed")){
            DaysLocationsClosed.push("Monday");
        }
        if(component.get("v.bIsTuesdayClosed")){
            DaysLocationsClosed.push("Tuesday");
        }
        if(component.get("v.bIsWednesdayClosed")){
            DaysLocationsClosed.push("Wednesday");
        }
        if(component.get("v.bIsThursdayClosed")){
            DaysLocationsClosed.push("Thursday");
        }
        if(component.get("v.bIsFridayClosed")){
            DaysLocationsClosed.push("Friday");
        }
        if(component.get("v.bIsSaturdayClosed")){
            DaysLocationsClosed.push("Saturday");
        }
        if(component.get("v.bIsSundayClosed")){
            DaysLocationsClosed.push("Sunday");
        }
        
        loc.sDaysLocationClosed = DaysLocationsClosed.join(';');
        component.set("v.LocationResource.sDaysLocationClosed",loc.sDaysLocationClosed);
        var agesServed = component.get("v.selectedRecords");
        component.set("v.LocationResource.slocationResAgesServed",agesServed);
        
        var toastEvent = $A.get("e.force:showToast");
        var errMsg = $A.get("$Label.c.servererror");
        
        
        
        try{ 
            
            component.set('v.isSpinnerActive',true);
            
            
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.updateResourceLocation', function(response) {
                
                component.set('v.isSpinnerActive',false);
               // component.set("v.check", "true");
                if(response.isSuccessful){

                    toastEvent.setParams({  
                        "title": $A.get("$Label.c.successstatus"), 
                        "message": $A.get("$Label.c.RE_LocationResource"),
                        "type": "success"
                    });  
                    toastEvent.fire(); 
                    //Navigate to Resource Page
                    /*var resourceIdToRedirect = component.get("v.sResourceId");
                    var resId = component.get("v.LocationResource.sLocationResourceId");
                    var sPageURL = decodeURIComponent(document.URL);
                    var sRecordId = sPageURL.split('resourceId=')[1]; 
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/edit-resource?sResourceId="+resourceIdToRedirect
                    });
                    urlEvent.fire();*/
                    
                    var sPageURL = new URL(document.URL);
                    var sRecordId = sPageURL.searchParams.get("sResourceId") === undefined ? sPageURL.searchParams.get("reslocId") : sPageURL.searchParams.get("sResourceId");
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/edit-resource?sResourceId="+sRecordId
                    });
                    urlEvent.fire();

                }
                else{
                    toastEvent.setParams({  
                        "title": $A.get("$Label.c.errorstatus"),  
                        "message": errMsg,
                        "type": "error"
                    });  
                    toastEvent.fire(); 
                } 
                
                
            },{
                "locRes": JSON.stringify(loc),
                "resID": component.get("v.sResourceId")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    validateLookupValues : function(component){
        var loc=component.get("v.LocationResource");
        var locValue = component.find("resLocError");
        if($A.util.isUndefinedOrNull(loc.slocationResOffering)){
            $A.util.removeClass(locValue,"slds-hide");
            component.set("v.csLookupRequired", true);
            return false;
        }else{
            $A.util.addClass(locValue,"slds-hide");
            return true;
        }
    },
    
    validHoursOfOperation : function(component){
        var loc=component.get("v.LocationResource");
        var monOpencheck = false;
        var monClosecheck = false;
        var monOpenError = component.find("monstarttime");
        var monCloseError = component.find("monendtime");
        
        var tueOpencheck = false;
        var tueClosecheck = false;
        var tueOpenError = component.find("tuestarttime");
        var tueCloseError = component.find("tueendtime");
        
        var wedOpencheck = false;
        var wedClosecheck = false;
        var wedOpenError = component.find("wedstarttime");
        var wedCloseError = component.find("wedendtime");
        
        var thursOpencheck=false;
        var thursClosecheck=false;
        var thursOpenError = component.find("thursstarttime");
        var thursCloseError = component.find("thursendtime");
        
        var friOpencheck=false;
        var friClosecheck=false;
        var friOpenError = component.find("fristarttime");
        var friCloseError = component.find("friendtime");
        
        
        var satOpencheck=false;
        var satClosecheck=false;
        var satOpenError = component.find("satstarttime");
        var satCloseError = component.find("satendtime");

        var sunOpencheck=false;
        var sunClosecheck=false;
        var sunOpenError = component.find("sunstarttime");
        var sunCloseError = component.find("sunendtime");
        //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue - Start
       //Monday Open Check
       if((!$A.util.isUndefinedOrNull(loc.tlocationResMondayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResMondayClose))){
            $A.util.removeClass(monCloseError,"slds-hide");
             monOpencheck= true;
        }else{
            $A.util.addClass(monCloseError,"slds-hide");
            monOpencheck = false;
        }
        //Monday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResMondayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResMondayClose))){
            $A.util.removeClass(monOpenError,"slds-hide");
            monClosecheck= true
        }else{
            $A.util.addClass(monOpenError,"slds-hide");
            monClosecheck = false;
        }
        //Thuesday open Check
        if((!$A.util.isUndefinedOrNull(loc.tlocationResTuesdayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResTuesdayClose))){
            $A.util.removeClass(tueCloseError,"slds-hide");
             tueOpencheck= true;
        }
        else{
            $A.util.addClass(tueCloseError,"slds-hide");
            tueOpencheck = false;
        }
        //Thuesday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResTuesdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResTuesdayClose))){
            $A.util.removeClass(tueOpenError,"slds-hide");
            tueClosecheck= true;
        }
        else{
            $A.util.addClass(tueOpenError,"slds-hide");
            tueClosecheck = false;
        }

        //Wednesday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tlocationResWednesdayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResWednesdayClose))){
            $A.util.removeClass(wedCloseError,"slds-hide");
             wedOpencheck= true;
        }
        else{
            $A.util.addClass(wedCloseError,"slds-hide");
            wedOpencheck = false;
        }
        //Wednesday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResWednesdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResWednesdayClose))){
            $A.util.removeClass(wedOpenError,"slds-hide");
            wedClosecheck= true
        }else{
            $A.util.addClass(wedOpenError,"slds-hide");
            wedClosecheck = false;
        }
        //Thrusday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tlocationResThursdayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResThursdayClose))){
            $A.util.removeClass(thursCloseError,"slds-hide");
             thursOpencheck= true;
        }else{
            $A.util.addClass(thursCloseError,"slds-hide");
            thursOpencheck = false;
        }
        //Thrusday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResThursdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResThursdayClose))){
            $A.util.removeClass(thursOpenError,"slds-hide");
            thursClosecheck= true
        }else{
            $A.util.addClass(thursOpenError,"slds-hide");
            thursClosecheck = false;
        }
        // Friday OpenCheck
        if((!$A.util.isUndefinedOrNull(loc.tlocationResFridayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResFridayClose))){
            $A.util.removeClass(friCloseError,"slds-hide");
             friOpencheck= true;
        }else{
            $A.util.addClass(friCloseError,"slds-hide");
            friOpencheck = false;
        }
        //Friday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResFridayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResFridayClose))){
            $A.util.removeClass(friOpenError,"slds-hide");
            friClosecheck= true
        }else{
            $A.util.addClass(friOpenError,"slds-hide");
            friClosecheck = false;
        }

        // Saturday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tlocationResSaturdayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResSaturdayClose))){
            $A.util.removeClass(satCloseError,"slds-hide");
             satOpencheck= true;
        }else{
            $A.util.addClass(satCloseError,"slds-hide");
            satOpencheck = false;
        }
        //Saturday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResSaturdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResSaturdayClose))){
            $A.util.removeClass(satOpenError,"slds-hide");
            satClosecheck= true
        }else{
            $A.util.addClass(satOpenError,"slds-hide");
            satClosecheck = false;
        }
        //Sunday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tlocationResSundayOpen)) && ($A.util.isUndefinedOrNull(loc.tlocationResSundayClose))){
            $A.util.removeClass(sunCloseError,"slds-hide");
             sunOpencheck= true;
        }else{
            $A.util.addClass(sunCloseError,"slds-hide");
            sunOpencheck = false;
        }
        //Sunday Close Check
        if(($A.util.isUndefinedOrNull(loc.tlocationResSundayOpen)) && (!$A.util.isUndefinedOrNull(loc.tlocationResSundayClose))){
            $A.util.removeClass(sunOpenError,"slds-hide");
            sunClosecheck= true
        }else{
            $A.util.addClass(sunOpenError,"slds-hide");
            sunClosecheck = false;
        }
        //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue - END
        if(monClosecheck || monOpencheck || tueOpencheck || tueClosecheck || wedOpencheck || wedClosecheck || thursOpencheck || thursClosecheck || friOpencheck || friClosecheck || satOpencheck || satClosecheck ||sunOpencheck || sunClosecheck){
            var toastEmailEvent = $A.get("e.force:showToast");  
               var errMsg = $A.get("$Label.c.mandatoryfieldserror");  
                toastEmailEvent.setParams({
                    "title": $A.get("$Label.c.errorstatus"),
                    "message": errMsg,
                    "type"   : "error"
                });
                
             toastEmailEvent.fire();
            return false;
        }
        else{
            return true;
        }
    },
    
    validateTimeInputs : function(component) {
        var loc=component.get("v.LocationResource");
        var moncheck=false;
        var tuescheck=false;
        var wedcheck=false;
        var thurscheck=false;
        var fricheck=false;
        var satcheck=false;
        var suncheck=false;
        
        if( loc.tlocationResMondayOpen !== null && loc.tlocationResMondayClose !== null){
            moncheck=loc.tlocationResMondayOpen>=loc.tlocationResMondayClose;
        }
        if( loc.tlocationResTuesdayOpen !== null && loc.tlocationResTuesdayClose !== null){
            tuescheck=loc.tlocationResTuesdayOpen>=loc.tlocationResTuesdayClose;
        }
        if( loc.tlocationResWednesdayOpen !== null && loc.tlocationResWednesdayClose !== null){
            wedcheck=loc.tlocationResWednesdayOpen>=loc.tlocationResWednesdayClose;
        }
        if( loc.tlocationResThursdayOpen !== null && loc.tlocationResThursdayClose !== null){
            thurscheck=loc.tlocationResThursdayOpen>=loc.tlocationResThursdayClose;
        }
        if( loc.tlocationResFridayOpen !== null && loc.tlocationResFridayClose !== null){
            fricheck=loc.tlocationResFridayOpen>=loc.tlocationResFridayClose;
        }
        if( loc.tlocationResSaturdayOpen !== null && loc.tlocationResSaturdayClose !== null){
            satcheck=loc.tlocationResSaturdayOpen>=loc.tlocationResSaturdayClose;
        }
        if( loc.tlocationResSundayOpen !== null && loc.tlocationResSundayClose !== null){
            suncheck=loc.tlocationResSundayOpen>=loc.tlocationResSundayClose;
        }
        
        if(moncheck || tuescheck || wedcheck || thurscheck || fricheck || satcheck || suncheck){
            var toastEmailEvent = $A.get("e.force:showToast");  
                toastEmailEvent.setParams({
                    "title": $A.get("$Label.c.errorstatus"),
                    "message": $A.get("$Label.c.RE_Loc_HoursofOperation"),
                    "type"   : "error"
                });
                
             toastEmailEvent.fire();
            return false;
        }
        else{
            return true;
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
    backToResource:function(component){
        /* Event is not used directly here, but navigateToURL Event is fired , Hence not Removed*/
        var resourceId = component.get("v.sResourceId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/our-resources?sResourceId="+resourceId
        });
        urlEvent.fire();
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
                            
                            var keys = Object.keys(result[pickListFlds[index]]);
                            for(var i in keys){
                                if(keys.hasOwnProperty(i)){
                                    options.push({ class: "optionClass", 
                                                  label: keys[i], 
                                                  value: result[pickListFlds[index]][keys[i]] 
                                                 });
                                }
                            }
                            if(pickListFlds[index] === "Status__c"){
                                component.set("v.lstStatusOptions", options);
                            }
                            if(pickListFlds[index] === "TimeZone__c"){
                                component.set("v.lstTimeZoneOptions", options);
                            }
                            if(pickListFlds[index] === "AgesServed__c"){
                                component.set("v.lstAgesServedOptions", options);
                            }
                            
                        }
                    }
                    component.set('v.LocationResource',response.objectData.objLocRes);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");;
                    bSuper.showToast('Error', 'Error', errMsg);
                    
                }
            },{
                "objectName":'LocationResource__c',
                "lstFields": flds                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }        
    },
    checkLocationResource : function(component,helper){
        var lookupval  = component.get("v.selectedLookUpRecord");     
        var toastEvent = $A.get("e.force:showToast");
        var errMsg = $A.get("$Label.c.servererror");
        try{ 
            
            component.set('v.isSpinnerActive',true);
            
            
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.checkResourceLocation', function(response) {
                
                component.set('v.isSpinnerActive',false);
                if(response.isSuccessful){
                 var isRecordFound=response.objectData.isRecordFound;
                 if(isRecordFound===true){
                    var dupLabel=$A.get("$Label.c.RE_DuplicateLocRes");
                    toastEvent.setParams({  "title": "Error",  "message": dupLabel,"type": "error"});  
                    toastEvent.fire();
                 }else{
                     helper.addLocationResourceDetails(component,event,helper);
                 }
                } else{
                    toastEvent.setParams({  
                        "title": $A.get("$Label.c.errorstatus"),  
                        "message": errMsg,
                        "type": "error"
                    });  
                    toastEvent.fire(); 
                }  
            },{
                "strLocId": lookupval.Id,
                "strRecID": component.get("v.sResourceId")
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

    }
})