library(ordinalRidge)
set.seed(42)

## Generate training and test data
Tr <- toyData( 100, 3, 2, stdev=0.5 )
Te <- toyData( 5, 3, 2, stdev=0.5 )

## Without normalizing by a constant
K <- Tr$X %*% t(Tr$X)
Kte <- Te$X %*% t(Tr$X)
mdl  <- ordinalRidge(K, Tr$y)

## With normalizing by a constant
n <- nrow(Tr$X)
KN <- Tr$X %*% t(Tr$X) / n                   # <-- Adjust training kernel
KNte <- Te$X %*% t(Tr$X) / n                 # <-- Adjust test kernel
mdlN <- ordinalRidge(KN, Tr$y, lambda=0.1/n) # <-- Adjust lambda

## Compute predictions
P <- predict(mdl, Kte)
PN <- predict(mdlN, KNte)

## Weights on the original features and bias terms
t(Tr$X) %*% mdl$v
#            [,1]
# Feat1 1.0166423
# Feat2 0.9938469
# Feat3 1.0025881

t(Tr$X) %*% mdlN$v / n                       # <-- Adjust the weights
#            [,1]
# Feat1 1.0166423
# Feat2 0.9938469
# Feat3 1.0025881

## No need to adjust the bias terms!
mdl$b
# [1] -1.393522 -4.517129

mdlN$b
# [1] -1.393522 -4.517129

## No need to adjust predictions!
range( P$score - PN$score )
# [1] -2.819966e-14  1.332268e-14

identical( P$pred, PN$pred )
# [1] TRUE

range( P$prob - PN$prob )
# [1] -5.884182e-15  8.659740e-15
