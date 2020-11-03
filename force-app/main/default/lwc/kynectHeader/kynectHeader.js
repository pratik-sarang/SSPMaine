/*
 * Component Name: KynectHeader.
 * Author: Narapa
 * Description: This will be the header component for Kynect Community Pages            
 * Date: 09/02/2020.
 * Task : 390945
 */
import { LightningElement, track } from "lwc";
import kynectIcons from "@salesforce/resourceUrl/kynectHomePageAssets";
import sspLanguagesText from "@salesforce/label/c.SSP_LanguagesText";
import kynectLanguages from "@salesforce/label/c.kynect_Language";
export default class KynectHeader extends LightningElement {

    @track
    bannerImage = kynectIcons + "/kynectIcon.png";

    @track languageOptions;
    @track chosenLanguage;
    @track selectedLanguage;

    customLabels = {
        kynectLanguages,
        sspLanguagesText
    }


    connectedCallback () {
        const kynectLanguagesList = this.customLabels.kynectLanguages.split(";");
        const optionsArray = [];
        for (let i = 0; i < kynectLanguagesList.length; i++) {
            const split = kynectLanguagesList[i].split("-");
            optionsArray.push({
                name: split[0],
                value: split[1]
            });
            this.chosenLanguage = split[0];
            this.languageOptions = optionsArray;
        }
    }


   /**
   * @function - languageChange
   * @description - Method is used to select the language from the drop down.
   * @param {*}event - Fired on selection of option.
   */
  languageChange = event => {
      try {
          this.selectedLanguage = event.target.dataset.value;
          window.location.href = "?language=" + this.selectedLanguage;
      }
        catch (error) {
      console.error(
        "failed in languageChange in header" + JSON.stringify(error)
      );
    }
  };



}