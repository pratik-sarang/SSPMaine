/***
 * Component Name: sspSelectionCardWithoutRemoveIcon.
 * Author: Kyathi.
 * Description: This component is used to show user information without remove icon.
 * Date:12/11/2019.
 */
import { LightningElement, api } from "lwc";
import sspCardImages from "@salesforce/resourceUrl/SSP_Icons";
import startButton from "@salesforce/label/c.SSP_StartButton";
import editButton from "@salesforce/label/c.SSP_EditButton";
import progressIcon from "@salesforce/label/c.SSP_ProgressIcon";
import continueButton from "@salesforce/label/c.SSP_ContinueButton";
import sspView from "@salesforce/label/c.SSP_View";
import apConstants from "c/sspConstants";

export default class sspSelectionCardWithoutRemoveIcon extends LightningElement {
    /*displayEdit is a boolean value to display the edit button.If this property is not passed, button will not be displayed */

    @api displayEdit = false;
    @api hideButtons = false;
    @api cardId;
    @api buttonAltText;
    @api displayContinue = false;
    @api disabled = false;
    @api isViewButtonVisible = false;
    @api viewButtonAltText = sspView;

    label = {
        sspView,
        startButton,
        editButton,
        progressIcon,
        continueButton
    };

    checkedIconUrl = sspCardImages + apConstants.url.progressChecked;
    uncheckedIconUrl = sspCardImages + apConstants.url.progressNotStartedIcon;

    get sectionDisable () {
        return this.disabled;
    }

    /**
     * @function : handleButton
     * @description : This method is used to dispatch event for handle button.
     */
    handleButton () {
        try {
            const selectedButtonEvent = new CustomEvent(
                apConstants.events.buttonClick,
                {
                    detail: this.cardId
                }
            );

            this.dispatchEvent(selectedButtonEvent);
        } catch (error) {
            console.error("Error in handleButton", error);
        }
    }
}