# Copyright (c) Microsoft Corporation.  All rights reserved.

# Third Party Programs. This software enables you to obtain software applications from other sources. 
# Those applications are offered and distributed by third parties under their own license terms.
# Microsoft is not developing, distributing or licensing those applications to you, but instead, 
# as a convenience, enables you to use this software to obtain those applications directly from 
# the application providers.
# By using the software, you acknowledge and agree that you are obtaining the applications directly
# from the third party providers and under separate license terms, and that it is your responsibility to locate, 
# understand and comply with those license terms.
# Microsoft grants you no license rights for third-party software or applications that is obtained using this software.


##PBI_R_VISUAL: VIZGAL_DTREE  Graphical display of Decision Tree 
# Computes and visualizes a decision tree used for classification or piecewise regression
# 
# INPUT: 
# The input dataset should include at least two columns. First column is a dependent variable,  
# the rest of columns are independend variables. 
# EXAMPLES:
#  #for R environment
#  dataset<-mtcars #assign dataset
#  source("visGal_corrplot.R") #create graphics
#
# WARNINGS: 
#     This visual intended to be used for classification tasks. It was not tested for regression trees. 
#
# CREATION DATE: 06/01/2016
#
# LAST UPDATE: 08/09/2016
#
# VERSION: 0.0.1
#
# R VERSION TESTED: 3.2.2
# 
# AUTHOR: B. Efraty (boefraty@microsoft.com)
#
# REFERENCES: https://cran.r-project.org/web/packages/corrplot/vignettes/corrplot-intro.html



if(exists("Target") && !exists("Variables"))
{
  plot.new()
  title( main  =  NULL, sub  =  "`Input Variables` are not yet defined", outer  =  FALSE, col.sub  =  "gray50" )
  dataset =data.frame(demo1=1,demo2=2) # demo to stop execution with empty plot
}

if(!exists("Target") && exists("Variables"))
{
  plot.new()
  title( main  =  NULL, sub  =  " `Target Variable` is not yet defined", outer  =  FALSE, col.sub  =  "gray50" )
  dataset =data.frame(demo1=1,demo2=2) # demo to stop execution with empty plot
}
#  stop("Variable `Target` is not defined")

if(exists("Target") && exists("Variables") && !exists( "dataset" ))
  dataset = cbind(Target,Variables)



#PBI_EXAMPLE_DATASET for debugging purposes 
if(!exists( "dataset" ))
{
  data( iris ) #Sepal.Length, Sepal.Width, Petal.Length, Petal.Width, Species
  dataset  =  iris[, c(5, 1, 2, 3, 4)]
}

############ User Parameters #########

if(exists("settings_tree_params_show") && settings_tree_params_show == FALSE)
  rm(list= ls(pattern = "settings_tree_params_"))
if(exists("settings_opt_params_show") && settings_opt_params_show == FALSE)
  rm(list= ls(pattern = "settings_opt_params_"))
if(exists("settings_additional_params_show") && settings_additional_params_show == FALSE)
  rm(list= ls(pattern = "settings_additional_params_"))


##PBI_PARAM: Should warnings messages be displayed?
#Type:logical, Default:TRUE, Range:NA, PossibleValues:NA, Remarks: NA
showWarnings  =  TRUE
if(exists("settings_additional_params_showWarnings"))
  showWarnings = settings_additional_params_showWarnings

##PBI_PARAM: the maximum depth of  the final tree [1, 30]
#Type:positive integer, Default:20, Range:[1, 30], PossibleValues:NA, Remarks: The tree of maxDepth is not promised
maxDepth   =   20
if(exists("settings_tree_params_maxDepth"))
  maxDepth = as.numeric(settings_tree_params_maxDepth)

###############Library Declarations###############
libraryRequireInstall = function(packageName, ...)
{
  if(!require(packageName, character.only = TRUE)) 
    warning(paste("*** The package: '", packageName, "' was not installed ***",sep=""))
}

libraryRequireInstall("rpart")
libraryRequireInstall("rpart.plot")
libraryRequireInstall("RColorBrewer")

###### Inner parameters and definitions ###################

##PBI_PARAM: Should info text be displayed in subtitle?
#Type:logical, Default:TRUE, Range:NA, PossibleValues:NA, Remarks: NA
showInfo  =  TRUE
if(exists("settings_additional_params_showInfo"))
  showInfo = settings_additional_params_showInfo

##PBI_PARAM: Complexity parameter. 
# Any split that does not decrease the overall lack of fit by a factor of complexity is not attempted.
#Type:numeric, Default:1e-05, Range:[0, 1], PossibleValues:NA, Remarks: If complexity and xval are 0 tree is maximal
complexity   =  1e-05 
if(exists("settings_opt_params_complexity"))
  complexity = as.numeric(settings_opt_params_complexity)

##PBI_PARAM: the minimum number of observations in any terminal (leaf) node 
#Type:positive integer, Default:2, Range:[1, 100], PossibleValues:NA, Remarks: NA
minBucket  =  2
if(exists("settings_tree_params_minBucket"))
  minBucket = as.numeric(settings_tree_params_minBucket)

##PBI_PARAM: indicator if xval parameter is to be found automatically 
#Type:bool, Default:TRUE, Range:NA, PossibleValues:NA, Remarks: NA
autoXval  =  FALSE

##PBI_PARAM: number of cross-validations, used only if autoXval  =  FALSE
#Type:integer, Default:10, Range:[0, 1000], PossibleValues:NA, Remarks: Can not be larger than number of records
xval  =  NA
if(exists("settings_opt_params_xval"))
  xval = as.numeric(settings_opt_params_xval)

if(is.na(xval))
  autoXval = TRUE
  
##PBI_PARAM: the random number generator (RNG) state for random number generation 
#Type: numeric, Default:42, Range:NA, PossibleValues:NA, Remarks: NA
randSeed  =  42

##PBI_PARAM: minimum required samples (rows in data table)
#Type: positive integer, Default:10, Range:[5, 100], PossibleValues:NA, Remarks: NA
minRows  =  10

##PBI_PARAM: maximum attempts to construct tree with optimal depth > 1 
#Type: positive integer, Default:10, Range:[1, 50], PossibleValues:NA, Remarks: NA
maxNumAttempts  =  10
if(exists("settings_opt_params_maxNumAttempts"))
  maxNumAttempts = as.numeric(settings_opt_params_maxNumAttempts)

###############Internal functions definitions#################

#automaticly select the number of cross-validations 
autoXvalFunc <- function(numRows)
{
  breaks  =  c(0, 5, 10, 100, 500, 1000, 10000, Inf)
  xvals  =  c(0, 2, 10, 100, 10, 5, 2)
  return( xvals[cut(numRows, breaks  =  breaks )] )
}

#select best CP by cptable (for optimal tree pruning) 
optimalCPbyXError <- function(cptable, delta  =  0.00001)
{
  opt  =  data.frame(ind  =  NaN, CP  =  NaN, xerror  =  NaN)
  xerror<-cptable$xerror
  relErr<-cptable$rel
  if(is.null(xerror))
    xerror<-relErr
  CP<-cptable$CP
  thresh<-min(xerror) + (max(xerror) - min(xerror))*delta
  opt$ind<-min(seq(1, length(xerror))[xerror <=  thresh])
  opt$CP<-CP[opt$ind]
  opt$xerror<-ifelse(is.null(cptable$xerror), NA, xerror[opt$ind])
  opt$relErr<-relErr[opt$ind]
  return(opt)
}

#format numbers to fixed number of digits after the floating point
d2form  =  function(x, p  =  2) {if(is.numeric(x)) format(round(x, p), nsmall  =  p)}

#automatically convert columns with few unique values to factors
convertCol2factors<-function(data, minCount  =  3)
{
  for (c in 1:ncol(data))
    if(is.logical(data[, c])){
      data[, c]  =  as.factor(data[, c])
    }else{
      uc<-unique(data[, c])
      if(length(uc) <=  minCount)
        data[, c]  =  as.factor(data[, c])
    }
  return(data)
}

#compute root node error 
rootNodeError<-function(labels)
{
  ul<-unique(labels)
  g<-NULL
  for (u in ul) g  =  c(g, sum(labels == u))
  return(1-max(g)/length(labels))
}

# this function is almost identical to fancyRpartPlot{rattle} 
# it is duplicated here because the call for library(rattle) may trigger GTK load, 
# which may be missing on user's machine 
replaceFancyRpartPlot<-function (model, main  =  "", sub  =  "", palettes, ...) 
{
  if(nchar(sub)>round(par()$din[1]/0.075) && nchar(sub)> 1)
    sub = paste(substring(sub,1,floor(par()$din[1]/0.075)),"...",sep="")

  num.classes <- length(attr(model, "ylevels"))
  
  default.palettes <- c("Greens", "Blues", "Oranges", "Purples", 
                        "Reds", "Greys")
  if (missing(palettes)) 
    palettes <- default.palettes
  
  missed <- setdiff(1:6, seq(length(palettes)))
  palettes <- c(palettes, default.palettes[missed])
  numpals <- 6
  palsize <- 5
  pals <- c(RColorBrewer::brewer.pal(9, palettes[1])[1:5], 
            RColorBrewer::brewer.pal(9, palettes[2])[1:5], RColorBrewer::brewer.pal(9, 
                                                                                    palettes[3])[1:5], RColorBrewer::brewer.pal(9, palettes[4])[1:5], 
            RColorBrewer::brewer.pal(9, palettes[5])[1:5], RColorBrewer::brewer.pal(9, 
                                                                                    palettes[6])[1:5])
  if (model$method  ==  "class") {
    yval2per <- -(1:num.classes) - 1
    per <- apply(model$frame$yval2[, yval2per], 1, function(x) x[1 + 
                                                                   x[1]])
  }
  else {
    per <- model$frame$yval/max(model$frame$yval)
  }
  per <- as.numeric(per)
  if (model$method  ==  "class") 
    col.index <- ((palsize * (model$frame$yval - 1) + trunc(pmin(1 + 
                                                                   (per * palsize), palsize)))%%(numpals * palsize))
  else col.index <- round(per * (palsize - 1)) + 1
  col.index <- abs(col.index)
  if (model$method  ==  "class") 
    extra <- 104
  else extra <- 101
  rpart.plot::prp(model, type  =  2, extra  =  extra, box.col  =  pals[col.index], 
                  nn  =  TRUE, varlen  =  0, faclen  =  0, shadow.col  =  "grey", 
                  fallen.leaves  =  TRUE, branch.lty  =  3, ...)
  title(main  =  main, sub  =  sub, cex.sub = 0.8)
}




###############Upfront input correctness validations (where possible)#################

pbiWarning<-""
pbiInfo<-""

dataset <- dataset[complete.cases(dataset[, 1]), ] #remove rows with corrupted labels
dataset  =  convertCol2factors(dataset)
nr <- nrow( dataset )
nc <- ncol( dataset )
nl <- length( unique(dataset[, 1]))

goodDim <- (nr  >=minRows && nc  >= 2 && nl  >= 2)


##############Main Visualization script###########
set.seed(randSeed)
opt  =  NULL
dtree  =  NULL

if(autoXval)
  xval<-autoXvalFunc(nr)

dNames <- names(dataset)
X <- as.vector(dNames[-1])

form <- as.formula(paste('`', dNames[1], '`', "~ .", sep  =  ""))

# Run the model
if(goodDim)
{
  for(a in 1:maxNumAttempts)
  {
    dtree <- rpart(form, dataset, control  =  rpart.control(minbucket  =  minBucket, cp  =  complexity, maxdepth  =  maxDepth, xval  =  xval)) #large tree
    rooNodeErr <- rootNodeError(dataset[, 1])
    opt <- optimalCPbyXError(as.data.frame(dtree$cptable))
    
    dtree<-prune(dtree, cp  =  opt$CP)
    if(opt$ind > 1)
      break;
  }
}

#info for classifier
if( showInfo && !is.null(dtree) && dtree$method  ==  'class')
  pbiInfo <- paste("Rel error  =  ", d2form(opt$relErr * rooNodeErr), 
                 "; CVal error  =  ", d2form(opt$xerror * rooNodeErr), 
                 "; Root error  =  ", d2form(rooNodeErr), 
                 ";cp  =  ", d2form(opt$CP, 3), sep  =  "")

if(goodDim && opt$ind>1)
{
  #fancyRpartPlot(dtree, sub  =  pbiInfo)
  replaceFancyRpartPlot(dtree, sub  =  pbiInfo)
  
  
}else{
  if( showWarnings )
    pbiWarning <- ifelse(goodDim, paste("The tree depth is zero.\n Root error  =  ", d2form(rooNodeErr), sep  =  ""), 
                                     "\n Wrong data dimensionality" )
  
  plot.new()
  title( main  =  NULL, sub  =  pbiWarning, outer  =  FALSE, col.sub  =  "gray50" )
}
remove("dataset")
