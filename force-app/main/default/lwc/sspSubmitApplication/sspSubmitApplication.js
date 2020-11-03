/* eslint-disable no-console */
import { LightningElement, track } from "lwc";
import callIntegrationFlow from "@salesforce/apex/SSP_SubmitApplicationController.invokeSSP_DC";
import fetchApplicationStatus from "@salesforce/apex/SSP_SubmitApplicationController.fetchApplicationStatus";

import sspUtility from "c/sspUtility";
import sspConstants from "c/sspConstants";

export default class SspSubmitApplication extends LightningElement { 
    @track showSpinner = false;

    submitApplication () {
        this.showSpinner = true;
        const applicationId = new URL(window.location.href).searchParams.get("applicationId");
        callIntegrationFlow({
            applicationId: applicationId
        }).then((result) => {
            // this.showSpinner = false;
            const parsedData = result.mapResponse;
            if (
                !sspUtility.isUndefinedOrNull(parsedData) &&
                parsedData.hasOwnProperty("ERROR")
            ) {
                console.error(
                    "failed in loading dashboard " +
                    JSON.stringify(parsedData.ERROR)
                );
            } else if (!sspUtility.isUndefinedOrNull(parsedData)) {
                
                this.fetchStatus();
            }
        }).catch((error) => {
            console.error(error);
        });
    }



    fetchStatus = () => {
        const id = new URL(window.location.href).searchParams.get("applicationId");
        try {
            fetchApplicationStatus({
                sspApplicationId : id
            })
                .then(response => {
                    const result = response.mapResponse;
                    if (result.hasOwnProperty("ERROR")) {
                        console.error(
                            "Error in sspSubmitApplication.fetchStatus" +
                            result.ERROR
                        );
                    } else if (result.hasOwnProperty("status")) {
                       
                        const status = result.status;
                        if (
                            status === sspConstants.pollingStatus_RAC.success
                        ) {
                            this.showSpinner = false;                           
                        } else{                          
                            // eslint-disable-next-line @lwc/lwc/no-async-operation
                            setTimeout(() => {
                                this.fetchStatus(                                    
                                );
                            }, 5000);
                        }
                    }
                })
                .catch(error => {
                    console.error(
                        "failed in sspNavFlowContainerElements.fetchTransactionStatusFromServer " +
                        error
                    );
                });
        } catch (error) {
            console.error(
                "Error in sspNavFlowContainerElements.fetchApplicationDetailsFromServer" +
                error
            );
        }
    }

}