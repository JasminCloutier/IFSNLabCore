# You can learn more about package authoring with RStudio at:
#
#   http://r-pkgs.had.co.nz/
#
# Some useful keyboard shortcuts for package authoring:
#
#   Install Package:           'Cmd + Shift + B'
#   Check Package:             'Cmd + Shift + E'
#   Test Package:              'Cmd + Shift + T'

# pseudorandom() outputs a pseudorandomized matrix

###################################### Example ######################################
# stim_list = match_list(optseq, stimuli, nulls=TRUE)
####################################### Code #######################################

if (!require("tidyverse")) {install.packages("tidyverse")}
library(tidyverse)
if (!require("jtools")) {install.packages("jtools")}
library(jtools)
if (!require("Matrix")) {install.packages("Matrix")}
library(Matrix)

match_list = function(order, stims, nulls=FALSE) {
  # order = df or matrix of conditions and their duration to which the stimuli need to be matched.
  #         First column must be "Condition" and the second "Duration".
  # stims = df or matrix of stimuli (first column) and the condition they exhibit (second column).
  #         First column must be "Stimuli" and the second "Condition".
  # nulls = are there "NULL"s in the order?
  # The length of both must match

  `%notin%` = Negate(`%in%`)

  if (nulls == FALSE) {
    if(nrow(order) != nrow(stims)) {
      stop("Please enter a condition list and stimuli df that match in length.")
    }
  } else {
    message("Order contains NULL trials.")
  }

  # rename stims cols just in case
  names(stims) = c("Stimuli", "Condition")
  # rename order cols just in case
  names(order) = c("Condition", "Duration")

  # get all conditions
  conditions = unique(order$Condition)
  # remove NULL if present
  conditions = conditions[conditions %in% unique(stims$Condition)]

  matched_stims = data.frame(matrix(,ncol=3, nrow=nrow(order)))
  matched_stims[,1] = order$Condition
  matched_stims[,3] = order$Duration
  names(matched_stims) = c("Condition", "Stimuli", "Duration")

  for (condition in conditions) {
    stim_counter = 1
    stimuli = stims$Stimuli[stims$Condition == condition]
    stimuli = sample(stimuli, length(stimuli), replace=FALSE)

    condition_index = which(matched_stims$Condition == condition)
    for (ind in condition_index) {
      matched_stims[ind, "Stimuli"] = stimuli[stim_counter]
      stim_counter = stim_counter + 1
    }
  }

  return(matched_stims)
}


