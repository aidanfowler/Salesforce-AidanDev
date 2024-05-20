import { LightningElement, api } from 'lwc';

export default class KnowledgeSearchCategoryMenu extends LightningElement {

    @api categoryName;
    @api categoryList;

    handleSelect(event) {

        event.stopPropagation();
        event.preventDefault();
        
        let name = event.detail.name;

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('categoryupdated', { detail: name });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}