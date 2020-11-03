({
    doInit:function(component,event,helper){
        helper.resetstatus(component,event,helper);
      
    },
    openDropdown:function(component,event){
        if(event.keyCode === 13 || !event.keyCode){
            if(component.get("v.disablefield")){
                $A.util.addClass(component.find('dropdown'),'slds-is-close');
                $A.util.removeClass(component.find('dropdown'),'slds-is-open');
            }
            else{
                if($A.get("$Browser.formFactor") === 'PHONE'){
                    if($A.util.hasClass(component.find('dropdown'),'slds-is-close')){
                        $A.util.addClass(component.find('dropdown'),'slds-is-open');
                   	 	$A.util.removeClass(component.find('dropdown'),'slds-is-close');
                    }else{
                        $A.util.addClass(component.find('dropdown'),'slds-is-close');
                        $A.util.removeClass(component.find('dropdown'),'slds-is-open');
                    }
                }else{
                    $A.util.addClass(component.find('dropdown'),'slds-is-open');
                    $A.util.removeClass(component.find('dropdown'),'slds-is-close');
                }
            }
        }
    },
    /*JAWS Issues Fix*/
    checkDropDown:function(component){
        console.log(document.getElementsByClassName("slds-is-open").length);
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
        if(event.keyCode === 13 || !event.keyCode){
            var value = event.currentTarget.id.split("#BP#")[0];
            var isCheck = event.currentTarget.id.split("#BP#")[1];
            helper.selectOptionHelper(component,value,isCheck);
        }
    },
     onReset : function(component,event,helper){

       var params = event.getParam('arguments');	
        if (params) {
            var allOptions = component.get('v.locationNames');
            
            for(var i=0;i<allOptions.length;i +=1){ 
            allOptions[i].isChecked = false;
            }
            
            component.set('v.locationNames',allOptions);
            
            helper.resetstatus(component,event,helper);
        }
        
    },
})