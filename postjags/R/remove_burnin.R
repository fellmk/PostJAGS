###############################################################################
# A simple function to remove the burn in or subset an mcmc.list.
#
# Written on January 5, 2018 by Michael K. Fell. 
# email: michael.fell@nau.edu
###############################################################################

#' A function to remove burnin
#'
#' @param mcmcdata An mcmc object.
#' @param start The iteration to start on.
#' @param end The iteration to stop at defaults to the final iteration.
#' mcmc.subset()
#' @export

mcmc.subset <- function(mcmcdata, start=1, end=0) {
test <- list()

require(coda)
require(mcmc)

if(exists("mcmcdata")==FALSE){
	stop("mcmcdata must be defined and contain an mcmc.list")
}

if(!is.mcmc.list(mcmcdata)){
	stop("mcmcdata must be an mcmclist see package coda")
}

codal <- length(mcmcdata[[1]][,1])
if(end != 0){
	if(end > codal){
		print("warning end exceeds the length of your mcmc.list")
		end <- codal
	}else{
		codal <- end
	}
}else if(end < 0){
	stop("end must be 0 (default) or greater than 0")
}

if(start < 1){
	stop("start must be equal to 1 (default) or greater")
}

for(i in 1:length(mcmcdata)){
	test[[i]] <- mcmc(mcmcdata[[i]][start:codal,])
}
test <- as.mcmc.list(test)
return(test)
}


