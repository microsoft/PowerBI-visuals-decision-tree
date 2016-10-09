/*
 *  Power BI Visual CLI
 *
 *  Copyright (c) Microsoft Corporation
 *  All rights reserved.
 *  MIT License
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the ""Software""), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in
 *  all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *  THE SOFTWARE.
 */
module powerbi.extensibility.visual {

    export interface ScriptResult {
        source: string;
        provider: string;
    }
    
     interface VisualSettings1 {//data preprocessing
        show: boolean;
        maxDepth: string;      
        minBucket: string;            
    }

     interface VisualSettings2 {//clustering algo
        show: boolean;
        complexity: string;     
        xval: string;
        maxNumAttempts: string;
     }

     interface VisualSettings3 {//appearance 
        show: boolean;
        showWarnings: boolean;
        showInfo: boolean;
     }

    export class Visual implements IVisual {
        private imageDiv: HTMLDivElement;
        private imageElement: HTMLImageElement;

         private settings1: VisualSettings1;
        private settings2: VisualSettings2;
        private settings3: VisualSettings3;

        public constructor(options: VisualConstructorOptions) {
            this.imageDiv = document.createElement('div');
            this.imageDiv.className = 'rcv_autoScaleImageContainer';
            options.element.appendChild(this.imageDiv);
            
            this.imageElement = document.createElement('img');
            this.imageElement.className = 'rcv_autoScaleImage';

            this.imageDiv.appendChild(this.imageElement);

             this.settings1 = <VisualSettings1>{
                show: false,
                 maxDepth: "15",
                 minBucket: "2",
            };
            this.settings2 = <VisualSettings2>{
                show: false,
                complexity: "1e-5",              
                xval: "auto",
                maxNumAttempts: "10"
            };
            this.settings3 = <VisualSettings3>{
                show: false,
                showWarnings: true,
                showInfo: true,
             };
        }

        public update(options: VisualUpdateOptions) {
            let dataViews: DataView[] = options.dataViews;
            if (!dataViews || dataViews.length === 0)
                return;

            let dataView: DataView = dataViews[0];
            if (!dataView || !dataView.metadata)
                return;

            this.settings1 = <VisualSettings1> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings1', 'show', false),
                maxDepth: getValue<string>(dataView.metadata.objects, 'settings1', 'maxDepth', "15"),
                minBucket: getValue<string>(dataView.metadata.objects, 'settings1', 'minBucket', "2"),
            };
            this.settings2 = <VisualSettings2> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings2', 'show', false),
                complexity: getValue<string>(dataView.metadata.objects, 'settings2', 'complexity', "1e-5"),
                xval: getValue<string>(dataView.metadata.objects, 'settings2', 'xval', "auto"),
                maxNumAttempts: getValue<string>(dataView.metadata.objects, 'settings2', 'maxNumAttempts', "10"),
            };
             this.settings3 = <VisualSettings3> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings3', 'show', false),
                showWarnings: getValue<boolean>(dataView.metadata.objects, 'settings3', 'showWarnings', true),
                showInfo: getValue<boolean>(dataView.metadata.objects, 'settings3', 'showInfo', true)
            };


            let imageUrl: string = null;
            if (dataView.scriptResult && dataView.scriptResult.payloadBase64) {
                imageUrl = "data:image/png;base64," + dataView.scriptResult.payloadBase64;
            }

            if (imageUrl) {
                this.imageElement.src = imageUrl;
            } else {
                this.imageElement.src = null;
            }

            this.onResizing(options.viewport);
        }

        public onResizing(finalViewport: IViewport): void {
            this.imageDiv.style.height = finalViewport.height + 'px';
            this.imageDiv.style.width = finalViewport.width + 'px';
        }

 public enumerateObjectInstances(options: EnumerateVisualObjectInstancesOptions): VisualObjectInstanceEnumeration {
            let objectName = options.objectName;
            let objectEnumeration = [];

            switch(objectName) {
                case 'settings1':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings1.show,
                            maxDepth: this.settings1.maxDepth,
                            minBucket: this.settings1.minBucket,
                            
                         },
                        selector: null
                    });
                    break;
                    case 'settings2':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings2.show,
                            complexity: this.settings2.complexity,
                            xval: this.settings2.xval,
                            maxNumAttempts: this.settings2.maxNumAttempts
                         },
                        selector: null
                    });
                    break;
                    case 'settings3':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings3.show,
                           showWarnings: this.settings3.showWarnings,
                           showInfo: this.settings3.showInfo,
                         },
                        selector: null
                    });
                    break;
            };

            return objectEnumeration;
        }
    }
}