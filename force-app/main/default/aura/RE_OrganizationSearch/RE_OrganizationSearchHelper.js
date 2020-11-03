({

/* overriding method from service component RE_UtilityServerCallerCmp
 * this function is to get the data from the apex for the inputs given from the UI
 * */

searchAction : function(component, event, helper, organizationName, organizationCity) {
	try{ 
		//show spinner when request sent
		component.set('v.isSpinnerActive',true);
		
		//reference to inherited super component
		var bSuper = component.find("bSuper"); 
		
		//override the method in super class and write your own logic with the response received
		bSuper.callServer(component, 'c.fetchOrganizations', function(response) {
			//hide spinner when server response received
			component.set("v.showNoResults", false);
			component.set('v.isSpinnerActive',false);
			//to do
			if(response.isSuccessful){
				var custs = [];
				var newCusts = [];
				var finalCusts = []; 
				var conts = response.objectData.account;
				for(var key in conts){
					if(conts.hasOwnProperty(key)){
						custs.push({value:conts[key], key:key});
					}
				}
				for(var i=0; i<custs.length; i+=1){
					newCusts = custs[i];
					for(var j=0; j<newCusts.value.length; j+=1){
						finalCusts.push({value:newCusts.value[j],key:newCusts.key});                        
					}
				}
				component.set("v.totalPages", Math.ceil(finalCusts.length/component.get("v.pageSize")));
				component.set("v.allData", finalCusts);
				component.set("v.currentPageNumber",1);
				helper.buildData(component, helper);
				if(finalCusts.length>0){
					document.getElementById("results-heading").style.display="block";
					document.getElementById("headings").style.display="none";
					$A.util.removeClass(component.find("help-btn"),"slds-hide");
					$A.util.addClass(component.find("help-btn"),"slds-show");
					document.getElementsByClassName("add-my-orgn")[0].classList.add("slds-hide");
					document.getElementsByClassName("headingL1")[0].classList.add("slds-hide");
					
				}
				else{
					component.set("v.showNoResults", true);
					document.getElementById("results-heading").style.display="none";
					$A.util.removeClass(component.find("help-btn"),"slds-hide");
					document.getElementById("headings").style.display="block";
					$A.util.addClass(component.find("help-btn"),"slds-show");
					document.getElementsByClassName("add-my-orgn")[0].classList.remove("slds-hide");
					document.getElementsByClassName("headingL1")[0].classList.remove("slds-hide");
				}
			}else{
				component.set("v.showNoResults", true);
				$A.util.removeClass(component.find("help-btn"),"slds-hide");
				$A.util.addClass(component.find("help-btn"),"slds-show");
				//Changed let to Var - Using this Toast to show error when wrong search criteria is provided
				/*var errMsg = $A.get("$Label.c.NoRecordsAvailable");
				bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg); */               }                
        },{
            "organizationName": organizationName,
            "organizationCity": organizationCity
        },false);
    }catch (e) {
    }
    
},
    
    getOrgDetail : function(component) {
        
        try{ 
            //show spinner when request sent
            component.set('v.isSpinnerActive',true);
            
            //reference to inherited super component
            var bSuper = component.find("bSuper"); 
            bSuper.callServer(component, 'c.getUnclaimedOrgDetail', function(response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive',false);
                
                //to do
                if(response.isSuccessful){
                    component.set("v.orgId",response.objectData.Account.Id);
                    component.set("v.orgName",response.objectData.Account.Name);
                    component.set("v.orgType",response.objectData.Account.Type);
                    component.set("v.orgStreet",response.objectData.Account.ShippingStreet);
                    component.set("v.orgState",response.objectData.Account.ShippingState);
                    component.set("v.orgCity",response.objectData.Account.ShippingCity);
                    component.set("v.orgZipcode",response.objectData.Account.ShippingPostalCode);
                    component.set("v.orgUniqueId",response.objectData.Account.OrganizationUniqueId__c);
                    component.set("v.orgWebsite",response.objectData.Account.Website);
                }else{
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);              }                
            },
            {
                orgId : component.get("v.orgId")
            },
             false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    
    
    /*
 * this function is to navigate to the claim site request page with passing with
 * the parameters to copy the data from one page to other page
 * */
handleClaimButton: function(component, event) {
	var buttonvalue = event.getSource().get("v.name");
  component.set("v.orgId",buttonvalue.Id);
	component.set("v.orgName",buttonvalue.Name);
	component.set("v.orgType",buttonvalue.Type);
	component.set("v.orgStreet",buttonvalue.ShippingStreet);
	component.set("v.orgState",buttonvalue.ShippingState);
	component.set("v.orgCity",buttonvalue.ShippingCity);
	component.set("v.orgZipcode",buttonvalue.ShippingPostalCode);
	component.set("v.orgUniqueId",buttonvalue.OrganizationUniqueId__c);
	component.set("v.orgWebsite",buttonvalue.Website);
},
/*
 * this function will build table data
 * based on current page selection
 * */
buildData : function(component, helper) { 
	var data = [];
	var pageNumber = component.get("v.currentPageNumber");
	var pageSize = component.get("v.pageSize");
	var allData = component.get("v.allData");
	allData.sort(function(a, b){
		var nameA=a.value.Name.toLowerCase(), nameB=b.value.Name.toLowerCase()
		if (nameA < nameB){//sort string ascending
			return -1 
		} 
		if (nameA > nameB){
			return 1 
		}
		return 0 //default return value (no sorting)
	})
	var currentData = component.get("v.dataResults");
	var x = (pageNumber-1)*pageSize;
	
	//creating data-table data
        //RE_Release 1.2.1 – Bug 368634 - Payal Dubela(05/19/2020)
        for(; x<(pageNumber)*pageSize; x+=1){
		if(allData[x]){
			data.push(allData[x]);
		}
	}
	if($A.util.isUndefinedOrNull(currentData)){
		component.set('v.dataResults',data);
	}else{
		component.set('v.dataResults',currentData.concat(data));
	}
	if(data.length < pageSize){
		component.set("v.disableScroll",true);
	}else{
	component.set("v.disableScroll",false);
	}
	helper.generatePageList(component, pageNumber);
},

/*
 * this function generate page list
 * */
generatePageList : function(component, pNumber){
	var pageNumber = parseInt(pNumber,10);
	var pageList = [];
	var totalPages = component.get("v.totalPages");
	if(totalPages > 1){
		if(totalPages <= 10){
			var counter = 2;
			for(; counter < (totalPages); counter+=1){
				pageList.push(counter);
			} 
		} else{
			if(pageNumber < 5){
				pageList.push(2, 3, 4, 5, 6);
			} else{
				if(pageNumber>(totalPages-5)){
					pageList.push(totalPages-5, totalPages-4, totalPages-3, totalPages-2, totalPages-1);
				} else{
					pageList.push(pageNumber-2, pageNumber-1, pageNumber, pageNumber+1, pageNumber+2);
				}
			}
		}
	}
	component.set("v.pageList", pageList);
},

bSuper:{}

})