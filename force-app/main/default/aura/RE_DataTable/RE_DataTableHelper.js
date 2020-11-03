({
    /* fetch the picklist Values based on the API names */
    fetchPicklistValues: function (component) {
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");

            var flds = component.get("v.picklistValues");

            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getPickListValues', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    var pickListFlds = flds.split(',');
                    var result = response.objectData.picklistvalues;
                    for (var index in pickListFlds) {
                        if (pickListFlds.hasOwnProperty(index)) {
                            var options = [];
                            var initialoptions = [];
                            var keys = Object.keys(result[pickListFlds[index]]);


                            for (var i in keys) {
                                if (keys.hasOwnProperty(i)) {
                                    if (keys[i] !== "Draft") {
                                        options.push({ Name: keys[i], Id: result[pickListFlds[index]][keys[i]] });
                                    }
                                    if (keys[i] !== "Draft" && keys[i] !== "Closed") {
                                        initialoptions.push({ Name: keys[i], Id: result[pickListFlds[index]][keys[i]] });
                                    }
                                }

                            }

                            if (pickListFlds[index] === "Status__c") {
                                component.set("v.statuslst", options);

                                component.set("v.initialstatuslst", initialoptions);
                            }
                        }
                    }

                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            },
                {
                    'strObjectName': 'Referral__c',
                    'strLstFields': component.get("v.picklistValues")
                }, false);
        }
        catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getColumns: function (cmp) {
        var columns = cmp.get("v.mycolumns");
        var columnNames = [];
        for (var i = 0; i < columns.length; i += 1) {
            if (columns[i].fieldName && columns[i].fieldName !== 'linkName')
                columnNames.push(columns[i].fieldName);
        }
        cmp.set("v.columnNames", columnNames);
    },
    getLocationfilter: function (cmp, event, helper) {

        try {
            //show spinner when request sent
            cmp.set('v.isSpinnerActive', true);
            var emptyObj = null;
            //reference to inherited super component
            var bSuper = cmp.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(cmp, 'c.getLocations', function (response) {
                //hide spinner when server response received
                cmp.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    var objectData = response.objectData.records;
                    var lstoptions = JSON.parse(objectData);
                    //  var lstoptions = JSON.parse(response);




                    var lstlocfilterdata = response.objectData.filterWrapper;
                    var lstlocfilter = JSON.parse(lstlocfilterdata);

                    var initiallocdata = response.objectData.loggedinLoc;
                    var initialloc = JSON.parse(initiallocdata);
                    cmp.set("v.initialloc", initialloc);
                    if (initialloc[0]) {
                        cmp.set("v.initiallocid", initialloc[0].Id);
                        cmp.set("v.initiallocidconst", initialloc[0].Id);
                    }


                    cmp.set("v.filterrecords", lstlocfilter);
                    if (cmp.get("v.sObject") === 'Referral__c') {
                        cmp.set("v.bshowfilter", "true");
                        cmp.set("v.bshowlocation", "false");
                    }

                    //var Statusobject='[{"Id":"New","Name":"NEW"},{"Id":"Closed","Name":"CLOSED"}]';

                    //locNames.push({ class: "optionClass", label: loc[i].Name, value: loc[i].Id, isChecked:true });  
                    // cmp.set("v.filterrecords", lstoptions);

                    cmp.set("v.lstLocations", lstoptions);
                    if (!(cmp.get('v.sObject') === 'Contact' && cmp.get('v.allClientsCheck') === true)) {
                        helper.getData(cmp, event, helper, cmp.get("v.pageNumber").toString(), false);
                    } else {
                        cmp.set("v.citizenCheck", "true");
                        cmp.set("v.isLastPage", "true");
                    }
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, emptyObj, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getData: function (cmp, event, helper, currentpageNumber, isSorting) {
        try {
            var isAgencyUser = cmp.get("v.isAgencyUser");
            var userInputIndividualID = cmp.get("v.individualID");
            var userInputCaseNumber = cmp.get("v.caseNumber");
            var userInputSSN = cmp.get("v.ssn");
            //show spinner when request sent
            cmp.set('v.isSpinnerActive', true);
            cmp.set("v.getURL", window.location.pathname);
            var string = cmp.get("v.getURL");
            if (string.includes("clients") || (cmp.get("v.isAssister") === true && string.includes("/"))) {
                cmp.set("v.citizenCheck", "true");
            }
            //Siri: Domain URL Changes -Task#389828
            //Smoketest issue - sspuat1 - Payal Dubela
            else if (string.includes("referral-outbox")) {
                cmp.set("v.referralOutboxTabCheck", true);
                cmp.set("v.citizenCheck", "false");
            }
            else {
                cmp.set("v.citizenCheck", "false");
            }
            //reference to inherited super component
            var bSuper = cmp.find("bSuper");
            var columns = cmp.get("v.columnNames");
            var pageSize = isSorting ? (cmp.get("v.pageNumber") * cmp.get("v.pageSize")).toString() : cmp.get("v.pageSize").toString();
            var pageNumber = currentpageNumber;
            var recid;
            var allClientsCheck;
            var sObjectName = cmp.get("v.sObject");
            var citizenCheck = cmp.get("v.citizenCheck");
            var searchCheck = cmp.get("v.searchCheck");

            if (searchCheck === true) {
                var str;
                var userInputFirstName = cmp.get("v.FirstName");
                var userInputLastName = cmp.get("v.LastName");
                var userInputDob = cmp.get("v.dob");
                // RE_Release 1.1 - Agency User Capture - Venkat - Line:190 - Added condition
                if (isAgencyUser === false || (isAgencyUser === true && cmp.get('v.nameDOBCheck') === true)) {
                    if ($A.util.isUndefinedOrNull(userInputDob) || userInputDob === "") {
                        str = "{\"FirstName\" : \"" + userInputFirstName + "\", \"LastName\" : \"" + userInputLastName + "\"}";
                    } else if ($A.util.isUndefinedOrNull(userInputLastName) || userInputLastName === "") {
                        //str  = "{\"FirstName\" : \""+userInputFirstName+"\", \"LastName\" : \""+userInputLastName+"\", \"birthDate\" : \""+userInputDob+"\"}";
                        str = "{\"FirstName\" : \"" + userInputFirstName + "\", \"birthDate\" : \"" + userInputDob + "\"}";
                    } else if ($A.util.isUndefinedOrNull(userInputFirstName) || userInputFirstName === "") {
                        str = "{\"LastName\" : \"" + userInputLastName + "\", \"birthDate\" : \"" + userInputDob + "\"}";
                    } else {
                        str = "{\"FirstName\" : \"" + userInputFirstName + "\", \"LastName\" : \"" + userInputLastName + "\", \"birthDate\" : \"" + userInputDob + "\"}";
                    }
                }
                // RE_Release 1.1 - Agency User Capture - Venkat
                else if (isAgencyUser === true && cmp.get('v.nameDOBCheck') === false) {
                    if (cmp.get('v.individualIDCheck') === true && !($A.util.isUndefinedOrNull(userInputIndividualID) || userInputIndividualID === "")) {
                        str = "{\"IndividualID\" : \"" + userInputIndividualID + "\"}";
                    }
                    else if (cmp.get('v.caseNumberCheck') === true && !($A.util.isUndefinedOrNull(userInputCaseNumber) || userInputCaseNumber === "")) {
                        str = "{\"CaseNumber\" : \"" + userInputCaseNumber + "\"}";
                    }
                    else if (cmp.get('v.ssnCheck') === true && !($A.util.isUndefinedOrNull(userInputSSN) || userInputSSN === "")) {
                        str = "{\"SSN\" : \"" + userInputSSN + "\"}";
                    }
                }
                // END
            }
            var allSearchCriteria = {userInputIndividualID, userInputCaseNumber, userInputSSN, userInputFirstName, userInputLastName, userInputDob};
            if(!($A.util.isUndefinedOrNull(userInputIndividualID) || userInputIndividualID === "")
                || !($A.util.isUndefinedOrNull(userInputCaseNumber) || userInputCaseNumber === "")
                || !($A.util.isUndefinedOrNull(userInputSSN) || userInputSSN === "")
                || (!($A.util.isUndefinedOrNull(userInputFirstName) || userInputFirstName === "") 
                    && !($A.util.isUndefinedOrNull(userInputLastName) || userInputLastName === "")
                    && !($A.util.isUndefinedOrNull(userInputDob) || userInputDob === "")
                    )
                )
            {
                sessionStorage.setItem('allSearchCriteria', JSON.stringify(allSearchCriteria));
            }
            if (sObjectName === "Resource__c" || citizenCheck === "true") {
                recid = "All";
                allClientsCheck = cmp.get("v.allClientsCheck");
            } else if (sObjectName === "Referral__c") {
                recid = "All";

            } else {
                recid = cmp.find("location").get("v.value");
            }


            //Set the varaibles here for the filter starts
            var filterwrapper = {};
            if (sObjectName === "Referral__c") {
                filterwrapper.contactId = cmp.get("v.contactId");
                filterwrapper.lstLocationFilter = cmp.get("v.selectedlocations");
                filterwrapper.lstResourceFilter = cmp.get("v.selectedresources");
                filterwrapper.status = JSON.stringify(cmp.get("v.selectedstatus"));
                filterwrapper.createddate = cmp.get("v.createddate") ? cmp.get("v.createddate") : null;
                filterwrapper.lessgreaterthan = cmp.get("v.lessthangreaterthan");
                filterwrapper.dayssinceopened = cmp.get("v.days") ? cmp.get("v.days") : null;
                filterwrapper.dafaultstatus = cmp.get('v.sstatus');
                filterwrapper.organizationName = cmp.get('v.orgName');
                filterwrapper.resourceName = cmp.get("v.resourceName");
                filterwrapper.defaultloc = cmp.get('v.initiallocid');
            }

            // Set the variables for the filter criteria here ends
            var clsDataTable = {};
            clsDataTable.sObjectName = sObjectName;
            clsDataTable.lstFlieds = columns;
            clsDataTable.pageSize = pageSize;
            clsDataTable.pageNumber = pageNumber;
            clsDataTable.recid = recid;
            clsDataTable.citizenCheck = citizenCheck;
            clsDataTable.allClientsCheck = allClientsCheck;
            clsDataTable.clientFirstName = userInputFirstName;
            clsDataTable.clientLastName = userInputLastName;
            clsDataTable.clientDob = userInputDob;
            if (isAgencyUser === true) {
                clsDataTable.clientIndividualID = userInputIndividualID;
                clsDataTable.clientCaseNumber = userInputCaseNumber;
                clsDataTable.clientSSN = userInputSSN;
            }
            clsDataTable.testStr = "disStr";
            clsDataTable.clientSearchDetails = str;
            //RE_Release 1.1 – 365008:Sorting issue on My Clients Screen
            if ((cmp.get('v.sObject') === 'Contact' && cmp.get("v.sortBy") === 'Phone')
                ||(cmp.get('v.sObject') === 'Favorite__c' && cmp.get("v.sortBy") === 'Phone')) {
                clsDataTable.sortField = '';
            } else {
                clsDataTable.sortField = cmp.get("v.sortBy");
            }
            clsDataTable.sortDirection = cmp.get("v.sortDirection");
            clsDataTable.referralfilterwrapper = filterwrapper;
            clsDataTable.isReferralOutboxTabClicked = cmp.get("v.referralOutboxTabCheck");
            var methodName = (cmp.get("v.isAssister") === true) ? 'c.getAssisterData' : 'c.getData';
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(cmp, methodName, function (response) {
                //hide spinner when server response received
                cmp.set('v.isSpinnerActive', false);
                if (response.isSuccessful) {
                    var mydata = response.objectData.records;
                    var obj = cmp.get("v.sObject");
                    mydata.forEach(function (record) {
                        if (obj === 'Referral__c') {
                            if (record.Resource__c) {
                                record.Resource__c = record.Resource__r.Name;
                            }
                            record.Createdbyid = record.CreatedBy.Name;
                            var diffindays = record.DaysSinceOpened__c + ' ' + $A.get("$Label.c.referraldaysago");
                            record.DaysSinceOpened__c = diffindays;
                            // if(record.Contacts__c && record.Contacts__r.FirstName && record.Contacts__r.LastName){
                            if (record.Contacts__r !== undefined && record.Contacts__r.FirstName)//Kojashree : 20Dec LV fix
                            {
                                record.Contacts__c = record.Contacts__r.FirstName;//+' '+record.Contacts__r.LastName;
                            } else {
                                record.Contacts__c = '';
                            }
                            /* Not needed as part of Bug : 341305
                            if(record.Status__c==='In Progress - Org in System' || record.Status__c==='In Progress - Org Not in System'){
                                record.Status__c='In Progress';
                            }  */

                            if (record.Contacts__r !== undefined && record.Contacts__r.LastName)//Kojashree : 20Dec LV fix
                            {
                                record.CreatedbyId = record.Contacts__r.LastName;
                            } else {
                                record.CreatedbyId = '';
                            }
                            if (record.Location__r !== undefined)//Kojashree : 20Dec LV fix
                            {
                                record.location__c = record.Location__r.Name;
                            } else {
                                record.location__c = '';
                            }
                        }
                        else if (obj === 'Contact') {
                            if (record.PrimaryLocationName) {
                                record.PrimaryLocation =record.PrimaryLocationName;
                            }
                            if (record.Phone) {
                                record.Phone = helper.formatPhoneNumber(cmp, record.Phone);
                            }
                            if (!$A.util.isUndefinedOrNull(record.BirthDate) && !$A.util.isEmpty(record.BirthDate)) {
                                record.BirthDate = $A.localizationService.formatDate(record.BirthDate, "MM/dd/yyyy");
                            }
                        }
                        //Nandita: 04/08/2020: added logic to fix teh DOB issue for My Clients tab
                        else if (obj === 'Favorite__c') {

                            if (!$A.util.isUndefinedOrNull(record.Birthdate) && !$A.util.isEmpty(record.Birthdate)) {
                                record.BirthDate = $A.localizationService.formatDate(record.Birthdate, "MM/dd/yyyy");
                            }
                        }
                    });
                    if (!(cmp.get('v.sObject') === 'Contact' && cmp.get('v.allClientsCheck') === true))//Kojashree : 20Dec LV fix
                    {
                        if (response.objectData.records.length < cmp.get("v.pageSize")) {
                            cmp.set("v.isLastPage", true);
                        } else if ((!$A.util.isUndefinedOrNull(isSorting) && !isSorting)) {
                            cmp.set("v.isLastPage", false);
                        }
                        cmp.set("v.dataSize", response.objectData.records.length);
                        var currentData = cmp.get('v.mydata');
                        var newData = response.objectData.records;
                        if ($A.util.isUndefinedOrNull(currentData) || (!$A.util.isUndefinedOrNull(isSorting) && isSorting)) {
                            cmp.set('v.mydata', newData);
                        } else {
                            var allData = currentData.concat(newData);
                            var myArrSerialized = allData.map(e => JSON.stringify(e));
							var mySetSerialized = new Set(myArrSerialized);
                            var myUniqueArrSerialized = [...mySetSerialized];
                            var myUniqueArr = myUniqueArrSerialized.map(e => JSON.parse(e));
                            cmp.set('v.mydata', myUniqueArr);
                            //cmp.set('v.mydata', currentData.concat(newData));
                        }
                        if ((cmp.get('v.sObject') === 'Contact' || cmp.get('v.sObject') === 'Favorite__c') && cmp.get("v.sortBy") === 'Phone') {
                            helper.sortDataOnFields(cmp);
                        }
                    } else {
                        if (response.objectData.records.length === 0) {
                            cmp.set("v.isLinkFromIEES", false);
                            var errMsg = $A.get("$Label.c.No_match_client_search");
                            bSuper.showToast($A.get("$Label.c.RE_Info"), 'Info', errMsg);
                        }
                        cmp.set('v.mydata', response.objectData.records);
                        //To sort Client Search data by default
                        if ($A.util.isUndefinedOrNull(cmp.get("v.sortBy"))) {
                            cmp.set("v.sortBy", 'FirstName');
                            cmp.set("v.sortDirection", 'asc');
                        }
                        helper.sortDataOnFields(cmp);
                    }
                    helper.sortDataOnFields(cmp);
                    cmp.set('v.allData', response.objectData.records);
                    sessionStorage.removeItem('isFromOneView');
                    if(cmp.get("v.isLinkFromIEES") === true && (cmp.get('v.sObject') === 'Contact' || cmp.get('v.sObject') === 'Favorite__c'))
                    {
                        var rowObj = cmp.get("v.allData")[0]; 
                        var row;
                        if(!$A.util.isUndefinedOrNull(rowObj.BirthDate))
                        {
                            rowObj.BirthDate=$A.localizationService.formatDate(rowObj.BirthDate, "yyyy-MM-dd");
                        }
                        var row = rowObj.Id;
                        if(!$A.util.isUndefinedOrNull(rowObj) && !$A.util.isEmpty(rowObj) && (typeof row === 'undefined' || row === null))
                        {
                            helper.createContactAndOpenOneView(cmp,event, rowObj);
                        }
                        else{
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
                    }
                } else {
                    var servererrMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), servererrMsg);
                }

            }, { clsDataTable: clsDataTable }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createModal: function (component) {
        $A.createComponent(
            "c:RE_OurTeamEditModal", {
            "aura:id": "editmodal"
        },
            function (newcomponent) {
                if (component.isValid()) {
                    var body = component.get("v.body");
                    body.push(newcomponent);
                    component.set("v.body", body);
                }
            }
        );
    },


    getNotes: function (cmp) {
        try {
            //show spinner when request sent
            cmp.set('v.isSpinnerActive', true);

            var pageSize = cmp.get("v.pageSize").toString();
            var pageNumber = cmp.get("v.pageNumber").toString();
            var recid = cmp.get("v.recid");
            // var emptyObj = null;
            //reference to inherited super component
            var bSuper = cmp.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(cmp, 'c.getNotes', function (response) {
                //hide spinner when server response received
                cmp.set('v.isSpinnerActive', false);
                if (response.isSuccessful) {
                    var objectData = response.objectData.records;
                    var lstrecords = JSON.parse(objectData);
                    var button;
                    if (lstrecords.length < cmp.get("v.pageSize")) {
                        button = cmp.find('Loadmorebutton');
                        $A.util.toggleClass(button, "slds-hide");
                        cmp.set("v.isLastPage", true);
                    } else {
                        button = cmp.find('Loadmorebutton');
                        $A.util.toggleClass(button, "slds-show");
                        cmp.set("v.isLastPage", false);
                    }
                    cmp.set("v.dataSize", lstrecords.length);
                    cmp.set('v.mydata', lstrecords);
                    cmp.set('v.allData', lstrecords);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                recid: recid,
                pageSize: pageSize,
                pageNumber: pageNumber,
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },

    sortData: function (component, event, helper) {
        //RE_Release 1.1 – 365008:Sorting issue on My Clients Screen
        if ((component.get('v.sObject') === 'Contact' ||
             component.get('v.sObject') === 'Favorite__c')
             && component.get('v.sortBy') === 'Phone') {
            helper.sortDataOnFields(component);
        } else {
            helper.getData(component, event, helper, '1', true);
        }

    },
    showToast: function (component, variant, msg) {
        if (variant === 'Error') {
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },
    formatPhoneNumber: function (component, phone) {
        var s2 = ("" + phone).replace(/\D/g, '');
        var m = s2.match(/^(\d{3})(\d{3})(\d{4})$/);
        return (!m) ? phone : "(" + m[1] + ") " + m[2] + "-" + m[3];
    },
    getLoggedInUserRole: function (component, event, helper) {
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);
            // var emptyObj = null;
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getUserRole', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    //var data = response();
                    var bIsAdmin = response.objectData.isAdmin;
                    var bIsAssister = response.objectData.isAssister;
                    var isCPUser = response.objectData.isCPUser;
                    component.set("v.isCPUser", isCPUser);
                    component.set("v.isAssister", bIsAssister);
                    var bIsAgencyUser = response.objectData.isAgencyUser;
                    component.set("v.isAgencyUser", bIsAgencyUser);
                    var url = component.get("v.getURL");
                    if (!(bIsAdmin || bIsAgencyUser) && url.includes("our-team")) {
                        helper.displayErrorPage();
                    } else {
                        component.set('v.mydata', null);
                        component.set('v.pageNumber', 1);
                        component.set('v.mycolumns', component.get("v.mycolumns"));
                        var obj = component.get('v.sObject');
                        if (obj === 'ContentNote') {
                            helper.getNotes(component);
                        } else {
                            helper.getColumns(component);
                            if (bIsAssister) {
                                if (!(component.get('v.sObject') === 'Contact' && component.get('v.allClientsCheck') === true))//Kojashree : 20Dec LV fix
                                {
                                    helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
                                } else {
                                    component.set("v.citizenCheck", "true");
                                    component.set("v.isLastPage", "true");
                                }
                            } // Kojashree: permformance optimization changes Bug 343023 start
                            else if (component.get('v.sObject') === 'Contact' && url.includes("our-team") === false) {
                                if (component.get('v.allClientsCheck') === false) {
                                    helper.getData(component, event, helper, component.get("v.pageNumber").toString(), false);
                                } else {
                                    component.set("v.citizenCheck", "true");
                                    component.set("v.isLastPage", "true");
                                }
                            } else {
                                helper.fetchPicklistValues(component, event, helper);
                                helper.getLocationfilter(component, event, helper);
                            }// Kojashree: permformance optimization changes Bug 343023 end
                            // helper.getLocationfilter(component); Moved helper from helper to controller
                        }
                    }
                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }


            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

    },
    createColumnData: function (component) {
        var agencyColumnData = [];
        agencyColumnData.push({ label: $A.get("$Label.c.RE_IndividualID"), value: 'Individual ID', type: 'boolean', sortable: true },
            { label: $A.get("$Label.c.RE_CaseNumber"), value: 'Case Number', type: 'boolean', sortable: true },
            { label: $A.get("$Label.c.SSN"), value: 'SSN', type: 'boolean', sortable: true },
            { label: $A.get("$Label.c.RE_NameDOB"), value: 'Name/DOB', type: 'boolean', sortable: true })
        component.set("v.agencySearchOptions", agencyColumnData);
    },
    createContactAndOpenOneView: function (component, event, rowObj) {
        try {
            var bSuper = component.find("bSuper");
            component.set('v.isSpinnerActive', true);
            bSuper.callServer(component, 'c.createContactForIEESData', function (response) {
                component.set('v.isSpinnerActive', false);
                //hide spinner when server response received
                if (response.isSuccessful) {
                    var clientId = response.objectData.clientId
                    rowObj.Id = clientId;
                    var cmpEvent = component.getEvent("OurClientsStopInitEvent");
                    cmpEvent.setParams({
                        "ClientId": clientId,
                        "StopParentInit": false,
                        "showdetail": true,
                        "clientData": rowObj
                    });
                    cmpEvent.fire();
                    location.hash = "clientId=" + clientId;
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            }, {
                "IEESData": JSON.stringify(rowObj)
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createContactAndOpenReferral: function (component,event,rowObj) {
        try {
            var bSuper = component.find("bSuper");
            component.set('v.isSpinnerActive', true);
            //override the method in super class and write your own logic with the response received
            console.log('checkDataForContact === > before callserver ');
            bSuper.callServer(component, 'c.createContactForIEESData', function (response) {
                component.set('v.isSpinnerActive', false);
                //hide spinner when server response received
                if (response.isSuccessful) {
                    var clientId = response.objectData.clientId
                    rowObj.Id=clientId;
                   
                    var cmpEvt = component.getEvent("OurClientsStopInitEvent");
                        cmpEvt.setParams({
                            "ClientId" : clientId,
                            "StopParentInit" : false,
                            "showdetail": false,
                            "clientName": rowObj.FirstName +' '+ rowObj.LastName,
                            "clientData":rowObj
                        });  
                        cmpEvt.fire();
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            }, {
                "IEESData": JSON.stringify(rowObj)
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    displayErrorPage: function () {
        /*var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": $A.get("$Label.c.errorpage")
        });
        urlEvent.fire();*/
        window.open($A.get("$Label.c.errorpage"), '_self');
    },
    checkFutureDateHelper: function (component) {
        var bSuper = component.find("bSuper");
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        // if date is less then 10, then append 0 before date   
        if (dd < 10) {
            dd = '0' + dd;
        }
        // if month is less then 10, then append 0 before date    
        if (mm < 10) {
            mm = '0' + mm;
        }

        var todayFormattedDate = yyyy + '-' + mm + '-' + dd;
        if (component.get("v.dob") > todayFormattedDate) {
            var errMsg = $A.get("$Label.c.DOBFutureDateError");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            //component.set("v.dob",null);
            component.set("v.checkFutureDate", true);
        }
        else {
            component.set("v.checkFutureDate", false);
        }
    },
    calculateAge: function (component) {
        var today = new Date();
        var birthDate = new Date(component.get("v.dob"));
        var age = today.getFullYear() - birthDate.getFullYear();
        var m = today.getMonth() - birthDate.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
            age = age - 1;
        }
        return age;
    },
    sortDataOnFields: function (component) {
        var sortBy = component.get("v.sortBy");
        var sortDirection = component.get("v.sortDirection");
        var data = component.get("v.mydata");
        var key = function (aVar2) { return aVar2[sortBy]; }
        var reverse = sortDirection === 'asc' ? 1 : -1;

        data.sort(function (aVar2, bVar2) {
            var aVar = aVar2;
            var bVar = bVar2;
            aVar = key(aVar) ? key(aVar).toLowerCase() : '';
            bVar = key(bVar) ? key(bVar).toLowerCase() : '';
            return reverse * ((aVar > bVar) - (bVar > aVar));
        });

        component.set("v.mydata", data);
    },
    checkUserAssociateWithContact: function (cmp, event, contactId) {
        try {
            var bSuper = cmp.find("bSuper");
            bSuper.callServer(cmp, 'c.checkUserForContact', function (response) {
                if (response.isSuccessful) {
                    if (response.objectData.isActive===false) {
                        $A.createComponent(
                            "c:RE_OurTeamEditModal", { "recId": contactId },
                            function (newcomponent) {
                                if (cmp.isValid()) {
                                    var body = cmp.get("v.body");
                                    body.push(newcomponent);
                                    cmp.set("v.body", body);
                                }
                            }
                        );
                    }else if (response.objectData.user === 0) {
                        var errMsg1 = $A.get("$Label.c.RE_NoUserForContact");
                        bSuper.showToast($A.get("$Label.c.RE_WarningStatus"), 'Warning', errMsg1);
                    }
                    else {
                        $A.createComponent(
                            "c:RE_OurTeamEditModal", { "recId": contactId },
                            function (newcomponent) {
                                if (cmp.isValid()) {
                                    var body = cmp.get("v.body");
                                    body.push(newcomponent);
                                    cmp.set("v.body", body);
                                }
                            }
                        );

                    }
                }
            }, { strContactId: contactId }, false);
        }
        catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    agencySearchActionHelper:  function(component, event, helper) 
    {
        component.set('v.pageNumber',1);
        component.set("v.searchCheck", true);
        var searchCheckCtrl = component.get("v.searchCheck");
        var errMsg;
        var entry_not_match = $A.get('$Label.c.entry_not_match');
        if(searchCheckCtrl === true)
        {
            var userInputIndividualID = component.get("v.individualID");
            var userInputCaseNumber = component.get("v.caseNumber");
            var userInputSSN = component.get("v.ssn");
            // Do we need any pattern for individualID, caseNumber
            //var ssn_regex = /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/;
            var ssn_regex = /^[0-9]{9}$/;
            var individualID_regex = /^[0-9]*$/;
            var caseNumber_regex = /^[0-9]*$/;
            var bSuper = component.find("bSuper");
            
            if(component.get('v.allClientsCheck')===false && 
               ((component.get('v.individualIDCheck')===true && ($A.util.isUndefinedOrNull(userInputIndividualID) || userInputIndividualID === ""))
                || (component.get('v.caseNumberCheck')===true && ($A.util.isUndefinedOrNull(userInputCaseNumber) || userInputCaseNumber === ""))
                || (component.get('v.ssnCheck')===true && ($A.util.isUndefinedOrNull(userInputSSN) || userInputSSN === ""))
                ))
            {
                errMsg = $A.get("$Label.c.AllClientSearchValidation");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            }
            else if(component.get('v.allClientsCheck')===true && 
                    ((component.get('v.individualIDCheck')===true && ($A.util.isUndefinedOrNull(userInputIndividualID) || $A.util.isEmpty(userInputIndividualID.trim())))
                     || (component.get('v.caseNumberCheck')===true && ($A.util.isUndefinedOrNull(userInputCaseNumber) || $A.util.isEmpty(userInputCaseNumber.trim())))
                     || (component.get('v.ssnCheck')===true && ($A.util.isUndefinedOrNull(userInputSSN) || $A.util.isEmpty(userInputSSN.trim())))
                     ))
            {
                errMsg = $A.get("$Label.c.AllClientSearchValidation");
                bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
            }
            else
            {
                // check for regex
                if((component.get('v.individualIDCheck')===true && !$A.util.isUndefinedOrNull(userInputIndividualID) && !individualID_regex.test(userInputIndividualID) && userInputIndividualID !== "")
                    || (component.get('v.caseNumberCheck')===true && !$A.util.isUndefinedOrNull(userInputCaseNumber) && !caseNumber_regex.test(userInputCaseNumber) && userInputCaseNumber !== "")
                    || (component.get('v.ssnCheck')===true && !$A.util.isUndefinedOrNull(userInputSSN) && !ssn_regex.test(userInputSSN) && userInputSSN !== "")
                ){
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), entry_not_match); 
                }
                else
                {
                    component.set('v.mydata',null);
                    this.getData(component, event, helper,component.get("v.pageNumber").toString(),false);
                }
            }
        }
        return true;
    },
    checkInvalidDate: function (component) {
        var date = component.get("v.dob");
        //var reg = /[\d - \/]+/g;
        var reg = /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[0-1])$/;
        return reg.test(date);
    },
    bSuper: {}
})