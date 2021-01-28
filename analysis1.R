library(rstan)
library(HDInterval)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# d1 <- readRDS('./Data/firstny.rds')
# d2 <- readRDS('./Data/nyamp.rds')
# 
# phase.med <- apply(d1,2, median)
# phase.sd <- apply(d1,2, sd)
# 
# amp.med <- apply(d2,2,median)
# amp.sd <- apply(d2,2,sd)
# amp.prec <- 1/amp.sd^2
# 
# input.data.list <- list('phase.med'=phase.med,'phase.sd'=phase.sd,'amp.med'=amp.med, 'amp.sd'=amp.sd)
# saveRDS(input.data.list,'./Data/input_data.rds')
input.data.list <- readRDS('./Data/input_data.rds')

phase.med <- input.data.list$phase.med
phase.sd <- input.data.list$phase.sd
amp.med <- input.data.list$amp.med
amp.sd <- input.data.list$amp.sd

amp.med.scale <- (amp.med- mean(amp.med))/sd(amp.med)
amp.sd.scale <- (amp.sd- mean(amp.med))/sd(amp.med)

plot( log(amp.med),phase.med)

dat2 <- list('y'=phase.med,'x_meas'=amp.med,'tau'=amp.sd, 'N'=length(phase.med)) #save data in a list

fit1 <- stan(file = './model.stan', data = dat2)
print(fit1)
plot(fit1)
pairs(fit1, pars = c("alpha", "beta", "sigma", "lp__"))


la1 <- extract(fit1, permuted = TRUE) # return a list of arrays 

plot(la1$beta, type='l') #trace plot


x.post <- la1$x
x.hdi <- t(apply(x.post,2, hdi, credMass=0.95))
x.med <- apply(x.post,2, median)
x.hdi <- cbind.data.frame(x.med, x.hdi)

plot(x.hdi$x.med, phase.med)

plot( log(amp.med),log(x.hdi$x.med))
