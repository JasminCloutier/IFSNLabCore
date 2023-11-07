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

###########################################Load data###############################################

df = "../../../data/preprocessed/Within_Subjects/TG_performance_data_survey_long_8_28_2021.csv"
data = read.csv(df, stringsAsFactors = FALSE, na.strings = c("", "NA"))
data = data[with(data, order(Subject, Game_Number, Round)),]

### Clean df

data = data %>% 
  filter(active_screen == "PLAYER_INVEST") %>%
  group_by(Subject, Game_Number, Round) %>% 
  filter(row_number()==n()) %>%
  ungroup() %>%
  ### Contrasts for Status
  ## Make sure contrasts are 1 away from each other because beta is multiplied with the step distance
  #Scode1 = c(0.5, -0.5) #high status, low status
  mutate(status_contrast = ifelse(StatusLevel == "HIGH", 0.5, -0.5),
         ### Contrasts for Generosity
         #Gcode1 = c(-0.5, 0, 0.5) #greedy, neutral, generous
         generosity_contrast1 = ifelse(Generosity == "greedy", -0.5, ifelse(Generosity == "neutral", 0, 0.5)),
         #Gcode2 = c(0.33, 0.33, -0.66) #greedy, neutral, generous
         generosity_contrast2 = ifelse(Generosity == "greedy", 0.33, ifelse(Generosity == "neutral", 0.33, -0.66)),
         #Gcode3 = c(-0.5, 0.5, 0) #greedy, neutral, generous
         generosity_contrast3 = ifelse(Generosity == "greedy", -0.5, ifelse(Generosity == "neutral", 0.5, 0)),
         #Gcode4 = c(0, -0.5, 0.5) #greedy, neutral, generous
         generosity_contrast4 = ifelse(Generosity == "greedy", 0, ifelse(Generosity == "neutral", -0.5, 0.5)),
         #Gcode5 = c(-0.66, 0.33, 0.33) #greedy, neutral, generous
         generosity_contrast5 = ifelse(Generosity == "greedy", -0.66, ifelse(Generosity == "neutral", 0.33, 0.33)),
         ### Contrasts for agency
         #Acode = c(-0.5, 0.5) #AI, HUMAN
         agency_contrast = ifelse(PartnerAgency == "CPU", -0.5, 0.5),
         ### Feedback
         Feedback = ifelse(Round == 1, 0, lag(PartnerReturn)),
         MoneyTrusted = as.numeric(MoneyTrusted),
         Z_Competitiveness = scale(Competitiveness),
         Z_Cooperativeness = scale(Cooperativeness),
         Z_AICompetence = scale(AICompetence),
         Z_AIWarmth = scale(AIWarmth),
         HighestDegree = ifelse(HighestDegree == "Less than high school", 1,
                                ifelse(HighestDegree == "High School", 2,
                                       ifelse(HighestDegree == "Associate's Degree", 3,
                                              ifelse(HighestDegree == "Bachelor's Degree", 4, 
                                                     ifelse(HighestDegree == "Master's Degree", 5,
                                                            ifelse(HighestDegree == "Professional", 6, NA)))))),
         HighestGrade = stri_extract_last(HighestGrade, regex = "\\d{2}"),
         EmploymentStatus = ifelse(EmploymentStatus == "Unemployed", 0,
                                   ifelse(EmploymentStatus == "Keeping house or raising children full-time", 0,
                                          ifelse(EmploymentStatus == "Looking for work", 0,
                                                 ifelse(EmploymentStatus == "Part-time", 1,
                                                        ifelse(EmploymentStatus == "Full-time", 2, NA))))),
         Income = ifelse(Income == "<5k", 1,
                         ifelse(Income == "5k-12k", 2, 
                                ifelse(Income == "12k-16k", 3,
                                       ifelse(Income == "16k-25k", 4,
                                              ifelse(Income == "25k-35k", 5,
                                                     ifelse(Income == "35k-50k", 6,
                                                            ifelse(Income == "50k-75k", 7,
                                                                   ifelse(Income == "75k-100k", 8,
                                                                          ifelse(Income == ">100k", 9, NA))))))))),
         HouseholdIncome = ifelse(Income == "<5k", 1,
                                  ifelse(Income == "5k-12k", 2, 
                                         ifelse(Income == "12k-16k", 3,
                                                ifelse(Income == "16k-25k", 4,
                                                       ifelse(Income == "25k-35k", 5,
                                                              ifelse(Income == "35k-50k", 6,
                                                                     ifelse(Income == "50k-75k", 7,
                                                                            ifelse(Income == "75k-100k", 8,
                                                                                   ifelse(Income == ">100k", 9, NA))))))))),
         Savings = ifelse(Savings == "<1 month", 1,
                          ifelse(Savings == "1-2 months", 2,
                                 ifelse(Savings == "3-6 months", 3,
                                        ifelse(Savings == "7-12 months", 4, 
                                               ifelse(Savings == ">12 months", 5, NA))))),
         Assets = ifelse(Assets == "<500", 1,
                         ifelse(Assets == "500-5k", 2,
                                ifelse(Assets == "5k-10k", 3,
                                       ifelse(Assets == "10k-20k", 4, 
                                              ifelse(Assets == "20k-50k", 5, 
                                                     ifelse(Assets == "50k-100k", 6,
                                                            ifelse(Assets == "100k-200k", 7,
                                                                   ifelse(Assets == "200k-500k", 8,
                                                                          ifelse(Assets == ">500k", 9, NA))))))))),
         NetWorth = ifelse(NetWorth == "<500", 1,
                           ifelse(NetWorth == "500-5k", 2,
                                  ifelse(NetWorth == "5k-10k", 3,
                                         ifelse(NetWorth == "10k-20k", 4, 
                                                ifelse(NetWorth == "20k-50k", 5, 
                                                       ifelse(NetWorth == "50k-100k", 6,
                                                              ifelse(NetWorth == "100k-200k", 7,
                                                                     ifelse(NetWorth == "200k-500k", 8,
                                                                            ifelse(NetWorth == ">500k", 9, NA)))))))))) %>%
  mutate(HighestGrade = as.numeric(HighestGrade))

data = data %>%
  mutate(Z_Degree = scale(HighestDegree),
         Z_Grade = scale(HighestGrade),
         Z_EmploymentStatus = scale(EmploymentStatus),
         Z_Income = scale(Income),
         Z_HouseholdIncome = scale(HouseholdIncome),
         Z_Savings = scale(Savings),
         Z_Assets = scale(Assets),
         Z_NetWorth = scale(NetWorth))

data = data %>%
  mutate(EduIndex = rowMeans(as.matrix(data[,c("Z_Degree","Z_Grade")]), na.rm = TRUE),
         IncomeIndex = rowMeans(as.matrix(data[,c("Z_Income","Z_HouseholdIncome")]),na.rm = TRUE),
         AssetsIndex = rowMeans(as.matrix(data[,c("Z_Savings","Z_Assets","Z_NetWorth")]),na.rm=TRUE))

data = data %>%
  mutate(Z_EduIndex = scale(EduIndex),
         Z_IncomeIndex = scale(IncomeIndex),
         Z_AssetsIndex = scale(AssetsIndex))

data = data %>% mutate(ObjectiveSES = rowMeans(as.matrix(data[,c("Z_EduIndex","Z_IncomeIndex","Z_AssetsIndex","Z_EmploymentStatus")]),na.rm=TRUE))
data = data %>% mutate(Race_recoded = ifelse(Race %in% c("Black or African American|White", 
                                                         "Black or African American|Native Hawaiian or Other Pacific Islander|White", 
                                                         "White|Asian",
                                                         "Native Hawaiian or Other Pacific Islander|Asian|Other",
                                                         "White|Other"), "Multiracial", Race))


###########################################Create subsetted dfs###############################################
max = max(data$Feedback)
mid = max/2
mean = mean(data$Feedback)
mean_minusSD = mean - sd(data$Feedback)
mean_plusSD = mean + sd(data$Feedback)

data_dummy = data %>% mutate(Feedback = ifelse(Round == 1 & Feedback == 0, is.null(Feedback), Feedback))

data_dummy = data %>% mutate(PartnerAgency_AI = ifelse(agency_contrast == -0.5, 0, 1),
                             PartnerAgency_Human = ifelse(agency_contrast == 0.5, 0, 1),
                             Status_Low = ifelse(status_contrast == -0.5, 0, 1),
                             Status_High = ifelse(status_contrast == 0.5, 0, 1),
                             Generosity_Greedy = ifelse(generosity_contrast1 == -0.5, 0, 1),
                             Generosity_Greedy1 = ifelse(generosity_contrast1 == -0.5, 0, 
                                                         ifelse(generosity_contrast1 == 0, -0.5, 0.5)),
                             Generosity_Neutral = ifelse(generosity_contrast1 == 0, 0, 1),
                             Generosity_Generous = ifelse(generosity_contrast1 == 0.5, 0, 1),
                             Generosity_Generous1 = ifelse(generosity_contrast1 == 0.5, 0,
                                                          ifelse(generosity_contrast1 == 0, -0.5, 0.5)),
                             Round_1 = Round - 1,
                             Round_2 = Round - 2,
                             Round_5 = Round - 5,
                             Round_10 = Round - 10,
                             Feedback_mid = Feedback - mid,
                             Feedback_max = Feedback - max,
                             Feedback_mean = Feedback - mean,
                             Feedback_minusSD = Feedback - mean_minusSD,
                             Feedback_plusSD = Feedback - mean_plusSD)

data_firstroundexcluded = data_dummy %>% filter(Round != 1)

write.csv(data, "../../../data/preprocessed/Within_Subjects/data_cleaned.csv", row.names = FALSE)
write.csv(data_dummy, "../../../data/preprocessed/Within_Subjects/data_dummy_cleaned.csv", row.names = FALSE)
write.csv(data_firstroundexcluded, "../../../data/preprocessed/Within_Subjects/data_firstroundexcluded_cleaned.csv", row.names = FALSE)

data_firstroundexcluded %>% ggplot(aes(MoneyTrusted)) + geom_histogram()
#Anchoring effects but we can cross-check with CLM model
#Lots of plots of descriptives! relationships between each of our variables of interest
#Merge survey data and run exploratory model
#Look at trustworthiness ratings
#### POWER POINTS

workerIds = unique(data$Subject)
newIds = seq(20001,20154,1)
anonymize = data.frame("Subject" = workerIds, "NewIds" = newIds)
data = merge(data, anonymize, by="Subject") %>% select(-Subject) %>% rename("Subject" = NewIds)
data_firstroundexcluded = merge(data_firstroundexcluded, anonymize, by="Subject") %>% select(-Subject) %>% rename("Subject" = NewIds)

temp = read.csv("../../../data/preprocessed/Within_Subjects/unfiltered datasets/filtered_performance_data.csv")
temp = temp %>% select(Subject, Game_Number, opp_icon)
temp = merge(temp, anonymize, by = "Subject")
temp = temp %>% select(NewIds, Game_Number, opp_icon) %>% rename("Subject" = NewIds)
temp = temp %>% mutate(opp_icon = gsub("^.*?_([0-9]+)_.*?$", "\\1", opp_icon))
data = merge(data, temp, by=c("Subject", "Game_Number")) %>% distinct()
data_firstroundexcluded = merge(data_firstroundexcluded, temp, by=c("Subject", "Game_Number")) %>% distinct()

data_firstroundexcluded = data_firstroundexcluded %>%
  select(-Stimuli) %>%
  rename("Stimuli" = opp_icon) %>%
  mutate(Benevolence_NeutralDummy = ifelse(generosity_contrast1 == 0, 0, 1),
         Benevolence_MalevolentDummy = ifelse(generosity_contrast1 == -0.5, 0, 1),
         Benevolence_MalevolentContrast = ifelse(generosity_contrast1 == -0.5, 0,
                                                 ifelse(generosity_contrast1 == 0, -0.5, 0.5)),
         Stimuli = gsub("^[A-Za-z]+_([0-9]+)$", "\\1", Stimuli)) %>%
  select(Subject, Stimuli, PartnerAgency, Generosity, StatusLevel, Game_Number, Round, 
         MoneyTrusted, PartnerReturn, Feedback, PlayerRoundTotal, PartnerRoundTotal, 
         PreCooperationRatings, PreTrustRatings, PostCooperationRatings, PostTrustRatings, 
         agency_contrast, status_contrast, generosity_contrast1, generosity_contrast2, generosity_contrast3, 
         generosity_contrast4, generosity_contrast5, Competitiveness, Z_Competitiveness, 
         Cooperativeness, Z_Cooperativeness, AICompetence, Z_AICompetence, AIWarmth, Z_AIWarmth,
         SubjectiveSES_Community, SubjectiveSES_USA, HighestGrade, HighestDegree, EmploymentStatus, 
         EmploymentIndustry, LaborType, HouseholdIncome, Income, HouseholdSize, EarningAdults, Savings, 
         Assets, NetWorth, ObjectiveSES, Race_recoded, Age, Gender, Ethnicity, PartnerAgency_AI, 
         PartnerAgency_Human, Status_High, Status_Low, Generosity_Generous, Generosity_Generous1, 
         Benevolence_NeutralDummy, Benevolence_MalevolentDummy, Benevolence_MalevolentContrast, 
         Round_1, Round_5, Round_10, Feedback_mid, Feedback_max, Believability_AI, Believability_Human)

names(data_firstroundexcluded) = c("Subject", "Stimuli", "PartnerAgency", "PartnerBenevolence", "PartnerStatus", "Game", "Round", 
                                   "MoneyTrusted", "PartnerReturn", "Feedback", "PlayerRoundTotal", "PartnerRoundTotal", 
                                   "PreCooperationRatings", "PreTrustRatings", "PostCooperationRatings", "PostTrustRatings", 
                                   "Agency", "Status", "Benevolence_GenerousvsMalevolent", "Benevolence_GenerousvsRest", 
                                   "Benevolence_GreedyvsNeutral", "Benevolence_GenerousvsNeutral", "Benevolence_GreedyvsRest", 
                                   "Competitiveness", "CompetitivenessZ", "Cooperativeness", "CooperativenessZ", "AICompetence", 
                                   "AICompetenceZ", "AIWarmth", "AIWarmthZ", "SubjectiveSES_Community", "SubjectiveSES_USA", 
                                   "HighestGrade", "HighestDegree", "EmploymentStatus", "EmploymentIndustry", "LaborType", 
                                   "HouseholdIncome", "Income", "HouseholdSize", "EarningAdults", "Savings", "Assets", "NetWorth", 
                                   "ObjectiveSES", "Race", "Age", "Gender", "Ethnicity", "PartnerAgency_AI", "PartnerAgency_Human", 
                                   "PartnerStatus_High", "PartnerStatus_Low", "Benevolence_GenerousDummy", 
                                   "Benevolence_GenerousContrast", "Benevolence_NeutralDummy", "Benevolence_MalevolentDummy", 
                                   "Benevolence_MalevolentContrast", "Round1", "Round5", "Round10", "Feedback11", "Feedback22", 
                                   "Believability_AI", "Believability_Human")

write.csv(data, "data.csv", row.names = FALSE)
write.csv(data_firstroundexcluded, "data_firstroundexcluded.csv", row.names = FALSE)

