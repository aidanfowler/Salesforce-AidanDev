import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getRecentlyViewedArticles from '@salesforce/apex/RecentlyViewedArticlesController.getRecentlyViewedArticles';

const ERROR_VARIANT = 'error';

export default class KnowledgeRecentlyViewedArticles extends NavigationMixin(LightningElement) {

    @api articleId;

    articleList;
    errorMessage;

    @wire(getRecentlyViewedArticles, {articleId: '$articleId'})
    wiredRecord({ error, data }) {
        if (error) {

            console.log(error);

            this.errorMessage = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errorMessage = error.body.message;
            }

            this.showToast('Error', this.errorMessage, ERROR_VARIANT);
            
        } else if (data) {

            this.articleList = JSON.parse(JSON.stringify(data));
        }
    }

    renderedCallback(){
        if(typeof(this.articleId) === 'undefined') {
            this.articleId = null;
        }
    }

    handleSelect(event) {
        let articleId = event.detail.name;

        if(articleId) {

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