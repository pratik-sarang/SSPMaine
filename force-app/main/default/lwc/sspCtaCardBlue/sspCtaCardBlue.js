import { LightningElement, api } from "lwc";

export default class SspCtaCardBlue extends LightningElement {
    @api sspTitleValue;
    @api sspSubtitleValue;
    @api sspButtonLabel; //put the label you want to give to the button here
}