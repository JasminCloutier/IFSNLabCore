###########################################Data Wrangling###############################################

rm(list = ls()) # clear the workspace

### Load packages
library(lme4)
library(lmerTest)
library(tidyverse)
library(stringr)
library(stringi)
library(interactions)
library(buildmer)
library(fastDummies)
###########################################Function to only get significant rows

get_sig = function(model) {
  summary = summary(model)
  subset(summary$coefficients, summary$coefficients[,"Pr(>|t|)"] < 0.05 & rownames(summary$coefficients) != "(Intercept)")
}

###########################################Load data###############################################

df1 = "../../../data/preprocessed/Between_Subjects/data_cleaned.csv"
df2 = "../../../data/preprocessed/Between_Subjects/data_dummy_cleaned.csv"
df3 = "../../../data/preprocessed/Between_Subjects/data_firstroundexcluded_cleaned.csv"

data = read.csv(df1, stringsAsFactors = FALSE)
data_dummy = read.csv(df2, stringsAsFactors = FALSE)
data_firstroundexcluded = read.csv(df3, stringsAsFactors = FALSE)

###########################################Base Model###############################################

mod0 = lmer(MoneyTrusted ~ status_contrast*generosity_contrast1*agency_contrast*Feedback +
              (1 + status_contrast*generosity_contrast1*Feedback|Subject) +
              (1 + status_contrast*generosity_contrast1|Stimuli), 
            data = data)

summary(mod0)

interact_plot(mod0, pred = agency_contrast, modx = generosity_contrast1)
###########################################Find Largest Model that Converges###############################################
#buildmer(MoneyTrusted ~ status_contrast*generosity_contrast1*agency_contrast*Feedback +
#           (1 + status_contrast*generosity_contrast1*Feedback|Subject) +
#           (1 + status_contrast*generosity_contrast1|Stimuli), 
#         data = data)

mod_test = lmer(MoneyTrusted ~ 1 + Feedback + generosity_contrast1 + status_contrast + (1 | Subject), data=data)

summary(mod_test)

###########################################Final Suggested Model###############################################
###
### MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + (1 + Feedback|Subject)
###
###########################################Look into Feedback###############################################

mod_dummy = lmer(MoneyTrusted ~ agency_contrast*Feedback*generosity_contrast1*status_contrast + 
                   (1 + Feedback | Subject), 
                 data = data_dummy)

summary(mod_dummy)
get_sig(mod_dummy)

#agency:generosityconstrast1**
interact_plot(mod_dummy, pred = generosity_contrast1, modx = agency_contrast)

#Feedback:status***
interact_plot(mod_dummy, pred = Feedback, modx = status_contrast)

#generositycontrast1:status*
interact_plot(mod_dummy, pred = status_contrast, modx = generosity_contrast1)

###########################################Role of Feedback == 0 in non-first rounds###############################################
temp_df = data_dummy %>% filter(Feedback == 0 & Round != 1)

agency_generosity_mod = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast + 
                               (1 | Subject), 
                             data = temp_df)
get_sig(agency_generosity_mod)
#agency:generosity
#agency:status

interact_plot(agency_generosity_mod, pred = agency_contrast, modx = status_contrast)
###########################################Role of Feedback in non-first rounds###############################################

agency_generosity_feedback_mod = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + 
                                        (1 + Feedback| Subject), 
                                      data = data_firstroundexcluded)

#model did not converge
###########################################Converge Model###############################################
#buildmer(MoneyTrusted ~ status_contrast*generosity_contrast1*agency_contrast*Feedback +
#                      (1 + status_contrast*generosity_contrast1*Feedback|Subject) +
#                      (1 + status_contrast*generosity_contrast1|Stimuli), 
#                data = data_firstroundexcluded)

### Suggested model
### MoneyTrusted ~ 1 + Feedback + generosity_contrast1 + (1 + generosity_contrast1 | Subject), Data= data_firstroundexcluded

### Revised model
agency_generosity_feedback_mod = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback + 
                                        (1 + generosity_contrast1 | Subject), 
                                      data=data_firstroundexcluded)

#agency:generosity
#generosity:feedback
#status:feedback

### Separate Greedy from Neutral+Generous
agency_generosity5_feedback_mod = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast5*status_contrast*Feedback + 
                                         (1 + generosity_contrast5 | Subject), 
                                       data=data_firstroundexcluded)

#no interactions

### Separate Generous from Neutral+Greedy
agency_generosity2_feedback_mod = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast2*status_contrast*Feedback + 
                                         (1 + generosity_contrast2 | Subject), 
                                       data=data_firstroundexcluded)

#agency:generosity
#generosity:feedback
#status:Feedback
#agency:generosity:feedback

###########################################Revised Model 1###############################################

model_1 = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast*Feedback +
                 (1 + generosity_contrast1| Subject),
               data = data_firstroundexcluded)

#generosity:feedback
#status:feedback
#agency:generosity

###########################################Revised Model 2###############################################

model_2 = lmer(MoneyTrusted ~ agency_contrast*generosity_contrast1*status_contrast +
                 (1 + generosity_contrast1| Subject),
               data = data)

#generosity:status
#agency:status
