########################################### Data Wrangling ###############################################

rm(list = ls()) # clear the workspace

### Load packages
library(lme4)
library(lmerTest)
library(tidyverse)
library(interactions)
library(buildmer)
source("/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/analysis/NewFunctions/get_sig.R")
source("/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/analysis/NewFunctions/get_simslopes.R")
# source(paste0(getwd(), "/get_sig.R"))
# source(paste0(getwd(), "/get_simslopes.R"))

########################################### Load data ###############################################

df1 = "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/data/preprocessed/Within_Subjects/data.csv"
df2 = "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/data/preprocessed/Within_Subjects/data_firstroundexcluded.csv"
data = read.csv(df1, stringsAsFactors = FALSE, na.strings = c("", "NA"))
data_firstroundexcluded = read.csv(df2, stringsAsFactors = FALSE, na.strings = c("", "NA"))
rm(df1, df2)

########################################### Final Model 1 ###########################################

# buildmer(MoneyTrusted ~ Agency*Benevolence_GenerousvsMalevolent*Competence*Round + 
#            (1 + Agency + Benevolence_GenerousvsMalevolent + Competence + Competence:Benevolence_GenerousvsMalevolent | Subject), data = data)
# Suggested Formula: MoneyTrusted ~ 1 + Benevolence_GenerousvsMalevolent + Round + Benevolence_GenerousvsMalevolent:Round +  
#   Agency + Round:Agency + Benevolence_GenerousvsMalevolent:Agency +  
#   Benevolence_GenerousvsMalevolent:Round:Agency + Competence +  
#   Round:Competence + Benevolence_GenerousvsMalevolent:Competence +  
#   Benevolence_GenerousvsMalevolent:Round:Competence + Agency:Competence +  
#   Benevolence_GenerousvsMalevolent:Agency:Competence + Round:Agency:Competence +  
#   Benevolence_GenerousvsMalevolent:Round:Agency:Competence +  
#   (1 + Benevolence_GenerousvsMalevolent + Agency + Competence +  
#      Benevolence_GenerousvsMalevolent:Competence | Subject)

mod1 = lmer(MoneyTrusted ~ Agency*(Benevolence_GenerousvsMalevolent+Benevolence_NeutralvsRest)*Competence*Round + (1|Subject), data = data)
round(get_sig(summary(mod1)), 3)

#                                                             B       SE      df    t-value   p-value
# Benevolence_GenerousvsMalevolent                            1.510   0.164   8902   9.181    0.000
# Benevolence_NeutralvsRest                                   0.484   0.144   8902   3.361    0.001
# Competence                                                  0.341   0.134   8902   2.542    0.011
# Round                                                      -0.281   0.011   8902 -25.990    0.000
# Benevolence_GenerousvsMalevolent:Round                      0.312   0.027   8902  11.754    0.000
# Benevolence_NeutralvsRest:Round                            -0.142   0.023   8902  -6.106    0.000
# Agency:Benevolence_GenerousvsMalevolent:Competence:Round   -0.234   0.106   8902  -2.211    0.027

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
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`))))

write.csv(mod1_statstable, "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s2_mod1_statstable.csv", row.names = FALSE)

########################################### Simple Slopes Model 1 ###########################################
mod1_simslopes_agencycompetencebenevolenceround = get_simslopes(model = mod1, confints = "Yes",
                                                      variables = c("Agency", "Competence", "Benevolence_GenerousvsMalevolent", "Round"), 
                                                      levels = list(c(-0.5, 0.5), c(-0.5, 0.5), c(-0.5, 0, 0.5), c(1, 5, 10)), 
                                                      labels = list(c("AI", "Human"), c("LowCompetence", "HighCompetence"), c("Malevolent", "Neutral", "Generous"), c("Round1", "Round5", "Round10")), 
                                                      categorical = c(TRUE, TRUE, TRUE, FALSE))$significant_slopes

mod1_simslopes_agencycompetencebenevolenceround = mod1_simslopes_agencycompetencebenevolenceround %>%
  mutate(Reference = gsub("^.*?_([A-Za-z0-9]+)[[:space:]]+.*?_([A-Za-z0-9]+)[[:space:]]+.*?_([A-Za-z0-9]+)$", "\\1 \\2 \\3", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***",
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(grepl("[A-Za-z]+[0-9]+", Reference), gsub("(.*?)([A-Za-z]+)([0-9]+)(.*?)", "\\1\\2 \\3\\4", Reference), Reference),
         Reference = ifelse(grepl("[[:lower:]][[:upper:]][[:lower:]]", Reference), gsub("(.*?)([[:lower:]])([[:upper:]][[:lower:]])(.*?)", "\\1\\2 \\3\\4", Reference), Reference),
         Reference = gsub("AI", "A.I.", Reference))

write.csv(mod1_simslopes_agencycompetencebenevolenceround, 
          "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s2_mod1_simslopes_agencycompetencebenevolenceround.csv", 
          row.names = FALSE)

########################################### Final Model 2 ###########################################

# buildmer(MoneyTrusted ~ Agency*Benevolence_GenerousvsMalevolent*Competence*Integrity + Game_Number +
#            (1 + Agency + Benevolence_GenerousvsMalevolent + Competence| Subject), data=data_firstroundexcluded)

# Suggested Formula: MoneyTrusted ~ 1 + Integrity + Benevolence_GenerousvsMalevolent + Game_Number + Agency + Competence + 
# Integrity:Benevolence_GenerousvsMalevolent + Integrity:Agency + Integrity:Competence + Benevolence_GenerousvsMalevolent:Competence +  
# Integrity:Benevolence_GenerousvsMalevolent:Competence + Benevolence_GenerousvsMalevolent:Agency +  
# Integrity:Benevolence_GenerousvsMalevolent:Agency + Agency:Competence +  
# Integrity:Agency:Competence + Benevolence_GenerousvsMalevolent:Agency:Competence +  
# Integrity:Benevolence_GenerousvsMalevolent:Agency:Competence + 
# (1 + Benevolence_GenerousvsMalevolent | Subject)
# Data: data_firstroundexcluded

mod2 = lmer(MoneyTrusted ~ Agency*(Benevolence_GenerousvsMalevolent+Benevolence_NeutralvsRest)*Competence*Integrity + Game + (1|Subject), data=data_firstroundexcluded)
round(get_sig(summary(mod2)), 3)

#                                                   B       SE       df       t-value   p-value
# Benevolence_GenerousvsMalevolent                  1.224   0.120   8042.840  10.188    0.000
# Benevolence_NeutralvsRest                        -0.249   0.095   8011.789  -2.629    0.009
# Competence                                        0.209   0.092   8023.353   2.264    0.024
# Integrity                                         0.433   0.009   8069.629  49.160    0.000
# Agency:Competence                                -0.396   0.183   8014.385  -2.167    0.030
# Benevolence_NeutralvsRest:Competence              0.564   0.205   8013.609   2.752    0.006
# Benevolence_NeutralvsRest:Integrity               0.036   0.017   8016.038   2.145    0.032
# Benevolence_NeutralvsRest:Competence:Integrity   -0.082   0.033   8017.481  -2.453    0.014

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

write.csv(mod2_statstable, 
          "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s2_mod2_statstable.csv", 
          row.names = FALSE)

########################################### Simple Slopes Model 2 ###########################################
mod2_simslopes_competencebenevolenceintegrity = get_simslopes(model = mod2, confints = "Yes",
                                                              variables = c("Competence", "Benevolence_GenerousvsMalevolent", "Integrity"), 
                                                              levels = list(c(-0.5, 0.5), c(-0.5, 0, 0.5), c(0, 11, 22)),
                                                              labels = list(c("LowCompetence", "HighCompetence"), c("Malevolent", "Neutral", "Generous"), c("LowIntegrity", "NeutralIntegrity", "HighIntegrity")), 
                                                              categorical = c(TRUE, TRUE, FALSE))$significant_slopes

mod2_simslopes_agencycompetence = get_simslopes(model = mod2, confints = "Yes",
                                                variables = c("Agency", "Competence"),
                                                levels = list(c(-0.5, 0.5), c(-0.5, 0.5)),
                                                labels = list(c("AI", "Human"), c("LowCompetence", "HighCompetence")), 
                                                categorical = c(TRUE, TRUE))$significant_slopes

mod2_simslopes_competencebenevolenceintegrity = mod2_simslopes_competencebenevolenceintegrity %>%
  mutate(Reference = gsub("Benevolence_GenerousvsMalevolent", "Benevolence", Reference),
         Reference = gsub("^.*?_([A-Za-z0-9]+)[[:space:]]+.*?_([A-Za-z0-9]+)$", "\\1 \\2", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***",
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(grepl("[[:lower:]][[:upper:]][[:lower:]]", Reference), gsub("(.*?)([[:lower:]])([[:upper:]][[:lower:]])(.*?)", "\\1\\2 \\3\\4", Reference), Reference))

mod2_simslopes_agencycompetence = mod2_simslopes_agencycompetence %>%
  mutate(Reference = gsub("^.*?_([A-Za-z0-9]+)$", "\\1", Reference),
         `p-value` = ifelse(as.numeric(`p-value`) < 0.001, "< 0.001***",
                            ifelse(as.numeric(`p-value`) < 0.01, paste0(`p-value`, "**"),
                                   ifelse(as.numeric(`p-value`) < 0.05, paste0(`p-value`,"*"), `p-value`)))) %>%
  mutate(Reference = ifelse(grepl("[[:lower:]][[:upper:]][[:lower:]]", Reference), gsub("(.*?)([[:lower:]])([[:upper:]][[:lower:]])(.*?)", "\\1\\2 \\3\\4", Reference), Reference),
         Reference = gsub("AI", "A.I.", Reference))

write.csv(mod2_simslopes_competencebenevolenceintegrity, 
          "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s2_mod2_simslopes_competencebenevolenceintegrity.csv", 
          row.names = FALSE)
write.csv(mod2_simslopes_agencycompetence, 
          "/Users/richagautam/Library/CloudStorage/Dropbox/UDel_Mturk_TrustGame/manuscript/s2_mod2_simslopes_agencycompetence.csv", 
          row.names = FALSE)




