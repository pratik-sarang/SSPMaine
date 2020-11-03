import { api } from "lwc";
import sspIcons from "@salesforce/resourceUrl/SSP_Icons";
import apConstants from "c/sspConstants";

import BaseNavFlowPage from "c/sspBaseNavFlowPage";

import sspBackgroundIcons from "@salesforce/resourceUrl/SSP_CD2_Icons";

import sspAccessDenied from "@salesforce/label/c.sspAccessDenied";
import sspYouDoNotHaveAccess from "@salesforce/label/c.sspYouDoNotHaveAccess";
import sspAccessScreenFromBookmark from "@salesforce/label/c.sspAccessScreenFromBookmark";
import sspBookmarkHomePage from "@salesforce/label/c.sspBookmarkBenefindHomePage";

export default class SspAccessDenied extends BaseNavFlowPage {
    @api Access;
    needsReviewIconUrl = sspIcons + apConstants.url.needsReviewIcon;
    searchIcon = sspBackgroundIcons + "/sspIcons/background_copy@3x.png";

    labels = {
        sspAccessDenied,
        sspYouDoNotHaveAccess,
        sspAccessScreenFromBookmark,
        sspBookmarkHomePage
    };
}