/***
 * Component Name: sspSelectionCard.
 * Author: Chaitanya.
 * Description: This card shows user information.
 * Date: 12/11/2019.
 */
import { LightningElement, api } from "lwc";

export default class Assignment extends LightningElement {
    @api displayEditButton;
    @api displayStartButton;
    @api buttonValue;
}
