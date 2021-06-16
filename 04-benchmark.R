library( ordinalRidge )
library( qs )
library( microbenchmark )

## Load real data and compute a linear kernel
traindata <- qread("traindata.qs")
y <- purrr::pluck(traindata, "Label")
X <- as.matrix(dplyr::select(traindata, -Label))

nvar <- ncol(X)
ncls <- length(levels(y))

## Benchmark
microbenchmark(
    m1 = ordinalRidge( X, y, lambda=0.1, kernel=FALSE, maxIter=100, verbose=FALSE ),
    m2 = ordinalNet::ordinalNet( X, y, alpha=0, lambdaVals=0.1, threshIn=1e-5, threshOut=1e-5 ),
    m3 = OrdinalLogisticBiplot::pordlogist( as.integer(y), X ),
    m4 = glmnetcr::glmnetcr( X, y, lambda=0.1, alpha=0, pmax=1000 ),
    m5 = ordinalForest::ordfor( "Label", traindata, nsets=10, ntreeperdiv=sqrt(nvar), ntreefinal=nvar ),
    times = 5
)
                    
## Define an 80/20% train/test split
set.seed(42)
iTe <- sample( 1:nrow(X), as.integer(nrow(X)/5) )
iTr <- setdiff( 1:nrow(X), iTe )
Xtr <- X[iTr,]; ytr <- y[iTr]
Xte <- X[iTe,]; yte <- y[iTe]

## Re-train models on the 80% partition
m1 <- ordinalRidge( Xtr, ytr, lambda=0.1, kernel=FALSE, maxIter=100, verbose=FALSE )
m2 <- ordinalNet::ordinalNet( Xtr, ytr, alpha=0, lambdaVals=0.1, threshIn=1e-5, threshOut=1e-5 )
m3 <- OrdinalLogisticBiplot::pordlogist( as.integer(ytr), Xtr )
m4 <- glmnetcr::glmnetcr( Xtr, ytr, lambda=0.1, alpha=0, pmax=nvar*2 )
m5 <- ordinalForest::ordfor( "Label", traindata[iTr,], nsets=10, ntreeperdiv=sqrt(nvar), ntreefinal=nvar )

## Train AUC on the 80% partition
evaluateRanking( predict(m1, Xtr)$score, ytr )
evaluateRanking( predict(m2, Xtr)[,ncls], ytr )
evaluateRanking( Xtr %*% m3$coefficients, ytr )
evaluateRanking( Xtr %*% m4$beta[1:nvar], ytr )
evaluateRanking( predict(m5, Xtr)$classprobs[,ncls], ytr )

## Test AUC on the 20% partition
evaluateRanking( predict(m1, Xte)$score, yte )
evaluateRanking( predict(m2, Xte)[,ncls], yte )
evaluateRanking( Xte %*% m3$coefficients, yte )
evaluateRanking( Xte %*% m4$beta[1:nvar], yte )
evaluateRanking( predict(m5, Xte)$classprobs[,ncls], yte )
