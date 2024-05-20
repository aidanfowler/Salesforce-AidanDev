import { LightningElement, api, wire } from 'lwc';

import getKnowledgeArticleId from "@salesforce/apex/KnowledgeArticleURLController.getKnowledgeArticleId";
import getSupportSettings from "@salesforce/apex/KnowledgeArticleURLController.getSupportSettings";

export default class KnowledgeArticleURL extends LightningElement {

    @api recordId;
    @api knowledgeArticle;
    @api supportSettings;

    get url() {

        return 'https://help.circle.com/s/article-page?articleId=' + this.knowledgeArticle.KnowledgeArticleId;
    }

    @wire(getSupportSettings, {})
    supportSettingsRecord({ error, data }) {
        if (error) {

            this.errorMessage = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errorMessage = error.body.message;
            }
            
        } else if (data) {
            console.log(data);

            this.supportSettings = data;
        }
    }

    @wire(getKnowledgeArticleId, { recordId: '$recordId'})
    wiredRecord({ error, data }) {
        if (error) {

            this.errorMessage = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.errorMessage = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.errorMessage = error.body.message;
            }
            
        } else if (data) {

            console.log(data);

            this.knowledgeArticle = data;
        }
    }    
}