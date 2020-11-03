import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";

export default class SspBaseComponent extends LightningElement {
    @track ScreenShown = "";
    @track BaseProgramsScreenShown = [];
    @track customAppId = "";
    @api applicationId = "";
    @api memberId = "";
    @api flowName;
    @wire(CurrentPageReference) pageRef;

    constructor () {
        super();
    }

    handleScreenSelection (event) {
        const selectedScreen = event.detail.SelectedScreens;

        this.ScreenShown = selectedScreen;
    }

    @api
    navToComponent (cmpName, urlParams) {
        const navService = this.template.querySelector(
            '[data-id="navService"]'
        );
        const pageReference = {
            type: "standard__component",
            attributes: {
                componentName: "c__" + cmpName
            },
            state: urlParams
        };
        navService.navigate(pageReference);
    }
    @api
    showError (message) {
        this.showToast(message, "error", "pester");
    }
}
