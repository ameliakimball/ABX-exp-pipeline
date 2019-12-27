#create_bayes_factor_paired dfs

#BIGEF 
model_functions <- source("fn_model_comparison_functions.R")

bigef_pos_mast  <- readr::read_csv("master_df_4each_144_dinst10_30subjs.csv")
bigef_pos_mast$fit_name <-model_fit_filename(bigef_pos_mast)

bigef_zero_mast <- readr::read_csv("new_master_df_4each_zeroes_dinst10_30subjs.csv")
bigef_zero_mast$fit_name <- model_fit_filename(bigef_zero_mast)

bigef_pairs_df <- dplyr::left_join(bigef_pos_mast,
                                   bigef_zero_mast, 
                                   by= c("d_coef_econ","d_coef_glob","d_coef_loc")) %>%
  dplyr::select(fit_name.x,fit_name.y, d_coef_econ, d_coef_glob,d_coef_loc, m_pos_vars.x)

bigef_pairs_df<-as.data.frame(bigef_pairs_df)

colnames(bigef_pairs_df)<-c("pos_mod", "zero_mod", "d_coef_econ","d_coef_glob","d_coef_loc","m_pos_vars")

readr::write_csv(bigef_pairs_df,"paired_mods_for_bayes_factor_eff_size_10.csv")

#reg effect size dinst4 

regef_pos_mast  <- readr::read_csv("master_df_4each_144_dinst4_30subjs.csv")
regef_pos_mast$fit_name <-model_fit_filename(regef_pos_mast)

regef_zero_mast <- readr::read_csv("master_df_4each_zeroes_dinst4_30subjs.csv")
regef_zero_mast$fit_name <- model_fit_filename(regef_zero_mast)

regef_pairs_df <- dplyr::left_join(regef_pos_mast,
                                   regef_zero_mast, 
                                   by= c("d_coef_econ","d_coef_glob","d_coef_loc")) %>%
  dplyr::select(fit_name.x,fit_name.y, d_coef_econ, d_coef_glob,d_coef_loc, m_pos_vars.x)

regef_pairs_df<-as.data.frame(bigef_pairs_df)

colnames(regef_pairs_df)<-c("pos_mod", "zero_mod", "d_coef_econ","d_coef_glob","d_coef_loc","m_pos_vars")


readr::write_csv(regef_pairs_df,"paired_mods_for_bayes_factor_eff_size_1.csv")


#smallef .1 dinst11

smallef_pos_mast  <- readr::read_csv("master_df_4each_144_dinst11_30subjs.csv")
smallef_pos_mast$fit_name <-model_fit_filename(smallef_pos_mast)

smallef_zero_mast <- readr::read_csv("master_df_4each_zeroes_dinst11_30subjs.csv")
smallef_zero_mast$fit_name <- model_fit_filename(smallef_zero_mast)

smallef_pairs_df <- dplyr::left_join(smallef_pos_mast,
                                     smallef_zero_mast, 
                                   by= c("d_coef_econ","d_coef_glob","d_coef_loc")) %>%
  dplyr::select(fit_name.x,fit_name.y, d_coef_econ, d_coef_glob,d_coef_loc, m_pos_vars.x)

smallef_pairs_df<-as.data.frame(bigef_pairs_df)

colnames(smallef_pairs_df)<-c("pos_mod", "zero_mod", "d_coef_econ","d_coef_glob","d_coef_loc","m_pos_vars")

dplyr::bind_rows()
