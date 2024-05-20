import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import Id from '@salesforce/user/Id';
import formFactorPropertyName from '@salesforce/client/formFactor'
import CIRCLE_ASSETS from '@salesforce/resourceUrl/CircleAssets';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
} from 'lightning/messageService';
import categoryNameUpdated from '@salesforce/messageChannel/CategoryNameUpdated__c';

import communityPath from '@salesforce/community/basePath';

const SMALL_SIZE = 'Small';

export default class KnowledgeHeader extends NavigationMixin(LightningElement) {

    @api term;
    @api commonSearchTerms;
    @api showSearch;
    @api showTitle;
    @api title;

    @track systemStatus = "";
    @track systemIndicator = "";

    userId = Id;

    circleImage = CIRCLE_ASSETS + '/images/logo_support-stacked.png';

    get updatedTerm() {
        return this.term ? decodeURI(this.term) : '';
    }

    get searchTerms() {
        // Get a list of the common search terms
        return this.commonSearchTerms ? this.commonSearchTerms.split(',') : [];
    }

    get pageTitle() {
        return this.title ? decodeURI(this.title) : '';
    }

    get smallFormFactor() {
        return formFactorPropertyName === SMALL_SIZE;
    }

    get divStyle() {

        let style = 'width:600px;margin:auto;';

        if(formFactorPropertyName === SMALL_SIZE) {
            style = 'width:350px;margin:auto;';
        }

        return style;
    }

    get commonSearchTermsClass() {

        let classes = "slds-p-around_xx-small";

        if(formFactorPropertyName === SMALL_SIZE) {
            classes="slds-col slds-size--1-of-1 slds-small-size--1-of-2 slds-medium-size--1-of-4"
        }

        return classes;
    }

    @wire(MessageContext)
    messageContext;

    // Encapsulate logic for Lightning message service subscribe and unsubsubscribe
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                categoryNameUpdated,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    // Handler for message received by component
    handleMessage(message) {
        this.title = message.categoryName;
    }

    connectedCallback() {

        this.subscribeToMessageChannel();

        this.getStatus();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    getStatus() {
        fetch('https://status.circle.com/api/v2/status.json')
            .then((response) => response.json())
            .then((data) => {

                    // Set the status
                    this.systemStatus = data.status.description;
                    this.systemIndicator = data.status.indicator;

                    let statusCircle = this.template.querySelector('[data-recid="statusCircle"]');

                    if(this.systemIndicator !== "none" && this.systemIndicator !== "operational"){
                        if(this.systemIndicator == 'minor'){
                            statusCircle.className = 'statusMinor';
                        }
                        else if(this.systemIndicator == 'major'){
                            statusCircle.className = 'statusMajor';
                        }
                        else if(this.systemIndicator == 'critical'){
                            statusCircle.className = 'statusCritical';
                        }
                        else if(this.systemIndicator == 'maintenance'){
                            statusCircle.className = 'statusMaintenance';
                        }
                    }
                    
                });
    }

    handleHome(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": communityPath
            }
        });
    }

    handleDevelopersClick(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "https://developers.circle.com/"
            }
        });
    }

    handleLogin(event) {

        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'login'
            }
        });
    }

    handleLogout(event){
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            }
        });
    }

    handleSearch(event) {

        let searchTerm = event.target.getAttribute("name");

        searchTerm = searchTerm.replaceAll(' ', '+');

        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/searchResults?term=" + encodeURI(searchTerm)
            }
        });
    }

    handleEnter(event) {

        if(event.keyCode === 13){
            let term = event.target.value;

            if(term !== '') {

                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": "/searchResults?term=" + encodeURI(term)
                    }
                });
            }
        }
    }
}