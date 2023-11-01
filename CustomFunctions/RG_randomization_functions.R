get_matrix_byproportion = function(row, col, prop1) {
  #proportion of 0s  = 1-prop1
  prop2 = 1-prop1
  #proportion of 1s will determine row and column sums
  row_sum = col*prop1
  col_sum = row*prop1
  #Create a matrix with 50/50 1 and 0 in every column and row
  matrix = matrix(c(rep(0:1,each=col*prop2, times=row*prop2), 
                    rep(1:0,each=col*prop1, times=row*prop1)), 
                  byrow=TRUE, nrow = row, ncol = col)
  
  for (column in 1:ncol(matrix)) {
    rand = sample(nrow(matrix))
    matrix[,column] = matrix[rand,column]
  }
  
  sumrow = apply(matrix,1,sum)
  missing = pmax(0,row_sum-sumrow) # vector of n component, how many ones miss for each col
  excess = pmax(0,sumrow-row_sum) # vector of n component, how many ones miss for each col
  
  #pick a random row with a missing one (r) and a random row with an excess one (s)
  #swap randomly a 1 in s-th columns with a 0 in r-th column
  
  while(sum(missing)>0){
    index_excess = which(excess>0)
    index_missing = which(missing>0)
    index_chosen_donor = if(length(index_excess)==1) index_excess else sample(index_excess,1)
    index_chosen_recipient = if(length(index_missing)==1) index_missing else sample(index_missing,1)
    joint_index = which(matrix[index_chosen_donor,]==1 & matrix[index_chosen_recipient,]==0)
    joint_index_chosen = if(length(joint_index)==1) joint_index else sample(joint_index,1)
    matrix[index_chosen_recipient,joint_index_chosen] = 1
    matrix[index_chosen_donor,joint_index_chosen] = 0
    
    sumrow = apply(matrix,1,sum)
    missing = pmax(0,row_sum-sumrow)
    excess = pmax(0,sumrow-row_sum)
  }
  
  matrix
  
}

get_matrix = function(row, col, row_sum, col_sum) {
  #proportion of 0s  = 1-prop1
  #prop2 = 1-prop1
  #proportion of 1s will determine row and column sums
  #row_sum = col*prop1
  #col_sum = row*prop1
  #Create a matrix with 50/50 1 and 0 in every column and row
  matrix = matrix(c( rep(c(rep(0, times=(row-col_sum)), rep(1, times=col_sum)), times=(col-row_sum)), 
                     rep(c(rep(1, times=col_sum), rep(0, times=(row-col_sum))), times=row_sum)),
                  # rep(0:1,each=col*prop2, times=row*prop2), 
                  # rep(1:0,each=col*prop1, times=row*prop1)), 
                  byrow=FALSE, nrow = row, ncol = col)
  
  for (column in 1:ncol(matrix)) {
    rand = sample(nrow(matrix))
    matrix[,column] = matrix[rand,column]
  }
  
  sumrow = apply(matrix,1,sum)
  missing = pmax(0,row_sum-sumrow) # vector of n component, how many ones miss for each col
  excess = pmax(0,sumrow-row_sum) # vector of n component, how many ones miss for each col
  
  #pick a random row with a missing one (r) and a random row with an excess one (s)
  #swap randomly a 1 in s-th columns with a 0 in r-th column
  
  while(sum(missing)>0){
    index_excess <- which(excess>0) # index of excess
    index_missing = which(missing>0)
    index_chosen_donor = if(length(index_excess)==1) index_excess else sample(index_excess,1)
    index_chosen_recipient = if(length(index_missing)==1) index_missing else sample(index_missing,1)
    joint_index = which(matrix[index_chosen_donor,]==1 & matrix[index_chosen_recipient,]==0)
    joint_index_chosen = if(length(joint_index)==1) joint_index else sample(joint_index,1)
    matrix[index_chosen_recipient,joint_index_chosen] = 1
    matrix[index_chosen_donor,joint_index_chosen] = 0
    
    sumrow = apply(matrix,1,sum)
    missing = pmax(0,row_sum-sumrow)
    excess = pmax(0,sumrow-row_sum)
  }
  
  matrix
  
}

get_randlist_withconstraints = function(row, col, row_sum, col_sum, constraint_ones, constraint_zeros=1) {
  random_matrix = get_matrix(row=row, col=col, row_sum=row_sum, col_sum=col_sum)
  corrAns = c(random_matrix)
  
  index_ones = which(corrAns == 1)
  index_ones = split(index_ones, cumsum(c(1, diff(index_ones) != 1)))
  if (length(index_ones) > 0) {
    index_missing = list()
    new_ind = 1
    for (i in 1:length(index_ones)) {
      if (length(index_ones[[i]]) > constraint_ones) {
        index_missing[[new_ind]] = index_ones[[i]]
        new_ind = new_ind+1
      }
    }
  }
  
  index_zeros = which(corrAns == 0)
  index_zeros = split(index_zeros, cumsum(c(1, diff(index_zeros) != 1)))
  if (length(index_zeros) > 0) {
    index_excess = list()
    new_ind = 1
    for (i in 1:length(index_zeros)) {
      if (length(index_zeros[[i]]) > constraint_zeros) {
        index_excess[[new_ind]] = index_zeros[[i]]
        new_ind = new_ind+1
      }
    }
  }
  
  while (length(index_missing) > 0 & length(index_excess) > 0) {
    index_ones = which(corrAns == 1)
    index_ones = split(index_ones, cumsum(c(1, diff(index_ones) != 1)))
    if (length(index_ones) > 0) {
      index_missing = list()
      new_ind = 1
      for (i in 1:length(index_ones)) {
        if (length(index_ones[[i]]) > constraint_ones) {
          index_missing[[new_ind]] = index_ones[[i]]
          new_ind = new_ind+1
        }
      }
    }
    
    index_zeros = which(corrAns == 0)
    index_zeros = split(index_zeros, cumsum(c(1, diff(index_zeros) != 1)))
    if (length(index_zeros) > 0) {
      index_excess = list()
      new_ind = 1
      for (i in 1:length(index_zeros)) {
        if (length(index_zeros[[i]]) > constraint_zeros) {
          index_excess[[new_ind]] = index_zeros[[i]]
          new_ind = new_ind+1
        }
      }
    }
    
    if (length(index_missing) != length(index_excess)) {
      length_index_missing = c()
      new_ind = 1
      for (i in 1:length(index_missing)) {
        length_index_missing = c(length_index_missing, length(index_missing[[i]]))
      }
      max_missing_ind = which(length_index_missing == max(length_index_missing))
      
      length_index_excess = c()
      new_ind = 1
      for (i in 1:length(index_excess)) {
        length_index_excess = c(length_index_excess, length(index_excess[[i]]))
      }
      max_excess_ind = which(length_index_excess == max(length_index_excess))
      
      max_missing_ind = ifelse(length(max_missing_ind) > 1, sample(max_missing_ind, 1), max_missing_ind)
      max_excess_ind = ifelse(length(max_excess_ind) > 1, sample(max_excess_ind, 1), max_excess_ind)
      donor_index = index_excess[[max_excess_ind]][length(index_excess[[max_excess_ind]])]
      recipient_index = round(median(index_missing[[max_missing_ind]]))
      corrAns[donor_index] = 1
      corrAns[recipient_index] = 0
      
      index_ones = which(corrAns == 1)
      index_ones = split(index_ones, cumsum(c(1, diff(index_ones) != 1)))
      index_missing = list()
      new_ind = 1
      for (i in 1:length(index_ones)) {
        if (length(index_ones[[i]]) > constraint_ones) {
          index_missing[[new_ind]] = index_ones[[i]]
          new_ind = new_ind+1
        }
      }
      
      index_zeros = which(corrAns == 0)
      index_zeros = split(index_zeros, cumsum(c(1, diff(index_zeros) != 1)))
      index_excess = list()
      new_ind = 1
      for (i in 1:length(index_zeros)) {
        if (length(index_zeros[[i]]) > constraint_zeros) {
          index_excess[[new_ind]] = index_zeros[[i]]
          new_ind = new_ind+1
        }
      }
    } else {
      for (i in 1:length(index_missing)) {
        donor_index = index_excess[[i]][length(index_excess[[i]])]
        recipient_index = round(median(index_missing[[i]]))
        corrAns[donor_index] = 1
        corrAns[recipient_index] = 0
      }
      
      index_ones = which(corrAns == 1)
      index_ones = split(index_ones, cumsum(c(1, diff(index_ones) != 1)))
      index_missing = list()
      new_ind = 1
      for (i in 1:length(index_ones)) {
        if (length(index_ones[[i]]) > constraint_ones) {
          index_missing[[new_ind]] = index_ones[[i]]
          new_ind = new_ind+1
        }
      }
      
      index_zeros = which(corrAns == 0)
      index_zeros = split(index_zeros, cumsum(c(1, diff(index_zeros) != 1)))
      index_excess = list()
      new_ind = 1
      for (i in 1:length(index_zeros)) {
        if (length(index_zeros[[i]]) > constraint_zeros) {
          index_excess[[new_ind]] = index_zeros[[i]]
          new_ind = new_ind+1
        }
      }
    }
  }
  return(corrAns)
}
