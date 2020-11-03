import { LightningElement, track, wire } from "lwc";
import { CurrentPageReference, NavigationMixin} from "lightning/navigation";
import { getUrlParameter } from "c/sspUtility";
import execute from "@salesforce/apex/SSP_KnowledgeArticleCtrlr.exec";
//Importing Custom Labels
import sspHelpResources from "@salesforce/label/c.SSP_HelpResources";
import sspBack from "@salesforce/label/c.SSP_Back";
import sspSearch from "@salesforce/label/c.SSP_SearchButtonText";
import sspNoResultsFound from "@salesforce/label/c.SSP_NoResultsFound";
import sspResultsFound from "@salesforce/label/c.SSP_ResultsFound";
import sspResultFound from "@salesforce/label/c.SSP_ResultFound";
import sspExpandAll from "@salesforce/label/c.SSP_ExpandAll";
import sspCollapseAll from "@salesforce/label/c.SSP_CollapseAll";
import sspAltExpandAll from "@salesforce/label/c.SSP_AltExpandAll";
import sspAltCollapseAll from "@salesforce/label/c.SSP_AltCollapseAll";
import sspAltGoBack from "@salesforce/label/c.SSP_AltGoBack";

//Importing Static Resources
import sspImages from "@salesforce/resourceUrl/SSP_CD2_Icons";
import isGuest from "@salesforce/user/isGuest";
import sspConstants from "c/sspConstants";


export default class SspKnowledgeArticleCategoryListPage extends NavigationMixin(LightningElement) {
    
    //properties 
    @track isInit = false;

    @track searchIcon = sspImages + "/sspIcons/ic_search@3x.png";

    @track allCategories;

    @track searchedCategories;

    @track searchedArticles;

    @track language;

    @track currentPageReference;

    @track searchText = "";

    @track showAccordionButtons = false;

    @track searchResultsCount = 0;

    @track showSearchResultsCount = false;

    @track searchResultsInfo;

    //Custom Labels 
    customLabels = {
        sspHelpResources,
        sspBack,
        sspSearch,
        sspNoResultsFound,
        sspResultsFound,
        sspResultFound,
        sspExpandAll,
        sspCollapseAll,
        sspAltExpandAll,
        sspAltCollapseAll,
        sspAltGoBack
    }

    /*
     * @function    : setCurrentPageReference
     * @description : Method to get various parameters of the page like language, search Text 
     *                from the url and use it in various other methods to search Knowledge Articles,
     *                search Knowledge Article Categories             
     */
    @wire(CurrentPageReference)
    setCurrentPageReference (currentPageReference) {
        this.currentPageReference = currentPageReference;
        if (this.currentPageReference.state.language) {
            this.language = this.currentPageReference.state.language;
        }
        else if (!this.language){
            this.language = "en_US";
        }
        if (this.currentPageReference.state.searchText) {
            this.searchText = getUrlParameter("searchText"); 
        }
    }

    /*
     * @function    : connectedCallback
     * @description : Method that will be called on load of the page , gets all the Article Categories.
     *                If Articles and Categories are searched before moving away from the page , On clicking Back to Help 
     *                and FAQ this method keeps the search results active
     */
    connectedCallback () {
        if (this.searchText && this.searchText !== "") {
            this.clearResults();
            this.searchKA();
        }
            this.getKACategories();
    }

    //getter parameter holding the value if a search had been made on the pages
    get isSearched () {
        return this.searchText && String(this.searchText).length > 1;  
    }

    /*
     * @function    : getKACategories
     * @description : Method calls the server side execute method and obtains the  Article Categories
     */
    getKACategories () {
        execute({
            action: "getKACategories"
        })
            .then(response => {
                this.allCategories = response.mapResponse.kACategories;
            })
            .catch(error => {
                console.error("Error in getKACategories method from SspKnowledgeArticleCategoryListPage"+ JSON.stringify(error));
            });     
    }

    /*
     * @function    : onSearchInput
     * @description : Method called when a word is typed into the Search Box on the Help and FAQ's page
     * @param {*} event - Js event.
     */
    onSearchInput (event) {
        event.preventDefault();
        this.searchText = event.target.value;
        this.clearResults();
        this.searchKA(); 
    }

    /*
     * @function    : clearResults
     * @description : method to clear and reset search results before searching 
     *                Categories and Articles with a new search word
     * @param {*} event - Js event.
     */
    clearResults () {
        this.searchedCategories = null;
        this.searchedArticles = null;
        this.showAccordionButtons = false;
        this.showSearchResultsCount = false;
    }

    /*
     * @function    : searchKA
     * @description : Method to get results from the server method to search Articles and Categories 
     *                based on the search word and the language
     */
    searchKA () {
        if (String(this.searchText).length > 1) {
            execute({
               action: "searchArticles",
               searchTerm: this.searchText,
                language: this.language
            }).then(response => {
                //If there is any exception on the server side method
                if (response.mapResponse.ERROR) {
                    console.error("Error in searchKA method from SspKnowledgeArticleCategoryListPage " +JSON.stringify(response.mapResponse.ERROR));
                }
                //when we get a successful Response 
                else {
                    this.searchedCategories = response.mapResponse.categories.length > 0 ? response.mapResponse.categories : null;
                    this.searchedArticles = response.mapResponse.articles.length > 0 ? response.mapResponse.articles : null;
                    this.countSearchResults();
                    this.generateSearchResultsInfo();
                    this.showSearchResultsCount = true;
                }
           })
                .catch(error => {
                    console.error("Error in searchKA method from SspKnowledgeArticleCategoryListPage "+ JSON.stringify(error));
           });
        } 
    }

    /*
     * @function    : countSearchResults
     * @description : Method to obtain the total number of Categories and Articles obtained after searching for a word 
     */
    countSearchResults () {
        this.searchResultsCount = 0;
        if (this.searchedArticles){
                this.showAccordionButtons = true;
                this.searchResultsCount = this.searchResultsCount + this.searchedArticles.length;
        }
        if (this.searchedCategories) {
                this.searchResultsCount = this.searchResultsCount + this.searchedCategories.length;
        } 
    }

    /*
     * @function    : generateSearchResultsInfo
     * @description : Method to obtain the message to be displayed to the user after obtaining the searched Results 
     */
    generateSearchResultsInfo () {
        if (this.searchResultsCount === 0) {
            this.searchResultsInfo = this.customLabels.sspNoResultsFound;
        }
        else if (this.searchResultsCount === 1){
            this.searchResultsInfo = this.searchResultsCount + " " + this.customLabels.sspResultFound;
        }
        else {
            this.searchResultsInfo = this.searchResultsCount + " " + this.customLabels.sspResultsFound;
        }
    }

    /*
     * @function    : redirectToPreviousPage
     * @description : Method to redirect back to the page from where User moved to Help and FAQ's Page 
     */
    redirectToPreviousPage () {
        if (isGuest){
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.home
                }
            });
        }
        else {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: sspConstants.communityPageNames.dashboard
                }
            });
        }
        
    }

    /*
     * @function    : expandAllAccordions
     * @description : Method to expand Accordions of all the Knowledge Articles, obtained from search results 
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
     * @description : Method to close Accordions of all the Knowledge Articles, obtained from search results 
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