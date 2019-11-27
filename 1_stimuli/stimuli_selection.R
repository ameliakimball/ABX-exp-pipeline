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
PAIRS <-ARGS[1] #"1_stimuli/distances_by_pair.csv" # 

# Output filtered subset of these 
OUTPUT <- ARGS[2]# "1_stimuli/exp_length_pairs.csv" #

pairs_w_dist <- readr::read_csv(PAIRS)

#English sounds the most variable between instances are b,z,d͡ʒ ɽʱ
#once these are removed, remove pairs with large mean distances
#after pairs are winnowed down, 
#sample one of each phoneme pair
#use join to select triplets that match 


filt_diff_pairs <-  dplyr::filter(pairs_w_dist, target_other=="OTH")%>%
                    dplyr::filter(.,phone_1!="z"&phone_2!="z")%>%
                    dplyr::filter(!(phone_1=="ɽʱ" & phone_2 == "d͡ʒ"))%>%
                    dplyr::filter(!(phone_1=="d͡ʒ"& phone_2 =="ɽʱ"))%>%
                    dplyr::group_by(.,phone_1, phone_2, language_1) %>%
                    dplyr::summarise(.,mean_dist = mean(distance))%>%
                    dplyr::filter(mean_dist < .375) %>%
                    dplyr::filter(.,language_1=="HIN") %>%
                    dplyr::select(phone_1,phone_2) %>%
                    dplyr::rename(. ,phone_HIN = phone_1, phone_ENG = phone_2) %>%
                    dplyr::ungroup(.)

#reorder phonemes so that they alternate which lang is first 

filt_diff_pairs$language_1 <-NA
filt_diff_pairs$phone_1 <- NA
filt_diff_pairs$phone_2 <- NA

for (i in (1:nrow(filt_diff_pairs))) {
  filt_diff_pairs$language_1[i] <- sample(c("HIN","ENG"),1)
  }
for (i in (1:nrow(filt_diff_pairs))) {             
filt_diff_pairs$phone_1[i]<- ifelse(filt_diff_pairs$language_1[i]=="HIN",
                    filt_diff_pairs$phone_HIN[i],
                    filt_diff_pairs$phone_ENG[i])
filt_diff_pairs$phone_2[i]<- ifelse(filt_diff_pairs$language_1[i]=="HIN",
                                    filt_diff_pairs$phone_ENG[i],
                                    filt_diff_pairs$phone_HIN[i])
        }


diff_pairs <-dplyr::select(filt_diff_pairs,"phone_1","phone_2","language_1") %>%
                  dplyr::left_join(.,pairs_w_dist,
                                    by=c("phone_1","phone_2","language_1"))%>%
                  dplyr::group_by(phone_1,phone_2,language_1) %>%
                  dplyr::sample_n(1)


same_pairs <- dplyr::filter(pairs_w_dist, target_other=="TGT")%>%
              dplyr::filter(.,phone_1!="z"&phone_2!="z")%>%
              dplyr::group_by(.,phone_1, phone_2, language_1) %>%
              dplyr::sample_n(1)


full_filt_pairs<-dplyr::bind_rows(diff_pairs,same_pairs)


readr::write_csv(full_filt_pairs, OUTPUT)
