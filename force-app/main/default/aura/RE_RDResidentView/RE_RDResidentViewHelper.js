({
  getData: function (component, event, helper) {
    var recId = component.get("v.resourceId");
    var locID = component.get("v.locationId");
    if (locID === 'undefined') {
      locID = null;
    }
    var zipCode = component.get("v.zipcode");

    component.set("v.mapLoad", false);
    try {
      //show spinner when request sent
      component.set('v.isSpinnerActive', true);
      //reference to inherited super component
      var bSuper = component.find("bSuper");
      //override the method in super class and write your own logic with the response received
      bSuper.callServer(component, 'c.getResourceData', function (response) {
        //hide spinner when server response received
        component.set('v.isSpinnerActive', false);
        //to do
        var usrLocation;
        if (response.isSuccessful) {
          var mylocation = response.objectData.usrLocation;
          if (mylocation) {
            mylocation = JSON.parse(mylocation);
            if ((!$A.util.isUndefinedOrNull(mylocation.ContactGeoLocation__c)) || (!$A.util.isUndefinedOrNull(mylocation.ContactGeoLocation__c))) {
              usrLocation = mylocation.ContactGeoLocation__c.latitude + '##' + mylocation.ContactGeoLocation__c.longitude;
            }else {
              usrLocation = response.objectData.zipCodeLocation;
            }

          } else {
            usrLocation = response.objectData.zipCodeLocation;
          }
          var result = response.objectData.objWrapper;
          component.set("v.locationTime", result.LocationTimeFields);
          component.set("v.lstFiles", response.objectData.listOfFiles.lstFileWrapper);
          component.set("v.resourceRecords", result.selectedResource);
          component.set("v.selectedLocRecord", result.selectedlocationWrap);
          component.set(
            "v.selectedLocationResource",
            result.LocResourceWrapper
          );
          var formatedPhone;
          var phone = component.get("v.selectedLocationResource.MainPhone");
          if (phone !== null && phone !== "" && phone !== undefined) {
            // 20Dec LV issue
            formatedPhone = helper.formatPhoneNumber(phone);
            component.set(
              "v.selectedLocationResource.MainPhone",
              formatedPhone
            );
          }
          var FirstPocPhone = component.get(
            "v.selectedLocationResource.FirstPOCPhone"
          );
          if (
            FirstPocPhone !== null &&
            FirstPocPhone !== "" &&
            FirstPocPhone !== undefined
          ) {

            formatedPhone = helper.formatPhoneNumber(FirstPocPhone);
            component.set(
              "v.selectedLocationResource.FirstPOCPhone",
              formatedPhone
            );
          }
          var SecondPOCPhone = component.get(
            "v.selectedLocationResource.SecondPOCPhone"
          );
          if (
            SecondPOCPhone !== null &&
            SecondPOCPhone !== "" &&
            SecondPOCPhone !== undefined
          ) {

            formatedPhone = helper.formatPhoneNumber(SecondPOCPhone);
            component.set(
              "v.selectedLocationResource.SecondPOCPhone",
              formatedPhone
            );
          }
          var tollfree = component.get("v.selectedLocationResource.TollFree");
          if (
            tollfree !== null &&
            tollfree !== "" &&
            tollfree !== undefined
          ) {
            formatedPhone = helper.formatPhoneNumber(tollfree);
            component.set(
              "v.selectedLocationResource.TollFree",
              formatedPhone
            );
          }
          component.set(
            "v.relatedResourcesWrapper",
            result.lstOtherResourcesWrap
          );
          component.set(
            "v.isSelectedResConDisabled",
            result.isdsabldCnctSelectedRes
          );
          if (
            !$A.util.isUndefinedOrNull(result.selectedResource.Referrals__r)
          )
            component.set(
              "v.resReferralStatus",
              result.selectedResource.Referrals__r[0].Status__c
            );
          var sLocResourceId = response.objectData.locresourceId;
          component.set("v.sLocResourceId", sLocResourceId);
          //var cmpId = component.find("favorite-selected");// getting "favorite" DOM element using aura id.
          var imgId = document.getElementById("favorite-selected-img");
          if (!$A.util.isUndefinedOrNull(imgId)) {
            if (response.objectData.isfavorite) {
              component.set('v.isFavoriteIconRed',true);
              imgId.src = imgId.src.replace("heartgray", "heartred");
            } else {
              component.set('v.isFavoriteIconRed',false);
              imgId.src = imgId.src.replace("heartred", "heartgray");
            }
          }
          if (!$A.util.isUndefinedOrNull(response.objectData.dMiles)) {
            var miles = Math.round(response.objectData.dMiles * 100) / 100;
            component.set("v.distanceMiles", miles);
          } else {
            component.set("v.distanceMiles", "N/A");
          }

          // GeolOcation Data //
          //var selectedLocation= response.objectData.geoLocation.split("##");

          if (
            !$A.util.isUndefinedOrNull(
              response.objectData.objWrapper.lstlocationWrap[0]
            )
          ) {
            var resourceAddress1 =
              response.objectData.objWrapper.lstlocationWrap[0].Address1__c;
            var resourceCity =
              response.objectData.objWrapper.lstlocationWrap[0].City__c;
            var resourceState =
              response.objectData.objWrapper.lstlocationWrap[0].State__c;
            //var resourceCountry=wrapperData.lstResourceLocations[0].sLocationCountry;
            var resourceZip =
              response.objectData.objWrapper.lstlocationWrap[0].Zip__c;
            var address1 =
              resourceAddress1 !== undefined
                ? resourceAddress1.split(" ").join("+")
                : "";
            var cityadd =
              resourceCity !== undefined
                ? resourceCity.split(" ").join("+")
                : "";
            var stateadd =
              resourceState !== undefined
                ? resourceState.split(" ").join("+")
                : "";
            var zip = resourceZip !== undefined ? resourceZip : "";
            var resCompAddress =
              address1 + "+" + cityadd + "+" + stateadd + "+" + zip;
            component.set("v.locGeolocation", resCompAddress);
          } else {
            component.set("v.locGeolocation", "NULL");
          }
          if (!$A.util.isUndefinedOrNull(usrLocation)) {
            component.set("v.Geolocation", usrLocation.split("##"));
          }

          component.set("v.mapLoad", true);
          var mapData = [];
          //var mapOptionsCenter = {"lat":parseFloat(selectedLocation[0]), "lng":parseFloat(selectedLocation[1])};
          var objSleLOcationData = component.get("v.selectedLocRecord");

          var sMarkerText = "";
          if (
            !$A.util.isUndefinedOrNull(objSleLOcationData.Account__r.Name)
          ) {
            sMarkerText += objSleLOcationData.Account__r.Name + "<br/>";
          }
          if (!$A.util.isUndefinedOrNull(objSleLOcationData.Address1__c)) {
            sMarkerText += objSleLOcationData.Address1__c + "<br/>";
          }
          if (!$A.util.isUndefinedOrNull(objSleLOcationData.Address2__c)) {
            sMarkerText += objSleLOcationData.Address2__c + "<br/>";
          }
          if (!$A.util.isUndefinedOrNull(objSleLOcationData.City__c)) {
            sMarkerText += objSleLOcationData.City__c + ", ";
          }
          if (!$A.util.isUndefinedOrNull(objSleLOcationData.State__c)) {
            sMarkerText += objSleLOcationData.State__c + " ";
          }
          if (!$A.util.isUndefinedOrNull(objSleLOcationData.Zip__c)) {
            sMarkerText += objSleLOcationData.Zip__c;
          }
          var mapOptionsCenter;
          if (!$A.util.isEmpty(usrLocation)) {
            var loggedInUserLocation = usrLocation.split("##");
            mapOptionsCenter = {
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
          if (!$A.util.isUndefinedOrNull(response.objectData.geoLocation)) {
            var selectedLocation = response.objectData.geoLocation.split(
              "##"
            );
            mapData.push({
              lat: parseFloat(selectedLocation[0]),
              lng: parseFloat(selectedLocation[1]),
              markerText: sMarkerText,
              selected: "None"
            });
            if ($A.util.isEmpty(usrLocation)) {
              mapOptionsCenter = {
                lat: parseFloat(selectedLocation[0]),
                lng: parseFloat(selectedLocation[1])
              };
            }
          }

          component.set("v.mapOptionsCenter", mapOptionsCenter);
          component.set("v.mapData", mapData);
          //time formatting

          var daysArr = [
            "MondayOpen",
            "MondayClose",
            "TuesdayOpen",
            "TuesdayClose",
            "WednesdayOpen",
            "WednesdayClose",
            "ThursdayOpen",
            "ThursdayClose",
            "FridayOpen",
            "FridayClose",
            "SaturdayOpen",
            "SaturdayClose",
            "SundayOpen",
            "SundayClose"
          ];
          for (var i = 0; i < daysArr.length; i += 1) {
            var isotime = component.get("v.locationTime." + daysArr[i]);
            if (isotime) {
              component.set(
                "v.locationTime." + daysArr[i],
                helper.dateConverter(isotime)
              );
            }
          }
          //check the resource record type
          var resourceRecordType = component.get("v.resourceRecords")
            .RecordType.Name;
          if (resourceRecordType === "StateProgram") {
            component.set("v.isStatePrgm", true);
          } else {
            component.set("v.isStatePrgm", false);
          }
          //var resourceSelected = component.get("v.resourceRecords");
          //Nandita 11-Feb-2020: removed reference for AgesServed field on Resource Object.
          /* for (var index in resourceSelected) {
            if (
              Object.prototype.hasOwnProperty.call(resourceSelected, index)
            ) {
              if (resourceSelected.AgesServed__c) {
                resourceSelected.AgesServed__c = resourceSelected.AgesServed__c.replace(
                  ";",
                  ", "
                );
              }
            }
          }*/

          var resRecord = component.get("v.selectedLocRecord");
          //var closedDays = [];
          for (var property in resRecord) {
            if (Object.prototype.hasOwnProperty.call(resRecord, property)) {
              if (resRecord.Language__c) {
                resRecord.Language__c = resRecord.Language__c.replace(";", ", ");
              }
              if (resRecord.County__c) {
                resRecord.County__c = resRecord.County__c.replace(";", ", ");
              }

            }
          }
          component.set(
            "v.mondayClose",
            result.LocationTimeFields.isMondayClosed
          );
          component.set(
            "v.tuesdayClose",
            result.LocationTimeFields.isTuesdayClosed
          );
          component.set(
            "v.wednesdayClose",
            result.LocationTimeFields.isWednesdayClosed
          );
          component.set(
            "v.thursdayClose",
            result.LocationTimeFields.isThursdayClosed
          );
          component.set(
            "v.fridayClose",
            result.LocationTimeFields.isFridayClosed
          );
          component.set(
            "v.saturdayClose",
            result.LocationTimeFields.isSaturdayClosed
          );
          component.set(
            "v.sundayClose",
            result.LocationTimeFields.isSundayClosed
          );

          component.set("v.selectedLocRecord", result.selectedlocationWrap);
          component.set("v.selectedLocation", result.selectedlocationWrap.Id)
          var shareResourceWrapper = { 'acc': '', 'location': '', 'resource': '' };
          var resData = component.get("v.resourceRecords");
          var locData = component.get("v.selectedLocRecord");
          var locResData = component.get("v.selectedLocationResource");
          // var locTimeData = component.get("v.locationTime");
          var accWrapper = { 'sReferralOrgName': '', 'sReferralOrgUrl': '' };
          accWrapper.sReferralOrgName = resData.Organization__r.Name;
          accWrapper.sReferralOrgUrl = resData.Organization__r.Website;
          shareResourceWrapper.acc = accWrapper;
          //var weekdayValue;
          // weekdayValue = helper.getDayName();

          var locWrapper = { 'sLocationAddress1': '', 'sLocationAddress2': '', 'sLocationCity': '', 'sLocationState': '', 'sLocationZip': '', 'sPOCPhone': '' };
          locWrapper.sLocationAddress1 = locData.Address1__c;
          locWrapper.sLocationAddress2 = locData.Address2__c;
          locWrapper.sLocationCity = locData.City__c;
          locWrapper.sLocationState = locData.State__c;
          locWrapper.sLocationZip = (locData.Zip__c) ? locData.Zip__c : '';
          locWrapper.sLocationId = locData.Id;
          locWrapper.sPOCPhone =
            locResData.MainPhone !== "" && locResData.MainPhone !== null && locResData.MainPhone !== undefined
              ? locResData.MainPhone
              : locResData.TollFree;//Nandita 17-Feb-2020: Updated logic to fix issue# 353052
          //locWrapper.sPOCEmail = locData.Email__c!==''?locData.Email__c:locData.Account__r.Email__c;
          //locWrapper.sOperatingHoursToday = helper.operatingHoursDayValue(component,weekdayValue,locTimeData);
          shareResourceWrapper.location = locWrapper;
          var resWrapper = { sResourceName: "", sSDOHCategory: "" };
          //resWrapper.sResourceDescription = resData.Description__c;
          resWrapper.sResourceName = resData.Name;
          resWrapper.sSDOHCategory = resData.SdohDomain__c;
          resWrapper.resourceId = resData.Id;
          shareResourceWrapper.resource = resWrapper;

          component.set("v.wrapdata", shareResourceWrapper);
          //Code added to Show/Hide the fields/Sections as part of Defect - 1062.
          /*if(!$A.util.isUndefinedOrNull(response.objectData.listOfFiles.lstFileWrapper) && response.objectData.listOfFiles.lstFileWrapper >0){
                      component.set("v.hideReferrenceMaterials", true);
                  }
                  if(!$A.util.isUndefinedOrNull(result.lstOtherResourcesWrap) && result.lstOtherResourcesWrap >0){
                      component.set("v.hideOtherResources", true);
                  }*/
          component.set(
            "v.hideReferrenceMaterials",
            helper.showHideFieldsSections(
              response.objectData.listOfFiles.lstFileWrapper
            )
          );
          component.set(
            "v.hideOtherResources",
            helper.showHideFieldsSections(result.lstOtherResourcesWrap)
          );
        } else {
          var errMsg = "";
          if (!$A.util.isUndefinedOrNull(locID)) {

            errMsg =
              "Resource is not associated to any Location. Please map the resource to atleast one available Location.";
            bSuper.showToast("Error", "Error", errMsg);
          }
          //var errMsg = "";
          errMsg = "Some error has occured. Please check with Admin.";
          bSuper.showToast("Error", "Error", errMsg);
        }
      },
        {
          strResourceRecId: recId,
          strLocationID: locID,
          strZipcode: zipCode
        },
        false
      );
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
  },

  getOptOutInformation: function (
    component,
    event,
    helper,
    rsOptResReferralStatus
  ) {
    try {
      component.set('v.displayLoader',true);
      var bSuper = component.find("bSuper");

      bSuper.callServer(component, 'c.getOptOutInfoSharingDetails', function (response) {
        //hide spinner when server response received
        component.set('v.displayLoader',false);
        if (response.isSuccessful) {
          component.set("v.cartOptIn", response.objectData.OptOutInfoSharing);
          if (!component.get("v.cartOptIn")) {
            component.set('v.displayLoader',true);
            component.set("v.isConsentAgreed", false);
            if (rsOptResReferralStatus === 'Draft')
              helper.handleDraftConnectHelper(component, event, helper);
            else
              helper.createReferralOnConnect(component);
            component.set('v.displayLoader',false);
          }
        }
      }, null, false);
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
  },
  createReferralOnConnect: function (component) {

    try {
      //show spinner when request sent
      component.set('v.isSpinnerActive', true);
      var resourceRecord;
      var evtValue = component.get("v.selectedCardValue");
      var eventName = component.get("v.selectedCardName");


      if (eventName === 'othResConn') {

        resourceRecord = evtValue.objResource;
      } else {

        resourceRecord = evtValue;
      }
      var locationID = component.get("v.selectedLocRecord").Id;

      //reference to inherited super component
      var bSuper = component.find("bSuper");

      //override the method in super class and write your own logic with the response received
      bSuper.callServer(component, 'c.insertReferralForResident', function (response) {
        if (response.isSuccessful) {
          var accountName;
          var resourceName;

          if (eventName === 'othResConn') {

            accountName = evtValue.objResource.Organization__r.Name;
            resourceName = evtValue.objResource.Name;
            evtValue.isdisabledConnect = true;
            component.set("v.relatedResourcesWrapper", component.get("v.relatedResourcesWrapper"));
            bSuper.showToast($A.get("$Label.c.successstatus"), 'Success', $A.get('$Label.c.successfully') +' '+accountName +' '+ $A.get('$Label.c.for_resource') +' '+ resourceName);
          } else {
            accountName = evtValue.Organization__r.Name;
            resourceName = evtValue.Name;
            component.set("v.isSelectedResConDisabled", true);
            bSuper.showToast($A.get("$Label.c.successstatus"), 'SUCCESS', $A.get('$Label.c.successfully') +' '+ accountName +' '+ $A.get('$Label.c.for_resource') +' '+ resourceName);
          }
        }

      }, {
        "objResource": resourceRecord,
        "strlocationID": locationID,
        "bConsentAgreed": component.get("v.isConsentAgreed")
      }, false);
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }

  },

  dateConverter: function (isoTime) {
    var hours = isoTime.substring(0, 5),ampm;
    var index = isoTime.length;
    ampm = isoTime.substring(index-2,index);
    if (ampm === 'AM') {
      ampm = 'am';
    } else {
      ampm = 'pm';
    }
    return hours + ' ' + ampm;
  },

  isResidentUser: function (component) {

    try {
      //show spinner when request sent
      component.set('v.isSpinnerActive', true);

      //reference to inherited super component
      var bSuper = component.find("bSuper");

      //override the method in super class and write your own logic with the response received
      bSuper.callServer(component, 'c.getLoggedInUserRole', function (response) {
        component.set('v.isSpinnerActive', false);
        if (response.isSuccessful) {
          component.set("v.isGuest", response.objectData.bIsGuestUser);
          component.set("v.isResident", response.objectData.bIsResidentorGuest);

        } else {
          var errMsg = '';
          errMsg = $A.get('$Label.c.servererror');
          bSuper.showToast('Error', 'Error', errMsg);
        }
      }, {
      }, false);
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }

  },
  getDayName: function () {
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
  operatingHoursDayValue: function (component, weekdayValue, locTimeData) {
    var sOperatingHoursDataValue;
    if (weekdayValue === $A.get('$Label.c.monday')) {
      if (component.get("v.mondayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.MondayOpen +
          " to " +
          locTimeData.MondayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.tuesday')) {
      if (component.get("v.tuesdayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.TuesdayOpen +
          " to " +
          locTimeData.TuesdayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.wednesday')) {
      if (component.get("v.wednesdayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.WednesdayOpen +
          " to " +
          locTimeData.WednesdayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.thursday')) {
      if (component.get("v.thursdayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.ThursdayOpen +
          " to " +
          locTimeData.ThursdayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.friday')) {
      if (component.get("v.fridayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue = $A.get('$Label.c.today') + ' ' + locTimeData.FridayOpen + ' to ' + locTimeData.FridayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.saturday')) {
      if (component.get("v.saturdayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.SaturdayOpen +
          " to " +
          locTimeData.SaturdayClose;
      }

    }
    if (weekdayValue === $A.get('$Label.c.sunday')) {
      if (component.get("v.sundayClose")) {
        sOperatingHoursDataValue = $A.get('$Label.c.Closed');
      } else {
        sOperatingHoursDataValue =
          $A.get("$Label.c.today") +
          " " +
          locTimeData.SundayOpen +
          " to " +
          locTimeData.SundayClose;
      }

    }
    return sOperatingHoursDataValue;
  },
  getAllLocations: function (component) {
    var recId = component.get("v.resourceId");
    //show spinner when request sent
    component.set('v.isSpinnerActive', true);
    //reference to inherited super component
    var bSuper = component.find("bSuper");
    //override the method in super class and write your own logic with the response received
    bSuper.callServer(component, 'c.getAllLocations', function (response) {
      if (response.isSuccessful) {
        var result = response.objectData.allLocations;
        component.set("v.LocationRecords", result);

      }
    }, {
      "strResourceID": recId
    }, false);

  },

  getParam: function (component) {
    var resourceID = (this.getURLParam().resourceId) ? atob(this.getURLParam().resourceId) : '';
    var locationID = (this.getURLParam().locationId) ? atob(this.getURLParam().locationId) : '';
    var zipcode = (this.getURLParam().zipcode) ? atob(this.getURLParam().zipcode) : '';
    var contactId = (this.getURLParam().sContactId);

    if (!$A.util.isUndefinedOrNull(resourceID) && resourceID !== '' && !$A.util.isUndefinedOrNull(locationID) && locationID !== '' && !$A.util.isUndefinedOrNull(zipcode) && zipcode !== '') {
      component.set("v.resourceId", resourceID);
      component.set("v.locationId", locationID);
      component.set("v.zipcode", zipcode);
      component.set("v.myplanurl", "/my-plan?sContactId=" + contactId);
    }

  },
  getURLParam: function () {
    var query = location.search.substr(1);
    var result = {};
    if (query !== '') {
      query.split("&").forEach(function (part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
      });
    }
    return result;
  },

  handleDraftConnectHelper: function (component, event, helper) {
    try {
      var rsRefArrayDetails = helper.getDraftResourceReferralDetails(component);
      //reference to inherited super component
      var bSuper = component.find("bSuper");
      //override the method in super class and write your own logic with the response received
      bSuper.callServer(component, 'c.connectDraftReferralsFromResourceDetails', function (response) {
        //hide spinner when server response received
        component.set('v.isSpinnerActive', false);
        //to do
        if (response.isSuccessful) {
          $A.get('e.force:refreshView').fire();
          var accountName = rsRefArrayDetails[1];
          var resourceName = rsRefArrayDetails[2];
          bSuper.showToast($A.get("$Label.c.successstatus"), 'SUCCESS', $A.get('$Label.c.successfully')+' '+ accountName +' '+$A.get('$Label.c.for_resource')+' '+ resourceName);
          var ccEvent = $A.get("e.c:RE_CountEvent");
          ccEvent.setParams({
            "cartCount": response.objectData.draftReferralCount
          });
          ccEvent.fire();
        } else {
          var errMsg = $A.get("$Label.c.servererror");
          bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
        }
      }, {
        "strReferralId": rsRefArrayDetails[0],
        "bConsentAgreed": component.get("v.isConsentAgreed")
      }, false);
    } catch (e) {
      bSuper.consoleLog(e.stack, true);
    }
  },

  getReferralStatus: function (component) {
    var selCardValue = component.get("v.selectedCardValue");
    var selName = component.get("v.selectedCardName");
    var rsReferralStatus = '';
    if (selName === 'othResConn'
      && !$A.util.isUndefinedOrNull(selCardValue.objResource.Referrals__r))
      rsReferralStatus = selCardValue.objResource.Referrals__r[0].Status__c;
    else if (selName === 'selResConn'
      && !$A.util.isUndefinedOrNull(selCardValue.Referrals__r))
      rsReferralStatus = selCardValue.Referrals__r[0].Status__c;
    return rsReferralStatus;
  },

  getDraftResourceReferralDetails: function (component) {
    var selRefCardValue = component.get("v.selectedCardValue");
    var selRefName = component.get("v.selectedCardName");
    var rsRefArray = [];
    if (selRefName === 'othResConn'
      && !$A.util.isUndefinedOrNull(selRefCardValue.objResource.Referrals__r)) {
      rsRefArray[0] = selRefCardValue.objResource.Referrals__r[0].Id;
      rsRefArray[1] = selRefCardValue.objResource.Organization__r.Name;
      rsRefArray[2] = selRefCardValue.objResource.Name;
    }
    else if (selRefName === 'selResConn'
      && !$A.util.isUndefinedOrNull(selRefCardValue.Referrals__r)) {
      rsRefArray[0] = selRefCardValue.Referrals__r[0].Id;
      rsRefArray[1] = selRefCardValue.Organization__r.Name;
      rsRefArray[2] = selRefCardValue.Name;
    }
    return rsRefArray;
  },
  /* format phone number */
  formatPhoneNumber: function (phoneNumber) {
    var phone = ("" + phoneNumber).replace(/\D/g, '');
    var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
    if (!formatedPhone) {
      return phone;
    }
    return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
  }
})