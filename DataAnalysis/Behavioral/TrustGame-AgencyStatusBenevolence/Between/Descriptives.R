########################################### Descriptives ###############################################

rm(list = ls()) # clear the workspace

### Load packages
library(tidyverse)

###########################################Load data###############################################

df1 = "../../../data/preprocessed/Between_Subjects/data_cleaned.csv"
df2 = "../../../data/preprocessed/Between_Subjects/data_dummy_cleaned.csv"
df3 = "../../../data/preprocessed/Between_Subjects/data_firstroundexcluded_cleaned.csv"

data = read.csv(df1, stringsAsFactors = FALSE)
data_dummy = read.csv(df2, stringsAsFactors = FALSE)
data_firstroundexcluded = read.csv(df3, stringsAsFactors = FALSE)

########################################### Demographics ###############################################

demog = data %>% select(Subject, Gender, Race, SubjectiveSES_USA, SubjectiveSES_Community)
demog = demog[!duplicated(demog$Subject), ]

demog %>% ggplot(aes(Gender))+
  geom_bar(aes(y = (..count..)/sum(..count..)))+
  scale_y_continuous(labels=scales::percent) +
  ylab("Percentage") +
  theme(axis.text = element_text(size = 12, face = "bold"),
        axis.title.y = element_text(size = 14, face = "bold"),
        axis.title.x = element_text(size = 14, face = "bold"))

demog %>% group_by(Gender) %>% dplyr::summarise(Percentage = (n()/303)*100)

########################################### Generosity Simulation ###############################################
y_greedy = dbinom(x,10,0.23)
y_neutral = dbinom(x,10,0.33)
y_generous = dbinom(x,10,0.43)
temp = data.frame("Value" = x, "Generous" = y_generous, "Greedy" = y_greedy, "Neutral" = y_neutral)

temp = temp %>% gather("GenerosityLevel", "Probability", Generous:Neutral)

temp %>% ggplot(aes(Value, Generous)) + geom_bar(stat = "identity") + labs(title="Return distribution: Generous Partner") + coord_cartesian(
  xlim = c(0, 11))

temp %>% ggplot(aes(Value, Greedy)) + geom_bar(stat = "identity") + labs(title="Return distribution: Greedy Partner") + coord_cartesian(
  xlim = c(0, 11))

temp %>% ggplot(aes(Value, Neutral)) + geom_bar(stat = "identity") + labs(title="Return distribution: Neutral Partner") + coord_cartesian(
  xlim = c(0, 11))

###########################################Descriptive Graphs###############################################

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(Gender)) + 
  geom_bar() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(Age)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(Race_recoded)) + 
  geom_bar() + 
  theme_light() + 
  scale_x_discrete(labels = function(Race_recoded) str_wrap(Race_recoded, width = 10))

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(ObjectiveSES)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(SubjectiveSES_USA)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(SubjectiveSES_Community)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(ITS)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(IUS)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(Z_Competitiveness)) + 
  geom_histogram() + 
  theme_light()

data %>% 
  distinct(Subject, .keep_all = TRUE) %>% 
  ggplot(aes(Z_Cooperativeness)) + 
  geom_histogram() + 
  theme_light()

temp = data %>% group_by(PartnerAgency, PartnerReturn) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = PartnerReturn, y = count)) + 
  geom_col() + 
  facet_wrap(~PartnerAgency)

temp = data %>% group_by(StatusLevel, PartnerReturn) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = PartnerReturn, y = count)) + 
  geom_col() + 
  facet_wrap(~StatusLevel)

temp = data %>% group_by(Generosity, PartnerReturn) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = PartnerReturn, y = count)) + 
  geom_col() + 
  facet_wrap(~Generosity)

temp = data %>% group_by(PartnerAgency, MoneyTrusted) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = MoneyTrusted, y = count)) + 
  geom_col() + 
  facet_wrap(~PartnerAgency)

temp = data %>% group_by(StatusLevel, MoneyTrusted) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = MoneyTrusted, y = count)) + 
  geom_col() + 
  facet_wrap(~StatusLevel)

temp = data %>% group_by(Generosity, MoneyTrusted) %>% summarise(count = n())
temp %>% 
  ggplot(aes(x = MoneyTrusted, y = count)) + 
  geom_col() + 
  facet_wrap(~Generosity)
