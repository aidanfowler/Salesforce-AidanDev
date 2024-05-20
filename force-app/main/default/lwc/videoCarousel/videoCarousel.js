import { LightningElement, wire } from 'lwc';

import communityPath from '@salesforce/community/basePath';
import getVideos from '@salesforce/apex/VideoCarouselController.getVideos';

export default class VideoCarousel extends LightningElement {

    videos;
    options = { autoScroll: false, autoScrollTime: 2 };

    @wire(getVideos)
    wiredRecord({ error, data }) {
        if (error) {

            console.log(error);

            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            
        } else if (data) {

            this.videos = JSON.parse(JSON.stringify(data));

            for(let video of this.videos) {
                video.url = communityPath + video.url;
            }

            this.videos.sort((a, b) => (a.order > b.order) ? -1 : 1);
        }
    }
}