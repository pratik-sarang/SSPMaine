({
    validateZipCode : function() {
        var invalid = false;
        /*var zipCodePattern = /^[0-9]{5}$/;
        var zipCode = component.get("v.zipCode");
        if(!zipCodePattern.test(zipCode))
            invalid = true;*/
        return invalid;    
    },
    submitZipCode : function(component, event){ 
        var result = this.validateZipCode();         
        if(!result){
            var zipCode = component.get("v.zipCode");
            var encodedZip = window.btoa(zipCode);
            sessionStorage.setItem("zipCodeVal", encodedZip);
            component.set("v.showDiscoverResource",false);
            component.set("v.showSpecifySituation",true);
        }
        else{
            this.showToast(component, event, $A.get("$Label.c.RE_ZipCode_Error"));
            component.set("v.showDiscoverResource",true);
            component.set("v.showSpecifySituation",false); 
        }        
    },
    getResourceData: function(component){   
        var cachedZipCode = component.get("v.zipCode");
        try{ 
            component.set('v.isSpinnerActive',true);
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.getArchetypeResources', function(response) {  
                component.set("v.usrlatlng",response.objectData.lstArchetypeDetails.strUserLatLong);
                if(response.objectData.lstArchetypeDetails.resourceCount !== undefined){
                    if(component.get("v.onLoad") || component.get("v.updateResources")){
                        var lstGoalDomains = [];
                        if(response.objectData.lstArchetypeDetails.lstCategoryBlock !== undefined){
                            for(var i=0;i<response.objectData.lstArchetypeDetails.lstCategoryBlock.length;i+=1)
                            {
                                var catData = response.objectData.lstArchetypeDetails.lstCategoryBlock[i];
                                for(var j=0; j<catData.lstGoalBlock.length; j+=1)
                                {   
                                    var goalData = catData.lstGoalBlock[j];
                                    if(!$A.util.isUndefinedOrNull(goalData.goalId))//Added by Megha to fix bug- 342093
                                    { 
                                        var goalDomains = catData.lstGoalBlock[j].goalDomain;  
                                        lstGoalDomains.push(goalDomains);  
                                    }
                                }
                            }
                        }
                        
                        var domainArr = []; 
                        var applicableDomainArr = [];  
                        var lstAllDomains = component.get("v.lstAllDomains");                
                        for(var key in lstAllDomains){  
                            if(lstGoalDomains.includes(lstAllDomains[key])){
                                var domain = {name:key, value:lstAllDomains[key], isPresent:lstGoalDomains.includes(lstAllDomains[key]), isChecked:lstGoalDomains.includes(lstAllDomains[key])};
                                domainArr.push(domain);
                                applicableDomainArr.push(domain);
                            }else{
                                var domainObj = {name:key, value:lstAllDomains[key], isPresent:lstGoalDomains.includes(lstAllDomains[key]), isChecked:lstGoalDomains.includes(lstAllDomains[key])};
                                domainArr.push(domainObj);
                            }                                                            
                        } 
                        component.set("v.lstApplicableGoalDomains", applicableDomainArr);
                        component.set("v.lstAvailableDomains", domainArr);
                        component.set("v.showAllDomains", true);
                    }
                    //hide spinner when server response received
                    component.set('v.isSpinnerActive',false); 
                    component.set("v.resourcedata", response);
                    component.set("v.resourcedatacopy", response);
                    component.set("v.loadResource", true);
                    component.set("v.onLoad", false);
                    component.set("v.updateResources", false);
                    if(response.objectData.lstArchetypeDetails.resourceCount===0){
                        component.set("v.showAllDomains", false);
                    }
                }
            },{
                "strZipCodeParam" : cachedZipCode,
                "strArchetypeIdParam" : component.get("v.archeTypeId"),
                "strSubArchetypeIdParam" : component.get("v.selectedArcheTypeId"), 
                "strDomainParam": component.get("v.strDomains"),
                "strGoalParam": '',
                "strSeeAllLess":'see-less',
                "selectedHours":component.get("v.selectedHours")
            },false);
        }catch (e) {            
            bSuper.consoleLog(e.stack, true);
        }
    },    
    showToast : function(component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            "type": $A.get("$Label.c.errorstatus"),
            duration : '5000'
        });
        toastEvent.fire();
    },
    getCategories : function(component){
        var lstAllDomains = component.get("v.lstAllDomains");        
        var catagoriesValue = '';
        for(var key in lstAllDomains){                                                          
            if(catagoriesValue !== ''){
                catagoriesValue = catagoriesValue + ',' +lstAllDomains[key];
            }else{
                catagoriesValue = lstAllDomains[key];
            }                    
        }                
        component.set("v.strDomains",catagoriesValue);
    },
    navigateToUrl : function(){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({            
            "url": '/landing-page'
        });
        urlEvent.fire();
    },
    mapDataHelper: function(component,goalData,clickedIndex,resourceCardOpenCloseIndx){ 
        var mapSelectedData = [];
        var map =  component.get("v.mapData");
        var location = (goalData.locationLatLong).split('##');
        var data=component.get("v.onloadmapdata");
        for(var k=0;k<map.length;k+=1){
            if(parseFloat(map[k].lat) === parseFloat(location[0]) && parseFloat(map[k].lng) === parseFloat(location[1])){
                map[k].selected = (resourceCardOpenCloseIndx !== 0)? "selectedLocation": "None";
				 mapSelectedData.push(map[k]);
               }else{
                   if(map[k].selected !== "My location"){
                       data[k].selected = "None";
                   }
                	mapSelectedData.push(map[k]);    
                }
        }
       // added by Pankaj [05/12/2019] as part of fixing map when the zipcode on contact is invalid
       if(Array.isArray(map) && map.length>0){
           component.set("v.showMultiPleMarker",false);
           component.set("v.mapData", map);
           component.set("v.showMultiPleMarker",true);
       }else{
           component.set("v.showMultiPleMarker",false);
           component.set("v.showMultiPleMarkerForCompleted", false);
           component.set("v.showSingleMarkerForCompleted",false);
       }
    },
    submitHandler :function(component, event, helper){
        if(!component.get("v.selectedArcheTypeId")){
        	helper.showToast(component, event, $A.get("$Label.c.RE_Role_Error"));   
        } 
        var roleVal = component.find("Role").get("v.value");
        //added loop for getting the Selected ArcheType Title by [CHFS Developer-Mohan-12/02/19] 
          var titlelist = component.get("v.archeTypeList");
        for(var strbal  in titlelist ){
            if(titlelist[strbal].Id === roleVal){
                component.set("v.selectedArcheTypeTitle",titlelist[strbal].Title__c);
            } }
        component.set("v.selectedArcheTypeId",roleVal);
        var encodedRole = window.btoa(roleVal);
        window.localStorage.setItem('selectedRole', encodedRole); 
        //added Timeout for Pop up closing by [CHFS Developer-Mohan-12/02/19] 
        window.setTimeout(
            $A.getCallback(function() {
        component.set("v.showSpecifySituation",false);
            }), 500
        );  
        helper.getCategories(component,event,helper);        
        helper.getResourceData(component);  
    },
    doInitHandler : function(component, event, helper){
        var cachedZipCode=null; 
        var encodedZip = sessionStorage.getItem('zipCodeVal');
        if(encodedZip!==null){  
        	cachedZipCode = window.atob(encodedZip); 
        }
        //for role caching
        var cachedRole=null; 
        var encodedRole = window.localStorage.getItem('selectedRole');
        if(encodedRole!==null){  
        	cachedRole = window.atob(encodedRole); 
        }
        component.set("v.selectedArcheTypeId",cachedRole);
        var url = new URL(document.location.href);
        var urlSplit = url.searchParams.get("id");
        if(!$A.util.isUndefinedOrNull(urlSplit)){
            var decryptedId;            
            if(btoa(atob(urlSplit))===urlSplit){
                decryptedId = window.atob(urlSplit);                
            }
            else{
                decryptedId = urlSplit;                
            }            
            component.set("v.archeTypeId",decryptedId);
            var oldCombination = window.localStorage.getItem('roleArchCombination');
            var roleArchetypeCombination = cachedRole+'-'+decryptedId;
            window.localStorage.setItem('roleArchCombination',roleArchetypeCombination);
        }
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.processUserInfo', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                component.set("v.userlocation",response.objectData.mylocationdata);
                component.set("v.lstAllDomains",response.objectData.mapAvailableDomains); //new Added by Ashwin
                if(response.objectData.isGuestUser === true){
                    if(cachedZipCode !== null){
                        component.set("v.zipCode",cachedZipCode);
                    	component.set("v.showDiscoverResource",false);
                        component.set("v.showSpecifySituation",true);
                    }
                    else{
                        component.set("v.showDiscoverResource",true);
                    }
                }else if(response.objectData.isGuestUser === false){
                    if(response.objectData.zipCodeProfile.length > 0){
                       if(cachedZipCode !== null){
                        component.set("v.zipCode",cachedZipCode);
                       }else{
                        var zipEncoded = window.btoa(response.objectData.zipCodeProfile);
            			sessionStorage.setItem("zipCodeVal", zipEncoded);
                         component.set("v.zipCode",response.objectData.zipCodeProfile);
                       }
                        //window.localStorage.setItem('zipCodeVal', zipEncoded);
                        component.set("v.showDiscoverResource",false);
                        if($A.util.isUndefinedOrNull(oldCombination) || !oldCombination.includes(decryptedId)){
                        	component.set("v.showSpecifySituation",true);
                        }
                        else{
                            helper.getCategories(component,event,helper);
                            helper.getResourceData(component);
                            component.set("v.showSpecifySituation",false);
                        }
                    }
                    else if(response.objectData.zipCodeProfile.length === 0 && cachedZipCode !== null){
                        component.set("v.zipCode",cachedZipCode);
                        component.set("v.showDiscoverResource",false);
                        if($A.util.isUndefinedOrNull(oldCombination) || !oldCombination.includes(decryptedId)){
                        	component.set("v.showSpecifySituation",true);
                        }
                        else{
                            helper.getCategories(component,event,helper);
                            helper.getResourceData(component);
                            component.set("v.showSpecifySituation",false);
                        }
                    }else{
                        component.set("v.showDiscoverResource",true);
                    }
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                component.set("v.loadChildCmp",true);
                var subArcheTypeRecords=response.objectData.archTypeRecords;
                if(subArcheTypeRecords!== undefined){                    
                    if(component.get("v.selectedArcheTypeId") === null || component.get("v.selectedArcheTypeId") === undefined)
                    	component.set("v.selectedArcheTypeId",subArcheTypeRecords[0].Id);
                    component.set("v.archetypeTitle",subArcheTypeRecords[0].ParentArchetype__r.Title__c);
                    component.set("v.archetypeBannerImage",subArcheTypeRecords[0].ParentArchetype__r.BannerImage__c);                    
                    component.set("v.archeTypeList",response.objectData.archTypeRecords);
                    component.set("v.showSubArcheTypeList",true);
                }                
            },{
                "strarchId" : component.get("v.archeTypeId"),
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
                
        component.set("v.isDisabled",true);
    }
})