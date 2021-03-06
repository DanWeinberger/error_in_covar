library(rstan)
library(HDInterval)
options(mc.cores = (parallel::detectCores()-1))
rstan_options(auto_write = TRUE)


##Derivative for harmonic
#lambda= exp(b0 +  amp*cos(2*pi*t/period+phase) + phi)
#deriv.lambda= -pi/6*amp*sin(2*pi*t/period+phase)*exp(b0 + amp*cos(2*pi*t/period+phase) + phi)
#Check
# period=12
# phase=0.2
# amp=1
# t=1:120
# phi = 0
# b0=1
# lambda <- exp(b0 + amp*cos(2*pi*t/period+phase) +phi) 
# deriv.log.lambda = -pi/6*amp*sin(2*pi*t/period+phase)
# deriv.lambda = -pi/6*amp*sin(2*pi*t/period+phase)*lambda
# manual.deriv.lambda=rep(NA, length(deriv.lambda))
# for(i in 2: length(deriv.lambda)){ manual.deriv.lambda[i] = lambda[i] - lambda[i-1] }
# 
# plot(deriv.lambda, type='l')
# points(manual.deriv.lambda, type='l' ,col='red')
# max(deriv.lambda)

 #  d1 <- as.matrix(readRDS('./Data/firstny.rds'))
 #  amp <- as.matrix(readRDS('./Data/nyamp.rds')) #multiplyin by -pi/6 converts from scale of amplitude to max derivative
 # d2 <- pi/6*amp # sin(2*pi*t/period-phase.shift) ranges from -1 to 1 the max deriv occurs when the harmonic=-1; this cancels out the -1 in front of pi/6*amp
 # 
 # phase.med <- apply(d1,2, median)
 # phase.sd <- apply(d1,2, sd)
 # 
 # amp.med <- apply(d2,2,median)
 # amp.sd <- apply(d2,2,sd)
 # 
 # exclude <- which(phase.sd > 0.2 ) #These represent models that did not converge well
 # phase.sd[exclude] <- 1e2
 # amp.sd[exclude] <- 1e2
 # amp.med[exclude] <- 1
 # 
 # 
 # amp.prec <- 1/amp.sd^2
 # amp.inv.var <- 1/amp.sd^2
 # wgt.mean.amp <- weighted.mean(amp.med, 1/amp.sd^2)
 # wgt.var <- sum(amp.inv.var * (amp.med - wgt.mean.amp)^2) #weighted variance
 # 
 # amp.med.std <- (amp.med - wgt.mean.amp)/sqrt(wgt.var) #standardize amplitude, using weighted values
 # amp.sd.std <- amp.sd/sqrt(wgt.var) #scale sd
 # 
 # 
 # input.data.list <- list('phase.med'=phase.med,'phase.sd'=phase.sd,'amp.med.std'=amp.med.std, 'amp.sd.std'=amp.sd.std)
 # saveRDS(input.data.list,'./Data/input_data.rds')

input.data.list <- readRDS('./Data/input_data.rds')

phase.med <- input.data.list$phase.med
phase.sd <- input.data.list$phase.sd
amp.med.std <- input.data.list$amp.med.std
amp.sd.std <- input.data.list$amp.sd.std



plot( amp.med.std,phase.med)

dat2 <- list('y_meas'=phase.med, 'y_meas_sd'=phase.sd, 'x_meas'=amp.med.std,'tau'=amp.sd.std, 'N'=length(phase.med)) #save data in a list

fit1 <- stan(file = './model.stan', data = dat2)

plot(fit1)
pairs(fit1, pars = c("alpha", "beta", "sigma_x","sigma_y", "lp__"))

la1 <- extract(fit1, permuted = TRUE) # return a list of arrays 

plot(la1$beta, type='l') #trace plot
beta.med <- median(la1$beta)
alpha.med <- median(la1$alpha)
x.post <- la1$x
x.hdi <- t(apply(x.post,2, hdi, credMass=0.95))
x.med <- apply(x.post,2, median)
x.hdi <- cbind.data.frame(x.med, x.hdi)

true.y.med <- t(apply(la1$true_y,2,median))
plot(true.y.med,phase.med)

plot(x.med,true.y.med)

y.pred <- sapply(1:length(la1$alpha), function(x) { 
        la1$alpha[x] + x.post[x,] * la1$beta[x]
})
r2.iter <- apply(y.pred,2, function(y.p)  1-sum((phase.med-y.p)^2)/sum((phase.med-mean(phase.med))^2) )
med.r2 <- median(r2.iter)


# plot(x.hdi$x.med, phase.med)
# abline(a=alpha.med, b=beta.med, col='red')

#"True' X vs True Y
symbols(x.hdi$x.med, true.y.med, sqrt((1/phase.sd^2)/pi),fg=NA, bg=rgb(0,0,1,0.05) , inches=0.15, ylim=c(-1,1) )
abline(a=alpha.med, b=beta.med, col='red')

#Observed data with regression line overlaid
symbols(amp.med.std, phase.med, sqrt((1/phase.sd^2)/pi),fg=NA, bg=rgb(0,0,1,0.05) , inches=0.15 )
abline(a=alpha.med, b=beta.med, col='red')


beta.hdi <- hdi(la1$beta, credMass = 0.95)
beta.hdi
beta.med

