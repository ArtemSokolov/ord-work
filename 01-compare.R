library( tidyverse )
library( ordinalRidge )

## Generate training and test data
set.seed(42)
Tr <- toyData( 100, 3, 3, stdev=2 )
Te <- toyData( 20, 3, 3, stdev=2 )

## Compose kernels
Ktr <- Tr$X %*% t(Tr$X)
Kte <- Te$X %*% t(Tr$X)
Ktr0 <- cov(t(Tr$X))
Kte0 <- cov(t(Te$X), t(Tr$X))

## Train models
or0 <- ordinalRidge(Ktr0, Tr$y)
or1 <- ordinalRidge(Ktr, Tr$y)

onet0 <- ordinalNet::ordinalNet(Ktr0, Tr$y, alpha=0, threshIn=1e-5, threshOut=1e-5)
onet1 <- ordinalNet::ordinalNet(Ktr, Tr$y, alpha=0, threshIn=1e-5, threshOut=1e-5)

pl1 <- OrdinalLogisticBiplot::pordlogist( as.integer(Tr$y), Tr$X )

## Compute training error
evaluate_ranking( Tr$y, predict( or0, Ktr0 )$score )
evaluate_ranking( Tr$y, predict( onet0, Ktr0 )[,4] )

evaluate_ranking( Tr$y, predict( or1, Ktr )$score )
evaluate_ranking( Tr$y, predict( onet1, Ktr )[,4] )

evaluate_ranking( Tr$y, Tr$X %*% pl1$coefficients )

## Compare fits
cor( Ktr %*% or1$v, Tr$X %*% pl1$coefficients )
cor( Ktr %*% or1$v, predict( onet1, Ktr )[,4] )

## Evaluate on test data
evaluate_ranking( Te$y, predict( or0, Kte0 )$score )
evaluate_ranking( Te$y, predict( onet0, Kte0 )[,4] )

evaluate_ranking( Te$y, predict( or1, Kte )$score )
evaluate_ranking( Te$y, predict( onet1, Kte )[,4] )

evaluate_ranking( Te$y, Te$X %*% pl1$coefficients )
