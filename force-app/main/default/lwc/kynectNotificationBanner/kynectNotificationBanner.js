import { LightningElement, api } from "lwc";

export default class KynectNotificationBanner extends LightningElement {
    @api infoText = "";
    @api linkTitle = "";
    @api linkUrl = "";
}