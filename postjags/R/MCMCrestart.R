###############################################################################
#
# A function to extract values from a given iteration for each chain in an MCMC
# object.  The main use of this function is to extract the final state of a 
# model for use in initializing the model for further update.
#
# Written by Michael Fell on Monday, May 8, 2017
#
# Version 2 Wednesday, June 14, 2017
#
# Version 2 changes:
# - Updated to handle n-dimensional arrays
#
# Version 2_2 changes:
# 	Added an option for OpenBUGS that deals with 1D arrays.
#	Added on May 14, 2018
#
# Version 2_3 changes:
#   An issue with restarting OpenBUGS code was fixed by adding a for loop for
#	each chain in the OpenBUGS = TRUE section. This was added by Jessica Guo
#	on May 25, 2018.
#
# Some instructions:
###############################################################################
# # Double comment marks (# #) indicate a comment, one comment mark (#) 
# # indicates code.
# # Call:
# Source(“MCMCrestart_v2.r”) # Load the functions
# newinits <-  Initfind(MCMCoutput) # Run the function to find initials
# newinits$variables # list the variables for which values were obtained.
#
# # Some variables may not need initials and cause JAGS to give a warning:
# # 	Error in setParameters(init.values[[i]], i) : Error in node NH4total[1]
# #		Cannot set value of non-variable node
# # The following function removes this type of error by removing the variables
# # The values in variables (i.e. 2,3,4,5,6,7) will be removed.
# newinits <- removevars(initsin = newinits, variables=c(2,3,4,5,6,7))
# inits <- newinits[[2]] # USE THIS IN YOUR MODEL. 
#
# # The final line setting the value of “inits” is what goes into the JAGS
# # model to start from the
# # final values for the last model run. 
###############################################################################

#' A function to find initial values for a JAGS or OpenBUGS model.
#'
#' @param mcmcin - an mcmc object or list.
#' @param iteration - the iteration to pull values from, defaults to the final iteration.
#' @param OpenBUGS - Are the initials for OpenBUGS? Defaults to FALSE.
#' 
#' Output:
#' The output from this function is a list containing two elements. The first
#' contains the names of the variables and their indicies. These are useful 
#' when using removevars to remove variables that don't need initial values
#' in JAGS. The second element contains a list of initial values (this is a 
#' list of lists).

initfind <- function(mcmcin, iteration=0, OpenBUGS=FALSE){
	# If mcmc.list convert to mcmc
	if(is.mcmc.list(mcmcin)==TRUE){
		mcmcin <- mcmc(data=mcmcin, thin=1)
	}
	
	# Get the number of chains
	n.chains <- length(mcmcin)
	
	# get variable names from a list
	var.names <- colnames(mcmcin[[1]])
	var.dims <- dim(mcmcin[[1]])
	if(iteration==0){
		iteration <- var.dims[1]
	}
	
	if(sum(var.names=="deviance")>0){
		var.names <- var.names[-which(var.names=="deviance")]
		var.dims[2] <- var.dims[2]-1 # correct for removing deviance
	}
	
	# Get names and dimension of each variable since the output is a table
	var.names2 <- apply(X=as.matrix(var.names), MARGIN=c(1), FUN=strsplit, split="\\x5B", perl=TRUE)
    var.names2 <- lapply(X=var.names2, FUN=unlist)
    var.names2 <- lapply(X=var.names2, FUN=gsub, pattern="\\x5D", replacement="", perl=TRUE)
	
    # Create a table of names and dimensions
    # Column 1 is the variable me column 2 has the dimensions
	var.info <- matrix(nrow=length(var.names), ncol=3)
  for(i in 1:length(var.names2)){
    if(length(var.names2[[i]]) > 1){
      var.info[i,] <- c(var.names2[[i]], var.names[i])
    }else if(length(var.names2[[i]]) == 1){
      var.info[i,] <- c(var.names2[[i]], 1, var.names[i])
      #print(i)
      #print(var.names2[[i]])
    }else{
      stop("A variable name has incorrect dimensions for parsing.") 
    }
  }

	# Get variable names
	unique.names <- unique(var.info[,1])
	initsoutall <- list()
	
	
	for(k in 1:n.chains){
	  initsout <- list()
  	for(i in 1:length(unique.names)){
  	  sel <- which(var.info[,1]==unique.names[i])
  	  #sel2 <- grep(pattern=paste0("^",unique.names[i],"\\x5B"), x=var.names)
  	  
  	  # Make sure the above selections worked
  	  #if(length(sel) != length(sel2)){
  	  #  stop("Error matching unique variable names with MCMC output")  
  	  #}
  	  name.sel <- var.info[sel,3]
  	  index <- apply(X=as.matrix(var.info[sel,2]), MARGIN=1, FUN=strsplit, split=",", perl=TRUE)
  	  index <- lapply(X=index, FUN=unlist)
  	  index <- matrix(data=as.numeric(unlist(index)), nrow=length(index), ncol=length(index[[1]]), byrow=TRUE)
  	  
  	  # There are possibly easier ways to do this but they make more assumptions
  	  dims <- as.numeric(apply(X=index, MARGIN=2, FUN=max))
  	  variable <- array(data=NA, dim=dims)
  	  
  	  # Fill the new variable with the correct values
  	  for(j in 1:dim(index)[1]){
  	    # The output into mcmc objects lists names in the order R stacks them
  	    # in arrays so the single index for the variable references the 
  	    # correct array location.
  	    variable[j] <- mcmcin[[k]][iteration, which(colnames(mcmcin[[k]])==name.sel[j])]
  	  }
  	  
  	  # Use dims to produce a new array to store the data
  	  initsout[[i]] <- variable
  	} # End of variable loop
	  names(initsout) <- unique.names
	  initsoutall[[k]] <- initsout
	} # End of chain loop
	
	listout <- list(unique.names, initsoutall)
	names(listout) <- c("variables", "initials")
	
	# Account for OpenBUGS by outputing 1 dimensional arrays as vectors.
	if(OpenBUGS==TRUE){
	  for(i in 1:n.chains){
	    for(j in 1:length(listout[[2]][[i]])){
	      if(length(dim(listout[[2]][[i]][[j]]))==1){
	        listout[[2]][[i]][[j]] <- as.vector(listout[[2]][[i]][[j]])
	      }
	    }
	  }
	}
	
	return(listout)
} # End of function
	

###############################################################################
#
# Removes specific variables from the initial values
#
###############################################################################

#' A function to remove variables that don't need initial values in JAGS.
#'
#' @param initsin - The initial values from the initsfind function.
#' @param variables - The indexes of variables to be removed. Variables with 
#' indexes are available in the first list element from initsfind.

removevars <- function(initsin, variables){
  n.chains <- length(initsin[[2]])
  n.vars <- 1:length(initsin[[1]])
  n.vars <- n.vars[-variables]
  
  var.names <- initsin[[1]][n.vars]
  
  new.inits <- list()
  for(i in 1:n.chains){
    chain.inits <- list()
    for(k in 1:length(n.vars)){
      chain.inits[[k]] <- initsin[[2]][[i]][[n.vars[k]]] 
    } # End of k loop
    names(chain.inits) <- var.names
    new.inits[[i]] <- chain.inits
  } # End of i loop
  
  output <- list(var.names, new.inits)
  names(output) <- c("variables", "initials")
  
  return(output)
  
} # End of function




