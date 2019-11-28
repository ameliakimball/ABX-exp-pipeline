#!/usr/bin/env Rscript
#author Amelia 

`%>%`<-magrittr::`%>%`


hindi_scores_single_label <- read_delim("2_validation/hindi_scores_single_label_TAP_WRONG.csv", 
                                      ";", escape_double = FALSE, trim_ws = TRUE) 
hindi_scores <-dplyr::rename(hindi_scores_single_label,Phone_NOTENG=labels)

diff_pairs <- readr::read_csv("2_validation/diff_pairs_for_design.csv")
diff_pairs_two <- dplyr::rename(diff_pairs,Phone_NOTENG=phone_HIN, Phone_ENG=phone_ENG)

new_des<- dplyr::left_join(diff_pairs_two,hindi_scores,
                           by="Phone_NOTENG")



#master df vars
EXPERIMENT_NAME<- "new_144"
DATA_INSTANCE <- "dinst2_30subjs"
MASTER_OUT_CSV <- paste0("master_df_",
                         EXPERIMENT_NAME,
                         "_",
                         DATA_INSTANCE,
                         ".csv")

#data sampling vars
DATA_SUB_FOLDER <- "2_validation/sampled_data"
#DESIGN_CSV<- "exp_designs/fake_grid.csv"
NUM_SUBJS = 30


##################
#create master df#
##################
create_masterdf<-"2_validation/fn_create_masterdf_function_pos_neg.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=c(-1,0,1),
                            exp_name= EXPERIMENT_NAME,
                            data_inst= DATA_INSTANCE)
                            
readr::write_csv(master_df, path=MASTER_OUT_CSV)

#####################
#create csv datasets#
#####################

design_df <- new_des

num_trials = nrow(design_df)

colnames(design_df)[colnames(design_df)=="mean_dist"] <- "acoustic_distance"
colnames(design_df)[colnames(design_df)=="stat_econ"] <- "Econ"
colnames(design_df)[colnames(design_df)=="stat_loc"] <- "Loc"
colnames(design_df)[colnames(design_df)=="stat_glob"] <- "Glob"

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

for (i in 1:nrow(full_design)) {
  full_design$item[i] <- paste(full_design$Phone_NOTENG[i],full_design$Phone_ENG[i],sep = "_")
}

full_design$item <- as.factor(full_design$item)

#the below are dummy values, but must be present for the sampler to work. 
full_design$response_var <- 1



######################
#sample data and save#
######################


sample_binary_four<-"2_validation/fn_sample_binary_four_function.R"
source(sample_binary_four)

coef_dist <- -.1784  #effect of acoustic distance. taken from pilot data 

corr_mods <-subset(master_df, master_df$is_correct_model=="TRUE")

uniq_filenames<-unique(master_df$csv_filename)

for (i in 1:nrow(corr_mods)){
  
    data_i <- sample_binary_four(d = full_design,

                              response_var = "response_var",
                              predictor_vars = c("Econ",
                                                 "Glob",
                                                 "Loc",
                                                "acoustic_distance"),

                              coef_values = c(corr_mods$d_coef_econ[i],
                                              corr_mods$d_coef_glob[i],
                                              corr_mods$d_coef_loc[i],
                                              coef_dist),
                              
                              intercept = 1.3592
                              )
  
    readr::write_csv(data_i,path = paste0(DATA_SUB_FOLDER,"/",uniq_filenames[i]))
}





