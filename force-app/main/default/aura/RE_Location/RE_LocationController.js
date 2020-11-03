({
    doInit : function(component, event, helper) {
        
         var objLocation = {};
         component.set("v.Location", objLocation);
         var sPageURL = new URL(document.location.href);
         var sRecordId = sPageURL.searchParams.get("sRecordId"); //Specifically fetching the Resource Id
         component.set("v.sRecordID",sRecordId);
        //Lagan' changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getLocationDetails', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var sLocation = JSON.parse(response.objectData.result);
                    var lstStatusOptions = JSON.parse(response.objectData.lstStatusOptions);
                    component.set("v.lstStatusOptions", lstStatusOptions);
                    
                    var lstStateOptions = JSON.parse(response.objectData.lstStateOptions);
                    component.set("v.lstStateOptions", lstStateOptions);
                    
                    var lstTimeZoneOptions = JSON.parse(response.objectData.lstTimeZoneOptions);
                    component.set("v.lstTimeZoneOptions", lstTimeZoneOptions);
                    
                    if ( sLocation !== undefined) {
                        if(sLocation.sLanguage){
                            var array = sLocation.sLanguage.split(";");
                            component.set("v.lstLanguages",array);
                            
                        }
                        else{
                            component.set("v.lstLanguages",[]);
                        }
                        
                        if(sLocation.LocationType__c === 'Headquarters'){
                           component.set("v.bIsPrimary",true);
                         }
                        else{
                            component.set("v.bIsPrimary",false);
                        }
                        if(sLocation.sPointofContactPhone !== null && sLocation.sPointofContactPhone !== ''){
                            var formatedPhone = helper.formatPhoneNumber(component, sLocation.sPointofContactPhone);
                            sLocation.sPointofContactPhone = formatedPhone;
                        }
                         if(sLocation.phone !== null && sLocation.phone !== ''){
                            var formattedPhone = helper.formatPhoneNumber(component, sLocation.phone);                         
                            sLocation.phone = formattedPhone;
                        }
                       
                        if(sLocation.sDaysLocationClosed !== null && sLocation.sDaysLocationClosed !== ''){
                            var lstDaysLocClosed = sLocation.sDaysLocationClosed.split(";");
                           // console.log("lstDaysLocClosed is:"+lstDaysLocClosed);
                          //  console.log("lstDaysLocClosed is:"+lstDaysLocClosed);
                            for(var i=0;i<lstDaysLocClosed.length; i += 1){
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.monday')){
                                component.set("v.bIsMondayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.tuesday')){
                                component.set("v.bIsTuesdayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.wednesday')){
                                component.set("v.bIsWednesdayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.thursday')){
                                component.set("v.bIsThursdayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.friday')){
                                component.set("v.bIsFridayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.saturday')){
                                component.set("v.bIsSaturdayClosed",true);
                            }
                            if(lstDaysLocClosed[i] === $A.get('$Label.c.sunday')){
                                component.set("v.bIsSundayClosed",true);
                            }
                        }
                        }
                        
                        //component.set("v.Location",sLocation);
                        component.set("v.initialLocationObj",sLocation);
                        
                        component.set("v.Location", component.get("v.initialLocationObj"));
                        
                        helper.getFiles(component, event, helper);
                        helper.checkReadOnly(component);
                        
                        
                        /* Time format coversion logic - Commenting for sprint 7
                        var daysArr=['MondayOpen__c','MondayClose__c','TuesdayOpen__c','TuesdayClose__c','WednesdayOpen__c','WednesdayClose__c','ThursdayOpen__c','ThursdayClose__c','FridayOpen__c','FridayClose__c','SaturdayOpen__c','SaturdayClose__c','SundayOpen__c','SundayClose__c'];
                        for(var i=0;i<daysArr.length;i += 1){
  
                            var isotime=component.get("v.Location."+daysArr[i]);
                            
                            if(isotime){                                                     
                                component.set("v.Location."+daysArr[i],helper.dateConverter(isotime));  
                            }
                        }
                        */
                    }
                }
                else{
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.component_failure"));
                }
                
                
            },{
                "strRecordId": component.get("v.sRecordID")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        //Lagan's change end
        
       
    },
    
    openModel: function(component) {
        component.set("v.isOpen", true);
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },1000);
    },
    handleRemove: function(component) {
        component.set("v.isOpen", true);
        
    },
    addLanguage: function(component) {
        component.set("v.bAddLanguageInput", true);
        
    },
    
    saveLocUpdatedData: function(component, event, helper) {
        var unsavedData = component.find("unsaved");
        unsavedData.setUnsavedChanges(false);
                   
        var validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        // Release 1.1 Added By Kojashree
        var validPhone = component.find('stdPhone').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        var validEmail = component.find('stdemail').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        //RE_Release 1.1 – Defect 359098- Payal Dubela– Opertaing hour issue
        var valid= helper.validateInput(component,event,helper);
        var vaildHoursOfOperation = helper.validHoursOfOperation(component,event,helper);
        if(validForm && validPhone && validEmail && valid && vaildHoursOfOperation){
            
            helper.saveLocUpdatedData(component); 
        }
        else if(!validForm || !vaildHoursOfOperation){
            var toastEmailEvent = $A.get("e.force:showToast");  
            toastEmailEvent.setParams({
                "title": $A.get("$Label.c.errorstatus"),
                "message": $A.get('$Label.c.fill_required_fields'),
                "type"   : "error"
            });
            
            toastEmailEvent.fire();
            }
            
            
            
       
    },
    
    getFilesAfterUpload : function(component, event, helper) {
        var isFileUploadSuccess = event.getParam("isSuccess"); 
        if(isFileUploadSuccess){
            helper.getFiles(component);
        }
        
    },
    
    handleLangUpdateEvent: function(component, event) {
        var listSelectedLangs = event.getParam("listSelectedLangs");
        component.set("v.lstLanguages",listSelectedLangs);
        var sLanguagesSemicolonString ='';
        var i= 0;
        for(i=0;i < listSelectedLangs.length; i +=1){
            if(i !== (listSelectedLangs.length -1)){
                sLanguagesSemicolonString += listSelectedLangs[i] +';'
            }
            else{
                sLanguagesSemicolonString += listSelectedLangs[i];
            }
            
        }
        
        var sLocation = component.get("v.Location");
        sLocation.sLanguage = sLanguagesSemicolonString;
        component.set("v.Location",sLocation);
    },
    //Open File onclick event  
    OpenFile :function(component,event){  
        var rec_id = event.currentTarget.id;  
        $A.get('e.lightning:openFiles').fire({ //Lightning Openfiles event  
            recordIds: [rec_id] //file id  
        });  
    },
    
    deleteFile: function(component, event, helper) {
        var bReadOnly = component.get("v.bMakeReadOnly");
        if(!bReadOnly){  
            helper.deleteFileHelper(component,event,helper);  
        }
        
    },
    
    backToOrgDetails : function() {
        
        /*
        var oldLocationArray = component.get("v.initialLocationObj");
        var sLocationArray = component.get("v.Location");
       
        var newUrl;
        var loc; 
        
        if( oldLocationArray.PointOfContactName__c !== sLocationArray.PointOfContactName__c
           || oldLocationArray.PointofContactEmail__c !== sLocationArray.PointofContactEmail__c 
           || oldLocationArray.PointofContactPhone__c !== sLocationArray.PointofContactPhone__c
           || oldLocationArray.SpecialLocationInstructions__c !== sLocationArray.SpecialLocationInstructions__c
           || oldLocationArray.TransportationInstructions__c !== sLocationArray.TransportationInstructions__c
           || oldLocationArray.ParkingInstructions__c !== sLocationArray.ParkingInstructions__c
           || oldLocationArray.SpecialAnnouncements__c !== sLocationArray.SpecialAnnouncements__c
           //|| oldLocationArray.AnnouncementStatus__c !== sLocationArray.displayAnnouncementNew
           || oldLocationArray.Language__c !== sLocationArray.Language__c)
        {
            
            var confirmBackWithoutSaving = confirm("You have unsaved changes. Are you sure you want to leave the page?");
            
            if(confirmBackWithoutSaving){
              
                newUrl = 'organization-details' ;
                loc = null;
                try{
                    loc = window.location;
                }
                catch(e){
                }
                if(undefined === loc){
                    
                    this.navigateToUrl(component,event,newUrl, true);
                }
                else {
                    loc.href = newUrl;
                }
            } 
            
            
        }
        else{
            
            newUrl = 'organization-details' ;
            loc = null;
            try{
                loc = window.location;
            }
            catch(e){
                
            }
            if(undefined === loc){
                
                this.navigateToUrl(component,event,newUrl, true);
            }
            else {
                loc.href = newUrl;
            }
        } */
         var sPageURL = decodeURIComponent(document.URL);
        var baseURL = sPageURL.split("locationdetails")[0]; //Split by ? so that you get the key value pairs separately in a list
        var urlEvent = $A.get("e.force:navigateToURL");
        
        urlEvent.setParams({
            "url": baseURL +"organization-details"
        });
        urlEvent.fire();
        
    },
    
    /**
     * Redirects the page to passed url.
     * @param url URL to navigate
     * @param isredirect Indicates that the new URL should replace the current one in the navigation history. Defaults to false.
     */
    navigateToUrl : function(component,event,url, isredirect) {
        /*if(undefined == isredirect){
            isredirect = false;
        }*/
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url,
            isredirect : isredirect !== undefined ? isredirect : false
        });
        urlEvent.fire();
    },
    
    
    valueChanged : function(component) {
        
        var bFirstChange = component.get("v.bFirstChange");
        
        if(!bFirstChange){
            
            var unsavedInIf = component.find("unsaved");
            unsavedInIf.setUnsavedChanges(false);
            component.set("v.bFirstChange",true);
        }
        
        
        
    },
    
    
    //Release 1.1 Updated By Kojashree
        formatPhoneNumber: function(component, event, helper) {
        
        var objWrapper = component.get("v.Location");
        var phonePOC = objWrapper.sPointofContactPhone;
        var formatedPhone1 = helper.formatPhoneNumber(component, phonePOC);
        // formatedPhone = formatedPhone.replace(/^0+/, '');
        objWrapper.sPointofContactPhone = formatedPhone1;
        
        var phone = objWrapper.phone;
        var formattedPhone2 = helper.formatPhoneNumber(component,phone);
        objWrapper.phone = formattedPhone2;

        var phoneExtn = objWrapper.sPointofContactPhoneExt;
        var formattedPhoneExtn = helper.formatPhoneNumber(component,phoneExtn);
        objWrapper.sPointofContactPhoneExt = formattedPhoneExtn;
        
        component.set("v.Location", objWrapper);
        
    },
    onCloseOfAParticularDay : function(component) {
        var loc=component.get("v.Location");
        if(component.get("v.bIsMondayClosed")){
            loc.tMondayOpen = null;
            loc.tMondayClose = null;
        }
        
        if(component.get("v.bIsTuesdayClosed")){
            loc.tTuesdayOpen=null;
            loc.tTuesdayClose=null;
        }
        
        if(component.get("v.bIsWednesdayClosed")){
            loc.tWednesdayClose=null;
            loc.tWednesdayOpen=null;
        }
        
        if(component.get("v.bIsThursdayClosed")){
            loc.tThursdayOpen=null;
            loc.tThursdayClose=null;
        }
        
        if(component.get("v.bIsFridayClosed")){
            loc.tFridayClose=null;
            loc.tFridayOpen=null;
        }
        if(component.get("v.bIsSaturdayClosed")){
            loc.tSaturdayClose=null;
            loc.tSaturdayOpen=null;
        }
        
        if(component.get("v.bIsSundayClosed")){
            
            loc.tSundayOpen=null;
            loc.tSundayClose=null;
        }
        
        component.set("v.Location",loc);
    },
})