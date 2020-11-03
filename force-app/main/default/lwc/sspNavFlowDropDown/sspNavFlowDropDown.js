import { LightningElement, track, api } from "lwc";

export default class sspNavFlowDropDown extends LightningElement {
    @track activeSections = [];
    @track pageGroupInfo = {};
    @track pageToLoadReceived;
    @track pageInfo = {};
    @track pageOptionsValue = [];
    @track pageOptionsMap = [];
    @api headOfHousehold;
    @api flowName;
    optIndex = 0;
    pageMatched = false;

    get pageOptions () {
        return this.pageOptionsValue;
    }
    set pageOptions (value) {
        if (value) {
            this.pageOptionsValue = value;
        }
    }

    @api
    get pageToLoadApi () {
        return this.pageToLoadReceived;
    }
    set pageToLoadApi (value) {
        this.pageToLoadReceived = value;
        if (this.pageToLoadReceived !== value) {
            this.pageToLoadReceived = value;
            this.loadDropdown();
        }
    }
    get retExp1 () {
        return this.pageToLoadReceived !== null;
    }

    get retExp2 () {
        const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
        const res =
            this.pageToLoadReceived.pageConfig.Id ===
            tempPageConfig.pageConfigId;
        this.pageMatched = false;
        if (res === true) {
            this.optIndex++;
            this.pageMatched = true;
        }
        return res;
    }

    get retExp3 () {
        let res = false;
        if (this.pageMatched === false) {
            const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
            res =
                tempPageConfig.pageStatus === 67 &&
                this.pageToLoadReceived.pageConfig.Id !==
                    tempPageConfig.pageConfigId;
            if (res === true) {
                this.optIndex++;
                this.pageMatched = true;
            }
        }
        return res;
    }

    get retExp4 () {
        let res = false;
        if (this.pageMatched === false) {
            const tempPageConfig = this.pageOptionsMap[this.optIndex].value;
            res =
                tempPageConfig.pageStatus === 82 &&
                this.pageToLoadReceived.pageConfig.Id !==
                    tempPageConfig.pageConfigId;
            const limit = this.pageOptionsMap.length - 1;
            if (this.optIndex < limit) {
                this.optIndex++;
                this.pageMatched = true;
            }
        }
        return res;
    }
    onPageSelect () {
        const tempSelValue = this.template.querySelectorAll(".selVal");
        const resetGoToAction = new CustomEvent("gotoaction");
        this.dispatchEvent(resetGoToAction);

        if (tempSelValue !== undefined) {
            const selectedValue = tempSelValue[0].value;

            const goToAction = new CustomEvent("gotoaction", {
                detail: {
                    action: "goToPage",
                    goToPageConfigId: selectedValue
                }
            });
            this.dispatchEvent(goToAction);
        }
    }
    loadDropdown () {
        const pageGroupInfos = this.pageToLoadReceived.pageGroupInfos;
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

                    this.pageOptionsMap.push({ key: i, value: pageInfo });
                }
            }
        }
    }
}