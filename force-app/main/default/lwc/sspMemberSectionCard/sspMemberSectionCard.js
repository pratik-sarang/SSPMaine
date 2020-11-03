import { LightningElement, api, track } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import startButton from "@salesforce/label/c.SSP_StartButton";
import editButton from "@salesforce/label/c.SSP_EditButton";
import continueButton from "@salesforce/label/c.SSP_ContinueButton";
import notStartedLabel from "@salesforce/label/c.SSP_NotStarted";
import reviewRequiredLabel from "@salesforce/label/c.sspReviewRequired";
import pendingLabel from "@salesforce/label/c.SSP_Pending";
import completedLabel from "@salesforce/label/c.SSP_Completed";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import ProgressIcon from "@salesforce/label/c.SSP_ProgressIcon";
import sspView from "@salesforce/label/c.SSP_View";
import apConstants from "c/sspConstants";

const status = {
    REVIEW_REQUIRED: reviewRequiredLabel,
    NOT_STARTED: notStartedLabel,
    PENDING: pendingLabel,
    COMPLETED: completedLabel
};
const cssStyle = "ssp-ReviewVariationCardBlack ssp-fontFamily_popinBold";
const IS_START = "IsStart__c";
const IS_EDIT = "IsEdit__c";
const IS_CONTINUE = "IsContinue__c";

const defaultStartStatus = {
    [IS_START]: true
};

const buttonStyle = "ssp-cardItemsButton";
export default class SspMemberSectionCard extends LightningElement {
    @api disabled = false;
    @api cardTitle;
    //Shikha - defect 379955
    @api readOnlyUser = false;  
    @api
    get newMemberFlow () {
        return this._newMemberFlow;
    }
    set newMemberFlow (value) {
        if (this._newMemberFlow !== value) {
            this._newMemberFlow = value;
            this.initTile();
        }
    }

    @api
    get flowStatus () {
        return this._flowData || {};
    }
    set flowStatus (value) {
        this._flowData = value;
        this.initTile();
    }

    @api
    get section () {
        return this._sectionData || {};
    }
    set section (value) {
        this._sectionData = value;
        this.initTile();
    }

    @track tileAction = {};
    @track memberItems;
    @track _isReviewRequired;

    redNextIcon = `${sspIcons}${apConstants.url.redNextIcon}`;
    blueNextIcon = `${sspIcons}${apConstants.url.blueNextIcon}`;
    darkNextIcon = `${sspIcons}${apConstants.url.darkNextIcon}`;
    notStartedNextIcon = `${sspIcons}${apConstants.url.notStartedNextIcon}`;
    needsReviewIconUrl = sspIcons + apConstants.url.needsReviewIcon;
    reviewRequiredIconUrl = `${sspIcons}${apConstants.url.needsReviewIcon}`;
    checkedIconUrl = `${sspIcons}${apConstants.url.progressChecked}`;
    uncheckedIconUrl = `${sspIcons}${apConstants.url.progressNotStartedIcon}`;
    inProgressIconUrl = `${sspIcons}${apConstants.url.inProgressIcon}`;

  label = {
    startButton,
    editButton,
    continueButton,
    learnMoreLink,
    ProgressIcon,
    sspView
  };

    /**
     * @function handleSectionAction
     * @description Handles Section/Tile level action button/link click.
     */
    handleSectionAction = () => {
        try {
            const isNotStarted =
                !!this.sectionStatus && this.sectionStatus.IsStart__c;
            const isNotRequired =
                !!this.sectionStatus && this.sectionStatus.IsNotRequired__c;
            const isCompleted = this.isCompleted;
            const selectedButtonEvent = new CustomEvent("action", {
                detail: {
                    pageName: this.section.pageName,
                    flowName: this.section.flowName,
                    isReviewRequired: this.isReviewRequired,
                    isNotStarted,
                    isCompleted,
                    isNotRequired
                }
            });
            this.dispatchEvent(selectedButtonEvent);
        } catch (error) {
            console.error("Error in handleButton", error);
        }
    };

    /**
     * @function handleMemberAction
     * @description Handles member level action item click.
     * @param {object} event - Event object to capture member's id.
     */
    handleMemberAction = event => {
        try {
            const memberId = event.currentTarget.dataset.memberId;
            const pageName = event.currentTarget.dataset.pageName;
            const flowName = event.currentTarget.dataset.flowName;
            const flowStatus =
                this.memberItemsMap[memberId].flowStatus &&
                this.memberItemsMap[memberId].flowStatus;
            const isReviewRequired = flowStatus.isReviewRequired;
            const isCompleted = flowStatus.IsEdit__c;
            const isNotRequired = flowStatus.IsNotRequired__c;
            const isNotStarted = flowStatus.IsStart__c;
            const selectedButtonEvent = new CustomEvent("action", {
                detail: {
                    memberId,
                    pageName,
                    flowName,
                    isNotRequired,
                    isNotStarted,
                    isCompleted,
                    isReviewRequired
                }
            });
            this.dispatchEvent(selectedButtonEvent);
        } catch (error) {
            console.error("Error in handleButton", error);
        }
    };

    /**
     * @function handleSubsectionAction
     * @description Handles subsection level actions.
     * @param {object} event - Event object to capture member's id and flow id.
     */
    handleSubsectionAction = event => {
        try {
            const memberId = event.currentTarget.dataset.memberId;
            const pageName = event.currentTarget.dataset.pageName;
            const flowName = event.currentTarget.dataset.flowName;
            const flowStatus =
                (this.memberItemsMap[memberId] &&
                    this.memberItemsMap[memberId].subsectionsMap[flowName] &&
                    this.memberItemsMap[memberId].subsectionsMap[flowName]
                        .flowStatus &&
                    this.memberItemsMap[memberId].subsectionsMap[flowName]
                        .flowStatus) ||
                {};
            const isReviewRequired = flowStatus.isReviewRequired;
            const isCompleted = flowStatus.IsEdit__c;
            const isNotRequired = flowStatus.IsNotRequired__c;
            const isNotStarted = flowStatus.IsStart__c;
            const selectedButtonEvent = new CustomEvent("action", {
                detail: {
                    memberId,
                    pageName,
                    flowName,
                    isNotStarted,
                    isNotRequired,
                    isCompleted,
                    isReviewRequired
                }
            });
            this.dispatchEvent(selectedButtonEvent);
        } catch (error) {
            console.error("Error in handleButton", error);
        }
    };

    /**
     * @function initTile
     * @description Prepares the data to be displayed by performing some aggregations.
     */
    initTile = () => {
        try {
            if (
                !this._sectionData ||
                !this._flowData ||
                this._newMemberFlow === undefined
            ) {
                return;
            }
            this.cardTitle = this.section.sectionName;
            const flowName = this.section.flowName;
            const screenName = this.section.screenName;
            const sortFunction = (a, b) =>
                a.IsHeadOfHousehold__c ? -1 : b.IsHeadOfHousehold__c ? 1 : 0;
                //Defect 379955 fix
            if (this.section.memberLevel) {
                let lastDisabled = false;
                this.memberItems = JSON.parse(
                    JSON.stringify(this.section.members)
                )
                    .sort(sortFunction)
                    .map(this.initMember)
                    .map((member) => {
                        if (
                            (this.newMemberFlow &&
                            !member.isNew &&
                            !member.flowStatus.Id) || (this.readOnlyUser && member.flowStatus.IsStart__c) 
                        ) {
                            member.action.disabled = true;
                        }
                        return member;
                    })
                    .map(member => {
                        if (!member.action.disabled) {
                            member.action.disabled = lastDisabled;
                            lastDisabled =
                                lastDisabled ||
                                member.flowStatus.IsStart__c ||
                                member.flowStatus.IsContinue__c;
                        }
                        return member;
                    });
                this.memberItemsMap = this.memberItems.reduce((map, member) => {
                    map[member.SSP_Member__c] = member;
                    return map;
                }, {});
            } else if (flowName) {
                const [flowStatuses] = this.flowStatus[flowName] || [];
                const flowStatus = JSON.parse(
                    JSON.stringify(
                        Object.assign({}, defaultStartStatus, flowStatuses)
                    )
                );
                const screenStatus = JSON.parse(
                    flowStatus.Screen_Status__c || "{}"
                );
                if (flowStatus.isReviewRequired === undefined) {
                    flowStatus.isReviewRequired = Object.values(
                        screenStatus
                    ).some(screen => screen.isReviewRequired);
                     //379955
                     flowStatus.isReviewRequired = this.readOnlyUser ? false : flowStatus.isReviewRequired
                }
                this.initTileAction(flowStatus);
            } else if (screenName) {
                this.initTileAction(
                    this.flowStatus[screenName] || "NOT_STARTED"
                );
            }
        } catch (error) {
            console.error("Error in initTile", error);
        }
    };

    initTileAction = sectionStatus => {
        this.sectionStatus = sectionStatus;
        const action = {};
        if (sectionStatus === "NOT_STARTED" || sectionStatus.IsStart__c) {
            action.label = startButton;
            action.altText = `${startButton} ${this.cardTitle}`;
            action.variant = "neutral";
            action.style = `ssp-button_neutral ${buttonStyle}`;
            this._isNotStarted = true;
            this.changeStartBtnFontSize();
        }
        if (sectionStatus === "PENDING" || sectionStatus.IsContinue__c) {
            action.label = continueButton;
            action.altText = `${continueButton} ${this.cardTitle}`;
            action.variant = "neutral";
            action.style = `ssp-button_neutral ${buttonStyle}`;
            this._isPending = true;
        }
        if (sectionStatus === "COMPLETED" || sectionStatus.IsEdit__c) {
            action.label = editButton;
            action.altText = `${editButton} ${this.cardTitle}`;
            action.variant = "neutral";
            action.style = `ssp-button_base ${buttonStyle}`;
            this._isCompleted = true;
        }
        if (
            sectionStatus === "REVIEW_REQUIRED" ||
            sectionStatus.isReviewRequired
        ) {
            action.label = editButton;
            action.altText = `${editButton} ${this.cardTitle}`;
            action.variant = "neutral";
            action.style = `ssp-button_neutral ${buttonStyle}`;
            this._isReviewRequired = true;
        }
        //Shikha - Defect 379955
        if ( this.readOnlyUser ) {
            action.label = sspView;
            action.altText = `${sspView} ${this.cardTitle}`;
            action.variant = "neutral";
            action.style = `ssp-button_neutral ${buttonStyle}`;
            this._isReviewRequired = false;
        }
        this.tileAction = action;
    };

    initMember = member => {
        try {
            const hasSubsections =
                Array.isArray(this.section.subsections) &&
                this.section.subsections.length > 0;
            const aggregateFlowStatus = {};
            if (hasSubsections) {
                let lastDisabled = false;
                member.subsections = this.section.subsections
                    .filter(subsection =>
                        this.newMemberFlow && !member.isNew ? this.flowStatus[member.SSP_Member__c] &&
                            this.flowStatus[member.SSP_Member__c][subsection.flowName]
                            : subsection.members.includes(member.Id)
                    )
                    .map(subsection =>
                        this.initSubsection(
                            JSON.parse(JSON.stringify(subsection)),
                            member
                        )
                    )
                    .map(subsection => {
                        subsection.disabled = lastDisabled;
                        lastDisabled =
                            lastDisabled ||
                            subsection.flowStatus.isReviewRequired ||
                            subsection.flowStatus.IsStart__c ||
                            subsection.flowStatus.IsContinue__c;
                        return subsection;
                    });
                member.subsectionsMap = member.subsections.reduce(
                    (map, subsection) => {
                        const key =
                            subsection.flowName || subsection.screenName;
                        map[key] = subsection;
                        return map;
                    },
                    {}
                );
                const [lastSubsection] = member.subsections
                    .filter(subsection => !subsection.disabled)
                    .splice(-1);

                if (lastSubsection && lastSubsection.flowStatus) {
                    Object.assign(aggregateFlowStatus, {
                        isReviewRequired: member.subsections.some(
                            subsection => subsection.flowStatus.isReviewRequired
                        ),
                        [IS_EDIT]: member.subsections.every(
                            subsection => subsection.flowStatus.IsEdit__c
                        ),
                        [IS_START]: member.subsections.every(
                            subsection => subsection.flowStatus.IsStart__c
                        ),
                        [IS_CONTINUE]:
                            !member.subsections.every(
                                subsection => subsection.flowStatus.IsEdit__c
                            ) &&
                            !member.subsections.every(
                                subsection => subsection.flowStatus.IsStart__c
                            ),
                        Id: member.subsections.some(
                            subsection => subsection.flowStatus.Id
                        )
                    });
                }
            }
            const flowName = this.section.flowName;
            const defaultStatus = defaultStartStatus;
            const flowStatus = JSON.parse(
                JSON.stringify(
                    Object.assign(
                        {},
                        defaultStatus,
                        flowName &&
                            this.flowStatus[member.SSP_Member__c] &&
                            this.flowStatus[member.SSP_Member__c][flowName],
                        aggregateFlowStatus
                    )
                )
            );

            if (flowStatus.Screen_Status__c) {
                const screenStatus = JSON.parse(flowStatus.Screen_Status__c);
                flowStatus.isReviewRequired =
                    flowStatus.isReviewRequired ||
                    Object.values(screenStatus).some(
                        screen => screen.isReviewRequired
                    );
                //379955
                flowStatus.isReviewRequired = this.readOnlyUser ? false : flowStatus.isReviewRequired;
            }

            const action = {};
            const sectionName = this.cardTitle;
            member.cssStyle = `${cssStyle} ssp-color_blueAlpha`;
            action.cssStyle = `${cssStyle} ssp-color_blueAlpha`;
            if (flowStatus.IsStart__c) {
                action.label = startButton;
                action.icon = this.darkNextIcon;
                action.altText = `${startButton} ${member.SSP_Member__r.Name}'s ${sectionName}`;
                action.cssStyle = `${cssStyle} ssp-color_magentaBeta`;
                if (!this.newMemberFlow || member.isNew) {
                    if (this.flowStatus[this.section.id] === "COMPLETED") {
                        flowStatus.isReviewRequired = true;
                    }
                }
            }
            if (flowStatus.IsContinue__c) {
                action.label = continueButton;
                action.icon = this.blueNextIcon;
                action.altText = `${continueButton} ${member.SSP_Member__r.Name}'s ${sectionName}`;
                if (!this.newMemberFlow || member.isNew) {
                    if (this.flowStatus[this.section.id] === "COMPLETED") {
                        flowStatus.isReviewRequired = true;
                    }
                }
            }
            if (flowStatus.IsEdit__c) {
                action.label = editButton;
                action.icon = this.blueNextIcon;
                action.altText = `${editButton} ${member.SSP_Member__r.Name}'s ${sectionName}`;
            }
            //379955
            if (flowStatus.isReviewRequired && !this.readOnlyUser) {
                // action.label = editButton;
                action.icon = this.redNextIcon;
                action.cssStyle = `${cssStyle} ssp-color_redAlpha`;
                member.cssStyle = `${cssStyle} ssp-color_redAlpha`;
                // action.altText = `${editButton} ${member.SSP_Member__r.FirstName__c} ${member.SSP_Member__r.LastName__c}'s ${sectionName}`;
            }
            if (hasSubsections) {
                let [firstRequiredSubsection] = member.subsections;
                const self = this;
                for (const subsection of member.subsections) {
                    if (!self.readOnlyUser && 
                        (subsection.flowStatus.isRequired ||
                        subsection.flowStatus.IsStart__c) ||
                        subsection.flowStatus.IsContinue__c
                    ) {
                        firstRequiredSubsection = subsection;
                        break;
                    }
                }
                if (firstRequiredSubsection) {
                    action.pageName = firstRequiredSubsection.pageName;
                    action.flowName = firstRequiredSubsection.flowName;
                }
            }

            action.pageName = action.pageName || this.section.pageName;
            action.flowName = action.flowName || this.section.flowName;

            member.flowStatus = flowStatus;
            //Shikha -- added defect 379955
            if (this.readOnlyUser ){
                action.label = sspView;                
            }
            member.action = action;
        } catch (error) {
            console.error("Error in initMember", error);
        }
        return member;
    };

    initSubsection = (subsection, member) => {
        try {
            const flowName = subsection.flowName;
            const defaultStatus = defaultStartStatus;
            const flowStatus = JSON.parse(
                JSON.stringify(
                    Object.assign(
                        {},
                        defaultStatus,
                        flowName &&
                            this.flowStatus[member.SSP_Member__c] &&
                            this.flowStatus[member.SSP_Member__c][flowName]
                    )
                )
            );
            if (flowStatus.Screen_Status__c) {
                const screenStatus = JSON.parse(flowStatus.Screen_Status__c);
                flowStatus.isReviewRequired = Object.values(screenStatus).some(
                    screen => screen.isReviewRequired
                );
                 //379955
                 flowStatus.isReviewRequired = this.readOnlyUser ? false : flowStatus.isReviewRequired;
            }
            subsection.action = {
                icon: this.notStartedNextIcon,
                altText: ""
            };
            subsection.cssStyle = `${cssStyle} ssp-color_monoBody`;
            if (flowStatus.IsStart__c) {
                subsection.statusString = status.NOT_STARTED;
                subsection.action.altText = `${startButton} ${member.SSP_Member__r.FirstName__c} ${member.SSP_Member__r.LastName__c}'s ${subsection.subsectionName}`;
                subsection.action.icon = this.notStartedNextIcon;
                subsection.action.disableArrow = false;
                if (this.flowStatus[this.section.id] === "COMPLETED") {
                    flowStatus.isReviewRequired = true;
                }
            }
            if (flowStatus.IsContinue__c) {
                subsection.statusString = status.PENDING;
                subsection.action.altText = `${continueButton} ${member.SSP_Member__r.FirstName__c} ${member.SSP_Member__r.LastName__c}'s ${subsection.subsectionName}`;
                subsection.action.icon = this.blueNextIcon;
                subsection.action.disableArrow = true;
                if (this.flowStatus[this.section.id] === "COMPLETED") {
                    flowStatus.isReviewRequired = true;
                }
            }
            if (flowStatus.IsEdit__c) {
                subsection.statusString = status.COMPLETED;
                subsection.action.altText = `${editButton} ${member.SSP_Member__r.FirstName__c} ${member.SSP_Member__r.LastName__c}'s ${subsection.subsectionName}`;
                subsection.action.icon = this.blueNextIcon;
                subsection.action.disableArrow = true;
            }
            if (flowStatus.isReviewRequired && !this.readOnlyUser) {
                // subsection.statusString = status.REVIEW_REQUIRED;
                subsection.cssStyle = `${cssStyle} ssp-color_redAlpha`;
                subsection.action.icon = this.redNextIcon;
                // subsection.action.disableArrow = true;
            }
            subsection.flowStatus = flowStatus;
        } catch (error) {
            console.error("Error in initSubsection", error);
        }
        return subsection;
    };

    get headerCssStyle () {
        if (this.isReviewRequired && !this.readOnlyUser) {
            return "ssp-MemberCard ssp-bg_redGamma ssp-ReviewCard";
        }
        return "ssp-MemberCard sspMonoBetaBorderBottom";
    }

    @api
    get isReviewRequired () {
        //379955
        const readOnly = this.readOnlyUserProp;  
        if (Array.isArray(this.memberItems)) {
            return this.memberItems.some(
                item => !readOnly && item.flowStatus && item.flowStatus.isReviewRequired
            );
        }
        return !!this._isReviewRequired;
    }

    get notStarted () {
        if (Array.isArray(this.memberItems)) {
            const filteredItems = this.applicableMembers;
            const notStartedItems = filteredItems.filter(
                item => item.flowStatus && item.flowStatus.IsStart__c
            );
            return notStartedItems.length === filteredItems.length;
        }
        return !!this._isNotStarted;
    }

    @api
    get isPending () {
        if (Array.isArray(this.memberItems)) {
            const filteredItems = this.applicableMembers;
            const completedItems = filteredItems
                .filter(member => !this.newMemberFlow || member.isNew)
                .filter(
                    item =>
                        item.flowStatus &&
                        (item.flowStatus.IsEdit__c ||
                            item.flowStatus.IsContinue__c)
                );
            return completedItems.length > 0;
        }
        return !!this._isPending;
    }

    @api
    get isCompleted () {
        if (Array.isArray(this.memberItems)) {
            const filteredItems = this.applicableMembers;
            const completedItems = filteredItems.filter(
                item => item.flowStatus && item.flowStatus.IsEdit__c === true
            );
            return completedItems.length === filteredItems.length;
        }
        return !!this._isCompleted && !this.isReviewRequired;
    }

    get cardIconUrl () {
        if (this.isReviewRequired && !this.readOnlyUser) {
            return this.reviewRequiredIconUrl;
        }
        if (this.isCompleted) {
            return this.checkedIconUrl;
        }
        if (this.isPending) {
            return this.inProgressIconUrl;
        }
        return this.uncheckedIconUrl;
    }

    get showTileActionButton () {
        const showAction = this.readOnlyUser && (this.section && this.section.flowName === "SignAndSubmit") ? false : 
                            !Array.isArray(this.memberItems) ;
        return showAction;
    }

    get applicableMembers () {
        return this.memberItems.filter(
            item => !this.newMemberFlow || item.isNew || item.flowStatus.Id
        );
    }

    changeStartBtnFontSize = () => {
        // Added below code to decrease the font size of Spanish Start button in mobile
            const urlString = window.location.href;
            const url = new URL(urlString);
            const language = url.searchParams.get("language");
            if (language === "es_US") {
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    const btnRef = this.template.querySelector(".ssp-cardItemsButton");
                    btnRef.classList.add("ssp-SpanishStartBtn");
                }, 0);
            }
    }
}
