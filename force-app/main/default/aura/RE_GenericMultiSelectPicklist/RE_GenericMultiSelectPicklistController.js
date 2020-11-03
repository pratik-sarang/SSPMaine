({
    doInit:function(component,event,helper){
        helper.resetStatus(component);
    },
    openDropdown:function(component, event){ 
        if(event.keyCode === 13 || !event.keyCode){
            if(component.get("v.disabled")){
                $A.util.addClass(component.find('dropdown'),'slds-is-close');
                $A.util.removeClass(component.find('dropdown'),'slds-is-open');
            }
            else{
            $A.util.addClass(component.find('dropdown'),'slds-is-open');
            $A.util.removeClass(component.find('dropdown'),'slds-is-close');
            } 
        }
    },
    checkDropDown:function(component, event){
        $A.util.removeClass(component.find('dropdown'),'slds-is-open');
        var selectedElements = document.querySelectorAll(".slds-is-open");
        selectedElements.forEach(function(el) {
          el.classList.remove("slds-is-open");
          el.classList.add("slds-is-close");
        });
        $A.util.addClass(component.find('dropdown'),'slds-is-close');
    },
    closeDropDown:function(component){
        $A.util.addClass(component.find('dropdown'),'slds-is-close');
        $A.util.removeClass(component.find('dropdown'),'slds-is-open');
    },
    selectOption:function(component,event,helper){  
        var label = event.currentTarget.id.split("#BP#")[0];
        var isCheck = event.currentTarget.id.split("#BP#")[1];
        helper.selectOptionHelper(component,label,isCheck);
    }
})