({
    fetchData: function (component) {

        try {
            //show spinner when request sent
            //component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getAssessmentQuestions', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {
                    var objectData = response.objectData.records;
                    var parsedvalue = JSON.parse(objectData);
                    component.set("v.questions", parsedvalue);

                    for (var i in parsedvalue) {
                        if (parsedvalue[i].bTextAnswerType) {
                            parsedvalue[i].sResponse = response.objectData.addressrec;
                            component.set("v.bisValueSelected", true);
                            component.set("v.sInitialAddress", response.objectData.addressrec);

                            component.set("v.bIsAnonymous", response.objectData.isanonymous);
                            if (component.get("v.bIsAnonymous")) {
                                component.set("v.bshowData", false);
                            } else {
                                component.set("v.bshowData", true);
                            }

                            break;
                        }

                    }

                    //RE_Release 1.3 – Bug 370239- Payal Dubela(06/10/2020)
                    var encodedQuestion;
                    for (var k in parsedvalue) {
                        if (!$A.util.isUndefinedOrNull(parsedvalue[k].sQuestion)){
                            var encodedQuestion= parsedvalue[k].sQuestion.replace(/\\\'/g,'\'');
                            parsedvalue[k].sQuestion=encodedQuestion;
                            for(var j in parsedvalue[k].lstOptions){
                                parsedvalue[k].lstOptions[j].label=parsedvalue[k].lstOptions[j].label.replace(/\\\'/g,'\'');
                            }
                        }
                    }

                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR', 'ERROR', errMsg);
                }
            }, {
                "strAssessmentId": component.get("v.sAssessmenTemplatetId"),
                "sContactId": component.get("v.sContactId")

            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getParam: function (component) {

        var sAssessmenTemplatetId = (this.getURLParam().Id) ? atob(this.getURLParam().Id) : '';
        var sContactId = (this.getURLParam().user) ? atob(this.getURLParam().user) : '';
        var sTempName = (this.getURLParam().tempName) ? atob(this.getURLParam().tempName) : '';
        var cName = (this.getURLParam().cName) ? atob(this.getURLParam().cName) : '';
        component.set('v.sContactId', sContactId);
        component.set('v.sTempName', sTempName);
        component.set('v.cName', cName);

        component.set('v.sAssessmenTemplatetId', sAssessmenTemplatetId);




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
    submitAssessment: function (component, event, helper) {
        try {
            var objWrapper = component.get("v.questions");
            var sendData = JSON.stringify(component.get("v.questions"));




            var objMap = {};
            objMap.data = objWrapper;
            //show spinner when request sent
            //component.set('v.isSpinnerActive',true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.createAssessment', function (response) {
                //hide spinner when server response received
                component.set('v.isSpinnerActive', false);
                //to do
                if (response.isSuccessful) {




                    var objectData = response.objectData.records;
                    var parsedData = JSON.parse(objectData);
                    //set the name here
                    component.set("v.sAssessmentId", parsedData);

                    helper.navigateToAssessmentResult(component);


                }
                else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast('ERROR', 'ERROR', errMsg);
                }
            }, {
                "strmyString": sendData,
                "strContactId": (component.get("v.bisResident") === true && component.get("v.sContactId") == '') ? "undefined" : component.get("v.sContactId"),
                "strAssessmentTemplateId": component.get("v.sAssessmenTemplatetId"),
                "strTempName": component.get("v.sTempName"),
                "strEmail": component.get("v.sEmail")

            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    showToast: function (component, event, variant, msg) {
        if (variant === 'Success') {
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.successstatus"),
                "message": msg,
                "variant": "success"
            });
        } else if (variant === 'Error') {
            component.find('notifLib').showToast({
                "title": $A.get("$Label.c.errorstatus"),
                "message": msg,
                "variant": "error"
            });
        }
    },


    navigateToAssessmentResult: function (component) {
        var userAssessmentId = btoa(component.get('v.sAssessmentId'));
        if (component.get("v.bIsAnonymous") === true) {
            //Nandita:05/05/2020: updated logic as a part of defect# 360169
            component.set("v.bIsAnonymousSubmit", true);
            var bSuper = component.find("bSuper");
            var assessmentId = btoa(component.get('v.sAssessmenTemplatetId'));
            var templateName = btoa(component.get('v.sTempName'));
            bSuper.callServer(component, 'c.encryptParameter', function (response) {
                if (response !== null && response !== '') {
                    userAssessmentId = response;
                    var url = 'guest-assessment?Id=' + assessmentId + '&tempName=' + templateName + '&userAssessmentId=' + userAssessmentId;
                    window.open(url, '_self');
                }
            }, {
                "sParamValue": component.get("v.sAssessmentId")
            }, false);
        }
        else if (component.get("v.bisResident")) {
            component.set("v.userAssessmentId", component.get("v.sAssessmentId"));
            component.set("v.bshowassessmentres", true);
        }
        else {
            window.open('assessment-results?Id=' + userAssessmentId, '_self');
        }
        // window.open(backURL,'_self');
    },
    /* check email validation */
    checkEmailValidity: function (component, event) {
        var pattern = /^([a-zA-Z0-9_+-])+([a-zA-Z0-9_+.-])*\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9])+$/;
        var value = component.get("v.sEmail");
        if (!pattern.test(value)) {
            return false;
        }
        else {
            return true;
        }
    },
    checkLoggedinUserRole: function (component, event, helper) {
        //Nandita:05/05/2020: updated logic as a part of defect# 360169
        var bSuper = component.find("bSuper");
        var userAssessmenId = this.getURLParam().userAssessmentId;
        bSuper.callServer(component, 'c.checkLoggedinUserRole', function (response) {
            component.set('v.isSpinnerActive', false);
            var resp = response;
            if (response != null && response != '') {
                if (response.UserType === 'Citizen' || response.UserType === 'Guest') {

                    if (response.AssessmentId !== '' && response.AssessmentId !== undefined) {
                        component.set('v.sAssessmentId', response.AssessmentId);
                        component.set('v.bIsAnonymousSubmit', true);
                    }
                }
                else if (response.UserType === 'CPAdmin') {
                    window.open('referral-inbox', '_self');
                }
                else if (response.UserType === 'Assister') {
                    window.open('clients', '_self');
                }
            }

        }, {
            userAssessmentId: userAssessmenId
        }, false);
    }

})