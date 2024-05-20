import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityPath from '@salesforce/community/basePath';
import getCategoryMap from '@salesforce/apex/SuggestedArticlesController.getCategoryMap';

const ERROR_VARIANT = 'error';

export default class KnowledgeSuggestedArticles extends LightningElement {

    @api categoryName;

    categoryList;
    categoryMap;
    errorMessage;

    heightSaves = [];

    @wire(getCategoryMap)
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
                category.iconName = 'utility:chevrondown';
                category.class ='slds-accordion__section accordion-state_closed';

                for(let article of category.articles) {
                    article.url = communityPath + '/article-page?articleId=' + article.Id;
                }
            }
        }
    }

    handleClick(event) {

        console.log()

        let tempCategoryList = JSON.parse(JSON.stringify(this.categoryList));

        let index = tempCategoryList.findIndex(item => item.name === event.currentTarget.name);

        let sections = this.template.querySelectorAll('.slds-accordion__section');

        let el = sections[index];

        if(index !== -1) {

            var icon = this.template.querySelectorAll('lightning-icon')[index];

            if(icon.iconName === 'utility:chevronup') {

                this.slideUp(el, index, icon);
            }
            else {

                this.slideDown(el, index, icon);
            }
        }
        
    }

    getHeight(el) {
        el.style.display = 'block'; // Make it visible
        //var height = el.scrollHeight + 'px'; // Get it's height
        el.style.display = ''; //  Hide it again
        return height;
    }

    // Shows an element
    slideDown(el, index, icon) {

        var contentEl = this.template.querySelectorAll('.slds-accordion__content')[index];

        // Get the natural height of the element
        if(contentEl) {
            //var height = this.getHeight(el); // Get the natural height
            //var height = this.getHeight(el);
            var height = this.heightSaves[index];

            el.className ='slds-accordion__section opening';

            // Once the transition is complete, remove the inline height so the content can scale responsively
            setTimeout(function () {
                contentEl.style.height = height;
                el.className = 'slds-accordion__section accordion-state_open';
                icon.iconName = 'utility:chevronup';
            }, 200);
        }
    }

    // Hide an element
    slideUp(el, index, icon) {
        var contentEl = this.template.querySelectorAll('.slds-accordion__content')[index];

        // Get the natural height of the element
        if(contentEl) {

            contentEl.style.height = contentEl.scrollHeight + 'px';

            this.heightSaves[index] = contentEl.style.height;

            // Set the height back to 0
            setTimeout(function () {

                //categoryItem.class = 'slds-accordion__section closing';
                el.className = 'slds-accordion__section closing';
                contentEl.style.height = '0px';
            }, 1);

            // When the transition is complete, hide it
            setTimeout(function () {

                icon.iconName = 'utility:chevrondown';
                el.className = 'slds-accordion__section accordion-state_closed';
                contentEl.style.height = '0px';
            }, 500);
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