# COMPUTE STRING DISTANCES AND AGE DISTANCES WITHIN BLOCKS
# ADAPTED FROM CODE DEVELOPED BY ABRAMITZKY ET AL

# Emily Eisner, January 2019

# set working directory
setwd("~/")


# set linking years
year1 = 1920
year2 = 1940

year1small = year1 - 1900
year2small = year2 - 1900

#Load packages
#install.packages('doParallel')
#install.packages('stringdist')
library(foreign)
library(data.table)
library(stringdist)
library(doParallel)
options(scipen=999)

# for running in parallel
cl <- makeCluster(4)
registerDoParallel(cl)


# number of files from previous blocking step
n_blocks<-length(list.files(path="/homes/nber/eisere/bulk/cens1930.work/temp/blocks",pattern = paste(year1,"_",year2,sep="")))
list_blocks<-list.files(path="/homes/nber/eisere/bulk/cens1930.work/temp/blocks",pattern = paste(year1,"_",year2,sep=""))


# set up matrices or matches
matches_cons <- list()
matches_lib <- list()

foreach(j=11210:n_blocks) %dopar% {
  library(stringdist)

  All_Data<-read.csv(paste("/homes/nber/eisere/bulk/cens1930.work/temp/blocks/",list_blocks[j],sep=""))

  A<-All_Data[which(All_Data$YEAR==year1),]
  B<-All_Data[which(All_Data$YEAR==year2),]

  rm(All_Data)
  gc()
  

  #Count the number of observations in the source dataset

  n<-nrow(A)

  #Initialize empty lists

  strdist_FN<-list()
  strdist_LN<-list()
  agedist<-list()
  #n_obs<-list()

  #I now loop over each of the observations in the source dataset A.
  # the line that starts with "index" identifies, for each observation in A, which observations in B belong to the same block
  # the lines that start with strdist_FN and strdist_LN compute the string distance of each observation in A with respect to each observation in B that belongs to its same block (this step is aimed at saving computational time)

  #Drop those that do not have a match within a five years window and match on sex

  # should i just store the differences instead?
  agecomp <- outer(A$BIRTHYR,B$BIRTHYR,function(x,y){abs(x-y)<=5})

  if (sum(agecomp)>0){

      #n_obs <- rowSums(agecomp)
      agecomp <- as.vector(agecomp)

      #Create distances in age, first and last names

      # use outer here and then subset (like above)
      ageAlong <- rep(A$BIRTHYR,length(B$BIRTHYR))[agecomp]
      ageBlong <- rep(B$BIRTHYR,each = length(A$BIRTHYR))[agecomp]
      agedist <- ageAlong - ageBlong
      rm(ageAlong, ageBlong)
      gc()

      # are foreign names not going to be treated well by jw?
      #junk <- outer(A$NAMEFRST,B$NAMEFRST,function(x,y){stringdist(x,y,method="jw",p=0.1)})
      fnAlong <- rep(A$NAMEFRST,length(B$NAMEFRST)) [agecomp]
      fnBlong <- rep(B$NAMEFRST,each = length(A$NAMEFRST))[agecomp]
      strdist_FN <- stringdist(fnAlong,fnBlong,method="jw",p=0.1)
      rm(fnAlong,fnBlong)
      gc()

      lnAlong <- rep(A$NAMELAST,length(B$NAMELAST)) [agecomp]
      lnBlong <- rep(B$NAMELAST,each = length(A$NAMELAST))[agecomp]
      strdist_LN <- stringdist(lnAlong,lnBlong,method="jw",p=0.1)
      rm(lnAlong,lnBlong)
      gc()
      
      
      # make zscore variables
      z_strdist_LN <- scale(strdist_LN,center=TRUE, scale=TRUE)
      z_strdist_FN <- scale(strdist_FN,center=TRUE, scale=TRUE)
      z_agedist <- scale(agedist,center=TRUE, scale=TRUE)
      

      #Export data on string distance to Stata

      idAlong <- rep(A$id,length(B$id))[agecomp]
      idBlong <- rep(B$id,each = length(A$id))[agecomp]
      data<-as.data.frame(cbind(idAlong, idBlong, agedist,strdist_FN, strdist_LN,z_agedist,z_strdist_FN, z_strdist_LN))
      colnames(data)<-c("ID_A","ID_B","Age_Dist","Dist_FN","Dist_LN","zAge_Dist","zDist_FN","zDist_LN")
      

      # need to figure out how to deal with the fact that this is not one-to-one...
      #data_matches_cons <- data[(abs(data$Age_Dist)<=1) & (data$Dist_FN <= .1) & (data$Dist_LN <=.1) ,]
      #data_matches_lib <- data[(abs(data$Age_Dist)<=2) & (data$Dist_FN <= .2) & (data$Dist_LN <=.2) ,]
      data_matches_lib <- data[(abs(data$zAge_Dist)<=.25) & (abs(data$zDist_FN) <= .25) & (abs(data$zDist_LN) <=.25) ,]
      #matches_cons <- rbind(matches_cons,data_matches_cons)
      #matches_lib <- rbind(matches_lib,data_matches_lib)

#      if (dim(data_matches_cons)[1]>0){
#        file<-paste("./censusLinking/tempdistances/Matches_cons_",j,".csv",sep="")
#        write.table(data_matches_cons,file, row.names=F)
#      }


      if (dim(data_matches_lib)[1]>0){
      file<-paste("/homes/nber/eisere/bulk/cens1930.work/temp/distances",year1small,year2small,"/Matches_lib_",j,".csv",sep="")
      write.table(data_matches_lib,file, row.names=F)
      }

      rm(idAlong,idBlong,data,strdist_FN,z_strdist_FN,strdist_LN,z_strdist_LN,agedist,z_agedist,data_matches_lib)
      gc()
      
      #rm(idAlong,idBlong,data,strdist_FN,strdist_LN,agedist, data_matches_cons, data_matches_lib)

  }
 

}

stopCluster(cl)

