########################################### Data Wrangling ###############################################

rm(list = ls()) # clear the workspace

### Load packages
library(lme4)
library(lmerTest)
library(tidyverse)
library(stringr)
library(stringi)
library(interactions)
source("~/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/analysis/NewFunctions/get_sig.R")
source("~/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/analysis/NewFunctions/get_simslopes.R")
# source(paste0(getwd(), "/get_sig.R"))
# source(paste0(getwd(), "/get_simslopes.R"))

########################################### Load data ###############################################

df1 = "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/data/preprocessed/Between_Subjects/data.csv"
df2 = "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/data/preprocessed/Between_Subjects/data_firstroundexcluded.csv"

data = read.csv(df1, stringsAsFactors = FALSE)
data_firstroundexcluded = read.csv(df2, stringsAsFactors = FALSE)

rm(df1, df2)

########################################### Final Model 1 ###########################################

# buildmer(MoneyTrusted ~ Competence*Benevolence*Agency*Round +
#            (1 + Competence*Benevolence|Subject) +
#            (1 + Competence*Benevolence|Stimuli), 
#          data = data)

# Suggested Formula: MoneyTrusted ~ 1 + Benevolence + Round + Competence + Agency + (1 + Benevolence + Competence | Subject), data= data

mod1 = lmer(MoneyTrusted ~ Agency*(Benevolence_GenerousvsMalevolent+Benevolence_NeutralvsRest)*Competence*Round + (1|Subject), data = data)
round(get_sig(summary(mod1)), 3)

#                                               Estimate  SE      df      t value  p value
# Benevolence_GenerousvsMalevolent               0.837    0.114   17796   7.358    0.000
# Benevolence_NeutralvsRest                      0.274    0.100   17796   2.752    0.006
# Competence                                     0.999    0.093   17796  10.753    0.000
# Round                                         -0.218    0.007   17796 -29.128    0.000
# Benevolence_GenerousvsMalevolent:Competence    0.731    0.228   17796   3.211    0.001
# Benevolence_GenerousvsMalevolent:Round         0.354    0.018   17796  19.319    0.000
# Benevolence_NeutralvsRest:Round               -0.078    0.016   17796  -4.887    0.000
# Competence:Round                              -0.097    0.015   17796  -6.487    0.000

mod1_statstable = round(summary(mod1)$coefficients, 3)
mod1_confint = confint(mod1)
mod1_confint = round(subset(mod1_confint, rownames(mod1_confint) %in% rownames(mod1_statstable)), 3)
mod1_statstable = merge(mod1_statstable, mod1_confint, by="row.names")
mod1_statstable = mod1_statstable %>%
  mutate("CI" = paste0("[", round(mod1_statstable$`2.5 %`, 3), ", ", round(mod1_statstable$`97.5 %`, 3), "]")) %>%
  select(-c(`2.5 %`, `97.5 %`))
names(mod1_statstable) = c("Predictor", "Estimate", "SE", "df", "t-value", "p-value", "CI")
rm(mod1_confint)

mod1_statstable = mod1_statstable %>%
  select(Predictor, Estimate, SE, df, CI, `t-value`, `p-value`) %>%
  mutate(Predictor = gsub(":", " x ", Predictor)) %>%
  mutate(Predictor = gsub("Benevolence_GenerousvsMalevolent", "Benevolence - Generous vs Malevolent", Predictor),
         Predictor = gsub("Benevolence_NeutralvsRest", "Benevolence - Neutral vs rest", Predictor),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                            ifelse(as.numeric(`p-value`) < 0.010, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) <= 0.050, paste0(`p-value`,"*"), `p-value`))))

write.csv(mod1_statstable, "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod1_statstable.csv", row.names = FALSE)

########################################### Simple Slopes Model 1 ###########################################

mod1_simslopes_benevolenceround = get_simslopes(model = mod1, confints = "Yes",
                                               variables = c("Benevolence_GenerousvsMalevolent", "Round"), 
                                               levels = list(c(-0.5, 0, 0.5), c(1, 5, 10)), 
                                               labels = list(c("Malevolent", "Neutral", "Generous"), c("Round1", "Round5", "Round10")), 
                                               categorical = c(TRUE, FALSE))$significant_slopes

mod1_simslopes_competenceround = get_simslopes(model = mod1, confints = "Yes",
                                           variables = c("Competence", "Round"), 
                                           levels = list(c(-0.5, 0.5), c(1, 5, 10)),
                                           labels = list(c("LowCompetence", "HighCompetence"), c("Round1", "Round5", "Round10")),
                                           categorical = c(TRUE, FALSE))$significant_slopes

mod1_simslopes_competencebenevolence = get_simslopes(model = mod1, confints = "Yes",
                                                variables = c("Benevolence_GenerousvsMalevolent", "Competence"), 
                                                levels = list(c(-0.5, 0, 0.5), c(-0.5, 0.5)),
                                                labels = list(c("Malevolent", "Neutral", "Generous"), c("LowCompetence", "HighCompetence")),
                                                categorical = c(TRUE, TRUE))$significant_slopes

mod1_simslopes_benevolenceround = mod1_simslopes_benevolenceround %>%
  mutate(Reference = gsub("^.*_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(Reference %in% c("Round1", "Round5", "Round10"), gsub("([A-Za-z]+)([0-9])", "\\1 \\2", Reference), Reference))

mod1_simslopes_competenceround = mod1_simslopes_competenceround %>%
  mutate(Reference = gsub("^.*_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value`= ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                                        ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                               ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(Reference %in% c("Round1", "Round5", "Round10"), gsub("([A-Za-z]+)([0-9])", "\\1 \\2", Reference), Reference),
         Reference = ifelse(Reference %in% c("LowCompetence", "HighCompetence"), gsub("([[:lower:]])([[:upper:]][[:lower:]])", "\\1 \\2", Reference), Reference))

mod1_simslopes_competencebenevolence = mod1_simslopes_competencebenevolence %>%
  mutate(Reference = gsub("^.*_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                                        ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                               ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(Reference %in% c("LowCompetence", "HighCompetence"), gsub("([[:lower:]])([[:upper:]][[:lower:]])", "\\1 \\2", Reference), Reference))

write.csv(mod1_simslopes_benevolenceround, "~/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod1_simslopes_benevolenceround.csv", row.names = FALSE)
write.csv(mod1_simslopes_competenceround, "~/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod1_simslopes_competenceround.csv", row.names = FALSE)
write.csv(mod1_simslopes_competencebenevolence, "~/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod1_simslopes_competencebenevolence.csv", row.names = FALSE)

########################################### Final Model 2 ###########################################

# buildmer(MoneyTrusted ~ status_contrast*generosity_contrast1*agency_contrast*Integrity + Game_Number +
#            (1 + status_contrast*generosity_contrast1*Integrity|Subject) +
#            (1 + status_contrast*generosity_contrast1*Integrity|Stimuli), 
#          data = data_firstroundexcluded)
# Suggested Formula: MoneyTrusted ~ 1 + Integrity + generosity_contrast1 + (1 + generosity_contrast1 | Subject), data= data_firstroundexcluded

mod2 = lmer(MoneyTrusted ~ Agency*(Benevolence_GenerousvsMalevolent+Benevolence_NeutralvsRest)*Competence*Integrity + Game + (1|Subject), data=data_firstroundexcluded)
round(get_sig(summary(mod2)), 3)

#                                             Estimate  SE      df        t value   p value
# Benevolence_GenerousvsMalevolent              0.876   0.081   16186.91  10.795    0.000
# Competence                                    0.216   0.065   16114.68   3.337    0.001
# Integrity                                     0.448   0.006   16194.51  72.617    0.000
# Game                                         -0.075   0.012   15968.13  -6.491    0.000
# Agency:Benevolence_GenerousvsMalevolent       0.388   0.162   16186.55   2.389    0.017
# Benevolence_GenerousvsMalevolent:Integrity   -0.039   0.015   16154.23  -2.633    0.008

mod2_statstable = round(summary(mod2)$coefficients, 3)
mod2_confint = confint(mod2)
mod2_confint = round(subset(mod2_confint, rownames(mod2_confint) %in% rownames(mod2_statstable)), 3)
mod2_statstable = merge(mod2_statstable, mod2_confint, by="row.names")
mod2_statstable = mod2_statstable %>%
  mutate("CI" = paste0("[", round(mod2_statstable$`2.5 %`, 3), ", ", round(mod2_statstable$`97.5 %`, 3), "]")) %>%
  select(-c(`2.5 %`, `97.5 %`))
names(mod2_statstable) = c("Predictor", "Estimate", "SE", "df", "t-value", "p-value", "CI")
rm(mod2_confint)

mod2_statstable = mod2_statstable %>%
  select(Predictor, Estimate, SE, df, CI, `t-value`, `p-value`) %>%
  mutate(Predictor = gsub(":", " x ", Predictor)) %>%
  mutate(Predictor = gsub("Benevolence_GenerousvsMalevolent", "Benevolence - Generous vs Malevolent", Predictor),
         Predictor = gsub("Benevolence_NeutralvsRest", "Benevolence - Neutral vs rest", Predictor),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`))))

write.csv(mod2_statstable, "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod2_statstable.csv", row.names = FALSE)

########################################### Simple Slopes Model 2 ###########################################

mod2_simslopes_benevolenceintegrity = get_simslopes(model = mod2, confints = "Yes",
                                                  variables = c("Benevolence_GenerousvsMalevolent", "Integrity"), 
                                                  levels = list(c(-0.5, 0, 0.5), c(0, 11, 22)),
                                                  labels = list(c("Malevolent", "Neutral", "Generous"), c("LowIntegrity", "NeutralIntegrity", "HighIntegrity")), 
                                                  categorical = c(TRUE, FALSE))$significant_slopes

mod2_simslopes_agencybenevolence = get_simslopes(model = mod2, confints = "Yes", 
                                                variables = c("Benevolence_GenerousvsMalevolent", "Agency"),
                                                levels = list(c(-0.5, 0, 0.5), c(-0.5, 0.5)),
                                                labels = list(c("Malevolent", "Neutral", "Generous"), c("AI", "Human")), 
                                                categorical = c(TRUE, TRUE))$significant_slopes

mod2_simslopes_benevolenceintegrity = mod2_simslopes_benevolenceintegrity %>%
  mutate(Reference = gsub("^.*_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(Reference %in% c("LowIntegrity", "NeutralIntegrity", "HighIntegrity"), gsub("([[:lower:]])([[:upper:]][[:lower:]])", "\\1 \\2", Reference), Reference))

mod2_simslopes_agencybenevolence = mod2_simslopes_agencybenevolence %>%
  mutate(Reference = gsub("^.*_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***", 
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(Reference == "AI", "A.I.", Reference))

write.csv(mod2_simslopes_benevolenceintegrity, "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod2_simslopes_benevolenceintegrity.csv", row.names = FALSE)
write.csv(mod2_simslopes_agencybenevolence, "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s1_mod2_simslopes_agencybenevolence.csv", row.names = FALSE)





