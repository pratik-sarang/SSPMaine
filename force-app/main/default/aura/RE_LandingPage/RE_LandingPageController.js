({
    doInit : function(component, event, helper) {
        helper.getLoggedInUser(component);
    },
    handleEventFromResourcePackages : function(component) {
        component.set("v.isViewLessPackages", !component.get("v.isViewLessPackages"));
        var elmnt = component.find("ResourcePackages").getElement();
        elmnt.scrollIntoView();
    },
    navigateToGetStarted : function() {                
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/get-started"
        });
        urlEvent.fire();
    },
    goToSite : function(component, event) {                        
        if(event.currentTarget.id === 'facebook')
            window.open($A.get("$Label.c.RE_FacebookURL"),'_blank');
        if(event.currentTarget.id === 'twitter')
            window.open($A.get("$Label.c.RE_TwitterURL"),'_blank');
        if(event.currentTarget.id === 'instagram')
            window.open($A.get("$Label.c.RE_InstagramURL"),'_blank');
    },
    HideGrey : function(component, event) {         
        //var parentTargetId = event.target.parentElement.parentElement.id;
        
        if(!event.target.classList.contains("domain-category")){
        var cmpResourceCategory = component.find("resourceCategory");
                        
        
        var selectedDomainArr, parentContainerArr, activeDomainArr = [];
        selectedDomainArr = cmpResourceCategory.find('domainValue');          
        parentContainerArr = cmpResourceCategory.find('parentContainer');
        activeDomainArr = cmpResourceCategory.find('selectedDomain');
        
        if(Array.isArray(selectedDomainArr)){    
            /*var selectedItem = '';
            selectedItem = selectedDomainArr.find(function (domain){                 
                return selectedDomain === domain.getElement().id}) */           
                        
            for(var index = 0; index < parentContainerArr.length; index+=1){                      
                if($A.util.hasClass(parentContainerArr[index].getElement(),"slds-show")){                     
                    $A.util.removeClass(parentContainerArr[index].getElement(),"slds-show");                            
                    $A.util.addClass(parentContainerArr[index].getElement(),"slds-hide");
                }                                            
            }          
            
            for(var domainIndex = 0; domainIndex < selectedDomainArr.length; domainIndex+=1){                                                         
                if($A.util.hasClass(selectedDomainArr[domainIndex].getElement(),"slds-show")){                       
                    $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"slds-show");
                    $A.util.removeClass(selectedDomainArr[domainIndex].getElement(),"activeDomain");
                    $A.util.addClass(selectedDomainArr[domainIndex].getElement(),"slds-hide");
                }                                                                     
            }   
            
            for(var domainIndx = 0; domainIndx < activeDomainArr.length; domainIndx+=1){                  
                if($A.util.hasClass(activeDomainArr[domainIndx].getElement(),"activeDomain")){                        
                    $A.util.removeClass(activeDomainArr[domainIndx].getElement(),"activeDomain");                        
                }                                                                  
            }
        }
        }
    }
})