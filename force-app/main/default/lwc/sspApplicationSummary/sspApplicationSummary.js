import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import applicationSummary from "@salesforce/label/c.SSP_ApplicationSummary";
import changeSummary from "@salesforce/label/c.SSP_ChangeSummary";
import renewalSummary from "@salesforce/label/c.SSP_RenewalSummary";

import caseDataUpdated from "@salesforce/label/c.SSP_CaseUpdated";
import applicationSummaryText from "@salesforce/label/c.SSP_ApplicationSummaryText";
import renewalSummaryText from "@salesforce/label/c.SSP_RenewalSummaryText";
import changeSummaryText from "@salesforce/label/c.SSP_ChangeSummaryText";
import caseNumber from "@salesforce/label/c.SSP_Case";
import applicationNumber from "@salesforce/label/c.SSP_ApplicationNumber";
import saveAndExit from "@salesforce/label/c.SSP_SaveAndExit";
import explicitText from "@salesforce/label/c.SSP_ExplicitText";
import applicationSummaryReviewText from "@salesforce/label/c.SSP_ApplicationSummaryReviewText";
import nonMemberNote from "@salesforce/label/c.SSP_ApplicationNonMemberNote";
import benefitsApplication from "@salesforce/label/c.SSP_BenefitsApplication";
import learnMoreLink from "@salesforce/label/c.SSP_LearnMoreLink";
import cancel from "@salesforce/label/c.SSP_Cancel";
import relationshipAndTaxFiling from "@salesforce/label/c.SSP_RelationshipTaxFiling";
import progressIndicator from "@salesforce/label/c.SSP_ProgressIndicator";
import sspExitButton from "@salesforce/label/c.SSP_ExitButton";
import { applicationMode, programValues, navigationUrl, permission } from "c/sspConstants";
import { formatLabels } from "c/sspUtility";
import getApplicationSummaryDetail from "@salesforce/apex/SSP_ApplicationSummaryController.getApplicationSummaryDetail";
import resetRSSPDCEligibility from "@salesforce/apex/SSP_ApplicationSummaryController.resetRSSPDCEligibility";
import fireCallouts from "@salesforce/apex/SSP_ApplicationSummaryController.fireCallouts";
import retryRSSPDCTransaction from "@salesforce/apex/SSP_Utility.retryRSSPDCTransaction";
import resetStatus from "@salesforce/apex/SSP_ApplicationSummaryController.resetStatus";
import markSectionComplete from "@salesforce/apex/SSP_ApplicationSummaryController.markSectionsComplete";
import getTransactionStatus from "@salesforce/apex/SSP_ApplicationSummaryController.getTransactionStatus";
import sspSaveAndExitAltText from "@salesforce/label/c.SSP_SaveAndExitAltText";
import pollingInterval from "@salesforce/label/c.SSP_IsDataProcessedPollingInterval";
import { updateRecord } from "lightning/uiRecordApi";

//Added labels for performance fix Bug 378743
//�eslint-disable-next-line�camelcase
import SSP_SignSubmitText from "@salesforce/label/c.SSP_SignSubmitText";
//�eslint-disable-next-line�camelcase 
import SSP_HealthCoverage from "@salesforce/label/c.SSP_HealthCoverage";
//�eslint-disable-next-line�camelcase 
import SSP_Expenses_Information from "@salesforce/label/c.SSP_Expenses_Information";
//�eslint-disable-next-line�camelcase 
import SSP_Income_Subsidies_Information from "@salesforce/label/c.SSP_Income_Subsidies_Information";
//�eslint-disable-next-line�camelcase 
import SSP_Resources_Information from "@salesforce/label/c.SSP_Resources_Information";
//�eslint-disable-next-line�camelcase 
import SSP_Other_Information from "@salesforce/label/c.SSP_Other_Information";
//�eslint-disable-next-line�camelcase 
import SSP_HealthInformation from "@salesforce/label/c.SSP_HealthInformation";
//�eslint-disable-next-line�camelcase 
import SSP_Individual_Information from "@salesforce/label/c.SSP_Individual_Information";
//�eslint-disable-next-line�camelcase 
import SSP_MemberDetails from "@salesforce/label/c.SSP_MemberDetails";
//�eslint-disable-next-line�camelcase 
import SSP_HouseholdInformation from "@salesforce/label/c.SSP_HouseholdInformation";
//�eslint-disable-next-line�camelcase 
import SSP_Relationships from "@salesforce/label/c.SSP_Relationships";
//�eslint-disable-next-line�camelcase 
import SSP_RepsAssistersAgents from "@salesforce/label/c.SSP_RepsAssistersAgents";
//�eslint-disable-next-line�camelcase 
import SSP_ContactInfo from "@salesforce/label/c.SSP_ContactInfo";
//�eslint-disable-next-line�camelcase 
import SSP_HouseholdMembers from "@salesforce/label/c.SSP_HouseholdMembers";
//�eslint-disable-next-line�camelcase 
import SSP_ProgramSelection from "@salesforce/label/c.SSP_ProgramSelection";

export default class SspApplicationSummary extends NavigationMixin(
    LightningElement
) {
    @api mode;
    /**
     * Please inform me (Ajay Saini, ajsaini@deloitte.com) over skype or email
     * before even touching it.
     */
    @track applicationId;
    @track members = [];
    @track sections = [];
    @track programSelectionSection;
    @track application = {};
    @track flowData = {};
    @track sectionStatus = {};
    @track showLearnMore = false;
    @track progressSummary;
    @track showToast = false;
    @track showSpinner = false;
    @track newMembers = [];
    @track openSaveExitModal = false;
    @track showEarlySubmission = false;
    @track showAdditionalChanges = false;
    @track reference = this;
    @track showCaseUpdatedAlert = false;
    @track showErrorModal = false;
    @track changeMode;
    @track failureLogsId;
    //@track queueWrapper = {};
    initFlowStatuses = {};
    @track initFlowStatusesMap = {};

    @track isEarlySubmissionReadOnly = false; //2.5 Security Role Matrix.
    @track isEarlySubmissionNotAccessible = false; //2.5 Security Role Matrix.

    @track isScreenAccessible = false; //2.5 Security Role Matrix and Program Access.
    @track showAccessDeniedComponent = false; //2.5 Security Role Matrix.
    @track readOnlyUserProp;
    @track showNextSteps = false;
    contactId;
    label = {
        caseDataUpdated,
        saveAndExit,
        explicitText,
        applicationSummaryReviewText,
        benefitsApplication,
        learnMoreLink,
        cancel,
        sspSaveAndExitAltText,
        //�eslint-disable-next-line�camelcase 
        SSP_SignSubmitText,
        //�eslint-disable-next-line�camelcase 
        SSP_HealthCoverage,
        //�eslint-disable-next-line�camelcase 
        SSP_Expenses_Information,
        //�eslint-disable-next-line�camelcase 
        SSP_Income_Subsidies_Information,
        //�eslint-disable-next-line�camelcase 
        SSP_Resources_Information,
        //�eslint-disable-next-line�camelcase 
        SSP_Other_Information,
        //�eslint-disable-next-line�camelcase 
        SSP_HealthInformation,
        //�eslint-disable-next-line�camelcase 
        SSP_Individual_Information,
        //�eslint-disable-next-line�camelcase 
        SSP_MemberDetails,
        //�eslint-disable-next-line�camelcase 
        SSP_HouseholdInformation,
        //�eslint-disable-next-line�camelcase 
        SSP_Relationships,
        //�eslint-disable-next-line�camelcase 
        SSP_RepsAssistersAgents,
        //�eslint-disable-next-line�camelcase 
        SSP_ContactInfo,
        //�eslint-disable-next-line�camelcase 
        SSP_HouseholdMembers,
        //�eslint-disable-next-line�camelcase 
        SSP_ProgramSelection,
    };
    get earlySubmissionModalAccessible (){
        return this.showEarlySubmission && !this.isEarlySubmissionNotAccessible;
    }

    get pageTitle () {
        if (this.mode === applicationMode.RENEWAL) {
            return renewalSummary;
        }
        if (this.mode === applicationMode.RAC) {
            return changeSummary;
        }
        return applicationSummary;
    }

    get summaryButtonLabel () {
        if (this.mode !== applicationMode.INTAKE || this.readOnlyUserProp) {
            return sspExitButton;
        }
        return saveAndExit;
    }

    get saveExitAltButtonLabel () {
        if (this.mode === applicationMode.RAC) {
            return sspSaveAndExitAltText;
        }
        return sspSaveAndExitAltText;
    }

    get applicationType () {
        if (this.mode === applicationMode.INTAKE) {
            return applicationNumber;
        }
        return caseNumber;
    }

    get recordNumber () {
        if (this.mode !== applicationMode.INTAKE) {
            return this.application.DCCaseNumber__c;
        }
        return this.application.Name;
    }

    get instructiveTitle () {
        if (this.mode === applicationMode.RENEWAL) {
            return renewalSummaryText;
        }
        if (this.mode === applicationMode.RAC) {
            return changeSummaryText;
        }
        return applicationSummaryText;
    }

    get totalSectionCount () {
        return this.template.querySelectorAll("c-ssp-member-section-card")
            .length;
    }

    //Shikha - 379955
    get isReviewRequired () {
        const readOnly = this.readOnlyUserProp;
        const revReq = Array.from(
            this.template.querySelectorAll("c-ssp-member-section-card")
        ).some((item) => !readOnly && item.isReviewRequired);
        return revReq;
    }

    get completedSections () {
        return Array.from(
            this.template.querySelectorAll("c-ssp-member-section-card")
        ).filter(item => item.isCompleted).length;
    }

    get progressPercent () {
        if (this.totalSectionCount > 0) {
            return Math.floor(
                (this.completedSections * 100) / this.totalSectionCount
            );
        }
        return 0;
    }

    get progressBarStyle () {
        return `width: ${this.progressPercent}%`;
    }

    get showProgramSelection () {
        return (
            this.programSelectionSection && this.mode !== applicationMode.RAC
        );
    }

    get disableProgramSelection () {
        return this.mode === applicationMode.RENEWAL;
    }

    get newMemberFlow () {
        return (
            this.mode === applicationMode.RAC &&
            (this.changeMode === "AddRemoveMember" || !this.changeMode)
        );
    }

    get modeValue () {
        if (this.newMemberFlow) {
            return "addRemoveMember";
        }
        return this.mode;
    }

    @wire(CurrentPageReference)
    wiredPageRef (value) {
        if (!value) {
            return;
        }
        this.pageRef = value;
        this.applicationId = value.state.applicationId;
        if (value.attributes && value.attributes.sectionId) {
            this.sourceSection = value.attributes.sectionId;
        }
        if (value.attributes && value.attributes.incompleteSections) {
            this.incompleteSections = value.attributes.incompleteSections;
        }
    }

    /**
     * @function connectedCallback
     * @description Sets applicationId from URL params.
     */
    async connectedCallback () {
        try {
            this.showSpinner = true;
            await this.transactionSuccess();
            this.fetchApplicationSummary();
            this.calloutsDone = false;
        } catch (error) {
            this.showSpinner = false;
            if (Array.isArray(error.mapResponse && error.mapResponse.logs)) {
                [this.failureLogsId] = error.mapResponse.logs;
            }
            this.showErrorModal = true;
            console.error("Error in connectedCallback", error);
        }
    }


    /**
     * @function renderedCallback
     * @description Sets applicationId from URL params.
     */
    renderedCallback () {
        try {
            this.progressSummary = formatLabels(progressIndicator, [
                this.completedSections,
                this.totalSectionCount
            ]);
            const sectionCards = Array.from(
                this.template.querySelectorAll("c-ssp-member-section-card")
            );
            // if (this.mode === applicationMode.RENEWAL) {
            //     sectionCards = sectionCards.splice(1);
            // }
            let nextCardDisabled = false;
            for (const card of sectionCards) {
                card.disabled = nextCardDisabled;
                nextCardDisabled = nextCardDisabled || !card.isCompleted;
            }
            const completedSections = sectionCards
                .filter(section => section.isCompleted)
                .map(card => card.section.id);
            //Expedite SNAP
            if (
                completedSections.includes("REPS_Home") &&
                this.getExpeditedSNAPEligible
            ) {
                for (const card of sectionCards) {
                    if (card.section.id === "Sign_and_Submit") {
                        if (card.disabled === false) {
                            this.previousSectionsComplete = true;
                        } else {
                            card.disabled = false;
                            this.previousSectionsComplete = false;
                        }
                        break;
                    }
                }
            }
            for (const card of sectionCards) {
                if (card.section.id === "Sign_and_Submit") {
                    if (card.disabled === false) {
                        this.showAdditionalChangesModal();
                    }
                    break;
                }
            }
            
            const latestCompletedSection = this.sourceSection || "$";
            const incompleteSections = this.incompleteSections || [];
            if(latestCompletedSection === "Member_Details" &&
                completedSections.includes(latestCompletedSection)) {
                this.triggerCalloutsOnMemberDetailsCompletion();
            }
            if (this.sectionsMap && 
                this.sectionsMap[latestCompletedSection] && 
                completedSections.includes(latestCompletedSection) &&
                incompleteSections.includes(latestCompletedSection)) {
                const sectionName = this.sectionsMap[latestCompletedSection]
                    .sectionName;
                this.toastMessage = `${sectionName} section is complete.`;
                this.showToast = true;
                this.sourceSection = "$";
                this.markSectionsComplete(completedSections);
            }
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }

    /**
     * @function fetchApplicationSummary
     * @description Makes a server call to get application detail.
     */
    fetchApplicationSummary = () => {
        this.fetchApplicationSummaryCalled = true;
        this.showSpinner = true;
    
        this.applicationReady().then(async data => {
            if (data && data.bIsSuccess && data.mapResponse) {
                this.response = data.mapResponse;
                await this.initPage(data.mapResponse);
                //Shikha -- added
                if (data && data.mapResponse){
                    const { screenPermissionEarlySubmission } = data.mapResponse.screenPermissionEarlySubmission;
                    if (screenPermissionEarlySubmission){
                        this.isEarlySubmissionReadOnly = screenPermissionEarlySubmission === permission.readOnly;
                        this.isEarlySubmissionNotAccessible = screenPermissionEarlySubmission === permission.notAccessible;
                    }
                }                
            }
            this.showSpinner = false;
            return data;
        });
    };

    applicationReady = () => new Promise(this.pollApplication);

    pollApplication = (resolve, reject) => {
        getApplicationSummaryDetail({
            applicationId: this.applicationId,
            mode: this.mode
        }).then(response => {
            if (response.bIsSuccess) {
                if (
                    response.mapResponse &&
                    response.mapResponse.applicationReady
                ) {
                    resolve(response);
                } else {
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout(
                        () => this.pollApplication(resolve, reject),
                        1000
                    );
                }
                return;
            }
            reject(response);
        });
    };

    getInitialNavFlowStatuses = () => {
        try {
            for (const member of this.members) {
                for (const flowName of this.memberFlows) {
                    this.initFlowStatuses[flowName] = Object.assign(
                        {},
                        this.initFlowStatuses[flowName],
                        {
                            [member.SSP_Member__c]: !this.initFlowStatusesMap[
                                member.SSP_Member__c
                            ][flowName]
                                .split("")
                                .every(statusChar => statusChar === "N")
                        }
                    );
                }
            }

            const HOHMember = "HOH";
            for (const flowName of this.nonMemberFlows) {
                this.initFlowStatuses[flowName] = !this.initFlowStatusesMap[
                    HOHMember
                ][flowName]
                    .split("")
                    .every(statusChar => statusChar === "N");
            }
            return Promise.resolve();
        } catch (error) {
            console.error("Error in getInitialNavFlowStatuses:", error);
        }
    };

    /**
     * @function initPage
     * @description Initializes page attributes.
     * @param {object} response - Object having list if flow status' and members.
     */
    initPage = async response => {
        this.showSpinner = true;
        try {
            if (!Array.isArray(response.members)) {
                return;
            }
            const members = JSON.parse(JSON.stringify(response.members || []));
            members.forEach(member => {
                member.isNew = member.MemberStatus__c === "New";
            });
            //Bug 378743: Performance Fix: Converting label api names into values  
            response.appSummaryConfig.forEach((appConfig) => {
                appConfig.sectionName = this.label[appConfig.sectionName];
                appConfig.subsectionName = this.label[appConfig.subsectionName];
            });
            this.members = members;
            this.newMembers = this.members
                .filter(member => member.isNew)
                .map(member => member.SSP_Member__c);
            this.flowData = response.flowStatusMap;
            this.application = response.application || {};
            this.changeMode = this.application.ChangeSummaryMode__c;
            this.sectionStatus = JSON.parse(
                this.application.SectionStatus__c || "{}"
            );
            const programsAppliedString =
                this.application.ProgramsApplied__c || "";
            this.programsApplied = programsAppliedString.split(";");
            const rawItems = response.appSummaryConfig.filter(item =>
                item.applicablePrograms.some(program =>
                    this.programsApplied.includes(program)
                )
            );
            this.memberFlows = response.appSummaryConfig
                .filter(config => !!config.flowName && config.memberLevel)
                .map(config => config.flowName);
            this.nonMemberFlows = response.appSummaryConfig
                .filter(config => !!config.flowName && !config.memberLevel)
                .map(config => config.flowName);
            this.initFlowStatusesMap = response.initNavFlowStatus;
            if (applicationMode.INTAKE === this.mode) {
                this.showCaseUpdatedAlert = !!response.caseUpdated;
            }
             //Shikha - /** #379955 fix*/
            this.readOnlyUserProp = response.readOnlyUser;   
            this.contactId = response.contactId;          
            await this.getInitialNavFlowStatuses();
            if(response.isEligibleRSSPDC){
                this.resetRSSPDCEligibility();
            }
            this.buildItems(JSON.parse(JSON.stringify(rawItems)));
            this.showSpinner = false;
        } catch (error) {
            this.showErrorModal = true;
            this.showSpinner = false;
            console.error("Error in initPage", error);
        }
    };

    /**
     * @function buildItems
     * @description Prepares the data to be rendered.
     * @param {object[]} rawItems - Array of object describing appearance of a section tile.
     */
    buildItems = rawItems => {
        try {
            const sections = rawItems.reduce((map, item) => {
                let members = this.members
                    .filter((member) =>
                        item.members.includes(member.SSP_Member__c)
                    )
                    .filter(member => {
                        if(item.memberFilter) {
                            return !member.IsTMember__c;
                        }
                        return true;
                    });
                if (item.flowName) {
                    if (item.memberLevel) {
                        const initialFlowStatuses = this.initFlowStatuses[
                            item.flowName
                        ];
                        if (this.newMemberFlow) {
                            members = members.filter(
                                member =>
                                    !member.isNew ||
                                    (initialFlowStatuses &&
                                        initialFlowStatuses[
                                            member.SSP_Member__c
                                        ])
                            );
                        } else if (this.mode === applicationMode.RAC) {
                            members = members
                                .filter(member => !member.isNew)
                                .filter(
                                    member =>
                                        (this.flowData &&
                                            this.flowData[
                                                member.SSP_Member__c
                                            ] &&
                                            this.flowData[member.SSP_Member__c][
                                                item.flowName
                                            ] &&
                                            this.flowData[member.SSP_Member__c][
                                                item.flowName
                                            ].IsNotRequired__c === false) ||
                                        (initialFlowStatuses &&
                                            initialFlowStatuses[
                                                member.SSP_Member__c
                                            ])
                                );
                        } else {
                            members = members.filter(
                                member =>
                                    initialFlowStatuses &&
                                    initialFlowStatuses[member.SSP_Member__c]
                            );
                        }
                        if (members.length === 0) {
                            return map;
                        }
                    } else {
                        if (
                            this.initFlowStatuses &&
                            this.initFlowStatuses[item.flowName] !== undefined
                        ) {
                            if (
                                this.initFlowStatuses[item.flowName] === false
                            ) {
                                return map;
                            }
                        }
                    }
                }
                const memberIds = members.map(member => member.Id);
                if (map[item.id] && Array.isArray(map[item.id].subsections)) {
                    item.mode = this.mode;
                    map[item.id].members = Object.values(
                        map[item.id].members
                            .concat(members || [])
                            .reduce((dictionary, member) => {
                                dictionary[member.Id] = member;
                                return dictionary;
                            }, {})
                    );
                    item.members = memberIds;
                    map[item.id].subsections.push(item);
                } else {
                    item.mode = this.mode;
                    if (item.subsectionLevel) {
                        item.members = memberIds;
                        map[item.id] = {
                            id: item.id,
                            subsections: [item],
                            sectionName: item.sectionName,
                            memberLevel: item.memberLevel,
                            subsectionLevel: item.subsectionLevel,
                            members
                        };
                    } else {
                        map[item.id] = {
                            ...item,
                            members
                        };
                    }
                }
                map[item.id].mode = this.mode;
                return map;
            }, {});
            const programSelection = sections.SSP_APP_ProgramSelection;
            if (programSelection) {
                delete sections.SSP_APP_ProgramSelection;
                this.programSelectionSection = programSelection;
            }
            //Exceptions
            if (sections.Relationships) {
                const unicorn0 = /\{0\}/g;
                const members = sections.Relationships.members;
                const nonMembers = members
                    .filter(member => member.IsTMember__c)
                    .map(member => member.SSP_Member__r.Name);
                if (nonMembers.length > 0) {
                    const nonMembersList = nonMembers.join(", ");
                    sections.Relationships.bottomNote = nonMemberNote.replace(
                        unicorn0,
                        nonMembersList
                    );
                }
                if (
                    this.programsApplied.includes(programValues.MA) ||
                    this.programsApplied.includes(programValues.SS)
                ) {
                    sections.Relationships.sectionName = relationshipAndTaxFiling;
                }
            }
            this.sectionsMap = JSON.parse(JSON.stringify(sections));
            this.sections = Object.values(sections);
        } catch (error) {
            console.error("Error in buildItems:", error);
        }
    };

    transactionSuccess = () => new Promise(this.pollTransactionStatus);

    pollTransactionStatus = (resolve, reject) => {
        try {
            getTransactionStatus({
                applicationId: this.applicationId,
                mode: this.mode //added mode param
            }).then(response => {
                if (response.bIsSuccess) {
                    //2.5 Security Role Matrix and Program Access.
                  if (response.mapResponse.hasNoAccess !== undefined && response.mapResponse.hasNoAccess  !== null){
                        this.isScreenAccessible = false;
                        this.showNextSteps = true;
                        this.showSpinner = false;
                    }else if (response.mapResponse.isNotAccessible){
                        this.isScreenAccessible = false;
                        this.showAccessDeniedComponent = true;
                        this.showSpinner = false;
                    }
                    else{
                        this.isScreenAccessible = true; 
                        if (response.mapResponse.allSuccessFull) {
                            resolve(response);
                        } else if (response.mapResponse.anyFailed) {
                            [this.failureLogsId] = response.mapResponse.logs;
                            reject(response);
                        } else {
                            // eslint-disable-next-line @lwc/lwc/no-async-operation
                            setTimeout(
                                () => this.pollTransactionStatus(resolve, reject),
                                +pollingInterval
                            );
                        }
                    }//2.5 Security Role Matrix and Program Access.
                } else {
                    reject(response);
                }
            });
        } catch (error) {
            reject(error);
        }
    };

    markSectionsComplete = sections => {
        if (!Array.isArray(sections) || sections.length === 0) {
            return;
        }
        // this.markSectionsCompleteCalled = true;
        return markSectionComplete({
            applicationId: this.applicationId,
            sections: sections.join(";")
        }).then(response => {
            if (
                response.mapResponse &&
                Array.isArray(response.mapResponse.newlyCompletedSections) &&
                response.mapResponse.newlyCompletedSections
            ) {
                this.sectionName = response.mapResponse.newlyCompletedSections;
            }
            return response;
        });
    };

    /**
     * @function triggerCalloutsOnMemberDetailsCompletion
     * @description Fires the callouts on completion of member details.
     */
    triggerCalloutsOnMemberDetailsCompletion = () => {
        if(!this.calloutsDone) {
            this.calloutsDone = true;
            fireCallouts({
                applicationId: this.applicationId,
                mode: this.modeValue
            });
        }
    }

    /**
     * @function launchFlow
     * @description Launches contact-information flow for a member.
     * @param {object} event - Event object.
     */
    launchFlow = async event => {
        try {
            this.showSpinner = true;
            const pageName = event.detail.pageName;
            const flowName = event.detail.flowName;
            const memberId = event.detail.memberId;
            const sectionId = event.target.section.id;
            if (sectionId === "Sign_and_Submit") {
                if (this.showModalsBeforeSubmit()) {
                    this.showSpinner = false;
                    return;
                }
            }
            const applicationId = this.applicationId;
            //Shikha Defect 379955 
            const isReviewRequired = this.readOnlyUserProp ? false : event.detail.isReviewRequired;
             
            const isCompleted = event.detail.isCompleted;
            const isNotRequired = event.detail.isNotRequired;
            const isNotStarted = event.detail.isNotStarted;
            const mode = this.modeValue;
            //const queueObject = JSON.stringify(this.queueWrapper);
            //Shikha Defect 379955 
            if (isNotStarted || isNotRequired || isCompleted || this.readOnlyUserProp) {
                if (flowName && !isReviewRequired) {
                    await resetStatus({
                        applicationId,
                        memberId,
                        flowName,
                        mode
                    });
                }
            }
            await this.navigate(pageName, memberId, sectionId);
        } catch (error) {
            console.error("Error in launchFlow", error);
        }
    };

    /**
     * @function dashboardNavigate () {
     * @description Redirect to dashboard.
     */
    dashboardNavigate = () => {
        try {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: navigationUrl.existingDashboard
                }
            });
        } catch (error) {
            console.error("Error in dashboardNavigate", error);
        }
    };

    /**
     * @function handleSaveExit () {
     * @description Saves the data and redirects to home page.
     */
    handleSaveExit = () => {
        try {
            if (this.mode === applicationMode.RAC || this.mode === applicationMode.RENEWAL) {
                if (this.applicationId) {
                    const objApplication = {};
                    objApplication[
                        "Application_Change_Start_Timestamp__c"
                    ] = null;
                    const record = {
                        recordId: this.applicationId,
                        fields: objApplication
                    };
                    updateRecord(record)
                        .then(() => {
                            this.dashboardNavigate();
                        })
                        .catch(error => {
                            console.error(
                                "error handleSaveExit - update record : ",
                                error
                            );
                        });
                } else {
                    this.dashboardNavigate();
                }
            } 
            else if(this.readOnlyUserProp){
                //379955
                this.dashboardNavigate();
            } 
            else {
                this.openSaveExitModal = true;
            }
        } catch (error) {
            console.error("Error in handleSaveExit", error);
        }
    };

    closeExitModal = () => {
        try {
            this.openSaveExitModal = false;
        } catch (error) {
            console.error("Error in closeExitModal", error);
        }
    };

    /**
     * @function navigate
     * @description Navigates the flow to respective page or component.
     * @param {string} pageName - Name of the page to navigate.
     * @param {string} memberId - Id of the member.
     * @param {string} sectionId - Id of the section.
     */
    navigate = (pageName, memberId, sectionId) => {
        try {
            const mode = this.modeValue;
            const sectionCards = Array.from(
                this.template.querySelectorAll("c-ssp-member-section-card")
            );
            const incompleteSections = sectionCards
                .filter((section) => !section.isCompleted)
                .map((card) => card.section.id);
            return this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: pageName,
                    sectionId: sectionId || "$",
                    incompleteSections
                },
                state: {
                    applicationId: this.applicationId,
                    memberId,
                    mode
                }
            });
        } catch (error) {
            console.error("Error in navigation", error);
        }
    };

    closeLearnMoreModal = () => {
        this.showLearnMore = false;
    };

    openLearnMoreModal = () => {
        this.showLearnMore = true;
    };

    handleHideToast = () => {
        // this.showToast = false;
    };

    preventPageUnload = event => {
        event.returnValue = "Do you wish to leave application here?";
    };

    get getAdditionalChanges () {
        return (
            this.mode === applicationMode.RAC &&
            !this.additionalChangesModalShown
        );
    }

    get getExpeditedSNAPEligible () {
        const programsApplied = this.programsApplied || [];
        return (
            !(
                programsApplied.includes(programValues.MA) ||
                programsApplied.includes(programValues.KP) ||
                programsApplied.includes(programValues.SS)
            ) && this.mode === applicationMode.INTAKE
        );
    }

    showModalsBeforeSubmit = () => this.showEarlySubmissionModal();

    showEarlySubmissionModal = () => {
        try {
            if (
                this.getExpeditedSNAPEligible &&
                !this.previousSectionsComplete
            ) {
                this.showEarlySubmission = true;
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error in showEarlySubmissionModal:", error);
        }
    };

    showAdditionalChangesModal = () => {
        try {
            if (this.getAdditionalChanges) {
                this.showAdditionalChanges = true;
                return true;
            }
            return false;
        } catch (error) {
            console.error("Error in showEarlySubmissionModal:", error);
        }
    };

    hideEarlySubmissionModal = () => {
        this.showEarlySubmission = false;
    };

    closeAdditionalChanges = () => {
        this.showAdditionalChanges = false;
        this.additionalChangesModalShown = true;
    };

    resetRSSPDCEligibility = () => {
        if (            
            this.contactId && 
            this.mode 
        ) {
            resetRSSPDCEligibility({
                mode: this.mode,
                contactId : this.contactId
            })
                .then((result) => {
                    /*if (result && result.mapResponse){
                        const { screenPermissionEarlySubmission } = result.mapResponse;
                        if (screenPermissionEarlySubmission){
                            this.isEarlySubmissionReadOnly = screenPermissionEarlySubmission === permission.readOnly;
                            this.isEarlySubmissionNotAccessible = screenPermissionEarlySubmission === permission.notAccessible;
                        }
                    }*/
                })
                .catch((error) => {
                    console.error(
                        "failed in sspApplicationSummary.resetRSSPDCEligibility " +
                            JSON.stringify(error)
                    );
                });
        }
    };

    retryTransaction = async () => {
        try {
            this.showErrorModal = false;
            this.showSpinner = true;
            await retryRSSPDCTransaction({
                mode: this.mode,
                applicationId: this.applicationId
            });
            this.initPage(this.response);
        } catch (error) {
            console.error(JSON.parse(JSON.stringify(error)));
        }
    };
}
