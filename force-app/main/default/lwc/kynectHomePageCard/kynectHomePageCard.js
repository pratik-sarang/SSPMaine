/*
 * Component Name: KynectHomePageCard.
 * Author: Narapa
 * Description: Component for Showing Benefits, Resources, Health Coverage Cards on the Home Page 
 *               for Kynect Community          
 * Date: 09/02/2020.
 * Task : 390945
 */
import { LightningElement, track, api } from "lwc";
import  kynectHomePageAssets from "@salesforce/resourceUrl/kynectHomePageAssets";
import constants from "c/sspConstants";

export default class KynectHomePageCard extends LightningElement {

    @api
    cardImage;

    @api
    cardTitle;

    @api
    cardHeaderStyle;

    @api
    cardBodyContent;

    @track
    arrow =  kynectHomePageAssets + "/rightArrow.png";

    get hpCardHeaderStyle () {
        const cardStyle = constants.kynectHomeCardStyle;
        if (this.cardHeaderStyle) {
            return cardStyle + " " + this.cardHeaderStyle;
        }
        return cardStyle;
    }

}