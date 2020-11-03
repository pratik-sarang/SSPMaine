({
  /* onload data load*/
  doInit: function (component, event, helper) {
    component.set("v.resLimit", $A.get("$Label.c.Keyword_Search_PageLimit"));
    helper.getZipCode(component, event, helper);
      setTimeout(function(){//JAWS Fix
          document.getElementsByClassName("modal-lg-heading")[0].focus(); 
      },1000);
  },
  /* handle zipcode validation*/
  handleZipCode: function (component) {
    var zipCode = component.get("v.zipCode");
    //if(zipCode.length === 5){
    if (zipCode.length > 0) {
      var filterCmp = component.find("cmpFilter");
      filterCmp.set("v.onFilterLoad", true);
      component.set("v.isDisabled", false);
    } else {
      component.set("v.isDisabled", true);
    }
  },
  /*submit zip to load results */
  submitZipCode: function (component, event, helper) {
    var result = helper.validateZipCode();
    if (!result) {
      var zipCode = component.get("v.zipCode");
      var encodedZip = window.btoa(zipCode);
      sessionStorage.setItem("zipCodeVal", encodedZip);
      component.set("v.showDiscoverResource", false);
      helper.getParamValue(component, event, helper);
    } else {
      this.showToast(component, event, $A.get("$Label.c.RE_ZipCode_Error"));
      component.set("v.showDiscoverResource", true);
    }
  },
  /*cancel Zipcode*/
  cancelZipCode: function (component) {
    component.set("v.showDiscoverResource", false);
    window.history.back();
  },
  /*load resource based on zip change*/
  updateResources: function (component, event, helper) {
    /* var cachedZip = sessionStorage.getItem("zipCodeVal");
        debugger
        if(!cachedZip){
            sessionStorage.setItem("zipCodeVal", component.get("v.zipCode"));
        }*/
    if (!component.get("v.onLoad") || component.get("v.updateResources")) {
      var bSearchKey = component.get("v.sSearchKey");
      if (!$A.util.isEmpty(bSearchKey)) {
        component.set("v.isSpinnerActive", true);
        component.set("v.resOffset", 0);
        component.set("v.searchresults", []);
        component.set("v.originalSearchResults", []);
        component.set("v.displayCard", false);
        component.set("v.displayMap", false);
        component.set("v.disableScroll", true);
        helper.getSearchResults(component, event, helper);
      } else {
        component.set("v.isSpinnerActive", true);
        component.set("v.resOffset", 0);
        component.set("v.searchresults", []);
        component.set("v.originalSearchResults", []);
        component.set("v.displayCard", false);
        component.set("v.searchbycategory", true);
        helper.getSubcategorySearchResults(component, event, helper);
      }
    }
  },
  /* update search results based on category */
  updateResourcesBasedCategory: function (
    component,
    event,
    helper,
    newlistarray
  ) {
    var filterCategories = [];
    var originalJobs = [];
    if (newlistarray !== undefined && newlistarray.size() > 0) {
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
      //component.set("v.searchresults",component.get("v.originalSearchResults"));
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
    // helper.updateResourcesBasedCategory(component, event, helper);
  },
  /* handle Open/Close hours search*/
   updateResourcesBasedHours: function (component, event, helper) {
      helper.updateResourceBasesOnHourFilter(component,event,helper);
  },
  /*map event handler to display markers on map*/
  handleApplicationEvent: function (component, event, helper) {
    component.set("v.showSingleMarkerForCompleted", false);
    component.set("v.mapData", []);
    var cardOpenCloseIndex = event.getParam("index");
    var clickedIndex = event.getParam("resourceClickedIndex");
    var data = component.get("v.searchresults");

    var userLocation = component.get("v.userLocation");
    helper.mapDataHelper(
      component,
      event,
      data,
      userLocation,
      clickedIndex,
      cardOpenCloseIndex
    );
  },
  actionfromResourceCards: function (component) {
    component.set("v.isCreateRefferel", !component.get("v.isCreateRefferel"));
    //RE_Release 1.4 – Defect 378735- Payal Dubela
    /*if (component.get("v.sSearchKey")) {
      component.set("v.disableScroll", component.get("v.isCreateRefferel"));
    }*/
  },
  loadMore: function (component, event, helper) {
    helper.getSearchResults(component, event, helper);
  },
  loadMoreSearchbyCategory: function (component, event, helper) {
    helper.getSubcategorySearchResults(component, event, helper);
  },
    showFilter: function(component){
        $A.util.addClass(component.find("filter-button-show"),"slds-hide");
        $A.util.removeClass(component.find("result-filter"),"slds-hide");
        $A.util.removeClass(component.find("filter-button-hide"),"slds-hide");
    },
    hideFilter: function(component){
        $A.util.removeClass(component.find("filter-button-show"),"slds-hide");
        $A.util.addClass(component.find("result-filter"),"slds-hide");
        $A.util.addClass(component.find("filter-button-hide"),"slds-hide");
    },
  moveFocusToTop: function(component, event) {//JAWS Fix  
        setTimeout(function(){
            document.getElementsByClassName("modal-lg-heading")[0].focus(); 
        },10);
    }
});