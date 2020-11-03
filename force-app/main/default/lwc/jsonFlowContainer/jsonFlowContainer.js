/*
 * Component Name: jsonFlowContainer.
 * Author: Narapa
 * Description: This will be the place holder for the Navigation flow detail Metadata and 
 *              renders the various fields provided in the Object Schema on  UI
 * Date: 05/25/2020.
 */
import { LightningElement, api, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { formatLabels } from "c/sspUtility";
import { labelPrescreening } from "c/sspPrescreeningCustomLabels"; //Importing Custom Labels
import getFlowInitData from "@salesforce/apex/JsonFlowController.getFlowInitData";
import getPageInfo from "@salesforce/apex/JsonFlowController.getPageInfo";
import exec from "@salesforce/apex/JsonFlowController.exec";
import sectionDetail from "@salesforce/label/c.SSP_SectionDetail";
import formFactorPropertyName from "@salesforce/client/formFactor";

export default class JsonSchemaFlowContainer extends NavigationMixin(
    LightningElement
) {
	@api flowName;

	@api recordId = null;

	@api retPage = null;

	@api programType ;

	@track navFlowDetail;

	@track navFlowPageConfig;

	@track layoutSchema;

	@track pageInfo;

	@track objectData;

	objectPrevData;

	@track objectSchema;

	@track isInit = false;

	@track isPageReady = false;

	@track showSpinner = false;

	@track hasError = false;

	@track curPageIndex;

	@track renderingCond;

	@track disableCond;

	@track navButtonFields;

	@track allFields;

	@track showModalWindow = false;

	@track modalHeader;

	@track modalBody;

	@track modalFooter;

	// TODO need to get user profile from Apex
    profile = "Guest";

	dynamicPropSchema;

	allPageConfigIds;

	progressPageCount = 0;

	@track validationFailed = false;

	@track trueValue = true;

    labelPrescreening = labelPrescreening; //assigning the imported labels to a local variable

	finalRedirectionPage;

	// Injects the page reference that describes the current page
	@wire(CurrentPageReference)
	setCurrentPageReference (currentPageReference) {
		this.currentPageReference = currentPageReference;
		if (this.currentPageReference.state.retPage) {
			this.retPage = this.currentPageReference.state.retPage;
			this.programType = this.currentPageReference.state.programType;
		}
	}

	/**
   * @function : connectedCallback
   * @description : This method is called when html is attached to the component.
   */
    connectedCallback () {
		this.showSpinner = true;
	}

    //Whenever the flow name is selected and the flowName is changed
    //this wire adapter provisions data for the component
    @wire(getFlowInitData, {
        recordId: "$recordId",
        flowName: "$flowName"
    })
	wireJsonSchema ({ error, data }) {
		try {
			if (data) {
				if (data.pageConfData.navFlowDetail) {
                    //initializing various component attributes based on Navigation Flow detail meta data record
                    //whose developer name is flowName being passed in wire adapter
					this.initFlowDetails(data.pageConfData.navFlowDetail);
					this.loadPage(data);
					this.isInit = true;
				}
			} else if (error) {
				this.jsonSchema = undefined;
                this.showToast("Error", JSON.stringify(error), "error");
			}
			this.showSpinner = false;
        } catch (e) {
            console.error(
                "failed in wireJsonSchema in jsonFlowContainer" +
                    JSON.stringify(error)
            );
        }
	}

    /**
     * @function : initFlowDetails
     * @description : Method to initialize component Parameters based on the Navigation Flow Detail Metadata Record.
     * @param {object} navFlowDetail - Navigation Flow Detail Metadata record.
     */
	initFlowDetails (navFlowDetail) {
		this.navFlowDetail = navFlowDetail;
		this.objectSchema = JSON.parse(this.navFlowDetail.JsonObjectSchema__c);
		this.objectData = new Object();
		this.objectPrevData = Object.assign({}, this.objectData);
		if (this.navFlowDetail.Navigation_Flow_Page_Configuration__r) {
			this.allPageConfigIds = new Array();
            Object.keys(this.navFlowDetail
                .Navigation_Flow_Page_Configuration__r).forEach(i => {
                    const navPage = this.navFlowDetail
                    .Navigation_Flow_Page_Configuration__r[i];
                //getting all the record Id's of child Navigation Flow Page Configuration records
                //belonging to Navigation Flow Detail record and storing in an array
				this.allPageConfigIds.push(navPage.Id);
				if (!navPage.IsExcludedInProgress__c) {
                        //Increment the counter to obtain total number of sections
                    //to use the information in showing Subheading on the page like "Section 1 of 3 "
					this.progressPageCount++;
				}
                });
			}
		}

    /*
     * @function : loadPage
     * @description : Method to initialize component Parameters based on the Page info record details of
     * Navigation Flow Page Metadata record,which is child of Navigation Flow Detail record.
     * @param {event} resp- JsonPageResponse object.
     */
    loadPage (resp) {
        window.scrollTo({ top: 0, left: 0, behavior: "smooth"});
		this.pageInfo = resp.pageConfData.pageInf;
		this.navFlowPageConfig = resp.pageConfData.pageInf.navFlowPageConfig;
        this.layoutSchema = JSON.parse(
            this.navFlowPageConfig.PageInfo__r.JsonLayoutSchema__c
        );
        this.setAllFields(); //method to set allFields attribute of the jsonFlowContainer
		if (resp.pageObjectData) {
			this.objectData = resp.pageObjectData;
		}
        this.curPageIndex = this.getCurPageIndex(); //method to get current page Index from allPageConfigIds attribute
		this.isPageReady = true;
		this.renderingCond = new Object();
		this.disableCond = new Object();
        this.initDynamicProps(); //method to populate attribute dynamicPropSchema
		this.computeDynamicProps();
	}

    /*
     * @function : setAllFields
     * @description : Method to set all fields attribute of the component with the information about all the fields
     *                being populated on the page of a jsonFlowContainer.
     */
	setAllFields () {
		this.allFields = new Object();
        // start with fields from the layout. This will ensure read-only fields are added
        //getting information about all fields from fields array of layoutSchema
		if (this.layoutSchema && this.layoutSchema.fields) {
            Object.keys(this.layoutSchema.fields).forEach(j => {
                        const fieldName = this.layoutSchema.fields[j].name;
                        this.allFields[fieldName] = this.layoutSchema.fields[j];
                    });
		}
        //getting information about all fields from navButtons array of layoutSchema
		if (this.layoutSchema && this.layoutSchema.navButtons) {
            Object.keys(this.layoutSchema.navButtons).forEach(m => {
                    const fieldName = this.layoutSchema.navButtons[m].name;
                    this.allFields[fieldName] = this.layoutSchema.navButtons[m];
                });
		}
        // now, add the fields from the object.
		if (this.objectSchema && this.objectSchema.fields) {
			if (!this.allFields) {
				this.allFields = new Object();
			}
            Object.keys(this.objectSchema.fields).forEach(k => {
                    const fieldName = this.objectSchema.fields[k].name;
                    let field = this.allFields[fieldName];
				//If field is already added from layout schema then merge the properties from object schema
				if (field) {
                    field = {
                        ...field,
                            ...this.objectSchema.fields[k]
                    }; //merging the information about field from layoutSchema and ObjectSchema
				} else {
                        field = this.objectSchema.fields[k];
				}
				this.allFields[fieldName] = field;
                });
		}
	}

	initPageLoad (pageToLoadId) {
		this.isPageReady = false;
        getPageInfo({
            recordId: this.recordId,
            pageConfigId: pageToLoadId
        })
            .then(result => {
				this.isPageReady = true;
				this.loadPage(result);
			})
            .catch(error => {
				this.isPageReady = true;
				this.jsonSchema = undefined;
                this.showToast("Error", JSON.stringify(error), "error");
			});
	}

    /**
     * @function : initDynamicProps
     * @description : Populating dynamicPropSchema with fields whose display of enabling them
     *                is dependent on other fields on the page and their information.
     */
	initDynamicProps () {
		this.dynamicPropSchema = new Object();
        //when we use this key word inside the below for loop it refers
        //to parameter being looped
        //to access the components inside for loop with "this" keyword we are assigning
        //the component to the variable "$this"
        const $this = this;
        Object.keys( $this.allFields).forEach(fieldName => {
			if ($this.allFields.hasOwnProperty(fieldName)) {
                    const field = $this.allFields[fieldName];
				if (field.dependFields) {
                        const dFieldNames = field.dependFields.split(",");
					if (dFieldNames) {
                        //dynamicPropSchema Map holds the field name with dependent fields, Array having Information about each dependent field
						$this.dynamicPropSchema[field.uniqName] = new Array();
						dFieldNames.forEach(function (dFieldName) {
                                const dFieldNameTrimmed = dFieldName.trim();
                                const dField = $this.getDependentField(dFieldNameTrimmed); //method call to get the information about the dependent field
							if (dField) {
                                $this.dynamicPropSchema[field.uniqName].push(
                                    dField
                                );
							}
						});
					}
				}
			}
            });
	}

    /**
     * @function : computeDynamicProps
     * @description : Method calls for refreshDynamicProps methods to calculate if the fields need to be displayed
     *                or enabled based on the other fields values.
     */
	computeDynamicProps () {
		if (this.dynamicPropSchema) {
            Object.keys(this.dynamicPropSchema).forEach(fieldName => {
				if (this.dynamicPropSchema.hasOwnProperty(fieldName)) {
					this.refreshDynamicProps(fieldName);
				}
                });
		}
	}

    /*
     * @function : refreshDynamicProps
     * @description : Method calls for refreshDisplayCondn methods to calculate if the fields need to be displayed
     * and refreshEnableCondn to enable fields based on the other fields values.
     * @param curFieldName
     */
	refreshDynamicProps (curFieldName) {
        const $this = this;
        const dFields = this.dynamicPropSchema[curFieldName];
		if (dFields) {
			dFields.forEach(function (dField) {
				if (dField.dynaprops) {
					//Check display conditions
					$this.refreshDisplayCondn(dField);
					$this.refreshEnableCondn(dField);
				}
			});
		}
	}

    /*
     * @function : refreshDisplayCondn
     * @description : Method to refresh display condition of a field (whether a field must be displayed
     * on a page or not).
     *   @param {object} dField - Dependent field.
     */
	refreshDisplayCondn (dField) {
		if (dField.dynaprops.display) {
            const $this = this;
			// TODO for now handling only the first condition. Need to enhance to process multiple conditions
            const renderCondn = dField.dynaprops.display[0];
            const value = $this.objectData[renderCondn.field];
			switch (renderCondn.op) {
                case "EQ":
                    //populating renderingCond Map Object with
                    //uniqName of the field , Whether field must be displayed or not (based on the value of the field on which current field depends)
                    $this.renderingCond[dField.uniqName] =
                        value == renderCondn.value;
					break;
				// TODO add other operators
			}
		}
	}

    /**
     * @function : refreshEnableCondn
     * @description : Method to refresh enable condition of a button/field (whether a button/field must be enabled
     * on a page or not).
     *   @param {object} dField - Dependent field.
     */
	refreshEnableCondn (dField) {
		if (dField.dynaprops.enabled) {
            const $this = this;
			// TODO for now handling only the first condition. Need to enhance to process multiple conditions
            const renderCondn = dField.dynaprops.enabled[0];
            const value = $this.objectData[renderCondn.field];
			switch (renderCondn.op) {
                case "EQ":
                    //populating disableCond Map Object with
                    //uniqName of the field , Whether field must be enabled or disabled (based on the value of the field on which current field depends)
                    $this.disableCond[dField.uniqName] = !(
                        value == renderCondn.value
                    );
					break;
				// TODO add other operators
			}
		}
	}

    /*
     * @function : getDependentField
     * @description : Method to get information about the dependent field.
     *   @param {object} dField - Dependent field.
     */
    getDependentField (dFieldName) {
        let dField;
		Object.values(this.allFields).forEach(function (field) {
			if (dFieldName == field.uniqName) {
				if (field.dynaprops) {
					dField = field;
				}
				return;
			}
		});
		return dField;
	}

	get progressSummary () {
        return formatLabels(sectionDetail, [
            parseInt(this.curPageIndex),
            this.progressPageCount
        ]);
	}

	get progressPercent () {
        return Math.floor(
            (parseInt(this.curPageIndex) * 100) / this.progressPageCount
        );
	}

	get progressBarStyle () {
		return `width: ${this.progressPercent}%`;
	}

	// set the values from field change
    /*
     * @function : handleFieldChange
     * @description : Method to handle the field change occurring at each of the child of jsonFormElement.
     *   @param {event} event -  Js event.
     */
	handleFieldChange (event) {
        this.objectData[event.detail.name] = event.detail.value; //Populating the objectData with the fieldName and its value
        //refreshing the dynamic props to render hidden fields or enable disable buttons based on
        //answered field values on the page
		this.refreshDynamicProps(event.detail.name);
	}

    /**
     * @function : handleNavButtonClick
     * @description : When button is clicked on the jsonFlowNavButtons it generates an event
     * and the event is handled on jsonFlowContainer(current component).
     * @param {event} event - Js event.
     */
	handleNavButtonClick (event) {
        const action = event.detail.action;
		switch (action) {
            case "next":
				this.handleNext();
				break;
            case "submit":
				this.handleSubmit();
				break;

            case "back":
				this.handleBack();
				break;

            case "exit":
				this.handleExit();
				break;

            case "gotopage":
				this.navigateToPage(event.detail.gotopage);
				break;
		}
	}

    /**
     * @function : handleNext
     * @description : When next button is clicked this method validates the fields on the current page
     *                and when the validation is success, next page loads.
     */
	handleNext () {
		this.validate();

		if (!this.hasError) {
			this.isPageReady = false;
            this.callFlowAction("next");
		}
	}

	handleSubmit () {
		this.validate();
		if (!this.hasError) {
			this.isPageReady = false;
            this.callFlowAction("submit");
		}
	}

	handleBack () {
        const pageToLoadId = this.getPageToLoadId("back");
		if (null != pageToLoadId) {
			this.initPageLoad(pageToLoadId);
		}
	}

	handleExit () {
		if (!this.retPage) {
			// default to home page
            this.retPage = "Home";
		}
		try {
			this.navigateToPage(this.retPage);
        } catch (e) {
            console.error(
                "failed in handleExit in jsonFlowContainer" + JSON.stringify(e)
            );
        }
	}

	callFlowAction (action) {
		try {
			this.hasError = false;
            const req = {
				action: action,
				recordId: this.recordId,
				data: JSON.stringify(this.objectData),
				pageName: this.navFlowPageConfig.PageInfo__r.PageName__c,
				flowId: this.navFlowDetail.Id,
				pageConfigId: this.navFlowPageConfig.Id,
				allPageConfigIds: this.allPageConfigIds
			};
			exec(req)
                .then(result => {
					this.isPageReady = true;
					if (result.vMessage) {
						// TODO throw validation messages
					} else {
						this.loadPage(result);
					}
				})
                .catch(error => {
					this.hasError = true;
					this.isPageReady = true;
					this.jsonSchema = undefined;
                    this.showToast("Error", JSON.stringify(error), "error");
				});
		} catch (e) {
            console.error(
                "failed in callFlowAction in jsonFlowContainer" +
                    JSON.stringify(e)
            );
		}
	}

    /**
     * @function : loadPage
     * @description : Method to get the current Page Index which can be used in showing the Subheading
     *                like "Section 1 of 3".
     */
	getCurPageIndex () {
        //loadPage method sets navFlowPageConfig and we are obtaining the record Id of
        //Navigation Flow Page Configuration Record Id
        const curPageId = this.navFlowPageConfig.Id;
        let pageIndex;
        //In allPageConfigIds obtained from Navigation Flow Page Configuration records
        //belonging to Navigation Flow Detail record , obtaining index when Ids match
        const BreakException = {};
        try {
            Object.keys(this.allPageConfigIds).forEach(i => {
			if (curPageId == this.allPageConfigIds[i]) {
				pageIndex = i;
                        throw BreakException;
                    }
                });
        }
        catch (e) {
            if (e !== BreakException) {
                console.error(
                    "failed in getCurPageIndex in jsonFlowContainer" +
                        JSON.stringify(e)
                );
			}
		}
		return pageIndex;
	}

	getPageToLoadId (action) {
        let pageToLoadId = null;
        let pageIndex = this.getCurPageIndex();
        if ("next" == action) {
			if (pageIndex == this.allPageConfigIds.length - 1) {
				pageToLoadId = null;
			} else {
				pageIndex++;
				pageToLoadId = this.allPageConfigIds[pageIndex];
			}
        } else if ("back" == action) {
			if (pageIndex == 0) {
				pageToLoadId = null;
			} else {
				pageIndex--;
				pageToLoadId = this.allPageConfigIds[pageIndex];
			}
		}
		return pageToLoadId;
	}

	navigateToPage (page) {
		this[NavigationMixin.Navigate]({
            type: "comm__namedPage",
			attributes: {
				name: page
			},
            state:{
                program: this.programType
            }
		});
	}

    /**
     * @function : validate
     * @description : This method helps in validating the fields on the page. This method calls
     *                isValid method on the child component (c-json-schema-page).
     */
	validate () {
		this.hasError = false;
		this.validationFailed = false;
        let validationResult = [];
        validationResult = this.template
            .querySelector("c-json-schema-page")
            .isValid();
		if (validationResult.includes(false)) {
			this.hasError = true;
			this.validationFailed = true;
		}
	}

	get isNewPageLoad () {
		//var isReady = this.isPageReady && !this.hasError;
		// reset the hasError flag
		//this.hasError = false;
        const isReady = this.isPageReady;
		//this.isPageReady = !this.isPageReady;
		return isReady;
	}

	showToast (title, message, variant) {
		this.dispatchEvent(
			new ShowToastEvent({
				title: title,
				message: message,
				variant: variant
			})
		);
	}

	get pageTitle () {
		return this.labelPrescreening[this.layoutSchema.pageTitle];
	}

    get isImgTitle () {
        if (this.layoutSchema.isImgTitle)
        {
            return true;
        }
        return false;
    }

    get imgContainerStyle () {
        let cssStyle = "";
            if (formFactorPropertyName === "Small" && this.layoutSchema.imgMobile) {
                cssStyle += "background-image:" + this.layoutSchema.imgMobile + ";";
            }
            else if (this.layoutSchema.imgDesktop) {
                cssStyle += "background-image:" + this.layoutSchema.imgDesktop + ";";
            }
        return cssStyle;
    }

	get flowTitle () {
		return this.labelPrescreening[this.navFlowDetail.FlowDisplayName__c];
	}

	get pageSubtitle () {
		return this.labelPrescreening[this.layoutSchema.pageSubtitle];
	}

	get hasBackButton () {
        return (
            this.curPageIndex > 0 &&
            !this.navFlowPageConfig.IsFinalSummaryPage__c
        );
	}

	get isSubmitPage () {
		return this.layoutSchema.isSubmitPage;
	}

	get isFinalSummaryPage () {
		return this.navFlowPageConfig.IsFinalSummaryPage__c;
	}

	get isExcludedInProgress () {
		return this.navFlowPageConfig.IsExcludedInProgress__c;
	}

	get summaryGoToButton () {
		// determine which button needs to be displayed. Return only one button.
        let btn = null;
        if (
            this.navFlowPageConfig.IsFinalSummaryPage__c &&
            this.layoutSchema.navBtns
        ) {
			btn = this.layoutSchema.navBtns[0];
			this.finalRedirectionPage = btn.gotoPage;
            btn.originalLabel = this.labelPrescreening[
                this.layoutSchema.navBtns[0].label
            ];
		}
		return btn;
	}

	get backLabel () {
        return this.labelPrescreening["sspBack"];
	}

	get exitLabel () {
        return this.labelPrescreening["sspExit"];
	}

    get nextLabel () {
        return this.labelPrescreening["sspNext"];
	}

	get submitLabel () {
        return this.labelPrescreening["sspSubmit"];
	}

    /*
     * @function : handleLinkClick
     * @description : When link kind of button is clicked and modals must be opened, this method handles the operation.
     */
	handleLinkClick (event) {
		this.showModalWindow = true;
		this.modalHeader = event.detail.modalHeader;
		this.modalBody = event.detail.modalBody;
		this.modalFooter = event.detail.modalFooter;
	}

    /**
     * @function : handleCloseModal
     * @description : On clicking on close button of the modal , this method hides the modal window.
     *
     */
	handleCloseModal () {
		this.showModalWindow = false;
	}

	/*
   * @function    : hideToast
   * @description : Method to hide Toast
   */
	hideToast = () => {
		try {
			this.validationFailed = false;
		} catch (error) {
            console.error(
                "Error occurred in error toast:",
                JSON.stringify(error.message)
            );
		}
	};

	/**
     * @function : redirectToPreScreeningTool.
   * @description : redirect User to PreScreening Tool.
   */

    redirectAwayFromFinalPage (){
		{
			this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
				attributes: {
					name: this.finalRedirectionPage
				}
			});
		}
	}
}
