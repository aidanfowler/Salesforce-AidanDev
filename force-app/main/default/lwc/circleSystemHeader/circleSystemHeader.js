import { LightningElement, track } from 'lwc';
export default class CircleSystemHeader extends LightningElement {
    @track systemStatus = "";
    @track systemIndicator = "";
    connectedCallback() {
        fetch('https://status.circle.com/api/v2/status.json')
            .then((response) => response.json())
            .then((data) => {

                    console.log(data.status.description);
                    this.systemStatus = data.status.description;
                    this.systemIndicator = data.status.indicator;
                    //this.template.querySelector('status').innerHTML = data.status.description;
                    
                    let statusCircle = this.template.querySelector('statusCircle');
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

    // renderedCallback() {
    //     fetch('https://status.circle.com/api/v2/status.json')
    //         .then((response) => response.json())
    //         .then((data) => this.template.querySelector('status').innerHTML = data.status.description);
    // }
}