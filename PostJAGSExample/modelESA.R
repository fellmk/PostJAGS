model{
	for(i in 1:N){
		
		# Likelihood for observed photosynthesis data
		Aobs[i] ~ dnorm(mu.A[i], tau.A)
		
		# mean for observed photosynthesis data is modeled as a 
		# rectangular hyperbola
		mu.A[i] <- (LUE * PAR[i] * Amax) / (LUE*PAR[i]+Amax) - Rd
		
		# Generate replicated data to help evaluate model fit
		# This can also be used to calculate posterior predictive loss
		# (D)
		Arep[i]~dnorm(mu.A[i], tau.A)
		Dsq[i] <- pow((Aobs[i]-Arep[i]),2)
	} # End of the i loop
	
	# Calculate posterior predictive loss
	D <- sum(Dsq[])
	
	# Provide Priors for parameters in the model.
	# Uninformative conjugate prior for tau.A
	tau.A ~ dgamma(0.0001,0.0001)
	# Uninformative Priors for LUE, Amax, and Rd
	LUE ~ dnorm(0, 0.001)
	Rd ~ dnorm(0, 0.001)
	Amax ~ dnorm(0, 0.001)
	
}