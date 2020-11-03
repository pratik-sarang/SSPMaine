({
    selectOptionHelper : function(component,label,isCheck) {
        var selectedOption= component.get("v.selectedOptions");
        var allOptions = component.get('v.updatedPicklistValues');
        var selectedItems = [];
        var selectedPickList = '';
        //var count=0;
        for(var i=0;i<allOptions.length;i+=1){ 
            if(allOptions[i].label === label) { 
                if(isCheck === 'true'){ 
                    allOptions[i].isChecked = false; 
                }else{ 
                    allOptions[i].isChecked = true; 
                } 
            } if(allOptions[i].isChecked){ 
                selectedItems.push(allOptions[i].label); 
            } 
        } if(selectedItems !== undefined){
            selectedOption = selectedItems.length+' items selected';
        }
        component.set("v.selectedOptions",selectedOption);
        component.set('v.updatedPicklistValues',allOptions);
        for(var j=0; j<selectedItems.length;j+=1){
            selectedPickList = selectedPickList + selectedItems[j]+';';
        }
        component.set("v.selectedRecords", selectedPickList);
    },
    resetStatus : function(component){
        var loc = component.get("v.options");
        var selectedOption= component.get("v.selectedOptions");
        var picklistValues = [];
        var selectedItems = [];
        var selectedPickList = '';
        for(var i =0 ; i< loc.length; i +=1){
            var checkCondition = false;
            for(var j =0 ; j< selectedOption.length;  j +=1){
                if (loc[i].value === selectedOption[j].value){
                    checkCondition=true;
                    break;
                } else if (loc[i].value === selectedOption[j].value){//Added logic
                    checkCondition=true;
                    break;  
                }
            }
            if(checkCondition){
                picklistValues.push({ class: "optionClass", label: loc[i].label, value: loc[i].value, isChecked:true });
                var object = {};
                object.label	=	loc[i].label;
                object.value	=	loc[i].value;
                selectedItems.push(object);
            }else{
                picklistValues.push({ class: "optionClass", label: loc[i].label, value: loc[i].value, isChecked:false });
            }
        }
        component.set("v.updatedPicklistValues", picklistValues);
        var placeHolder;
        if(selectedOption !== undefined){
            placeHolder = selectedOption.length+ ' '+$A.get("$Label.c.RE_itemsSelected");
        }
        for(var k=0; k<selectedItems.length;k+=1){
            selectedPickList = selectedPickList + selectedItems[k].value+';';
        }
        component.set("v.selectedRecords", selectedPickList);
        component.set("v.selectedOptions",placeHolder);
    }
    
})