import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class KnowledgeSupportTicketLeft extends NavigationMixin(LightningElement) {

    @api articleId;

    first = true;

    get currArticleId() {
        return this.articleId ? this.articleId : null;
    }

    handleCategoryUpdated(event) {

        let categoryName = event.detail;

        if(!(this.first)) {            

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
}