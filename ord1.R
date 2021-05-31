library(tidyverse)
library(qs)
library(here)
library(ordinalRidge)

synapser::synLogin()
syn <- synExtra::synDownloader(here("data"))
    
ad_data <- syn("syn25607441") %>% qread()
    
all_genes <- setdiff(
    colnames(ad_data),
    c("Barcode", "ID", "PMI", "AOD", "CDR", "Braak", "Label")
)
    
set.seed(42)
ad_data_subset <- select(
    ad_data,
    all_of(sample(all_genes, size = 200, replace = FALSE))
)
    
ad_data_subset_cov <- ad_data_subset %>%
    as.matrix() %>% t() %>% cov()

K <- ad_data_subset_cov
y <- ad_data$Label
    
mdl <- ordinalRidge(K, y, verbose=TRUE)
pred <- predict(mdl, K)
evaluate_ranking( y, pred$score )
