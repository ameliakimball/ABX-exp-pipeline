#create zero masters
#filter master Dec 06 


`%>%` <- magrittr::`%>%`

#three_dups <- readr::read_csv("master_df_3each_dups_dinst1_30subjs.csv")

#one_each_ds<- dplyr::filter(three_dups,m_pos_vars == "Econ+Glob+Loc")


four_mast <- readr::read_csv("master_df_4each_144_dinst11_30subjs.csv")


#filter by all neg just to get a subset, rename model neg as "zero_model" so 
#that filenames come out right. 

 
fourmastfilt<- dplyr::filter(four_mast,m_neg_vars == "Econ+Glob+Loc")
fourmastfilt$m_neg_vars <-"zero_model"

readr::write_csv(fourmastfilt,"master_df_4each_zeroes_dinst11_30subjs.csv")



three_mast <- readr::read_csv("master_df_3each_216_dinst7_30subjs.csv")

#filter by all neg just to get a subset, rename model neg as "zero_model" so 
#that filenames come out right. 

threemastfilt<- dplyr::filter(three_mast,m_neg_vars == "Econ+Glob+Loc")
threemastfilt$m_neg_vars <-"zero_model"


readr::write_csv(fourmastfilt,"master_df_3each_zeroes_dinst7_30subjs.csv")


