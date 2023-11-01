predicted_out = function(model, pred, pred.values = NULL, pred.labels = NULL,
                         modx, modx.values = NULL, modx.labels = NULL,
                         mod2, mod2.values = NULL, mod2.labels = NULL,
                         mod3, mod3.values = NULL, mod3.labels = NULL) {

  d = get_data(model, warn = TRUE)

  split_int_data <- function(d, modx, mod2, mod3,
                             modx.values,modxvals2, facmod,
                             mod2.values, mod2vals2, facmod2,
                             mod3.values, mod3vals2, facmod3) {

    # For numeric, non-binary moderators
    if (facmod == FALSE &
        !(length(unique(d[[modx]])) == 2 & length(modxvals2) == 2)) {

      # Use ecdf function to get quantile of the modxvals
      mod_val_qs <- ecdf(d[[modx]])(sort(modxvals2))

      # Now I am going to split the data in a way that roughly puts each modxval
      # in the middle of each group. mod_val_qs is a vector of quantiles for each
      # modxval, so I will now build a vector of the midpoint between each
      # neighboring pair of quantiles — they will become the cutpoints for
      # splitting the data into groups that roughly correspond to the modxvals

      cut_points <- c() # empty vector

      # Iterate to allow this to work regardless of number of modxvals
      for (i in 1:(length(modxvals2) - 1)) {
        cut_points <- c(cut_points, mean(mod_val_qs[i:(i + 1)]))
      }

      # Add Inf to both ends to encompass all values outside the cut points
      cut_points <- c(-Inf, quantile(d[[modx]], cut_points, na.rm = TRUE), Inf)

      # Create variable storing this info as a factor
      d["modx_group"] <- cut(d[[modx]], cut_points,
                             labels = names(sort(modxvals2)))

      if (!is.null(modx.values) && modx.values[1] == "terciles") {
        d$modx_group <- factor(cut2(d[[modx]], g = 3, levels.mean = TRUE),
                               labels = c(paste("Lower tercile of", modx),
                                          paste("Middle tercile of", modx),
                                          paste("Upper tercile of", modx)))
      }

    } else {

      d["modx_group"] <- factor(d[[modx]], levels = modxvals2,
                                labels = names(modxvals2))

    }

    if (!is.null(mod2)) {
      if (facmod2 == FALSE &
          !(length(unique(d[[mod2]])) == 2 & length(mod2vals2) == 2)) {

        mod_val_qs <- ecdf(d[[mod2]])(sort(mod2vals2))


        cut_points2 <- c()
        for (i in 1:(length(mod2vals2) - 1)) {

          cut_points2 <- c(cut_points2, mean(mod_val_qs[i:(i + 1)]))

        }

        cut_points2 <- c(-Inf, quantile(d[[mod2]], cut_points2, na.rm = TRUE),
                         Inf)

        d["mod2_group"] <- cut(d[[mod2]], cut_points2,
                               labels = names(sort(mod2vals2)))

        if (!is.null(mod2.values) && mod2.values[1] == "terciles") {
          d$mod2_group <- factor(cut2(d[[mod2]], g = 3, levels.mean = TRUE),
                                 labels = c(paste("Lower tercile of", mod2),
                                            paste("Middle tercile of", mod2),
                                            paste("Upper tercile of", mod2)))
        }

      } else if (facmod2 == TRUE) {

        d["mod2_group"] <- factor(d[[mod2]], levels = mod2vals2,
                                  labels = names(mod2vals2))

      }
    }

    if (!is.null(mod3)) {
      if (facmod3 == FALSE &
          !(length(unique(d[[mod3]])) == 2 & length(mod3vals2) == 2)) {

        mod_val_qs <- ecdf(d[[mod3]])(sort(mod3vals2))


        cut_points3 <- c()
        for (i in 1:(length(mod3vals2) - 1)) {

          cut_points3 <- c(cut_points3, mean(mod_val_qs[i:(i + 1)]))

        }

        cut_points3 <- c(-Inf, quantile(d[[mod3]], cut_points3, na.rm = TRUE),
                         Inf)

        d["mod3_group"] <- cut(d[[mod3]], cut_points3,
                               labels = names(sort(mod3vals2)))

        if (!is.null(mod3.values) && mod3.values[1] == "terciles") {
          d$mod3_group <- factor(cut2(d[[mod3]], g = 3, levels.mean = TRUE),
                                 labels = c(paste("Lower tercile of", mod3),
                                            paste("Middle tercile of", mod3),
                                            paste("Upper tercile of", mod3)))
        }

      } else if (facmod3 == TRUE) {

        d["mod3_group"] <- factor(d[[mod3]], levels = mod3vals2,
                                  labels = names(mod3vals2))

      }
    }

    return(d)

  }

  drop_factor_levels <- function(d, var, values, labels) {
    # Need to save the rownames because of tibble's stupidity
    the_row_names <- rownames(d)
    the_row_names <- the_row_names[d[[var]] %in% values]
    d <- d[d[[var]] %in% values,]
    d[[var]] <- factor(d[[var]], levels = values)
    # Can't use rowname assignment method because of tibble's stupidity
    attr(d, "row.names") <- the_row_names
    return(d)

  }


  # Define prep_data
  prep_data = function(model, d,
                       pred, pred.values = NULL, pred.labels = NULL,
                       modx, modx.values = NULL, modx.labels = NULL,
                       mod2, mod2.values = NULL, mod2.labels = NULL,
                       mod3, mod3.values = NULL, mod3.labels = NULL,
                       facvars, centered = "all", force.cat = FALSE,
                       preds.per.level = 100, outcome.scale = "response", ...) {

    # We will now set facpred, facmod, facmod2, and facmod3
    # These will be used to set values and colors

    # if predictor is not numeric
    if (!is.numeric(d[[pred]])) {
      # set facpred to true
      facpred <- TRUE
      # if predictor is character
      if (is.character(d[[pred]])) {
        # convert to factor
        d[[pred]] <- factor(d[[pred]])
      }
      # if not forcing numeric predictor into categorical
    } else if (force.cat == FALSE) {
      # set facpred to false
      facpred <- FALSE
      # if forcing numeric predictor into categorical
    } else {
      #set facpred to true
      facpred <- TRUE
    }

    # if modx is not null and modx is numeric
    if (!is.null(modx) && !is.numeric(d[[modx]])) {
      # set facmod to true
      facmod <- TRUE
      # if modx is character
      if (is.character(d[[modx]])) {
        # change modx to factor
        d[[modx]] <- factor(d[[modx]])
      }
      # if not forcing numeric predictor into categorical or modx is null
    } else if (force.cat == FALSE | is.null(modx)) {
      # set facmod to false
      facmod <- FALSE
      # if modx is numeric
    } else if (!is.null(modx)) {
      # set facmod to true
      facmod <- TRUE
    }

    # Treat binary numeric moderators as quasi-categorical
    if (!is.null(modx) && length(unique(d[[modx]])) == 2) {
      # if modx values not provided
      if (is.null(modx.values)) {
        # sort modx values and set as values
        modx.values <- sort(unique(d[[modx]]))
      }
    }

    # if mod2 is not null and modx is numeric
    if (!is.null(mod2) && !is.numeric(d[[mod2]])) {
      # set facmod2 to true
      facmod2 <- TRUE
      # if mod2 is character
      if (is.character(d[[mod2]])) {
        # change mod2 to factor
        d[[mod2]] <- factor(d[[mod2]])
      }
      # if not forcing numeric mod2 into categorical or mod2 is null
    } else if (force.cat == FALSE | is.null(mod2)) {
      # set facmod2 to false
      facmod2 <- FALSE
      # if forcing numeric mod2 into categorical
    } else if (!is.null(mod2)) {
      # set facmod2 to true
      facmod2 <- TRUE
    }

    # Treat binary numeric moderators as quasi-categorical
    if (!is.null(mod2) && length(unique(d[[mod2]])) == 2) {
      # if mod2 values not provided
      if (is.null(mod2.values)) {
        # sort mod2 and set values
        mod2.values <- sort(unique(d[[mod2]]))
      }
    }

    # if mod3 is not null and modx is numeric
    if (!is.null(mod3) && !is.numeric(d[[mod3]])) {
      # set facmod3 to true
      facmod3 <- TRUE
      # if mod3 is character
      if (is.character(d[[mod3]])) {
        # change to factor
        d[[mod3]] <- factor(d[[mod3]])
      }
      # if not forcing numeric mod3 to categorical or mod3 is null
    } else if (force.cat == FALSE | is.null(mod3)) {
      #set facmod3 to false
      facmod3 <- FALSE
      # if forcing numeric mod3 to categorical
    } else if (!is.null(mod3)) {
      #set facmod3 to true
      facmod3 <- TRUE
    }

    # Treat binary numeric moderators as quasi-categorical
    if (!is.null(mod3) && length(unique(d[[mod3]])) == 2) {
      # if mod3 values not provided
      if (is.null(mod3.values)) {
        #sort mod3 and set values
        mod3.values <- sort(unique(d[[mod3]]))
      }
    }

    # Get the formula from lm object if given
    formula <- get_formula(model)

    # Pulling the name of the response variable for labeling
    resp <- jtools::get_response_name(model)

    # Create a design object
    design <- NULL

    # Define check_interaction
    check_interactions = function(formula, vars) {
      vars <- vars[!is.null(vars)]

      # Define any_interaction
      any_interaction = function(formula) {
        any(attr(terms(formula), "order") > 1)
      }

      # Define get_interactions
      get_interactions = function(formula) {
        if (any_interaction(formula)) {
          ts <- terms(formula)
          labs <- paste("~", attr(ts, "term.labels"))
          forms <- lapply(labs, as.formula)
          forms <- forms[which(attr(ts, "order") > 1)]
          ints <- lapply(forms, all.vars)
          names(ints) <- attr(ts, "term.labels")[which(attr(ts, "order") > 1)]
          return(ints)
        } else {
          NULL
        }
      }

      if (any_interaction(formula)) {
        checks <- sapply(get_interactions(formula), function(x, vars) {
          if (all(vars %in% x)) TRUE else FALSE
        }, vars = vars)
        any(checks)
      } else {
        FALSE
      }
    }

    # Warn user if interaction term is absent
    if (!check_interactions(formula, c(pred, modx, mod2, mod3))) {
      warn_wrap(paste(c(pred, modx, mod2, mod3), collapse = " and "),
                " are not included in an interaction with one another in the
              model.")
    }

    ### Getting moderator values ##################################################

    ### Define mod_vals
    mod_vals = function(d, modx, modx.values, modx.labels = NULL,
                        design = design,
                        any.mod2 = FALSE, is.mod2 = FALSE,
                        any.mod3 = FALSE, is.mod3 = FALSE,
                        force.cat = FALSE, add.varname = TRUE) {

      # Get moderator mean
      if (is.numeric(d[[modx]])) {
        weights <- rep(1, nrow(d))
        modmean <- weighted.mean(d[[modx]], weights, na.rm = TRUE)
        modsd <- wtd.sd(d[[modx]], weights)
      }

      # set is_fac to true if modx is not numeric or we are forcing categorization
      is_fac <- if (!is.numeric(d[[modx]]) | force.cat == TRUE) TRUE else FALSE

      # Testing whether modx.values refers to pre-defined arg or list of factor levels
      predefined_args <- c("mean-plus-minus", "plus-minus", "terciles")

      if (is.character(modx.values) & length(modx.values) == 1) {
        char1 <- if (modx.values %in% predefined_args) TRUE else FALSE
        if (is_fac == TRUE & char1 == TRUE) {
          stop_wrap(modx.values, " is not supported for a non-numeric moderator.")
        } else if (is_fac == FALSE & char1 == FALSE) {
          stop_wrap(modx.values, " is not a valid ",
                    ifelse(is.mod2, yes = "mod2.values", no = "modx.values"),
                    " argument for a numeric moderator.")
        }
      } else {char1 <- FALSE}

      user_specified <- length(modx.values) > 1

      # If using a preset, send to auto_mod_vals function
      if (is_fac == FALSE && (is.null(modx.values) | is.character(modx.values))) {
        ## Gets the preset values, e.g., mean plus/minus 1 SD
        modxvals2 <- auto_mod_vals(d, modx.values = modx.values, modx = modx,
                                   modmean = modmean, modsd = modsd,
                                   modx.labels = modx.labels,
                                   mod2 = (is.mod2), add.varname = add.varname)

      }

      # For user-specified numbers or factors, go here
      if (is.null(modx.values) & is_fac == TRUE) {

        modxvals2 <- ulevels(d[[modx]])
        if (is.null(modx.labels)) {

          if ((is.mod2) & add.varname == TRUE) {
            modx.labels <- paste(modx, "=", ulevels(d[[modx]]))
          } else {
            modx.labels <- ulevels(d[[modx]])
          }

        }
        names(modxvals2) <- modx.labels

      } else if (!is.null(modx.values) & char1 == FALSE) {
        # Use user-supplied values otherwise

        if (!is.null(modx.labels)) {
          # What I'm doing here is preserving the label order
          names(modx.values) <- modx.labels
          if (!is.mod2 & !is.factor(d[[modx]])) {
            modxvals2 <- rev(modx.values)
          } else {
            modxvals2 <- modx.values
          }
          modx.labels <- names(modxvals2)

        } else {

          names(modx.values) <- if ((is.mod2) & add.varname == TRUE) {
            paste(modx, "=", modx.values)
          } else {
            modx.values
          }
          if (!is.mod2 & !is.factor(d[[modx]])) {
            modxvals2 <- rev(modx.values)
          } else {
            modxvals2 <- modx.values
          }
          modx.labels <- names(modxvals2)

        }

      }

      if (is.null(modx.labels)) {
        # Name the modx.labels object with modxvals2 names

        modx.labels <- if ((is.mod2) & add.varname == TRUE) {
          paste(modx, "=", modxvals2)
        } else {
          names(modxvals2)
        }

      }

      # Hacky way to have a shorthand to drop NA
      range2 <- function(...) {
        range(..., na.rm = TRUE)
      }
      if (is_fac == FALSE & user_specified == FALSE) {
        # The proper order for interact_plot depends on presence of second moderator
        modxvals2 <- sort(modxvals2, decreasing = (!any.mod2 | !any.mod3))
        if (any(modxvals2 > range2(d[[modx]])[2])) {
          warn_wrap(paste(modxvals2[which(modxvals2 > range2(d[[modx]])[2])],
                          collapse = " and "), " is outside the observed range of ",
                    modx)
        }
        if (any(modxvals2 < range2(d[[modx]])[1])) {
          warn_wrap(paste(modxvals2[which(modxvals2 < range2(d[[modx]])[1])],
                          collapse = " and "), " is outside the observed range of ",
                    modx)
        }
      }

      return(modxvals2)

    }
    ### Define auto_mod_vals
    auto_mod_vals = function(d, modx, modx.values, modmean, modsd, modx.labels = NULL,
                             mod2 = FALSE, add.varname = TRUE) {

      # Default to +/- 1 SD unless modx is factor
      if ((is.null(modx.values) || modx.values == "mean-plus-minus") &
          length(unique(d[[modx]])) > 2) {

        modxvals2 <- c(modmean - modsd,
                       modmean,
                       modmean + modsd)
        if (mod2 == FALSE) {
          names(modxvals2) <- c("- 1 SD", "Mean", "+ 1 SD")
        } else {
          names(modxvals2) <- c(paste("Mean of", modx, "- 1 SD"),
                                paste("Mean of", modx),
                                paste("Mean of", modx, "+ 1 SD"))
        }

      } else if (!is.null(modx.values) && modx.values[1] == "plus-minus") { # No mean

        modxvals2 <- c(modmean - modsd, modmean + modsd)
        if (mod2 == FALSE) {
          names(modxvals2) <- c("- 1 SD", "+ 1 SD")
        } else {
          names(modxvals2) <- c(paste("Mean of", modx, "- 1 SD"),
                                paste("Mean of", modx, "+ 1 SD"))
        }

      } else if (!is.null(modx.values) && modx.values[1] == "terciles") {

        x_or_2 <- switch(as.character(mod2),
                         "TRUE" = "2",
                         "FALSE" = "x")
        group_name <- paste0("mod", x_or_2)
        d[[group_name]] <- cut2(d[[modx]], g = 3, levels.median = TRUE)
        modxvals2 <- as.numeric(levels(d[[group_name]]))
        msg_wrap("Medians of each tercile of ", modx, " are ",
                 paste(modxvals2, collapse = ", "))

        if (mod2 == FALSE) {
          names(modxvals2) <- c("Lower tercile median", "Middle tercile median",
                                "Upper tercile median")
        } else {
          names(modxvals2) <- c(paste("Lower tercile of", modx),
                                paste("Middle tercile of", modx),
                                paste("Upper tercile of", modx))
        }

      } else if (is.null(modx.values) & length(unique(d[[modx]])) == 2) {

        modxvals2 <- as.numeric(levels(factor(d[[modx]])))
        if (!is.null(modx.labels)) {

          names(modxvals2) <- modx.labels

        } else {

          if (mod2 == TRUE & add.varname == TRUE) {
            names(modxvals2) <-
              sapply(modxvals2, FUN = function(x) {paste(modx, "=", round(x,3))})
          } else {
            names(modxvals2) <- modxvals2
          }

        }

      }

      if (!is.null(modx.labels)) {
        if (length(modx.labels) == length(modxvals2)) {
          names(modxvals2) <- modx.labels
        } else {
          warn_wrap("modx.labels or mod2.labels argument is not the same length
                  as the number of moderator values used. It will be ignored.")
        }
      }

      return(modxvals2)

    }

    if (facpred == TRUE) {
      # get values for predictor
      pred.values <- mod_vals(d = d, modx = pred, modx.values = pred.values, modx.labels = pred.labels,
                              design = design, is.mod2 = TRUE, add.varname = FALSE)
      # get labels for predictor
      pred.labels <- names(pred.values)

    }

    # if modx is not null
    if (!is.null(modx)) {
      # get values for modx
      modxvals2 <- mod_vals(d = d, modx = modx, modx.values = modx.values, modx.labels = modx.labels,
                            design = design, any.mod2 = !is.null(mod2), any.mod3 = !is.null(mod3), force.cat = force.cat)
      # get labels for modx
      modx.labels <- names(modxvals2)
    } else {
      modxvals2 <- NULL
    }

    # if mod2 is not null
    if (!is.null(mod2)) {
      # get values for mod2
      mod2vals2 <- mod_vals(d = d, modx = mod2, modx.values = mod2.values, modx.labels = mod2.labels,
                            design = design, any.mod2 = !is.null(mod2), any.mod3 = !is.null(mod3),
                            is.mod2 = TRUE, force.cat = force.cat)
      #get labels for mod2
      mod2.labels <- names(mod2vals2)
    } else {
      mod2vals2 <- NULL
    }

    # if mod3 is not null
    if (!is.null(mod3)) {
      # get values for mod3
      mod3vals2 <- mod_vals(d = d, modx = mod3, modx.values = mod3.values, modx.labels = mod3.labels,
                            design = design, any.mod2 = !is.null(mod3), any.mod3 = !is.null(mod3),
                            is.mod2 = FALSE, is.mod3 = TRUE, force.cat = force.cat)
      # get labels for mod3
      mod3.labels <- names(mod3vals2)
    } else {
      mod3vals2 <- NULL
    }

    ### Drop unwanted factor levels ###############################################


    if (facpred == TRUE && !is.numeric(d[[pred]])) {

      d <- drop_factor_levels(d = d, var = pred, values = pred.values,
                              labels = pred.labels)

    }

    if (facmod == TRUE && !is.numeric(d[[modx]])) {

      d <- drop_factor_levels(d = d, var = modx, values = modxvals2,
                              labels = modx.labels)

    }

    if (facmod2 == TRUE && !is.numeric(d[[mod2]])) {

      d <- drop_factor_levels(d = d, var = mod2, values = mod2vals2,
                              labels = mod2.labels)

    }

    if (facmod3 == TRUE && !is.numeric(d[[mod3]])) {

      d <- drop_factor_levels(d = d, var = mod3, values = mod3vals2,
                              labels = mod3.labels)

    }

    #### Creating predicted frame #################################################

    if (facpred == TRUE) {
      pred.predicted <- levels(factor(d[[pred]]))
    } else {
      pred.predicted <- seq(from = min(d[[pred]], na.rm = TRUE),
                            to = max(d[[pred]], na.rm = TRUE),
                            length.out = preds.per.level)
    }

    if (!is.null(modx)) {
      num_combos <- length(modxvals2)
      combos <- expand.grid(modxvals2)
      names(combos) <- modx
    } else {
      num_combos <- 1
    }
    if (!is.null(mod2)) {
      num_combos <- nrow(expand.grid(modxvals2, mod2vals2))
      combos <- expand.grid(modxvals2, mod2vals2)
      names(combos) <- c(modx, mod2)
    }
    if (!is.null(mod3)) {
      num_combos <- nrow(expand.grid(modxvals2, mod2vals2, mod3vals2))
      combos <- expand.grid(modxvals2, mod2vals2, mod3vals2)
      names(combos) <- c(modx, mod2, mod3)
    }

    pms <- list()

    at_list_full = list()
    for (i in seq_len(num_combos)) {

      at_list <- list()
      if (!is.null(modx)) {
        at_list[[modx]] <- combos[i, modx]
      }
      if (!is.null(mod2)) {
        at_list[[mod2]] <- combos[i, mod2]
      }
      if (!is.null(mod3)) {
        at_list[[mod3]] <- combos[i, mod3]
      }

      at_list_full[[i]] = at_list

      suppressMessages({
        pms[[i]] <- jtools::make_predictions(
          model = model, data = d, pred = pred, pred.values = pred.predicted,
          at = at_list, center = centered,
          outcome.scale = outcome.scale)
      })
      # only looking for completeness in these variables
      check_vars <- all.vars(get_formula(model)) %just% names(pms[[i]])
      pms[[i]] <-
        pms[[i]][complete.cases(pms[[i]][check_vars]), ]
    }

    pm <- do.call("rbind", pms)


    ## Prep original data for splitting into groups ##
    if (!is.null(modx)) {
      d <- split_int_data(d = d, modx = modx, mod2 = mod2, mod3 = mod3,
                          modx.values = modx.values, modxvals2 = modxvals2,
                          mod2.values = mod2.values, mod2vals2 = mod2vals2,
                          mod3.values = mod3.values, mod3vals2 = mod3vals2,
                          facmod = facmod, facmod2 = facmod2, facmod3 = facmod3)
    }

    # Labels for values of moderator
    if (!is.null(modx) && !is.numeric(d[[modx]])) {
      pm[[modx]] <- factor(pm[[modx]], levels = modxvals2, labels = modx.labels)
    }
    if (facmod == TRUE) {
      d[[modx]] <- factor(d[[modx]], levels = modxvals2, labels = modx.labels)
    }
    if (!is.null(modx)) {
      if (is.numeric(d[[modx]])) {
        pm$modx_group <- factor(pm[[modx]], levels = modxvals2,
                                labels = modx.labels)
      } else {
        pm$modx_group <- factor(pm[[modx]], levels = modx.labels)
      }
    }

    # Setting labels for second moderator
    if (!is.null(mod2)) {

      # Convert character moderators to factor
      if (!is.numeric(d[[mod2]])) {
        d[[mod2]] <- factor(d[[mod2]], levels = mod2vals2, labels = mod2.labels)
        pm[[mod2]] <- factor(pm[[mod2]], levels = mod2vals2, labels = mod2.labels)
        pm$mod2_group <- pm[[mod2]]
      } else {
        pm$mod2_group <- factor(pm[[mod2]], levels = mod2vals2,
                                labels = mod2.labels)
      }

    }

    # Setting labels for third moderator
    if (!is.null(mod3)) {

      # Convert character moderators to factor
      if (!is.numeric(d[[mod3]])) {
        d[[mod3]] <- factor(d[[mod3]], levels = mod3vals2, labels = mod3.labels)
        pm[[mod3]] <- factor(pm[[mod3]], levels = mod3vals2, labels = mod3.labels)
        pm$mod3_group <- pm[[mod3]]
      } else {
        pm$mod3_group <- factor(pm[[mod3]], levels = mod3vals2,
                                labels = mod3.labels)
      }

    }

    # Dealing with transformations of the dependent variable
    # Have to make sure not to confuse situations with brmsfit objects and distributional DVs
    if (resp %nin% names(d) & "dpar" %nin% names(list(...))) {
      trans_name <- as.character(deparse(formula[[2]]))
      d[[trans_name]] <- eval(formula[[2]], d)
    }

    out <- list(predicted = pm, original = d, at = at_list_full)
    return(out)

  }

  prepped = prep_data(model = model, d = d,
                      pred = pred,
                      modx = modx, modx.values = modx.values, modx.labels = modx.labels,
                      mod2 = mod2, mod2.values = mod2.values, mod2.labels = mod2.labels,
                      mod3 = mod3, mod3.values = mod3.values, mod3.labels = mod3.labels)

  return(prepped)
}



