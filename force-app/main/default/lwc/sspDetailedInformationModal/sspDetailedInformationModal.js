/***
 * Component Name:sspDetailedInformationModal.js.
 * Author:P V.
 * Description: This is the Detailed Information Modal.It is a generic modal which pops up when an event is triggered.
 * Date:12/11/2019.
 */
import { LightningElement, api } from "lwc";
import sspClose from "@salesforce/label/c.SSP_Close";
import { events, generalConstants } from "c/sspConstants";
export default class LWCModalBoxDemo extends LightningElement {
    @api policyData;
    @api memberId;
    @api applicationId;
    @api coveredIndData;
    @api headerValue;
    @api openModel = false;
    @api isCoveredIndDeletion;
    @api openModelForExist = false;
    @api scrollEvent = false;
    @api scrollBottomEvent = false;
    _hideCrossIcon = true;
    @api
    get hideCrossIcon () {
        return this._hideCrossIcon;
    }
    set hideCrossIcon (value) {
        this._hideCrossIcon = value;
    }
    customLabel = {
        sspClose
    };
    @api openModal () {
        this.openModel = true;
    }
    @api reference;
    lastFocusElement;
    hasRendered=false;

    /**
     * @function : enableButtons
     * @description : Used to enable buttons on scroll.
     *  @param {object} event - Js event.
     */
    enableButtons (event) {
        const element = event.target;
        const paddingBottom = 30;
        if (
            element.scrollHeight - element.scrollTop <=
            element.clientHeight + paddingBottom
        ) {
            this.dispatchEvent(CustomEvent(events.enableModalButtons));
        }
    }
    /**
     * @function - closeModal
     * @description - Method is used to close the modal.
     */
    closeModal () {
        try {
            this.openModel = false;
            this.openModel = "";
            window.document.body.style.overflow = "";
            this.dispatchEvent(CustomEvent(events.closeModal));
        } catch (error) {
            console.error("Error in closeModal", error);
        }
    }

   /**
    * @function : handleLastFocus
    * @description : handle the key down event from modal last button.
    * @param {object} event - Js event.
    */
    handleLastFocus = (event) =>{
        try {
            if (event.key === "Tab" && !event.shiftKey) {
                event.preventDefault();
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    const headerReference = this.template.querySelector(
                        ".ssp-modalHeadingText"
                    );
                    if (headerReference) {
                        headerReference.focus();
                    }
                }, 100);
            }
        }
        catch (error) {
            console.error("Error in handleLastFocus in sspDetailedInformationModal", error);
        }
    }

    /**
     * @function : handleHeaderFocus
     * @description : handle header focus.
     *  @param {object} event - Js event.
     */
    handleHeaderFocus = (event) => {
        try {
            if (event.key === "Tab") {
                if (event.shiftKey) {
                    // eslint-disable-next-line @lwc/lwc/no-async-operation
                    setTimeout(() => {
                        if (this.reference && this.lastFocusElement) {
                            this.lastFocusElement.focus();
                        }
                    }, 0);
                }
            }
        }
        catch (error) {
            console.error("Error in handleHeaderFocus in sspDetailedInformationModal", error);
        }
    }
    @api
    lessContentEnableButtons (){
        const element = this.template.querySelector(
            ".slds-modal__content"
        );
        const paddingBottom = 30;
        if (
            element.scrollHeight - element.scrollTop <=
            element.clientHeight + paddingBottom
        ) {
            this.dispatchEvent(CustomEvent(events.enableModalButtons));
        }
    }

    /**
     * @function - renderedCallback
     * @description - Method is used to make changes in html after the render.
     */
    renderedCallback () {
        try {
            const headerReference = this.template.querySelector(
                ".ssp-modalHeadingText"
            );
            let footerTabAbleElements=[];
            let contentTabAbleElements=[];
            const focusElementsString = generalConstants.focusElementsString;
            if (!this.hasRendered){
                if (headerReference) {
                    headerReference.focus();
                    window.document.body.style.overflow = "hidden";
                }
                else {
                    window.document.body.style.overflow = "";
                }
            }
            this.hasRendered = false;
            if (this.scrollEvent) {
                this.template
                    .querySelector(".slds-modal__content")
                    .addEventListener("scroll", this.enableButtons.bind(this));
           
                if (!this.hasRendered) {
                    if (
                        this.template.querySelector(".slds-modal__content") &&
                        this.template.querySelector(".slds-modal__content")
                            .clientHeight >
                            this.template.querySelector(".slds-modal__content")
                                .scrollHeight
                    ) {
                        this.dispatchEvent(
                            CustomEvent(events.enableModalButtons)
                        );
                    }
                }
            }
            if (this.reference && !this.hasRendered){
                footerTabAbleElements = this.reference.template.querySelectorAll(".slds-modal__footer lightning-button");
                contentTabAbleElements = this.template.querySelectorAll(`.slds-modal__header ${focusElementsString}`);
                if (footerTabAbleElements.length){  
                    this.lastFocusElement = footerTabAbleElements[footerTabAbleElements.length - 1];
                    if (this.lastFocusElement){
                        this.lastFocusElement.addEventListener(events.keyDown, this.handleLastFocus.bind(this));
                    } 
                }
                else if (contentTabAbleElements.length){
                    this.lastFocusElement = contentTabAbleElements[contentTabAbleElements.length - 1];
                    if (this.lastFocusElement){
                        this.lastFocusElement.addEventListener(events.keyDown, this.handleLastFocus.bind(this));
                    }
                }
                if (this.scrollBottomEvent && this.scrollEvent && this.reference.template.querySelector(".ssp-last-focus-element")){
                    this.reference.template.querySelector(".ssp-last-focus-element").addEventListener("blur", this.handleLastScroll.bind(this));
                }
            }
            this.hasRendered=true;
        } catch (error) {
            console.error("Error in renderedCallback", error);
        }
    }
    /**
     * @function - handleLastScroll
     * @description - Method is used to move scroll bar to the bottom.
     */
    handleLastScroll = () =>{
        try{
            if (this.template.querySelector(".slds-modal__content")) {
                this.template.querySelector(".slds-modal__content").scrollTop = this.template.querySelector(".slds-modal__content").scrollHeight;
            }
        }
        catch(error){
            console.error(error);
        }
    }

    /**
     * @function - disconnectedCallback
     * @description - Method is called when component is removed.
     */
    disconnectedCallback () {
        try {
            window.document.body.style.overflow = "";
        } catch (error) {
            console.error("Error in disconnectedCallback", error);
        }
    }
}
