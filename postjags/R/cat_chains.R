###############################################################################
# A simple function to concatenate chains from different coda objects into a 
# single coda object with multiple chains.
#
# Written on July 15, 2022 by Michael K. Fell. 
# email: michael.fell@nau.edu
#
###############################################################################
#' A function to concatenate chains from two coda objects. The coda objects
#' must have chains with the same number of columns and the same length. The 
#' parameters in each chain must also match. 
#'
#' @param coda1 A coda object form a model run.
#' @param coda2 A coda object from a second model run.
#' @export

cat.chains <- function(coda1, coda2){
  # If mcmc.list convert to mcmc
  if(is.mcmc.list(coda1)){
    coda1 <- mcmc(data=coda1, thin=1)
  }
  if(is.mcmc.list(coda2)){
    coda2 <- mcmc(data=coda2, thin=1)
  }
  
  # Check that the chains are the same length before appending.
  if(ncol(coda1[[1]]) == ncol(coda2[[1]])){
    if(nrow(coda1[[1]]) == nrow(coda2[[1]])){
      namesIdentical = identical(colnames(coda1[[1]]), colnames(coda2[[1]]))
      if(namesIdentical){
        mcmcout <- append(coda1, coda2)
        mcmcout <- as.mcmc.list(mcmcout)
        return(mcmcout)
      }else{
        stop("All chains must have the same column names in the same order.")
      }
    }else{
      stop("The number of rows in chains within coda objects must match.")
    }
  }else{
    stop("The number of columns in chains within coda objects must match.")
  }
}