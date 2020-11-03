({	
   // fetchData : function(component, event) {
   fetchData : function(component) {
       // var contactId = component.get("v.contactId");
        //Lagan's changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchloggedInUserInfo', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    // var retVal = response.getReturnValue();
                    var objectData = response.objectData.records;
                    var parsedvalue = JSON.parse(objectData);
                    //console.log('lstoptions is '+parsedvalue.Phone);
                    var Name=parsedvalue.FirstName+' '+parsedvalue.LastName;
                   // component.set("v.referralObj.Phone",parsedvalue.Phone);
                   component.set("v.userPhone",parsedvalue.Phone);
                    
                    
                    
                    component.set("v.referralObj.Email",parsedvalue.Email);
                    //var clientName=component.get("v.clientName");
                    
                    component.set("v.referralObj.Name",Name);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
                
            },{
                //"sRecordId": component.get("v.sRecordID")
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                    //Lagan's changes end
                   
        
    },
    getLocation : function(component) {
        var accountId = component.get("v.accountId");
        
        //Lagan' changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchLocations', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                       // var retVal = response.getReturnValue();
                var objectData = response.objectData.records;
                var lstlocations = JSON.parse(objectData);
                
                 var locationId = component.get("v.locationId");
                var options = [];
                for(var i in lstlocations){
                //  if((lstlocations[i].Id).slice(0,15) ===locationId ){
                  if(lstlocations[i].Id ===locationId ){
                        options.push({
                            class: "optionClass",
                            label: lstlocations[i].Name,
                            value: lstlocations[i].Id,
                            selected: true
                        });
                      var objWrapper = component.get("v.referralObj");
                      objWrapper.Location=locationId;
                      component.set("v.bIsresourcedisabled",false);
                      
                    }else{ 
                    options.push({
                        class: "optionClass",
                        label: lstlocations[i].Name,
                        value: lstlocations[i].Id
                   });
                    }
                }
                    component.set("v.locationmap", options);
                }
                 else{
                     var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"),errMsg);
                }
                
                
            },{
                "strAccountId": accountId
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                    //Lagan's changes end

    },
    getResource : function(component) {
        //call to get the resource;
        var locationId = component.get("v.locationId");
        //Lagan' changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchLocationResources', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                   // var retVal = response.getReturnValue();
                var objectData = response.objectData.records;
                var lstresources = JSON.parse(objectData);
               // console.log('the resources are '+lstresources);
                var resourceId = component.get("v.resourceId");
                var options = [];
                for(var i in lstresources){
                    //  if((lstresources[i].Resource__c).slice(0,15) === resourceId){
                      if(lstresources[i].Resource__c === resourceId){
                        options.push({
                            class: "optionClass",
                            label: lstresources[i].Resource__r.Name,
                            value: lstresources[i].Id,
                            selected: true
                        });
                          var objWrapper = component.get("v.referralObj");
                      	  objWrapper.Resource=resourceId;
                           
                    }else{ 
                    options.push({
                        class: "optionClass",
                        label: lstresources[i].Resource__r.Name,
                        value: lstresources[i].Resource__c
                    });
                    }
                }
                    component.set("v.resourcemap", options);
                }
                else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
                
            },{
                "strLocationId": locationId
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                    //Lagan's changes end
                    
        
    },
    submitReferral : function(component) {
      
        var objWrapper = component.get("v.referralObj");
        objWrapper.Phone=component.get("v.userPhone");
        objWrapper.Contact=component.get("v.contactId");
        objWrapper.Archetype=component.get("v.archId");
        objWrapper.isIEESData=component.get("v.isIEESData");
        objWrapper.clientData=JSON.stringify(component.get("v.clientDetails"));
         //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020)
        objWrapper.isFrequentlyPaired=component.get("v.isFrequentlyPaired");
        objWrapper.isRelatedServices=component.get("v.isRelatedServices");
        
       // console.log('objWrapper in cmp--'+JSON.stringify(objWrapper));
       
        //Lagan' changes start
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            var existing_referral_msg = $A.get("$Label.c.existing_referral");
            
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.insertReferral', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    
                    if(!response.objectData.referralexist){
                       var successMsg= $A.get("$Label.c.referralcreated"); 
                        //RE_Release 1.2 – Requirment 361795 & 361782 - Payal Dubela(04/23/2020)
                       component.set("v.isFrequentlyPaired",false);
                       component.set("v.isRelatedServices",false);
                    bSuper.showToast('Success', 'Success',successMsg);
                    
                    //helper.showToast(component, event, helper, 'Success', successMsg);
                    component.set('v.bShowClientTable',true);
                    component.set('v.showClientDetail',true);
                    component.set('v.showreferral',false);
                    component.set('v.bShowResourceDetail',true);                       
                        var methodRef = component.get("v.methodRef");
                        $A.enqueueAction(methodRef);
                        
                        if(document.getElementsByClassName('archtype-banner')[0]){
                            document.getElementsByClassName('archtype-banner')[0].classList.remove('display-none');
                        }
                        if(document.getElementsByClassName('archtype-header')[0]){
                            document.getElementsByClassName('archtype-header')[0].classList.remove('display-none');
                        }
                        if(document.getElementsByClassName('resource-cards-section')[0]){
                            document.getElementsByClassName('resource-cards-section')[0].classList.remove('display-none');
                        }
                        if(document.getElementsByClassName('archtype-filter-section')[0]){
                            document.getElementsByClassName('archtype-filter-section')[0].classList.remove('display-none');
                        }
                        if(document.getElementsByClassName('archtype-map-section')[0]){
                            document.getElementsByClassName('archtype-map-section')[0].classList.remove('display-none');
                        }
                        if(document.getElementsByClassName('empty-div')[0]){
                            document.getElementsByClassName('empty-div')[0].classList.remove('display-none');
                        }
                        
                        // Search Results
                        
                        if (document.getElementsByClassName('myPlanLeftTab')[0]) {
                            document.getElementsByClassName('myPlanLeftTab')[0].classList.remove('slds-hide');
                            document.getElementsByClassName('myPlanLeftTab')[0].classList.add('slds-show');
                        }
                        if (document.getElementsByClassName('planMapSection')[0]) {
                            document.getElementsByClassName('planMapSection')[0].classList.remove('slds-hide');
                            document.getElementsByClassName('planMapSection')[0].classList.add('slds-show');
                        }
                        if (document.getElementsByClassName('search-results-cards')[0]) {
                            document.getElementsByClassName('search-results-cards')[0].classList.remove('slds-hide');
                            document.getElementsByClassName('search-results-cards')[0].classList.add('slds-show');
                        }
    
                    }
                    else{
                                            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"),existing_referral_msg);
                    }
                     
                }
                 else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"),errMsg);
                }
                
                
            },{
                "objWrapper": objWrapper
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                    //Lagan's changes end
                    

        
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
    checkPhoneValidity: function(component, event, phoneval){
	    var bSuper = component.find("bSuper"); 
        var pattern1 =/^(\([0]{3}\) |[0]{3}-)[0]{3}-[0]{4}$/ ;
        var phoneValCorrect;
        var errMsg;
        if(pattern1.test(phoneval)){
             phoneValCorrect = false;
             errMsg = $A.get("$Label.c.InvalidPhoneValue");                
             bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
             //exit;
        }
        else{
            var pattern2 = /^(\([0-9]{3}\) |[0-9]{3}-)[0-9]{3}-[0-9]{4}$/;
            if(pattern2.test(phoneval)){
                phoneValCorrect = true;
            }else
                phoneValCorrect = false;
         }
        return phoneValCorrect;
            
    },
    validateInput : function(component, event, helper) {
         var objWrapper = component.get("v.referralObj");
         //var phoneId = component.find('required_fldPhone');
         var phoneval = component.find('required_fldPhone').get('v.value');
         var inputFieldPhoneVal = this.checkPhoneValidity(component,event,phoneval);
         /* var allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);*/
        var allValid;
        var emailValid = component.find('required_fld');
        if(component.find('required_fld').get('v.value') === ''){
            emailValid.checkValidity();
            emailValid.showHelpMessageIfInvalid();
            allValid = false;
        }else{
            allValid = true;
        }
        if( inputFieldPhoneVal === false ){
            allValid = false;
        }else{
            allValid = true;
        }
        
        
        var phone =component.get("v.userPhone");
        //  if(objWrapper.Organization &&!objWrapper.Location && !objWrapper.Organization && objWrapper.Resource){
        if((!objWrapper.Contact && !component.get("v.isIEESData")) || !objWrapper.Organization || !objWrapper.Location || !objWrapper.Resource || !objWrapper.Email || !phone){
            if(component.get("v.bshowClientLookup")){
                var contactemptymsg =  $A.get("$Label.c.contactemptymsg");  
                helper.showToast(component, event,  $A.get("$Label.c.errorstatus"), contactemptymsg);   
              }else{ 
            helper.showToast(component, event,  $A.get("$Label.c.errorstatus"), $A.get("$Label.c.referralcreationerror"));
              }
           
            
            return false;
        }
        
        else if (allValid === false){
            var emailphoneerror =  $A.get("$Label.c.emailphoneerror"); 
             helper.showToast(component, event,  $A.get("$Label.c.errorstatus"), emailphoneerror);   
            return false;
        }else{
            return true;
        }
    },
     /* check eail validation */
    checkEmailValidity : function(component, event, OriginalEmailId) {
            var pattern = /^([a-zA-Z0-9_+-])+([a-zA-Z0-9_+.-])*\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9])+$/;
            var inputField = OriginalEmailId;
            var value = inputField.get('v.value');
            
            if(!pattern.test(value)){
                inputField.set('v.validity', {valid:false, badInput :true});
                inputField.showHelpMessageIfInvalid();
               }
    },   
    formatPhoneNumber: function(component, phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    getRecord : function(component) {
 
        var accountId = component.get("v.accountId");
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
               component.set("v.accountobjectrecord", storeResponse);
                } else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"),errMsg);
                }
                
                
            },{
                "recID": accountId,
                "ObjectName" : 'Account'
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                    //Lagan's changes end
                    
        
	},
    fetchFavorites : function(component) {
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchFavResources', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                //to do
                if(response.isSuccessful){
                    var favWrapperList = [];
                    var favoriteMap = {"favEntry" : '',"idVal" :''};
                    var favoriteMapList =[];
                    var entryVal ='';
                    var mapVal='';
                    favWrapperList = response.objectData.favorites;
                    component.set("v.favWrapperList",favWrapperList);
                    for (var i = 0; i < favWrapperList.length; i+=1){
                        entryVal ='';
                        mapVal='';
                        favoriteMap = {"favEntry" : '',"idVal" :''};
                        if(!$A.util.isUndefinedOrNull(favWrapperList[i].sResourceName)){
                           entryVal += favWrapperList[i].sResourceName+', ';
                           mapVal +=  favWrapperList[i].sResourceId+', ';
                        }
                        if(!$A.util.isUndefinedOrNull(favWrapperList[i].sLocAddress1)){
                           entryVal += favWrapperList[i].sLocAddress1+', ';
                           mapVal +=  favWrapperList[i].sLocationId+', ';
                        }
                        if(!$A.util.isUndefinedOrNull(favWrapperList[i].sOrgName)){
                           entryVal += favWrapperList[i].sOrgName+', ';
                           mapVal +=  favWrapperList[i].sOrgId+', ';
                        }
                        entryVal = entryVal.trim();
                        if(entryVal.endsWith(',')){
                            entryVal = entryVal.substring(0, entryVal.length - 1);
                        }
                        mapVal = mapVal.trim();
                        if(mapVal.endsWith(',')){
                            mapVal = mapVal.substring(0, mapVal.length - 1);
                        }
                        favoriteMap.favEntry = entryVal;
                        favoriteMap.idVal =mapVal;
                        favoriteMapList.push(favoriteMap);
                        favoriteMapList.sort();
                    }
                    component.set("v.favoriteMap",favoriteMapList);
                } else{
                    var errMsg =  $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"),errMsg);
                }
            },{
                
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
	},
    handleFavoriteChange : function(component,event, helper){
    	var selectedFav = component.get("v.selectedFavValue");
        if(selectedFav.length !== 0){
            var idSetSplit = selectedFav.split(",");
            component.set("v.resourceId",idSetSplit[0].trim());
            component.set("v.locationId",idSetSplit[1].trim());
            component.set("v.accountId",idSetSplit[2].trim());
            component.set("v.referralObj.Organization",idSetSplit[2].trim());
            helper.getLocation(component,event,helper);
            helper.getResource(component,event,helper);
        }
        else{
            component.set("v.accountId","");
            component.set("v.locationId","");
            component.set("v.resourceId","");
            component.set("v.referralObj.Organization","");
        }
    },
    //Venkat: 03/11/2020: Spanish Translation
    createColumnData:function(component){
        var actionListAllClients=[];
        actionListAllClients.push({ label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'View'}, 
                                  { label: $A.get("$Label.c.createreferral"), name:'Create'}, 
                                  { label: $A.get("$Label.c.Request_Consent "), name:'Request'}
                                                             ]}})
        component.set("v.actionListAllClients",actionListAllClients);
        
        var actionListMyClients=[];
        actionListMyClients.push({ label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'View'}, 
                                 { label: $A.get("$Label.c.RE_Select_Client"), name:'select_client'}
                                                             ]}})
        component.set("v.actionListMyClients",actionListMyClients);
    }
})