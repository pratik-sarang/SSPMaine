({
    onfocus: function (component) {
        component.set("v.Message", "");
        //Lagan's changes
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);
            var component_failure = $A.get('$Label.c.component_failure');

            //reference to inherited super component
            var bSuper = component.find("bSuper");

            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getAllOptions', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    component.set("v.lstAllFieldValues", response.objectData.PicklistVals);
                } else {
                    bSuper.showToast('ERROR', 'ERROR', component_failure);
                }
            }, {
                    "sObjectName": component.get("v.sObjectAPIName"),
                    "sFieldAPIName": component.get("v.sFieldAPIName")

                }, false);
        } catch (e) {
            bSuper.showToast('ERROR', 'ERROR', e);

        }

    },

    handleRemove: function (component, event) {

        var bReadOnly = component.get("v.bMakeReadOnly");
        if (!bReadOnly) {
            var selectedValues = component.get("v.lstFieldValues");
            var sRemovedValues = event.getSource().get('v.label');

            var index2 = selectedValues.indexOf(sRemovedValues);
            selectedValues.splice(index2, 1);
            component.set('v.lstFieldValues', selectedValues);
            var cmpEvent = component.getEvent("LanguagesUpdateEventNew");
            cmpEvent.setParams({ "listSelectedfieldValues": selectedValues });
            cmpEvent.fire();
        }

    },
    addValue: function () {
        var plusIcon = document.getElementById("plus-icon");
        var searchValue = document.getElementById("search-value");
        var searchOptions = document.getElementById("search-options");
        if (plusIcon) {
            plusIcon.classList.toggle("slds-hide");
        }
        if (searchOptions) {
            searchOptions.classList.toggle("slds-hide");
        }
        if (searchValue) {
            searchValue.classList.toggle("slds-hide");
            searchValue.focus();
        }
        //component.set("v.bAddValueInput", true);
        searchValue.value = "";
    },

    keyPressController: function (component) {
        var AllLanguages = [];
        AllLanguages = component.get("v.lstAllFieldValues");
        var selectedLanguages = component.get("v.lstFieldValues");

        for (var i = 0; i < selectedLanguages.length; i += 1) {
            var index = AllLanguages.indexOf(selectedLanguages[i]);
            if (index > -1) {
                AllLanguages.splice(index, 1);
            }
        }

        component.set("v.lstUnselectedFieldValues", AllLanguages);

        var sSearchKeyword = document.getElementById("search-value").value.toUpperCase();

        if (sSearchKeyword.length !== 0) {
            var searchResults = [];
            for (i = 0; i <= AllLanguages.length; i += 1) {

                var sLanguage = AllLanguages[i];

                if (sLanguage !== undefined && sLanguage.toUpperCase().indexOf(sSearchKeyword) > -1) {
                    searchResults.push(sLanguage);
                }

            }
            if ((searchResults.length === 0)) {
                component.set("v.Message", "No results found");
            }
            else {
                component.set("v.Message", "");
            }

            component.set('v.lstUnselectedFieldValues', searchResults);

        }
    },
    selectRecord: function (component, event) {
        var selectedLanguages = component.get("v.lstFieldValues");
        var unSelectedLanguages = component.get("v.lstUnselectedFieldValues");
        var index = event.target.dataset.index;
        var selectedLanguage = component.get("v.lstUnselectedFieldValues")[index];
        selectedLanguages.push(selectedLanguage);
        var index2 = unSelectedLanguages.indexOf(selectedLanguage);
        unSelectedLanguages.splice(index2, 1);
        component.set('v.lstUnselectedFieldValues', unSelectedLanguages);
        component.set('v.lstFieldValues', selectedLanguages);

        var cmpEvent = component.getEvent("LanguagesUpdateEventNew");
        cmpEvent.setParams({ "listSelectedfieldValues": selectedLanguages });
        cmpEvent.fire();
    },
    removeBox: function (component) {
        var plusIcon = document.getElementById("plus-icon");
        var searchValue = document.getElementById("search-value");
        var searchOptions = document.getElementById("search-options");

        if (plusIcon) {
            plusIcon.classList.toggle("slds-hide");
        }
        if (searchValue) {
            searchValue.classList.toggle("slds-hide");
        }
        if (searchOptions) {
            searchOptions.classList.toggle("slds-hide");
        }
        component.set("v.lstUnselectedFieldValues", "");
    }
})