#!/usr/bin/env Rscript
#author Amelia 

`%>%`<-magrittr::`%>%`

#master df vars
EXPERIMENT_NAME<- "fake_grid"
DATA_INSTANCE <- "dinst5"
MASTER_OUT_CSV <- paste0("master_df_",
                         EXPERIMENT_NAME,
                         "_",
                         DATA_INSTANCE,
                         ".csv")

#data sampling vars
DATA_SUB_FOLDER <- "sampled_data"
DESIGN_CSV<- "exp_designs/fake_grid.csv"
NUM_SUBJS = 1000


##################
#create master df#
##################
create_masterdf<-"fn_create_masterdf_function_pos_neg.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=c(-1,0,1),
                            exp_name= EXPERIMENT_NAME,
                            data_inst= DATA_INSTANCE)
                            
readr::write_csv(master_df, path=MASTER_OUT_CSV)

####################
#create csv dataset#
####################

design_df <- readr::read_csv(DESIGN_CSV)
num_trials = nrow(design_df)

#colnames(design_df)[colnames(design_df)=="Acoustic distance"] <- "acoustic_distance"

subjs<- c()
  for (i in 1:NUM_SUBJS) {
    subjs[i] = paste("subject",i,sep = "_")
  }

trials <- c()
  for (i in 1:num_trials){
    trials[i] = paste("trial",i,sep = "_")
  }

subs_trials <- expand.grid(trials,subjs)
names(subs_trials)<-c("subject","trial")


rep_design_df<- design_df %>% dplyr::slice(rep(dplyr::row_number(), NUM_SUBJS))

full_design <- dplyr::bind_cols(rep_design_df,subs_trials)

full_design$item <- NA

#for (i in 1:nrow(full_design)) {
 # full_design$item[i] <- paste(full_design$Phone_NOTENG[i],full_design$Phone_ENG[i],sep = "_")
#}

#full_design$item <- as.factor(full_design$item)

#the below are dummy values, but must be present for the sampler to work. 
full_design$response_var <- 1



######################
#sample data and save#
######################

#four for hindi, 3 for fake grid
#sample_binary_four<-"fn_sample_binary_four_function.R"
#source(sample_binary_four)

sample_binary_three<-"fn_sample_binary_three_function.R"
source(sample_binary_three)

coef_dist <- -.1784  #effect of acoustic distance. taken from pilot data 

corr_mods <-subset(master_df, master_df$is_correct_model=="TRUE")
uniq_filenames<-unique(master_df$csv_filename)

for (i in 1:nrow(corr_mods)){
  
   # data_i <- sample_binary_four(d = full_design,
   data_i <- sample_binary_three(d = full_design,
                              response_var = "response_var",
                              predictor_vars = c("Econ",
                                                 "Glob",
                                                 "Loc"),
                                                #"acoustic_distance"),

                              coef_values = c(
                                              corr_mods$d_coef_econ[i],
                                              corr_mods$d_coef_glob[i],
                                              corr_mods$d_coef_loc[i]),
                                             # coef_dist),
                              
                              intercept = 1.3592
                              )
  
    readr::write_csv(data_i,path = paste0(DATA_SUB_FOLDER,"/",uniq_filenames[i]))
}





