import { api, LightningElement } from "lwc";
import sspJawsAssistText from "@salesforce/label/c.sspJawsAssistiveText";


export default class SspJawsAssistText extends LightningElement {
    isCalled;
    label = {
        sspJawsAssistText
    }

    @api
    get triggerJaws () {
        return this.isCalled;
    }

    set triggerJaws (value) {
        this.isCalled = value;
        if (this.isCalled) {
            if (this.template.querySelector(".ssp-jaws-text")) {
                this.template.querySelector(".ssp-jaws-text").tabIndex = "0";
                this.template
                    .querySelector(".ssp-jaws-text")
                    .setAttribute("aria-hidden", "false");
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    this.template.querySelector(".ssp-jaws-text").focus();
                }, 1000);
            }
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                if (
                    this.template.querySelector(".ssp-jaws-text").tabIndex ==
                    "0"
                ) {
                    this.template.querySelector(".ssp-jaws-text").tabIndex =
                        "-1";
                    this.template
                        .querySelector(".ssp-jaws-text")
                        .setAttribute("aria-hidden", "true");
                }
            }, 2000);
        }
    }
}
