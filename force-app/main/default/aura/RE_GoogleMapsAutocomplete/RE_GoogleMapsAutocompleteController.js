({
    keyPressController: function (component, event, helper) {
        
        var searchKey = component.get("v.searchKey");
        helper.openListbox(component, searchKey);
        helper.displayOptionsLocation(component, searchKey);
        component.set("v.bselectedaddress",false);
    },
    
    selectOption: function (component, event) {
        var selectedItem = event.currentTarget.dataset.record;
        //var selectedValue = event.currentTarget.dataset.value;
        component.set("v.selectedOption", selectedItem);
        
        var searchLookup = component.find("searchLookup");
        $A.util.removeClass(searchLookup, 'slds-is-open');
        
        var iconDirection = component.find("iconDirection");
        $A.util.removeClass(iconDirection, 'slds-input-has-icon_left');
        $A.util.addClass(iconDirection, 'slds-input-has-icon_right');
        
        component.set("v.searchKey", selectedItem);
        component.set("v.bselectedaddress",true);
        
    },
    
    clear: function (component, event, helper) {
        if(event.type === "click" || event.keyCode === 13 || event.keyCode === 32){//JAWS Fixes
            component.set("v.bselectedaddress",false);
            helper.clearComponentConfig(component);
        }else if(event.keyCode === 9){
            return false;
        }
    }
})