/***
 * Component Name: sspSpinner.js.
 * Author: P V.
 * Description: This is component shows spinner.
 * Date: 03/01/2020.
 */
import { LightningElement } from "lwc";
import sspLoadingIcon from "@salesforce/resourceUrl/sspLoadingIcon";
import apConstants from "c/sspConstants";

export default class SspSpinner extends LightningElement {
    loadingSpinner = sspLoadingIcon + apConstants.url.spinner;
}
