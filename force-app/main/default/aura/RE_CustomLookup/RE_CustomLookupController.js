({
    doinIt : function(component, event,helper) {
        
        var accid=component.get('v.accountID');  
        if(accid){
           helper.getRecord(component,event,helper);
        }
    },
    onfocus : function(component,event,helper){
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    onblur : function(component){  
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
        // get the search Input keyword   
        //var getInputkeyWord = component.get("v.SearchKeyWord");   
        var getInputkeyWord=event.target.value;
        var forOpen;
        if( getInputkeyWord.length > 0 ){
            forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{ 
            if(event.keyCode === 13){
                forOpen = component.find("searchRes");
                $A.util.addClass(forOpen, 'slds-is-open');
                $A.util.removeClass(forOpen, 'slds-is-close');
                getInputkeyWord = '';
                helper.searchHelper(component,event,getInputkeyWord);  
            }
            else{
                component.set("v.listOfSearchRecords", null ); 
                var forclose = component.find("searchRes");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
            }
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component){
        	
        var pillTarget = component.find("lookup-pill");
        var lookUpTarget = component.find("lookupField"); 
        
        
        if(component.get("v.isChanged")){
            if(component.get("v.cmpPill") === "clientPill"){
                document.getElementById("clientField").classList.add("slds-hide");
            }
            else if(component.get("v.cmpPill") === "orgnPill"){
                document.getElementById("orgnField").classList.add("slds-hide");
            }
            
        }else{
            if(component.get("v.cmpPill") === "clientPill"){
                document.getElementById("clientField").classList.add("slds-hide");
            }
            else if(component.get("v.cmpPill") === "orgnPill"){
                document.getElementById("orgnField").classList.add("slds-hide");
            }
            
        }
        
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null );
        component.set("v.selectedRecord", {} );   
        //firing the event to catch the clearing if record
        
        
        var compEvent = component.getEvent("oSelectedRecordEvent");
        // set the Selected sObject Record to the event attribute.  
        compEvent.setParams({"recordByEvent" : 'cleared',
                             "lookupObjName": component.get("v.objectAPIName")
                            });  
        // fire the event 
        
        //  //till here 
        if($A.util.hasClass(pillTarget,'slds-hide') || $A.util.hasClass(lookUpTarget, 'slds-hide')){
        	compEvent.fire();
        }        
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event) {
    // get the selected Account record from the COMPONENT event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
       
        var forclose = component.find("lookup-pill");
        var forcloseSearch = component.find("searchRes");
           $A.util.addClass(forcloseSearch, 'slds-is-close');
           $A.util.removeClass(forcloseSearch, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
        
        if(!$A.util.hasClass(forclose,"slds-hide")){
            component.set("v.isChanged",false);
            $A.util.toggleClass(forclose,"slds-hide");
            
            $A.util.toggleClass(lookUpTarget,"slds-hide")
            
            
        }else{
            component.set("v.isChanged",true);
            $A.util.removeClass(forclose,"slds-hide");
            
            $A.util.addClass(lookUpTarget,"slds-hide");
            
        }
        
    },
    onReset : function(component,event,helper){
       
        
        var params = event.getParam('arguments');	
        if (params) {
                    helper.clear(component);
        }
        
    },
    handleAccountChange : function(component, event,helper) {
        var accid=component.get('v.accountID');
        if(!$A.util.isUndefinedOrNull(accid) && accid.startsWith("001")){
            helper.clear(component);
            var forclose = component.find("lookup-pill");
    		    var lookUpTarget = component.find("lookupField");
            $A.util.toggleClass(forclose,"slds-hide");
    		    $A.util.toggleClass(lookUpTarget,"slds-hide");
            if(accid){
               helper.getRecord(component,event,helper);
            }  
        }  
    }
    
})