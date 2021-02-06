library(rstan)
library(HDInterval)
options(mc.cores = (parallel::detectCores()-1))
rstan_options(auto_write = TRUE)

  d1 <- as.matrix(readRDS('./Data/firstny.rds'))
 d2 <- as.matrix(readRDS('./Data/nyamp.rds')) 
 
 par(mfrow=c(1,2))
 for(i in 1:10){
         plot(d1[,i] , typ='l', main=i)
         plot(d2[,i] , typ='l', main=i)
         
          }
sd.d1 <- apply(d1,2,sd) 

for(i in which(sd.d1<0.1)){
        plot(d1[,i] , typ='l', main=i)
        plot(d2[,i] , typ='l', main=i)
        
}
