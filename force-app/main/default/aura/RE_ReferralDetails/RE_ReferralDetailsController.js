({
    init: function (component, event, helper) {
        helper.fetchPicklistValues(component,event,helper);
        helper.getReferral(component, event, helper);  
    },
    handleStatusChange:function (component, event) {
        var fieldName = event.getSource().getLocalId();
        var changeValue = component.find(fieldName).get("v.value");
        var objWrapper = component.get("v.objwrapper");
        if(fieldName === 'refstatus'){
            objWrapper.Status = changeValue;
            if(changeValue==='Closed'){
                component.set("v.bisstatuschange",true);
            }
        }else if(fieldName === 'assignedto'){
            objWrapper.OwnerId = changeValue;
        }else if(fieldName === 'feedbackstatus'){
            objWrapper.OutcomeReason = changeValue;
        }else if(fieldName === 'outcome'){
            objWrapper.Outcome = changeValue;
             
            if(changeValue==='Resource Not Provided')
            {
                component.set("v.showoutcomereason",true);
            }else{
                component.set("v.showoutcomereason",false);
            }
        }
        
        
       
    },
    handleAssignedChange:function (cmp) {
        cmp.set("v.assignedto",cmp.find("assignedto").get("v.value"));
    },
    
    hideEditModal:function (cmp ) {
        cmp.set("v.showEditModal",false);
    },
    showEditModal:function (cmp) {
        cmp.set("v.showEditModal",true);
        setTimeout(function(){//JAWS Fixes
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },500);
    },
    openFdbkModal:function (component, event, helper) {

        setTimeout(function(){//JAWS Fixes
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
         },500);
         
        var objWrapper = component.get("v.objwrapper");
       
        var showpopup=component.get("v.bisstatuschange");
        if(objWrapper.Status==='Closed' && showpopup){
            component.set("v.showFdbkModal",true);
        }
        else{
             var valid= helper.validateInput(component,event,helper);
        		if(valid){
            helper.updateReferral(component,event,helper);
            helper.backToDataTable(component, event, helper);
                }
        }
        
    },
    //RE_Release 1.2 – Lightning valuate - Payal Dubela 
    moveFocusToTop: function(component, event) {
        if(event.keyCode === 9) {
            setTimeout(function(){
                document.getElementsByClassName("modal-lg-heading")[0].focus(); 
            },10)
        }
    },
    closeFdbkModal:function (cmp) {
        cmp.set("v.showFdbkModal",false);
        //  cmp.set("v.showoutcomereason",false);  
    },
    handleFdbkSubmit:function (component, event, helper) {
        var valid= helper.validateInput(component,event,helper);
        if(valid){
        helper.updateReferral(component,event,helper);
        component.set("v.showFdbkModal",false);
        helper.backToDataTable(component, event, helper);
        }
       // var k=component.find("comments").get("v.value");     
    },
    handleLike:function (component, event) {
        var objWrapper = component.get("v.objwrapper");
        var button = event.getSource();
        var id = button.getLocalId();
        if(id==="great"){
            //logic related to great button click
            component.set("v.isGreatClicked",true);
            component.set("v.isNtGoodClicked",false);
            component.set("v.isFbkSubmitEnabled",false);
            objWrapper.Rating = '1';
            
        }
        else{
            //logic related to not good button click
            component.set("v.isGreatClicked",false);
            component.set("v.isNtGoodClicked",true);
            component.set("v.isFbkSubmitEnabled",false);
            objWrapper.Rating = '0';
        }
    },
    backToDataTable:function(component, event, helper){
        helper.backToDataTable(component, event, helper);
    },
    handleOptoutOk:function(component){
        component.set("v.showOptoutPopup",false);
    },
    handleResidentClick:function(component){
        
        var objWrapper = component.get("v.objwrapper");
  
        
        
        if(objWrapper.OptOutInfoSharing){
            component.set("v.showOptoutPopup",true);
        }
        else{
        var contactId=btoa(component.get("v.objwrapper.ContactId"));
        //component.set("v.showOptoutPopup",true);
        //window.open('/s/client-one-view?referralid='+contactId,'_blank');
        window.open('clients?clientId='+contactId,'_blank');
        }
    }
})