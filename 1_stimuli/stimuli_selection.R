#!/usr/bin/env Rscript
#stimuli seleciton pipeline

#created by Amelia 
#last edit 26 Nov by Amelia 

#library(magrittr)
#library(readr)
#library(dplyr)

#takes the initial narrowed data frame of possible stimuli with acoustic 
#distances and samples a subset  to form a dataframe of length 
#144 (= desired number of trials). This new data frame of pairs is then made 
#intro triplets, and then input into the optimization script a second time, to 
#select the instances to use (which recording and which speaker) 


`%>%` <- magrittr::`%>%`

 ARGS <-ARGS <- commandArgs(TRUE)

# Input triplet file
PAIRS <- ARGS[1] #"1_stimuli/distances_by_pair.csv" 

# Output filtered subset of these 
OUTPUT <- ARGS[2]# "1_stimuli/exp_length_pairs.csv" #

pairs_w_dist <- readr::read_csv(PAIRS)


#English sounds the most variable between instances are b,z,d͡ʒ ɽʱ
#once these are removed, remove pairs with the largest mean distance 

TGT_OTH_stats <-dplyr::filter(pairs_w_dist,target_other=="OTH")%>%
  dplyr::filter(phone_1!="z"&phone_2!="z")%>%
  dplyr::filter(!(phone_1=="ɽʱ" & phone_2 == "d͡ʒ"))%>%
  dplyr::filter(!(phone_1=="d͡ʒ"& phone_2 =="ɽʱ"))%>%
  dplyr::group_by(.,phone_1,phone_2, language_1)%>%
  dplyr::summarise(.,mean_dist = mean(distance),sd_dist =sd(distance)) %>%
  dplyr::filter(., mean_dist<.375) %>%
  dplyr::filter(., language_1=="HIN")

# this yields 144 hindi pairs. 
#when we join, that's doubled to 288 because there are two instances of each pair,
#so we cut in half again

filtered_pairs <- dplyr::left_join(TGT_OTH_stats,pairs_w_dist,
                                   by = c("phone_1","phone_2","language_1")) %>%
                  dplyr::group_by(., phone_1, phone_2)%>%
                  dplyr::sample_n( 1)

readr::write_csv(filtered_pairs, OUTPUT)
