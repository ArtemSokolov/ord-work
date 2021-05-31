library(tidyverse)
library(qs)
library(ordinalNet)

traindata <- qread("traindata.qs")

Zte <- traindata[1:2,]
Ztr <- traindata[-(1:2),]

## Training data
ytr <- pluck(Ztr, "Label")
Xtr <- select(Ztr, -Label)
Ctr <- Xtr %>% t %>% cov

## Test data
Xte <- select( Zte, -Label )
Cte <- t(Xte) %>% cov( t(Xtr) )

## Train a model
mdl <- ordinalNet(Ctr, ytr, alpha=0, threshIn=1e-5, threshOut=1e-5)

## Apply the model back to the training data
ypred <- predict(mdl, Cte)[,"P[Y=7]"]
ytrue <- Zte$Label

## Compare against true labels
if( ((ypred[2] > ypred[1]) && (ytrue[2] > ytrue[1])) ||
    ((ypred[2] < ypred[1]) && (ytrue[2] < ytrue[1])) )
    print( "Correct" ) else
    print( "Incorrect" )

