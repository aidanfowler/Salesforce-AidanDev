import { LightningElement, wire, api } from 'lwc';
import {NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest';
import USER_ID from "@salesforce/user/Id";
import submitATicketSuccessMessage from '@salesforce/label/c.Submit_a_Ticket_Success_Message';

import verifyRecaptcha from '@salesforce/apex/SubmitATicketController.insertRecord';
import getEmailAddress from '@salesforce/apex/SubmitATicketController.getEmailAddress';
import getContactId from '@salesforce/apex/SubmitATicketController.getContactId';
import getSupportSettings from '@salesforce/apex/SubmitATicketController.getSupportSettings';
import getArticleTitle from '@salesforce/apex/SubmitATicketController.getArticleTitle';
import getArticleMainCategory from '@salesforce/apex/SubmitATicketController.getArticleMainCategory';

const ERROR_VARIANT = 'error';
const SUCCESS_VARIANT = 'success';
const CASE_SUBMITTED_TITLE = 'Case Submmited';
const CASE_SUBMITTED_MESSAGE = submitATicketSuccessMessage;

export default class KnowledgeSubmitATicket extends NavigationMixin(LightningElement) {
    @api articleId;

    @wire(CurrentPageReference)
    currentPageReference;

    currentUserEmail;
    isGuestUser = isguest;

    userId = USER_ID;

    articleTitle;
    articleCategory;
    categoryName;

    verified = false;
    isValid = true;
    supportSettings;
    contactId;
    isLoading = false;
    source = null;

    @wire(getSupportSettings) 
    currentUserInfo({error, data}) {

        if (data) {

            this.supportSettings = data;
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(CurrentPageReference)
    getUrlParams(currentPageRefernce){
        if(currentPageRefernce){
            this.source = currentPageRefernce.state?.source;
        }
    }

    connectedCallback() {
        this.categoryName = this.currentPageReference.state.categoryName;
        if(this.userId) {

            getEmailAddress()
                .then(result => {

                    this.currentUserEmail = result;
                })
                .catch(error => {
                    console.log('error');
                    console.log(error);
                });

            getContactId({userId: this.userId})
                .then(result => {

                    this.contactId = result;
                })
                .catch(error => {
                    console.log('error');
                    console.log(error);
                });
        }

        if(this.articleId) {
            getArticleTitle({articleId: this.articleId})
                .then(result => {
                    this.articleTitle = result;
                })
                .catch(error => {
                    console.log('error');
                    console.log(error);
                });
            getArticleMainCategory({articleId: this.articleId})
            .then(result => {
                this.articleCategory = result;
            })
            .catch(error => {
                console.log('error');
                console.log(error);
            });
        }

        if(typeof(this.template) !== 'undefined') {
            
            var currentDoc = this;

        document.addEventListener("grecaptchaVerified", function(e) {
            verifyRecaptcha({ record: null, //TODO: map UI fields to sobject
                recaptchaResponse: e.detail.response})
                .then(result => {

                    currentDoc.verified = true;
                })
                .catch(error => {
                    console.log('error');
                    console.log(error);
                });

        });

        }
    }

    renderedCallback() {
            var divElement = this.template.querySelector('div.recaptchaInvisible');

            if(divElement) {
                //valide values for badge: bottomright bottomleft inline
                var payload = {element: divElement, badge: 'bottomright'};
                document.dispatchEvent(new CustomEvent("grecaptchaRender", {"detail": payload}));
            }

            /*var labelElements = this.template.querySelectorAll('label');

            console.log(labelElements);

            for(let i = 0; i < labelElements.length; i++) {
                labelElements.classList.remove("hidden");
            }*/
    }

    

    doSubmit(evt){
        document.dispatchEvent(new Event("grecaptchaExecute"));
    }

    handleSubmit(event) {
        //document.dispatchEvent(new CustomEvent("analyticsSupport", { "detail" : "test abc" }));
        if(!(this.isGuestUser && !this.verified)) {

            this.isLoading = true;

            let fields = [];
            this.isValid = true;

            const inputFields = this.template.querySelectorAll(
                'lightning-input-field'
            );

            if (inputFields) {
                inputFields.forEach(field => {

                    let fieldValid = field.reportValidity();

                    if(this.isValid) {
                        this.isValid = fieldValid;
                    }

                    fields[field.fieldName] = field.value;
                });
            }

            if(this.isValid) {
                if(!this.source){
                    fields['Origin'] = this.supportSettings.Case_Origin__c;
                }
                else{
                    fields['Origin'] = this.source;
                }
                if(this.source == 'CAP_Discord'){
                    fields['OwnerId'] = this.supportSettings.Sales_Queue_ID__c;
                }
                else{
                    fields['OwnerId'] = this.supportSettings.Case_Queue_Id__c;
                }

                if(!this.isGuestUser) {
                    fields['ContactId'] = this.contactId;
                }

                fields['Subject'] = fields['Description'];
                if(this.articleId){
                    if(this.articleTitle){
                        fields['Referral_Article_Title__c'] = this.articleTitle;
                    }
                    if(this.articleCategory){
                        fields['Referral_Category__c'] = this.articleCategory;
                    }
                }
                else if(this.categoryName){
                    fields['Referral_Category__c'] = this.categoryName;
                }
                else{
                    fields['Referral_Category__c'] = 'Home_Page';
                }

                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            else {
                this.isLoading = false;
            }
        }
    }

    

    handleSuccess(event) {
        /*let payload = { detail: 
            { 
                'user_id': 'abc', 
                'user_properties': {
                    'user_id': '456',
                    'account_rating': 'Silver'
                }
            }
        };
        console.log('should be sending event');
        //publish custom event for the listener in the head markup to handle
        document.dispatchEvent(new CustomEvent('analyticsSupport', payload));*/
        this.isLoading = false;
        document.dispatchEvent(new Event("grecaptchaReset"));
        this.resetForm();
        this.showToast(CASE_SUBMITTED_TITLE, CASE_SUBMITTED_MESSAGE, SUCCESS_VARIANT);
    }

    handleError(event) {

        this.isLoading = false;

        let message = event.detail.detail;
        //do some stuff with message to make it more readable

        if(message === '' && this.isValid) {
            
            if(this.isGuestUser) {
                document.dispatchEvent(new Event("grecaptchaReset"));
            }
            this.resetForm();
            this.showToast(CASE_SUBMITTED_TITLE, CASE_SUBMITTED_MESSAGE, SUCCESS_VARIANT);
        }
        else if(this.isValid) {
            this.showToast('Error', message, ERROR_VARIANT);
        }
    }

    showToast(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'pester'
        });
        this.dispatchEvent(toastEvent);
    }

    resetForm() {
        const inputFields = this.template.querySelectorAll( 'lightning-input-field' );
        if ( inputFields ) {
            inputFields.forEach( field => {
                field.reset();
            } );
        }
    }

    handleSubmitCase(event) {

        this.isLoading = false;

        // if(this.isGuestUser) {
        //     this[NavigationMixin.Navigate]({
        //         "type": "standard__webPage",
        //         "attributes": {
        //             "url": "/case-submitted"
        //         }
        //     });
        // }
    }
}