library(tidyverse)
library(qs)
library(ordinalRidge)

Z <- qs::qread("traindata.qs")

y <- purrr::pluck(Z, "Label")
X <- as.matrix( dplyr::select(Z, -Label) )
K <- X %*% t(X) / nrow(X)

mdl <- ordinalRidge( K, y, verbose=TRUE )
mdl$b

## Compute the final ranking of samples by the model
ypred <- K %*% mdl$v

## Report correlation against true labels
cat( "\n" )
cat( "Correlation against ground truth =", evaluate_ranking( y, ypred ), "\n" )    
