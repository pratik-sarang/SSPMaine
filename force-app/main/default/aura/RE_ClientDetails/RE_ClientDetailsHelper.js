({
    getParam: function (component) {
        var recid = this.getURLParam().referralid;
        if (!$A.util.isUndefinedOrNull(recid) && recid !== '') {
            component.set("v.bshowback", false);
            component.set("v.clientId", atob(recid));
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
    doInitHandler: function (component, event, helper) {

        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);
            var showAssesmentReponse = component.get("v.bisAssesmentOpen");
            if (!$A.util.isUndefinedOrNull(showAssesmentReponse) && showAssesmentReponse === true) {
                component.set('v.showClientDetail', false);
            } else {
                component.set("v.showClientDetail", true);
            }

            this.createColumnData(component);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.fetchClientDetails', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                component.set("v.isLoading", false);

                //to do
                if (response.isSuccessful) {
                    if(response.objectData.bIsAgencyUser)
                    {
                        component.set("v.hasConsentToView",response.objectData.hasConsentToView);
                        component.set("v.hasActiveConsent",response.objectData.hasActiveConsent);
                        component.set("v.isIEESClient", false);
                    }
                    var clientDetails = response.objectData.details;
                    if (!$A.util.isUndefinedOrNull(showAssesmentReponse) && showAssesmentReponse === true) {
                        $A.util.toggleClass(component.find('headingContainer'), 'slds-hide');
                    }
                    var phone = clientDetails.clientPhone;
                    //Added for formatting phone into US format
                    if (phone !== null && phone !== '') {
                        var formatedPhone = helper.formatPhoneNumber(component, phone);
                    }
                    clientDetails.clientPhone = formatedPhone;
                    if (clientDetails.clientAge >= 18) {
                        component.set("v.isAnAdult", true);

                    } else if (!$A.util.isUndefinedOrNull(clientDetails.clientAge) && clientDetails.clientAge < 18) {
                        component.set("v.hasConsentToView", false);
                    }
                    if (clientDetails.DOB) {
                        clientDetails.DOB = $A.localizationService.formatDate(clientDetails.DOB, "MM/dd/yyyy");
                    }
                    if (clientDetails.isFavorite) {
                        component.set("v.bShowMyClients", false);
                    }
                    component.set("v.clientDetails", clientDetails);
                    if ($A.util.isUndefinedOrNull(clientDetails)) {
                        helper.navigateToURL(component, 'clients');
                        component.set("v.showClientDetail", false);
                        var errMsg = $A.get("$Label.c.GeneralError");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                    component.set("v.clientUniqueId", (response.objectData.clientUniqueId === "" ? '' : response.objectData.clientUniqueId));
                    //Parse Address
                    helper.setAddress(component, event, clientDetails, response.objectData.IEESAddress);
                    //Sort and slice notes
                    var notesList = JSON.parse(clientDetails.notesList);
                    notesList = helper.sortData(component, 'CreatedDate', 'desc', notesList);
                    component.set("v.mydatanotes", notesList.slice(0, 4));
                    component.set("v.fulldatanotes", notesList);
                    //Sort and slice Household composition and enrolled programs
                    var arrEnrollPrograms = JSON.parse(response.objectData.EnrollPrgs);
                    var arrHHComp = JSON.parse(response.objectData.HHComp);
                    component.set("v.lstEnrollProgWrapperLimited", arrEnrollPrograms.slice(0, 4));
                    component.set("v.lstHHCompWrapperLimited", arrHHComp.slice(0, 4));
                    component.set("v.lstEnrollProgWrapper", arrEnrollPrograms);
                    component.set("v.lstHHCompWrapper", arrHHComp);

                    //RiskFactors Data
                    component.set("v.riskScoreSetting", response.objectData.riskScoresSetting);
                    component.set("v.lstSDOHCatPicklistValues", response.objectData.listSDOHCategoryValues);
                    helper.getAssessmentResponse(component, event);
                    helper.sortRiskFactors(component, response.objectData.riskFactors, response.objectData.riskScoresSetting, helper);

                    //enable Send Email button
                    var optOutComm = response.objectData.optOutComm;
                    component.set("v.sendEmailWrapper.clientEmail", response.objectData.clientContactEmail);
                    component.set("v.sendEmailWrapper.clientName", response.objectData.clientName);
                    component.set("v.sendEmailWrapper.clientId", response.objectData.ClientId);
                    if (optOutComm === true) {
                        component.set("v.bOptOutComm", false);
                    }
                    else {
                        component.set("v.bOptOutComm", true);
                    }
                } else {
                    component.set("v.showClientDetail", false);
                    component.set('v.bShowClientTable', true);
                    var errorMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errorMsg);
                }

            }, {
                strClientId: component.get("v.clientId")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    createColumnData: function (component) {
        var householdColumnData = [];
        householdColumnData.push({ label: $A.get("$Label.c.RE_Client"), fieldName: 'ClientName', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_Age"), fieldName: 'Age', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_Relationship"), fieldName: 'Relationship', type: 'text', sortable: true })
        component.set("v.mycolumnsHousehold", householdColumnData);
        var enrolledProgramColumnData = [];
        enrolledProgramColumnData.push({ label: $A.get("$Label.c.RE_Program"), fieldName: 'ProgramFullName', type: 'text', sortable: true },
            { label: $A.get("$Label.c.start"), fieldName: 'StartDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } },
            { label: $A.get("$Label.c.RE_Renewal"), fieldName: 'RenewalDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } })
        component.set("v.mycolumnsEnrolledProgram", enrolledProgramColumnData);
        var notesColumnData = [];
        notesColumnData.push({ label: $A.get("$Label.c.Subject"), fieldName: 'Title', type: 'text', sortable: true },
            { label: $A.get("$Label.c.Created_Date"), fieldName: 'CreatedDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } },
            { label: $A.get("$Label.c.Created_By"), fieldName: 'CreatedBy', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_View"), type: 'action', typeAttributes: { rowActions: [{ label: $A.get("$Label.c.RE_View"), name: 'view' }] } })
        component.set("v.mycolumnsNotes", notesColumnData);
        var fullNotesColumnData = [];
        fullNotesColumnData.push({ label: $A.get("$Label.c.Subject"), fieldName: 'Title', type: 'text', sortable: true },
            { label: $A.get("$Label.c.Created_Date"), fieldName: 'CreatedDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } },
            { label: $A.get("$Label.c.Created_By"), fieldName: 'CreatedBy', type: 'text', sortable: true },
            { label: $A.get("$Label.c.Last_modified_date"), fieldName: 'ModifiedDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } },
            { label: $A.get("$Label.c.Last_modified_by"), fieldName: 'ModifiedBy', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_View"), type: 'action', typeAttributes: { rowActions: [{ label: $A.get("$Label.c.RE_View"), name: 'view' }] } })
        component.set("v.fullcolumnsNotes", fullNotesColumnData);
        var assessmentColumnData = [];
        assessmentColumnData.push({ label: $A.get("$Label.c.date"), fieldName: 'assessmentSubmitDate', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } },
            { label: $A.get("$Label.c.name"), fieldName: 'assessmentTitle', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_TakenBy"), fieldName: 'assessmentTakenBy', type: 'text', sortable: true },
            { label: $A.get("$Label.c.RE_View"), type: 'action', typeAttributes: { rowActions: [{ label: $A.get("$Label.c.RE_View"), name: 'view' }] } })
        component.set("v.mycolumnsAssessment", assessmentColumnData);
        var riskFactorsColumnData = [];
        //class attribute added for view all page color
        riskFactorsColumnData.push({ label: $A.get("$Label.c.RE_SDOHTitle"), fieldName: 'Category__c', type: 'text',sortable : true,cellAttributes:{"class": {"fieldName": "riskClass"},iconName: { fieldName: 'riskIconName' }, iconPosition: 'left',iconAlternativeText:{fieldName: 'riskIconLabel'} }},
            { label: $A.get("$Label.c.RE_AssessedOn"), fieldName: 'AssessmentDate__c', type: 'date-local', sortable: true, typeAttributes: { day: 'numeric', month: 'numeric', year: 'numeric' } })
        component.set("v.riskFactorsColumns", riskFactorsColumnData);
    },
    saveNote: function (component, event, helper) {

        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            component.set("v.showClientDetail", true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.createNote', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                component.set("v.isLoading", false);

                //to do
                var noteButton = component.find('submitNote');
                noteButton.set("v.disabled", false);
                if (response.isSuccessful) {
                    component.set("v.showNotesModal", false);
                    component.set("v.noteSubject", '');
                    component.set("v.noteDescription", '');
                    var successMsg = $A.get("$Label.c.notessuccessmessage");
                    helper.refreshNotesList(component, event, helper);
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);

                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                strNoteTitle: component.get("v.noteSubject"),
                strNoteDescription: component.get("v.noteDescription"),
                strClientId: component.get("v.clientId")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    sortData: function (component, fieldName, sortDirection, data) {
        //Sort Data for datatable
        var key = function (a) { return a[fieldName]; }
        var reverse = sortDirection === 'asc' ? 1 : -1;

        data.sort(function (a, b) {
            var a1 = key(a) ? key(a).toLowerCase() : '';
            var b1 = key(b) ? key(b).toLowerCase() : '';
            return reverse * ((a1 > b1) - (b1 > a1));
        });
        return data;
    },
    setAddress: function (component, event, clientDetails, alternateAddress) {
        var address = JSON.parse(clientDetails.clientAddress);
        if (!$A.util.isUndefinedOrNull(address)) {
            if (!$A.util.isUndefinedOrNull(address.street)) {
                component.set("v.Address.AddressLine1", address.street);
            }
            if (!$A.util.isUndefinedOrNull(address.city)
                && !$A.util.isUndefinedOrNull(address.state)) {
                component.set("v.Address.AddressLine2", address.city + ', ' + address.state + ' ' + address.postalCode);
            } else if (!$A.util.isUndefinedOrNull(address.city)) {
                component.set("v.Address.AddressLine2", address.city + ', ' + address.postalCode);
            } else if (!$A.util.isUndefinedOrNull(address.state)) {
                component.set("v.Address.AddressLine2", address.state + ', ' + address.postalCode);
            } else {
                component.set("v.Address.AddressLine2", address.postalCode);
            }
            if (!$A.util.isUndefinedOrNull(address.country)) {
                component.set("v.Address.AddressLine3", address.country);
            }

        } else {
            component.set("v.Address.AddressLine1", alternateAddress.AddressLine1);
            component.set("v.Address.AddressLine2", alternateAddress.AddressLine2);
            component.set("v.Address.AddressLine3", alternateAddress.AddressLine3);
        }

    },
    checkConsent: function (component) {
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.checkConsent', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                component.set("v.isLoading", false);

                //to do
                if (response.isSuccessful) {
                    if (!$A.util.isUndefinedOrNull(response.objectData.hasConsentToView)) {
                        component.set("v.hasConsentToView", response.objectData.hasConsentToView);
                    }
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                strClientId: component.get("v.clientId")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    refreshNotesList: function (component, event, helper) {

        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.refreshNotes', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                component.set("v.isLoading", false);

                //to do
                if (response.isSuccessful) {
                    var notesList = JSON.parse(response.objectData.records);
                    notesList = helper.sortData(component, 'CreatedDate', 'desc', notesList);
                    component.set("v.mydatanotes", notesList.slice(0, 4));
                    component.set("v.fulldatanotes", notesList);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                strClientId: component.get("v.clientId")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    navigateToURL: function (cmp, url) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/' + url
        });
        urlEvent.fire();
    },
    /* checks email validity */
    checkEmailValidity: function (component) {
        var pattern = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
        var inputField = component.find('clientEmail');
        var value = inputField.get('v.value');
        if (!pattern.test(value)) {
            inputField.set('v.validity', { valid: false, badInput: true });
            inputField.showHelpMessageIfInvalid();
            return false;
        }
        else
            return true;
    },
    /*validates email and message field of send email modal */
    validateInputs: function (component, event, helper) {
        var isEmailValid = helper.checkEmailValidity(component);
        var isMsgValid = true;
        var inputMsg = component.get("v.sendEmailWrapper.message");
        inputMsg = inputMsg.trim();
        if ($A.util.isUndefinedOrNull(inputMsg) || inputMsg.length === 0) {
            this.showToast(component, event, $A.get("$Label.c.RE_MessageRequired"));
            isMsgValid = false;
        }
        if (isEmailValid === false) {
            this.showToast(component, event, $A.get("$Label.c.RE_EmailError"));
        }
        if (isEmailValid && isMsgValid) {
            if (!component.get("v.isIEESClient")) {
                helper.sendEmail(component);
            } else {
                component.set("v.clientWrapper", component.get("v.clientDetails"));
                var BirthDate = $A.localizationService.formatDate(component.get("v.clientWrapper.BirthDate"), "yyyy-MM-dd");
                component.set("v.clientWrapper.BirthDate", BirthDate);
                try {
                    var bSuper = component.find("bSuper");
                    component.set('v.isSpinnerActive', true);
                    //override the method in super class and write your own logic with the response received
                    bSuper.callServer(component, 'c.createContactForIEESData', function (response) {
                        component.set('v.isSpinnerActive', false);
                        //hide spinner when server response received
                        if (response.isSuccessful) {
                            var clientId = response.objectData.clientId;
                            component.set("v.clientId", clientId);
                            component.set("v.sendEmailWrapper.clientName", component.get("v.clientDetails.FirstName") + ' ' + component.get("v.clientDetails.LastName"));
                            component.set("v.sendEmailWrapper.clientId", clientId);
                            helper.sendEmail(component);
                            component.set("v.isIEESClient", false);
                            helper.doInitHandler(component, event, helper);
                        } else {
                            var errMsg = $A.get("$Label.c.servererror");
                            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                        }
                    }, {
                        "IEESData": JSON.stringify(component.get("v.clientWrapper"))
                    }, false);
                } catch (e) {
                    bSuper.consoleLog(e.stack, true);
                }

            }

        }
    },
    formatPhoneNumber: function (component, phoneNumber) {
        var phone = ("" + phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (!formatedPhone) {
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    /*shows error message as toast when fields are not validated */
    showToast: function (component, event, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            type: $A.get("$Label.c.errorstatus"),
            duration: '5000'
        });
        toastEvent.fire();
    },
    sortRiskFactors: function (component, riskFactors, allSDOHPicklistValues, helper) {
        var listRed = [];
        var listYellow = [];
        var listGreen = [];
        var listGrey = [];
        var listRiskFactors = [];

        //component.set("v.riskFactorsColumns",tableColumns);
        var settingsList = component.get("v.riskScoreSetting");
        // Check is there any assessent available for particular client
        //var lstAssessmentResponse=component.get("v.lstAssessmentResponseLimited");
        var lstSDOHCatPicklistValues = component.get("v.lstSDOHCatPicklistValues");

        var listSdohCatObj = [];
        var listSelectedSDOHCat = [];
        if (riskFactors.length === 0) {
            for (var j = 0; j < lstSDOHCatPicklistValues.length; j += 1) {
                var sdohCatObj = { "Category__c": "", "riskClass": "", "riskIconName": "" };
                sdohCatObj.Category__c = lstSDOHCatPicklistValues[j];
                sdohCatObj.riskClass = "color-na";
                sdohCatObj.riskIconName = 'utility:record'
                listSdohCatObj.push(sdohCatObj);
            }
            listSdohCatObj = helper.sortRisk('Category__c', listSdohCatObj);
            component.set("v.lstFullSDOH", listSdohCatObj);
            component.set("v.lstSDOH", listSdohCatObj.slice(0, 10));
        }
        else {
            for (var i = 0; i < riskFactors.length; i += 1) {
                riskFactors[i].riskIconName = 'utility:record';
                for (var t = 0; t < settingsList.length; t += 1) {
                    if (Math.round(riskFactors[i].Score__c) === Number(settingsList[t].Name)) {
                        riskFactors[i].riskClass = 'color' + settingsList[t].ScoreColor__c;
                    }
                }
                var index = lstSDOHCatPicklistValues.indexOf(riskFactors[i].Category__c);
                if (index > -1) {
                    lstSDOHCatPicklistValues.splice(index, 1);
                }
                if (!$A.util.isUndefinedOrNull(riskFactors[i].Category__c)) {
                    var sdohCatObject = { "Category__c": "", "riskClass": "", "riskIconName": "", "AssessmentDate__c": "" };
                    sdohCatObject.Category__c = riskFactors[i].Category__c;
                    sdohCatObject.riskClass = riskFactors[i].riskClass;
                    sdohCatObject.riskIconName = 'utility:record';
                    sdohCatObject.AssessmentDate__c = riskFactors[i].AssessmentDate__c;
                    listSelectedSDOHCat.push(sdohCatObject);
                }
            }
            for (var k = 0; k < lstSDOHCatPicklistValues.length; k += 1) {
                var sdohCategoryObj = { "Category__c": "", "riskClass": "", "riskIconName": "", "AssessmentDate__c": "" };
                sdohCategoryObj.Category__c = lstSDOHCatPicklistValues[k];
                sdohCategoryObj.riskClass = 'colorGrey';
                sdohCategoryObj.riskIconName = 'utility:record';
                listSelectedSDOHCat.push(sdohCategoryObj);
            }
            for (var y = 0; y < listSelectedSDOHCat.length; y += 1) {
                if (listSelectedSDOHCat[y].riskClass === 'colorRed') {
                    listRed.push(listSelectedSDOHCat[y]);
                } else if (listSelectedSDOHCat[y].riskClass === 'colorYellow') {
                    listYellow.push(listSelectedSDOHCat[y]);
                } else if (listSelectedSDOHCat[y].riskClass === 'colorGreen') {
                    listGreen.push(listSelectedSDOHCat[y]);
                } else {
                    listSelectedSDOHCat[y].riskClass = 'colorGrey';
                    listGrey.push(listSelectedSDOHCat[y]);
                }

            }
            listRed = helper.sortRisk('Category__c', listRed);
            listYellow = helper.sortRisk('Category__c', listYellow);
            listGreen = helper.sortRisk('Category__c', listGreen);
            listGrey = helper.sortRisk('Category__c', listGrey);
            listRiskFactors = listRiskFactors.concat(listRed);
            listRiskFactors = listRiskFactors.concat(listYellow);
            listRiskFactors = listRiskFactors.concat(listGreen);
            listRiskFactors = listRiskFactors.concat(listGrey);
            component.set("v.lstFullSDOH", listRiskFactors);
            component.set("v.lstSDOH", listRiskFactors.slice(0, 10));
        }

    },
    getAssessmentRecords: function (component) {
        try {
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.fetchAssessmentRecords', function (response) {
                if (response.isSuccessful) {
                    var objectData = response.objectData.assessmentRecords;
                    component.set("v.lstAssessment", objectData);
                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            });
        }
        catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getAssessmentResponse: function (component) {
        try {
            var clientId = component.get("v.clientDetails").clientId;

            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.fetchAssessmentResponses', function (response) {
                if (response.isSuccessful) {
                    var objectData = response.objectData.assessmentResponseRecords;
                    component.set("v.lstAssessmentResponse", objectData);
                    component.set("v.lstAssessmentResponseLimited", objectData.splice(0, 4));
                    objectData = component.get("v.lstAssessmentResponse");
                    var hasConsent= component.get("v.hasConsentToView");
                    if(objectData.length===0 && hasConsent===true){
                        bSuper.showToast($A.get("$Label.c.RE_Info"), 'Info', $A.get("$Label.c.Firstassmntdue"));
                    } else if (objectData.length > 0) {


                        var createdd = new Date(objectData[0].assessmentSubmitDate).getTime();

                        var prevday = new Date(new Date().setFullYear(new Date().getFullYear() - 1));
                        var prevnowd = prevday.getTime();
                        var diff = Math.ceil((createdd - prevnowd) / (24 * 1000 * 3600));

                        if (diff < 0 && hasConsent===true) {
                            bSuper.showToast($A.get("$Label.c.RE_Info"), 'Info', $A.get("$Label.c.firstassmntyearago"));
                        }



                    }
                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
            }, {
                "strResidentId": clientId
            }, false);
        }
        catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    startAssessementHelper: function (component) {

        var BirthDate;
        var clientId;



        if (!component.get("v.isIEESClient")) {
            clientId = window.btoa(component.get("v.clientId"));

        } else {
            BirthDate = $A.localizationService.formatDate(component.get("v.clientWrapper.BirthDate"), "yyyy-MM-dd");
            component.set("v.clientWrapper.BirthDate", BirthDate);
            try {
                var bSuper = component.find("bSuper");
                component.set('v.isSpinnerActive', true);
                //override the method in super class and write your own logic with the response received
                bSuper.callServer(component, 'c.createContactForIEESData', function (response) {
                    component.set('v.isSpinnerActive', false);
                    //hide spinner when server response received
                    if (response.isSuccessful) {
                        clientId = response.objectData.clientId;
                        component.set("v.clientId", clientId);
                    } else {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                }, {
                    "IEESData": JSON.stringify(component.get("v.clientWrapper"))
                }, false);
            } catch (e) {
                bSuper.consoleLog(e.stack, true);
            }

        }
    },
    sortRisk: function (fieldName, sortList) {
        var data = sortList;
        var key = function (aVar2) { return aVar2[fieldName]; }
        var reverse = 1;

        data.sort(function (aVar2, bVar2) {
            var aVar = aVar2;
            var bVar = bVar2;
            aVar = key(aVar) ? key(aVar).toLowerCase() : '';
            bVar = key(bVar) ? key(bVar).toLowerCase() : '';
            return reverse * ((aVar > bVar) - (bVar > aVar));
        });

        return data;
    },
    calculateAge: function (component, birthDate) {
        var today = new Date();
        var birthDateValue = new Date(birthDate);
        var age = today.getFullYear() - birthDateValue.getFullYear();
        var m = today.getMonth() - birthDateValue.getMonth();
        if (m < 0 || (m === 0 && today.getDate() < birthDateValue.getDate())) {
            age = age - 1;
        }
        return age;
    },
    sendEmail: function (component) {

        var inputWrapper = component.get("v.sendEmailWrapper");
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.sendEmail', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    var successMsg = $A.get("$Label.c.RE_SendConsentEmailSuccessToast");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                    component.set("v.sendEmailWrapper.message", '');
                    component.set("v.showEmailResidentModal", false);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                "sendEmailWrapper": inputWrapper
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getSDOHPicklistValues: function (component, helper) {
        try {
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getSDOHValues', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    component.set("v.lstSDOHCatPicklistValues", response.objectData.listSDOHCategoryValues);
                    helper.sortRiskFactors(component, [], response.objectData.listSDOHCategoryValues, helper);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {}, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    //Nandita: 03/26/2020: new function to add client to Favorite : 357475
    addToMyClientsHelper: function (component) {
        var clientId = component.get("v.clientId");
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.createClientFavourite', function (response) {
                component.set('v.isSpinnerActive', false);
                if (response.isSuccessful) {
                    component.set("v.bShowMyClients", false);
                    var successMsg = $A.get("$Label.c.RE_Create_Favorite_Client_Message");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                "clientId": clientId
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    removeFromMyClientsHelper: function (component) {
        var clientId = component.get("v.clientId");
        try {
            component.set('v.isSpinnerActive', true);
            var bSuper = component.find("bSuper");
            bSuper.callServer(component, 'c.removeFavoriteClient', function (response) {
                component.set('v.isSpinnerActive', false);
                if (response.isSuccessful) {
                    component.set("v.bShowMyClients", true);
                    var successMsg = $A.get("$Label.c.RE_Remove_Favorite_Client_Message");
                    bSuper.showToast($A.get("$Label.c.successstatus"), "success", successMsg);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                "clientId": clientId
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    }
})