({
    getFormattedDate : function(date) {
        var d = new Date(date);
        var month = d.getMonth() + 1;
        var day = d.getDate();
        var year = (''+ d.getFullYear()).substr(2);
        return month + "/" + day + "/" + year;
    },
    
    /* fetch the picklist Values based on the API names */
    fetchPicklistValues : function(component) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            
            var flds = component.get("v.picklistValues");
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getPickListValues', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var pickListFlds = flds.split(',');
                    var result = response.objectData.picklistvalues;
                    for(var index in pickListFlds){
                        if(pickListFlds.hasOwnProperty(index)){
                            var options = [];
                            var keys = Object.keys(result[pickListFlds[index]]);
                            for(var i in keys){
                                if(keys.hasOwnProperty(i)){
                                    //Not needed as part of Bug : 341305
                                   // if(keys[i]!=="Draft" && keys[i]!=="In Progress - Org Not in System" && keys[i]!=="Resource Cancelled" && keys[i]!=="Resource Provided" && keys[i]!=="Resource Not Provided"){
                                    if(keys[i]!=="Draft" && keys[i]!=="Resource Cancelled" && keys[i]!=="Resource Provided" && keys[i]!=="Resource Not Provided"){ 
                                        options.push({ class: "optionClass", label: keys[i], value: result[pickListFlds[index]][keys[i]] });
                                    }                            
                                    if(keys[i]==="Resource Provided"){
                                        options.push({ class: "optionClass", label: $A.get("$Label.c.yes"), value: result[pickListFlds[index]][keys[i]] });
                                    }
                                    if(keys[i]==="Resource Not Provided"){
                                        options.push({ class: "optionClass", label: $A.get("$Label.c.RE_No"), value: result[pickListFlds[index]][keys[i]] });
                                    }   
                                  }
                            }
                            if(pickListFlds[index] === "Status__c"){
                                //Bug 347664:Add a loop for removing the value "Org Not in System" from Picklist 
                                for( var j = 0; j < options.length; j+=1){ 
                                    if (options[j].value === component.get("v.OrgNotinSystem")){
                                        options.splice(j,1); 
                                    }    
                                }
                             component.set("v.statusmap", options);  
                            }else if(pickListFlds[index] === "Outcome__c"){
                                component.set("v.outcomemap", options);
                            }else if(pickListFlds[index] === "OutcomeReason__c"){
                                component.set("v.outcomereasonmap", options);
                            }
                        }
                    }
                    
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },
            {
                                  'strObjectName':'Referral__c',
                                  'strLstFields': component.get("v.picklistValues")
            },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    getReferral : function(component,event,helper) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var refrecId = component.get("v.refrecId");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getReferralDetails', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){                    
                    var objectData = response.objectData.records;
                    var objwrapper = JSON.parse(objectData);
                     //Bug 347664:updating the status value
                    if(objwrapper.Status === component.get("v.OrgNotinSystem")){
                       objwrapper.Status = 'New';
                    }
                    component.set('v.objwrapper', objwrapper); 
                    component.set('v.resident',objwrapper.Contacts);
                    component.set('v.phone',objwrapper.ReferringUserPhone);
                    component.set('v.email',objwrapper.ReferringUserEmail);
                    //component.set('v.referraldate',objwrapper.DateOfReferral.slice(0,10));
                    component.set('v.referraldate',helper.getFormattedDate(objwrapper.DateOfReferral));
                    component.set('v.organization',objwrapper.ReferredAccountID);
                    component.set('v.referralmadeby',objwrapper.CreatedBy);

                    component.set('v.bmasked',objwrapper.OptOutInfoSharing);
                    component.set('v.oldStatus',objwrapper.Status);
                    component.set('v.statusReason',objwrapper.OutcomeReason);
                    
                    
                    //var fDate = helper.getFormattedDate(objwrapper.DateOfReferral);
                    
                    //  var daysSinceOpened=' '+objwrapper.DaysSinceOpened+' days open';
                    var daysSinceOpened=' '+objwrapper.DaysSinceOpened+' '+$A.get("$Label.c.referraldaysago") ;
                    
                    component.set('v.daysSinceOpened',daysSinceOpened);
                    component.set('v.refName',objwrapper.Name);
                    
                    /* if(objwrapper.Status !== $A.get("$Label.c.closingrefserviceprovided") && objwrapper.Status !==$A.get("$Label.c.closingrefservicenotprovided") ){
                    component.set("v.isSaveEnabled",true);
                	} */
                    if(objwrapper.Rating === 1){
                        component.set("v.isGreatClicked",true);
                        component.set("v.isNtGoodClicked",false);
                        component.set("v.isFbkSubmitEnabled",false);
                    }else if(objwrapper.Rating === 0){
                        component.set("v.isGreatClicked",false);
                        component.set("v.isNtGoodClicked",true);
                        component.set("v.isFbkSubmitEnabled",false);
                    }
                    
                    if(objwrapper.Status !== null){
                        var statusmap = component.get("v.statusmap");
                        for(var indexstatusmap in statusmap){
                            if(statusmap[indexstatusmap].value === objwrapper.Status){
                                statusmap[indexstatusmap].selected = true;
                            }
                        }
                        component.set("v.statusmap", statusmap);
                    }
                    if(objwrapper.OutcomeReason !== null){
                        var outcomereasonmap = component.get("v.outcomereasonmap");
                        for(var indexoutcomereasonmap in outcomereasonmap){
                            if(outcomereasonmap[indexoutcomereasonmap].value === objwrapper.OutcomeReason){
                                outcomereasonmap[indexoutcomereasonmap].selected = true;
                            }
                        }
                        component.set("v.outcomereasonmap", outcomereasonmap);
                    }
                    if(objwrapper.Outcome !== null){
                        if(objwrapper.Outcome==='Resource Not Provided'){
                            component.set("v.showoutcomereason",true)
                        }
                        else{
                            component.set("v.showoutcomereason",false);
                        }
                        var outcomemap = component.get("v.outcomemap");
                        for(var indexoutcome in outcomemap){
                            if(outcomemap[indexoutcome].value === objwrapper.Outcome){
                                outcomemap[indexoutcome].selected = true;
                            }
                        }
                        component.set("v.outcomemap", outcomemap);
                    }
                    var options = [];
                    for(var i in objwrapper.lstUsers){
                        if(objwrapper.lstUsers[i].Id === objwrapper.OwnerId){
                            options.push({
                                class: "optionClass",
                                label: objwrapper.lstUsers[i].Name,
                                value: objwrapper.lstUsers[i].Id,
                                selected: true
                            });
                        }else{
                            options.push({
                                class: "optionClass",
                                label: objwrapper.lstUsers[i].Name,
                                value: objwrapper.lstUsers[i].Id
                            });
                        }
                    }
                    
                    //For unassigned
                    //RE_Release 1.2 – Lightning valuate - Payal Dubela 
                    if(objwrapper.sQueueId === objwrapper.OwnerId){
                        options.push({
                            class: "optionClass",
                            label: objwrapper.sQueueName === "Unassigned" ? $A.get("$Label.c.RE_Unassigned") : objwrapper.sQueueName,
                            value: objwrapper.sQueueId,
                            selected: true
                        });
                    }else{
                        //RE_Release 1.2 – Lightning valuate  - Payal Dubela 
                        options.push({
                            class: "optionClass",
                            label: objwrapper.sQueueName === "Unassigned" ? $A.get("$Label.c.RE_Unassigned") : objwrapper.sQueueName,
                            value: objwrapper.sQueueId
                        });
                    }  
                    
                    component.set("v.usermap", options);
                    if(objwrapper.Status==='Closed'){
                      component.set("v.bshowclosureinfo", true);  
                    }
                    
                    
                    
                    
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },
            {
                                  'strRecId' : refrecId
            },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    createColumnData:function(component){
        var columnsData=[];
        columnsData.push({ label: $A.get("$Label.c.RE_Title"), fieldName: 'Title', type: 'text',sortable : true},
                         { label: $A.get("$Label.c.description"), fieldName: 'Description', type: 'text',sortable : true},
                         { label: $A.get("$Label.c.Created_Date"), fieldName: 'CreatedDate', type: 'date',sortable : true},
                         { label: $A.get("$Label.c.Last_modified_date"), fieldName: 'ModifiedDate', type: 'date',sortable : true},
                         { label: $A.get("$Label.c.referredby"), fieldName: 'CreatedBy', type: 'text',sortable : true})
        component.set("v.mycolumns",columnsData);
    },
    updateReferral : function(component) {
        try{
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var refdata = component.get("v.objwrapper");
            if((component.get('v.oldStatus')!==refdata.Status)){
                refdata.isChangedStatus=true;
            }                        
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateReferralDetails', function(response){
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var successMsg = $A.get("$Label.c.referralsuccessmessage"); 
                    bSuper.showToast($A.get("$Label.c.successstatus"),"SUCCESS",successMsg);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR','Error',errMsg);
                }
            },
            {
            	"objWrapper" : refdata
            },false);
        }
        catch(e){
            bSuper.consoleLog(e.stack, true);
        }
    },
    backToDataTable:function(component){
        var closebtn = component.getEvent("CloseModalEvt");
        closebtn.setParams({"closeModal" : false,
                            "sObjectName" : "Referral__c",
                            "sObjectId" : component.get("v.recid")
                           });
        // closebtn.setParams({"sObjectName" : "ContentNote"});
        closebtn.fire(); 
        
        
        
        document.getElementsByClassName("locationtable-cont")[0].classList.remove("slds-hide");
        document.getElementsByClassName("locationtable-body")[0].classList.add("slds-hide");
        document.getElementsByClassName("headingContainer")[0].classList.remove("slds-hide");
        document.getElementsByClassName("headingL1")[0].classList.remove("slds-hide");
        document.getElementsByClassName("locationsel-cont")[0].classList.remove("slds-hide");
        document.getElementsByClassName("save-btn")[0].classList.remove("slds-hide");
        //   console.log("ojj",document.getElementsByClassName("save-btn")[0]);
        
        //delete it 
        
    },
    
  
    
    validateInput : function(component,event,helper){
    var objWrapper = component.get("v.objwrapper");
        if(objWrapper.Status==='Closed' && objWrapper.Outcome==='Resource Not Provided' && !objWrapper.OutcomeReason )	{
            //Show error
            var RequiredField  =  $A.get("$Label.c.RequiredField");  
                helper.showToast(component, event, 'Error', RequiredField ); 
            return false;
        }
        else if(objWrapper.Status==='Closed' && !objWrapper.Outcome )	{
        //Show error
        var RequiredField1  =  $A.get("$Label.c.RequiredField");  
        helper.showToast(component, event, 'Error', RequiredField1); 
        return false;
        }
         else{
              return true;
            }
	},
    showToast : function(component, event, variant, msg){
        if(variant === 'Success'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.successstatus"),
                "message": msg,
                "variant": "success"
            });
        }else if(variant === 'Error'){
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },
    
})