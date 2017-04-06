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

    interface VisualSettingsTreeParams {// tree
        show: boolean;
        maxDepth: string;
        minBucket: string;
    }

    interface VisualSettingsOptParams {// optimization
        show: boolean;
        complexity: string;
        xval: string;
        maxNumAttempts: string;
    }

    interface VisualSettingsAdditionalParams {// additional
        show: boolean;
        showWarnings: boolean;
        showInfo: boolean;
    }

    export class Visual implements IVisual {
        private imageDiv: HTMLDivElement;
        private imageElement: HTMLImageElement;

        private settings_tree_params: VisualSettingsTreeParams;
        private settings_opt_params: VisualSettingsOptParams;
        private settings_additional_params: VisualSettingsAdditionalParams;

        public constructor(options: VisualConstructorOptions) {
            this.imageDiv = document.createElement('div');
            this.imageDiv.className = 'rcv_autoScaleImageContainer';
            options.element.appendChild(this.imageDiv);

            this.imageElement = document.createElement('img');
            this.imageElement.className = 'rcv_autoScaleImage';

            this.imageDiv.appendChild(this.imageElement);

             this.settings_tree_params = <VisualSettingsTreeParams>{
                show: false,
                 maxDepth: "15",
                 minBucket: "2",
            };
            this.settings_opt_params = <VisualSettingsOptParams>{
                show: false,
                complexity: "1e-5",
                xval: "auto",
                maxNumAttempts: "10"
            };
            this.settings_additional_params = <VisualSettingsAdditionalParams>{
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

            this.settings_tree_params = <VisualSettingsTreeParams> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings_tree_params', 'show', false),
                maxDepth: getValue<string>(dataView.metadata.objects, 'settings_tree_params', 'maxDepth', "15"),
                minBucket: getValue<string>(dataView.metadata.objects, 'settings_tree_params', 'minBucket', "2"),
            };
            this.settings_opt_params = <VisualSettingsOptParams> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings_opt_params', 'show', false),
                complexity: getValue<string>(dataView.metadata.objects, 'settings_opt_params', 'complexity', "1e-5"),
                xval: getValue<string>(dataView.metadata.objects, 'settings_opt_params', 'xval', "auto"),
                maxNumAttempts: getValue<string>(dataView.metadata.objects, 'settings_opt_params', 'maxNumAttempts', "10"),
            };
             this.settings_additional_params = <VisualSettingsAdditionalParams> {
                show: getValue<boolean>(dataView.metadata.objects, 'settings_additional_params', 'show', false),
                showWarnings: getValue<boolean>(dataView.metadata.objects, 'settings_additional_params', 'showWarnings', true),
                showInfo: getValue<boolean>(dataView.metadata.objects, 'settings_additional_params', 'showInfo', true)
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

            switch (objectName) {
                case 'settings_tree_params':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings_tree_params.show,
                            maxDepth: this.settings_tree_params.maxDepth,
                            minBucket: this.settings_tree_params.minBucket,

                         },
                        selector: null
                    });
                    break;
                    case 'settings_opt_params':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings_opt_params.show,
                            complexity: this.settings_opt_params.complexity,
                            xval: this.settings_opt_params.xval,
                            maxNumAttempts: this.settings_opt_params.maxNumAttempts
                         },
                        selector: null
                    });
                    break;
                    case 'settings_additional_params':
                    objectEnumeration.push({
                        objectName: objectName,
                        properties: {
                            show: this.settings_additional_params.show,
                           showWarnings: this.settings_additional_params.showWarnings,
                           showInfo: this.settings_additional_params.showInfo,
                         },
                        selector: null
                    });
                    break;
            };

            return objectEnumeration;
        }
    }
}