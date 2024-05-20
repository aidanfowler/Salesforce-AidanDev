import { LightningElement } from 'lwc';

export default class SearchBar extends LightningElement {
    handleInputFocus(event) {
        console.log('onfocus fired');
        console.log(event.target.name);
        var element = document.getElementById("131:0-listbox");
        element.classList.remove("comm-hide");
    }
}