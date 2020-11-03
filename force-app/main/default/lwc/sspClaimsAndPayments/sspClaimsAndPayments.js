/**
 * Component Name: sspClaimsAndPayments.
 * Author: Venkata Ranga Babu, Ajay.
 * Description: Component for Claims and Payments Screen.
 */
import { LightningElement, track } from "lwc";
import sspClaimsAndPayments from "@salesforce/label/c.SSP_ClaimsAndPayments";
import payOnlineInstruction from "@salesforce/label/c.SSP_PayOnlineInstruction1";
import repaymentInstruction from "@salesforce/label/c.SSP_RepaymentInstruction";
import amountOwedInstruction from "@salesforce/label/c.SSP_AmountOwedInstruction";
import repaymentContactNumber from "@salesforce/label/c.SSP_ReportContactNumber";
import amountOwed from "@salesforce/label/c.SSP_AmountOwed";
import ID from "@salesforce/label/c.SSP_ID";
import dueDate from "@salesforce/label/c.SSP_DueDate";
import currentAmountOwed from "@salesforce/label/c.SSP_CurrentAmountOwed";
import payImmediatelyAlert from "@salesforce/label/c.SSP_PayImmediatelyAlert";
import payNow from "@salesforce/label/c.SSP_PayNow";
import sspChoosePaymentAmount from "@salesforce/label/c.SSP_ChoosePaymentAmount";
import sspSelectIfYouWouldLikeToPay from "@salesforce/label/c.SSP_SelectIfYouWouldLikeToPayYourCurrentTotalAmountOwedOrTheRepayment";
import sspRepaymentPlanAmount from "@salesforce/label/c.SSP_RepaymentPlanAmount";
import sspRemainingAmountOwed from "@salesforce/label/c.SSP_RemainingAmountOwed";
import sspPleaseHaveYourBankAccountInformation from "@salesforce/label/c.SSP_PleaseHaveYourBankAccountOrCreditCardInformationReady";
import sspTotalAmount from "@salesforce/label/c.SSP_TotalAmount";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspCancel from "@salesforce/label/c.sspCancel";
import sspClickToVisitKentucky from "@salesforce/label/c.SSP_ClickToVisitKentuckyInteractiveToMakeClaimPayment";
import sspClickToReturn from "@salesforce/label/c.SSP_ClickToReturnToClaimsPaymentsScreen";
import getIndividualsIds from "@salesforce/apex/SSP_ClaimsAndPayments.getIndividualsIds";
import getScreenData from "@salesforce/apex/SSP_ClaimsAndPayments.getScreenData";
import prepareCart from "@salesforce/apex/SSP_ClaimsAndPayments.getPaymentURL";
import getPaymentStatus from "@salesforce/apex/SSP_ClaimsAndPayments.getPaymentStatus";
import sspConstants from "c/sspConstants"
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import delinquentLabel from "@salesforce/label/c.SSP_Delinquent";
import unpaidLabel from "@salesforce/label/c.SSP_Unpaid";
import paymentProcessingLabel from "@salesforce/label/c.SSP_ProcessingPayment";
import totalAmountOwedLabel from "@salesforce/label/c.SSP_TotalAmountOwed";
import repaymentAmountLabel from "@salesforce/label/c.SSP_RepaymentAmountOwed";
import childCareLabel from "@salesforce/label/c.sspChildCare";
import medicaidLabel from "@salesforce/label/c.sspMedicaid";
import paymentProcessingToast from "@salesforce/label/c.SSP_PaymentProcessing";
import paymentSuccessfulToast from "@salesforce/label/c.SSP_PaymentSuccessful";
import paymentFailedToast from "@salesforce/label/c.SSP_PaymentFailed";
import explicitCallTimeout from "@salesforce/label/c.SSP_PaymentStatusCallbackTimeout";
import pollInterval from "@salesforce/label/c.SSP_PaymentStatusPollInterval";
import stateSupplementation from "@salesforce/label/c.SSP_StateSupplementation";
import snapLabel from "@salesforce/label/c.SSP_SNAPLabel";
import kTapLabel from "@salesforce/label/c.SSP_KTAPLabel";
import kihippLabel from "@salesforce/label/c.SSP_KIHIPPLabel";
import kinshipLabel from "@salesforce/label/c.SSP_KinshipLabel";

export default class SspClaimsAndPayments extends LightningElement {
    @track reviewIcon = sspIcons + sspConstants.url.needsReviewIcon;
    @track isPaymentModal = false;
    @track showSpinner = false;
    @track showErrorModal = false;
    @track claimRecordsByProgram = [];
    @track selectedAmountType = "CurrentAmountOwed";
    @track notAccessible = false;
    @track isNotAllowedToPay = false;
    @track amountTypeList = [];
    @track showToastFlag = false;
    @track reference = this;
    toastType = "positive";
    label = {
        sspClaimsAndPayments,
        payOnlineInstruction,
        repaymentInstruction,
        amountOwedInstruction,
        repaymentContactNumber,
        amountOwed,
        ID,
        dueDate,
        currentAmountOwed,
        payImmediatelyAlert,
        payNow,
        sspChoosePaymentAmount,
        sspSelectIfYouWouldLikeToPay,
        sspRepaymentPlanAmount,
        sspRemainingAmountOwed,
        sspPleaseHaveYourBankAccountInformation,
        sspTotalAmount,
        sspNext,
        sspCancel,
        sspClickToVisitKentucky,
        sspClickToReturn
    }

    /**
     * @function phoneHref.
     * @description Method to get the href for the phone field.
     */
    get phoneHref () {
        return `tel:${this.label.repaymentContactNumber}`;
    }

    /**
     * @function remainingAmount
     * @description Returns the remaining amount.
     */
    get remainingAmount () {
        try {
            const totalAmount = this.claimRecordsMap[this.selectedClaim].CurrentAmountOwed;
            const payableAmount = this.claimRecordsMap[this.selectedClaim][this.selectedAmountType];
            return totalAmount - payableAmount;
        } catch (error) {
            console.error(error);
            return null;
        }
    }

    /**
     * @function connectedCallback
     * @description Fetches the data from RSSPDC through apex.
     */
    async connectedCallback () {
        try {
            this.connected = true;
            this.showSpinner = true;
            this.pollingMap = {};
            const individualsIdsResponse = await getIndividualsIds();
            const searchParams = new URL(window.location.href).searchParams;
            await getScreenData({
                individualIds: individualsIdsResponse.mapResponse.individuals,
                cartId: searchParams.get("cartid"),
                status: searchParams.get("status")
            }).then(this.initPage);
            this.showSpinner = false;
            this.makeExplicitCall = false;
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            this.timer = setTimeout(() => {
                this.makeExplicitCall = true;
            }, +explicitCallTimeout);
        }
        catch(error) {
            this.showSpinner = false;
            this.showErrorModal = true;
            console.error("Error in connectedCallback", error);
        }
    }
    /**
     * @function disconnectedCallback
     * @description Sets the flag to stop polling after disconnected.
     */
    disconnectedCallback () {
        try {
            this.connected = false;
            clearTimeout(this.timer);
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function initPage
     * @description Prepares the data to be rendered on the page.
     * @param {object} response - Raw response received from server.
     */
    initPage = (response) => {
        try {
            if(!response.bIsSuccess || !response.mapResponse) {
                console.error(JSON.parse(JSON.stringify(response)));
                this.showErrorModal = true;
                return;
            }
            this.notAccessible = response.mapResponse.isNotAccessible;
            this.isNotAllowedToPay = !response.mapResponse.isAllowedToPay;
            this.isReadOnly = response.mapResponse.isReadOnly;

            if(this.notAccessible) {
                return;
            }
            if (response.mapResponse.hasOwnProperty("endPoint") && response.mapResponse.hasOwnProperty("encryptedToken")) {
                this.showSpinner = false;
                const portalUrl = new URL(response.mapResponse.endPoint);
                portalUrl.searchParams.append("EncryptedData",response.mapResponse.encryptedToken);
                window.open(portalUrl.href);
                return;
            }

            const displayValueMap = {
                "UN": unpaidLabel,
                "DL": delinquentLabel,
                "PP": paymentProcessingLabel
            };

            const statusClass = {
                "UN": "ssp-fontFamily_popinBold ssp-color_blueAlpha",
                "DL": "ssp-fontFamily_popinBold ssp-color_redAlpha",
                "PP": "ssp-fontFamily_popinBold ssp-color_blueAlpha"
            };

            const amountClass = {
                "UN": "ssp-currentAmountOwned ssp-fontFamily_popinBold ssp-color_blueAlpha",
                "DL": "ssp-currentAmountOwned ssp-fontFamily_popinBold ssp-color_redAlpha",
                "PP": "ssp-currentAmountOwned ssp-fontFamily_popinBold ssp-color_blueAlpha"
            };

            const programLabelMap = {
                "CC": childCareLabel,
                "SN": snapLabel,
                "KT": kTapLabel,
                "MA": medicaidLabel,
                "SS": stateSupplementation,
                "KP": kihippLabel,
                "DS": "DSNAP",
                "KC": kinshipLabel
            }
            
            const sortOrder = {
                "DL": 1,
                "UN": 2,
                "PP": 3
            };

            const dateRegex = /(\d+)-(\d+)-(\d+)/g;
            if(!Array.isArray(response.mapResponse.records)) {
                return;
            }
            const rawClaimsData = response.mapResponse.records
                .map(claim => ({
                    ...claim,
                    CurrentAmountOwed: claim.CurrentAmountOwed__c,
                    RepaymentAmount: claim.RepaymentAmount__c,
                    DueDate: claim.DueDate__c && claim.DueDate__c.replace(dateRegex, "$2/$3/$1"),
                    statusDisplay: displayValueMap[claim.ClaimStatus__c],
                    statusClass: statusClass[claim.ClaimStatus__c],
                    amountClass: amountClass[claim.ClaimStatus__c],
                    showWarning: claim.ClaimStatus__c === "DL",
                    paymentDisabled: claim.ClaimStatus__c === "PP" || this.isReadOnly
                }));

            this.claimRecordsMap = rawClaimsData.reduce((map, claim) => {
                map[claim.ClaimNumber__c] = claim;
                return map;
            }, {});

            const claimsGroupedByProgram = rawClaimsData.reduce((map, claim) => {
                const program = claim.ProgramCode__c || "NA";
                map[program] = map[program] || [];
                map[program].push(claim);
                return map;
            }, {});

            const claimRecords = Object.keys(claimsGroupedByProgram).map(key => {
                const claims = JSON.parse(JSON.stringify(claimsGroupedByProgram[key]));
                return {
                    program: key,
                    programDisplay: programLabelMap[key] || key,
                    claims: claims.sort((a, b) => sortOrder[a.ClaimStatus__c] - sortOrder[b.ClaimStatus__c] || +a.ClaimNumber__c -+b.ClaimNumber__c)
                };
            });
            this.claimRecordsByProgram = claimRecords;
            const processingPayments = rawClaimsData
                .filter(claim => claim.ClaimStatus__c === "PP")
                .map(claim => {
                    if(!this.pollingMap[claim.ClaimNumber__c]) {
                        this.pollingMap[claim.ClaimNumber__c] = new Promise((resolve, reject) => this.pollPaymentStatus(claim.ClaimNumber__c, resolve, reject))
                    }
                    return this.pollingMap[claim.ClaimNumber__c];
                });
            if(processingPayments.length > 0) {
                this.showToast("positive", paymentProcessingToast);
            }
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in initPage", error);
            return null;
        }
    }

    /**
     * @function pollPaymentStatus
     * @description Polls for the payment status.
     * @param {string} claimNumber - Claim Number.
     * @param {Function} resolve - Resolve callback.
     * @param {Function} reject - Reject callback.
     */
    pollPaymentStatus = (claimNumber, resolve, reject) => {
        getPaymentStatus({
            claimNumber,
            makeExplicitCall: this.makeExplicitCall
        })
            .then(response => {
                try {
                    if(!this.connected) {
                        return resolve("Disconnected!");
                    }
                    if(!response.bIsSuccess || !response.mapResponse) {
                        console.error(claimNumber, JSON.parse(JSON.stringify(response)));
                        return reject(response);
                    }
                    if(response.mapResponse.status) {
                        return getScreenData()
                            .then(this.initPage)
                            .then(() => {
                                if(response.mapResponse.status.toUpperCase() === "PAID") {
                                    this.showToast("positive", paymentSuccessfulToast);
                                }
                                else {
                                    this.showToast("negative", paymentFailedToast);
                                }
                            });
                    }
                    else {
                        // eslint-disable-next-line @lwc/lwc/no-async-operation
                        setTimeout(
                            () => this.pollPaymentStatus(claimNumber, resolve, reject),
                            +pollInterval
                        );
                    }
                } catch (error) {
                    console.error(error);
                }
            });
    }

    /**
     * @function openPaymentModal
     * @description Prepares the data for the payment modal and opens it.
     * @param {object} event - Event object.
     */
    openPaymentModal = (event) => {
        try {
            if(this.isReadOnly) {
                return;
            }
            const selectedClaim = event.target.dataset.claimNumber;
            const totalAmount = this.claimRecordsMap[selectedClaim].CurrentAmountOwed;
            const repaymentAmount = this.claimRecordsMap[selectedClaim].RepaymentAmount;
            const amountTypeList = [];
            amountTypeList.push({
                label: totalAmountOwedLabel.replace(/\{0\}/g, totalAmount),
                value: "CurrentAmountOwed"
            });
            
            this.selectedClaim = selectedClaim;
            if(repaymentAmount !== undefined && repaymentAmount !== null) {
                amountTypeList.push({
                    label: repaymentAmountLabel.replace(/\{0\}/g, repaymentAmount),
                    value: "RepaymentAmount"
                });
                this.selectedAmountType = null;
            }
            this.selectedAmountType = "CurrentAmountOwed";
            this.amountTypeList = amountTypeList;
            this.isPaymentModal = true;
        }
        catch(error) {
            this.showErrorModal = true;
            console.error("Error in openPaymentModal", error);
        }
    }

    /**
     * @function handleAmountChange
     * @description Handles amount selection on payment modal.
     * @param {object} event - Event object.
     */
    handleAmountChange = (event) => {
        try {
            this.selectedAmountType = event.target.value;
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function navigateToPaymentPage
     * @description Prepares the cart through a service call and redirects to payment page.
     * @param {object} event - Event object.
     */
    navigateToPaymentPage = async (event) => {
        try {
            if(this.isReadOnly || this.isNotAllowedToPay) {
                return;
            }
            this.isPaymentModal = false;
            this.showSpinner = true;
            const amount = this.claimRecordsMap[this.selectedClaim][this.selectedAmountType];
            const claimNumber = this.claimRecordsMap[this.selectedClaim].ClaimNumber__c;
            const redirectUrl = window.location.origin + window.location[sspConstants.verticalNavigation.pathName];
            const cartInfo = await prepareCart({
                amount,
                claimNumber,
                redirectUrl
            });
            if(cartInfo.bIsSuccess && cartInfo.mapResponse && cartInfo.mapResponse.data) {
                const paymentURL = cartInfo.mapResponse.data.PaymentURL;
                if(!event.ctrlKey) {
                    window.location.replace(paymentURL);
                }
                else {
                    window.open(paymentURL);
                }
            }
            else {
                this.showSpinner = false;
                this.showErrorModal = true;
                console.error("Error preparing cart:", JSON.parse(JSON.stringify(cartInfo)));
            }
        }
        catch(error) {
            this.showSpinner = false;
            this.showErrorModal = true;
            console.error("Error in navigateToPaymentPage", error);
        }
    }

    /**
     * @function closePaymentModal
     * @description Handles payment modal closure.
     */
    closePaymentModal = () => {
        try {
            this.isPaymentModal = false;
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function closeErrorModal
     * @description Handles error modal closure.
     */
    closeErrorModal = () => {
        try {
            this.showErrorModal = false;
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function hideToast
     * @description Sets toast to null.
     */
    hideToast = () => {
        try {
            this.toast = null;
            this.showToastFlag = false;
        } catch (error) {
            console.error(error);
        }
    }

    /**
     * @function showToast
     * @description Shows the toast message.
     * @param {string} type - Type of toast - "positive" / "negative".
     * @param {string} message - Toast Message.
     */
    showToast = (type, message) => {
        try {
            this.toastType = type;
            this.toastMessage = message;
            this.showToastFlag = true;
        } catch (error) {
            console.error(error);
        }
    }
}