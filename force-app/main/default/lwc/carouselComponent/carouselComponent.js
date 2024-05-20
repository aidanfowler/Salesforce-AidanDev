/*
MIT License

Copyright (c) 2020 Playground, https://www.playg.app

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import { LightningElement, api, track } from 'lwc';
import formFactorPropertyName from '@salesforce/client/formFactor';

const SMALL_SIZE = 'Small';

export default class CarouselComponent extends LightningElement {

    @api items;
    @api options;
    @track components;
    @track showComponents;
    @track showPlayIcon;
    activeComponent = 0;
    loaded = false;
    autoScroll;
    intervalVar;
    index = 0;


    get pageSize() {
        let size = 3;

        if(formFactorPropertyName === SMALL_SIZE) {
            size = 1;
        }

        return size;
    }

    navigate(event) {
        this.activeComponent = parseInt(event.target.dataset.id);
        this.arrangeComponents();
    }

    arrangeComponents() {
        let untrackedComponents = [];
        this.showComponents = [];
        let iterator = 0;
        this.items.forEach(item => {
            let temp = { ...item };
            temp.id = iterator;
            temp.contentId = 'content-id-' + iterator;
            temp.indicatorId = 'indicator-id-' + iterator;
            if(temp.href){
                temp.href='javascript:void(0);';
            }
            untrackedComponents.push(temp);
            iterator++;
        });
        this.components = untrackedComponents;
        this.loadComponenets();
    }

    loadComponenets(){
        let firstVideoIndex, secondVideoIndex, thirdVideoIndex;
        firstVideoIndex = this.index;
        secondVideoIndex = this.index+1;
        thirdVideoIndex = this.index+2;
        if(thirdVideoIndex == this.components.length){
            thirdVideoIndex = 0;
        }
        if(thirdVideoIndex == this.components.length+1){
            secondVideoIndex = 0;
            thirdVideoIndex = 1;
        }
            
        if(this.pageSize == 1){
            this.showComponents[0]=this.components[firstVideoIndex];
        }
        else{
            this.showComponents[0]=this.components[firstVideoIndex];
            this.showComponents[1]=this.components[secondVideoIndex];
            this.showComponents[2]=this.components[thirdVideoIndex];
        }
    }

    togglePlay(){
        if(!this.showPlayIcon){
            clearInterval(this.intervalVar);
            this.showPlayIcon = true;
        }else{
            this.checkOptions();
        }
    }

    checkOptions() {
        if (this.options) {
            if (this.options.autoScroll && this.options.autoScrollTime) {
                this.autoScroll = true;
                this.showPlayIcon = false;
                this.intervalVar = setInterval(() => {
                    if (this.activeComponent === (this.components.length - 1)) {
                        this.activeComponent = 0;
                    } else {
                        this.activeComponent++;
                    }
                    this.arrangeComponents();
                }, this.options.autoScrollTime * 1000);
            }
        }
    }

    next() {
        this.index++;
        if(this.index > this.components.length-1){
            this.index = 0;
        }
        this.loadComponenets();
    }

    previous() {
        this.index--;
        if(this.index < 0){
            this.index = this.components.length-1;
        }
        this.loadComponenets();
    }

    renderedCallback() {
        if (!this.loaded) {
            this.arrangeComponents();
            this.checkOptions();

            this.loaded = true;
        }
    }

    goToURL() {
        
    }
}