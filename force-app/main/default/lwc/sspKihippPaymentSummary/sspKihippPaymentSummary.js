import { track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import sspBackToBenefitDetails from "@salesforce/label/c.sspBackToBenefitDetails";
import sspKIHIPPPaymentSummary from "@salesforce/label/c.SSP_KIHIPPPaymentSummary";
import sspFilter from "@salesforce/label/c.SSP_Filter";
import sspSortBy from "@salesforce/label/c.SSP_SortBy";
import sspDateNewest from "@salesforce/label/c.sspDateNewest";
import sspDateOldest from "@salesforce/label/c.sspDateOldest";
import sspAmountHighest from "@salesforce/label/c.sspAmountHighest";
import sspAmountLowest from "@salesforce/label/c.sspAmountLowest";
import sspTimePeriod from "@salesforce/label/c.sspTimePeriod";
import sspStartDate from "@salesforce/label/c.SSP_StartDate";
import sspEndDate from "@salesforce/label/c.SSP_EndDate";
import sspPolicyHolder from "@salesforce/label/c.SSP_HealthCareEnrollPolicyHolder";
import sspReimbursedOn from "@salesforce/label/c.sspReimbursedOn";
import sspViewMore from "@salesforce/label/c.SSP_ViewMore";
import sspViewResults from "@salesforce/label/c.SSP_ViewResults";
import sspResetFilter from "@salesforce/label/c.SSP_ResetFilter";
import sspDollarSign from "@salesforce/label/c.sspDollarSign";

import sspUtility from "c/sspUtility";
import fetchPayments from "@salesforce/apex/SSP_KIHIPPPaymentSummaryController.fetchPaymentSummary";
import fetchMoreRecords from "@salesforce/apex/SSP_KIHIPPPaymentSummaryController.fetchMoreRecords";

export default class SspKihippPaymentSummary extends NavigationMixin(BaseNavFlowPage) {
    label = {
        sspBackToBenefitDetails,
        sspKIHIPPPaymentSummary,
        sspFilter,
        sspSortBy,
        sspDateNewest,
        sspDateOldest,
        sspAmountHighest,
        sspAmountLowest,
        sspTimePeriod,
        sspStartDate,
        sspEndDate,
        sspPolicyHolder,
        sspReimbursedOn,
        sspViewMore,
        sspViewResults,
        sspResetFilter,
        sspDollarSign
    };

    @track openModel = false;
    @track reference = this;
    @track dataCard = [];
    @track dataCardFiltered = [];
    @track masterList = [];
    @track masterCardsListTotal;

    @track benefitMonth;

    @track filterOptions = [
        { label: sspDateNewest, value: "benefitMonth_date-desc" },
        { label: sspDateOldest, value: "benefitMonth_date" },
        { label: sspAmountHighest, value: "reimbursedAmount-desc" },
        { label: sspAmountLowest, value: "reimbursedAmount" }
    ];

    @track policyHolder = [];
    @track selectedPolicyHolder = [];
    @track paymentCard = [];
    @track filterStartDate;
    @track filterEndDate;

    @track showSpinner = false;
    @track showScreen = false;
    @track showAccessDenied = false;
    @track resultObj;
    @track fieldPriority = [];
    @track sortByField = "";
    @track showViewMore = false;
    //@track maxResults = 2;
    @track currentResults;
    @track callBackData;
    @track masterCardsList = [];

    
    connectedCallback () {
        this.fetchDetails();
    }

    fetchDetails () {
        try {
            this.showSpinner = true;
            const url = new URL(window.location.href);
            this.individualId = url.searchParams.get("individualId");
            fetchPayments({
                individualId: this.individualId //"999015984"
            })
                .then(result => {
                    this.callBackData =  result.mapResponse;
                    this.handleCallbackData();
                })
                .catch(error => {
                    console.error("Error : " + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error in connectedCallBack:" + JSON.stringify(error)
            );
        }
    }

    handleCallbackData () {
        const parsedData = this.callBackData;
                    if (
                        !sspUtility.isUndefinedOrNull(parsedData) &&
                        parsedData.hasOwnProperty("ERROR")
                    ) {
                        console.error(
                            "failed in loading dashboard" +
                                JSON.stringify(parsedData.ERROR)
                        );
                    } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                        if (parsedData.hasOwnProperty("summaryWrapper")) {
                            this.resultObj = JSON.parse(
                                parsedData.summaryWrapper
                            );
                            this.dataCard = [];
                            this.dataCardFiltered = [];
                            this.masterList = [];
                            this.policyHolder = [];
                            this.masterCardsList = [];
                            
                            for (let i = 0; i < this.resultObj.length; i++) {
                                this.dataCard.push(
                                    JSON.parse(
                                        JSON.stringify(this.resultObj[i])
                                    )
                                );
                                this.dataCardFiltered.push(
                                    JSON.parse(
                                        JSON.stringify(this.resultObj[i])
                                    )
                                );
                                this.masterList.push(
                                    JSON.parse(
                                        JSON.stringify(this.resultObj[i])
                                    )
                                );

                                this.policyHolder.push({
                                    label: this.resultObj[i].userName,
                                    value: this.resultObj[i].userName
                                });
                                for (
                                    let j = 0;
                                    j < this.resultObj[i].userCard.length;
                                    j++
                                ) {
                                    const card = this.resultObj[i].userCard[j];

                                    this.masterCardsList.push(card);
                                }
                            }
                        }
                    }
                    
                    this.sortByField = "benefitMonth_date-desc";
                    this.fieldPriority = [];
                    this.fieldPriority.push(
                        this.sortByField.indexOf("-desc") > 1
                            ? this.sortByField.substr(
                                  0,
                                  this.sortByField.indexOf("-desc")
                              )
                            : this.sortByField
                    );
                    this.sortDataForFilter();
                    this.sortDataForFilterMaster();
                    if (
                        parsedData.hasOwnProperty("showMore") &&
                        parsedData.showMore
                    ) {
                        this.showViewMore = true;
                    } else {
                        this.showViewMore = false;
                    }
                    
                    if (
                        parsedData.hasOwnProperty("showScreen") &&
                        parsedData.showScreen
                    ) {
                        this.showScreen = true;
                    } 
                    //remove as a part of defect 70
                    /*else {
                        this.showAccessDenied = true;
                    }*/
                    if(parsedData.hasOwnProperty("masterCards")){
                        this.masterCardsListTotal = parsedData.masterCards;
                    }
                    
                    this.resetFilters();
                    this.showSpinner = false;
    }
    /**
     * @function : applyFilters
     * @description : Function to apply filters.
     */
    applyFilters () {
        

        //const temp = [];
        //temp = this.dataCard;
        this.dataCard = JSON.parse(JSON.stringify(this.masterList));
        this.dataCardFiltered = [];
        //Apply policy holder filter, if any
        if (this.selectedPolicyHolder.length > 0) {
            for (let i = 0; i < this.dataCard.length; i++) {
                if (
                    this.selectedPolicyHolder.includes(
                        this.dataCard[i].userName
                    )
                ) {
                    this.dataCardFiltered.push(this.dataCard[i]);
                }
            }
        } else {
            this.dataCardFiltered = JSON.parse(JSON.stringify(this.dataCard));
        }

        this.applyDateFilter();
        this.sortDataForFilter();

        this.openModel = false;
        
    }

    applyDateFilter () {
        //apply date filters, if any
        if (this.filterStartDate || this.filterEndDate) {
            const filterStart = new Date(this.filterStartDate);
            const filterEnd = new Date(this.filterEndDate);
            let tempUserCard = [];
            for (let i = 0; i < this.dataCardFiltered.length; i++) {
                const card = this.dataCardFiltered[i];
                tempUserCard = JSON.parse(JSON.stringify([]));
                for (let j = 0; j < card.userCard.length; j++) {
                    const cardDate = new Date(card.userCard[j].reimbursedDate);
                    if (
                        (this.filterStartDate &&
                            filterStart <= cardDate &&
                            !this.filterEndDate) ||
                        (this.filterEndDate &&
                            filterEnd >= cardDate &&
                            !this.filterStartDate) ||
                        (this.filterStartDate &&
                            this.filterEndDate &&
                            filterStart <= cardDate &&
                            filterEnd >= cardDate)
                    ) {
                        tempUserCard.push(
                            JSON.parse(JSON.stringify(card.userCard[j]))
                        );
                    }
                }

                this.dataCardFiltered[i].userCard = JSON.parse(
                    JSON.stringify(tempUserCard)
                );
            }
        }
    }
    /**
     * @function : resetFilters
     * @description : Function to reset filters.
     */
    resetFilters () {
        this.selectedPolicyHolder = [];
        this.filterStartDate = null;
        this.filterEndDate = null;
        this.dataCardFiltered = [];
        this.sortByField = "benefitMonth_date-desc";

        this.dataCardFiltered = JSON.parse(JSON.stringify(this.masterList));
        this.openModel = false;
    }

    handleFilterChange (event) {
        this.selectedPolicyHolder = event.detail.value;
        
    }

    updateStartDate (event) {
        this.filterStartDate = event.detail.value;
        
    }

    updateEndDate (event) {
        this.filterEndDate = event.detail.value;
        
    }

    openModal () {
        this.openModel = true;
    }

    /**
     * @function : handleProp
     * @description : This used to close Modal.
     */
    handleProp () {
        this.openModel = false;
        this.fireEvent();
    }

    handleSortChange (event) {
        this.sortByField = event.detail.value;
        this.fieldPriority = [];
        //this.fieldPriority.push("reimbursedAmount");

        this.fieldPriority.push(
            this.sortByField.indexOf("-desc") > 1
                ? this.sortByField.substr(0, this.sortByField.indexOf("-desc"))
                : this.sortByField
        );
        
    }

    /**
     * @function : sortDataForFilter
     * @description : This function evaluates the sorting criteria and filter criteria.
     */
    sortDataForFilter () {
        
        for (let i = 0; i < this.dataCardFiltered.length; i++) {
            this.dataCardFiltered[i].userCard.sort(
                this.calculateSortOrder.bind(this)
            );
        }
    }

    sortDataForFilterMaster () {
        for (let i = 0; i < this.masterList.length; i++) {
            this.masterList[i].userCard.sort(
                this.calculateSortOrder.bind(this)
            );
        }
    }
    
    /**
     * @function : calculateSortOrder
     * @description : This function evaluates and sort the data as per the criteria.
     * @param {object} a - The nth index in array.
     * @param {object} b - The nth + 1 element in the array.
     */
    calculateSortOrder = (a, b) => {
        for (let i = 0; i < this.fieldPriority.length; i++) {
            if (
                a[this.fieldPriority[i]] === null ||
                a[this.fieldPriority[i]] === ""
            ) {
                return 1;
            } else if (
                b[this.fieldPriority[i]] === null ||
                b[this.fieldPriority[i]] === ""
            ) {
                return -1;
            } else if (
                (a[this.fieldPriority[i]] === null &&
                    b[this.fieldPriority[i]] === null) ||
                (a[this.fieldPriority[i]] === "" &&
                    b[this.fieldPriority[i]] === "")
            ) {
                return 0;
            } else if (a[this.fieldPriority[i]] > b[this.fieldPriority[i]]) {
                return this.sortByField.includes("-desc") ? -1 : 1;
            } else if (a[this.fieldPriority[i]] < b[this.fieldPriority[i]]) {
                return this.sortByField.includes("-desc") ? 1 : -1;
            }
        }
        return 0;
    };

    handleViewMoreClick () {
        
        try {
            this.showSpinner = true;
            const offsetVal = this.masterCardsList.length;
            
            fetchMoreRecords({
                individualId: this.individualId,
                offset: offsetVal,
                lstCards: this.masterCardsListTotal
            })
                .then(result => {
                    this.callBackData =  result.mapResponse;
                    this.handleCallbackData();
                })
                .catch(error => {
                    console.error("Error : " + JSON.stringify(error));
                });
        } catch (error) {
            console.error(
                "Error in connectedCallBack:" + JSON.stringify(error)
            );
        }

    }
    /**
   * @function - backToBenefits.
   * @description - Method to navigate to benefits screen.
   * @param  {object} event - Fired on key down or click of the link.
   */
  backToBenefits = (event) =>{
    try{
        if (event.keyCode === 13 || event.type === "click") {
            this.showSpinner = true;
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "Benefits_Page__c"
                }
            });
        } 
    }
    catch(error){
        console.error("Error occurred in backToBenefits",error);
    }
}
}