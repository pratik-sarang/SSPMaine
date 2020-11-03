({
    searchHelper : function(component,event,getInputkeyWord) {
        //Lagan's changes start
        try{ 
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchLookUpValues', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var storeResponse = response.objectData.lookUpValues;
                    
                    if (storeResponse.length === 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }
                    
                    component.set("v.listOfSearchRecords", storeResponse);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
                
            },{
                'strSearchKeyWord': getInputkeyWord,
                'strObjectName' : component.get("v.objectAPIName"),
                'bfilter': component.get("v.bfilter")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        //Lagan's changes end
        
        
    },
    getRecord : function(component) {
        var accountId = component.get("v.accountID");
        
        //Lagan's changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getObjectRecord', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var storeResponse = response.objectData.getRec;
                    component.set("v.selectedRecord" , storeResponse); 
                    var forclose = component.find("lookup-pill");
                    var lookUpTarget = component.find("lookupField");
                    if(document.getElementsByClassName("slds-pill-container")[0].classList.contains("slds-show") && component.get("v.isChanged")){
                        component.set("v.isChanged",false);
                        $A.util.addClass(forclose,"slds-hide");                        
                        $A.util.removeClass(lookUpTarget,"slds-hide");
                    }else{
                        component.set("v.isChanged",true);
                        $A.util.removeClass(forclose,"slds-hide");
                        $A.util.addClass(lookUpTarget,"slds-hide");
                    }
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },{
                "recID": accountId ,
                "ObjectName" : component.get("v.objectAPIName")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
        //Lagan's changes end
    },
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
    }
})