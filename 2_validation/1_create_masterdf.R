#!/usr/bin/env Rscript
#author Amelia 

`%>%`<-magrittr::`%>%`

DESIGN_4each <- "2_validation/design_4_each.csv"
DESIGN_3each <- "2_validation/design_3_each.csv"
HINDI_SCORES <- "2_validation/hindi_scores.csv"

hindi_scores <- readr::read_csv(HINDI_SCORES) 
hindi_scores <- dplyr::rename(hindi_scores,Phone_NOTENG=phone)

diff_pairs_4 <- readr::read_csv(DESIGN_4each)
diff_pairs_4 <- dplyr::rename(diff_pairs_4,Phone_NOTENG=phone_HIN, Phone_ENG=phone_ENG)


diff_pairs_3 <- readr::read_csv(DESIGN_3each)
diff_pairs_3 <- dplyr::rename(diff_pairs_3,Phone_NOTENG=phone_HIN, Phone_ENG=phone_ENG)

new_des_4<- dplyr::left_join(diff_pairs_4,hindi_scores,
                           by="Phone_NOTENG")

new_des_3<- dplyr::left_join(diff_pairs_3,hindi_scores,
                             by="Phone_NOTENG")




#master df vars
EXPERIMENT_NAME<- "4each_zeroes"
DATA_INSTANCE <- "dinst11_30subjs"
MASTER_OUT_CSV <- paste0("master_dfs/",
                         "master_df_",
                         EXPERIMENT_NAME,
                         "_",
                         DATA_INSTANCE,
                         ".csv")
COEF_VALS <- c(-.1,0,.1)

#data sampling vars
DATA_SUB_FOLDER <- "2_validation/sampled_data"
NUM_SUBJS = 30

DESIGN_DF <- new_des_4



##################
#create master df#
##################
create_masterdf<-"2_validation/fn_create_masterdf_function_pos_neg.R"
source(create_masterdf)
master_df<- create_masterdf(vars=c("econ","glob","loc"),
                            coef_vals=COEF_VALS,
                            exp_name= EXPERIMENT_NAME,
                            data_inst= DATA_INSTANCE)
                            
readr::write_csv(master_df, path=MASTER_OUT_CSV)



#####################################################
#create csv dataset with arbitrary response variable#
#####################################################

design_df <- new_des_3

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
#sample response_variable and savecsv#
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





