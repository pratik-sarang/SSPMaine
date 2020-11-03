/*
 * Component Name: JsonFormToggle
 * Author: Narapa 
 * Description: Component to generate lightning buttons in jsonFormElement
 * Date: 05/27/2020.
 */
import { track,} from "lwc";
import { JsonFormField } from "c/jsonFormField";
import pageUrl from "@salesforce/resourceUrl/captchaDemo";
import constants from "c/sspConstants";

export default class JsonFormButton extends JsonFormField {
  @track captchaVFPage = pageUrl;

    connectedCallback () {
    this.parentConnectedCallback();
        //Listening to get the message if not a robot captcha is
        //successfully clicked and gives information to enable buttons
        //dependent on captcha
    try {
      if (window.addEventListener) {
                window.addEventListener(
                    "message",
                    this.handleCaptchaClick.bind(this)
                );
      } else {
        window.attachEvent("onmessage", this.listenMessage); //TODO:Check this listen message
      }
    } catch (error) {
      console.error("Error in connectedCallback:", error);
    }
  }

    //to check if the button is of the subType Link
    get isLinkButton () {
    return "link" == this.subType;
  }

    //to check if the button is of the subType navFlowButton
    get isNavFlowButton (){
    return "navFlowButton" == this.subType;
  }

    //to check if the button is of the subType captchaButton
    get isCaptchaButton () {
    return "captchaButton" == this.subType;
  }

    //method to provide the button class which changes the color and style of the button
    get buttonClass () {
        let cls = " ssp-footerBtnBackSave ssp-button_base dd-zindexDisable";
    if (this.variant) {
      cls = "slds-text-align_right ssp-footerBtnNext ssp-button_neutral dd-zindexDisable";
    }
    return cls;
  }

    get buttonTitle () {
        return this.btnTitle;
    }

    /**
     * @function : linkClick
     * @description : When a button is of the type Link and it should open a modal, This method
     *                fires event with required Modal Information which will be handled in the parent
     *                jsonFlowContainer.
     */
    linkClick () {
    if (this.modal === true) {
      const linkClickEvent = new CustomEvent("linkclick", {
        detail: {
          modalHeader: this.modalHeader,
          modalBody: this.modalBody,
          modalFooter: this.modalFooter
        },

        bubbles: true
      });
      this.dispatchEvent(linkClickEvent);
    }
  }

    /*
 * @function : handleNavAction
 * @description : On click of the Navigation button an event is generated which will be handled
 * on the parent jsonFlowContainer.
 * @param {event} event- JS event
 */
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

    /*
 * @function : handleCaptchaClick
 * @description : When captcha is clicked and verification is a success which fires the change event
 * that will be handled in the parent jsonFlowContainer and the buttons or fields that can be
 * rendered/enabled is calculated.
 * @param {event} evt - JS event
 */
    handleCaptchaClick (evt) {
    try {
      const dtl = new Object();
      dtl.name = "sspPsToolCaptcha";
            dtl.value =
                evt.data === constants.shortSNAPFlowConstants.Unlock
                    ? "unlocked"
                    : "locked";
      const changeEvent = new CustomEvent("fieldchange", {
        detail: dtl,
        bubbles: true
      });
      this.dispatchEvent(changeEvent);
    } catch (error) {
      console.error("Error in handleCaptchaClick", error);
    }
  }
}
