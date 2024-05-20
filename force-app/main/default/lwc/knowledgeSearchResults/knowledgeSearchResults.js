import { LightningElement, api } from 'lwc';

const TOKENS_TO_IGNORE = ['a', 'the', 'and'];
const REG_EXP_SEPARATOR = '|';
const AND_SEPARATOR = '+';

export default class KnowledgeSearchResults extends LightningElement {

    @api searchResults;
    @api categories;
    @api term;
    @api numResults;

    tokensToIgnore = TOKENS_TO_IGNORE;

    get updatedSearchResults() {

        // Get the terms to highlight.
        let tempTerm = JSON.parse(JSON.stringify(this.term));

        let termValues = tempTerm.split(AND_SEPARATOR);

        if(termValues.length === 0) {
            termValues.push(tempTerm);
        }

        let additionalItems = [];

        // Split on space and add the terms.
        for(let termValue of termValues) {

            var strValues = termValue.split(' ');
            let newValues = JSON.parse(JSON.stringify(strValues));

            if(newValues.length > 0) {
                additionalItems = additionalItems.concat(newValues);
            }
        }

        termValues = termValues.concat(additionalItems).filter(item => !this.tokensToIgnore.includes(item));

        let tempSearchResults = JSON.parse(JSON.stringify(this.searchResults));
        // Create the regexp for the terms.
        let regExpValues = termValues.join(REG_EXP_SEPARATOR);
        // Should allow additional characters at beginning and end. End at spaces.
        //let regEx = new RegExp('\\S*(' + regExpValues + ')[^!._,\'@?/s]*', "igu");
        //let regEx = new RegExp('^\\w*(' + regExpValues +')\\w*$', "ig");
        let regEx = new RegExp('\\b\\w*(' + regExpValues + ')\\w*\\b', "ig");

        for(let searchResult of tempSearchResults) {

            if(searchResult.description) {

                searchResult.description = searchResult.description.replaceAll(regEx, function replace(match) {
                    return '<span class="highlight">' + match + '</span>';
                });
            }
            if(searchResult.title) {
                searchResult.title = searchResult.title.replaceAll(regEx, function replace(match) {
                    return '<span class="highlight">' + match + '</span>';
                });
            }
        }

        return tempSearchResults;
    }

    handleClick(event) {

        let id = event.currentTarget.dataset.targetId;

        // Creates the event with the contact ID data.
        const selectedEvent = new CustomEvent('articleclicked', { detail: id });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}