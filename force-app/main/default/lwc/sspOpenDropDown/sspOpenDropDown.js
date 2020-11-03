/* eslint-disable spellcheck/spell-checker */
/* eslint-disable no-console */
/**
 * Component Name: sspOpenDropDown.
 * Author: Mandi Fazeel Ahmed and Shikha.
 * Description: Custom drop down implementation.
 * Date:  02/18/2020.
 */
import { LightningElement, api, track } from "lwc";

export default class SspMenuItemDropdown extends LightningElement {
  @api label;
  @api subLabel;
  @api options = []; // object takes 2 keys, label - to display the label and link - the url.

  /**
   * @function - pageToLoadApi.
   * @description - get and set for various options to load data to drop down.
   */

  @api
  get pageToLoadApi () {
    return this.pageToLoadReceived;
  }
  set pageToLoadApi (value) {
    if (value) {
      this.pageToLoadReceived = value;
      this.loadDropdown();
    }
  }
  @track pageToLoadReceived;
  @track pageOptionsMap = [];
  @track pageOptionsValue = [];
  @track pageInfo = {};
  @track activeSections = [];
  @track selectedValue;
  @track selectedLabel;
  @track isTabPressed = false;
  pageMatched = false;
  optIndex = 0;

  /**
   * @function - pageOptions.
   * @description - get and set for various options for page drop down.
   */

  get pageOptions () {
    return this.pageOptionsValue;
  }
  set pageOptions (value) {
    if (value) {
      this.pageOptionsValue = value;
    }
  }

  /**
   * @function - retExp1.
   * @description - Method to show/hide section.
   */

  get retExp1 () {
    return this.pageToLoadReceived !== null;
  }

  /**
   * @function - retExp2.
   * @description - Method to show/hide in-progress section in drop down.
   */

  get retExp2 () {
    try {
      const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
      const res = (this.pageToLoadReceived.pageConfig.Id === tempPageConfig.pageConfigId) && (tempPageConfig.pageDupStatus ? tempPageConfig.pageDupStatus !== 67 :tempPageConfig.pageStatus !== 67);
      this.pageMatched = false;
      const limit = this.pageOptionsMap.length - 1;
      if (res === true && this.optIndex <= limit) {
        this.optIndex++;
        this.pageMatched = true;
      }
      if (this.optIndex > limit) {
        this.optIndex = limit;
      }
      return res;
    } catch (error) {
      console.error("Error in return exp 2 method", error);
      return false;
    }
  }

  /**
   * @function - retExp3.
   * @description - Method to show/hide completed section in drop down.
   */

  get retExp3 () {
    let res = false;
    try {
      if (this.pageMatched === false) {
        const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
        res = (tempPageConfig.pageDupStatus ? tempPageConfig.pageDupStatus === 67 : tempPageConfig.pageStatus === 67);
        const limit = this.pageOptionsMap.length - 1;
        if (res === true && this.optIndex < limit) {
          this.optIndex++;
          this.pageMatched = true;
        }
      }
      return res;
    } catch (error) {
      console.error("Error in return exp 3 method", error);
      return res;
    }
  }

  /**
   * @function - retExp4.
   * @description - Method to show/hide locked section in drop down.
   */

  get retExp4 () {
    let res = false;
    try {
      if (this.pageMatched === false) {
        const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
        
        res = (tempPageConfig.pageDupStatus ? tempPageConfig.pageDupStatus === 82 :
          tempPageConfig.pageStatus === 82)
           &&
          this.pageToLoadReceived.pageConfig.Id !== tempPageConfig.pageConfigId;
        const limit = this.pageOptionsMap.length - 1;
        if (this.optIndex < limit) {
          this.optIndex++;
          this.pageMatched = true;
        }
      }
      return res;
    } catch (error) {
      console.error("Error in return exp 4 method", error);
      return res;
    }
  }

  /**
   * @function - toggleDropDown.
   * @description - Method to show/hide the drop down.
   */

  toggleDropDown = () => {
    try {
      const dropDownIcon = this.template.querySelector(
        ".ssp-menuItemDropDownIcon"
      );
      this.template
        .querySelector(".ssp-menuItemDropDownContent")
        .classList.toggle("ssp-expandDropDown");
      dropDownIcon.classList.toggle("ssp-collapseDropDown");
    } catch (error) {
      console.error("Error toggling drop down", error);
    }
  };

    /**
     * @function - handleKeyPress.
     * @description - Method to handle key press event for JAWS.
     * @param  {object} event - Fired on key down of dropdown value.
     */
    handleKeyPress = event => {
        try {
          if (event.keyCode === 13 || event.keyCode === 32) {
                this.toggleDropDown();
            }
            if (event.keyCode === 9) {
                this.isTabPressed = true;
            } 
            if (event.key === "Tab") {
                if (event.shiftKey) {
                    this.isTabPressed = false;
                }
            }
        } catch (error) {
            console.error("Error occurred in handleKeyPress", error);
        }
    };

    /**
     * @function - closeDropDown.
     * @description - Method to hide the drop down.
     */

    closeDropDown = () => {
        try {
            if (!this.isTabPressed) {
                const dropDownIcon = this.template.querySelector(
                    ".ssp-menuItemDropDownIcon"
                );
                this.template
                    .querySelector(".ssp-menuItemDropDownContent")
                    .classList.remove("ssp-expandDropDown");
                dropDownIcon.classList.remove("ssp-collapseDropDown");
                this.isDisabledItemClicked = false;
            }
            this.isTabPressed = false;
        } catch (error) {
            console.error("Error hiding drop down", error);
        }
    };

  /**
   * @function - loadDropdown.
   * @description - Method to populate the drop down.
   */

  loadDropdown = () => {
    try {
      const pageGroupInfos = this.pageToLoadReceived.pageGroupInfos;
      this.selectedLabel = this.pageToLoadReceived.pageInfo.Page_Display_Name_View__c;
      this.selectedValue = this.pageToLoadReceived.pageInfo.Id;
      this.pageOptionsMap = [];
      this.optIndex = 0;
      for (let i = 0; i < pageGroupInfos.length; i++) {
        for (let j = 0; j < pageGroupInfos[i].pageInfos.length; j++) {
          const pageInfo = pageGroupInfos[i].pageInfos[j];
          if (pageInfo.pageDispName !== undefined) {
            const obj = {
              key: pageInfo.pageDispName,
              value: pageInfo.pageConfigId
            };
            if (
              this.pageOptions.findIndex(
                x => x.key === pageInfo.pageDispName
              ) === -1
            ) {
              this.pageOptions.push(obj);
            }

            this.pageOptionsMap.push({
              key: i,
              value: pageInfo
            });
          }
        }
      }
    } catch (error) {
      console.error("Error Loading data in drop down", error);
    }
  };

  /**
   * @function - handleSelectedValue.
   * @description - Method to select value from drop down.
   */

    handleSelectedValue = event => {
        try {
          if (
            event.type === "mousedown" ||
            (event.type === "keydown" && event.keyCode === 13)
          ) {
            event.preventDefault();
            if (!event.target.classList.contains("ssp-lockedProgress")) {
                this.isDisabledItemClicked = false;
                this.selectedValue = event.target.dataset.id;
                this.selectedLabel = event.target.dataset.label;
                this.toggleDropDown();
                const goToAction = new CustomEvent("gotoaction", {
                    detail: {
                        action: "goToPage",
                        goToPageConfigId: this.selectedValue
                    }
                });
                this.dispatchEvent(goToAction);
            }
          } else if (event.keyCode === 40) {
            event.target.nextSibling.focus();
          } else if (event.keyCode === 38) {
            event.target.previousSibling.focus();
          }
        } catch (error) {
            console.error("Error selecting value from drop down", error);
        }
    };
}