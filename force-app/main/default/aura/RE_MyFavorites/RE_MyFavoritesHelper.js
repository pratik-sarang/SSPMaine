({
    disableCreateButton : function(component){
        
        var buttonCheck = true;
        var checkboxes = component.find("checkBox1");
    if(!$A.util.isUndefinedOrNull(checkboxes) && !Array.isArray(checkboxes)){
          if(checkboxes.get("v.value").bisSelected){
            buttonCheck=false;
          }
    }
       // var checkboxesChecked = [];
        for (var i=0; i<checkboxes.length; i+= 1) {
            var bCheck = checkboxes[i].get("v.value").bisSelected;
           
            // And stick the checked ones onto an array...
            if (bCheck) {
                buttonCheck = false;
                
            }
        }
       
        if(!buttonCheck){
            component.set("v.bCreateRefrral",false);
        }
        else{
            component.set("v.bCreateRefrral",true);
        }
        
    },
	getFavResources : function(component,helper) {
		
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
                    var weekdayValue;
                    var arrayMyResource = response.objectData.favorites;
                   
                    //for(var i in arrayMyResource){
                    for(var i = 0; i < arrayMyResource.length; i+=1){ 
                        
              var objMyResourcesOperatingHours = JSON.parse(
                arrayMyResource[i].sOperatingHoursData
              );
              if (objMyResourcesOperatingHours !== null) {
                // Kojashree : 20Dec LV issue fix
                weekdayValue = helper.getDayName();
                //Nandita 6-feb-2020 : Updated logic for the hours of operation
                var LocResourceNotes = arrayMyResource[i].sNotes;
                //var lstClosedDays = arrayMyResource[i].lstClosedDays;
                var isContainsTodayDay =
                  objMyResourcesOperatingHours[weekdayValue][2] === "true"
                    ? true
                    : false; //lstClosedDays.includes(weekdayValue);
                if (
                  objMyResourcesOperatingHours[weekdayValue][3] === "false" &&
                  LocResourceNotes !== null &&
                  LocResourceNotes !== ""
                ) {
                  arrayMyResource[i].sOperatingHoursToday = "";
                } else {
                  if (isContainsTodayDay === true) {
                    arrayMyResource[i].sOperatingHoursToday =
                      weekdayValue + " Closed";
                  } else if (
                    !isContainsTodayDay &&
                    (!$A.util.isEmpty(
                      objMyResourcesOperatingHours[weekdayValue][0]
                    ) ||
                      !$A.util.isEmpty(
                        objMyResourcesOperatingHours[weekdayValue][1]
                      ))
                  ) {
                    arrayMyResource[i].sOperatingHoursToday =
                      $A.get("$Label.c.today") +
                      " " +
                      objMyResourcesOperatingHours[weekdayValue][0] +
                      " " +
                      $A.get("$Label.c.to") +
                      " " +
                      objMyResourcesOperatingHours[weekdayValue][1];
                  } else if (
                    $A.util.isEmpty(objMyResourcesOperatingHours[weekdayValue])
                  ) {
                    arrayMyResource[i].sOperatingHoursToday = "";
                  }
                }
              } else {
                arrayMyResource[i].sOperatingHoursToday = "";
              }
              /* if(objMyResourcesOperatingHours != null){
                            if($A.util.isUndefinedOrNull(objMyResourcesOperatingHours) || $A.util.isEmpty(objMyResourcesOperatingHours[weekdayValue])){
                                arrayMyResource[i].sOperatingHoursToday = '';
                            }else{
                                arrayMyResource[i].sOperatingHoursToday = $A.get('$Label.c.today') + ' ' + objMyResourcesOperatingHours[weekdayValue].replace('##', $A.get('$Label.c.to'));
                                
                            } 
                        } */
                        var phone = arrayMyResource[i].sOrgPhone;
                        if(phone!== null && phone!=='' && phone!==undefined)//Kojashree 20Dec LV issue fix
                        {
                            var formatedPhone = helper.formatPhoneNumber(phone);
                            arrayMyResource[i].sOrgPhone=formatedPhone;
                        }
                    }
                    component.set('v.favorites',arrayMyResource);
                    
				}
			},{
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

	},
    
    navigateToResourceDetail: function(component, event){
      var itemIndex = event.target.getAttribute("data-card");
      var itemResource = component.get("v.favorites")[itemIndex];
       
        var encodeZip = btoa(itemResource.sContactZipCode);
        var encodeResourceId = btoa(itemResource.sResourceId);
        var encodeLocationId = btoa(itemResource.sLocationId);
        var url = 'resource-details?zipcode='+encodeZip+'&resourceId='+encodeResourceId+'&locationId='+encodeLocationId;
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
    },
    
    /* get day name */
    getDayName : function(){
        var weekdays = new Array(7);
        weekdays[0] = "Sunday";
        weekdays[1] = "Monday";
        weekdays[2] = "Tuesday";
        weekdays[3] = "Wednesday";
        weekdays[4] = "Thursday";
        weekdays[5] = "Friday";
        weekdays[6] = "Saturday";
        
        var current_date = new Date();
        var weekdayValue = current_date.getDay();
        return weekdays[weekdayValue];
    },
    /* format phone number */
    formatPhoneNumber: function(phoneNumber) {
        var phone = (""+phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if(!formatedPhone){
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    }
})