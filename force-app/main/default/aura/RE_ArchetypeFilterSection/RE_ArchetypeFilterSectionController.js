({    
    updateZipCode : function(component, event, helper) {
        if(event.type === "click" || event.keyCode === 13){ 
            var zipCode = component.get("v.sZipCodeVal");  
            if(zipCode){           
                var encodedZip = window.btoa(zipCode);
                //window.localStorage.setItem('zipCodeVal', encodedZip);
                sessionStorage.setItem("zipCodeVal", encodedZip);
                component.set("v.updateResources",true); 
                component.set("v.sZipCode", zipCode);                                      
            }else{
                component.set("v.updateResources",true);             
                component.set("v.sZipCodeVal", '');
                component.set("v.sZipCode", '');            
                helper.showToast(component, event, $A.get("$Label.c.RE_ZipCode_Error"));  
            }
        }
	},
    updateZipCodeValue : function(component){
        var hoursColumnData=[];
        hoursColumnData.push({'label': $A.get("$Label.c.RE_Open_Today"), value: 'Open Today'},
                             {'label': $A.get("$Label.c.RE_Open_Weekends"), value: 'Open Weekends'})
        component.set("v.hoursList",hoursColumnData);
        
        var zipCode = component.get("v.sZipCode");
       // if(component.get("v.onFilterLoad") && zipCode.length === 5){
       if(component.get("v.onFilterLoad") && zipCode.length>0){
            component.set("v.onFilterLoad", false);
            component.set("v.sZipCodeVal", component.get("v.sZipCode"));
        }
    },
    handleChange: function(component) {        
        if($A.util.isUndefinedOrNull(component.get("v.allAvailableDomains"))){
            component.set("v.allAvailableDomains",component.get("v.selectedDomains")); 
        }
        var catagoriesValue = '';
        var selectedDomainArr = [];
        selectedDomainArr = component.find('domains');
        
        var lstDomains = component.get("v.lstApplicableDomains");
        var lstSelectedDomains = [];
        
        for (var i = 0; i < selectedDomainArr.length; i+=1){                              
            if(selectedDomainArr[i].get("v.checked") === true){
                lstSelectedDomains.push(selectedDomainArr[i].get("v.name"));
                if(catagoriesValue!==''){ 
                    catagoriesValue = catagoriesValue + ',' +selectedDomainArr[i].get("v.name");
                }
                else{
                    catagoriesValue = selectedDomainArr[i].get("v.name");
                } 
            }
        }        
        component.set("v.selectedDomains",catagoriesValue); 
        
        if(lstDomains.length !== lstSelectedDomains.length){            
            component.set("v.showAll",false);
        }
        else{
            component.set("v.showAll",true);
        }             
    },
    updateRole : function(component, event){         
        if($A.util.isUndefinedOrNull(component.get("v.allAvailableDomains"))){
            component.set("v.allAvailableDomains",component.get("v.selectedDomains"));
        }
        if(!$A.util.isUndefinedOrNull(component.get("v.allAvailableDomains"))){
            component.set("v.onLoad",true);
            component.set("v.selectedDomains",component.get("v.allAvailableDomains"));
            component.set("v.onLoad",false);
        }
        var encodedRole = window.btoa(event.getSource().get('v.value'));
        window.localStorage.setItem('selectedRole', encodedRole);
        component.set("v.selectedSubArchetypeId",event.getSource().get('v.value'));        
        component.set("v.updateResources",true); 
    },
    getResourceCards : function(component){ 
        var options = component.get("v.resourceCatagoriesValue");
        var catagoriesValue = '';
        for(var i=0; i<options.length; i+=1){
            if(catagoriesValue !== ''){
                catagoriesValue = catagoriesValue + ',' +options[i];
            }
            else{
            	catagoriesValue = options[i];
            }            
        }        
    },
    updateAllDomains : function(component){
        if($A.util.isUndefinedOrNull(component.get("v.allAvailableDomains"))){
            component.set("v.allAvailableDomains",component.get("v.selectedDomains")); 
        }
        var selectedDomainArr = [];
        selectedDomainArr = component.find('domains'); 
        var lstDomains = component.get("v.lstApplicableDomains");
        var lstGoalDomains = [];
        
        if(component.get("v.showAll")===true){ 
            var catagoriesValue = '';
            for(var i=0; i<lstDomains.length; i+=1){
                lstGoalDomains.push(lstDomains[i].value);
                if(catagoriesValue !== ''){
                    catagoriesValue = catagoriesValue + ',' +lstDomains[i].value;
                }
                else{
                    catagoriesValue = lstDomains[i].value;
                }                
            }
            component.set("v.selectedDomains",catagoriesValue); 
                        
            for (var j = 0; j < selectedDomainArr.length; j+=1){                  
                if(lstGoalDomains.includes(selectedDomainArr[j].get("v.name")) === true){                    
                	selectedDomainArr[j].set("v.checked",true);
                }
            }            
        }
        else{
            component.set("v.selectedDomains",'');             
            for (var k = 0; k < selectedDomainArr.length; k+=1){
                selectedDomainArr[k].set("v.checked",false);
            }            
        }             
    },
    handleFilterCancel:function(){
        if(document.getElementsByClassName('archetype-cards')[0]){
            document.getElementsByClassName('archetype-cards')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('archtype-filter-section')[0]){
            document.getElementsByClassName('archtype-filter-section')[0].classList.add('slds-hide');
        }
        if(document.getElementsByClassName('archetypeBanner')){
            document.getElementsByClassName('archetypeBanner')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('archetypeBanner')[0]){
            document.getElementsByClassName('archetypeBanner')[0].classList.remove('slds-hide'); 
        }
        if(document.getElementsByClassName('empty-div')[0]){
            document.getElementsByClassName('empty-div')[0].classList.remove('slds-hide'); 
        }
    },
    getUpdatedHours : function(component) {
        var selectedHours = [];
        var hours = component.find('hoursOpen');
        for (var i = 0; i < hours.length; i+=1){                              
            if(hours[i].get("v.checked") === true){                
               if(selectedHours!==null){
                selectedHours.push(hours[i].get("v.name")); 
               }
            }
        } 
        component.set("v.selectedHours", selectedHours); 
        
    }
})