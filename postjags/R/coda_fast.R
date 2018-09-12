###############################################################################
# Written for work on the Multicomp project
# Updated by Michael Fell 9/10/2018
#   Added an option for an arbitrary function
#   Added more informative error messages
###############################################################################
#' A function to find initial values for a JAGS or OpenBUGS model.
#'
#' @param chains - The number of chains
#' @param thin - The thinning interval. Defaults to 1 (no thinning).
#' @param coda - A coda object form a model run.
#' @param FUN - An optional function to run on the coda object. 
#' @param colname - A name or list of names for the output of the optional 
#' function.
#' @param ... - Optional parameters to FUN.
#' 
#' Output:
#' The output from this function is a list containing two elements. The first
#' contains the names of the variables and their indices. These are useful 
#' when using removevars to remove variables that don't need initial values
#' in JAGS. The second element contains a list of initial values (this is a 
#' list of lists).

coda.fast <- function(chains, thin=1, coda=NULL, FUN=NULL, colname = "optfun", ...){
  
    if(is.null(coda)){
        message("No coda object provided. Summarizing nothing is too philosophical")
        message("a task for this function.")
        stop()
    }
  
    codal <- length(coda[[1]][,1])

    # Combine chains
    Ftab <- numeric()
    for(i in 1:chains){
        Ftab <- rbind(Ftab, coda[[i]][(0:(codal-1))%%thin==0,])
    }

    # mean, sd, 95% CrI table
    pred <- matrix(nrow=dim(Ftab)[2], ncol=5)
    colnames(pred)<-c("mean", "median", "sd","pc2.5","pc97.5")

    # Fill table with stats
    pred[,1] <- colMeans(Ftab) #calculate predicted mean RW's
    pred[,2] <- apply(X=Ftab, MARGIN=2, FUN=median, na.rm=TRUE)
    pred[,3] <- apply(X=Ftab, MARGIN=2, FUN=sd,na.rm=TRUE) #calculate sd, apply column wise
    pred[,4] <- apply(X=Ftab, MARGIN=2, FUN=quantile,probs=c(0.025),na.rm=TRUE) 
    pred[,5] <- apply(X=Ftab, MARGIN=2, FUN=quantile,probs=c(0.975),na.rm=TRUE)
    
    pred <- data.frame(pred)
    if(length(rownames(pred)) == length(colnames(coda[[1]]))){
        rownames(pred) <- colnames(coda[[1]])
    }else{
        message("Could not determine row (variable) names from coda.")
    }
    
    # Optional Function
    if(!is.null(FUN))
    {
        placeholder <- tryCatch(
        {
            out <- apply(X=Ftab, MARGIN=2, FUN=FUN, na.rm=TRUE, ...)
            out <- as.matrix(out)
            if(ncol(out) == nrow(pred)){
                out <- t(out)
            }
           
            pred <- cbind(pred, out)
            colnames(pred) <- c("mean", "median", "sd","pc2.5","pc97.5", colname)
        },
        error=function(cond){
            message(paste0("A problem led to an error executing the optional function."))
            message("The result without the added function will be returned.")
            message("Here is the original error:")
            message(cond)
        },
        warning=function(cond){
            message("A warning occurred executing the optional function.")
            message("The result without the added function will be returned.")
            message("Here is the original warning:")
            message(cond)
        },
        finally={
            return(pred)
        }
        )
    }
  
    # Return the summary values
    return(pred)
}