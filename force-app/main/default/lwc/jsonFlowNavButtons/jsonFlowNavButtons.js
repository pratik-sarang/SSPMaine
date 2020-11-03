/*
 * Component Name: JsonFormToggle
 * Author: Narapa 
 * Description: Component to generate the Navigation flow Buttons like Back, Next, Submit on the jsonFlowContainer
 * Date: 05/27/2020.
 */
import { LightningElement, api } from "lwc";

export default class JsonFlowNavButtons extends LightningElement {
    @api
    curPageIndex;

    @api
    navFlowPageConfig;

    @api
    customLabels;

    @api
    layoutSchema;
    
    @api
    objectData;

    @api
    allFields;

    @api
    renderingCond;

    @api
    disableCond;

    get hasBackButton (){
        return (
            this.curPageIndex > 0 &&
            !this.navFlowPageConfig.IsFinalSummaryPage__c
        );
    }

    get backLabel () {
        const backBtnLabel = this.layoutSchema.backBtnLabel
            ? this.customLabels[this.layoutSchema.backBtnLabel]
            : this.customLabels["sspBack"];
        return backBtnLabel;
    }

    get backTitle () {
        const backBtnTitle = this.layoutSchema.backBtnTitle
            ? this.customLabels[this.layoutSchema.backBtnTitle]
            : this.customLabels["sspBackTitle"];
        return backBtnTitle;
    }
    get exitLabel () {
        const exitBtnLabel = this.layoutSchema.exitBtnLabel
            ? this.customLabels[this.layoutSchema.exitBtnLabel]
            : this.customLabels["sspExit"];
        return exitBtnLabel;
    }

    get exitTitle () {
        const exitBtnTitle = this.layoutSchema.exitBtnTitle
            ? this.customLabels[this.layoutSchema.exitBtnTitle]
            : this.customLabels["sspStartPsToolExitTitle"];
        return exitBtnTitle;
    }

    get nextLabel () {
        const nextBtnLabel = this.layoutSchema.nextBtnLabel
            ? this.customLabels[this.layoutSchema.nextBtnLabel]
            : this.customLabels["sspNext"];
        return nextBtnLabel;
    }

    get nextTitle () {
        const nextBtnTitle = this.layoutSchema.nextBtnTitle
            ? this.customLabels[this.layoutSchema.nextBtnTitle]
            : this.customLabels["sspNextTitle"];
        return nextBtnTitle;
    }

    get submitLabel () {
        const submitBtnLabel = this.layoutSchema.submitBtnLabel
            ? this.customLabels[this.layoutSchema.submitBtnLabel]
            : this.customLabels["sspSubmit"];
        return submitBtnLabel;
    }

    get submitTitle () {
        const submitBtnTitle = this.layoutSchema.submitBtnTitle
            ? this.customLabels[this.layoutSchema.submitBtnTitle]
            : this.customLabels["sspSubmitTitle"];
        return submitBtnTitle;
    }

    get isSubmitPage () {
        return this.layoutSchema.isSubmitPage;
    }

    get isFinalSummaryPage () {
        return this.navFlowPageConfig.IsFinalSummaryPage__c;
    }

    get summaryGoToButton () {
        // determine which button needs to be displayed. Return only one button.
        let btn = null;
        if (
            this.navFlowPageConfig.IsFinalSummaryPage__c &&
            this.layoutSchema.navBtns
        ) {
            btn = this.layoutSchema.navBtns[0]; 
            btn.label = this.customLabels[this.layoutSchema.navBtns[0].label];
        }
        return btn;
    }

    get hasNavButtons () {
        return this.layoutSchema.navButtons;
    }

    handleNavAction (event) {
        event.preventDefault();
        const dtl = new Object();
        dtl.action = event.currentTarget.dataset.navaction;
        dtl.gotopage = event.currentTarget.dataset.gotopage;
        const navEvent = new CustomEvent("navbuttonclick", {
            detail: dtl,
            bubbles: true
          });
          this.dispatchEvent(navEvent);
    }
}
