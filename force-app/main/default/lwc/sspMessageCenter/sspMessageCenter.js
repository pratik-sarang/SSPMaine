/**
 * Component Name: sspMessageCenter.
 * Author: Chirag.
 * Description: Message Center  Parent Component.
 * Date: 7/1/2020.
 */
import { track } from "lwc";
import BaseNavFlowPage from "c/sspBaseNavFlowPage";
import initMessageCenter from "@salesforce/apex/SSP_MessageCenterCtrl.initMessageCenter";
import updateReadStatus from "@salesforce/apex/SSP_MessageCenterCtrl.updateReadStatus";
import sspMessageCenterHeading from "@salesforce/label/c.SSP_MessageCenterHeading";
import sspMessageCenterNoticesBraces from "@salesforce/label/c.SSP_MessageCenterNoticesBraces";
import sspMessageCenterMessagesBraces from "@salesforce/label/c.SSP_MessageCenterMessagesBraces";
import sspMessageCenterBracesClose from "@salesforce/label/c.SSP_MessageCenterBracesClose";
import sspMessageCenterResults from "@salesforce/label/c.SSP_MessageCenterResults";
import sspMessageCenterAnnouncements from "@salesforce/label/c.SSP_MessageCenterAnnouncements";
import sspMessageCenterToDos from "@salesforce/label/c.SSP_MessageCenterToDos";
import sspMessageCenterDetails from "@salesforce/label/c.SSP_Details";
import sspMessageCenterDueDate from "@salesforce/label/c.SSP_DueDate";
import sspMessageCenterCurrentlyNoData from "@salesforce/label/c.SSP_MessageCenterCurrentlyNoData";
export default class SspMessageCenter extends BaseNavFlowPage {
    @track blackVal = " ";
    @track data;
    @track messages;
    @track notices;
    @track messageTableData2 = [];
    @track messageTableData1 = [];
    @track messageTableDataMessages = [];
    @track messageTableDataNotices = [];
    @track showMessage = true;
    @track tabSelected = "message";
    @track callingFlag = "MessageCenter";
    @track messagesCount = 0;
    @track noticesCount = 0;
    @track updateReadStatusID = [];
    @track tableColumnsSearch = [
        { columnName: sspMessageCenterResults, isSort: false },
        { columnName: this.blackVal, isSort: false },
        { columnName: this.blackVal, isSort: false },
        { columnName: this.blackVal, isSort: false }
    ];
    @track tableColumns1;
    @track tableColumns2 = [
        { columnName: sspMessageCenterResults, isSort: false },
        { columnName: this.blackVal, isSort: false }
    ];
    @track tableColumnsMessages = [
        { columnName: sspMessageCenterDetails, isSort: false },
        { columnName: sspMessageCenterDueDate, isSort: true },
        { columnName: "", isSort: false },
        { columnName: "", isSort: false }
    ];
    @track isSearch = false;
    @track noSearchFound = false;
    @track noSearchFoundMessage = false;
    @track searchValue = "";
    @track showSpinner = true;
    @track tableColumns1 = [
        { columnName: sspMessageCenterDetails, isSort: false },
        { columnName: sspMessageCenterDueDate, isSort: true },
        { columnName: "", isSort: false },
        { columnName: "", isSort: false }
    ];
    customLabel = {
        sspMessageCenterHeading,
        sspMessageCenterNoticesBraces,
        sspMessageCenterMessagesBraces,
        sspMessageCenterBracesClose,
        sspMessageCenterAnnouncements,
        sspMessageCenterToDos,
        sspMessageCenterCurrentlyNoData
    };
    /**
     * @function : connectedCallback
     * @description : Called on page load to fetch the response.
     */
    connectedCallback () {
        try {
            this.showHome = true;
            this.initMessageCenter();
        } catch (error) {
            console.error(
                "Error in connectedCallback of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : initMessageCenter
     * @description : initialize data for message center home.
     */
    initMessageCenter () {
        initMessageCenter({ callingFlag: this.callingFlag })
            .then(response => {
                if (response.bIsSuccess && response.mapResponse) {
                    this.messages = JSON.stringify(
                        response.mapResponse.messages
                    );
                    this.notices = JSON.stringify(response.mapResponse.notices);
                    this.messageTableData2 = JSON.parse(this.notices);
                    this.messageTableData1 = JSON.parse(this.messages);
                    this.messageTableDataMessages = this.messageTableData1;
                    this.messageTableDataNotices = this.messageTableData2;
                    this.tableColumns1 = this.tableColumnsMessages;
                    this.messagesCount = JSON.stringify(
                        response.mapResponse.countOfUnreadMessages
                    );
                    this.noticesCount = JSON.stringify(
                        response.mapResponse.countOfUnreadNotices
                    );
                    if (this.messagesCount === 0 && this.noticesCount === 0) {
                        this.showMessage = false;
                    }
                    for (
                        this.i = 0;
                        this.i < this.messageTableDataMessages.length;
                        this.i++
                    ) {
                        if (
                            this.messageTableDataMessages[this.i]
                                .isNotification === true &&
                            this.messageTableDataMessages[this.i].readStatus ===
                                false
                        ) {
                            this.updateReadStatusID.push(
                                this.messageTableDataMessages[this.i].sfdcId
                            );
                        }
                    }

                    this.updateReadStatus();
                    this.showSpinner = false;
                } else {
                    this.showSpinner=false;
                    console.error(
                        "Error in initMessageCenter of sspMessageCenter," +
                            JSON.stringify(response)
                    );
                }
                window.document.body.style.overflow = "";
            })
            .catch(function (error) {
                window.document.body.style.overflow = "";
                this.showSpinner=false;
                console.error(
                    "Error in initMessageCenter of sspMessageCenter," +
                        JSON.stringify(error)
                );
            });
    }

    /**
     * @function : openSelected
     * @description : This method is used to open a selected tab.
     * @param {*} event - Returns a particular tab.
     */
    openSelected (event) {
        try {
            const tabs = this.template.querySelectorAll(".ssp-Tab");
            const tabsContent = this.template.querySelectorAll(
                ".ssp-TabsContent"
            );
            const count = this.template.querySelectorAll(".ssp-count");
            tabs.forEach(element => {
                element.classList.remove("ssp-active");
            });
            event.target.classList.add("ssp-active");
            for (let i = 0; i < tabs.length; i++) {
                if (tabs[i].classList.contains("ssp-active")) {
                    tabsContent[i].classList.add("ssp-show");
                    count[i].classList.add("ssp-color_blueAlpha");

                    if (i == 0) {
                        this.tabSelected = "notice";
                    } else {
                        this.tabSelected = "message";
                    }
                } else {
                    tabsContent[i].classList.remove("ssp-show");
                    count[i].classList.remove("ssp-color_blueAlpha");
                }
            }
        } catch (error) {
            console.error(
                "Error in openSelected of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : handleToDo
     * @description : handle Tag Search Todo.
     */
    handleToDo = () => {
        try {
            this.messageTableData1 = [];
            for (let i = 0; i < this.messageTableDataMessages.length; i++) {
                if (this.messageTableDataMessages[i].isToDo === true) {
                    this.messageTableData1.push(
                        this.messageTableDataMessages[i]
                    );
                }
            }
            if (this.messageTableData1.length === 0) {
                this.noSearchFoundMessage = true;
            }
            this.tableColumns1 = this.tableColumnsSearch;
            this.searchValue = "";
            this.searchValue = sspMessageCenterToDos;
        } catch (error) {
            console.error(
                "Error in handleToDo of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleAnnouncement.
     * @description : handle Tag Search Announcement.
     */
    handleAnnouncement = () => {
        try {
            this.messageTableData1 = [];
            for (let i = 0; i < this.messageTableDataMessages.length; i++) {
                if (this.messageTableDataMessages[i].isAnnouncement === true) {
                    this.messageTableData1.push(
                        this.messageTableDataMessages[i]
                    );
                }
            }
            if (this.messageTableData1.length === 0) {
                this.noSearchFoundMessage = true;
            }
            this.tableColumns1 = this.tableColumnsSearch;
            this.searchValue = "";
            this.searchValue = sspMessageCenterAnnouncements;
        } catch (error) {
            console.error(
                "Error in connectedCallback of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleSearchResults.
     * @description : handle the search .
     * @param {*} event - This event returns particular class.
     */
    handleSearchResults (event) {
        try {
            const searchValue = event.detail;
            this.messageTableData1 = [];

            for (let i = 0; i < this.messageTableDataMessages.length; i++) {
                if (
                    this.messageTableDataMessages[i].subject &&
                    this.messageTableDataMessages[i].subject
                        .toLowerCase()
                        .includes(searchValue.toLowerCase())
                ) {
                    this.messageTableData1.push(
                        this.messageTableDataMessages[i]
                    );
                }
            }
            this.tableColumns1 = this.tableColumnsSearch;
            this.messageTableData2 = [];

            for (let i = 0; i < this.messageTableDataNotices.length; i++) {
                if (
                    this.messageTableDataNotices[i].subject &&
                    this.messageTableDataNotices[i].subject
                        .toLowerCase()
                        .includes(searchValue.toLowerCase())
                ) {
                    this.messageTableData2.push(
                        this.messageTableDataNotices[i]
                    );
                }
            }
            if (this.messageTableData2.length === 0) {
                this.noSearchFound = true;
            }
            if (this.messageTableData1.length === 0) {
                this.noSearchFoundMessage = true;
            }
            this.isSearch = true;
        } catch (error) {
            console.error(
                "Error in handleSearchResult of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : handleEmpty.
     * @description : it empty the search bar whenever it click onBlur.
     */
    handleEmpty = () => {
        try {
            this.messageTableData1 = this.messageTableDataMessages;
            this.messageTableData2 = this.messageTableDataNotices;
            this.isSearch = false;
            this.noSearchFound = false;
            this.noSearchFoundMessage = false;
            this.tableColumns1 = this.tableColumnsMessages;
        } catch (error) {
            console.error(
                "Error in handleEmpty of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleMessageRead.
     * @description : handle the Read Status of Message .
     * @param {*} event - This event returns particular class.
     */
    handleMessageRead = event => {
        try {
            this.updateReadStatusID = [];
            this.buttonId = event.detail;
            for (
                this.i = 0;
                this.i < this.messageTableDataMessages.length;
                this.i++
            ) {
                if (
                    (this.messageTableDataMessages[this.i].isNotification ===
                        true &&
                        this.messageTableDataMessages[this.i].readStatus ===
                            false) ||
                    (this.messageTableDataMessages[this.i].sfdcId ===
                        this.buttonId &&
                        this.messageTableDataMessages[this.i].readStatus ===
                            false)
                ) {
                    this.updateReadStatusID.push(
                        this.messageTableDataMessages[this.i].sfdcId
                    );
                }
            }
            if (this.updateReadStatusID.length > 0) {
                this.updateReadStatus();
                this.messagesCount = this.messagesCount - 1;
            }
        } catch (error) {
            console.error(
                "Error in handleMessageRead of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleNoticeRead.
     * @description : handle the Read Status of Notice .
     * @param {*} event - This event returns particular class.
     */
    handleNoticeRead = event => {
        try {
            this.noticeId = event.detail;
            this.updateReadStatusID.push(this.noticeId);
            this.updateReadStatus();
            this.noticesCount = this.noticesCount - 1;
            this.initMessageCenter();
            this.messageTableData2 = [];
        } catch (error) {
            console.error(
                "Error in handleNoticeRead of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : handleReadStatus.
     * @description : this update the read status .
     */
    updateReadStatus = () => {
        try {
            updateReadStatus({
                notificationId: JSON.stringify(this.updateReadStatusID)
            });
        } catch (error) {
            console.error(
                "Error in updateReadStatus of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : selectNoticeTab.
     * @description : this function Update the Notice tab.
     */
    selectNoticeTab = () => {
        try {
            this.template.querySelector(".ssp-notice-tab").click();
        } catch (error) {
            console.error(
                "Error in selectNoticeTab of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : selectNoticeTab.
     * @description : this function Update the Notice tab.
     */
    updateMessage = () => {
        try {
            this.initMessageCenter();
        } catch (error) {
            console.error(
                "Error in updateMessage of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    };

    /**
     * @function : sortByKey.
     * @description : handle the Sort of Message .
     * @param {*} event - This event returns particular class.
     */
    sortByKey (event) {
        try {
            const order = event.detail;
            const that = this;
            const tableList = Array.from(this.messageTableDataMessages);
            if (order === "asc") {
                tableList.sort(function (a, b) {
                    if (a.isToDo != true || b.isToDo != true) {
                        return 0;
                    }
                    let x = a.dueDate;
                    let y = b.dueDate;
                    x = that.convertDateToTimestamp(x);
                    y = that.convertDateToTimestamp(y);
                    return x < y ? -1 : x > y ? 1 : 0;
                });
            }
            if (order === "desc") {
                tableList.sort(function (a, b) {
                    if (a.isToDo != true || b.isToDo != true) {
                        return 0;
                    }
                    let x = a.dueDate;
                    let y = b.dueDate;
                    x = that.convertDateToTimestamp(x);
                    y = that.convertDateToTimestamp(y);
                    return x > y ? -1 : x < y ? 1 : 0;
                });
            }

            this.messageTableData1 = tableList;
        } catch (error) {
            console.error(
                "Error in sortByKey of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    }

    /**
     * @function : convertDateToTimestamp.
     * @description : handle the Read Status of Notice .
     * @param {*} date - This event returns timestamp.
     */
    convertDateToTimestamp (date) {
        try {
            const dateNew = date.split("/");
            const timestamp = new Date(
                dateNew[0] + "-" + dateNew[1] + "-" + dateNew[2]
            ).getTime();
            return timestamp;
        } catch (error) {
            console.error(
                "Error in convertDateToTimestamp of sspMessageCenter" +
                    JSON.stringify(error.message)
            );
        }
    }
}
