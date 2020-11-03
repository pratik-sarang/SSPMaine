/***
 * Component Name: sspSearchBox.js.
 * Author: Soumyashree.
 * Description: This is component is used to search data.
 * Date: 12/11/2019.
 */
import { LightningElement, track } from "lwc";

export default class SspSearchBox extends LightningElement {
    @track queryTerm;
    @track showBackIcon;

    /**
     * @function : handleKeyUp
     * @description : This method is used to select a div.
     * @param {*} evt - This event returns particular class.
     
     */
    handleKeyUp (evt) {
        const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
        }
    }
    /**
     * @function : handleSearchInput
     * @description : This method is used to select a div.
     *   @param {*} evt - This event returns particular class.
     */
    handleSearchInput (evt) {
        const srcInput = evt.target.value;
        if (srcInput === "") {
            this.showBackIcon = false;
            this.template
                .querySelector(".ssp-searchBox-child")
                .classList.remove("ssp-hideSearchIcon");
        } else {
            this.showBackIcon = true;
            this.template
                .querySelector(".ssp-searchBox-child")
                .classList.add("ssp-hideSearchIcon");
        }
    }
}