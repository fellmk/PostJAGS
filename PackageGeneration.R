###############################################################################
#
# Package to make the use of a few tools I have written for use with JAGS 
# easier.
#
# Written by Michael Fell, September 11, 2018.
# Based on code written at various times while working on projects for my 
# dissertation.
#
###############################################################################
install.packages("devtools")
library(devtools)
devtools::install_github("klutometis/roxygen")
library(roxygen2)

# Create the package directory
create("postjags")

wd <- getwd()
setwd("postjags/R")
document()
