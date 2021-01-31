library(rstan)
library(HDInterval)
options(mc.cores = (parallel::detectCores()-1))
rstan_options(auto_write = TRUE)
set.seed(123)
N <- 1000

true.x <- rnorm(N,0, 1)
sd.x <- runif(N,0.1,4)
obs.err.x <- rnorm(N,rep(0, N),sd.x)
obs.x <- true.x + obs.err.x

true.y <- 2 + true.x*1.5
sd.y <- runif(N,0.1,4)
obs.err.y <- rnorm(N,rep(0, N),sd.y)
obs.y <- true.y + obs.err.y

plot(true.y, obs.x)
plot(obs.y, obs.x)

dat2 <- list('y_meas'=obs.y, 'y_meas_sd'=sd.y, 'x_meas'=obs.x,'tau'=sd.x, 'N'=N) #save data in a list
fit1 <- stan(file = './model.stan', data = dat2)

plot(fit1)
la1 <- extract(fit1, permuted = TRUE) # return a list of arrays 
plot(la1$beta, type='l') #trace plot

true.y.med <- t(apply(la1$true_y,2,median))
plot(true.y.med,true.y)
abline(a=0,b=1)

true.x.med <- t(apply(la1$x,2,median))

beta.hdi <- hdi(la1$beta, credMass = 0.95)
beta.median <- median(la1$beta)
beta.hdi
beta.median


alpha.hdi <- hdi(la1$alpha, credMass = 0.95)
alpha.hdi

plot(true.x.med,true.x)
abline(a=0,b=1)
