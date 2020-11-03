({
    saveLocUpdatedData: function(component) {
         var loc = component.get("v.Location");
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
       
        component.set("v.Location.sDaysLocationClosed",loc.sDaysLocationClosed);
        
        var sLocation = JSON.stringify(component.get("v.Location"));
        var toastEvent = $A.get("e.force:showToast");
        var errMsg = $A.get("$Label.c.servererror");
        
        var displayAnnouncement =  component.find("displayAnnouncement").get("v.checked");
        //Lagan's changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.saveLocation', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    toastEvent.setParams({  
                        "title": $A.get("$Label.c.successstatus"),  
                        "message": $A.get("$Label.c.RE_LocDetails"),
                        "type": "success"
                    });  
                    toastEvent.fire(); 
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
                "strLocationJson": sLocation,
                "bDisplayAnnouncement": displayAnnouncement
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        
        
        //Lagan's changes end
        
       
    },
    
    getFiles : function(component){
        //Lagan's changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getFiles', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    
                    
                    var filesWrapper= response.objectData.lstFileWrapper;
                    if(filesWrapper !== undefined && filesWrapper !== null){
                        component.set("v.fileWrapperList",filesWrapper);
                        
                        
                    }
                }else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"),$A.get("$Label.c.errorstatus"), component_failure);
                }
                
                
            },{
                "strParentId": component.get("v.sRecordID")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        //Lagan's changes end
        
        
    },
    
    deleteFileHelper: function(component, event, helper) {
        var index = event.target.dataset.index;
        var selectedFile = component.get("v.fileWrapperList")[index];
        var component_failure = $A.get('$Label.c.component_failure');
        
        var sConDocId = selectedFile.objConDoc.Id; 
        //Lagan's changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.deleteFiles', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    helper.getFiles(component);
                }
                else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"),$A.get("$Label.c.errorstatus"), component_failure);
                }
            }
                              ,{
                                  "strContDocId": sConDocId
                                  
                              },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
       
        
    },
    dateConverter: function(isoTime) {
        var hours   = parseInt(isoTime.substring(0, 2), 10),
            minutes = isoTime.substring(3, 5),
            ampm    = 'am';    
        if (hours === 12) {
            ampm = 'pm';
        } else if (hours === 0) {
            hours = 12;
        } else if (hours > 12) {
            hours -= 12;
            ampm = 'pm';
        }       
        return hours + ':' + minutes + ' ' + ampm;
    },
    
    checkReadOnly : function(component) {
        //Lagan's changes
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.isReadOnly', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){ 
                    var bCanUpdate = response.objectData.canUpdate;
                    
                    
                    component.set("v.bMakeReadOnly",!bCanUpdate);
                }
                else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), component_failure);
                }
            }
                              ,{
                                  
                                  
                              },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
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
   
    validateInput : function(component) {
        var loc=component.get("v.Location");
        var moncheck=false;
        var tuescheck=false;
        var wedcheck=false;
        var thurscheck=false;
        var fricheck=false;
        var satcheck=false;
        var suncheck=false;
        var endtimegreater = $A.get('$Label.c.end_time_greater');
        
        if( loc.tMondayOpen !== null && loc.tMondayClose !== null){
            moncheck=loc.tMondayOpen>=loc.tMondayClose;
        }
        if( loc.tTuesdayOpen !== null && loc.tTuesdayClose !== null){
            tuescheck=loc.tTuesdayOpen>=loc.tTuesdayClose;
        }
        if( loc.tWednesdayOpen !== null && loc.tWednesdayClose !== null){
            wedcheck=loc.tWednesdayOpen>=loc.tWednesdayClose;
        }
        if( loc.tThursdayOpen !== null && loc.tThursdayClose !== null){
            thurscheck=loc.tThursdayOpen>=loc.tThursdayClose;
        }
        if( loc.tFridayOpen !== null && loc.tFridayClose !== null){
            fricheck=loc.tFridayOpen>=loc.tFridayClose;
        }
        if( loc.tSaturdayOpen !== null && loc.tSaturdayClose !== null){
            satcheck=loc.tSaturdayOpen>=loc.tSaturdayClose;
        }
        if( loc.tSundayOpen !== null && loc.tSundayClose !== null){
            suncheck=loc.tSundayOpen>=loc.tSundayClose;
        }
        
        
        if(moncheck || tuescheck || wedcheck || thurscheck || fricheck || satcheck || suncheck){
            var toastEmailEvent = $A.get("e.force:showToast");  
                toastEmailEvent.setParams({
                    "title": $A.get("$Label.c.errorstatus"),
                    "message": endtimegreater,
                    "type"   : "error"
                });
                
                toastEmailEvent.fire();
            return false;
        }
        else{
            return true;
        }
    },
    validHoursOfOperation : function(component){
        var loc=component.get("v.Location");
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
       if((!$A.util.isUndefinedOrNull(loc.tMondayOpen)) && ($A.util.isUndefinedOrNull(loc.tMondayClose))){
        $A.util.removeClass(monCloseError,"slds-hide");
         monOpencheck= true;
        }else{
            $A.util.addClass(monCloseError,"slds-hide");
            monOpencheck = false;
        }
        //Monday Close Check
        if(($A.util.isUndefinedOrNull(loc.tMondayOpen)) && (!$A.util.isUndefinedOrNull(loc.tMondayClose))){
            $A.util.removeClass(monOpenError,"slds-hide");
            monClosecheck= true
        }else{
            $A.util.addClass(monOpenError,"slds-hide");
            monClosecheck = false;
        }
        //Thuesday open Check
        if((!$A.util.isUndefinedOrNull(loc.tTuesdayOpen)) && ($A.util.isUndefinedOrNull(loc.tTuesdayClose))){
            $A.util.removeClass(tueCloseError,"slds-hide");
            tueOpencheck= true;
        }
        else{
            $A.util.addClass(tueCloseError,"slds-hide");
            tueOpencheck = false;
        }
        //Thuesday Close Check
        if(($A.util.isUndefinedOrNull(loc.tTuesdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tTuesdayClose))){
            $A.util.removeClass(tueOpenError,"slds-hide");
            tueClosecheck= true;
        }
        else{
            $A.util.addClass(tueOpenError,"slds-hide");
            tueClosecheck = false;
        }

        //Wednesday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tWednesdayOpen)) && ($A.util.isUndefinedOrNull(loc.tWednesdayClose))){
            $A.util.removeClass(wedCloseError,"slds-hide");
            wedOpencheck= true;
        }
        else{
            $A.util.addClass(wedCloseError,"slds-hide");
            wedOpencheck = false;
        }
        //Wednesday Close Check
        if(($A.util.isUndefinedOrNull(loc.tWednesdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tWednesdayClose))){
            $A.util.removeClass(wedOpenError,"slds-hide");
            wedClosecheck= true
        }else{
            $A.util.addClass(wedOpenError,"slds-hide");
            wedClosecheck = false;
        }
        //Thrusday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tThursdayOpen)) && ($A.util.isUndefinedOrNull(loc.tThursdayClose))){
            $A.util.removeClass(thursCloseError,"slds-hide");
            thursOpencheck= true;
        }else{
            $A.util.addClass(thursCloseError,"slds-hide");
            thursOpencheck = false;
        }
        //Thrusday Close Check
        if(($A.util.isUndefinedOrNull(loc.tThursdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tThursdayClose))){
            $A.util.removeClass(thursOpenError,"slds-hide");
            thursClosecheck= true
        }else{
            $A.util.addClass(thursOpenError,"slds-hide");
            thursClosecheck = false;
        }
        // Friday OpenCheck
        if((!$A.util.isUndefinedOrNull(loc.tFridayOpen)) && ($A.util.isUndefinedOrNull(loc.tFridayClose))){
            $A.util.removeClass(friCloseError,"slds-hide");
            friOpencheck= true;
        }else{
            $A.util.addClass(friCloseError,"slds-hide");
            friOpencheck = false;
        }
        //Friday Close Check
        if(($A.util.isUndefinedOrNull(loc.tFridayOpen)) && (!$A.util.isUndefinedOrNull(loc.tFridayClose))){
            $A.util.removeClass(friOpenError,"slds-hide");
            friClosecheck= true
        }else{
            $A.util.addClass(friOpenError,"slds-hide");
            friClosecheck = false;
        }

        // Saturday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tSaturdayOpen)) && ($A.util.isUndefinedOrNull(loc.tSaturdayClose))){
            $A.util.removeClass(satCloseError,"slds-hide");
            satOpencheck= true;
        }else{
            $A.util.addClass(satCloseError,"slds-hide");
            satOpencheck = false;
        }
        //Saturday Close Check
        if(($A.util.isUndefinedOrNull(loc.tSaturdayOpen)) && (!$A.util.isUndefinedOrNull(loc.tSaturdayClose))){
            $A.util.removeClass(satOpenError,"slds-hide");
            satClosecheck= true
        }else{
            $A.util.addClass(satOpenError,"slds-hide");
            satClosecheck = false;
        }
        //Sunday Open Check
        if((!$A.util.isUndefinedOrNull(loc.tSundayOpen)) && ($A.util.isUndefinedOrNull(loc.tSundayClose))){
            $A.util.removeClass(sunCloseError,"slds-hide");
            sunOpencheck= true;
        }else{
            $A.util.addClass(sunCloseError,"slds-hide");
            sunOpencheck = false;
        }
        //Sunday Close Check
        if(($A.util.isUndefinedOrNull(loc.tSundayOpen)) && (!$A.util.isUndefinedOrNull(loc.tSundayClose))){
            $A.util.removeClass(sunOpenError,"slds-hide");
            sunClosecheck= true
        }else{
            $A.util.addClass(sunOpenError,"slds-hide");
            sunClosecheck = false;
        }
        //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue - END
        if(monClosecheck || monOpencheck || tueOpencheck || tueClosecheck || wedOpencheck || wedClosecheck || thursOpencheck || thursClosecheck || friOpencheck || friClosecheck || satOpencheck || satClosecheck ||sunOpencheck || sunClosecheck){
            return false;
        }
        else{
            return true;
        }
    }

})