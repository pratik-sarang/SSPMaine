import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getEnrollmentDetails from "@salesforce/apex/SSP_ChildcareEnrollSummaryCtrl.getEnrollmentDetails";
import sspViewBenefits from "@salesforce/label/c.SSP_ViewBenefits";
import sspChildCareSummary from "@salesforce/label/c.SSP_ChildCareSummary";
import sspChildCareSummaryText from "@salesforce/label/c.SSP_ChildCareSummaryText";
import sspActive from "@salesforce/label/c.SSP_Active";
import sspPending from "@salesforce/label/c.SSP_Pending";
import sspProvider from "@salesforce/label/c.SSP_Provider";
import sspEnrollmentStartDate from "@salesforce/label/c.SSP_EnrollmentStartDate";
import sspEnrollmentEndDate from "@salesforce/label/c.SSP_EnrollmentEndDate";
import sspProviderDailyRate from "@salesforce/label/c.SSP_ProviderDailyRate";
import sspAllocatedDailyCopay from "@salesforce/label/c.SSP_AllocatedDailyCopay";
import sspFamilyDailyCopay from "@salesforce/label/c.SSP_FamilyDailyCopay";
import sspEnrollmentId from "@salesforce/label/c.SSP_EnrollmentId";
import sspMon from "@salesforce/label/c.SSP_Mon";
import sspTue from "@salesforce/label/c.SSP_Tue";
import sspWed from "@salesforce/label/c.SSP_Wed";
import sspThu from "@salesforce/label/c.SSP_Thu";
import sspFri from "@salesforce/label/c.SSP_Fri";
import sspFullDay from "@salesforce/label/c.SSP_FullDay";
import sspSat from "@salesforce/label/c.SSP_Sat";
import sspNope from "@salesforce/label/c.SSP_Nope";
import sspSun from "@salesforce/label/c.SSP_Sun";
import sspSchoolOpen from "@salesforce/label/c.SSP_SchoolOpen";
import sspSchoolClosed from "@salesforce/label/c.SSP_SchoolClosed";
import sspSchoolSunday from "@salesforce/label/c.SSP_SchoolSunday";
import sspFlexibleFullDays from "@salesforce/label/c.SSP_FlexiFullDays";
import sspFullDays from "@salesforce/label/c.SSP_FullDays";
import sspFlexiblePartDays from "@salesforce/label/c.SSP_FlexiPartDays";
import sspPartDays from "@salesforce/label/c.SSP_PartDays";
import sspChildCarePhoneAlt from "@salesforce/label/c.SSP_ChildCarePhoneAlt";
import sspPartialDay from "@salesforce/label/c.SSP_PartialDay";
import sspConstants from "c/sspConstants";
import sspUtility from "c/sspUtility";

export default class SspChildCareEnrollmentSummary extends NavigationMixin(
    LightningElement
) {
    @track userName = "";
    @track enrollmentDetails = [];
    @track enrollmentScheduleDetails = [];
    @track individualId = "";
    @track isReadOnlyUser = false;
    @track isScreenAccessible = false;
    @track isEditable = false;
    @track showAccessDeniedComponent = false;
    @track showSpinner =false;
    label = {
        sspPartialDay,
        sspChildCarePhoneAlt,
        sspViewBenefits,
        sspChildCareSummary,
        sspChildCareSummaryText,
        sspActive,
        sspPending,
        sspProvider,
        sspEnrollmentStartDate,
        sspEnrollmentEndDate,
        sspProviderDailyRate,
        sspAllocatedDailyCopay,
        sspFamilyDailyCopay,
        sspEnrollmentId,
        sspMon,
        sspTue,
        sspWed,
        sspThu,
        sspFri,
        sspFullDay,
        sspSat,
        sspNope,
        sspSun,
        sspSchoolOpen,
        sspSchoolClosed,
        sspSchoolSunday,
        sspFlexibleFullDays,
        sspFullDays,
        sspFlexiblePartDays,
        sspPartDays
    };
    /**
     * @function : timeFormatConverter.
     * @description : Method to format time.
     * @param  {object} timeStamp - Time string.
     */
    timeFormatConverter = timeStamp => {
        try {
            let newTimeFormat = timeStamp.split("T")[0];
            newTimeFormat = `${newTimeFormat.split("-")[1]}/${
                newTimeFormat.split("-")[2]
            }/${newTimeFormat.split("-")[0]}`;
            return newTimeFormat;
        } catch (error) {
            console.error("Error in connectedCallback", error);
        }
    };

    /**
     * @function : returnArrayElementPosition.
     * @description : Method called on initial load.
     * @param  {Array} arr - Complete array.
     * @param  {string} id - Complete array.
     */
    returnArrayElementPosition = (arr, id) => {
        try {
            const tempArray = [];
            for (let i = 0; i < arr.length; i++) {
                if (arr[i].EnrollmentID === id) {
                    tempArray.push(arr[i]);
                }
            }
            return JSON.parse(JSON.stringify(tempArray));
        } catch (error) {
            console.error("Error in returnArrayElementPosition", error);
        }
    };

    /**
     * @function : connectedCallback.
     * @description : Method called on initial load.
     */
    connectedCallback () {
        try {
            this.showSpinner = true;
            const url = new URL(window.location.href);
            this.individualId = url.searchParams.get("individualId");
            this.getChildCareEnrollmentDetails();
        } catch (error) {
            this.showSpinner = false;
            console.error("Error in connectedCallback", error);
        }
    }

    getChildCareEnrollmentDetails = () => {
        try {
            getEnrollmentDetails({
                individualIdentity: this.individualId
            }).then(result => {
                if (result.bIsSuccess === true) {
                    this.userName = result.mapResponse.loggedInContact;
                    this.enrollmentDetails = JSON.parse(
                        result.mapResponse.ccEnrollmentDetails
                    );
                    this.enrollmentScheduleDetails = JSON.parse(
                        result.mapResponse.ccEnrollmentSchDetails
                    );
                    this.constructRenderingAttributes(
                        result.mapResponse.screenPermission
                    );
                    let scheduleDetails;
                    this.enrollmentDetails.forEach(item => {
                        scheduleDetails = this.returnArrayElementPosition(
                            this.enrollmentScheduleDetails,
                            item.EnrollmentId
                        );
                        if (item.EnrollmentStatus === sspConstants.childCareAttributes.Active) {
                            item.displayStatus = sspActive;
                            item.className = "ssp-Disc ssp-bg_greenAlpha";
                        } else {
                            item.displayStatus = sspPending;
                            item.className = "ssp-Disc ssp-bg_orangeAlpha";
                        }
                        if (
                            item.hasOwnProperty(sspConstants.childCareAttributes.EnrollmentStatusFromDate) &&
                            item.EnrollmentStatusFromDate
                        ) {
                            item.EnrollmentStatusFromDate = this.timeFormatConverter(
                                item.EnrollmentStatusFromDate
                            );
                        } else {
                            item.EnrollmentStatusFromDate = "";
                        }
                        if (
                            item.hasOwnProperty(sspConstants.childCareAttributes.EnrollmentStatusEndDate) &&
                            item.EnrollmentStatusEndDate
                        ) {
                            item.EnrollmentStatusEndDate = this.timeFormatConverter(
                                item.EnrollmentStatusEndDate
                            );
                        } else {
                            item.EnrollmentStatusEndDate = "";
                        }
                        if (
                            !item.hasOwnProperty(sspConstants.childCareAttributes.ProviderDailyRate) ||
                            !item.ProviderDailyRate
                        ) {
                            item.ProviderDailyRate = "0.00";
                        }
                        if (
                            !item.hasOwnProperty(
                                sspConstants.childCareAttributes.IndividualAllocatedDailyCoPayAmount
                            ) ||
                            !item.IndividualAllocatedDailyCoPayAmount
                        ) {
                            item.IndividualAllocatedDailyCoPayAmount = "0.00";
                        }
                        if (
                            !item.hasOwnProperty(
                                sspConstants.childCareAttributes.FamilyAllocatedDailyCoPayAmount
                            ) ||
                            !item.FamilyAllocatedDailyCoPayAmount
                        ) {
                            item.FamilyAllocatedDailyCoPayAmount = "0.00";
                        }
                        //Logic for showing schedules
                        for (let i = 0; i < scheduleDetails.length; i++) {
                            if (
                                scheduleDetails[i] &&
                                item.EnrollmentId ===
                                    scheduleDetails[i].EnrollmentID
                            ) {
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.FlexiMaxFullDays
                                    ) &&
                                    scheduleDetails[i].FlexiMaxFullDays
                                ) {
                                    item.FlexiMaxFullDays =
                                        scheduleDetails[i].FlexiMaxFullDays;
                                } else {
                                    item.FlexiMaxFullDays = "";
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.FlexiMaxPartDays
                                    ) &&
                                    scheduleDetails[i].FlexiMaxPartDays
                                ) {
                                    item.FlexiMaxPartDays =
                                        scheduleDetails[i].FlexiMaxPartDays;
                                } else {
                                    item.FlexiMaxPartDays = "";
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnFriday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnFriday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnFriday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnFriday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnFriday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnFriday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnFriday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnFriday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnMonday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnMonday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnMonday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnMonday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnMonday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnMonday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnMonday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnMonday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnSaturday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnSaturday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSaturday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnSaturday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSaturday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnSaturday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSaturday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnSaturday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnSunday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnSunday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSunday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnSunday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSunday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnSunday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnSunday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnSunday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnThursday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnThursday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnThursday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnThursday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnThursday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnThursday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnThursday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnThursday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnTuesday
                                    ) &&
                                    scheduleDetails[i].ServiceScheduleOnTuesday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnTuesday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnTuesday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnTuesday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnTuesday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnTuesday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnTuesday = sspFullDay;
                                    }
                                }
                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.ServiceScheduleOnWednesday
                                    ) &&
                                    scheduleDetails[i]
                                        .ServiceScheduleOnWednesday
                                ) {
                                    if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnWednesday ===
                                        "Part Day"
                                    ) {
                                        item.ServiceScheduleOnWednesday = sspPartialDay;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnWednesday ===
                                        "Not Needed"
                                    ) {
                                        item.ServiceScheduleOnWednesday = sspNope;
                                    } else if (
                                        scheduleDetails[i]
                                            .ServiceScheduleOnWednesday ===
                                        "Full Day"
                                    ) {
                                        item.ServiceScheduleOnWednesday = sspFullDay;
                                    }
                                }
                                if (!item.isWeekSchedule) {
                                    item.isWeekSchedule =
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnFriday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnFriday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnMonday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnMonday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnSaturday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnSaturday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnSunday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnSunday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnThursday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnThursday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnTuesday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnTuesday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.ServiceScheduleOnWednesday
                                        ) &&
                                            scheduleDetails[i]
                                                .ServiceScheduleOnTuesday !==
                                                null);
                                }
                                if (!item.isFlexibleSchedule) {
                                    item.isFlexibleSchedule =
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.FlexiMaxFullDays
                                        ) &&
                                            scheduleDetails[i]
                                                .FlexiMaxFullDays !== null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.FlexiMaxPartDays
                                        ) &&
                                            scheduleDetails[i]
                                                .FlexiMaxPartDays !== null);
                                }

                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.SchoolSunday
                                    ) &&
                                    scheduleDetails[i].SchoolSunday
                                ) {
                                    if (
                                        scheduleDetails[i].SchoolSunday ===
                                        "Part Day"
                                    ) {
                                        item.SchoolSunday = sspPartialDay;
                                    }
                                    if (
                                        scheduleDetails[i].SchoolSunday ===
                                        "Full Day"
                                    ) {
                                        item.SchoolSunday = sspFullDay;
                                    }
                                }

                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.SchoolClosedNeed
                                    ) &&
                                    scheduleDetails[i].SchoolClosedNeed
                                ) {
                                    if (
                                        scheduleDetails[i].SchoolClosedNeed ===
                                        "Part Day"
                                    ) {
                                        item.SchoolClosedNeed = sspPartialDay;
                                    }
                                    if (
                                        scheduleDetails[i].SchoolClosedNeed ===
                                        "Full Day"
                                    ) {
                                        item.SchoolClosedNeed = sspFullDay;
                                    }
                                }

                                if (
                                    scheduleDetails[i].hasOwnProperty(
                                        sspConstants.childCareAttributes.SchoolOpenNeed
                                    ) &&
                                    scheduleDetails[i].SchoolOpenNeed
                                ) {
                                    if (
                                        scheduleDetails[i].SchoolOpenNeed ===
                                        "Part Day"
                                    ) {
                                        item.SchoolOpenNeed = sspPartialDay;
                                    }
                                    if (
                                        scheduleDetails[i].SchoolOpenNeed ===
                                        "Full Day"
                                    ) {
                                        item.SchoolOpenNeed = sspFullDay;
                                    }
                                }
                                if (!item.isSchoolSchedule) {
                                    item.isSchoolSchedule =
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.SchoolSunday
                                        ) &&
                                            scheduleDetails[i].SchoolSunday !==
                                                null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.SchoolOpenNeed
                                        ) &&
                                            scheduleDetails[i]
                                                .SchoolOpenNeed !== null) ||
                                        (scheduleDetails[i].hasOwnProperty(
                                            sspConstants.childCareAttributes.SchoolClosedNeed
                                        ) &&
                                            scheduleDetails[i]
                                                .SchoolClosedNeed !== null);
                                }
                            }
                        }
                    });
                } else {
                    this.showSpinner = false;
                    this.isScreenAccessible = true;
                    console.error("Error in handler =>", JSON.stringify(result));
                }
                this.showSpinner = false;
            });
        } catch (error) {
            this.showSpinner = false;
            this.isScreenAccessible = true;
            console.error("Error in getChildCareEnrollmentDetails =>", error);
        }
    };
    /**
     * @function - backToBenefits.
     * @description - Method to navigate to benefits screen.
     * @param  {object} event - Fired on key down or click of the link.
     */
    backToBenefits = event => {
        try {
            if (
                event.type === "click" ||
                (event.type === "keydown" && event.keyCode === 13)
            ) {
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Benefits_Page__c"
                    }
                });
            }
        } catch (error) {
            console.error("Error occurred in backToBenefits", error);
        }
    };


    /**
     * @function : constructRenderingAttributes - 2.5	Security Role Matrix and Program Access
     * @description : This method is used to construct rendering attributes.
     * @param {object} response - Backend response.
     */
    constructRenderingAttributes = response => {
        try {
            if (
                response != null &&
                response != undefined &&
                response.hasOwnProperty("screenPermission")
            ) {
                this.showSpinner = true;
                const securityMatrix = response;
                this.isReadOnlyUser =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.readOnly;
                this.isScreenAccessible =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.notAccessible
                        ? false
                        : true;
                if (!this.isScreenAccessible){
                    this.showAccessDeniedComponent = true;
                }
                this.isEditable =
                    !sspUtility.isUndefinedOrNull(securityMatrix) &&
                    securityMatrix.screenPermission ==
                        sspConstants.permission.editable;
            }
        } catch (error) {
            console.error(JSON.stringify(error.message));
        }
    };
}