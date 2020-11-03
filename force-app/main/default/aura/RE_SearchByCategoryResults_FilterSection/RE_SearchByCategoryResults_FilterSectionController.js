({
	updateZipCodeValue : function(component){
        var hoursColumnData=[];
        hoursColumnData.push({'label': $A.get("$Label.c.RE_Open_Today"), value: 'Open Today'},
                             {'label': $A.get("$Label.c.RE_Open_Weekends"), value: 'Open Weekends'})
        component.set("v.hoursList",hoursColumnData);
        var zipCode = component.get("v.sZipCode"); 
        var zipCodeVal = component.get("v.sZipCodeVal");
        //if(zipCode.length === 5 && zipCode !== zipCodeVal)
        if(zipCode.length > 0 && zipCode !== zipCodeVal)
        	component.set("v.sZipCodeVal", component.get("v.sZipCode"));        
    },
    updateZipCode : function(component, event, helper) {        
        //if(event.which === 13){
            var zipCode = component.get("v.sZipCodeVal");        
            //var pattern = /^[0-9]{5}$/;        
            
            if(zipCode){
                var encodedZip = window.btoa(zipCode);
             
                sessionStorage.setItem("zipCodeVal", encodedZip);
                component.set("v.updateResources",true); 
                component.set("v.sZipCode", zipCode);                                      
            }else{
                component.set("v.updateResources",true);             
                component.set("v.sZipCodeVal", '');
                component.set("v.sZipCode", '');            
                helper.showToast(component, event, $A.get("$Label.c.RE_ZipCode_Error"));  
            }
        //}
	},
    handleChange: function(component) {        
        var catagoriesValue = '';
        var selectedDomainArr = [];
        selectedDomainArr = component.find('domains');
        for (var i = 0; i < selectedDomainArr.length; i+=1){                              
            if(selectedDomainArr[i].get("v.checked") === true){                
                if(catagoriesValue!==''){ 
                    catagoriesValue = catagoriesValue + ',' +selectedDomainArr[i].get("v.name");
                }
                else{
                    catagoriesValue = selectedDomainArr[i].get("v.name");
                } 
            }
        }        
        component.set("v.selectedDomains",catagoriesValue);
     //  helper.handleSelectedDomains(component);
    },
    getUpdatedHours : function(component) {
        var selectedHours = null;
        var hours = component.find('hoursOpen');
        for (var i = 0; i < hours.length; i+=1){                              
            if(hours[i].get("v.checked") === true){                
               if(selectedHours!==null){ 
                    selectedHours = selectedHours + ',' +hours[i].get("v.name");
                }
                else{
                    selectedHours = hours[i].get("v.name");
                } 
            }
        } 
        component.set("v.selectedHours", selectedHours); 
        
    },
    // added by Pankaj [12/17/2019]
    getSelectedValues : function(component) {
        var catagoriesValue = '';
        var selectedDomainArr = [];
        selectedDomainArr = component.find('domains');
        for (var i = 0; i < selectedDomainArr.length; i+=1){                              
            if(selectedDomainArr[i].get("v.checked") === true){                
                if(catagoriesValue!==''){ 
                    catagoriesValue = catagoriesValue + ',' +selectedDomainArr[i].get("v.name");
                }
                else{
                    catagoriesValue = selectedDomainArr[i].get("v.name");
                } 
            }
        }        
        return catagoriesValue; 
    },
     // added by Pankaj [12/17/2019]
    getSelectedHoursValues : function(component) {

        var selectedHours = null;
        var hours = component.find('hoursOpen');
        for (var i = 0; i < hours.length; i+=1){                              
            if(hours[i].get("v.checked") === true){                
               if(selectedHours!==null){ 
                    selectedHours = selectedHours + ',' +hours[i].get("v.name");
                }
                else{
                    selectedHours = hours[i].get("v.name");
                } 
            }
        }
        return selectedHours;
    }
})