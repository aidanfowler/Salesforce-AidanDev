import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getCategoryMap from '@salesforce/apex/CategoryPageController.getCategoryMap';

const ERROR_VARIANT = 'error';

export default class KnowledgeCategoryPage extends NavigationMixin(LightningElement) {

    @api categoryName;
    
    categoryMap;
    subcategoryMap;
    selectedCategoryName;
    siteURL;

    errorMessage;

    connectedCallback() {

        if(this.categoryName) {

            getCategoryMap({ categoryName: this.categoryName })
            .then((result) => {
                this.categoryMap = result;

                this.subcategoryMap = this.categoryMap[this.categoryName];
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
    }

    setCategoryMap() {
        
		if(this.categoryName !== 'undefined') {

            this.categoryName = decodeURI(this.categoryName);

			this.subcategoryMap = this.categoryMap[this.categoryName];
		}
	}

    handleCategoryUpdated(event) {

        if(event.detail !== this.categoryName) {

            this.categoryName = event.detail;

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "/category-page?categoryName=" + this.categoryName
                }
            });
        }
        if(this.categoryName){
            if(this.categoryName == 'Euro_Coin'){
                document.title = 'EURC';
            }
            else{
                document.title = this.categoryName.replaceAll('_',' ');
            }
        }
    }

    handleSelect(event) {

        if(event.detail.name && event.detail.name !== '') {

            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": "/article-page?articleId=" + event.detail.name
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