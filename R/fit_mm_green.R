#' Fit a mixture of two Gaussians to fluorescence intensities of groups of data from flow cytometry
#'
#' @param df Dataframe or dataframe subset with a column 'total.green' containing data to be fit
#' @param ouput Options are "classification", "posterior", "full"; default is "classification"
#' @export
#' @return a classified dataset ("classification", default), a dataset with the posteriors added as columns ("posterior"), or a dataset with posteriors and information about the mixtures ("full")

fit_mm_green <- function(df, output = "classification") {
  mdl <- normalmixEM(df$total.green, 2)
  df <- tibble::rowid_to_column(df, "ID")
  
  if (output == "full"){
    df.w.posterior <- data.frame(total.green = mdl$x, mdl$posterior, ID = df$ID) %>%
      mutate(lambda.1 = mdl$lambda[1],
             lambda.2 = mdl$lambda[2],
             mu.1 = mdl$mu[1],
             mu.2 = mdl$mu[2],
             sigma.1 = mdl$sigma[1],
             sigma.2 = mdl$sigma[2], loglik = mdl$loglik) %>%
      full_join(., df, by = c("total.green", "ID"))
    
  } else if (output == "posterior") {
    df.w.posterior <- data.frame(total.green = mdl$x, mdl$posterior, ID = df$ID) %>%
      full_join(., df, by = c("total.green", "ID"))
    
  } else if (output == "classification") {
    if (mdl$mu[1] > mdl$mu[2]) {
      #print(paste(mdl$mu[1], mdl$mu[2], "one greater than 2", sep = " "))
      df.w.posterior <- data.frame(total.green = mdl$x, mdl$posterior, ID = df$ID) %>%
        full_join(., df, by = c("total.green", "ID")) %>%
        mutate(green.classification = factor(ifelse(comp.1 > 0.5, "high", "low"), levels = c("low", "high")))
      
    } else {
      #print(paste(mdl$mu[1], mdl$mu[2], "two greater than 1", spe = " "))
      df.w.posterior <- data.frame(total.green = mdl$x, mdl$posterior, ID = df$ID) %>%
        full_join(., df, by = c("total.green", "ID")) %>%
        mutate(green.classification = factor(ifelse(comp.2 > 0.5, "high", "low"), levels = c("low", "high")))
    }
    
    
  }
}