###################################### Example ######################################
# interact_plot_4way(s2_mod1, 
#                    pred = "Feedback",
#                    modx = "agency_contrast", modx.values = c(-0.5, 0.5), modx.labels = c("AI", "Human"),
#                    mod2 = "status_contrast", mod2.values = c(-0.5, 0.5), mod2.labels = c("Low status", "High status"), mod2.reorder = c(0.5, -0.5),
#                    mod3 = "generosity_contrast1", mod3.values = c(-0.5, 0, 0.5), mod3.labels = c("Greedy", "Neutral", "Generous"))

# model is lm or lmer object
# pred will go on x axis
# modx will be used to color the lines
# mod2 and mod3 will be used to facet
####################################### Code #######################################

interact_plot_4way = function(model, pred, pred.values = NULL, pred.labels = NULL, pred.categorical = NULL, pred.reorder = NULL,
                              modx, modx.values = NULL, modx.labels = NULL, modx.categorical = NULL, modx.reorder = NULL,
                              mod2, mod2.values = NULL, mod2.labels = NULL, mod2.categorical = NULL, mod2.filter = NULL, mod2.reorder = NULL,
                              mod3, mod3.values = NULL, mod3.labels = NULL, mod3.categorical = NULL, mod3.filter = NULL, mod3.reorder = NULL,
                              colors = NULL, linetype = NULL, x.label = NULL, y.label = NULL, main.title = NULL, legend.main = NULL,
                              line.thickness = 1, point.size = 1.5, point.shape = FALSE, jitter = 0, point.alpha = 0.6) {
  library(tidyverse)
  library(jtools)
  source("~/Dropbox/UDel_Mturk_TrustGame/analysis/NewFunctions/predicted_out.R")
  
  d = get_data(model, warn = TRUE)
  resp = jtools::get_response_name(model)
  max_resp = max(d[[resp]])
  max_pred = max(d[[pred]])
  
  pred_out = predicted_out(model = model, pred = pred,
                           modx = modx, modx.values = modx.values, modx.labels = modx.labels,
                           mod2 = mod2, mod2.values = mod2.values, mod2.labels = mod2.labels,
                           mod3 = mod3, mod3.values = mod3.values, mod3.labels = mod3.labels)
  
  # Predicted dataset
  predicted = pred_out$predicted
  
  # Labels for plot
  if (is.null(modx.labels)) {
    if (!is.null(modx.categorical)) {
      if (modx.categorical == TRUE) {
        d[[modx]] = as.factor(d[[modx]])
        modx.labs = levels(d[[modx]])
        names(modx.labs) = unique(na.omit(as.numeric(as.character(d[[modx]]))))
      } else {
        mean = mean(d[[modx]])
        sd_minus = mean(d[[modx]]) - (2*(sd(d[[modx]])))
        sd_plus = mean(d[[modx]]) + (2*(sd(d[[modx]])))
        modx.labs = c("-2 SD", "mean", "+2 SD")
        names(modx.labs) = c(sd_minus, mean, sd_plus)
      }
    } else {
      mean = mean(d[[modx]])
      sd_minus = mean(d[[modx]]) - (2*(sd(d[[modx]])))
      sd_plus = mean(d[[modx]]) + (2*(sd(d[[modx]])))
      modx.labs = c("-2 SD", "mean", "+2 SD")
      names(modx.labs) = c(sd_minus, mean, sd_plus)
    }
  } else {
    modx.labs = modx.values
    names(modx.labs) = modx.labels
  }
  
  if (is.null(mod2.labels)) {
    if (!is.null(mod2.categorical)) {
      if (mod2.categorical == TRUE) {
        d[[mod2]] = as.factor(d[[mod2]])
        mod2.labs = levels(d[[mod2]])
        names(mod2.labs) = unique(na.omit(as.numeric(as.character(d[[mod2]]))))
      } else {
        mean = mean(d[[mod2]])
        sd_minus = mean(d[[mod2]]) - (2*(sd(d[[mod2]])))
        sd_plus = mean(d[[mod2]]) + (2*(sd(d[[mod2]])))
        mod2.labs = c("-2 SD", "mean", "+2 SD")
        names(mod2.labs) = c(sd_minus, mean, sd_plus)
      }
    } else {
      mean = mean(d[[mod2]])
      sd_minus = mean(d[[mod2]]) - (2*(sd(d[[mod2]])))
      sd_plus = mean(d[[mod2]]) + (2*(sd(d[[mod2]])))
      mod2.labs = c("-2 SD", "mean", "+2 SD")
      names(mod2.labs) = c(sd_minus, mean, sd_plus)
    }
  } else {
    if (!is.null(mod2.reorder)) {
      mod2.labs = mod2.labels
      names(mod2.labs) = mod2.reorder
    } else {
      mod2.labs = mod2.labels
      names(mod2.labs) = mod2.values
    }
  }
  
  if (is.null(mod3.labels)) {
    if (!is.null(mod3.categorical)) {
      if (mod3.categorical == TRUE) {
        d[[mod3]] = as.factor(d[[mod3]])
        mod3.labs = levels(d[[mod3]])
        names(mod3.labs) = unique(na.omit(as.numeric(as.character(d[[mod3]]))))
      } else {
        mean = mean(d[[mod3]])
        sd_minus = mean(d[[mod3]]) - (2*(sd(d[[mod3]])))
        sd_plus = mean(d[[mod3]]) + (2*(sd(d[[mod3]])))
        mod3.labs = c("-2 SD", "mean", "+2 SD")
        names(mod3.labs) = c(sd_minus, mean, sd_plus)
      }
    } else {
      mean = mean(d[[mod3]])
      sd_minus = mean(d[[mod3]]) - (2*(sd(d[[mod3]])))
      sd_plus = mean(d[[mod3]]) + (2*(sd(d[[mod3]])))
      mod3.labs = c("-2 SD", "mean", "+2 SD")
      names(mod3.labs) = c(sd_minus, mean, sd_plus)
    }
  } else {
    mod3.labs = mod3.labels 
    names(mod3.labs) = mod3.values
  }
  
  # Manually set linetypes
  types = c("solid", "4242", "2222", "dotdash", "dotted", "twodash",
             "12223242", "F282", "F4448444", "224282F2", "F1")
  ltypes = types[seq_along(modx.values)]
  
  # Reverse the order of the linetypes to make thick line go to biggest value
  if (is.numeric(modx.values) & all(sort(modx.values) == modx.values)) {
    ltypes <- rev(ltypes)
  } else if (!is.null(mod2) & !(is.numeric(modx.values) & !all(sort(modx.values) == modx.values))) { # also flip for factor second moderators
    ltypes <- rev(ltypes)
  }
  
  names(ltypes) = modx.values
  
  # GGPLOT
  # Filter df
  if (is.null(mod2.filter) && is.null(mod3.filter)) {
    plot = predicted %>% 
      filter(predicted[[resp]] <= max_resp, predicted[[pred]] <= max_pred)
  } else if (!is.null(mod2.filter) && is.null(mod3.filter)) {
    # Isolate by row
    plot = predicted %>% 
      filter(predicted[[resp]] <= max_resp, predicted[[pred]] <= max_pred, predicted[[mod2]] == mod2.filter)
  } else {
    # Isolate by column
    plot = predicted %>% 
      filter(predicted[[resp]] <= max_resp, predicted[[pred]] <= max_pred, predicted[[mod3]] == mod3.filter)
  }
  
  # Make sure variables are of the class we need
  if (modx.categorical == TRUE) {
    plot[[modx]] = as.factor(plot[[modx]])
  }
  
  # Make the variables into factors ordered per the input if requested
  if (!is.null(modx.reorder)) {
    plot[[modx]] = factor(plot[[modx]], levels=modx.reorder)
  }
  if (!is.null(mod2.reorder)) {
    plot[[mod2]] = factor(plot[[mod2]], levels=mod2.reorder)
  }
  if (!is.null(mod3.reorder)) {
    plot[[mod3]] = factor(plot[[mod3]], levels=mod3.reorder)
  }
  
  # Set arguments for ggplot
  if (is.null(modx.categorical)) {
    limits = c(min(plot[[modx]]), max(plot[[modx]]))
  } else {
    limits = c(modx.values[1], modx.values[length(modx.values)])
  }
  
  
  if (is.factor(d[[modx]])) {
    if (is.null(colors)) {
      colors = "CUD Bright"
    }
  } else {
    if (is.null(colors)) {
      colors = "blue"
    }
  }
  
  names(colors) = modx.values
  
  if (is.null(legend.main)) {
    legend.main = as.character(modx)
  }
  
  facet.form = paste0(mod2, " ~ ", mod3)
  pred = sym(pred)
  resp = sym(resp)
  if (!is.null(modx)) {modx = sym(modx)}
  if (!is.null(mod2)) {mod2 = sym(mod2)}
  if (!is.null(mod3)) {mod3 = sym(mod3)}
  
  p = ggplot(plot, aes(x= !! pred, y= !! resp, colour = !! modx, group = !! modx, linetype = !! modx))
  
  if (modx.categorical == TRUE) {
    p = p + 
      geom_smooth(aes(colour = !! modx, fill = !! modx, group = !! modx, linetype = !! modx), 
                  method = lm, inherit.aes = TRUE) +
      geom_ribbon(aes(ymin = !! sym('ymin'), ymax = !! sym('ymax'), fill = !! modx, linetype = NA), alpha = 0.2, inherit.aes = TRUE) +
      scale_colour_manual(name = legend.main, values = colors, breaks = modx.values, labels = modx.labels, aesthetics = c("colour", "fill")) +
      scale_linetype_manual(name = legend.main, values = ltypes, labels = modx.labels) +
      facet_grid(as.formula(facet.form), labeller=labeller(.rows = mod2.labs, .cols=mod3.labs)) +
      theme(legend.key.width = grid::unit(0.75, "cm")) +
      theme_bw() +
      papaja::theme_apa(base_size = 18, base_family = "", box = TRUE) +
      labs(title = main.title, x = x.label, y = y.label, 
           colour = legend.main, fill = legend.main, linetype = legend.main)
    
  } else {
    p = p + 
      geom_smooth(aes(colour = !! modx, fill = !! modx, group = !! modx, linetype = !! modx), 
                  method = lm, inherit.aes = TRUE) +
      geom_ribbon(aes(ymin = !! sym('ymin'), ymax = !! sym('ymax'), fill = !! modx, linetype = NA), alpha = 0.2, inherit.aes = TRUE) +
      scale_colour_gradientn(name = legend.main, breaks = modx.values, labels = modx.labs, colors = colors, limits = limits,
                             aesthetics = c("colour", "fill"), guide = "legend") +
      facet_grid(as.formula(facet.form), labeller = labeller(mod2 = mod2.labs, mod3 = mod3.labs)) +
      theme(legend.key.width = grid::unit(0.75, "cm")) +
      theme_bw() +
      papaja::theme_apa(base_size = 18, base_family = "", box = TRUE) +
      labs(title = main.title, x = x.label, y = y.label, 
           colour = legend.main, fill = legend.main, linetype = legend.main)
  }
  
  return(p)
}


