/**
 * Component Name: sspSelectionSummaryCards.
 * Author: P V.
 * Description: This a component which shows summary information in a card.
 * Date: 12/11/2019.
 */
import { LightningElement, api } from "lwc";
import sspProgressIcon from "@salesforce/label/c.SSP_ProgressIcon";
import apConstants from "c/sspConstants";

import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import sspSave from "@salesforce/label/c.SSP_Save";

export default class AssignmentTwo extends LightningElement {
    label = {
        sspProgressIcon,
        sspSave
    };
    progressNotStartedIconUrl =
        sspIcons + apConstants.url.progressNotStartedIcon;
    disagreeIconUrl = sspIcons + "/sspIcons/ic_disagree@3x.png";
    progressCheckedIconUrl = sspIcons + "/sspIcons/ic_progress_checked@3x.png";
    @api titleValue;
    @api isProgressStarted = false;
    @api isProgressComplete = false;
}
