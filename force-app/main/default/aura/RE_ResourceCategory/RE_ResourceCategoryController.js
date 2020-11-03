({
    doInit : function(component) {                
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            var component_failure = $A.get('$Label.c.component_failure');
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getResourceCategories', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do              
                if(response.isSuccessful){
                    var configResult = response.objectData.mapConfigMasterRecords;
                    var categoryArr = [];            
                    for(var key in configResult){
						if(key !== null && key !== undefined){
							categoryArr.push({value:configResult[key], key:key});
						}
                    }
                    component.set("v.mapConfigMasterRecords", categoryArr);
                                        
                    component.set("v.mapDomainCategories",response.objectData.mapDomainCategories); 
                }else{                    
                    bSuper.showToast('Error', 'Error', component_failure);
                }
                                
            },{
            "showByCategory" : false
            },false); 
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        };
    },
    toggle : function(component, event) {
        component.set("v.selectedDomain",'');
        component.set("v.categoryContent",null);
        component.set("v.showCategories",false);
        
        var selectedDomain = event.currentTarget.id;        
        component.set("v.selectedDomain",selectedDomain);
        
        var mapDomainCategories = component.get("v.mapDomainCategories");                
        var lstCategorySubCategories = mapDomainCategories[selectedDomain];        
        component.set("v.categoryContent",lstCategorySubCategories);   
        if(lstCategorySubCategories !== undefined)
        	component.set("v.showCategories",true);
        
        var selectedDomainArr, parentContainerArr, activeDomainArr = [];
        selectedDomainArr = component.find('domainValue');  
        parentContainerArr = component.find('parentContainer');
        activeDomainArr = component.find('selectedDomain');
        
        if(Array.isArray(selectedDomainArr)){    
            var selectedItem = '';
            selectedItem = selectedDomainArr.find(function (domain){                 
                return selectedDomain === domain.getElement().id})            
                for(var index = 0; index < parentContainerArr.length; index+=1){  
                    if(parentContainerArr[index].getElement().id === selectedItem.getElement().id &&
                      lstCategorySubCategories !== undefined){
                        if($A.util.hasClass(parentContainerArr[index].getElement(),"slds-show")){                        
                            $A.util.removeClass(parentContainerArr[index].getElement(),"slds-show");
                            $A.util.addClass(parentContainerArr[index].getElement(),"slds-hide");
                        }
                        else if($A.util.hasClass(parentContainerArr[index].getElement(),"slds-hide")){                        
                            $A.util.removeClass(parentContainerArr[index].getElement(),"slds-hide");
                            $A.util.addClass(parentContainerArr[index].getElement(),"slds-show");
                        }
                    }
                    else{
                        if($A.util.hasClass(parentContainerArr[index].getElement(),"slds-show")){                        
                            $A.util.removeClass(parentContainerArr[index].getElement(),"slds-show");                       
                        }
                        
                       $A.util.addClass(parentContainerArr[index].getElement(),"slds-hide"); 
                    }
                }
            for(var domainIndex = 0; domainIndex < selectedDomainArr.length; domainIndex+=1){  
                if(selectedDomainArr[domainIndex].getElement().id === selectedItem.getElement().id){                                        
                    if($A.util.hasClass(selectedDomainArr[domainIndex].getElement(),"slds-show")){                        
                        $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"slds-show");
                        $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"activeDomain");
                        $A.util.addClass(selectedDomainArr[domainIndex].getElement(),"slds-hide");
                    }
                    else if($A.util.hasClass(selectedDomainArr[domainIndex].getElement(),"slds-hide")){                        
                        $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"slds-hide");
                        $A.util.addClass(selectedDomainArr[domainIndex].getElement(),"slds-show");
                        $A.util.addClass(selectedDomainArr[domainIndex].getElement(),"activeDomain");
                    }
                }
                else{
                    if($A.util.hasClass(selectedDomainArr[domainIndex].getElement(),"slds-show")){                        
                        $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"slds-show");                       
                    }
                    
                   $A.util.addClass(selectedDomainArr[domainIndex].getElement(),"slds-hide"); 
                }                                 
            }                
            for(var domainIndx = 0; domainIndx < activeDomainArr.length; domainIndx+=1){  
                if(activeDomainArr[domainIndx].getElement().id === selectedItem.getElement().id){  
                    if($A.util.hasClass(activeDomainArr[domainIndx].getElement(),"activeDomain")){                        
                        $A.util.removeClass(activeDomainArr[domainIndx].getElement(),"activeDomain");                        
                    }
                    else if(!$A.util.hasClass(activeDomainArr[domainIndx].getElement(),"activeDomain")){                                                
                        $A.util.addClass(activeDomainArr[domainIndx].getElement(),"activeDomain");                        
                    }
        }        
                else{
                    if($A.util.hasClass(activeDomainArr[domainIndx].getElement(),"activeDomain")){                        
                        $A.util.removeClass(activeDomainArr[domainIndx].getElement(),"activeDomain");                       
                    }                                        
                }                                 
            }
        }        
    }
})