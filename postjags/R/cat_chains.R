###############################################################################
# A simple function to concatenate chains from different coda objects into a 
# single coda object with multiple chains.
#
# Written on July 15, 2022 by Michael K. Fell. 
# email: michael.fell@nau.edu
#
###############################################################################

cat.chains <- function(coda1, coda2){
  # If mcmc.list convert to mcmc
  if(is.mcmc.list(coda1)){
    coda1 <- mcmc(data=coda1, thin=1)
  }
  if(is.mcmc.list(coda2)){
    coda2 <- mcmc(data=coda2, thin=1)
  }
  
  mcmcout <- append(coda1, coda2)
  mcmcout <- as.mcmc.list(mcmcout)
  return(mcmcout)
}

## Test Code
# codalight
# codalightsave
# 
# coda1 <- mcmc(data=codalight, thin=1)
# coda2 <- mcmc(data=codalightsave, thin=1)
# 
# test <- stack_coda(coda1, coda2)
# test2 <- cat.chains(coda1, coda2)
# test3 <- stack_coda(test, test2)














