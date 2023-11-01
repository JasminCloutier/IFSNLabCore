to_number = function(x) {
  # create list of words to number
  word_to_number = list("one" = 1, "two" = 2, "three" = 3, "four" = 4, "five" = 5,
                        "six" = 6, "seven" = 7, "eight" = 8, "nine" = 9, "ten" = 10,
                        "eleven" = 11, "twelve" = 12, "thirteen" = 13, "fourteen" = 14,
                        "fifteen" = 15, "sixteen" = 16, "seventeen" = 17, "eighteen" = 18,
                        "nineteen" = 19, "twenty" = 20, "thirty" = 30, "fourty" = 40, "forty" = 40,
                        "fifty" = 50, "sixty" = 60, "seventy" = 70, "eighty" = 80, "ninety" = 90)
  # turn everything into lower-case
  x = tolower(x)
  # trim white space
  x = trimws(x)
  # convert dashes to spaces
  x = gsub("-", " ", x)
  # remove and/&
  x = gsub("and|&", " ", x)
  # remove any punctuation marks
  x = gsub("[[:punct:]]", "", x)
  # convert multiple spaces in the middle to single space
  x = gsub("\\s+", " ", x)
  # split x by space
  x = unlist(strsplit(x, " "))
  if (length(x) == 2 & x[2] == "teen") {
    x = paste0(x[1],x[2])
    if (x %in% names(word_to_number)) {
      x = word_to_number[[x]]
      return(as.character(x))
    } else {
      return(paste(x, collapse=" "))
    }
  } else {
    can_convert = 1
    for (i in 1:length(x)) {
      if (x[i] %notin% names(word_to_number) & x[i] %notin% c("hundred", "thousand")) {
        can_convert = 0
      }
    }
    if (can_convert == 1) {
      new_x = 0
      for (i in 1:length(x)) {
        if (x[i] %in% names(word_to_number)) {
          new_x = new_x + word_to_number[[x[i]]]
        } else if (x[i] == "hundred") {
          new_x = new_x * 100 
        } else if (x[i] == "thousand") {
          new_x = new_x * 1000
        } 
      }
      return(as.character(new_x))
    } else {
      return(paste(x,collapse=" "))
    }
  }
}