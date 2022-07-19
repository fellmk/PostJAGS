###############################################################################
# A simple function to remove the burn in or subset an mcmc.list.
#
# Written on July 15, 2022 by Michael K. Fell. 
# email: michael.fell@nau.edu
###############################################################################

cat.chains <- function(coda, iteration=0, OpenBUGS=FALSE){
  
  mcmcin <- coda # TODO change all mcmcin to coda in the future MKF 11/27/18
  # If mcmc.list convert to mcmc
  if(is.mcmc.list(mcmcin)==TRUE){
    mcmcin <- mcmc(data=mcmcin, thin=1)
  }
  
  
  
}