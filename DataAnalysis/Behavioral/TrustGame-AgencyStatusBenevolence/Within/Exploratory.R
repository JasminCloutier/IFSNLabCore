########################################### Data Wrangling ###############################################

rm(list = ls()) # clear the workspace

### Load packages
library(lme4)
library(lmerTest)
library(tidyverse)
library(interactions)
library(buildmer)
options(scipen = 5)

########################################### Function to only get significant rows

get_sig = function(model) {
  summary = summary(model)
  subset(summary$coefficients, summary$coefficients[,"Pr(>|t|)"] < 0.05 & rownames(summary$coefficients) != "(Intercept)")
}

########################################### Load data ###############################################

df1 = "../../../data/preprocessed/Within_Subjects/data_cleaned.csv"
df2 = "../../../data/preprocessed/Within_Subjects/data_dummy_cleaned.csv"
df3 = "../../../data/preprocessed/Within_Subjects/data_firstroundexcluded_cleaned.csv"
data = read.csv(df1, stringsAsFactors = FALSE, na.strings = c("", "NA"))
data_dummy = read.csv(df2, stringsAsFactors = FALSE, na.strings = c("", "NA"))
data_firstroundexcluded = read.csv(df3, stringsAsFactors = FALSE, na.strings = c("", "NA"))

########################################### Final Model 1 ###########################################

#mod1 = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + Game_Number +
#              (1 + agency_contrast + generosity_contrast1 + status_contrast | Subject), data=data_firstroundexcluded)

#buildmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + Game_Number +
#           (1 + agency_contrast + generosity_contrast1 + status_contrast| Subject), data=data_firstroundexcluded)

#Formula: MoneyTrusted ~ 1 + Feedback + generosity_contrast1 + (1 + generosity_contrast1 | Subject)
#Data: data_firstroundexcluded

mod1 = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + Game_Number +
              (1 + generosity_contrast1| Subject), data=data_firstroundexcluded)
get_sig(mod1)

###########################################Final Model 2###########################################
mod2 = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Round +
              (1|Subject), 
            data = data_dummy)
get_sig(mod2)






