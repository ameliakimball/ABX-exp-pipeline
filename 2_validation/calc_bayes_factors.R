#using the final_master, 
#create a df that compares between the full model and the zero model 

#calculate the bayes factor for each pair.  


#read in masters 
#strip off model_fit_filenames 
#put side by side 
#apply function recursively that 
# 1) reads in each of the two  brmsfits
# 2) applies bayes_factor() function 


myfit <-readRDS("2_validation/model_fits_rds/3each_dups/-1__-1__-1__dinst1_30subjs__Econ+Glob+Loc__NA__1.rds")


brms::bayes_factor(myfit1,myfit2)  



#add col: which one won
#add col: which one should have won

Error in cpp_object_initializer(.self, .refClassDef, ...) : 
  impossible de trouver la fonction "cpp_object_initializer"
Error in .local(object, ...) : 
  the model object is not created or not valid

et voila

