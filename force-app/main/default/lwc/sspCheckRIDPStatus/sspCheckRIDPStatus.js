/*
 * Component Name: sspCheckRIDPStatus.
 * Author:  Nikhil Shinde, Prasanth.
 * Description: This component calls the challenge questions service and then post answers service once the answers are selected.
 * Date: 25-06-2020
 */

import { track, api, LightningElement } from "lwc";
import sspConstants from "c/sspConstants";
import utility from "c/sspUtility";
import getQuestions from "@salesforce/apex/SSP_RIDPServices.getQuestions";
import getData from "@salesforce/apex/SSP_RIDPServices.getData";
import postAnswers from "@salesforce/apex/SSP_RIDPServices.postAnswers";
import createJSONWrapper from "@salesforce/apex/SSP_IdentityVerificationUploadController.createJSONWrapper";

import sspChallengeQuestions from "@salesforce/label/c.SSP_ApplicantVerificationChallengeQuestions";
import sspModalContent from "@salesforce/label/c.SSP_ApplicantVerificationModalContent";
import sspModalContentTwo from "@salesforce/label/c.SSP_ApplicantVerificationModalContent2";
import sspModalHeader from "@salesforce/label/c.SSP_ApplicantVerificationModalHeader";
import sspResumeRIDP from "@salesforce/label/c.SSP_ApplicantVerificationResumeRIDP";
import sspTelephoneHREF from "@salesforce/label/c.SSP_FooterTelephoneHREF";
import sspContactNumber from "@salesforce/label/c.SSP_ApplicantVerificationExperianContact";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import sspNextButton from "@salesforce/label/c.SSP_NextButton";
import sspRequiredErrorMessage from "@salesforce/label/c.SSP_RequiredErrorMessage";
import sspNextAltText from "@salesforce/label/c.SSP_NextAltText";
import updateApplicationStatusUnsubmitted from "@salesforce/apex/SSP_RIDPServices.updateApplicationStatusUnSubmitted";
import deleteNavFlowRecords from "@salesforce/apex/SSP_RIDPServices.deleteNavFlowRecords";

import { NavigationMixin } from "lightning/navigation";
import { formatLabels } from "c/sspUtility";
export default class sspCheckRIDPStatus extends NavigationMixin(
    LightningElement
) {
    @track resumeRIDPResult;
    @track resumeRIDPError;
    @track getQuestionsResult = {};
    @track getQuestionsError;
    memberId;
    @api memberIdValue;
    @track memberData = [];
    @track error;
    @track challengeQuestions = [];
    @track questionSet = {};
    @track keyValueOptions = {};
    @track reference = this;
    @track isVerification = false;
    parameters = {};
    @track label = {
        sspChallengeQuestions,
        sspModalContent,
        sspModalContentTwo,
        sspModalHeader,
        sspResumeRIDP,
        sspTelephoneHREF,
        sspContactNumber,
        sspExitButton,
        sspNextButton,
        sspRequiredErrorMessage,
        sspNextAltText
    };

    @track contactNumber =
        this.label.sspTelephoneHREF + this.label.sspContactNumber;
    @track selectedAnswers = new Map();
    @track sessionID = "";
    @track showApplicationError = false;
    @track referenceNumber = "";
    @track showSpinner = false;
    @track showErrorToast = false;
    @track toastMessage = this.label.sspRequiredErrorMessage;
    @track errorMsg = "";
    @track showErrorModal = false;
    @track appId;
    @track memberIndividualId;
    @track programRemoved = false;
    @track finalProgramListSize = false;

    @api
    /**
     * @function - set memberId.
     * @description - This method is used to set memberId value.
     */
    get memberId () {
        return this.memberIdValue;
    }

    /**
     * @function - set memberId.
     * @description - This method is used to set memberId value.
     * @param {*} value - Member Id.
     */
    set memberId (value) {
        try {
            if (value) {
                this.memberIdValue = value;
                this.fetchInformationFunction(this.memberIdValue);
            }
        } catch (e) {
            console.error(
                "Error in set memberId of Primary Applicant Contact page",
                e
            );
        }
    }

    @api
    /**
     * @function - set memberId.
     * @description - This method is used to set memberId value.
     */
    get sspMemberId () {
        return this.memberId;
    }

    /**
     * @function : sspMemberId
     * @description	: Setter for memberId.
     * @param  {string} value - Member id.
     */
    set sspMemberId (value) {
        try {
            if (value !== null && value !== undefined) {
                this.memberId = value;
            }
        } catch (error) {
            console.error(
                "failed in sspCheckRIDPStatus.sspMemberId " +
                    JSON.stringify(error)
            );
        }
    }

    /**
     * @function - connectedCallback.
     * @description -  This method is called when html is attached to the component.
     */
    async connectedCallback () {
        try {
            this.showSpinner = true;
            this.parameters = this.getQueryParameters();
            this.memberDataReady().then(response => {
                this.getChallengeQuestions();
            });
            this.appId = this.parameters.applicationId;
            this.memberIndividualId = this.parameters.memberId;            
        } catch (error) {
            console.error("Error in connectedCallback =>", error);
        }
    }

    /**
     * @function - memberDataReady.
     * @description -  This method waits until the getMemberData is executed.
     */
    memberDataReady = () => new Promise(this.getMemberData);

    getMemberData = (resolve, reject) => {
        try {
            getData({ memberId: this.parameters.memberId })
                .then(result => {
                    if (
                        result.bIsSuccess &&
                        result.mapResponse.PostalCode !== null
                    ) {
                        this.memberData = result.mapResponse;                       
                        this.error = undefined;
                        resolve(result);
                    } else {
                        // eslint-disable-next-line @lwc/lwc/no-async-operation
                        setTimeout(
                            () => this.getMemberData(resolve, reject),
                            1000
                        );
                    }
                })
                .catch(error => {
                    this.error = error;
                    this.showSpinner = false;
                    console.error("Error in getData =>", error);
                });
        } catch (error) {
            console.error("Error in getMemberData =>", error);
        }
    };

    /**
     * @function - getChallengeQuestions.
     * @description -  This method calls the question service on load.
     */
    getChallengeQuestions = () => {
        try {
            getQuestions({
                mp: this.memberData,
                LanguagePreference: "LanguagePreference",
                memberId: this.parameters.memberId
            })
                .then(result => {
                    if (result.bIsSuccess) {
                        this.getQuestionsResult = JSON.parse(
                            result.mapResponse.response
                        );
                        this.handleQuestionValue();
                        this.showSpinner = false;
                        if (result.mapResponse.referenceNumber) {
                            this.referenceNumber =
                                result.mapResponse.referenceNumber;
                            Object.keys(this.label).forEach(labelKey => {
                                this.label[labelKey] = formatLabels(
                                    this.label[labelKey],
                                    [this.referenceNumber]
                                );
                            });
                            this.isVerification = true;
                            //add pop up
                        }
                    } else {
                        console.error("Error bIsSuccess => false", JSON.stringify(result));
                        this.errorMsg = result.mapResponse.error;
                        this.showErrorModal = true; // add generic error modal
                        this.showSpinner = false;
                    }
                })
                .catch(error => {
                    console.error("Error in new RIDP", error);
                    this.getQuestionsError = error;
                    this.errorMsg = error;
                    this.showErrorModal = true; // add generic error modal
                    this.showSpinner = false;
                });
        } catch (error) {
            console.error("Error in getting questions from", error);
            this.showErrorModal = true; // add generic modal
            this.showSpinner = false;
        }
    };

    /**
     * @function - handleQuestionValue.
     * @description -  This method extracts the questions and their options from the javascript object.
     */
    handleQuestionValue = () => {
        try {
            const iterate = innerObject => {
                Object.keys(innerObject).forEach(key => {
                    if (key === sspConstants.applicantIdentity.questionKey) {
                        this.questionSet = {
                            questionNumber: "",
                            question: "",
                            options: [],
                            checked: false
                        };
                        const questionObject = innerObject[key];
                        Object.keys(questionObject).forEach(questionJSON => {
                            if (
                                questionJSON ===
                                sspConstants.applicantIdentity.value
                            ) {
                                this.questionSet.question =
                                    questionObject[questionJSON];
                            } else if (
                                questionJSON ===
                                sspConstants.applicantIdentity.key
                            ) {
                                this.questionSet.questionNumber =
                                    questionObject[questionJSON];
                                this.challengeQuestions.push(this.questionSet);
                            }
                        });
                    } else if (
                        key === sspConstants.applicantIdentity.answerKey
                    ) {
                        const answerObject = innerObject[key];
                        Object.keys(answerObject).forEach((multipleOptions) => {
                            if (answerObject instanceof Array) {
                                this.keyValueOptions = {
                                    key: "",
                                    value: ""
                                };
                                Object.keys(
                                    answerObject[multipleOptions]
                                ).forEach(answerJSON => {
                                    if (
                                        answerJSON ===
                                        sspConstants.applicantIdentity.value
                                    ) {
                                        this.keyValueOptions.value =
                                            answerObject[multipleOptions][
                                            answerJSON
                                            ];
                                    } else if (
                                        answerJSON ===
                                        sspConstants.applicantIdentity.key
                                    ) {
                                        this.keyValueOptions.key =
                                            answerObject[multipleOptions][
                                            answerJSON
                                            ];
                                        this.questionSet.options.push(
                                            this.keyValueOptions
                                        );
                                    }
                                });
                            }
                        });
                    } else if (
                        key === sspConstants.applicantIdentity.sessionId
                    ) {
                        this.sessionID = innerObject[key];
                    }
                    if (
                        typeof innerObject[key] ===
                        sspConstants.applicantIdentity.object
                    ) {
                        if (
                            innerObject[key] !== undefined &&
                            innerObject[key] !== null
                        ) {
                            iterate(innerObject[key]);
                        }
                    }
                });
            };
            iterate(this.getQuestionsResult);

            this.challengeQuestions.forEach(questions => {
                this.selectedAnswers.set(questions.questionNumber, "");
            });
        } catch (error) {
            console.error("Error in Demo getting values", error);
        }
    };

    /**
     * @function - checkValidations.
     * @description - This Method checks for validations.
     */
    checkValidations = () => {
        try {
            let countObject = 0;
            this.challengeQuestions.forEach(choice => {
                if (choice.checked === false) {
                    this.showApplicationError = true;
                    countObject = countObject + 1;
                }
            });
            if (countObject === 0) {
                this.showApplicationError = false;
                this.showErrorToast = false;
            } else {
                this.showErrorToast = true;
            }
        } catch (error) {
            console.error("Error in checkValidations =>", error);
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method is used to get notified when toast hides.
     */
    handleHideToast = () => {
        try {
            this.showErrorToast = false;
        } catch (error) {
            console.error("Error in handleHideToast", error);
        }
    };

    /**
     * @function : handleHideToast
     * @description : This method gets the updated value.
     ** @param {*} event -  This parameter provides the updated value.
     */
    handleOptionChange = event => {
        try {
      for (let choice = 0; choice < this.challengeQuestions.length; choice++) {
        if (event.target.name === this.challengeQuestions[choice].question) {
          this.selectedAnswers.set(
            this.challengeQuestions[choice].questionNumber,
            event.target.value
          );
          this.challengeQuestions[choice].checked = true;
        }
      }
          
        } catch (error) {
            console.error("Error in handling option change", error);
        }
    };

    /**
     * @function : closeAdditionalVerification
     * @description : This method is used close the verification modal.
     */
    closeAdditionalVerification = () => {
        try {
            this.isVerification = false;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Household_Summary__c"
                },
                state: {
                    applicationId: this.parameters.applicationId,
                    mode: this.parameters.mode,
                    RIDP: "failed"
                }
            });
        } catch (error) {
            console.error("Error in closing Additional Verification modal");
        }
    };

    /**
     * @function : getQueryParameters
     * @description : This method is used get the URL parameters.
     */
    getQueryParameters () {
        let params = {};
        const search = location.search.substring(1);

        if (search) {
            params = JSON.parse(
                '{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}',
                (key, value) => (key === "" ? value : decodeURIComponent(value))
            );
        }

        return params;
    }

    /**
     * @function : handleExitButton
     * @description : This method is used for exit function.
     */
    handleExitButton = () => {
        try {
            deleteNavFlowRecords({
                applicationId: this.parameters.applicationId
            })
                .then(result => {
                    this[NavigationMixin.Navigate]({
                        type: "comm__namedPage",
                        attributes: {
                            name: "Contact_Information__c"
                        },
                        state: {
                            memberId: this.parameters.memberId,
                            applicationId: this.parameters.applicationId,
                            mode: this.parameters.mode
                        }
                    });
                })
                .catch(error => {
                    console.error(
                        " Error in deleteNavFlowRecords" +
                        JSON.stringify(error)
                    );
            });
        } catch (error) {
            console.error("Error in handleExitButton =>", error);
        }
    };

    /**
     * @function : handleNext
     * @description : This method is used for next function.
     */
    handleNext = () => {
        try {
            this.checkValidations();

            if (!this.showApplicationError) {
                this.postAnswersHandler();
            }
        } catch (error) {
            console.error("Error in handleExitButton =>", error);
        }
    };

    /**
     * @function : postAnswersHandler
     * @description : This method is used to call the post answers service.
     */
    postAnswersHandler () {
    this.showSpinner = true;
    const selectedValues = this.selectedAnswers;
    const mapValues = {};
    for (const [key, value] of selectedValues) {
      mapValues[key] = value;
    }
        postAnswers({
      mapQuestionAnswers: JSON.stringify(mapValues),
            userKOGID: this.memberData.userKOGID,
            SessionId: this.sessionID,
            memberId: this.parameters.memberId
        })
            .then(result => {
                if (result.bIsSuccess) {
          this.showSpinner = false;
                    this.postAnswersResponse = result.mapResponse;
          if (result.mapResponse.referenceNumber) {
            this.referenceNumber = result.mapResponse.referenceNumber;
            Object.keys(this.label).forEach(labelKey => {
              this.label[labelKey] = formatLabels(this.label[labelKey], [
                this.referenceNumber
              ]);
            });
            this.isVerification = true;
          } else {
                    this.updateApplicationStatusUnsubmittedHandler();

                     this.navigateToHHSummary();
          }
                } else {
          this.showSpinner = false;
                    this.isVerification = true;
                }
            })
            .catch(error => {
                console.error("CheckRIDP=>postAnswers is failed ", error);
            });
    }

    /**
     * @function : callMCICallout
     * @description : This method is used for the MCI call out.
     */
    callMCICallout () {
        createJSONWrapper({
            memberId: this.parameters.memberId,
            appId: this.parameters.applicationId,
            sMode: true,
            sPage: "RIDPPage"
        })
            .then(result => {
                if (result.bIsSuccess) {
                    this.finalProgramList = result.mapResponse.finalProgramList;
                    this.programRemoved = result.mapResponse.programRemoved;
                    if (
                        (!utility.isUndefinedOrNull(this.programRemoved) &&
                            !this.programRemoved) ||
                        (!utility.isUndefinedOrNull(this.finalProgramList) &&
                            !this.finalProgramList)
                    ) {
                        this.navigateToHHSummary();
                    }
                } else {
                    this.showSpinner = false;
                }
            })
            .catch(error => {
                console.error(
                    "@@sspIdentityDocumentUpload=>createJSONWrapper failed" +
                        JSON.stringify(error)
                );
            });
    }

    /**
     * @function : navigateToHHSummary
     * @description : This method is used to navigate to House hold summary screen.
     */
    navigateToHHSummary = () => {
        this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
            attributes: {
                name: "Household_Summary__c"
            },
            state: {
                applicationId: this.parameters.applicationId,
                mode: this.parameters.mode,
                RIDP: "success",
                individualId: this.memberData.individualId
            }
        });
    };

    /**
     * @function : closeError.
     * @description	: Method to close error modal.
     */
    closeError = () => {
        try {
            this.showErrorModal = false;
            this.showSpinner = false;
        } catch (error) {
            console.error(
                "Error in closeError:" + JSON.stringify(error.message)
            );
        }
    };
    updateApplicationStatusUnsubmittedHandler () {
        updateApplicationStatusUnsubmitted({
            applicationId: this.parameters.applicationId,
            memberId: this.parameters.memberId,
            sPage: "RIDPPage"
        })
            .then(result => {
                if (!result.bIsSuccess) {
                    console.error(
                        "updateApplicationStatusUnsubmitted Failure" +
                            JSON.stringify(result)
                    );
                } 
            })
            .catch(error => {
                console.error(
                    "updateApplicationStatusUnsubmitted Failed" +
                        JSON.stringify(error)
                );
            });
    }
}