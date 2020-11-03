({
    doInit: function (component, event, helper) {
        var AssessmentId = component.get("v.sAssessmenTemplatetId");
        if (window.location.pathname.includes('guest-assessmen')) {
            helper.checkLoggedinUserRole(component, event, helper);
        }
        if (AssessmentId === '' || AssessmentId === null || AssessmentId === undefined) {
            helper.getParam(component);
        }

        helper.fetchData(component);

    },
    handleAnswerClick: function (component) {
        component.set("v.bisRequired", false);
    },
    handleNext: function (component, event, helper) {

        var req = event.getSource().get("v.value");
        var x = JSON.parse(JSON.stringify(component.get("v.questions")));
        var currentindex = event.getSource().get("v.name");


        var allValid = true;
        var emailreq = false;

        if (component.get("v.bIsAnonymous")) {

            var emailVal = component.get("v.sEmail");
            var validData = component.find('required_fld');
            var isValid = helper.checkEmailValidity(component, event, emailVal);
            //var emailField = component.find("emailAddress");
            if (!component.get("v.sEmail") || !isValid) {
                emailreq = true;
                if (validData.length < 4)
                    $A.util.addClass(validData[1], "required-class");
                else
                    $A.util.addClass(validData[2], "required-class");
            }
            else if (isValid && validData !== null && validData !== undefined) {
                if (validData.length < 4)
                    $A.util.removeClass(validData[1], "required-class");
                else
                    $A.util.removeClass(validData[2], "required-class");
            }
            // var addressfield = component.find("address");
            if (validData !== null && validData !== undefined) {
                if (x[currentindex].sResponse === null || x[currentindex].sResponse === undefined || x[currentindex].sResponse === '') {
                    $A.util.addClass(validData[0], "required-class");
                }
                else {
                    $A.util.removeClass(validData[0], "required-class");
                }
            }


            if (Array.isArray(component.find('required_fld'))) {
                if (component.find('required_fld')[0].get('v.value') === '') {

                    validData[0].checkValidity();
                    validData[0].showHelpMessageIfInvalid();
                    allValid = false;
                } else {
                    allValid = true;
                }

            }


        }

        if (component.get("v.sInitialAddress") === x[currentindex].sResponse) {
            component.set("v.bisValueSelected", true);
        }


        if ((req && !x[currentindex].sResponse) || !component.get("v.bisValueSelected") || allValid === false || emailreq) {
            var error = $A.get("$Label.c.SelectAnswer");

            helper.showToast(component, event, 'Error', error);
        }
        else {
            component.set('v.bIsMeterVisible', true);

            var index = event.getSource().get("v.name");
            var nextIndex = index + 1;

            component.set('v.index', nextIndex);
            document.getElementById('questioncontainer_' + index).classList.add('slds-hide');
            document.getElementById('questioncontainer_' + nextIndex).classList.remove('slds-hide');
        }

    },
    handlePrevious: function (component, event) {

        var index = event.getSource().get("v.name");
        var previousIndex = index - 1;

        if (index === 1) {
            component.set('v.bIsMeterVisible', false);
        }

        component.set('v.index', previousIndex);
        document.getElementById('questioncontainer_' + index).classList.add('slds-hide');
        document.getElementById('questioncontainer_' + previousIndex).classList.remove('slds-hide');
    },
    handleSubmit: function (component, event, helper) {
        var req = event.getSource().get("v.value");
        var x = JSON.parse(JSON.stringify(component.get("v.questions")));
        var currentindex = event.getSource().get("v.name");
        if (req && !x[currentindex].sResponse) {
            var error = $A.get("$Label.c.SelectAnswer");

            helper.showToast(component, event, 'Error', error);
        }
        else {


            component.set("v.bsubmitdisabled", true);

            helper.submitAssessment(component, event, helper);

        }

    },
    handleCancelClick: function (component) {
        component.set("v.bshowModal", true);

        //component.set("v.showOptoutPopup",true);
        //window.open('/s/client-one-view?referralid='+contactId,'_self');
    },
    handleCancel: function (component) {
        if (component.get("v.bisResident")) {



            var closebtn = component.getEvent("CloseModalEvt");
            closebtn.setParams({
                "closeModal": true,
                "sObjectName": "Assessment__c",
                "sObjectId": "abc"
            });
            closebtn.fire();
            component.set("v.bshowassessmentques", false);





        } else {
            var contactId = btoa(component.get("v.sContactId"));
            window.open('clients?clientId=' + contactId + '&backfromsurvey=true', '_self');
        }
    },
    handleContinue: function (component) {
        component.set("v.bshowModal", false);
    },
    goToClientDetail: function (component) {
        var contactId = btoa(component.get("v.sContactId"));
        window.open('clients?clientId=' + contactId, '_blank');
    },
    validateEmail: function (component, event, helper) {
        var email = component.get("v.sEmail");

        var isValid = helper.checkEmailValidity(component, event, email);
        if (isValid !== true) {
            component.set("v.bvalidEmail", true);

            return false;
        }
        else {
            return true;
        }
    },
    preventTextEntery: function (component) {
        var qtns = component.get("v.questions");
        var quetion = component.find("questionInput").get("v.id");
        var age = component.find("questionInput").get("v.value");
        var formattedAge = ("" + age).replace(/\D/g, '');
        var i = 0;
        if (!formattedAge) {
            for (i; i < qtns.length; i += 1) {
                if (qtns[i] === quetion) {
                    qtns[i].sResponse = formattedAge;
                }
            }
            component.set("v.questions", qtns);
            return;
        }
        for (i; i < qtns.length; i += 1) {
            if (qtns[i] === quetion) {
                qtns[i].sResponse = formattedAge;
            }
        }
        component.set("v.questions", qtns);
        return;
    }
})
