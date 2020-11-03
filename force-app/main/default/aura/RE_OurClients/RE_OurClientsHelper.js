({
    doInitHandler: function (component) {
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var string;
            //override the method in super class and write your own logic with the response received
            //this.createColumnData(component);
            bSuper.callServer(component, 'c.getContactMetadata', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do

                if (response.isSuccessful) {
                    component.set("v.lstcolumns", response.objectData.mycolumns);
                    component.set("v.bIsAgencyUser", response.objectData.bIsAgencyUser);
                    var columns = component.get("v.lstcolumns");
                    var columnNamesAllClients = [];
                    var columnNamesMyClients = [];
                    for (var i = 0; i < columns.length; i += 1) {
                        string = JSON.parse(columns[i]);
                        string.label = $A.get("$Label.c." + string.label);
                        columnNamesAllClients.push(string);
                        columnNamesMyClients.push(string);
                    }
                    // Venkat: 03/04/2020: Spanish Translation
                    var actionListAllClients=[];
                    if(component.get("v.bIsAgencyUser") === true)
                    {
                        actionListAllClients.push({ label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'View'},
                                                    {label:$A.get("$Label.c.createreferral") , name:'Create'}
                                                                        ]}})
                    }else{
                        actionListAllClients.push({ label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'View'}, 
                                                {label:$A.get("$Label.c.createreferral") , name:'Create'}, 
                                                {label:$A.get("$Label.c.Request_Consent") , name:'Request'}
                                                                        ]}})
                    }
                    component.set("v.actionListAllClients",actionListAllClients);
                    
                    var actionListMyClients=[];
                    actionListMyClients.push({label: $A.get("$Label.c.RE_View"), type:'action', typeAttributes:{rowActions: [{label:$A.get("$Label.c.RE_View") , name:'View'}, 
                                            {label:$A.get("$Label.c.createreferral") , name:'Create'}
                                                                        ]}})
                    component.set("v.actionListMyClients",actionListMyClients);
                    // END
                    var actListAllClients = component.get("v.actionListAllClients");
                    var actListMyClients = component.get("v.actionListMyClients");
                    for (var j = 0; j < actListAllClients.length; j += 1) {
                        columnNamesAllClients.push(actListAllClients[j]);
                    }
                    for (var k = 0; k < actListMyClients.length; k += 1) {
                        columnNamesMyClients.push(actListMyClients[k]);
                    }
                    component.set("v.mycolumnslstAll", columnNamesAllClients);
                    component.set("v.mycolumnslstMy", columnNamesMyClients);
                    component.set("v.onLoadCheck", "true");
                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast('Error', 'Error', errMsg);
                }
            }, null, false);
        }
        catch (e) {
        }
    },
    allClientDetailsEventHelper: function (cmp, event) {
        //Get the event message attribute
        var bStopInit = event.getParam("StopParentInit");
        var clientId = event.getParam("ClientId");
        var showdetail = event.getParam("showdetail");
        var clientName = event.getParam("clientName");
        var clientData = event.getParam("clientData");
        if ($A.util.isUndefinedOrNull(clientId)
            && !$A.util.isUndefinedOrNull(clientData.IEESId)) {
            cmp.set("v.isIEESData", true);
        } else {
            cmp.set("v.isIEESData", false);
        }
        if (clientData && clientData.BirthDate) {
            clientData.BirthDate = $A.localizationService.formatDate(clientData.BirthDate, "MM-dd-yyyy");
        }

        cmp.set("v.clientId", clientId);
        cmp.set("v.clientDetails", clientData);
        cmp.set("v.showdetail", showdetail);
        if (cmp.get("v.showdetail")) {
            cmp.set("v.bStopInit", bStopInit);
            cmp.set("v.clientName", clientName);
        } else {
            if (cmp.get("v.isIEESData") === false) {
                this.checkConsent(cmp, clientId, bStopInit, clientName);
            } else {
                cmp.set("v.showReferralBarredModal", true);
                setTimeout(function(){//JAWS Fix
                    document.getElementsByClassName("modal-lg-heading")[0].focus(); 
                },1000);
            }

        }

    },
    getParam: function (component) {
        var recid = (this.getURLParam().clientId) ? atob(this.getURLParam().clientId) : '';
        var backFromSurvey = this.getURLParam().backfromsurvey;
        if (!$A.util.isUndefinedOrNull(backFromSurvey) && backFromSurvey !== '' && backFromSurvey === 'true') {
            component.set("v.bshowSelectAssesment", true);
        }
        if (!$A.util.isUndefinedOrNull(recid) && recid !== '') {
            component.set("v.clientId", recid);
            component.set("v.showdetail", true);
            component.set("v.bStopInit", false);
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

    checkConsent: function (component, clientId, bStopInit, clientName) {
        try {
            //show spinner when request sent
            component.set('v.isSpinnerActive', true);

            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.checkClientConsent', function (response) {

                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);


                //to do
                if (response.isSuccessful) {
                    if (!$A.util.isUndefinedOrNull(response.objectData.hasConsentToView)) {
                        component.set("v.hasConsentToView", response.objectData.hasConsentToView);
                        if (component.get("v.hasConsentToView")) {
                            component.set("v.bStopInit", bStopInit);
                            component.set("v.clientName", clientName);
                        } else {
                            component.set("v.showReferralBarredModal", true);
                            setTimeout(function(){//JAWS Fix
                                document.getElementsByClassName("modal-lg-heading")[0].focus(); 
                            },1000);
                        }
                    }
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }
                
            },{
                strClientId : clientId
            },false);
        }catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    decryptionMethod:function (component, event, helper) 
    {
        var queryString = window.location.search;
        var encryptedValue;
        var encryptedCaseNumber;
        var encryptedIndividualId;
        var isCaseNumber = false;
        try
        {
            if(queryString.includes("CaseNumber=") === true)
            {
                encryptedCaseNumber = queryString.split("CaseNumber=").pop();
                if(!$A.util.isUndefinedOrNull(encryptedCaseNumber) && !$A.util.isEmpty(encryptedCaseNumber))
                {
                    encryptedValue = encryptedCaseNumber;
                    isCaseNumber = true;
                }
            }
            else if(queryString.includes("IndividualID=") === true)
            {
                encryptedIndividualId = queryString.split("IndividualID=").pop();
                if(!$A.util.isUndefinedOrNull(encryptedIndividualId) && !$A.util.isEmpty(encryptedIndividualId))
                {
                    encryptedValue = encryptedIndividualId;
                }
            }

            if(!$A.util.isUndefinedOrNull(encryptedValue) && !$A.util.isEmpty(encryptedValue))
            {
                var bSuper = component.find("bSuper");
                component.set('v.isSpinnerActive', true);
                bSuper.callServer(component, 'c.getDecryptedString', function (response)
                {
                    component.set('v.isSpinnerActive', false);
                    if(response.isSuccessful)
                    {
                        var decryptedString = response.objectData.decryptedValue;
                        if(!$A.util.isUndefinedOrNull(decryptedString) && !$A.util.isEmpty(decryptedString)) 
                        {
                            if(isCaseNumber === true)
                            {
                                component.set('v.caseNumber', decryptedString);
                            }
                            else{
                                component.set('v.individualID', decryptedString);
                                component.set("v.isLinkFromIEES", true);
                            }
                        }
                    }
                    else
                    {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }
                }, {
                    "cipherText": encryptedValue
                }, false);
            }
        }catch (e)
        {
            bSuper.consoleLog(e.stack, true);
        }
    },
})