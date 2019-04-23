# PostJAGS
A few useful functions for working with JAGS output. The primary functionality of PostJAGS is to restart JAGS models with initial values based on previous coda output.

## Installation 
To install the package add the following code to your R script:

install.packages("devtools")\
library(devtools)\
devtools::install_github("fellmk/PostJAGS/postjags")\
library(postjags)

## Example
See the example in the PostJAGSExample folder for a demonstration of using the restart function. The example is in "example.R" which fits a basic light response curve. Make sure to set the directory the example is in as the current working directory in R or to copy the files to your current working directory. An understanding of JAGS is assumed. Lines 96-102 use PostJAGS to get new initial values. Using a coda object obtained from a past JAGS model run PostJAGS will find the final values in each chain:

```{r}
newinits <- initfind(coda = codalight, iteration = 0)	#output is a list
newinits[[1]] # names of variables
```

This block of code runs `initfind()` and regurns values that can be used to reinitialize the model. The output of `initfind()` is a list. The first element contains the names of variables found in the coda object. The second element contains a list of lists with each sublist containing initial values for a single chain. For example, `newinits[[2]][[1]]` above would contain the initial values for the first chain. The `iteration = 0` input is not necessary but may be good to be aware of. It allows values to be pulled from any iteration in the mcmc chains. The default value is 0 and specifies the final iteration in the chains.  

Not all variables need initial values in JAGS, and an error will occur if values are provided. The `removevars()` function takes a vector of variable indices and removes those variables from the initials. The positions of the variables (variable names) can be found by looking at the first element of the list output by `initfind()` as shown in the above code block. In the below code one variable is removed and then the new initial values are assigned to a variable. It would also be possible to use `newinits[[2]]` directly to restart the JAGS model.
```{r}
# It may be necessary to remove a variable like Arep which is the 2nd list item
# NOTE: only the second item in the list is needed
newinits <- removevars(initsin = newinits, variables=c(2))
newinits <- newinits[[2]]
```

After new initals are obtained they can be provide to the JAGS model just like any other initial values.
```{r}
# Run the model with new initials
lightmodel <- jags.model(file = "modelESA.R", data = datause, inits = newinits, n.chains = n.chains, 
                         n.adapt = n.adapt)
```
## Citation for PostJAGS  
Fell, Michael (2019). PostJAGS. Retrieeved from: https://github.com/fellmk/PostJAGS. https://doi.org/10.5281/zenodo.2648914  

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.2648914.svg)](https://doi.org/10.5281/zenodo.2648914)
