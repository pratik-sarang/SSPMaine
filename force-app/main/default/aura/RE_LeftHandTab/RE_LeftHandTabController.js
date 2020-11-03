({
    doInit: function(component, event, helper) {
        var optionSelected=window.location.pathname.split('/s/')[1].replace(/-/g, ' ');
        if(optionSelected && optionSelected.length){
            if(optionSelected.indexOf(' ')>-1){
                if(optionSelected.indexOf('verbal consent')>-1){
                    optionSelected='Clients' 
                }
                else{
                    optionSelected=helper.capitalizeText(component, event, helper,optionSelected);
                } 
            } 
            else{
                optionSelected=optionSelected.charAt(0).toUpperCase() + optionSelected.slice(1)
            }
        }
        else{
               optionSelected="Referral Inbox";  
        }
        var spiltReportCheck=optionSelected.split("/");
        if(spiltReportCheck.indexOf('Report')=== 0){
            optionSelected="Report";
        }
        component.set("v.optionSelected",optionSelected);
        
        helper.doInitHandler(component);
    },    
    handleOnSelect: function(component, event, helper) {
        //Write your logic on select of any item
        helper.handleOnSelect(component, event, helper);
        helper.closetoggle(component);
    },
    closetoggle : function(component, event, helper) {
        helper.closetoggle(component);
    },
    
    opentoggle : function(component) {
        var toggleText = component.find("verticalNavigation");
        $A.util.addClass(toggleText, "toggleopen");
        $A.util.removeClass(toggleText, "toggleclose");
    },
    closehandler: function(component) {
        component.find("editmodal").destroy();
        component.set("v.showModal", false);
    },
    component2Event:function(component, event, helper){
        helper.component2Event(component, event, helper);
    }
})