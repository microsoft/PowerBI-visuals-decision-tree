# PowerBI-visuals-decision-tree
R powered custom visual based on rpart package

![Decision tree chart screenshot](https://az158878.vo.msecnd.net/marketing/Partner_21474836617/Product_42949680602/Asset_5fe01271-f11d-4f16-8096-59d4e2f88158/DecisionTreescreenshot3.png)
# Overview
Decision trees are probably one of the most common and easily understood decision support tools.

The decision tree learning automatically find the important decision criteria to consider and uses the most intuitive and explicit visual representation.

Current visual implements the popular and widely used tools of recursive partitioning for decision tree construction. Each leaf of the tree is labeled with a class and a probability distribution over the classes. Beside this we use cross validation to estimate the statistical performance of the decision tree.

If the target variable is categorical or has only few possible values the "Classification Tree" is constructed, whereas if the target variable is numeric the result of the visual is "Regression Tree".

You can control the algorithm parameters and the visual attributes to suit your needs.

Here is how it works:
* Define the "Target Variable" (exactly one) and "Input Variables" (two or more columns)
* Controll the basic properties of the tree such as maximum depth and the minimum observation number per leaf
* If you are the advanced user, control the recursive partitioning and cross-validation parameters

R package dependencies(auto-installed): rpart, rpart.plot, RColorBrewer

Supports R versions: R 3.3.1, R 3.3.0, MRO 3.3.1, MRO 3.3.0, MRO 3.2.2

See also [Decision Tree Chart at Microsoft Office store](https://store.office.com/en-us/app.aspx?assetid=WA104380817&sourcecorrid=c0c218da-1181-4620-9503-d4b4c2eead2e&searchapppos=0&ui=en-US&rs=en-US&ad=US&appredirect=false)