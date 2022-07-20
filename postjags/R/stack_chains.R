stack_chains <- function(coda1, coda2){
  
  if(is.mcmc.list(coda1)){
    coda1 <- mcmc(data=coda1, thin=1)
  }
  if(is.mcmc.list(coda2)){
    coda2 <- mcmc(data=coda2, thin=1)
  }
  
  # Check there are the same number of chains in each coda object.
  if(length(coda1) == length(coda2)){
    # Check that each chain has the same number of columns/variables
    if(ncol(coda1[[1]]) == ncol(mcmcin[[1]])){
      # Check that the names in each chain are the same.
      namesIdentical = identical(colnames(coda1[[1]]), colnames(coda2[[1]]))
      if(namesIdentical){
        mcmcout <- list()
        for(i in 1:length(coda1)){
          mcmcout[[i]] <- as.mcmc(rbind(coda1[[i]], coda2[[i]]))
        }
      }else{
        stop("All chains must have the same column names in the same order.")
      }
    }else{
      stop("All chains must have the same dimention, rows and columns.") 
    }
  }else{
    stop("All coda objects must have the same number of chains.")
  }
  
  mcmcout <- as.mcmc.list(mcmcout)
  return(mcmcout)
}