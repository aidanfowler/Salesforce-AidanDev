/* eslint-disable no-console */
// Import LightningElement and api classes from lwc module
import { LightningElement, api, wire, track } from 'lwc';
// import getPicklistValues method from lightning/uiObjectInfoApi
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
// import getObjectInfo method from lightning/uiObjectInfoApi
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
// Import lead object APi from schema
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
// import Lead status field from schema
import PICKLIST_FIELD from '@salesforce/schema/Opportunity.StageName';
// import record ui service to use crud services
import { getRecord} from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';


const FIELDS = [
    'Opportunity.Id',
    'Opportunity.StageName'
];

export default class CustomPath extends LightningElement {

    @track selectedValue;
    @api recordId;
    closedOpp;

    @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;


    get picklistValues() {
        refreshApex(this.record);
        this.closedOpp = false;
        let closedWon = false;
        let closedLost = false;
        let itemsList = [];
        if (this.record.data && this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
            if(this.record.data.fields.StageName.value === 'Closed Lost' || this.record.data.fields.StageName.value === 'Closed Won'){
                this.closedOpp = true;
                if(this.record.data.fields.StageName.value === 'Closed Lost'){
                    closedLost = true;
                }
                else if (this.record.data.fields.StageName.value === 'Closed Won'){
                    closedWon = true;
                }
            }

            let foundActiveStatus = false;
            for (let item in this.picklistFieldValues.data.values) {
                if (Object.prototype.hasOwnProperty.call(this.picklistFieldValues.data.values, item)) {
                    let classList;
                    if (this.picklistFieldValues.data.values[item].value === this.record.data.fields.StageName.value) {
                        classList = 'slds-path__item slds-is-current slds-is-active';
                        if(this.record.data.fields.StageName.value === 'Closed Won'){
                            classList += ' slds-is-won';
                            
                        }
                        else if(this.record.data.fields.StageName.value === 'Closed Lost'){
                            classList += ' slds-is-lost';
                            closedLost = true;
                        }
                        foundActiveStatus = true;
                    } 
                    else if(foundActiveStatus || this.record.data.fields.StageName.value === 'Closed Lost') {
                        classList = 'slds-path__item slds-is-incomplete noHover';
                    }
                    else{
                        classList = 'slds-path__item slds-is-complete';
                    }
                    
                    if((!this.closedOpp && this.picklistFieldValues.data.values[item].value != 'Closed Lost' && this.picklistFieldValues.data.values[item].value != 'Closed Won') ||
                        (closedWon == true && this.picklistFieldValues.data.values[item].value != 'Closed Lost') || 
                        (closedLost == true && this.picklistFieldValues.data.values[item].value != 'Closed Won')){
                        itemsList.push({
                            pItem: this.picklistFieldValues.data.values[item],
                            classList: classList
                        })
                    }
                }
            }
            return itemsList;
        }
        return null;
    }
}