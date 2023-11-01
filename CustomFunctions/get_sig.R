###################### Function to only get significant rows #######################
####################################### Code #######################################
library(tidyverse)
library(lme4)
library(lmerTest)

get_sig = function(summary) {
  subset(summary$coefficients, summary$coefficients[,"Pr(>|t|)"] < 0.05 & rownames(summary$coefficients) != "(Intercept)")
}
