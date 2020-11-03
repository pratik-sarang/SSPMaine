({
    selectOptionHelper : function(component,value,isCheck) {
        var selectedOption= component.get("v.selectedOptions");
        var allOptions = component.get('v.locationNames');
        var selectedItems = [];
        var unselectedItems = [];
        var altText = '';
        var itemsSelected = $A.get("$Label.c.RE_itemsSelected");
       // for(var i=0;i<allOptions.length;i++){ 
             for(var i=0;i<allOptions.length;i +=1){ 
            if(allOptions[i].value===value) { 
                if(isCheck==='true'){ 
                    allOptions[i].isChecked = false; 
                }else{ 
                    allOptions[i].isChecked = true; 
                } 
            } if(allOptions[i].isChecked){ 
                var object = {};
                object.Id	=	allOptions[i].value;
                object.Name	=	allOptions[i].label;
                if(selectedItems.length === 0){
                    altText = allOptions[i].label;
                }else{
                    altText = altText+', '+allOptions[i].label;
                }
                selectedItems.push(object); 
                
            }else{
                var obj = {};
                obj.Id	=	allOptions[i].value;
                obj.Name	=	allOptions[i].label;
                unselectedItems.push(obj); 
            } 
        } if(selectedItems !== undefined){
            selectedOption = selectedItems.length + ' ' + itemsSelected;  
        }
        component.set("v.sNames",altText);
        component.set("v.selectedRecords", selectedItems);
        component.set("v.unselectedRecords", unselectedItems);
        component.set("v.selectedOptions",selectedOption);
        component.set('v.locationNames',allOptions);
    },
    
    resetstatus  : function(component) {
        var loc = component.get("v.options");
        
        var resourceLoc = component.get("v.resourceLocList");
        var locNames = [];
        var resetSelectedOptions = [];
        var selectedItems = [];
        var altText = '';
        var selectedOptionCount;
        var itemsSelected = $A.get("$Label.c.RE_itemsSelected");
        //for(var i =0 ; i< loc.length; i++){
        for(var i =0 ; i< loc.length; i +=1){
            var checkCondition = false;
            //for(var j =0 ; j< resourceLoc.length; j++){
            for(var j =0 ; j< resourceLoc.length;  j +=1){
                if (loc[i].Id === resourceLoc[j].Location__c){
                    checkCondition=true;
                    break;
                } else if (loc[i].Id === resourceLoc[j].Id){//Added logic
                   checkCondition=true;
                    break;  
                }
            }
            if(checkCondition){
                resetSelectedOptions.push({ class: "optionClass", label: loc[i].Name, value: loc[i].Id, isChecked:true });
                locNames.push({ class: "optionClass", label: loc[i].Name, value: loc[i].Id, isChecked:true });
                var object = {};
                object.Id	=	loc[i].Id;
                object.Name	=	loc[i].Name;
                if(selectedItems.length === 0){
                    altText = loc[i].Name;
                }else{
                    altText = altText+', '+loc[i].Name;
                }
                selectedItems.push(object);
                
            }else{
                locNames.push({ class: "optionClass", label: loc[i].Name, value: loc[i].Id, isChecked:false });
            }
        }
        if(resetSelectedOptions !== undefined){
            selectedOptionCount = resetSelectedOptions.length + ' ' + itemsSelected;
        }
        component.set("v.selectedOptions",selectedOptionCount);
        component.set("v.selectedRecords", selectedItems);
        component.set("v.sNames",altText);
        component.set("v.locationNames", locNames);
        

       
}
})