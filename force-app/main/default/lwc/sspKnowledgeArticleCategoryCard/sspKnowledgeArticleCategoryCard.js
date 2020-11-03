import { LightningElement, api } from "lwc";
import sspConstants from "c/sspConstants";
import { NavigationMixin } from "lightning/navigation";

export default class SspKnowledgeArticleCategoryCard extends NavigationMixin(LightningElement) {

    hasRendered = false;

    // This is picklist object containing value and label attributes
    // @see SSP_KnowledgeArticleCtrlr.PicklistEntry
    @api
    category;

    @api
    searchText;

    /**
     * @function - renderedCallback
     * @description - This method is used to show the accordion block.
     */
    renderedCallback () {
        if(!this.hasRendered){
            this.hasRendered = true;
            const accordion = this.template.querySelector(".ssp-accordionButton");
            const $this = this;
            accordion.addEventListener("click", function () {
                $this.navigateToHelpArticlesPage();     
        });
    }
    }
    

     /**
     * @function - navigateToHelpArticlesPage
     * @description - This method redirects user to Help Articles Page based on the category selected.
     */
    navigateToHelpArticlesPage () {
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.helpArticles
                },
                state: { 
                    helpCategory: this.category.value,
                    searchText: this.searchText
                }
            });
        }
    }

}