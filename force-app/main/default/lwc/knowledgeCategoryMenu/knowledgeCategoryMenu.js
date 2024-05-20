import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {
    MessageContext,
    publish
} from 'lightning/messageService';
import categoryNameUpdated from '@salesforce/messageChannel/CategoryNameUpdated__c';
import getSupportCategories from '@salesforce/apex/CategoryMenuController.getSupportCategories';

const ERROR_VARIANT = 'error';

export default class KnowledgeCategoryMenu extends NavigationMixin(LightningElement) {
    
    @api categoryName;
    categoryList;
    selectedCategoryName;
    first = false;

    errorMessage;

    @wire(MessageContext)
    messageContext;

    @wire(getSupportCategories, { checkingSuggestedArticles: false})
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

            this.categoryList = JSON.parse(JSON.stringify(data));

            for(let category of this.categoryList) {
                category.name = category.name.replace('__c', '');
            }
        }
    }

    handleSelect(event) {

        event.stopPropagation();
        
        let name = event.detail.name;

        if(name !== 'Circle_News') {

            // Creates the event with the contact ID data.
            const selectedEvent = new CustomEvent('categoryupdated', { detail: name });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);

            const found = this.categoryList.find(category => category.name === name);

            if(found) {
                const payload = { categoryName: found.label };

                publish(this.messageContext, categoryNameUpdated, payload);
            }
        }
        else {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "https://www.circle.com/blog/tag/company-updates"
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