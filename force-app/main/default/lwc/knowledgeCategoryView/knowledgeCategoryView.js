import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityPath from '@salesforce/community/basePath';
import getSupportCategories from '@salesforce/apex/CategoryMenuController.getSupportCategories';

const ERROR_VARIANT = 'error';

export default class KnowledgeCategoryView extends NavigationMixin(LightningElement) {

    categoryList;
    siteURL;
    errorMessage;

    @wire(getSupportCategories, { checkingSuggestedArticles: false})
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

            this.categoryList = JSON.parse(JSON.stringify(data));

            for(let category of this.categoryList) {
                //category.iconURL = CIRCLE_ASSETS + '/icons/' + category.icon;
                category.name = category.name.replace('__c', '');
                category.url = communityPath + '/category-page?categoryName=' + category.name;
            }
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