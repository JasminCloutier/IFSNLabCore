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
# pr_matrix = pseudorandom(conditions = c("high", "low"),
#                          total = 96, across = 120,
#                          proportions = c(0.75, 0.25), constrain=5)
# pr_matrix = pseudorandom(conditions = c("HA", "SA", "HNA", "SNA"),
#                          total = 44, across = 128, constrain=3)
####################################### Code #######################################

if (!require("tidyverse")) {install.packages("tidyverse")}
library(tidyverse)
if (!require("jtools")) {install.packages("jtools")}
library(jtools)
if (!require("Matrix")) {install.packages("Matrix")}
library(Matrix)

pseudorandom = function(conditions, total, across, proportions=NULL, constrain=NULL) {
  # conditions = vector of condition names
  # total = total number of trials across all conditions. this will be the number of rows in the pseudorandom matrix
  # across = number of stimuli/participants that conditions need to be pseudorandomized across. this will be the number of columns in the pseudorandom matrix
  # proportions = proportion for each condition. default assumes equal distribution
  # constrain = maximum number of times a condition can appear consecutively. default assumes no constrains

  # convert conditions to characters in case numeric values were provided
  conditions = as.character(conditions)

  # calculate proportions if not provided
  if (is.null(proportions)) {
    proportion = 1/length(conditions)
    proportions = rep(proportion, length(conditions))
    rm(proportion)
  }

  # stop if number of proportions doesn't equal number of conditions
  if (length(proportions) != length(conditions)) {
    stop("Number of proportions does not match number of conditions.")
  }

  `%notin%` = Negate(`%in%`)

  get_matrix = function(conditions, total, across, proportions) {

    # First, create an un-random matrix
    data = c()
    for (i in 1:length(conditions)) {
      sumcol = floor(total*proportions[i])
      data_condition = rep(conditions[i], times=sumcol)
      data = c(data, data_condition)
    }
    data = rep(data, times=across)
    matrix = matrix(data, nrow=total, ncol=across, byrow=FALSE)
    rm(data, i, data_condition)

    # Shuffle each column
    for (column in 1:ncol(matrix)) {
      rand = sample(nrow(matrix))
      matrix[,column] = matrix[rand,column]
    }
    rm(column, rand)

    # Now calculate the counts for each condition per row
    missing = list()
    excess = list()

    # Iterate through matrix rows
    for (i in 1:nrow(matrix)) {
      # and through all conditions
      for (j in 1:length(conditions)) {
        # how many times does each condition appear in each row?
        condition_count = sum(matrix[i,] == conditions[j])
        # calculate how many times condition should be present in a row
        sumrow = floor(proportions[j]*across)
        # if the number of times doesn't equal what it should be
        if (sumrow != condition_count) {
          # if it is greater then add row to excess list
          if (condition_count > sumrow) {
            excess[[conditions[j]]] = c(excess[[conditions[j]]], i)
            # if it is lower then add to missing list
          } else if (condition_count < sumrow) {
            missing[[conditions[j]]] = c(missing[[conditions[j]]], i)
          }
        }
      }
    }
    rm(i, j, condition_count)
    missing = missing[which(lengths(missing) > 0)]
    excess = excess[which(lengths(excess) > 0)]

    # Order
    length_missing = sapply(missing, length)
    if (length(length_missing) > 0) {
      missing = missing[order(-length_missing)]
    }
    rm(length_missing)
    length_excess = sapply(excess, length)
    if (length(length_excess) > 0) {
      length_excess = excess[order(-length_excess)]
    }
    rm(length_excess)

    while (length(unlist(missing)) > 0 & length(unlist(excess)) > 0) {
      for (condition1 in names(missing)) {
        conditions_left = excess[names(excess)[names(excess) %notin% condition1]]
        conditions_left = conditions_left[which(lengths(conditions_left) > 0)]
        condition2 = names(which(lengths(conditions_left) == max(lengths(conditions_left))))
        condition2 = sample(condition2, 1)
        if (length(excess[[condition1]]) > 0 & (length(missing[[condition1]]) > 0 & length(excess[[condition2]]) > 0)) {
          index_excess_chosen = sample(excess[[condition1]], 1)
          index_missing = intersect(missing[[condition1]], excess[[condition2]])
          if (length(index_missing) > 0) {
            index_missing_chosen = sample(index_missing, 1)
            joint_index = which(matrix[index_excess_chosen,]==condition1 & matrix[index_missing_chosen,]==condition2)
            if (length(joint_index) > 0) {
              joint_index_chosen = sample(joint_index, 1)
              matrix[index_excess_chosen, joint_index_chosen] = condition2
              matrix[index_missing_chosen, joint_index_chosen] = condition1
            }
          }
        }
      }
      rm(condition1, condition2, conditions_left)

      # Reset the lists
      missing = list()
      excess = list()

      # Iterate through matrix rows to calculate the counts for each condition per row
      for (i in 1:nrow(matrix)) {
        # and through all conditions
        for (j in 1:length(conditions)) {
          # how many times does each condition appear in each row?
          condition_count = sum(matrix[i,] == conditions[j])
          # calculate how many times condition should be present in a row
          sumrow = floor(proportions[j]*across)
          # if the number of times doesn't equal what it should be
          if (sumrow != condition_count) {
            # if it is greater then add row to excess list
            if (condition_count > sumrow) {
              excess[[conditions[j]]] = c(excess[[conditions[j]]], i)
              # if it is lower then add to missing list
            } else if (condition_count < sumrow) {
              missing[[conditions[j]]] = c(missing[[conditions[j]]], i)
            }
          }
        }
      }
      rm(i, j, condition_count)

      missing = missing[which(lengths(missing) > 0)]
      excess = excess[which(lengths(excess) > 0)]

      # Order
      length_missing = sapply(missing, length)
      if (length(length_missing) > 0) {
        missing = missing[order(-length_missing)]
      }
      rm(length_missing)
      length_excess = sapply(excess, length)
      if (length(length_excess) > 0) {
        length_excess = excess[order(-length_excess)]
      }
      rm(length_excess)
    }
    rm(excess, missing, sumcol, sumrow)

    return(matrix)
  }

  final = get_matrix(conditions, total, across, proportions)

  if (!is.null(constrain)) {
    for (column in 1:ncol(final)) {
      data = c(final[,column])

      # Count
      index_conditions = list()
      for (condition in conditions) {
        index_condition = which(data %in% condition)
        index_condition = split(index_condition, cumsum(c(1, diff(index_condition) != 1)))
        index_condition = index_condition[names(which(lengths(index_condition) > constrain))]
        index_conditions[[condition]] = index_condition
      }
      # Remove any condition with no indices exceeding the constraint
      index_conditions = index_conditions[which(lengths(index_conditions) > 0)]
      rm(index_condition, condition)

      # Order
      length_index_conditions = sapply(index_conditions, length)
      if (length(length_index_conditions) > 0) {
        index_conditions = index_conditions[order(-length_index_conditions)]
      }
      rm(length_index_conditions)

      length_unconstrained = length(unlist(index_conditions))

      while (length_unconstrained > 0 & length(index_conditions) > 1) {
        for (condition1 in names(index_conditions)) {
          conditions_left = index_conditions[which(names(index_conditions) %notin% condition1)]
          conditions_left = conditions_left[which(lengths(conditions_left) > 0)]
          if (length(conditions_left) > 0) {
            condition2 = names(which(lengths(conditions_left) == max(lengths(conditions_left))))
            condition2 = sample(condition2, 1)

            # Order lists for cond1
            length_index_condition1 = sapply(index_conditions[[condition1]], length)
            if (length(length_index_condition1) > 0) {
              index_conditions[[condition1]] = index_conditions[[condition1]][order(-length_index_condition1)]
            }
            rm(length_index_condition1)

            # Order lists for cond2
            length_index_condition2 = sapply(index_conditions[[condition2]], length)
            if (length(length_index_condition2) > 0) {
              index_conditions[[condition2]] = index_conditions[[condition2]][order(-length_index_condition2)]
            }
            rm(length_index_condition2)

            # Start the loop
            min_length = min(length(index_conditions[[condition1]]), length(index_conditions[[condition2]]))
            for (i in 1:min_length) {
              cond1_index = index_conditions[[condition1]][[i]][length(index_conditions[[condition1]][[i]])]
              cond2_index = round(median(index_conditions[[condition2]][[i]]))
              data[cond1_index] = condition2
              data[cond2_index] = condition1
            }
          } else {
            break
          }
        }

        # Re-count
        index_conditions = list()
        for (condition in conditions) {
          index_condition = which(data %in% condition)
          index_condition = split(index_condition, cumsum(c(1, diff(index_condition) != 1)))
          index_condition = index_condition[names(which(lengths(index_condition) > constrain))]
          index_conditions[[condition]] = index_condition
        }
        # Remove any condition with no indices exceeding the constraint
        index_conditions = index_conditions[which(lengths(index_conditions) > 0)]
        rm(index_condition, condition)

        # Re-order
        length_index_conditions = sapply(index_conditions, length)
        if (length(length_index_conditions) > 0) {
          index_conditions = index_conditions[order(-length_index_conditions)]
        }
        rm(length_index_conditions)

        length_unconstrained = length(unlist(index_conditions))
      }
      rm(index_conditions, conditions_left, cond1_index, cond2_index, condition1,
         condition2, i, min_length, length_unconstrained)

      # do a final check to make sure all conditions are represented as many times as they should be
      excess = list()
      missing = list()
      for (i in 1:length(proportions)) {
        sumcol = floor(proportions[i]*total)
        if (sum(data == conditions[i], na.rm = TRUE) > sumcol) {
          excess[[conditions[i]]] = sum(data == conditions[i], na.rm = TRUE) - sumcol
        } else if (sum(data == conditions[i], na.rm = TRUE) < sumcol) {
          missing[[conditions[i]]] = sumcol - sum(data == conditions[i], na.rm = TRUE)
        }
      }
      missing = missing[which(lengths(missing) > 0)]
      excess = excess[which(lengths(excess) > 0)]

      # Order
      length_missing = sapply(missing, length)
      if (length(length_missing) > 0) {
        missing = missing[order(-length_missing)]
      }
      rm(length_missing)
      length_excess = sapply(excess, length)
      if (length(length_excess) > 0) {
        length_excess = excess[order(-length_excess)]
      }
      rm(length_excess)

      while (length(unlist(missing)) > 0 & length(unlist(excess)) > 0) {
        for (condition1 in names(missing)) {
          conditions_left = excess[names(excess)[names(excess) %notin% condition1]]
          conditions_left = conditions_left[which(lengths(conditions_left) > 0)]
          condition2 = names(which(lengths(conditions_left) == max(lengths(conditions_left))))
          condition2 = sample(condition2, 1)
          if (length(excess[[condition1]]) > 0 & (length(missing[[condition1]]) > 0 & length(excess[[condition2]]) > 0)) {
            index_excess_chosen = sample(excess[[condition1]], 1)
            index_missing = intersect(missing[[condition1]], excess[[condition2]])
            if (length(index_missing) > 0) {
              index_missing_chosen = sample(index_missing, 1)
                data[index_excess_chosen] = condition2
                data[index_missing_chosen] = condition1
            }
          }
        }
        rm(condition1, condition2, conditions_left)

        # Reset the lists
        excess = list()
        missing = list()
        for (i in 1:length(proportions)) {
          sumcol = floor(proportions[i]*total)
          if (sum(data == conditions[i], na.rm = TRUE) > sumcol) {
            excess[[conditions[i]]] = sum(data == conditions[i], na.rm = TRUE) - sumcol
          } else if (sum(data == conditions[i], na.rm = TRUE) < sumcol) {
            missing[[conditions[i]]] = sumcol - sum(data == conditions[i], na.rm = TRUE)
          }
        }
        missing = missing[which(lengths(missing) > 0)]
        excess = excess[which(lengths(excess) > 0)]

        # Order
        length_missing = sapply(missing, length)
        if (length(length_missing) > 0) {
          missing = missing[order(-length_missing)]
        }
        rm(length_missing)
        length_excess = sapply(excess, length)
        if (length(length_excess) > 0) {
          length_excess = excess[order(-length_excess)]
        }
        rm(length_excess)
      }
      final[,column] = data
    }
    rm(column, data, i, sumcol, excess, missing)
  }
  return(final)
}



