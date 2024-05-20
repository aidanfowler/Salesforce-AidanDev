import { LightningElement,track} from 'lwc';

export default class TopicBreadcrumb extends LightningElement {
    pathId;

    connectedCallback(){
        let pathname = window.location.pathname;
        this.pathId = pathname.split('/')[1];
    }

    get homeUrl(){
        return "/"+this.pathId+"/s";
    }
}