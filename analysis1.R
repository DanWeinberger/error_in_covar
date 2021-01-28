library(rstan)
d1 <- readRDS('./Data/firstny.rds')
d2 <- readRDS('./Data/nyamp.rds')

phase.med <- apply(d1,2, median)
phase.sd <- apply(d1,2, sd)

amp.med <- apply(d2,2,median)
amp.sd <- apply(d2,2,sd)
amp.prec <- 1/amp.sd^2

plot( log(amp.med),phase.med)

dat2 <- list('y'=phase.med,'x_meas'=amp.med,'tau'=amp.sd, 'N'=length(phase.med)) #save data in a list

fit1 <- stan(file = './model.stan', data = dat2)
print(fit1)
plot(fit1)
pairs(fit1, pars = c("alpha1", "beta", "sigma1", "lp__"))
