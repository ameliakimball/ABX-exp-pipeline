#create experiment designs that are the same length 
#NB right now hard coded to specific designs, as the addition of jitter will 
# depend on how many base rows there are.  


#in working directory model_scripts

thing<-readr::read_csv(file="exp_designs/exp_design_HK_with_acoustic_distance.csv")
thing2<- thing[rep(seq_len(nrow(thing)), 2), ]
thing3<-thing2[1:144,c('Phone_NOTENG','Phone_ENG', 'Econ','Loc','Glob','Acoustic distance')]


#add jitter to second repetition of pairs
for (i in (1+nrow(thing)):144){
  thing3$`Acoustic distance`[i]<- jitter(thing3$`Acoustic distance`[i])
}

write_csv(thing3,path = "exp_designs/exp_design_hk_144.csv")



that<-readr::read_csv(file="exp_designs/exp_design_Hindi_with_acoustic_distance.csv")
that2<- that[rep(seq_len(nrow(that)), 3), ]
that3<-that2[1:144,c('Phone_NOTENG','Phone_ENG', 'Econ','Loc','Glob','Acoustic distance')]

#add jitter to second repetition of pairs
for (i in (1:nrow(that)):144){
  that3$`Acoustic distance`[i]<- jitter(that3$`Acoustic distance`[i])
}

write_csv(that3,path = "exp_designs/exp_design_hindi_144.csv")

