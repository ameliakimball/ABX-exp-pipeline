#some sample bayesfactors 
#4each_144 





library(brms)

d_1_1_1_m_pos  <-readRDS("model_fits_rds/4each_144/1__1__1__dinst1_30subjs__Econ+Glob+Loc__NA__stan_models:master_pos.stan.rds")
d_1_1_1_m_zero <- readRDS("model_fits_rds/4each_zeroes/1__1__1__dinst1_30subjs__Econ+Glob+Loc__NA__stan_models:master_pos.stan.rds")

comp1 <- bayestestR::bayesfactor_models(d_1_1_1_m_pos,d_1_1_1_m_zero)





#model name IS CORRECT here (first round were run with posisitve names)
d_0_0_0_m_zero   <- readRDS("model_fits_rds/4each_zeroes/0__0__0__dinst4_30subjs__NA__zero_model__stan_models:master_neg.stan.rds")
d_0_0_0_m_pos  <- readRDS("model_fits_rds/4each_144/0__0__0__dinst4_30subjs__Econ+Glob+Loc__NA__stan_models:master_pos.stan.rds")


comp2 <-
bayestestR::bayesfactor_models(dinst4_exp, dinst4_exp_2)

bayes_factor(dinst4_exp, dinst4_exp_2)

d_neg_neg_neg_m_pos <- readRDS("model_fits_rds/4each_144/-10__-10__-10__dinst10_30subjs__Econ+Glob+Loc__NA__stan_models:master_pos.stan.rds")
d_neg_neg_neg_m_zero <- readRDS("model_fits_rds/4each_zeroes/-10__-10__-10__dinst10_30subjs__NA__zero_model__stan_models:master_neg.stan.rds")

bayestestR::bayesfactor_models(d_neg_neg_neg_m_pos,d_neg_neg_neg_m_zero)


