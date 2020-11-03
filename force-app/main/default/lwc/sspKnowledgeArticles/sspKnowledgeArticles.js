import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference,NavigationMixin } from "lightning/navigation";
import execute from "@salesforce/apex/SSP_KnowledgeArticleCtrlr.exec";
import { getUrlParameter } from "c/sspUtility";
import sspConstants from "c/sspConstants";
//Importing Custom Labels
import sspExpandAll from "@salesforce/label/c.SSP_ExpandAll";
import sspCollapseAll from "@salesforce/label/c.SSP_CollapseAll";
import sspBackToHelpFAQ from "@salesforce/label/c.SSP_BackToHelpFAQ";
import sspAltBackToHelpFAQ from "@salesforce/label/c.SSP_AltBacktoHelpFaq";
import sspAltExpandAll from "@salesforce/label/c.SSP_AltExpandAll";
import sspAltCollapseAll from "@salesforce/label/c.SSP_AltCollapseAll";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import LOCALE from "@salesforce/i18n/lang";


export default class SspKnowledgeArticles extends NavigationMixin(LightningElement) {

    @track isInit = false;

    @track showSpinner = false;

    @track language;

    @track categoryValue;

    @track categoryName;

    @track articlesList;

    @track currentPageReference;

    @track searchText;

    @track showBackButton = true;
    
    @track hasRendered = false;

    @track articlesAvailable;

    @track localeLanguage = LOCALE;

    //Custom Labels 
    customLabels = {
        sspExpandAll,
        sspCollapseAll,
        sspBackToHelpFAQ,
        sspAltBackToHelpFAQ,
        sspAltExpandAll,
        sspAltCollapseAll,
        sspNoResultsFound
    }

   
    /*
     * @function    : setCurrentPageReference
     * @description : Method to get various parameters of the page like language, help category 
     *                from the url and use it in various other methods to load Knowledge Articles.
     *                       
     */
    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference.state.language) {
            this.language = this.currentPageReference.state.language;
        }
        else if (this.localeLanguage) {
            this.language = this.localeLanguage.replace("-", "_");
        }
        else {
            this.language = "en_US";
        }
        
        if (this.currentPageReference.state.helpCategory) {
            this.categoryValue = getUrlParameter("helpCategory"); 
            if (!String(this.categoryValue).startsWith("BA_")){
                this.showBackButton = false;
                }
        }
        if (this.currentPageReference.state.searchText) {
            this.searchText = getUrlParameter("searchText"); 
        }   
    }

    /*
     * @function    : connectedCallback
     * @description : Method called on the Page Load.
     *                       
     */    
    connectedCallback () {
        this.showSpinner = true;
    }

    /*
     * @function    : wireArticles
     * @description : Method to fetch the Knowledge Articles by making a server call.
     *                       
     */
    
    @wire(execute, {
        action: "getKArticles",
        language:"$language",
        category: "$categoryValue"
    })
    wireArticles ({ error, data }) {
        try {
            if (data) {
                if (data.mapResponse.kArticles) {
                    this.articlesList = data.mapResponse.kArticles
                    if (this.articlesList.length > 0) {
                        this.articlesAvailable = true;
                        this.categoryName = this.articlesList[0].Help_Category__c;
                    }
                    else {
                        this.articlesAvailable = false;
                    }
                    this.isInit = true;
                }
                else if (data.mapResponse.Error) {
                    
                    this.articlesAvailable = false;
                }
            } else if (error) {
                this.articlesAvailable = false;
            }
            this.showSpinner = false;
        } catch (e) {
            this.articlesAvailable = false;
            this.showSpinner = false;
        }
    }
    



    /*
     * @function    : wireArticles
     * @description : Method to go back to Help and FAQ landing Page
     *                       
     */  
    navigateToHelpAndFAQ () { 
        {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.helpFAQ
                },
                state: { 
                    searchText: this.searchText
                }
            });
        }

    }

    /*
     * @function    : expandAllAccordions
     * @description : Method to expand all Accordions on the page.
     *                       
     */  
    expandAllAccordions () {
        const accordionList = this.template.querySelectorAll(
            "c-ssp-accordion-card"
        );
        accordionList.forEach(function (accordion) {
            accordion.expandAccordion();
        });
    }

    /*
     * @function    : collapseAllAccordions
     * @description : Method to collapse all Accordions on the page.
     *                       
     */  
    collapseAllAccordions () {
        const accordionList = this.template.querySelectorAll(
            "c-ssp-accordion-card"
        );
        accordionList.forEach(function (accordion) {
            accordion.collapseAccordion();
        });
        
    }
}