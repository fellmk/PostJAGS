###############################################################################
# A simple function to remove the burn in or subset an mcmc.list.
#
# Written on July 15, 2022 by Michael K. Fell. 
# email: michael.fell@nau.edu
#
# TODO: Add dimension checks to the function to make sure the variables
#       and lengths are the same. Provide an error if they are not.
#
###############################################################################

cat.chains <- function(coda1, coda2){
  
  mcmcin1 <- coda1 # TODO change all mcmcin to coda in the future MKF 11/27/18
  mcmcin2 <- coda2
  # If mcmc.list convert to mcmc
  if(is.mcmc.list(mcmcin1)==TRUE){
    mcmcin1 <- mcmc(data=mcmcin1, thin=1)
  }
  if(is.mcmc.list(mcmcin2)==TRUE){
    mcmcin2 <- mcmc(data=mcmcin2, thin=1)
  }
  
  mcmcout <- append(mcmcin1, mcmcin2)
  return(mcmcout)
}





stack_coda <- function(coda1, coda2){
  
  if(is.mcmc.list(mcmcin1)==TRUE){
    mcmcin1 <- mcmc(data=mcmcin1, thin=1)
  }
  if(is.mcmc.list(mcmcin2)==TRUE){
    mcmcin2 <- mcmc(data=mcmcin2, thin=1)
  }
  
  if(length(mcmcin1) == length(mcmcin2)){
    if(ncol(mcmcin1[[1]]) == ncol(mcmcin[[1]])){
      # TODO check columns are equal and then make sure the names of the columns
      # are the same in each mcmc object. 
      
      # TODO use mcmcout as the output object
      
    }else{
      stop("All chains must have the same dimention, rows and columns.") 
    }
  }else{
    stop("All coda objects must have the same number of chains.")
  }
  
  return(mcmcout)
  
}





## Test Code
codalight
codalightsave

mcmcin1 <- mcmc(data=codalight, thin=1)
mcmcin2 <- mcmc(data=codalightsave, thin=1)


dim(codalight[[1]])

