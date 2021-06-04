library(ordinalRidge)
library(qs)

## Generate data and compute a linear kernel
set.seed(42)
Tr <- toyData( 100, 3, 3, stdev=2 )
K <- Tr$X %*% t(Tr$X)

## Train a model using the original data and the kernel
mdl1 <- ordinalRidge( Tr$X, Tr$y )
mdl2 <- ordinalRidge( K, Tr$y )

## Ensure that both models produce the same predictions
pred1 <- predict( mdl1, Tr$X )
pred2 <- predict( mdl2, K )
range(pred1$score - pred2$score)

## Repeat on real data
traindata <- qread("traindata.qs")
y <- purrr::pluck(traindata, "Label")
X <- as.matrix(dplyr::select(traindata, -Label))

## Compute normalized and non-normalized kernels
K0 <- X %*% t(X)
KN <- X %*% t(X) / ncol(X)

## Train models in the original space and using both kernels
M <- ordinalRidge( X, y, kernel=FALSE )
M0 <- ordinalRidge( K0, y, kernel=TRUE )
MN <- ordinalRidge( KN, y, kernel=TRUE, lambda=0.1 / ncol(X) )

## M0 is a numerically unstable solution because the kernel matrix is
##   not scaled. Ensure the other two models produce identical predictions
range( predict(M, X)$score - predict(MN, KN)$score )
