import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getArticle from '@salesforce/apex/ArticlePageController.getArticle';
import redirectToMoreRecentArticle from '@salesforce/apex/ArticlePageController.redirectToMoreRecentArticle';

const ERROR_VARIANT = 'error';

export default class KnowledgeArticlePage extends NavigationMixin(LightningElement) {

    @api categoryName;
    @api articleId;
    @api url;

    article;
    breadcrumbs;
    
    categoryMap;
    subcategoryMap;
    selectedCategoryName;
    siteURL;
    errorMessage

    first = true;

    connectedCallback() {

        if(this.articleId) {

            redirectToMoreRecentArticle({ articleId: this.articleId })
            .then(result => {
                console.log(result);

                if(!result.redirect) {
                    getArticle({ articleId: this.articleId })
                    .then(result => {
                        if(result.article.Title){
                            document.title=result.article.Title;
                        }
                        this.article = result.article;
                        this.breadcrumbs = result.breadcrumbs;
                        this.categoryName = this.breadcrumbs[1].name;
                    })
                    .catch(error => {

                        this.errorMessage = 'Unknown error';
                        if (Array.isArray(error.body)) {
                            this.errorMessage = error.body.map(e => e.message).join(', ');
                        } else if (typeof error.body.message === 'string') {
                            this.errorMessage = error.body.message;
                        }

                        this.showToast('Error', this.errorMessage, ERROR_VARIANT);
                    });
                }
                else {
                    this[NavigationMixin.Navigate]({
                        "type": "standard__webPage",
                        "attributes": {
                            "url": "/article-page?articleId=" + result.currentArticleId
                        }
                    });
                }
            })
            .catch(error => {

                this.errorMessage = 'Unknown error';
                if (Array.isArray(error.body)) {
                    this.errorMessage = error.body.map(e => e.message).join(', ');
                } else if (typeof error.body.message === 'string') {
                    this.errorMessage = error.body.message;
                }

                this.showToast('Error', this.errorMessage, ERROR_VARIANT);
            });
        }
    }

    handleCategoryUpdated(event) {

        let categoryName = event.detail;

        if(!(this.first && this.categoryName === categoryName)) {            

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "/category-page?categoryName=" + categoryName
                }
            });
        }
        else {
            this.first = false;
        }
    }

    handleNavigateTo(event) {
        // prevent default navigation by href
        event.preventDefault();

        const name = event.target.name;

        let url = '';

        if(this.breadcrumbs[0].name === name) {
            url = "/";
        }
        else if(this.breadcrumbs[1].name === name) {
            url = "/category-page?categoryName=" + name;
        }

        if(url !== '') {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": url
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