({
  getResourceDetails : function(component, event)
  {
   var mapdata = [];
   var data = component.get("v.resourcedata");
   var usrloc = data.objectData.lstArchetypeDetails.strUserLatLong;
   var userLocationData =  component.get("v.userlocation");

   if(data.objectData.lstArchetypeDetails.lstCategoryBlock !== undefined){
       for(var i=0;i<data.objectData.lstArchetypeDetails.lstCategoryBlock.length;i+=1)
       {
           var catData = data.objectData.lstArchetypeDetails.lstCategoryBlock[i];
           if(!$A.util.isUndefinedOrNull(catData.lstGoalBlock))
           {
               for(var j=0; j<catData.lstGoalBlock.length; j+=1)
               {
                   var goalData = catData.lstGoalBlock[j];
        if(!$A.util.isUndefinedOrNull(goalData.goalId))//Added by Megha to fix bug- 342093
        {
          if(!$A.util.isUndefinedOrNull(goalData.lstResourceTile))
          {
            var resdatalen = (goalData.lstResourceTile.length > 2) ? 2 : goalData.lstResourceTile.length;
            for(var k=0; k<goalData.lstResourceTile.length; k+=1) // Removed k<resdatalen because of length 2, "locationIsClosedDay" & "locationOperatingHours" data was not getting populated
            {
              var resourceData = goalData.lstResourceTile[k];
              //weekdayValue = helper.getDayName(); commented this because helper.getDayName() and this.getDayName() was not working to call this method.
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
              var weekDay = weekdays[weekdayValue];
                                  var operationghours=JSON.parse(resourceData.locationOperatingHours);
                                  var notes=resourceData.locResTimeNotes;
                                  
                                  if(!$A.util.isUndefinedOrNull(operationghours) && operationghours[weekDay] !== ''){
                                     if(!$A.util.isUndefinedOrNull(operationghours[weekDay][3])){
                                          if(operationghours[weekDay][2]==='true' && operationghours[weekDay][3]==='true'){
                                              resourceData.locationIsClosedDay = weekDay+' '+$A.get('$Label.c.referralstatusclosed');
                                              resourceData.locationOperatingHours = '';
                                          }else if(!$A.util.isUndefinedOrNull(operationghours) && operationghours[weekDay][3]==='true' && !$A.util.isUndefinedOrNull(operationghours[weekDay]) && operationghours[weekDay][0] !== '' && operationghours[weekDay][1]!==''){
                                              resourceData.locationOperatingHours = $A.get('$Label.c.today') + ' ' +operationghours[weekDay][0]+' '+$A.get('$Label.c.to')+' '+operationghours[weekDay][1];
                                              resourceData.locationIsClosedDay='';
                                          }else if(!$A.util.isUndefinedOrNull(notes) && notes !== null && notes!==''){
                                              resourceData.locationOperatingHours = '';
                                              resourceData.locationIsClosedDay='';
                                          }else if(operationghours[weekDay][3]==='false' && operationghours[weekDay][2]==='true'){
                                              resourceData.locationIsClosedDay = weekDay+' '+$A.get('$Label.c.referralstatusclosed');
                                              resourceData.locationOperatingHours = '';
                                          }else if(!$A.util.isUndefinedOrNull(operationghours) && operationghours[weekDay][3]==='false' && !$A.util.isUndefinedOrNull(operationghours[weekDay]) && operationghours[weekDay][0] !== '' && operationghours[weekDay][1]!==''){
                                              resourceData.locationOperatingHours = $A.get('$Label.c.today') + ' ' +operationghours[weekDay][0]+' '+$A.get('$Label.c.to')+' '+operationghours[weekDay][1];
                                              resourceData.locationIsClosedDay='';
                                          }else{
                                              resourceData.locationOperatingHours = '';
                                              resourceData.locationIsClosedDay='';
                                          }
                                     }
        
                                  }
                                  var sAddressLine = '';                                
                                  if(!$A.util.isUndefinedOrNull(resourceData.locationAddress1) && resourceData.locationAddress1 !== ''){
                                      sAddressLine += resourceData.locationAddress1+', ';
                                  }
                                  if(!$A.util.isUndefinedOrNull(resourceData.locationAddress2) && resourceData.locationAddress2 !== ''){
                                      sAddressLine += resourceData.locationAddress2+', ';
                                  }
                                  if(!$A.util.isUndefinedOrNull(resourceData.locationCity) && resourceData.locationCity !== ''){
                                      sAddressLine += resourceData.locationCity+', ';
                                  }
                                  if(!$A.util.isUndefinedOrNull(resourceData.locationState) && resourceData.locationState !== ''){
                                      sAddressLine += resourceData.locationState+' ';
                                  }
                                  if(!$A.util.isUndefinedOrNull(resourceData.locationZipcode) && resourceData.locationZipcode !== ''){
                                      sAddressLine += resourceData.locationZipcode;
                                  }
                                  if(!$A.util.isUndefinedOrNull(sAddressLine) && sAddressLine !== '')
                                  {
                                      sAddressLine = sAddressLine.trim();
                                      if(sAddressLine.endsWith(',')){
                                          sAddressLine = sAddressLine.substring(0, sAddressLine.length - 1);
                                      } 
                                      resourceData.locationAddressFinal = sAddressLine;
                                  }
                                  else{
                                      resourceData.locationAddressFinal='';
                                  }
                                  if(k<resdatalen){
                                      mapdata.push({goalId:goalData.goalId, resourceData:resourceData});
                                  }                                 
                              }
                          }
                          else{
                              mapdata.push({goalId:goalData.goalId});
                          }
                      }
                      else{
                          data.objectData.lstArchetypeDetails.lstCategoryBlock[i].lstGoalBlock.splice(j,1);
                          j-=1;
                          
                      }
                  }
              }
              else{
                  data.objectData.lstArchetypeDetails.lstCategoryBlock.splice(i,1);
              }
          }
      }
      component.set("v.archetypeResource",data.objectData.lstArchetypeDetails);
      component.set("v.isGuest", data.objectData.lstArchetypeDetails.bIsGuestUser);
      component.set("v.isResident", data.objectData.lstArchetypeDetails.bIsResidentUser);
      component.set("v.mapdata", mapdata);
      this.mapDataHelper(component, event, mapdata, usrloc, userLocationData);
  },
  handleMapAccordianClickHelper:function(component,event,resourceIndexData,generalId,clickedIndex){
      var appEvent = $A.get("e.c:RE_LightningMapEvent");
      appEvent.setParams({
          "mapMarkersData" :  [],
          "mapMarkerSingleData":resourceIndexData,
          "index":generalId,
          "resourceClickedIndex":clickedIndex
      });
      appEvent.fire();
  },
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
  getOptOutInformation: function(component, event, helper, rsAchResReferralStatus){
      try{
         component.set('v.displayLoader',true);
          //reference to inherited super component
          var bSuper = component.find("bSuper"); 
          //override the method in super class and write your own logic with the response received
          bSuper.callServer(component, 'c.getOptOutInfoSharingDetails', function(response) {
              //hide spinner when server response received
              component.set('v.displayLoader',false);
              if(response.isSuccessful){  
                  component.set("v.cartOptIn", response.objectData.OptOutInfoSharing); 
                  
                  if(!component.get("v.cartOptIn")){
                    component.set('v.displayLoader',true);
                      component.set("v.isConsentAgreed", false);
                      if(rsAchResReferralStatus === 'Draft')
                          helper.handleAchDraftConnectHelper(component);
                      else
                          helper.createReferralOnConnect(component,event);
                     component.set('v.displayLoader',false);
                  }
              }
          }, null,false);
      }catch (e) {
          bSuper.consoleLog(e.stack, true);
      }
  },
  createReferralOnConnect: function(component){
      try{
          component.set('v.isSpinnerActive',true);

          var resourceRecord = component.get("v.selectedCardValue");
          var locationID = resourceRecord.locationId;
    resourceRecord.sArchetypeid=component.get("v.archetypeId");
          
          var bSuper = component.find("bSuper"); 
          bSuper.callServer(component, 'c.insertReferralForResident', function(response) {
              if(response.isSuccessful){
                  var accountName;
                  var resourceName;
                  accountName = resourceRecord.accountProviderName;
                  resourceName = resourceRecord.resourceName;
                  resourceRecord.isConnectButtonDisabled = true;
                  resourceRecord.referralId = response.objectData.referals.Id;
                  
                  //For archetype
                  resourceRecord.sArchetypeid=component.get("v.archetypeId");
                  
          component.set(
            "v.archetypeResource",
            component.get("v.archetypeResource")
          );
          component.set("v.isSelectedResConDisabled", true);
          bSuper.showToast(
            $A.get("$Label.c.successstatus"),
            "success",
             $A.get("$Label.c.successfully") + ' '+
              accountName + ' '+
              $A.get("$Label.c.for_resource") + ' '+
              resourceName
          );
        }
      },
      {
        strobjResource: JSON.stringify(resourceRecord),
        locationID: locationID,
        bConsentAgreed: component.get("v.isConsentAgreed")
        //   "sArchid" : component.get("v.archetypeId")
      },
      false
    );
  } catch (e) {
    component.set("v.isSpinnerActive", false);
    bSuper.consoleLog(e.stack, true);
  }
},

  navigateToResourceDetail: function(component, event){
      var cardKey = event.target.getAttribute("data-cardkey");
      var cardParent = event.target.getAttribute("data-cardparent");
      var cardGrandParent = event.target.getAttribute("data-cardgrandparent");
      var itemResource = component.get("v.archetypeResource.lstCategoryBlock")[cardGrandParent].lstGoalBlock[cardParent].lstResourceTile[cardKey];       
      var encodeZip = btoa(component.get("v.zipcode"));
      var encodeResourceId = btoa(itemResource.resourceId);
      var encodeLocationId = btoa(itemResource.locationId);
      var url = 'resource-details?zipcode='+encodeZip+'&resourceId='+encodeResourceId+'&locationId='+encodeLocationId;
      var urlEvent = $A.get("e.force:navigateToURL");
      urlEvent.setParams({
          "url": url
      });
      urlEvent.fire();
  },

  handleAchDraftConnectHelper: function(component){
      try{
          var selResource = component.get("v.selectedCardValue");
          //reference to inherited super component
          var bSuper = component.find("bSuper"); 
          //override the method in super class and write your own logic with the response received
          bSuper.callServer(component, 'c.connectDraftReferralsFromArcheTypeResults', function(response) {
              //hide spinner when server response received
              component.set('v.isSpinnerActive',false);
              //to do
              if(response.isSuccessful){
                  var accountName = selResource.accountProviderName;
                  var resourceName = selResource.resourceName;
                selResource.isConnectButtonDisabled = true; 
          selResource.objReferral.Status__c =
            response.objectData.resReferralStatus;
          component.set(
            "v.archetypeResource",
            component.get("v.archetypeResource")
          );
          bSuper.showToast(
            $A.get("$Label.c.successstatus"),
            "success",
             $A.get("$Label.c.successfully") + ' '+
              accountName + ' '+
              $A.get("$Label.c.for_resource") + ' '+
              resourceName
          );
          var ccEvent = $A.get("e.c:RE_CountEvent");
          ccEvent.setParams({
            cartCount: response.objectData.draftReferralCount
          });
          ccEvent.fire();
        } else {
          var errMsg = $A.get("$Label.c.servererror");
          bSuper.showToast(
            $A.get("$Label.c.errorstatus"),
            $A.get("$Label.c.errorstatus"),
            errMsg
          );
        }
      },
      {
        sAchReferralId: selResource.objReferral.Id,
        bAchConsentAgreed: component.get("v.isConsentAgreed")
      },
      false
    );
  } catch (e) {
    bSuper.consoleLog(e.stack, true);
  }
},
  loadMoreResourceHelper: function(component, event){
    var mapdata = [];
      try{
        component.set('v.isSpinnerActive',true);
          var currentGoalData = event.getSource().get("v.value");
          var bSuper = component.find("bSuper");
          bSuper.callServer(component, 'c.getArchetypeResources', function(response){
              //Start - To get new Resources based on Goal
              var data = response;
              var usrloc = data.objectData.lstArchetypeDetails.strUserLatLong;
              var userLocationData =  component.get("v.userlocation");
              var newResMapData = [];
              if(!$A.util.isUndefinedOrNull(userLocationData)){
                  userLocationData = JSON.parse(userLocationData);
                  usrloc = userLocationData.Contact.ContactGeoLocation__c.latitude+'##'+userLocationData.Contact.ContactGeoLocation__c.longitude;
              }
              if(data.objectData.lstArchetypeDetails.lstCategoryBlock !== undefined)
              {
                  for(var i=0;i<data.objectData.lstArchetypeDetails.lstCategoryBlock.length;i+=1)
                  {
                      var catData = data.objectData.lstArchetypeDetails.lstCategoryBlock[i];
                      if(!$A.util.isUndefinedOrNull(catData.lstGoalBlock))
                      {
                          for(var j=0; j<catData.lstGoalBlock.length; j+=1)
                          {
                              var goalData = catData.lstGoalBlock[j];
                              if(!$A.util.isUndefinedOrNull(goalData.goalId))//Added by Megha to fix bug- 342093
                    {   
                                  if(!$A.util.isUndefinedOrNull(goalData.lstResourceTile))
                                  {
                                      for(var k=0; k<goalData.lstResourceTile.length; k+=1)
                                      {
                                          var resourceData = goalData.lstResourceTile[k];
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
                                          var weekDay = weekdays[weekdayValue];
                                          
                      //Nandita 12-Feb-2020: Updated logic for Hours of Operation.
                      var objMyResourcesOperatingHours = JSON.parse(
                        resourceData.locationOperatingHours
                      );
                      var notes = resourceData.locResTimeNotes;
                      if (
                        !$A.util.isUndefinedOrNull(
                          objMyResourcesOperatingHours
                        ) &&
                        objMyResourcesOperatingHours[weekDay] !== ""
                      ) {
                        if (
                          !$A.util.isUndefinedOrNull(
                            objMyResourcesOperatingHours[weekDay][3]
                          )
                        ) {
                          if (
                            objMyResourcesOperatingHours[weekDay][2] ===
                              "true" &&
                            objMyResourcesOperatingHours[weekDay][3] ===
                              "true"
                          ) {
                            resourceData.locationIsClosedDay =
                              weekDay +
                              " " +
                              $A.get("$Label.c.referralstatusclosed");
                            objMyResourcesOperatingHours.locationOperatingHours =
                              "";
                          } else if (
                            !$A.util.isUndefinedOrNull(
                              objMyResourcesOperatingHours
                            ) &&
                            objMyResourcesOperatingHours[weekDay][3] ===
                              "true" &&
                            !$A.util.isUndefinedOrNull(
                              objMyResourcesOperatingHours[weekDay]
                            ) &&
                            objMyResourcesOperatingHours[weekDay][0] !== "" &&
                            objMyResourcesOperatingHours[weekDay][1] !== ""
                          ) {
                            resourceData.locationOperatingHours =
                              $A.get("$Label.c.today") +
                              " " +
                              objMyResourcesOperatingHours[weekDay][0] +
                              " " +
                              $A.get("$Label.c.to") +
                              " " +
                              objMyResourcesOperatingHours[weekDay][1];
                            resourceData.locationIsClosedDay = "";
                          } else if (
                            !$A.util.isUndefinedOrNull(notes) &&
                            notes !== null &&
                            notes !== ""
                          ) {
                            resourceData.locationOperatingHours = "";
                            resourceData.locationIsClosedDay = "";
                          } else if (
                            objMyResourcesOperatingHours[weekDay][3] ===
                              "false" &&
                            objMyResourcesOperatingHours[weekDay][2] ===
                              "true"
                          ) {
                            resourceData.locationIsClosedDay =
                              weekDay +
                              " " +
                              $A.get("$Label.c.referralstatusclosed");
                            resourceData.locationOperatingHours = "";
                          } else if (
                            !$A.util.isUndefinedOrNull(
                              objMyResourcesOperatingHours
                            ) &&
                            objMyResourcesOperatingHours[weekDay][3] ===
                              "false" &&
                            !$A.util.isUndefinedOrNull(
                              objMyResourcesOperatingHours[weekDay]
                            ) &&
                            objMyResourcesOperatingHours[weekDay][0] !== "" &&
                            objMyResourcesOperatingHours[weekDay][1] !== ""
                          ) {
                            resourceData.locationOperatingHours =
                              $A.get("$Label.c.today") +
                              " " +
                              objMyResourcesOperatingHours[weekDay][0] +
                              " " +
                              $A.get("$Label.c.to") +
                              " " +
                              objMyResourcesOperatingHours[weekDay][1];
                            resourceData.locationIsClosedDay = "";
                          } else {
                            resourceData.locationOperatingHours = "";
                            resourceData.locationIsClosedDay = "";
                          }
                        }
                      }
                      var sAddressLine = "";
                      if (
                        !$A.util.isUndefinedOrNull(
                          resourceData.locationAddress1
                        ) &&
                        resourceData.locationAddress1 !== ""
                      ) {
                        sAddressLine += resourceData.locationAddress1 + ", ";
                      }
                      if (
                        !$A.util.isUndefinedOrNull(
                          resourceData.locationAddress2
                        ) &&
                        resourceData.locationAddress2 !== ""
                      ) {
                        sAddressLine += resourceData.locationAddress2 + ", ";
                      }
                      if (
                        !$A.util.isUndefinedOrNull(
                          resourceData.locationCity
                        ) &&
                        resourceData.locationCity !== ""
                      ) {
                        sAddressLine += resourceData.locationCity + ", ";
                      }
                      if (
                        !$A.util.isUndefinedOrNull(
                          resourceData.locationState
                        ) &&
                        resourceData.locationState !== ""
                      ) {
                        sAddressLine += resourceData.locationState + " ";
                      }
                      if (
                        !$A.util.isUndefinedOrNull(
                          resourceData.locationZipcode
                        ) &&
                        resourceData.locationZipcode !== ""
                      ) {
                        sAddressLine += resourceData.locationZipcode;
                      }
                      if (
                        !$A.util.isUndefinedOrNull(sAddressLine) &&
                        sAddressLine !== ""
                      ) {
                        sAddressLine = sAddressLine.trim();
                        if (sAddressLine.endsWith(",")) {
                          sAddressLine = sAddressLine.substring(
                            0,
                            sAddressLine.length - 1
                          );
                        }
                        resourceData.locationAddressFinal = sAddressLine;
                      } else {
                        resourceData.locationAddressFinal = "";
                      }
                      newResMapData.push({
                        goalId: goalData.goalId,
                        resourceData: resourceData
                      });
                    }
                  } else {
                    mapdata.push({ goalId: goalData.goalId });
                  }
                } else {
                  data.objectData.lstArchetypeDetails.lstCategoryBlock[
                    i
                  ].lstGoalBlock.splice(j, 1);
                  j -= 1;
                }
              }
            } else {
              data.objectData.lstArchetypeDetails.lstCategoryBlock.splice(
                i,
                1
              );
            }
          }
        }
        //End - To get new Resources based on Goal
        //Start- Code to avoid duplicate resources
        var allMapdata = component.get("v.mapdata").concat(newResMapData);
        var uniqueGoalIdResId = [];
        var uniqueRes = [];
        for (i = 0; i < allMapdata.length; i += 1) {
          if (allMapdata[i].goalId && allMapdata[i].resourceData) {
            if (
              uniqueGoalIdResId.indexOf(
                allMapdata[i].goalId +
                  "," +
                  allMapdata[i].resourceData.resourceId
              ) === -1
            ) {
              uniqueGoalIdResId.push(
                allMapdata[i].goalId +
                  "," +
                  allMapdata[i].resourceData.resourceId
              );
              uniqueRes.push({
                goalId: allMapdata[i].goalId,
                resourceData: allMapdata[i].resourceData
              });
            }
          }
        }
        component.set("v.mapdata", uniqueRes);
        //End- Code to avoid duplicate resources
        //Start - To attach new Resources for Goal on click of See All Resources
        var newResourceTilte =
          data.objectData.lstArchetypeDetails.lstCategoryBlock[0]
            .lstGoalBlock[0].lstResourceTile;
        var allData = component.get("v.resourcedata");
        var breakFromLoop = false;
        if (
          allData.objectData.lstArchetypeDetails.lstCategoryBlock !==
          undefined
        ) {
          for (
             i = 0;
            i <
            allData.objectData.lstArchetypeDetails.lstCategoryBlock.length;
            i += 1
          ) {
             catData =
              allData.objectData.lstArchetypeDetails.lstCategoryBlock[i];
            if (!$A.util.isUndefinedOrNull(catData.lstGoalBlock)) {
              for (j = 0; j < catData.lstGoalBlock.length; j += 1) {
                 goalData = catData.lstGoalBlock[j];
                if (!$A.util.isUndefinedOrNull(goalData.goalId)) {
                  if (!$A.util.isUndefinedOrNull(goalData.lstResourceTile)) {
                    if (goalData.goalId === currentGoalData.goalId) {
                      goalData.lstResourceTile = [];
                      goalData.lstResourceTile = newResourceTilte;
                      var extraResCount = goalData.lstResourceTile.length - 2;
                      allData.objectData.lstArchetypeDetails.resourceCount =
                        extraResCount > 0
                          ? allData.objectData.lstArchetypeDetails
                              .resourceCount + extraResCount
                          : allData.objectData.lstArchetypeDetails
                              .resourceCount;
                      breakFromLoop = true;
                      break;
                    }
                  }
                } else {
                  allData.objectData.lstArchetypeDetails.lstCategoryBlock[
                    i
                  ].lstGoalBlock.splice(j, 1);
                  j -= 1;
                }
              }
              if (breakFromLoop) {
                break;
              }
            } else {
              allData.objectData.lstArchetypeDetails.lstCategoryBlock.splice(
                i,
                1
              );
            }
          }
        }
        component.set(
          "v.archetypeResource",
          allData.objectData.lstArchetypeDetails
        );
        component.set("v.isSpinnerActive", false);
        //End - To attach new Resources for Goal on click of See All Resources
        //Start - Code use to pass data to Google Map
        var mapData = [];
        var userLocation = usrloc;
        for (k = 0; k < uniqueRes.length; k += 1) {
          resourceData = uniqueRes[k].resourceData;
          var splitData = "";
          var markarText = "";
          if (!$A.util.isUndefinedOrNull(resourceData)) {
            if (!$A.util.isUndefinedOrNull(resourceData.locationAddress1)) {
              var latLongData = resourceData.locationLatLong;
              splitData = latLongData.split("##");
            }

            if (
              !$A.util.isUndefinedOrNull(resourceData.accountProviderName)
            ) {
              markarText += resourceData.accountProviderName + "<br/>";
            }
            if (!$A.util.isUndefinedOrNull(resourceData.locationAddress1)) {
              markarText += resourceData.locationAddress1 + "<br/>";
            }
            if (!$A.util.isUndefinedOrNull(resourceData.locationAddress2)) {
              markarText += resourceData.locationAddress2 + "<br/>";
            }
            if (!$A.util.isUndefinedOrNull(resourceData.locationCity)) {
              markarText += resourceData.locationCity + ", ";
            }
            if (!$A.util.isUndefinedOrNull(resourceData.locationState)) {
              markarText += resourceData.locationState + " ";
            }
            if (!$A.util.isUndefinedOrNull(resourceData.locationZipcode)) {
              markarText += resourceData.locationZipcode;
            }
          }

          if (!$A.util.isUndefinedOrNull(markarText) && markarText !== "") {
            markarText = markarText.trim();
            if (markarText.endsWith(",")) {
              markarText = markarText.substring(0, markarText.length - 1);
            }
          }
          if (
            !isNaN(parseFloat(splitData[0])) &&
            !isNaN(parseFloat(splitData[1]))
          ) {
            mapData.push({
              lat: parseFloat(splitData[0]),
              lng: parseFloat(splitData[1]),
              markerText: markarText,
              selected: "None"
            });
          }
        }
        if (!$A.util.isEmpty(userLocation)) {
          var loggedInUserLocation = userLocation.split("##");
          var mapOptionsCenter = {
            lat: parseFloat(loggedInUserLocation[0]),
            lng: parseFloat(loggedInUserLocation[1]),
            markerText: "My location",
            selected: "My location"
          };
          mapData.push(mapOptionsCenter);
        }
        component.set("v.onloadmapdata", mapData);
        component.set("v.onloadmapoption", component.get("v.mapOptions"));
        component.set("v.onloadmapcenter", mapOptionsCenter);
        component.set("v.showlessmapdata", mapData);
        var searchCompleteEvent = component.getEvent("mapDataEvent");
        searchCompleteEvent
          .setParams({
            mapOptions: component.get("v.mapOptions"),
            mapOptionsCenter: mapOptionsCenter,
            mapData: mapData
          })
          .fire();
        //End - Code use to pass data to Google Map
      },
      {
        strZipCodeParam: component.get("v.zipcode"),
        strArchetypeIdParam: component.get("v.archetypeId"),
        strSubArchetypeIdParam: component.get("v.subArchetype"),
        strDomainParam: currentGoalData.goalDomain,
        strGoalParam: currentGoalData.goalId,
        strSeeAllLess: "see-all",
        selectedHours:component.get("v.selectedHour")
      },
      false
    );
  } catch (e) {
    bSuper.consoleLog(e.stack, true);
  }
},
loadLessResourceHelper: function(component, event) {
  var newResMapData = [];
  var newResourceData = [];
  component.set("v.isSpinnerActive", true);
  var currentGoalData = event.getSource().get("v.value");
  var data = component.get("v.resourcedata");
  var usrloc = data.objectData.lstArchetypeDetails.strUserLatLong;
  var userLocationData = component.get("v.userlocation");
  var breakFromLoop = false;
  if (!$A.util.isUndefinedOrNull(userLocationData)) {
    userLocationData = JSON.parse(userLocationData);
    usrloc =
      userLocationData.Contact.ContactGeoLocation__c.latitude +
      "##" +
      userLocationData.Contact.ContactGeoLocation__c.longitude;
  }
  if (data.objectData.lstArchetypeDetails.lstCategoryBlock !== undefined) {
    for (
      var i = 0;
      i < data.objectData.lstArchetypeDetails.lstCategoryBlock.length;
      i += 1
    ) {
      var catData = data.objectData.lstArchetypeDetails.lstCategoryBlock[i];
      if (!$A.util.isUndefinedOrNull(catData.lstGoalBlock)) {
        for (var j = 0; j < catData.lstGoalBlock.length; j += 1) {
          var goalData = catData.lstGoalBlock[j];
          if (goalData.goalId === currentGoalData.goalId) {
            if (!$A.util.isUndefinedOrNull(goalData.lstResourceTile)) {
              for (var k = 0; k < 2; k += 1) {
                var resourceData = goalData.lstResourceTile[k];
                newResourceData.push(resourceData);
                newResMapData.push({
                  goalId: goalData.goalId,
                  resourceData: resourceData
                });
              }
              data.objectData.lstArchetypeDetails.resourceCount -=
                goalData.lstResourceTile.length;
              data.objectData.lstArchetypeDetails.resourceCount += 2;
              goalData.lstResourceTile = [];
              goalData.lstResourceTile = newResourceData;
              breakFromLoop = true;
              break;
            } else {
              data.objectData.lstArchetypeDetails.lstCategoryBlock[
                i
              ].lstGoalBlock.splice(j, 1);
              j -= 1;
            }
          }
        }
        if (breakFromLoop) {
          break;
        }
      } else {
        data.objectData.lstArchetypeDetails.lstCategoryBlock.splice(i, 1);
      }
    }
  }
  //Start - Remove the all Resources bind to that Goal on click on See less
  var oldMapData = component.get("v.mapdata");
  for (var l = 0; l < oldMapData.length; l += 1) {
    if (oldMapData[l].goalId === currentGoalData.goalId) {
      oldMapData.splice(l, 1);
      l -= 1;
    }
  }
  //Start - Remove the all Resources bind to that Goal on click on See less
  var allMapdata = oldMapData.concat(newResMapData); // Add only new 2 Resources
  component.set("v.mapdata", allMapdata);
  component.set("v.archetypeResource", data.objectData.lstArchetypeDetails);
  component.set("v.isSpinnerActive", false);
  this.mapDataHelper(component, event, allMapdata, usrloc, userLocationData);
},
mapDataHelper: function(
  component,
  event,
  goalData,
  usrloc,
  userLocationData,
  cardIndex,
  resourceCardOpenCloseIndx
) {
  var mapData = [];
  var userLocation = usrloc;
  for (var k = 0; k < goalData.length; k += 1) {
    var resourceData = goalData[k].resourceData;
    var splitData = "";
    if (!$A.util.isUndefinedOrNull(resourceData)) {
      if (!$A.util.isUndefinedOrNull(resourceData.locationAddress1)) {
        var latLongData = resourceData.locationLatLong;
        splitData = latLongData.split("##");
      }
      var markarText = "";
      if (!$A.util.isUndefinedOrNull(resourceData.accountProviderName)) {
        markarText += resourceData.accountProviderName + "<br/>";
      }
      if (!$A.util.isUndefinedOrNull(resourceData.locationAddress1)) {
        markarText += resourceData.locationAddress1 + "<br/>";
      }
      if (!$A.util.isUndefinedOrNull(resourceData.locationAddress2)) {
        markarText += resourceData.locationAddress2 + "<br/>";
      }
      if (!$A.util.isUndefinedOrNull(resourceData.locationCity)) {
        markarText += resourceData.locationCity + ", ";
      }
      if (!$A.util.isUndefinedOrNull(resourceData.locationState)) {
        markarText += resourceData.locationState + " ";
      }
      if (!$A.util.isUndefinedOrNull(resourceData.locationZipcode)) {
        markarText += resourceData.locationZipcode;
      }
    }

    if (!$A.util.isUndefinedOrNull(markarText) && markarText !== "") {
      markarText = markarText.trim();
      if (markarText.endsWith(",")) {
        markarText = markarText.substring(0, markarText.length - 1);
      }
    }
    if (
      !isNaN(parseFloat(splitData[0])) &&
      !isNaN(parseFloat(splitData[1]))
    ) {
      if (
        parseInt(cardIndex, 10) === parseInt(k, 10) &&
        resourceCardOpenCloseIndx === 1
      ) {
        component.set("v.showMultiPleMarker", false);
        mapData.push({
          lat: parseFloat(splitData[0]),
          lng: parseFloat(splitData[1]),
          markerText: markarText,
          selected: "selectedLocation"
        });
      } else {
        component.set("v.showMultiPleMarker", false);
        mapData.push({
          lat: parseFloat(splitData[0]),
          lng: parseFloat(splitData[1]),
          markerText: markarText,
          selected: "None"
        });
      }
    }
  }
  if (!$A.util.isEmpty(userLocation)) {
    var loggedInUserLocation = userLocation.split("##");
    var mapOptionsCenter = {
      lat: parseFloat(loggedInUserLocation[0]),
      lng: parseFloat(loggedInUserLocation[1]),
      markerText: "My location",
      selected: "My location"
    };
    mapData.push(mapOptionsCenter);
  }
  component.set("v.onloadmapdata", mapData);
  component.set("v.onloadmapoption", component.get("v.mapOptions"));
  component.set("v.onloadmapcenter", mapOptionsCenter);
  component.set("v.showlessmapdata", mapData);
  var searchCompleteEvent = component.getEvent("mapDataEvent");
  searchCompleteEvent
    .setParams({
      mapOptions: component.get("v.mapOptions"),
      mapOptionsCenter: mapOptionsCenter,
      mapData: mapData
    })
    .fire();
}
});
