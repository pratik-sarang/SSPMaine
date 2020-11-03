import {
    LightningElement,
    api
} from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspConstants from "c/sspConstants";
export default class SspGenericDashboardCard extends LightningElement {

    @api cardHeader;
    @api linkUrl;
    @api showArrow = false;

    @api iconUrl = sspIcons + "/sspIcons/ic_next@3x.png";
    onIconClick () {
        this.dispatchEvent(
            new CustomEvent(
                sspConstants.events.iconClick,
                {
                    detail: "icon click"
                }
            )
        );
    }
}