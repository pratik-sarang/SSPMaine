({
    getPicklistValues: function (component, helper) {
        try {
            component.set("v.isLoading", true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            var fields = component.get("v.picklistFields");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getPickListValues', function (response) {
                if (response.isSuccessful) {
                    var pickListFlds = fields.split(',');
                    var result = response.objectData.picklistvalues;
                    for (var index in pickListFlds) {
                        if (pickListFlds.hasOwnProperty(index)) {
                            var options = [];
                            var keys = Object.keys(result[pickListFlds[index]]);
                            for (var i in keys) {
                                if (keys.hasOwnProperty(i)) {
                                    options.push({
                                        class: "optionClass",
                                        label: keys[i],
                                        value: result[pickListFlds[index]][keys[i]],
                                        selected: false
                                    });
                                }
                            }
                            if (pickListFlds[index] === "PreferredCommunicationMethod__c") {
                                component.set("v.communicationMethodMap", options);
                            } else if (pickListFlds[index] === "Needs__c") {
                                component.set("v.needsMap", options);
                            } else if (pickListFlds[index] === "State__c") {
                                component.set("v.stateMap", options);
                            }
                        }
                    }
                    //Get ContactInfo and Archetype details
                    helper.getArchetypes(component, helper);
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                "strObjectName": 'Contact',
                "strLstFields": component.get("v.picklistFields")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }
    },
    getArchetypes: function (component, helper) {
        try {
            component.set('v.isSpinnerActive', true);
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.getArchetypes', function(response) {
                component.set("v.isLoading",false);
                if(response.isSuccessful){
                    var result=response.objectData;
                    var archetypes=result.archetypes;
                    var userdetails=result.userdetails;
                    component.set("v.isCPUser",result.bIsCPUserProfile);
                    component.set("v.isAgencyUser",result.bIsAgencyUserProfile);//RE_Release 1.1 - Agency User Capture- Mohan
                    component.set("v.isAssister",result.bIsAssister);
                    component.set("v.userdetails",userdetails);
                    var contactdetails=result.contactdetails;
                    if(!$A.util.isUndefinedOrNull(contactdetails)){
                        if(!$A.util.isUndefinedOrNull(contactdetails[0].Account)){
                            component.set("v.optOutFlag",contactdetails[0].Account.HasOptedOutOfAccount__c);
                        } 
                        //Spliting address into AddressLine1 and AddressLine 2
                        if (!$A.util.isUndefinedOrNull(contactdetails[0].MailingStreet)) {
                            var addresslist = contactdetails[0].MailingStreet.split('\n');
                            if (addresslist.length >= 2) {
                                component.set("v.addressLine1", addresslist[0]);
                                component.set("v.addressLine2", addresslist[1]);
                            } else if (addresslist.length >= 1) {
                                component.set("v.addressLine1", addresslist[0]);
                            }

                        }

                        component.set("v.contactinformation", contactdetails[0]);

                        var phone = component.get("v.contactinformation.Phone");
                        if (phone !== null && phone !== '' && phone !== undefined) {
                            var formatedPhone = helper.formatPhoneNumber(phone);
                            component.set("v.contactinformation.Phone", formatedPhone);
                        }
                        //Added By Kojashree
                        var consentToTextVar = component.get("v.contactinformation.ConsentToTexts__c");
                        component.set("v.consentToText",consentToTextVar);
                        
                        if (!$A.util.isUndefinedOrNull(contactdetails[0].Needs__c)) {
                            //if needs are already on records auto-select them
                            var needs = contactdetails[0].Needs__c.split(';');
                            var needsMap = component.get("v.needsMap");
                            for (var n in needsMap) {
                                if (needsMap.hasOwnProperty(n)) {
                                    if (needs.includes(needsMap[n].value)) {
                                        needsMap[n].selected = true;
                                    }
                                }
                            }
                            component.set("v.needsMap", needsMap);
                        }
                        var archetypeonContact;
                        //Set archtype and auto-select if already present 
                        if (!$A.util.isUndefinedOrNull(contactdetails[0].Archetype__c)) {
                            archetypeonContact = contactdetails[0].Archetype__c.split(';');
                        }
                        var options = [];
                        for (var i in archetypes) {
                            if (archetypes.hasOwnProperty(i) && userdetails.LanguageLocaleKey === archetypes[i].Language__c) {
                                options.push({
                                    record: archetypes[i],
                                    selected: false
                                });
                                if (!$A.util.isUndefinedOrNull(archetypeonContact) && archetypeonContact.includes(options[i].record.Id)) {
                                    options[i].selected = true;
                                }
                            }
                        }
                        component.set("v.archetypes", options);

                        //Set Primary Location for CPUsers
                        options = [];
                        if(result.bIsCPUserProfile===true ||result.bIsAgencyUserProfile===true){
                            for(var l in result.lstLocations){
                                if(result.lstLocations.hasOwnProperty(l)) {
                                    if(!$A.util.isUndefinedOrNull(contactdetails[0].PrimaryLocation__c) &&
                                       result.lstLocations[l].Id === contactdetails[0].PrimaryLocation__c){
                                        options.push({
                                            class: "optionClass",
                                            label: result.lstLocations[l].Name,
                                            value: result.lstLocations[l].Id,
                                            selected: true
                                        });
                                    } else {
                                        options.push({
                                            class: "optionClass",
                                            label: result.lstLocations[l].Name,
                                            value: result.lstLocations[l].Id
                                        });
                                    }
                                }

                            }
                            component.set("v.primarylocation", options);
                        }

                        component.set('v.isSpinnerActive', false);
                    }

                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {}, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

    },
    submitResidentInfo: function (component) {
        var needs = component.get("v.needsMap");
        var residentneeds = '';
        for (var n in needs) {
            if (needs.hasOwnProperty(n)) {
                if (needs[n].selected === true) {
                    residentneeds += needs[n].value + ';';
                }
            }
        }
        var archetypes = component.get("v.archetypes");
        var selectedArchetype = '';
        for (var a in archetypes) {
            if (archetypes.hasOwnProperty(a)) {
                if (archetypes[a].selected === true) {
                    selectedArchetype += archetypes[a].record.Id + ';';
                }
            }
        }
        var consentToText = component.get("v.consentToText");
        component.set("v.contactinformation.Needs__c", residentneeds);
        component.set("v.contactinformation.Account", null);
        component.set("v.contactinformation.Archetype__c", selectedArchetype);
        component.set("v.contactinformation.ConsentToTexts__c", consentToText);//Added By Kojashree
        if (!$A.util.isUndefinedOrNull(component.get("v.addressLine1")) &&
            !$A.util.isUndefinedOrNull(component.get("v.addressLine2"))) {
            component.set("v.contactinformation.MailingStreet", component.get("v.addressLine1") + '\n' + component.get("v.addressLine2"));
        } else if (!$A.util.isUndefinedOrNull(component.get("v.addressLine1")) &&
            $A.util.isUndefinedOrNull(component.get("v.addressLine2"))) {
            component.set("v.contactinformation.MailingStreet", component.get("v.addressLine1"));
        } else if ($A.util.isUndefinedOrNull(component.get("v.addressLine1")) &&
            !$A.util.isUndefinedOrNull(component.get("v.addressLine2"))) {
            component.set("v.contactinformation.MailingStreet", component.get("v.addressLine2"));
        } else {
            component.set("v.contactinformation.MailingStreet", '');
        }

        //reference to inherited super component
        var bSuper = component.find("bSuper");
        var addressValidationCheck = this.addressValidation(component);
        if (addressValidationCheck) {
            try {
                //override the method in super class and write your own logic with the response received
                bSuper.callServer(component, 'c.submitResidentInfo', function (response) {
                    if (response.isSuccessful) {
                        var successMsg = $A.get("$Label.c.AccountDetailsUpdated");
                        //bSuper.showToast($A.get("$.Label.c.successstatus"),$A.get("$.Label.c.successstatus"),successMsg);
                        bSuper.showToast($A.get("$Label.c.successstatus"), "SUCCESS", successMsg);
                        if (component.get("v.isMyAccount")) {
                            window.setTimeout(
                                $A.getCallback(function () {
                                    window.open($A.get("$Label.c.RE_Community_Base_URL"), '_top');
                                }), 3000
                            );
                        } else {
                            window.setTimeout(
                                $A.getCallback(function () {
                                    window.open('landing-page', '_top');
                                }), 3000
                            );
                        }

                    } else {
                        var errMsg = $A.get("$Label.c.servererror");
                        bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                    }

                }, {
                    "contantInfo": component.get("v.contactinformation"),
                    "optOutFlag": component.get("v.optOutFlag"),
                    "hasConsentToText": component.get("v.consentToText") //Added By kojashree

                }, false);
            } catch (e) {
                bSuper.consoleLog(e.stack, true);
            }
        } else {
            //var errMsg = $A.get("$Label.c.invalidAddress");
            var errMsg = $A.get("$Label.c.RE_Enter_Address");
            bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
        }
    },
    updateCPUserProfile: function (component) {
        try {
            //reference to inherited super component
            var bSuper = component.find("bSuper");
            //override the method in super class and write your own logic with the response received
            bSuper.callServer(component, 'c.updateCPUserInfo', function (response) {
                if (response.isSuccessful) {
                    var successMsg = $A.get("$Label.c.AccountDetailsUpdated");
                    //bSuper.showToast($A.get("$.Label.c.successstatus"),$A.get("$.Label.c.successstatus"),successMsg);
                    bSuper.showToast($A.get("$Label.c.successstatus"), "SUCCESS", successMsg);
                    window.setTimeout(
                        $A.getCallback(function () {
                            //Smoke test issue assister - Payal Dubela
                            window.open($A.get("$Label.c.RE_Community_Base_URL"), '_top');
                        }), 3000
                    );
                } else {
                    var errMsg = $A.get("$Label.c.servererror");
                    bSuper.showToast($A.get("$Label.c.errorstatus"), $A.get("$Label.c.errorstatus"), errMsg);
                }

            }, {
                "contantInfo": component.get("v.contactinformation")
            }, false);
        } catch (e) {
            bSuper.consoleLog(e.stack, true);
        }

    },
    /* format phone number */
    formatPhoneNumber: function (phoneNumber) {
        var phone = ("" + phoneNumber).replace(/\D/g, '');
        var formatedPhone = phone.match(/^(\d{3})(\d{3})(\d{4})$/);
        if (!formatedPhone) {
            return phone;
        }
        return (!formatedPhone) ? null : "(" + formatedPhone[1] + ") " + formatedPhone[2] + "-" + formatedPhone[3];
    },
    /* check eail validation */
    checkEmailValidity: function (OriginalEmailId) {
        var pattern = /^([a-zA-Z0-9_+-])+([a-zA-Z0-9_+.-])*\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9])+$/;
        var inputField = OriginalEmailId;
        var value = inputField.get('v.value');
        if (!pattern.test(value)) {
            inputField.set('v.validity', { valid: false, badInput: true });
            inputField.showHelpMessageIfInvalid();
        }
    },
    /* Address Validation Added as part of 339824*/
    addressValidation: function (component) {
        var pattern = /^[a-zA-Z0-9\s,-;:]*$/;
        var address1 = component.get("v.addressLine1");
        var address2 = component.get("v.addressLine2");
        if (!pattern.test(address1) || !pattern.test(address2)) {
            return false;
        } else {
            return true;
        }
    },
    checkPhoneValidity: function (component, event, inputFieldPhoneVal) {
        var bSuper = component.find("bSuper");
        var pattern1 = /^(\([0]{3}\) |[0]{3}-)[0]{3}-[0]{4}$/;
        var phoneValCorrect;
        var errMsg;
        if (pattern1.test(inputFieldPhoneVal)) {
            phoneValCorrect = false;
            errMsg = $A.get("$Label.c.InvalidPhoneValue");
            bSuper.showToast('Error', 'Error', errMsg);
            //exit;
        }
        else {
            var pattern2 = /^(\d{3})(\d{3})(\d{4})$/;
            if (pattern2.test(inputFieldPhoneVal)) {
                phoneValCorrect = true;
            } else
                phoneValCorrect = false;

        }

        return phoneValCorrect;

    },
    validateInputs: function (component) {
        var formdata = component.get("v.contactinformation");
        var allValid = component.find('required_fld').reduce(function (validSoFar, inputCmp) {
            inputCmp.checkValidity();
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        var validationError = false;

        var validPhone1;
        var validPhone2;
        var inputFieldPhoneVal; // 20Dec LV issue
        var inputFieldPhoneVal1 = component.find("required_fldPhone1");
        var inputFieldPhoneVal2 = component.find("required_fldPhone2");
        if (!$A.util.isUndefinedOrNull(inputFieldPhoneVal1)) {
            inputFieldPhoneVal = inputFieldPhoneVal1.get("v.value");
            validPhone1 = this.checkPhoneValidity(component, event, inputFieldPhoneVal);
        }
        if (!$A.util.isUndefinedOrNull(inputFieldPhoneVal2)) {
            inputFieldPhoneVal = inputFieldPhoneVal2.get("v.value");
            validPhone2 = this.checkPhoneValidity(component, event, inputFieldPhoneVal);
        }

        if(component.get("v.isCPUser")===false ||component.get("v.isAgencyUser")===false ){
            if($A.util.isUndefinedOrNull(formdata.FirstName)|| $A.util.isUndefinedOrNull(formdata.LastName)
               || $A.util.isUndefinedOrNull(formdata.Email)|| $A.util.isUndefinedOrNull(formdata.Phone)
               || $A.util.isUndefinedOrNull(formdata.PreferredCommunicationMethod__c)|| $A.util.isUndefinedOrNull(formdata.MailingPostalCode)){
                validationError = true;
            } else {
                if ($A.util.isEmpty(formdata.FirstName.trim()) || $A.util.isEmpty(formdata.LastName.trim())
                    || $A.util.isEmpty(formdata.Email.trim()) || $A.util.isEmpty(formdata.Phone.trim())
                    || $A.util.isEmpty(formdata.PreferredCommunicationMethod__c.trim()) ||
                    $A.util.isEmpty(formdata.MailingPostalCode.trim())) {
                    validationError = true;
                }
            }

        } else {
            if ($A.util.isUndefinedOrNull(formdata.Email) || $A.util.isUndefinedOrNull(formdata.Phone)
                || $A.util.isUndefinedOrNull(formdata.PrimaryLocation__c)) {
                validationError = true;
            } else {
                if ($A.util.isEmpty(formdata.Email.trim()) || $A.util.isEmpty(formdata.Phone.trim())
                    || $A.util.isEmpty(formdata.PrimaryLocation__c.trim())) {
                    validationError = true;
                }
            }

        }
        if ((!$A.util.isUndefinedOrNull(component.find('required_fldPhone1'))) && component.find('required_fldPhone1').checkValidity() === false && validPhone1 === false) {
            validationError = true;
        }

        if ((!$A.util.isUndefinedOrNull(component.find('required_fldPhone2'))) && component.find('required_fldPhone2').checkValidity() === false && validPhone2 === false) {
            validationError = true;
        }

        if (allValid === false) {
            validationError = true;
        }
        return validationError;
    }
})