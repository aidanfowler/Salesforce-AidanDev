import { LightningElement } from 'lwc';

export default class CsGetstarted extends LightningElement {
    pathId;

    connectedCallback(){
        let pathname = window.location.pathname;
        this.pathId = pathname.split('/')[1];
        if (this.pathId === "s") {
            this.pathId = "";
        } else {
            this.pathId = "/" + this.pathId;
        }
    }

    get contactSupportUrl(){
        return this.pathId + "/s/contactsupport";
    }
}