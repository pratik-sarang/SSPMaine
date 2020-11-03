import { LightningElement, api, track, wire } from "lwc";
//import {label_prescreening} from 'c/sspPrescreeningCustomLabels';
//import sspIcons from "@salesforce/resourceUrl/SSP_PreScreening";
//import sspIcons from "@salesforce/resourceUrl/SSP_ProgramPageResources";
import sspIcons from "@salesforce/resourceUrl/jsonFrameworkStaticResources";
import { CurrentPageReference } from "lightning/navigation";
import { NavigationMixin } from "lightning/navigation";

export class JsonFormField extends NavigationMixin(LightningElement) {
    @api
    name;

    @api
    formData;

    @api
    value = null;

    @api
    allFields;

    @api
    fieldLayout;

    @track
    fieldInfo;

    @track
    typ;

    @api
    customLabels;

    @api
    title = "";

    @api
    options;

    @api
    isHelpText = false;

    @api
    disableCond;

    @track
    hasError;

    @api
    errorMessages = [];

    @api
    helpTextContent;

    @track
    label;

    @track
    placeholder;

    @track
    badInputMsg;

    @track
    badPatternMsg;

    @track
    badTypeMsg;

    @track
    missValueMsg;

    @track
    formatter;

    @track
    step;

    @track
    stepMismatchMsg;

    @track
    rangeUnderflowMsg;

    @track
    pattern;

    @track
    maxLength;

    @track
    minLength;

    @track
    maxValue;

    @track
    minValue;

    @track
    fileTypes;

    @track
    requiredVar;

    @track
    helpText;

    @track
    subType;

    @track
    noticeType;

    @track
    noticeText;

    @track
    formattedText;

    @track
    img;

    @track
    altImg;

    @track
    cardTitle;

    @track
    gotoUrl;

    @track
    variant;

    @track
    modal;

    @track
    modalHeader;

    @track
    modalBody;

    @track
    modalFooter;

    @track
    action;

    @track
    gotoPage;

    @track
    imgTextContent;

    @track
    patternMismatchMsg;

    @track
    typeMismatchMsg;

    @track
    rangeOverflowMsg;

    @track
    btnTitle;

    @track
    hasButton;

    @track
    btnLabel;

    @track
    gotoPageType;

    @track
    resultCardBtnUrl;

    parentConnectedCallback (){
        this.fieldInfo = this.allFields[this.name];
        this.typ = this.fieldInfo.typ;
        const val = this.formData[this.name];
        if (val) {
            this.value = val;
        }
        this.initFieldProp();
    }

    /**
     * @function : initFieldProp
     * @description : Method to initialize various attributes used in loading the fields on the screen.
     */
    initFieldProp () {
        this.label = this.customLabels[this.fieldLayout.label];
        this.placeholder = this.fieldLayout.placeholder
            ? this.fieldLayout.placeholder
            : null;
        this.badInputMsg = this.fieldLayout.badInputMsg
            ? this.customLabels[this.fieldLayout.badInputMsg]
            : null;
        this.badPatternMsg = this.fieldLayout.badPatternMsg
            ? this.customLabels[this.fieldLayout.badPatternMsg]
            : null;
        this.badTypeMsg = this.fieldLayout.badTypeMsg
            ? this.customLabels[this.fieldLayout.badTypeMsg]
            : null;
        this.missValueMsg = this.fieldLayout.missValueMsg
            ? this.customLabels[this.fieldLayout.missValueMsg]
            : null;
        this.patternMismatchMsg = this.fieldLayout.patternMismatchMsg
            ? this.customLabels[this.fieldLayout.patternMismatchMsg]
            : null;
        this.typeMismatchMsg = this.fieldLayout.typeMismatchMsg
            ? this.customLabels[this.fieldLayout.typeMismatchMsg]
            : null;
        this.formatter = this.fieldLayout.formatter
            ? this.fieldLayout.formatter
            : null;
        this.step = this.fieldLayout.step ? this.fieldLayout.step : null;
        this.stepMismatchMsg = this.fieldLayout.stepMismatchMsg
            ? this.customLabels[this.fieldLayout.stepMismatchMsg]
            : null;
        this.rangeUnderflowMsg = this.fieldLayout.rangeUnderflowMsg
            ? this.customLabels[this.fieldLayout.rangeUnderflowMsg]
            : null;
        this.rangeOverflowMsg = this.fieldLayout.rangeOverflowMsg
            ? this.customLabels[this.fieldLayout.rangeOverflowMsg]
            : null;
        this.pattern = this.fieldLayout.pattern
            ? this.fieldLayout.pattern
            : null;
        this.maxLength = this.fieldLayout.maxLength
            ? this.fieldLayout.maxLength
            : null;
        this.minLength = this.fieldLayout.minLength
            ? this.fieldLayout.minLength
            : null;
        this.maxValue = this.fieldLayout.maxValue
            ? this.fieldLayout.maxValue
            : null;
        this.minValue = this.fieldLayout.minValue
            ? this.fieldLayout.minValue
            : null;
        this.fileTypes = this.fieldLayout.fileTypes
            ? this.fieldLayout.fileTypes
            : null;
        this.requiredVar = this.fieldLayout.required
            ? this.fieldLayout.required
            : null;
        this.helpText = this.fieldLayout.helpText
            ? this.fieldLayout.helpText
            : null;
        this.subType = this.fieldLayout.subType
            ? this.fieldLayout.subType
            : null;
        this.noticeType = this.fieldLayout.noticeType
            ? this.fieldLayout.noticeType
            : null;
        this.noticeText = this.fieldLayout.noticeText
            ? this.customLabels[this.fieldLayout.noticeText]
            : null;
        this.formattedText = this.fieldLayout.formattedText
            ? this.customLabels[this.fieldLayout.formattedText]
            : null;
        this.cardContent = this.fieldLayout.cardContent
            ? this.customLabels[this.fieldLayout.cardContent]
            : null;
        this.imgTextContent = this.fieldLayout.imgTextContent
            ? this.customLabels[this.fieldLayout.imgTextContent]
            : null;
        this.imgTextTitle = this.fieldLayout.imgTextTitle
            ? this.customLabels[this.fieldLayout.imgTextTitle]
            : null;
        this.img = this.fieldLayout.img
            ? sspIcons + "/icons/" + this.fieldLayout.img
            : null;
        this.altImg = this.fieldLayout.altImg ? this.fieldLayout.altImg : null;
        this.cardTitle = this.fieldLayout.cardTitle
            ? this.customLabels[this.fieldLayout.cardTitle]
            : null;
        this.gotoPage = this.fieldLayout.gotoPage
            ? this.fieldLayout.gotoPage
            : null;
        this.variant = this.fieldLayout.variant
            ? this.fieldLayout.variant
            : null;
        this.modal = this.fieldLayout.modal ? this.fieldLayout.modal : false;
        this.modalHeader = this.fieldLayout.modalHeader
            ? this.customLabels[this.fieldLayout.modalHeader]
            : null;
        this.modalBody = this.fieldLayout.modalBody
            ? this.customLabels[this.fieldLayout.modalBody]
            : null;
        this.modalFooter = this.fieldLayout.modalFooter
            ? this.customLabels[this.fieldLayout.modalFooter]
            : null;
        this.gotoUrl = this.fieldLayout.gotoUrl
            ? this.fieldLayout.gotoUrl
            : null;
        this.action = this.fieldLayout.action ? this.fieldLayout.action : null;
        this.btnTitle = this.fieldLayout.btnTitle
            ? this.customLabels[this.fieldLayout.btnTitle]
            : null;
        this.hasButton = this.fieldLayout.hasButton
            ? this.fieldLayout.hasButton
            : false;
        this.btnLabel = this.fieldLayout.btnLabel
            ? this.customLabels[this.fieldLayout.btnLabel]
            : null;
        this.gotoPageType = this.fieldLayout.gotoPageType
            ? this.fieldLayout.gotoPageType
            : null;
        this.resultCardBtnUrl = this.fieldLayout.resultCardBtnUrlLabel
            ? this.customLabels[this.fieldLayout.resultCardBtnUrlLabel]
            : null;
    }

    @wire(CurrentPageReference) pageRef;

    navigatePage () {
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: this.gotoUrl
                }
            });
        }
    }

    get disabled () {
        let isDisabled = null;
        if (this.disableCond) {
            isDisabled = this.disableCond[this.fieldLayout.uniqName]
                ? this.disableCond[this.fieldLayout.uniqName]
                : null;
        }
        return isDisabled;
    }
}
