({
  getZipCode: function(component, event, helper) {
    component.set("v.isSpinnerActive", true);
    var cachedZipCode = null;
    var encodedZip = sessionStorage.getItem("zipCodeVal");
    if (encodedZip !== null) cachedZipCode = window.atob(encodedZip);
    try {
      component.set("v.isSpinnerActive", true);
      var bSuper = component.find("bSuper");
      bSuper.callServer(
        component,
        "c.getUserInfo",
        function(response) {
          component.set("v.isGuestUser", response.objectData.isGuestUser);
          if (response.objectData.isGuestUser === true) {
            if (cachedZipCode !== null) {
              component.set("v.zipCode", cachedZipCode);
              component.set("v.showDiscoverResource", false);
            } else component.set("v.showDiscoverResource", true);
          } else if (response.objectData.isGuestUser === false) {
            if (cachedZipCode !== null) {
              component.set("v.zipCode", cachedZipCode);
              component.set("v.showDiscoverResource", false);
            } else if (response.objectData.zipCodeProfile.length > 0) {
              component.set("v.zipCode", response.objectData.zipCodeProfile);
              var zipEncoded = window.btoa(response.objectData.zipCodeProfile);
              // window.localStorage.setItem('zipCodeVal', zipEncoded);
              sessionStorage.setItem("zipCodeVal", zipEncoded);
              component.set("v.showDiscoverResource", false);
            } else component.set("v.showDiscoverResource", true);
            /*else if(response.objectData.zipCodeProfile.length === 0 && cachedZipCode !== null){
                        component.set("v.zipCode",cachedZipCode);
                        component.set("v.showDiscoverResource",false);                    	
                    }*/
          } else {
            var errMsg = $A.get("$Label.c.servererror");
            bSuper.showToast(
              $A.get("$Label.c.errorstatus"),
              $A.get("$Label.c.errorstatus"),
              errMsg
            );
          }
          component.set(
            "v.lstAllDomains",
            response.objectData.mapAvailableDomains
          );
          helper.getParamValue(component, event, helper);
        },
        {
          archId: component.get("v.archeTypeId")
        },
        false
      );
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
    component.set("v.isDisabled", true);
  },
  validateZipCode: function() {
    var invalid = false;
    /*var zipCodePattern = /^[0-9]{5}$/;
        var zipCode = component.get("v.zipCode");
        if(!zipCodePattern.test(zipCode))
            invalid = true;*/
    return invalid;
  },
  /* get client Id from URL params */
  getParamValue: function(component, event, helper) {
    var searchkey;
    if (this.getURLParam().searchkey) {
      searchkey = decodeURIComponent(this.getURLParam().searchkey);
    }
    var domain = this.getURLParam().domain;
    var category = this.getURLParam().category;
    var subcategory = this.getURLParam().subcategory;

    if (!$A.util.isUndefinedOrNull(searchkey) && searchkey !== "") {
      searchkey = searchkey.replace(/\+/g, " ");
      component.set("v.sSearchKey", searchkey);
      this.getSearchResults(component, event, helper);
    } else if (
      !$A.util.isUndefinedOrNull(domain) &&
      domain !== "" &&
      !$A.util.isUndefinedOrNull(subcategory) &&
      subcategory !== ""
    ) {
      component.set("v.domain", domain);
      category = category.replace(/\+/g, " ");
      component.set("v.category", category);
      subcategory = subcategory.replace(/\+/g, " ");
      component.set("v.subcategory", subcategory);
      if (component.get("v.zipCode") !== undefined)
        this.getSubcategorySearchResults(component, event, helper);
    }
  },
  /* get URL params */
  getURLParam: function() {
    var query = location.search.substr(1);
    var result = {};
    if (query !== "") {
      query.split("&").forEach(function(part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
      });
    }
    return result;
  },
  // added by Pankaj for search filter
  getKeywordSearchResultsWithFilter: function(component, event, helper) {
    // get the selected category filter values
    var selectedDomains = component.find("cmpFilter").getSelectedValues();
    if (selectedDomains) selectedDomains = selectedDomains.split(",");
    // get the selected weekend/opentoday
    var selectedHours = component.find("cmpFilter").getSelectedHoursValues();
    if (selectedHours) selectedHours = selectedHours.split(",");

    var currentResources = component.get("v.searchresults");
    this.getSearchResults(component, event, helper);
    //var newResources = component.set("v.searchresults");
    this.updateResourcesBasedCategory(
      component,
      event,
      helper,
      true,
      currentResources
    );
  },
  getSearchResults: function(component, event, helper) {
    try {
      var bSuper = component.find("bSuper");
      component.set("v.isSpinnerActive", true);
      bSuper.callServer(
        component,
        "c.getKeywordSearchResults",
        function(response) {
          if (response.isSuccessful) {
            if (parseInt(component.get("v.resOffset"), 10) === 0) {
              var nop =
                parseInt(response.objectData.sGlbResLen, 10) /
                parseInt(component.get("v.resLimit"), 10);
              component.set("v.resNoPages", nop);
            }
            //Passing Total search count to that variable for GA by [CHFS Developer-Mohan-12/12/19]
            component.set("v.searchTotalCount", response.objectData.sGlbResLen);
            component.set(
              "v.resOffset",
              parseInt(component.get("v.resOffset"), 10) + 1
            );
            if (
              parseInt(response.objectData.searchresults.length, 10) <
              parseInt(component.get("v.resLimit"), 10)
            ) {
              component.set("v.disableScroll", true);
            } else {
              component.set("v.disableScroll", false);
            }
            //component.set("v.searchbycategory", false);
            component.set(
              "v.setGlobalSearchResourceIds",
              response.objectData.setGlobalSearchResourceIds
            );
            component.set(
              "v.setGlobalLocationResourceIds",
              response.objectData.setGlobalLocResourceIds
            );
            var searcharray = [];
            var searchdata = response.objectData.searchresults;
            if (searchdata.length === 0) {
              component.set("v.displayErrorCard", true);
            }
            var userLocationAddress = response.objectData.mylocationdata;
            component.set("v.userLocation", userLocationAddress);
            var lstResourceDomains = component.get(
              "v.lstDomainsAlreadyChecked"
            );
            for (var i in searchdata) {
              if (searchdata.hasOwnProperty(i)) {
                var obj = searchdata[i];
                var today = helper.getDayName();
                var objOperatingHours = JSON.parse(
                  obj.lstResourceLocations[0].locationOperatingHours
                );
                var LocResourceNotes = obj.lstResourceLocations[0].Notes;

                //var bIsClosedToday = obj.lstResourceLocations[0].locationOpenToday;
                // Started Added by Arun
                //var lstClosedDays = obj.lstResourceLocations[0].lstClosedDays;
                var isContainsTodayDay = false; //= lstClosedDays.includes(today);
                if (objOperatingHours !== null) {
                  if (
                    objOperatingHours[today][3] === "false" &&
                    LocResourceNotes !== null &&
                    LocResourceNotes !== ""
                  ) {
                    obj.operatingHoursToday = "";
                  } else {
                    if (objOperatingHours[today][2] === "true") {
                      isContainsTodayDay = true;
                    }
                    if (isContainsTodayDay === true) {
                      obj.operatingHoursToday = today + " Closed";
                    } else if (
                      !isContainsTodayDay &&
                      !$A.util.isEmpty(objOperatingHours[today]) &&
                      (objOperatingHours[today][0] !== "" ||
                        objOperatingHours[today][1] !== "")
                    ) {
                      obj.operatingHoursToday =
                        $A.get("$Label.c.today") +
                        " " +
                        objOperatingHours[today][0] +
                        " " +
                        $A.get("$Label.c.to") +
                        " " +
                        objOperatingHours[today][1];
                    } else if ($A.util.isEmpty(objOperatingHours[today])) {
                      obj.operatingHoursToday = "";
                    }
                  }
                } else {
                  obj.operatingHoursToday = "";
                }
                obj.dMiles =
                  obj.resourceMiles >= 0
                    ? Math.round(obj.resourceMiles * 100) / 100
                    : "";
                obj.isResident = response.objectData.bIsResidentUser;
                obj.isGuest = response.objectData.bIsGuestUser;
                obj.isCPUser = response.objectData.bIsCPUser;
                obj.isAgencyUser = response.objectData.bIsAgencyUser;//RE_Release 1.1 - Agency user capture- Mohan

                var lstDomains = obj.lstDomains;
                for (var j in lstDomains) {
                  if (
                    lstDomains[j].domainValue !== undefined &&
                    lstDomains[j].domainValue !== null &&
                    !lstResourceDomains.includes(lstDomains[j].domainValue)
                  )
                    lstResourceDomains.push(lstDomains[j].domainValue);
                }
                searcharray.push(obj);
              }
            }
            component.set("v.newlistrecords", searcharray);
            component.set("v.lstDomainsAlreadyChecked", lstResourceDomains);
            var newSearchResults = component
              .get("v.searchresults")
              .concat(searcharray);

            component.set("v.searchresults", newSearchResults);
            component.set("v.originalSearchResults",component.get("v.originalSearchResults").concat(searcharray));
            helper.getCategoryValues(component, event, lstResourceDomains);
            component.set("v.displayCard", true);
            component.set("v.displayMap", true);
            component.set("v.displayErrorCard", false);
            helper.mapDataHelper(
              component,
              event,
              newSearchResults,
              userLocationAddress,
              "",
              ""
            );
            component.set("v.isSpinnerActive", false);
            var selectedHours = component.get("v.selectedHours");
            if(!$A.util.isUndefinedOrNull(selectedHours) && !$A.util.isEmpty(selectedHours)){
                  helper.updateResourceBasesOnHourFilter(component,event,helper);
            }
           
          } else {
            component.set("v.displayErrorCard", true);
          }
        },
        {
          //SOQL changes made for the below parameters and in associated apex class
          strKeyword: component.get("v.sSearchKey"),
          strZipCode: component.get("v.zipCode"),
          screen: "searchkeyword",
          iPageSize: component.get("v.resLimit"),
          pageNumber: component.get("v.resOffset"),
          setResourceIds: JSON.stringify(
            component.get("v.setGlobalSearchResourceIds")
          ),
          setLocResourceIds: JSON.stringify(
            component.get("v.setGlobalLocationResourceIds")
          )
        },
        false
      );
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
  },
  getSubcategorySearchResults: function(component, event, helper) {
    try {
      //reference to inherited super component
      var bSuper = component.find("bSuper");
      component.set("v.isSpinnerActive", true);
      component.set("v.disableScroll", true);
      //override the method in super class and write your own logic with the response received
      bSuper.callServer(
        component,
        "c.getSubCategorySearchResults",
        function(response) {
          if (response.isSuccessful) {
            if (parseInt(component.get("v.resOffset"), 10) === 0) {
              var nop =
                parseInt(response.objectData.sGlbResLen, 10) /
                parseInt(component.get("v.resLimit"), 10);
              component.set("v.resNoPages", nop);
            }
            component.set(
              "v.resOffset",
              parseInt(component.get("v.resOffset"), 10) + 1
            );
            if (
              parseInt(response.objectData.lstSearchResults.length, 10) <
              parseInt(component.get("v.resLimit"), 10)
            ) {
              component.set("v.searchbycategory", true);
            } else {
              component.set("v.searchbycategory", false);
            }
            component.set(
              "v.setGlobalSearchResourceIds",
              response.objectData.setGlobalSearchResourceIds
            );
            var searcharray = [];
            var searchdata = response.objectData.lstSearchResults;
            var newSearchResults =searchdata;
            var userLocationAddress = response.objectData.mylocationdata;
            component.set("v.userLocation", userLocationAddress);
            var lstResourceDomains = [];
            for (var i in newSearchResults) {
              if (newSearchResults.hasOwnProperty(i)) {
                var obj = newSearchResults[i];

                var today = helper.getDayName();
                /*if(bIsClosedToday){
                                obj.operatingHoursToday = $A.get('$Label.c.today') +' '+ objOperatingHours[today].replace('##', $A.get('$Label.c.to'));
                            }else{
                                obj.operatingHoursToday = today+ ' Closed';
                            }*/
                // added by Pankaj[12/1/2019]
                /* var lstClosedDays = obj.lstResourceLocations[0].lstClosedDays;
                var isContainsTodayDay = lstClosedDays.includes(today);
                if (isContainsTodayDay === true) {
                  obj.operatingHoursToday = today + " Closed";
                } else if (
                  !isContainsTodayDay &&
                  !$A.util.isEmpty(objOperatingHours[today])
                ) {
                  obj.operatingHoursToday =
                    $A.get("$Label.c.today") +
                    " " +
                    objOperatingHours[today].replace(
                      "##",
                      $A.get("$Label.c.to")
                    );
                } else if ($A.util.isEmpty(objOperatingHours[today])) {
                  obj.operatingHoursToday = "N/A";
                }*/

                var LocResourceNotes = obj.lstResourceLocations[0].Notes;
                var objOperatingHours = JSON.parse(
                  obj.lstResourceLocations[0].locationOperatingHours
                );
                //var bIsClosedToday = obj.lstResourceLocations[0].locationOpenToday;
                // Started Added by Arun
                //var lstClosedDays = obj.lstResourceLocations[0].lstClosedDays;
                var isContainsTodayDay = false; //= lstClosedDays.includes(today);
                if (objOperatingHours !== null) {
                  if (
                    objOperatingHours[today][3] === "false" &&
                    LocResourceNotes !== null &&
                    LocResourceNotes !== ""
                  ) {
                    obj.operatingHoursToday = "";
                  } else {
                    if (objOperatingHours[today][2] === "true") {
                      isContainsTodayDay = true;
                    }
                    if (isContainsTodayDay === true) {
                      obj.operatingHoursToday = today + " Closed";
                    } else if (
                      !isContainsTodayDay &&
                      !$A.util.isEmpty(objOperatingHours[today]) &&
                      (objOperatingHours[today][0] !== "" ||
                        objOperatingHours[today][1] !== "")
                    ) {
                      obj.operatingHoursToday =
                        $A.get("$Label.c.today") +
                        " " +
                        objOperatingHours[today][0] +
                        " " +
                        $A.get("$Label.c.to") +
                        " " +
                        objOperatingHours[today][1];
                    } else if ($A.util.isEmpty(objOperatingHours[today])) {
                      obj.operatingHoursToday = "";
                    }
                  }
                } else {
                  obj.operatingHoursToday = "";
                }

                obj.dMiles =
                  obj.resourceMiles >= 0
                    ? Math.round(obj.resourceMiles * 100) / 100
                    : "";
                obj.isResident = response.objectData.bIsResidentUser;
                obj.isGuest = response.objectData.bIsGuestUser;
                obj.isCPUser = response.objectData.bIsCPUser;
                obj.isAgencyUser = response.objectData.bIsAgencyUser;//RE_Release 1.1 - Agency user capture- Mohan
                var lstDomains = obj.lstDomains;
                for (var j in lstDomains) {
                  if (
                    lstDomains[j].domainValue !== undefined &&
                    lstDomains[j].domainValue !== null
                  )
                    lstResourceDomains.push(lstDomains[j].domainValue);
                }
                searcharray.push(obj);
              }
            }
            component.set("v.isSpinnerActive", true);
            helper.getCategoryValues(component, event, lstResourceDomains);
            var allResults=component.get("v.searchresults").concat(searcharray);
            component.set("v.searchresults", allResults);
            component.set("v.originalSearchResults", component.get("v.originalSearchResults").concat(searcharray));
            component.set("v.displayCard", true);
            component.set("v.displayMap", true);
            helper.mapDataHelper(
              component,
              event,
              allResults,
              userLocationAddress,
              "",
              ""
            );
            //hide spinner when server response received
            component.set("v.isSpinnerActive", false);
            var selectedHours = component.get("v.selectedHours");
            if(!$A.util.isUndefinedOrNull(selectedHours) && !$A.util.isEmpty(selectedHours)){
                  helper.updateResourceBasesOnHourFilter(component,event);
            }
            
          } else {
            component.set("v.searchresults", "");
            component.set("v.originalSearchResults", "");
            component.set("v.displayCard", false);
            component.set("v.displayMap", false);
          }
          component.set("v.domainName", response.objectData.domain);
          component.set("v.categoryName", response.objectData.category);
          component.set("v.subcategoryName", response.objectData.subcategory);
          component.set(
            "v.navMenu",
            response.objectData.domain +
              " / " +
              response.objectData.category +
              " / " +
              response.objectData.subcategory
          );
          component.set("v.onLoad", false);
          component.set("v.updateResources", false);
        },
        {
          //SOQL injection changes made for the following methods and in apex class aswell
          strZipCode: component.get("v.zipCode"),
          strDomain: component.get("v.domain"),
          strCategory: component.get("v.category"),
          strSubcategory: component.get("v.subcategory"),
          iPageSize: component.get("v.resLimit"),
          pageNumber: component.get("v.resOffset"),
          screen: "searchbycategory",
          setResourceIds: JSON.stringify(
            component.get("v.setGlobalSearchResourceIds")
          )
        },
        false
      );
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
  },
  getDayName: function() {
    var weekdays = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday"
    ];
    //var current_date = new Date();
    // var weekdayValue = new Date().getDay();
    return weekdays[new Date().getDay()];
  },
  mapDataHelper: function(
    component,
    event,
    mapdata,
    userLoc,
    cardIndex,
    resourceCardOpenCloseIndx
  ) {
    component.set("v.showMultiPleMarker", false);
    component.set("v.showMultiPleMarkerForCompleted", false);
    component.set("v.showSingleMarkerForCompleted", false);
    //var userLocationData;
    var mapData = [];
    var userLocation;
    for (var k = 0; k < mapdata.length; k += 1) {
      var resourceData = mapdata[k].lstResourceLocations;
      userLocation = mapdata[k].userLatLong;
      var splitData = "";
      if (!$A.util.isUndefinedOrNull(resourceData[0].locationLatLong)) {
        var latLongData = resourceData[0].locationLatLong;
        splitData = latLongData.split("##");
      }
      var markarText = "";
      if (!$A.util.isUndefinedOrNull(mapdata[k].accountName)) {
        markarText += mapdata[k].accountName + "<br/>";
      }

      if (!$A.util.isUndefinedOrNull(resourceData[0].locationAddress1)) {
        markarText += resourceData[0].locationAddress1 + ",";
      }
      if (!$A.util.isUndefinedOrNull(resourceData[0].locationAddress2)) {
        markarText += resourceData[0].locationAddress2 + ",";
      }
      if (!$A.util.isUndefinedOrNull(resourceData[0].locationCity)) {
        markarText += resourceData[0].locationCity + "<br/>";
      }
      if (!$A.util.isUndefinedOrNull(resourceData[0].locationState)) {
        markarText += resourceData[0].locationState + ",";
      }
      if (!$A.util.isUndefinedOrNull(resourceData[0].locationZip)) {
        markarText += resourceData[0].locationZip;
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
            lat: parseFloat(splitData[0], 10),
            lng: parseFloat(splitData[1], 10),
            markerText: markarText,
            selected: "selectedLocation"
          });
        } else {
          component.set("v.showMultiPleMarker", false);
          mapData.push({
            lat: parseFloat(splitData[0], 10),
            lng: parseFloat(splitData[1], 10),
            markerText: markarText,
            selected: "None"
          });
        }
      }
    }
    if (userLoc) {
      var locdata = JSON.parse(userLoc);
      userLocation =
        locdata.ContactGeoLocation__c.latitude +
        "##" +
        locdata.ContactGeoLocation__c.longitude;
    }
    if (!$A.util.isEmpty(userLocation)) {
      var loggedInUserLocation = userLocation.split("##");
      var mapOptionsCenter = {
        lat: parseFloat(loggedInUserLocation[0]),
        lng: parseFloat(loggedInUserLocation[1])
      };
      mapData.push({
        lat: parseFloat(loggedInUserLocation[0]),
        lng: parseFloat(loggedInUserLocation[1]),
        markerText: "My location",
        selected: "My location"
      });
    }
    component.set("v.mapOptionsCenter", mapOptionsCenter);
    component.set("v.mapData", mapData);
    component.set("v.showMultiPleMarker", true);
  },
  getCategoryValues: function(component, event, lstResDomains) {
    var domainArr = [];
    var applicableDomainArr = [];
    var lstAllDomains = component.get("v.lstAllDomains");
    for (var key in lstAllDomains) {
      if (lstResDomains.includes(lstAllDomains[key])) {
        var domain = {
          name: key,
          value: lstAllDomains[key],
          isPresent: lstResDomains.includes(lstAllDomains[key]),
          isChecked: lstResDomains.includes(lstAllDomains[key])
        };
        domainArr.push(domain);
        applicableDomainArr.push(domain);
      } else {
        var domainObj = {
          name: key,
          value: lstAllDomains[key],
          isPresent: lstResDomains.includes(lstAllDomains[key]),
          isChecked: lstResDomains.includes(lstAllDomains[key])
        };
        domainArr.push(domainObj);
      }
    }
    component.set("v.lstApplicableDomains", applicableDomainArr);
    component.set("v.lstAvailableDomains", domainArr);
  },
  /* update search results based on category [added for later use]*/
  updateResourcesBasedCategory: function(
    component,
    event,
    helper,
    newlistarray
  ) {
    var filterCategories = [];
    var originalJobs = [];
    
    if (newlistarray !== undefined && newlistarray.length > 0) {
      originalJobs = newlistarray;
    } else {
      originalJobs = component.get("v.originalSearchResults");
    }
    var selectedDomains = component.get("v.strDomains");
    selectedDomains = selectedDomains ? selectedDomains.split(",") : [];
    //for category filter
    if (selectedDomains !== undefined && !$A.util.isEmpty(selectedDomains)) {
      for (var i = 0; i < originalJobs.length; i += 1) {
        for (var j = 0; j < selectedDomains.length; j += 1) {
          var categoryValues = [];
          var lstResourceDomains = [];
          if (originalJobs[i].lstDomains !== undefined)
            categoryValues = originalJobs[i].lstDomains;
          for (var k in categoryValues) {
            if (
              categoryValues[k].domainValue !== undefined &&
              categoryValues[k].domainValue !== null
            )
              lstResourceDomains.push(categoryValues[k].domainValue);
          }
          if (
            lstResourceDomains.indexOf(selectedDomains[j]) >= 0 &&
            filterCategories.indexOf(originalJobs[i]) < 0
          ) {
            filterCategories.push(originalJobs[i]);
          }
        }
      }
    }
    if (filterCategories.length > 0) {
      component.set("v.searchresults", filterCategories);
      if (
        component.get("v.searchresults") !== undefined &&
        component.get("v.searchresults").length >= 30
      ) {
        if ($A.util.isEmpty(component.get("v.sSearchKey"))) {
          component.set("v.searchbycategory", false);
        } else {
          component.set("v.disableScroll", false);
        }
      } else {
        if ($A.util.isEmpty(component.get("v.sSearchKey"))) {
          component.set("v.searchbycategory", true);
        } else {
          component.set("v.disableScroll", true);
        }
      }
      component.set("v.displayCard", true);
      component.set("v.displayMap", true);
      helper.mapDataHelper(
        component,
        event,
        filterCategories,
        component.get("v.userLocation")
      );
    } else {
      // changed by Pankaj [12/11/2019] as part of defect#342582
      component.set("v.searchresults", []);
      component.set("v.searchbycategory", true);
      helper.mapDataHelper(
        component,
        event,
        component.get("v.originalSearchResults"),
        component.get("v.userLocation")
      );
      component.set("v.displayCard", true);
      component.set("v.displayMap", true);
    }
  },
    updateResourceBasesOnHourFilter :function(component, event,helper){
        var currentDay = new Date().getUTCDay();
        var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
        var originalJobs = component.get("v.originalSearchResults");
        var selectedHours = component.get("v.selectedHours");
        var filterHours = [];
        
        //for category filter
        if (selectedHours !== undefined && selectedHours !== "" && selectedHours !== null) {
            selectedHours = selectedHours.split(",");
            var checkToday = false,
                checkWeekends = false;
            for (var j = 0; j < selectedHours.length; j += 1) {
                if (selectedHours[j] === "Open Today") checkToday = true;
                if (selectedHours[j] === "Open Weekends") checkWeekends = true;
            }
            for (var i = 0; i < originalJobs.length; i += 1) {
                if (originalJobs[i] !== undefined && originalJobs[i] !== null && originalJobs[i] !== "") {
                    var values = [];
                    var openToday =false;
                    if (originalJobs[i].lstResourceLocations !== undefined){
                        values = originalJobs[i].lstResourceLocations;
                        // added by Pankaj as 12/16/2019
                        var operatingDays = JSON.parse(values[0].locationOperatingHours);
                        if (operatingDays !== null) {
                            var openWeekend = false;
                            if (checkWeekends === true) {
                                if ((!$A.util.isEmpty(operatingDays.Sunday) ||!$A.util.isEmpty(operatingDays.Saturday)) && (operatingDays["Sunday"][2] === "false" || operatingDays["Saturday"][2] === "false")) {
                                    openWeekend = true;
                                }
                            }
                            if(checkToday === true) {
                                if (!$A.util.isEmpty(operatingDays[days[currentDay]]) &&
                                    (operatingDays[days[currentDay]][0] !== "" ||
                                     operatingDays[days[currentDay]][1] !== "") &&
                                    operatingDays[days[currentDay]][2] === "false") {
                                    openToday = true;
                                }                   
                            }
                            // added check as part of defect#344541. When open weekends is selected but resource is also open today
                            if ((checkWeekends === true && openWeekend === true) && (checkToday===true  && openToday === true)){
                                filterHours.push(originalJobs[i]);
                            }else if(checkWeekends === true && checkToday ===false && openWeekend === true){
                                filterHours.push(originalJobs[i]);
                            }else if(checkToday===true && checkWeekends===false && openToday === true){
                                filterHours.push(originalJobs[i]);
                            }
                        }
                    }
                }
            }
            component.set("v.searchresults", filterHours);
            // added by Pankaj [12/16/2019]
            component.set("v.displayCard", true);
            component.set("v.displayMap", true);
            helper.mapDataHelper(
                component,
                event,
                filterHours,
                component.get("v.userLocation")
            );
        } else {
            
            //Nandita: Code fix for defect# 354344 -- start
            component.set("v.searchresults", component.get("v.originalSearchResults"));
            //Nandita: Code fix for defect# 354344 -- end
            helper.mapDataHelper(
                component,
                event,
                component.get("v.searchresults"),
                component.get("v.userLocation")
            );
            component.set("v.displayCard", true);
            component.set("v.displayMap", true);
        }
  }
});