//https://mc-stan.org/docs/2_18/stan-users-guide/bayesian-measurement-error-model.html
data {
  int<lower=0> N;
  vector[N] x_meas;     // measurement of x 
  vector[N] tau;  // measurement noise
  vector[N] y_meas;          // outcome (variate)
  vector[N] y_meas_sd; //variance from 1st stage

}
parameters {
  vector[N] x;          // unknown true value of x
  vector[N] true_y;          // unknown true valueof y
  real mu_x;          // prior location
  real mu_y;          // prior location
  real alpha;           // intercept
  real beta;            // slope
  real<lower=0> sigma_x;  // outcome noise
  real<lower=0> sigma_y;  // outcome noise

}
model {
  x ~ normal(mu_x, sigma_x);  // prior for true X
  true_y ~ normal(alpha + beta * x, sigma_y);
  x_meas ~ normal(x, tau);    // measurement model
  y_meas ~ normal(true_y, y_meas_sd);
  
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  mu_x ~ normal(0, 10);
  sigma_x ~ cauchy(0, 5);
  sigma_y ~ cauchy(0, 5);

}