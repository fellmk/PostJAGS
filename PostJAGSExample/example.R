###############################################################################
# for R2Bugs packages
###############################################################################

# load libraries and install if necessary
if("coda" %in% installed.packages()[,1] == FALSE){
	install.packages("coda", repos="https://cran.cnr.berkeley.edu/")
	library(coda)
} else{
	library(coda)
}
if("rjags" %in% installed.packages()[,1] == FALSE){
	install.packages("rjags", repos="https://cran.cnr.berkeley.edu/")
	library(rjags)
} else{
	library(rjags)
}
if("mcmc" %in% installed.packages()[,1] == FALSE){
	install.packages("mcmc", repos="https://cran.cnr.berkeley.edu/")
	library(mcmc)
} else{
	library(mcmc)
}
if("devtools" %in% installed.packages()[,1] == FALSE){
	install.packages("devtools", repos="https://cran.cnr.berkeley.edu/")
	library(devtools)
} else{
	library(devtools)
}
if("postjags" %in% installed.packages()[,1] == FALSE){
	devtools::install_github("fellmk/PostJAGS/postjags")
	library(postjags)
} else{
	library(postjags)
}


# load in data
datain <- read.csv("Light_Data.csv", header = T)
datause <- list(N = 210, Aobs = datain$Aobs, PAR = datain$PAR)

# load initials
source("ch1init.R")
source("ch2init.R")
source("ch3init.R")
# put initials into a list
inits <- list(inits1, inits2, inits3)

# set up model parameters
n.chains <- 3
n.iters = 10000
n.thin = 1
n.burnin = 5000
n.adapt = 5000

load.module("dic")
parameters <- c("Arep", "tau.A", "LUE", "Rd", "Amax", "deviance")
###############################################################################
# Non-hierarchical light model:
print("Starting Model Run")

lightmodel <- jags.model(file = "modelESA.R", data = datause, inits = inits, n.chains = n.chains, n.adapt = n.adapt)

runtime <- system.time(
{
  #update(lightmodel, n.iter=n.iters)
  codalight <- coda.samples(lightmodel,variable.names=parameters,
                       n.iter=n.iters, thin=n.thin)
}
)
codalightsave <- codalight

# Summarize Results
codanew <- list()
codalight <- as.mcmc.list(codalight)
for(i in 1:length(codalight)){
  codanew[[i]] <- cbind(codalight[[i]][,which(colnames(codalight[[1]])== "tau.A")],
                        codalight[[i]][,which(colnames(codalight[[1]])== "LUE")],
                        codalight[[i]][,which(colnames(codalight[[1]])== "Rd")],
                        codalight[[i]][,which(colnames(codalight[[1]])== "Amax")],
                        codalight[[i]][,which(colnames(codalight[[1]])== "deviance")]
  )
  colnames(codanew[[i]]) <- c("tau.A", "LUE", "Rd", "Amax", "deviance")
}
# Convert to mcmc objects
for(i in 1:length(codanew)){
  codanew[[i]] <- mcmc(codanew[[i]])
}
codanew <- as.mcmc.list(codanew)
# Gelman diagnostic
testsum <- coda.fast(chains=3, coda=codanew) 
test <- gelman.diag(x=codanew)

###############################################################################
# Get new inits for the model based on model output with PostJAGS
###############################################################################
newinits <- initfind(coda = codalight, iteration = 0)	#output is a list
newinits[[1]] # names of variables

# It may be necessary to remove a variable like Arep which is the 2nd list item
# NOTE: only the second item in the list is needed
newinits <- removevars(initsin = newinits, variables=c(2))
newinits <- newinits[[2]]

# Run the model with new initials
lightmodel <- jags.model(file = "modelESA.R", data = datause, inits = newinits, n.chains = n.chains, n.adapt = n.adapt)
# lightmodel <- jags.model(file = "modelESA.R", data = datause, inits = newinits[[1]], n.chains = 1, n.adapt = n.adapt)

runtime <- system.time(
  {
    #update(lightmodel, n.iter=n.iters)
    codalight <- coda.samples(lightmodel,variable.names=parameters,
                              n.iter=n.iters, thin=n.thin)
  }
)




