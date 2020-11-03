/**
 * Component Name: sspTabs.
 * Author: Chaitanya.
 * Description: This a component which shows user information depending on the screen.
 * Date: 12/11/2019.
 */
import { LightningElement, api } from "lwc";

export default class SspTabs extends LightningElement {
    @api tabsList = ["Upcoming Appointments", "Past Appointments"];

    /**
     * @function : openSelected
     * @description : This method is used to open a selected tab.
     * @param {*} e - Returns a particular tab.
     */
    openSelected (e) {
        const tabs = this.template.querySelectorAll(".ssp-Tab");
        const tabsContent = this.template.querySelectorAll(".ssp-TabsContent");
        for (let i = 0; i < tabs.length; i++) {
            tabs[i].classList.remove("ssp-active ssp-color_monoBody");
        }
        e.target.classList.add("ssp-active ssp-color_monoBody");
        for (let i = 0; i < tabs.length; i++) {
            if (tabs[i].classList.contains("ssp-active ssp-color_monoBody")) {
                tabsContent[i].classList.add("ssp-show");
            } else {
                tabsContent[i].classList.remove("ssp-show");
            }
        }
    }
}
