import { LightningElement, wire } from 'lwc';
import CIRCLE_ASSETS from '@salesforce/resourceUrl/CircleAssets';
import communityPath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';

const QUESTION_MARK_ICON = '/icons/question_post_action.svg';
const CLOSE_ICON = '/icons/remove.svg';

export default class KnowledgeFooter extends LightningElement {
    icon = CIRCLE_ASSETS + QUESTION_MARK_ICON;

    showPopup = false;

    get articleId() {
        return this.currentPageReference.state.articleId ? this.currentPageReference.state.articleId : '';
    }

    get categoryName(){
        return this.currentPageReference.state.categoryName ? this.currentPageReference.state.categoryName : '';
    }

    get supportUrl() {

        let submitTicketUrl;

        if(this.articleId !== '') {
            submitTicketUrl = communityPath + '/submit-ticket?articleId=' + this.articleId;
        }
        else if(this.categoryName !== ''){
            submitTicketUrl = communityPath + '/submit-ticket?categoryName=' + this.categoryName;
        }
        else {
            submitTicketUrl = communityPath + '/submit-ticket';
        }

        return submitTicketUrl;
    }

    @wire(CurrentPageReference)
    currentPageReference;

    handleShowPopup(event) {

        event.stopPropagation();
        event.preventDefault();

        if(this.showPopup) {
            this.showPopup = false;
            this.icon = CIRCLE_ASSETS + QUESTION_MARK_ICON;
        }
        else {
            this.showPopup = true;
            this.icon = CIRCLE_ASSETS + CLOSE_ICON;
        }

        //this.showPopup = !this.showPopup;
    }
}