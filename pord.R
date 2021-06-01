library( tidyverse )
library( ordinalRidge )

predEval <- function( mdl, K, lbl ) {
    predict(mdl, K) %>%
        pluck("score") %>%
        evaluate_ranking( lbl, . )
}

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

pl1 <- OrdinalLogisticBiplot::pordlogist( Tr$y, Tr$X )

## Evaluate predictions
predEval( or0, Ktr, Tr$y )
predEval( or0, Kte, Te$y )
predEval( or1, Ktr, Tr$y )
predEval( or1, Kte, Te$y )

evaluate_ranking( Tr$y, Tr$X %*% pl1$coefficients )

## Compare predictions
cor( Ktr %*% or1$v, Tr$X %*% pl1$coefficients )
