/**
 * Component Name: sspFilterSearchBox.
 * Author: Chirag.
 * Description: This is component is used to filter search data in message Center.
 * Date: 7/1/2020.
 */
import { LightningElement, track, api } from "lwc";
import sspBackgroundIcons from "@salesforce/resourceUrl/SSP_CD2_Icons";
import sspMessageCenterAnnouncements from "@salesforce/label/c.SSP_MessageCenterAnnouncements";
import sspMessageCenterToDos from "@salesforce/label/c.SSP_MessageCenterToDos";
import sspMessageCenterSearch from "@salesforce/label/c.SSP_MessageCenterSearch";

export default class SspFilterSearchBox extends LightningElement {
    iconUrlToDo = sspBackgroundIcons + "/sspIcons/ic_date@2x.png"; 
    iconUrlAnnouncement = sspBackgroundIcons + "/sspIcons/announcement.png";
    @api tabSelected;
    @api searchValue;
    @track queryTerm;
    @track showBackIcon;
    @track showAutocomplete = false;
    
    customLabel = {
        sspMessageCenterSearch,
        sspMessageCenterAnnouncements,
        sspMessageCenterToDos
    };


    /**
     * @function : handleKeyUp
     * @description : This method is used to search if enter is press.
     * @param {*} evt - This event returns particular class.
     */
    handleKeyUp (evt) {
       try{ const isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            this.queryTerm = evt.target.value;
            this.dispatchEvent(
                new CustomEvent("progress", {
                    detail: this.queryTerm
                })
            );
        }
       } catch (error) {
           console.error(
               "failed in handleKeyUp in sspFilterSearchBox" +
               JSON.stringify(error)
           );
       }
    }

    /**
     * @function : handleSearchInput
     * @description : This method is used to select a div.
     *   @param {*} evt - This event returns particular class.
     */
    handleSearchInput (evt) {
       try {if (this.tabSelected === "notice") {
            this.showAutocomplete = false;
        } else if (this.tabSelected === "message") {
            this.showAutocomplete = true;
        }
        const srcInput = evt.target.value;
        if (srcInput === "") {
            this.showBackIcon = true;
            this.template
                .querySelector(".ssp-searchBox-child")
                .classList.add("ssp-hideSearchIcon");
        } else {
            this.showBackIcon = true;
            this.showAutocomplete = false;
            this.template
                .querySelector(".ssp-searchBox-child")
                .classList.add("ssp-hideSearchIcon");
        }
        this.dispatchEvent(new CustomEvent("empty"));}
       catch (error) {
           console.error(
               "failed in handleSearchInput in sspFilterSearchBox" +
               JSON.stringify(error)
           );
       }
    }

    /**
     * @function : emptySearchField
     * @description : This method is used to empty the search Field.
     */
    emptySearchField =()=> {
        try{this.template.querySelector("lightning-input").value = "";
        this.showBackIcon = false;
        this.showAutocomplete = false;
        this.template
            .querySelector(".ssp-searchBox-child")
            .classList.remove("ssp-hideSearchIcon");

        this.dispatchEvent(new CustomEvent("empty"));}
        catch (error) {
            console.error(
                "failed in emptySearchField in sspFilterSearchBox" +
                JSON.stringify(error)
            );
        }
    }
    

/**
 * @function : handleTag
 * @description : This method is used handle tag search.
 */
    handleTag =()=> {
       try {this.showAutocomplete = false;
        this.showBackIcon = false;
        this.template
            .querySelector(".ssp-searchBox-child")
            .classList.remove("ssp-hideSearchIcon");
        this.dispatchEvent(new CustomEvent("blur"));}
        catch (error) {
            console.error(
                "failed in handleTag in sspFilterSearchBox" +
                JSON.stringify(error)
            );
        }
    }

/**
* @function : handleToDo
* @description : This method is used handle ToDo tag search.
*/
    handleToDo =()=> {
       try {this.showBackIcon = true;
        this.template
            .querySelector(".ssp-searchBox-child")
            .classList.add("ssp-hideSearchIcon");
        this.dispatchEvent(new CustomEvent("todo"));}
        catch(error) {
            console.error(
                "failed in handleToDo in sspFilterSearchBox" +
                JSON.stringify(error)
            );
        }
    }

/**
* @function : handleAnnouncement
* @description : This method is used handle Announcement tag search.
*/
    handleAnnouncement =()=> {
        try{this.showBackIcon = true;
        this.template
            .querySelector(".ssp-searchBox-child")
            .classList.add("ssp-hideSearchIcon");
        this.dispatchEvent(new CustomEvent("announcement"));}
        catch(error) {
            console.error(
                "failed in handleAnnouncement in sspFilterSearchBox" +
                JSON.stringify(error)
            );
        }
    }
}