({
    doInit : function(component, event, helper) {
        
        var sPageURL = decodeURIComponent(document.URL); //You get the whole decoded URL of the page.
        var sRecordId = sPageURL.split('sRecordId=')[1];        
        component.set("v.sRecordID",sRecordId);
        helper.fetchInitData(component,event,helper);
        
        
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
    } ,

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
    
    createLoc: function(component, event, helper) {

         var validForm = component.find('requiredField').reduce(function (validSoFar, inputCmp) {
                // Displays error messages for invalid fields
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.get('v.validity').valid;
            }, true); 
        
        
        var vaildPhone = component.find('stdPhone').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
        
        var validEmail = component.find('stdemail').reduce(function (validSoFar, inputCmp) {
            // Displays error messages for invalid fields
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true); 
       
            //create a method to check the validation of the time entered start time and end time
            var valid= helper.validateInput(component,event,helper);
            var vaildHoursOfOperation = helper.validHoursOfOperation(component,event,helper);
            if(validForm && valid && vaildPhone && validEmail && vaildHoursOfOperation){
               
                helper.createLocation(component,event,helper); 
            }
             else if (!validForm || !vaildHoursOfOperation){
                var toastEmailEvent = $A.get("e.force:showToast");  
                toastEmailEvent.setParams({
                    "title": $A.get("$Label.c.errorstatus"),
                    "message": $A.get('$Label.c.fill_required_fields'),
                    "type"   : "error"
                });
                
                toastEmailEvent.fire();
            }
    },
    backToOrgDetails : function() {
       // var confirmBackWithoutSaving = confirm("You have unsaved changes. Are you sure you want to leave the page?");
        var sPageURL = decodeURIComponent(document.URL);
        var baseURL = sPageURL.split("newlocation")[0]; //Split by ? so that you get the key value pairs separately in a list
       // if(confirmBackWithoutSaving){
            var urlEvent = $A.get("e.force:navigateToURL");
            
            urlEvent.setParams({
                "url": baseURL +"organization-details"
            });
            urlEvent.fire();
     //   }
        
        
    },
    
    formatPhoneNumber: function(component, event, helper) {
        
        var objWrapper = component.get("v.Location");
        var phone = objWrapper.sPointofContactPhone;
        var formatedPhone = helper.formatPhoneNumber(component, phone);
        objWrapper.sPointofContactPhone = formatedPhone;
        
        var locPhone = objWrapper.phone;
        var formattedPhone2 = helper.formatPhoneNumber(component,locPhone);
        objWrapper.phone = formattedPhone2;
        
        component.set("v.Location", objWrapper);
        
    }
    
})