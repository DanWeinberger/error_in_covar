//https://mc-stan.org/docs/2_18/stan-users-guide/bayesian-measurement-error-model.html
data {
  int<lower=0> N;
  vector[N] x_meas;     // measurement of x 
  vector[N] tau;  // measurement noise
  vector[N] y;          // outcome (variate)

}
parameters {
  vector[N] x;          // unknown true value
  real mu_x;          // prior location
  real sigma_x;       // prior scale
  real alpha;           // intercept
  real beta;            // slope
  real<lower=0> sigma;  // outcome noise
}
model {
  x ~ normal(mu_x, sigma_x);  // prior
  x_meas ~ normal(x, tau);    // measurement model
  y ~ normal(alpha + beta * x, sigma);
  alpha ~ normal(0, 10);
  beta ~ normal(0, 10);
  sigma ~ cauchy(0, 5);
}