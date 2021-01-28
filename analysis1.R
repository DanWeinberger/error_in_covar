library(rstan)
library(HDInterval)
options(mc.cores = (parallel::detectCores()-1))
rstan_options(auto_write = TRUE)

 # d1 <- as.matrix(readRDS('./Data/firstny.rds'))
 # d2 <- as.matrix(readRDS('./Data/nyamp.rds'))
 # 
 # d2.log <- log(d2)
 # d2.log.scale <- (d2.log - mean(d2.log))/sd(d2.log)
 # 
 # phase.med <- apply(d1,2, median)
 # phase.sd <- apply(d1,2, sd)
 # 
 # amp.med <- apply(d2.log.scale,2,median)
 # amp.sd <- apply(d2.log.scale,2,sd)
 # amp.prec <- 1/amp.sd^2
 # 
 # input.data.list <- list('phase.med'=phase.med,'phase.sd'=phase.sd,'amp.med'=amp.med, 'amp.sd'=amp.sd)
 # saveRDS(input.data.list,'./Data/input_data.rds')
input.data.list <- readRDS('./Data/input_data.rds')

phase.med <- input.data.list$phase.med
phase.sd <- input.data.list$phase.sd
amp.med <- input.data.list$amp.med
amp.sd <- input.data.list$amp.sd

plot( amp.med,phase.med)

dat2 <- list('y'=phase.med,'x_meas'=amp.med,'tau'=amp.sd, 'N'=length(phase.med)) #save data in a list

fit1 <- stan(file = './model.stan', data = dat2)
print(fit1)
plot(fit1)
pairs(fit1, pars = c("alpha", "beta", "sigma", "lp__"))


la1 <- extract(fit1, permuted = TRUE) # return a list of arrays 

plot(la1$beta, type='l') #trace plot
beta.med <- median(la1$beta)
alpha.med <- median(la1$alpha)
x.post <- la1$x
x.hdi <- t(apply(x.post,2, hdi, credMass=0.95))
x.med <- apply(x.post,2, median)
x.hdi <- cbind.data.frame(x.med, x.hdi)

plot(x.hdi$x.med, phase.med)
abline(a=alpha.med, b=beta.med, col='red')

symbols(x.hdi$x.med, phase.med, sqrt((1/phase.sd^2)/pi),fg=NA, bg=rgb(0,0,1,0.1) , inches=0.1 )
abline(a=alpha.med, b=beta.med, col='red')


beta.hdi <- hdi(la1$beta, credMass = 0.95)
beta.hdi
beta.med

plot( log(amp.med),x.hdi$x.med)
