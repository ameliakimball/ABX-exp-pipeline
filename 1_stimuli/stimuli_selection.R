##
#stimuli seleciton pipeline

#created by Amelia 
#last edit 15 Nov by Amelia 
#
#takes the initial narrowed data frame of possible stimuli with acoustic 
#distances and samples a subset  to form a dataframe of length 
#150 (= desired number of trials). This new data frame is then input into the
#optimization script a second time, to select the instances to use (which 
#recording and which speaker) 

#currently filters on the following things: 
#1)filter out  velar fricatives entirely
#2)filter out isntances for which the log acoustic distance ration is <-0.4 
# (based on pilot data suggesting that lower than this participant 
#accuracy is at ceiling) 


#dependencies:

#library(magrittr)
#library(readr)
#library(dplyr)



`%>%` <- magrittr::`%>%`


# ARGS <-ARGS <- commandArgs(TRUE)

# Input triplet file
INPUT <- "preregistration/triplets.csv"# ARGS[1] 

# Output filtered subset of these 
OUTPUT <- "preregistration/exp_length_stim_list.csv" #ARGS[2]

  
hindi_triplets <- readr::read_csv(INPUT)




hindi_150 <- dplyr::filter(hindi_triplets, phone_TGT != "ɣ"&
                                  phone_OTH != "ɣ" &
                                  phone_X != "ɣ") %>%
             dplyr::filter(., phone_TGT != "x"&
                                  phone_OTH != "x" &
                                  phone_X != "x") %>%
  
             dplyr::mutate(., ratio_distance=distance_TGT/distance_OTH) %>% 
             dplyr::mutate(., log_ratio_distance= 
                             log(distance_TGT/distance_OTH))%>%
             dplyr::filter(., log_ratio_distance > -.4) %>%
             dplyr::mutate(., phone_pair =paste0(as.character(phone_TGT),
                                                 "_",
                                                 as.character(phone_OTH))) %>%
             dplyr::group_by(., phone_pair)%>%
             dplyr::sample_n(size = 1) %>%
             dplyr::ungroup() %>%
             dplyr::sample_n(size = 150)


readr::write_csv(hindi_150, OUTPUT)
