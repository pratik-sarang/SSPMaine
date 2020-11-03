({
    init: function (cmp, event, helper) {
        cmp.set("v.getURL", window.location.pathname);
        // helper.getLocationfilter(cmp);
        helper.getLoggedInUserRole(cmp, event, helper);
        helper.createColumnData(cmp, event, helper);
        if(sessionStorage.getItem('isFromOneView') === "false" || sessionStorage.getItem('isFromOneView') == null)
        {
            cmp.set("v.individualIDCheck", true);
        }
    },
    backToClientSearch: function (cmp, event, helper) {
        if(sessionStorage.getItem('isFromOneView') === "true")
        {
            if(sessionStorage.getItem('allSearchCriteria') != null)
            {
                var allSearchValues = JSON.parse(sessionStorage.getItem('allSearchCriteria'));
                if(cmp.get("v.isAgencyUser") === true)
                {
                    if(!($A.util.isUndefinedOrNull(allSearchValues.userInputIndividualID) || allSearchValues.userInputIndividualID === ""))
                    {
                        cmp.set("v.individualID", allSearchValues.userInputIndividualID);
                        cmp.set("v.individualIDCheck", true);
                        helper.agencySearchActionHelper(cmp, event, helper);
                    }
                    else if(!($A.util.isUndefinedOrNull(allSearchValues.userInputCaseNumber) || allSearchValues.userInputCaseNumber === ""))
                    {
                        cmp.set("v.caseNumber", allSearchValues.userInputCaseNumber);
                        cmp.set("v.individualIDCheck", false);
                        cmp.set("v.caseNumberCheck", true);
                        cmp.set("v.value", 'Case Number');
                        helper.agencySearchActionHelper(cmp, event, helper);
                    }
                    else if(!($A.util.isUndefinedOrNull(allSearchValues.userInputSSN) || allSearchValues.userInputSSN === ""))
                    {
                        cmp.set("v.ssn", allSearchValues.userInputSSN);
                        cmp.set("v.individualIDCheck", false);
                        cmp.set("v.ssnCheck", true);
                        cmp.set("v.value", 'SSN');
                        helper.agencySearchActionHelper(cmp, event, helper);
                    }
                    else if(!($A.util.isUndefinedOrNull(allSearchValues.userInputFirstName) || allSearchValues.userInputFirstName === "") 
                            && !($A.util.isUndefinedOrNull(allSearchValues.userInputLastName) || allSearchValues.userInputLastName === "")
                            && !($A.util.isUndefinedOrNull(allSearchValues.userInputDob) || allSearchValues.userInputDob === "")
                        )
                    {
                        cmp.set("v.FirstName", allSearchValues.userInputFirstName);
                        cmp.set("v.LastName", allSearchValues.userInputLastName);
                        cmp.set("v.dob", allSearchValues.userInputDob);
                        cmp.set("v.individualIDCheck", false);
                        cmp.set("v.nameDOBCheck", true);
                        cmp.set("v.value", 'Name/DOB');
                        helper.agencySearchActionHelper(cmp, event, helper);
                    }
                }
                else if(cmp.get("v.isCPUser") === true || cmp.get("v.isAssister") === true)//CP User or Assister User
                {
                    if(!($A.util.isUndefinedOrNull(allSearchValues.userInputFirstName) || allSearchValues.userInputFirstName === "") 
                            && !($A.util.isUndefinedOrNull(allSearchValues.userInputLastName) || allSearchValues.userInputLastName === "")
                            && !($A.util.isUndefinedOrNull(allSearchValues.userInputDob) || allSearchValues.userInputDob === "")
                        )
                    {
                        cmp.set("v.FirstName", allSearchValues.userInputFirstName);
                        cmp.set("v.LastName", allSearchValues.userInputLastName);
                        cmp.set("v.dob", allSearchValues.userInputDob);
                        var a = cmp.get('c.searchAction');
                        $A.enqueueAction(a);
                    }
                }
            }
        }
    },
    // Venkat: Redirection Task
    getURLParams:function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params)
        {
            var decryptedCaseNumber = params.decryptedCaseNumber;
            var decryptedIndividualId = params.decryptedIndividualId;
            // Expected URL for CaseNumber: https://r1dev-benefind-redev.cs33.force.com/s/clients?CaseNumber=1234567
            // Expected URL for IndividualID: https://r1dev-benefind-redev.cs33.force.com/s/clients?IndividualID=123456789
            if(!$A.util.isUndefinedOrNull(decryptedCaseNumber) && !$A.util.isEmpty(decryptedCaseNumber))
            {
                component.set("v.caseNumberCheck", true);
                component.set("v.individualIDCheck", false);
                component.set("v.value", 'Case Number');
                component.set("v.caseNumber", decryptedCaseNumber);
                component.set("v.isAgencyUser", true);
                component.set('v.allClientsCheck', true);
                helper.agencySearchActionHelper(component, event, helper);
            }
            if(!$A.util.isUndefinedOrNull(decryptedIndividualId) && !$A.util.isEmpty(decryptedIndividualId))
            {
                component.set("v.individualID", decryptedIndividualId);
                component.set("v.isLinkFromIEES", true);
                component.set('v.allClientsCheck', true);
                helper.agencySearchActionHelper(component, event, helper);
            }
        }
    },
    // END
    handleRowClick:function (cmp, event, helper) { 
		var obj = cmp.get('v.sObject');
        var action = event.getParam('action');
        var row = event.getParam('row').Id;
        var rowObj = event.getParam('row');
        var isAgencyUser = cmp.get("v.isAgencyUser");
        if (obj === 'Contact' || obj === 'Favorite__c') {
            switch (action.name) {
                case 'View':
                    if (!$A.util.isUndefinedOrNull(rowObj.BirthDate)) {
                        rowObj.BirthDate = $A.localizationService.formatDate(rowObj.BirthDate, "yyyy-MM-dd");
                    }
                    if ( isAgencyUser === true && (typeof row === 'undefined' || row === null)) {
                        helper.createContactAndOpenOneView(cmp,event, rowObj);
                    }else{
                        var cmpEvent = cmp.getEvent("OurClientsStopInitEvent");
                        cmpEvent.setParams({
                            "ClientId" : row,
                            "StopParentInit" : false,
                            "showdetail": true,
                            "clientData":rowObj
                        }); 
                        cmpEvent.fire();
                        location.hash = "clientId="+row;
                    }
                    break;
                case 'Create':
                    if(!$A.util.isUndefinedOrNull(rowObj.BirthDate)){
                        rowObj.BirthDate=$A.localizationService.formatDate(rowObj.BirthDate, "yyyy-MM-dd");
                    }
                    if(isAgencyUser === true && (typeof row === 'undefined' || row === null)){
                        helper.createContactAndOpenReferral(cmp,event, rowObj);
                    }else{
                        var cmpEvt = cmp.getEvent("OurClientsStopInitEvent");
                        cmpEvt.setParams({
                            "ClientId" : row,
                            "StopParentInit" : false,
                            "showdetail": false,
                            "clientName": event.getParam('row').FirstName +' '+ event.getParam('row').LastName,
                            "clientData":rowObj
                        });  
                        cmpEvt.fire();
                    }
                    break;
                case 'edit':
                    helper.checkUserAssociateWithContact(cmp, event, row);
                    break;
                case 'Request':
                    if (!$A.util.isUndefinedOrNull(rowObj.BirthDate)) {
                        rowObj.BirthDate = $A.localizationService.formatDate(rowObj.BirthDate, "yyyy-MM-dd");
                    }
                    cmp.set("v.showModalConsent", true);
                    $A.createComponent(
                        "c:RE_RequestConsentModal", { "clientId": row, "clientWrapper": rowObj, "sverbalConsentOrigin": cmp.get("v.sverbalConsentOrigin") },
                        function (newcomponent, status) {
                            if (status === 'SUCCESS') {
                                var body = cmp.get("v.body");
                                body.push(newcomponent);
                                cmp.set("v.body", body);
                            }
                            else if (status === 'INCOMPLETE') {

                            }
                            else if (status === 'ERROR') {

                            }
                        }
                    );
                    break;
                default:
            }
        }
        if (obj === 'ContentNote') {
            $A.createComponent(
                "c:RE_NotesDetails", { "recId": event.getParam('row') },
                function (newcomponent) {
                    if (cmp.isValid()) {
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);
                    }
                }
            );
        }
        if (obj === 'Referral__c') {
            $A.createComponent(
                "c:RE_ReferralDetails", {
                "aura:id": "referral",
                "refrecId": row,
                "isReferralInbox": cmp.get("v.referralOutboxTabCheck")
            },
                function (newcomponent) {
                    if (cmp.isValid()) {

                        cmp.set("v.bshowlocation", false);
                        cmp.set("v.bshowfilter", false);
                        cmp.get("v.body").length = 0;
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);
                    }
                }
            );
            document.getElementsByClassName("locationtable-cont")[0].classList.add("slds-hide");
            document.getElementsByClassName("locationtable-body")[0].classList.remove("slds-hide");
            document.getElementsByClassName("headingL1")[0].classList.add("slds-hide");
            document.getElementsByClassName("headingContainer")[0].classList.add("slds-hide");
            document.getElementsByClassName("locationsel-cont")[0].classList.add("slds-hide");
            document.getElementsByClassName("save-btn")[0].classList.add("slds-hide");
        }
        if (obj === 'Resource__c') {
            $A.createComponent(
                "c:RE_ResourceSummary", {
                "aura:id": "resourse",
                "resRecordId": row,
                "hideLocationHeaderOnAddResource": true
            },
                function (newcomponent) {
                    if (cmp.isValid()) {
                        cmp.get("v.body").length = 0;
                        var body = cmp.get("v.body");
                        body.push(newcomponent);
                        cmp.set("v.body", body);
                    }
                }
            );
            document.getElementsByClassName("locationtable-cont")[0].classList.add("slds-hide");
            document.getElementsByClassName("locationtable-body")[0].classList.remove("slds-hide");
            document.getElementsByClassName("headingL1")[0].classList.add("slds-hide");
            document.getElementsByClassName("headingContainer")[0].classList.add("slds-hide");
            document.getElementsByClassName("locationsel-cont")[0].classList.add("slds-hide");
        }
    },
    getSelectedName: function (cmp, event) {
        var selectedRows = event.getParam('selectedRows');
        var slectedData = [];
        // Display that fieldName of the selected rows
        for (var i = 0; i < selectedRows.length; i += 1) {
            slectedData.push({
                "Name": selectedRows[i].Name,
                "Email": selectedRows[i].Email,
                "Id": selectedRows[i].Id,
                "Phone": selectedRows[i].Phone
            });
        }
        cmp.set('v.selectedDataArr', slectedData);
    },
    HideMe: function (component) {
        component.set("v.ShowModule", false);
    },
    ShowModuleBox: function (component) {
        component.set("v.ShowModule", true);
    },
    handleLocationChange: function (component, event, helper) {
        component.set('v.mydata', null);
        component.set('v.pageNumber', 1);
        helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
    },
    handleSort: function (component, event, helper) {
        var sortBy = event.getParam("fieldName");
        var sortDirection = event.getParam("sortDirection");
        component.set("v.sortBy", sortBy);
        component.set("v.sortDirection", sortDirection);
        //helper.sortData(component,event,helper);
        if (!(component.get('v.sObject') === 'Contact' && component.get('v.allClientsCheck') === true)) {
            helper.sortData(component, event, helper);
        } else {
            helper.sortDataOnFields(component);
        }
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber + 1);
        component.set("v.isLastPage", true);
        helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
    },
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber - 1);
        helper.getData(component);
    },
    openEditModal: function (component, event, helper) {
        component.set("v.showModal", true);
        helper.createModal(component, event, helper);
    },

    closehandler: function (component, event) {
        var sObject = event.getParam("sObjectName");
        if (event.getParam("sObjectId")) {
            var sObjectId = event.getParam("sObjectId");
            component.set("v.recid", sObjectId);
        }
        component.set("v.testing", sObject);
        component.set("v.sObject", sObject);
        component.set("v.showModal", false);
        var reloadtable = component.get('c.init');
        $A.enqueueAction(reloadtable);
    },
    searchAction: function (component, event, helper) {
        component.set('v.pageNumber', 1);
        component.set("v.searchCheck", true);
        var searchCheckCtrl = component.get("v.searchCheck");
        var validateDob;
        var errMsg;//Kojashree 20Dec LV issue fix
        var entry_not_match = $A.get('$Label.c.entry_not_match');
        var mmddyyyy = $A.get('$Label.c.mmddyyyy');
        if (searchCheckCtrl === true) {
            var userInputFirstName = component.get("v.FirstName");
            var userInputLastName = component.get("v.LastName");
            var userInputDob = component.get("v.dob");
            var date_regex = /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/;
            var firstName_regex = /^[a-zA-Z]+$/;
            var lastName_regex = /^[a-zA-Z]+$/;
            var bSuper = component.find("bSuper");
            if (!$A.util.isUndefinedOrNull(userInputDob)) {
                validateDob = component.get("v.dob").split("-");
            }
            /*if(!$A.util.isUndefinedOrNull(userInputFirstName) && !$A.util.isUndefinedOrNull(userInputLastName) && component.get("v.checkFutureDate") ===true){
                component.set("v.checkFutureDate",false);
                return false;
            }*/

            if (component.get('v.allClientsCheck') === false && ($A.util.isUndefinedOrNull(userInputFirstName) && $A.util.isUndefinedOrNull(userInputLastName)
                || $A.util.isUndefinedOrNull(userInputLastName) && $A.util.isUndefinedOrNull(userInputDob)
                || $A.util.isUndefinedOrNull(userInputFirstName) && $A.util.isUndefinedOrNull(userInputDob)
                || userInputFirstName === "" && userInputLastName === ""
                || userInputLastName === "" && userInputDob === ""
                || userInputDob === "" && userInputFirstName === ""
                || userInputFirstName === "" && $A.util.isUndefinedOrNull(userInputLastName)
                || userInputLastName === "" && $A.util.isUndefinedOrNull(userInputDob)
                || userInputDob === "" && $A.util.isUndefinedOrNull(userInputFirstName)
                || userInputFirstName === "" && $A.util.isUndefinedOrNull(userInputDob)
                || userInputLastName === "" && $A.util.isUndefinedOrNull(userInputFirstName)
            )) {
                errMsg = $A.get("$Label.c.clientsearchvalidation");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            } else if (component.get('v.allClientsCheck') === true && ($A.util.isUndefinedOrNull(userInputFirstName)
                || $A.util.isUndefinedOrNull(userInputLastName) || $A.util.isUndefinedOrNull(userInputDob) ||
                $A.util.isEmpty(userInputFirstName.trim()) || $A.util.isEmpty(userInputLastName.trim())
                || $A.util.isEmpty(userInputDob.trim()))) {
                errMsg = $A.get("$Label.c.AllClientSearchValidation");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            } else if (component.get("v.checkFutureDate")) {
                //component.set("v.checkFutureDate",false);
                return false;
            } else if (component.get('v.allClientsCheck') === true && helper.calculateAge(component) < 18) {
                //var errMsg = $A.get("$Label.c.AllClientSearchValidation");
                //bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                errMsg = $A.get("$Label.c.No_match_client_search");
                bSuper.showToast($A.get("$Label.c.RE_Info"), $A.get("$Label.c.RE_Info"), errMsg);
            }
            else {
                if (userInputDob === '' || $A.util.isUndefinedOrNull(userInputDob)) {
                    if (!firstName_regex.test(userInputFirstName) || !lastName_regex.test(userInputLastName)) {
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), entry_not_match);
                    } else {
                        component.set('v.mydata', null);
                        helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
                    }
                } else {
                    if ((!date_regex.test(userInputDob) || validateDob[1] > 12 || validateDob[2] > 31)) {
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), entry_not_match + mmddyyyy);
                    } else {
                        if (!$A.util.isUndefinedOrNull(userInputFirstName) && !firstName_regex.test(userInputFirstName) && userInputFirstName !== "") {
                            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), entry_not_match);
                        } else if (!$A.util.isUndefinedOrNull(userInputLastName) && !lastName_regex.test(userInputLastName) && userInputLastName !== "") {
                            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), entry_not_match);
                        } else {
                            component.set('v.mydata', null);
                            helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
                        }
                    }
                }
            }
        }
        return true;
    },

    referralSearchAction: function (component, event, helper) {
        var bSuper = component.find("bSuper");
        var date_regex = /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/;
        var inputDate = component.get("v.createddate");
        var inputValue = document.querySelectorAll('.custom-lookup-container .slds-lookup__search-input')[0].value;
        var itemClicked = document.querySelectorAll('.lookup-container')[0].classList.contains('slds-hide');

        if ((!date_regex.test(inputDate)) && !$A.util.isUndefinedOrNull(inputDate) && inputDate !== "") {
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.RE_SelectedValidDate"));
        }
        else if (!itemClicked && inputValue.trim() !== '' && inputValue.length) {
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.valid_client_error"));
        }
        else {
            component.set('v.initiallocid', '');
            component.set('v.sstatus', '');
            component.set('v.mydata', null);
            component.set('v.pageNumber', 1);
            helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
        }
    },


    resetSearchAction: function (component, event, helper) {
        if (document.querySelectorAll('.custom-lookup-container .slds-lookup__search-input')[0]) {
            document.querySelectorAll('.custom-lookup-container .slds-lookup__search-input')[0].value = '';
        }
        var empty = [];
        var referralOutbox = component.get("v.referralOutboxTabCheck");
        component.set("v.selectedlocations", empty);

        component.set("v.selectedresources", empty);

        component.set("v.selectedstatus", empty);



        component.set("v.createddate", null);
        component.set("v.resourceName", null);
        component.set("v.orgName", null);
        component.set("v.days", null)
        if (component.get("v.contactId")) {
            var childCmp = component.find("conlookup");
            childCmp.lookupreset(true);
            component.set("v.contactId", '');

        }


        var genericresource = component.find("genericloc");
        if (!referralOutbox) {
            for (var i in genericresource) {
                if (genericresource.hasOwnProperty(i)) {
                    genericresource[i].genericreset(true);
                }
            }
        }
        else {
            genericresource.genericreset(true);
        }
        component.set("v.breset", false);
        component.set("v.lessthangreaterthan", 'None');
        component.set('v.mydata', null);
        component.set('v.pageNumber', 1);
        component.set('v.sstatus', 'Closed');
        component.set('v.initiallocid', component.get("v.initiallocidconst"));



        helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
    },
    handleComponentEvent: function (component, event) {
        //document.querySelectorAll('.custom-lookup-container .slds-lookup__search-input')[0].value='';
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        var objName = event.getParam("lookupObjName");
        //var objWrapper = component.get("v.referralObj");
        if (selectedAccountGetFromEvent !== 'cleared' && objName === 'Contact') {
            //var k= component.get("v.contactId");
            //var conid=selectedAccountGetFromEvent.Id;
            component.set("v.contactId", selectedAccountGetFromEvent.Id);
        } else if (selectedAccountGetFromEvent === 'cleared' && objName === 'Contact') {
            component.set("v.contactId", '');
            // objWrapper.Contact='';
        }
    },
    handleoperatorchange: function (component) {
        var daysOpen = component.find("operator").get("v.value");
        if (daysOpen === "None") {
            component.set("v.days", null);
        }
    },
    resetAction: function (component, event, helper) {
        component.set('v.FirstName', '');
        component.set('v.LastName', '');
        component.set('v.dob', '');
        component.set('v.individualID','');
        component.set('v.caseNumber','');
        component.set('v.ssn','');
        component.set('v.pageNumber', '1');
        component.set('v.mydata', null);
        if (!(component.get('v.sObject') === 'Contact' && component.get('v.allClientsCheck') === true))//Kojashree 20Dec LV issue fix
        {
            helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
        }
        var inputCmp = component.find("DOB_fld");
        if ((!$A.util.isUndefinedOrNull(inputCmp)) && component.get('v.allClientsCheck') === true) {
            inputCmp.set("v.errors", null);
        }
    },
    // RE_Release 1.1 - Agency User Capture - Venkat
    handleChange : function(component, event, helper) {
        var a = component.get('c.resetAction');
        $A.enqueueAction(a);
        var selectedCheckboxValue = event.getParam("value");
        if(selectedCheckboxValue === 'Case Number')
        {
            component.set("v.caseNumberCheck", true);
            component.set("v.individualIDCheck", false);
            component.set("v.nameDOBCheck", false);
            component.set("v.ssnCheck", false);
        }
        else if(selectedCheckboxValue === 'SSN')
        {
            component.set("v.ssnCheck", true);
            component.set("v.individualIDCheck", false);
            component.set("v.caseNumberCheck", false);
            component.set("v.nameDOBCheck", false);
        }
        else if(selectedCheckboxValue === 'Name/DOB')
        {
            component.set("v.nameDOBCheck", true);
            component.set("v.individualIDCheck", false);
            component.set("v.caseNumberCheck", false);
            component.set("v.ssnCheck", false);
        }
        else
        {
            component.set("v.individualIDCheck", true);
            component.set("v.caseNumberCheck", false);
            component.set("v.nameDOBCheck", false);
            component.set("v.ssnCheck", false);
        }
    },
    agencySearchAction:  function(component, event, helper) 
    {
        helper.agencySearchActionHelper(component, event, helper); 
    },
    // END
    checkFutureDate: function (component, event, helper) {
        if (component.get("v.dob") !== "") {
            var validDate = helper.checkInvalidDate(component);
            if (validDate) {
                helper.checkFutureDateHelper(component);
                var inputCmp = component.find("DOB_fld");
                if (!$A.util.isUndefinedOrNull(inputCmp) && component.get('v.allClientsCheck') === true) {
                    if ($A.util.isUndefinedOrNull(component.get("v.dob")) || $A.util.isEmpty(component.get("v.dob"))) {
                        inputCmp.set("v.errors", [{ message: "Complete this field." }]);
                    }
                    /*else if(helper.calculateAge(component) < 18){
                     inputCmp.set("v.errors", [{message:"Invalid Date"}]);
                    }*/
                    else {

                        inputCmp.set("v.errors", null);
                    }
                }

            } else {
                var bSuper = component.find("bSuper");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), $A.get("$Label.c.RE_DOB"));
                //return false;
            }
        }
    }
    /*checkDOBFormat  : function(component) {
        
        var usrIpDob = [];
        var inputDate = component.find("inputDate");
        usrIpDob = component.get("v.dob").split("/");
        var bSuper = component.find("bSuper");
        if(usrIpDob[0] >12 || usrIpDob[1] >31 ){
            inputDate.set("v.errors", [{message:"format MM/DD/YYYY"}]);
            component.set("v.dobCheck",true);
            //bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), 'Your entry does not match the allowed format MM/DD/YYYY');
        }else{
            component.set("v.dobCheck",false);
            inputDate.set("v.errors", null);
        }
    }*/

})