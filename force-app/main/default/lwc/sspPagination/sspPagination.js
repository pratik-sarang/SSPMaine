/**
 * Component Name: sspPagination.
 * Author: Venkata Ranga Babu.
 * Description: Component to handle pagination.
 */
import { LightningElement, track, api } from "lwc";
import sspNext from "@salesforce/label/c.SSP_Next";
import sspPrevious from "@salesforce/label/c.SSP_Previous";
import sspConstants from "c/sspConstants";
import goMoreResults from "@salesforce/label/c.SSP_GoMoreResults";
import goPreviousResults from "@salesforce/label/c.SSP_GoPreviousResults";

export default class SspPagination extends LightningElement {
    _tableData;
    @api perPage = 5;
    @api pageSize = 5;
    @api currentPage = 1;
    @api get tableData () {
        return this._tableData;
    }
   set tableData (value) {
        this._tableData = value;
        this.setPages(this._tableData);
        if (this.currentPage === 1) {
            const _pages = [... this.pages];
            const pagesToDisplay = _pages.slice(0, this.pageSize);
            this.pagesList = pagesToDisplay;
            if (this.pagesList[this.pagesList.length - 1] >= this._lastPageNumber) {
                this._isLastPage = false;
            } else {
                if ( this.pagesList[this.pagesList.length - 1] + 1 === this._lastPageNumber ) {
                    this.isPageEllipses = false;
                } else {
                    this.isPageEllipses = true;
                }
                this._isLastPage = true;
            }
        }
    }
    @track currentPageData = [];
    @track firstPageNumber = 1;
    @track pages = [];
    @track isPageEllipses;
    @track isFirstPageEllipses = true;
    @track isFirstPage = false;
    @track pagesList;
    @track showPagination = false;
    _lastPageNumber;
    _isLastPage;
    _pagesList;
    customLabels = {
        sspNext,
        sspPrevious,
        nextIcon: ">",
        previousIcon: "<",
        goMoreResults,
        goPreviousResults
    };
    get lastPageNumber () {
        return this._lastPageNumber;
    }
    get isLastPage () {
        return this._isLastPage;
    }
    get hasPrev () {
        return this.currentPage > 1;
    }
    get hasNext () {
        return this.currentPage < this.pages.length
    }
    get hasPrevDisable () {
        return !this.hasPrev;
    }
    get hasNextDisable () {
        return !this.hasNext;
    }

    renderedCallback () {
        this.renderButtons();
    }
    /**
     * @function : renderButtons
     * @description	: To add or remove ssp-pageSelected class on page numbers to distinguish selected and not selected page numbers.
     */
    renderButtons = () => {
        this.template.querySelectorAll(".ssp-pageButton").forEach((button) => {
            if (this.currentPage === parseInt(button.dataset.id, 10)) {
                button.classList.add("ssp-pageSelected");
            } else {
                button.classList.remove("ssp-pageSelected");
            }
        });
    }

    /**
     * @function : getNextPageList
     * @description	: To get next list of pages.
     */
    getNextPageList = () => {
        const lastPageOfList = this.pagesList[this.pagesList.length - 1];
        this.currentPage = lastPageOfList + 1;
        let _pages = [... this.pages];
        const pagesToDisplay = _pages.splice(lastPageOfList, this.pageSize);
        _pages = [... this.pages];
        this.pagesList = pagesToDisplay;
        if (this.pagesList[0] <= 1) {
            this.isFirstPage = false;
        } else {
            this.isFirstPage = true;
        }
        if (this.pagesList[this.pagesList.length - 1] >= this._lastPageNumber) {
            this._isLastPage = false;
        } else {
            if ( this.pagesList[this.pagesList.length - 1] + 1 === this._lastPageNumber ) {
                this.isPageEllipses = false;
            } else {
                this.isPageEllipses = true;
            }
            this._isLastPage = true;
        }
    }

    /**
     * @function : getPreviousPageList
     * @description	: To get previous list of pages.
     */
    getPreviousPageList = () => {
        const firstPageOfList = this.pagesList[0];
        this.currentPage = firstPageOfList - 1;
        let _pages = [... this.pages];
        let startIndex = firstPageOfList - this.pageSize;
        startIndex = startIndex > 0 ? startIndex - 1 : 0;
        const pagesToDisplay = _pages.splice(startIndex, this.pageSize);
        _pages = [... this.pages];
        this.pagesList = pagesToDisplay;
        if (this.pagesList[0] <= 1) {
            this.isFirstPage = false;
        } else {
            this.isFirstPage = true;
        }
        if (this.pagesList[this.pagesList.length - 1] >= this._lastPageNumber) {
            this._isLastPage = false;
        } else {
            if ( this.pagesList[this.pagesList.length - 1] + 1 === this._lastPageNumber ) {
                this.isPageEllipses = false;
            } else {
                this.isPageEllipses = true;
            }
            this._isLastPage = true;
        }
    }

    /**
     * @function : pageData
     * @description	: To get current page data.
     */
    pageData = () => {
        try {
            const currentPage = this.currentPage;
            const perPage = this.perPage;
            const startIndex = (currentPage * perPage) - perPage;
            const endIndex = (currentPage * perPage);
            let data = this._tableData.slice(startIndex, endIndex);
            data = JSON.parse(JSON.stringify(data));
            
            this.dispatchEvent(
                new CustomEvent(
                    sspConstants.agencyManagement.pageData,
                    {
                        detail: {
                            currentPageData: data
                        }
                    }
                )
            );
        } catch (error) {
            console.error(error);
        }
    }
    /**
     * @function : setPages
     * @description	: To calculate number of pages based on data.
     * @param  {object} data - .
     */
    setPages = (data) => {
        try {
            const numberOfPages = Math.ceil(data.length / this.perPage);
            const pages = [];
            for (let index = 1; index <= numberOfPages; index++) {
                pages.push(index);
            }
            this.pages = pages;
            this._lastPageNumber = this.pages[this.pages.length - 1];
            this.pageData();
        } catch (error) {
            console.error(error);
        }
    }
    /**
     * @function : onNext
     * @description	: To handle Next action.
     */
    onNext = () => {
        try {
            if (this.currentPage === this.pagesList[this.pagesList.length - 1]) {
                this.getNextPageList();
            } else {
                ++this.currentPage;
                this.pageData();
            }
        } catch (error) {
            console.error(error);
        }
    }
    /**
     * @function : onPrev
     * @description	: To handle Previous action.
     */
    onPrev = () => {
        try {
            if (this.currentPage === this.pagesList[0]) {
                this.getPreviousPageList();
            } else {
                --this.currentPage;
                this.pageData();
            } 
        } catch (error) {
            console.error(error);
        }
    }
    /**
     * @function : onPageClick
     * @description	: To handle page number click action.
     * @param  {object} event - .
     */
    onPageClick = (event) => {
        try {
            this.currentPage = parseInt(event.target.dataset.id, 10);
            this.pageData();
        } catch (error) {
            console.error(error);
        }
    }

    onFirstPageClick = () => {
        try {
            this.currentPage = 1;
            let _pages = [... this.pages];
            const pagesToDisplay = _pages.splice(0, this.pageSize);
            _pages = [... this.pages];
            this.pagesList = pagesToDisplay;
            if (this.pagesList[0] <= 1) {
                this.isFirstPage = false;
            } else {
                this.isFirstPage = true;
            }
            if (this.pagesList[this.pagesList.length - 1] >= this._lastPageNumber) {
                this._isLastPage = false;
            } else {
                if ( this.pagesList[this.pagesList.length - 1] + 1 === this._lastPageNumber ) {
                    this.isPageEllipses = false;
                } else {
                    this.isPageEllipses = true;
                }
                this._isLastPage = true;
            }
            this.pageData();
        } catch (error) {
            console.error(error);
        }
    }

    onLastPageClick = () => {
        this.currentPage = this.lastPageNumber;
        let _pages = [... this.pages];
        let startIndex = this.lastPageNumber - this.pageSize;
        startIndex = startIndex > 0 ? startIndex : 0;
        const pagesToDisplay = _pages.splice(startIndex, this.pageSize);
        _pages = [... this.pages];
        this.pagesList = pagesToDisplay;
        if (this.pagesList[0] <= 1) {
            this.isFirstPage = false;
        } else {
            this.isFirstPage = true;
        }
        if (this.pagesList[this.pagesList.length - 1] >= this._lastPageNumber) {
            this._isLastPage = false;
        } else {
            if ( this.pagesList[this.pagesList.length - 1] + 1 === this._lastPageNumber ) {
                this.isPageEllipses = false;
            } else {
                this.isPageEllipses = true;
            }
            this._isLastPage = true;
        }
        this.pageData();
    }

    connectedCallback () {
        try {
            if (
                /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
                    navigator.userAgent
                )
            ) {
                this.pageSize = 2;
            }
            if (/iPad|iPod/i.test(navigator.userAgent)) {
                this.pageSize = 3;
            }
    
            if (this.tableData.length > 10) {
                this.showPagination = true;
            }
        } catch (error) {
            console.error("Error in connected call back in Pagination " + error);
        }
    }
}