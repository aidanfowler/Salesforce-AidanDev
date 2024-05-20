import { LightningElement, api, wire } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSearchResults from '@salesforce/apex/SearchResultsController.getSearchResults';
import getNextSearchResults from '@salesforce/apex/SearchResultsController.getNextSearchResults';

const ERROR_VARIANT = 'error';

export default class KnowledgeSearchResultsPage extends NavigationMixin(LightningElement) {

    @api term;
    @api pageSize = 10;
    numResults;
    categoryName = 'All Categories';
    fullSearchResults;
    searchResults;
    categories;
    pageNum = 1;
    alphaArticleIds;
    betaArticleIds;
    articleIds;
    categoryWrappers;
    globalCategoryName = 'All Categories';
    errorMessage;

    @api
    get updatedTerm() {
        return this.term ? decodeURI(this.term) : '';
    }

    get noNext() {

        let totalPages = Math.ceil(this.numResults / this.pageSize);

        return this.pageNum === totalPages;
    }

    get noPrevious() {
        return this.pageNum == 1;
    }

    @wire(getSearchResults, { searchTerm: '$updatedTerm',
                                pageSize: '$pageSize',
                                categoryName: '$globalCategoryName'})
    wiredRecord({ error, data }) {
        if (error) {

            this.errorMessage = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errorMessage = error.body.message;
            }

            this.showToast('Error', this.errorMessage, ERROR_VARIANT);
            
        } else if (data) {

            this.searchResults = data.searchResults;
            this.alphaArticleIds = data.alphaArticleIds;
            this.betaArticleIds = data.betaArticleIds;
            this.articleIds = data.articleIds;
            this.numResults = data.numResults;
			this.fullSearchResults = this.searchResults;
            this.categoryWrappers = data.categoryWrappers;

            this.processSearchResults();
        }
    }

    processSearchResults() {
        
        let categoryMap = new Map();

        categoryMap.set('All Categories', this.numResults);

        this.categories = [];

        // Create the Category Map with the category to the number of articles.
        for(let category of this.categoryWrappers) {
            categoryMap.set(category.name, category.numArticles);
        }

        // Add All Categories
        this.categories.push({ name: "All Categories", num: categoryMap.get("All Categories"), label: "All Categories (" + categoryMap.get("All Categories") + ")"});

        for(let category of this.categoryWrappers) {

            let num = categoryMap.get(category.name);

            this.categories.push({ name: category.name, num: num, label: category.label + " (" + num + ")"});
        }
    }

    handleCategoryUpdated(event) {

        event.stopPropagation();
        event.preventDefault();

        // Update the Search results for the Selected Category
        if(event.detail !== this.categoryName) {

            this.categoryName = event.detail;

            this.updateSearchResults();
        }
    }

    handleGetFirstPage() {

        this.pageNum = 1;

        getNextSearchResults({ offset: 0, pageSize: this.pageSize, articleIds: this.articleIds, alphaArticleIds: this.alphaArticleIds, betaArticleIds: this.betaArticleIds, categoryName: this.categoryName})
            .then((result) => {
                this.searchResults = result.searchResults;
                this.error = undefined;
            })
            .catch((error) => {
                this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
                this.contacts = undefined;
            });
    }

    handleNext() {

        this.pageNum = this.pageNum + 1;

        getNextSearchResults({ offset: this.pageSize * (this.pageNum - 1), pageSize: this.pageSize, articleIds: this.articleIds, alphaArticleIds: this.alphaArticleIds, betaArticleIds: this.betaArticleIds, categoryName: this.categoryName })
            .then((result) => {
                this.searchResults = result.searchResults;
                this.error = undefined;
            })
            .catch((error) => {
                this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
                this.contacts = undefined;
            });
    }

    handleGetLastPage() {

        // Get the page num
        this.pageNum = this.numResults/this.pageSize;

        if(this.pageNum * this.pageSize < this.numResults) {
            this.pageNum += 1;
        }

        // Get the Search results
        getNextSearchResults({ offset:this.pageSize * (this.pageNum - 1), pageSize: this.pageSize, articleIds: this.articleIds, alphaArticleIds: this.alphaArticleIds, betaArticleIds: this.betaArticleIds, categoryName: this.categoryName})
            .then((result) => {
                this.searchResults = result.searchResults;
                this.error = undefined;
            })
            .catch((error) => {
                this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
                this.contacts = undefined;
            });
    }

    handlePrevious() {
        this.pageNum = this.pageNum - 1;

        // Get the search results.
        getNextSearchResults({ offset: this.pageSize * (this.pageNum - 1), pageSize: this.pageSize, articleIds: this.articleIds, alphaArticleIds: this.alphaArticleIds, betaArticleIds: this.betaArticleIds, categoryName: this.categoryName})
            .then((result) => {
                this.searchResults = result.searchResults;
                this.error = undefined;
            })
            .catch((error) => {
                this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
                this.contacts = undefined;
            });
    }

    updateSearchResults() {			

        this.pageNum = 1;

        // Update the search results based on the category name
        getNextSearchResults({ offset: 0, pageSize: this.pageSize, articleIds: this.articleIds, alphaArticleIds: this.alphaArticleIds, betaArticleIds: this.betaArticleIds, categoryName: this.categoryName})
        .then((result) => {

            this.searchResults = result.searchResults;
            this.numResults = result.numResults;
            this.error = undefined;
        })
        .catch((error) => {
            this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
            this.contacts = undefined;
        });
	}

    handleArticleClicked(event) {

        let articleId = event.detail;

        // Redirect to the article
        if(articleId !== null) { 

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "/article-page?articleId=" + articleId
                }
            });
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(event);
    }
}