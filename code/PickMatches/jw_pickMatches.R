# AFTER COMPUTING JW DISTANCES ON NAMES BY BLOCK, LOOP OVER BLOCKS AND PICK BEST MATCH

# Emily Eisner, January 2019

# set working directory
setwd("~/")

#Load packages
#install.packages('doParallel')
#install.packages('stringdist')
library(foreign)
library(data.table)
library(stringdist)
library(doParallel)
options(scipen=999)

# for running in parallel
cl <- makeCluster(5)
registerDoParallel(cl)

# set linking years
year1 = 1920
year2 = 1930

# set weights on each distance
wgt_firstname = 1
wgt_lastname = 1
wgt_birthyr = 1


year1small = year1 - 1900
year2small = year2 - 1900


# number of files from previous blocking step
n_blocks<-length(list.files(path=paste("/homes/nber/eisere/bulk/cens1930.work/temp/distances",year1small,year2small,sep=""),pattern = "_lib"))
list_blocks<-list.files(path=paste("/homes/nber/eisere/bulk/cens1930.work/temp/distances",year1small,year2small,sep=""),pattern = "_lib")

# LOOP OVER FILES WITH DISTANCE MEASURES
foreach(j=1:n_blocks) %dopar% {
  
  library(data.table)
  
  
  # READ IN DATA
  data<-read.csv(paste("/homes/nber/eisere/bulk/cens1930.work/temp/distances",year1small, year2small,"/",list_blocks[j],sep=""),sep=" ")
  data<-data.table(data)
  
  # create single distance index using weights specified above
  # make zscore variables
  #z_strdist_LN <- scale(data$Dist_LN,center=TRUE, scale=TRUE)
  #z_strdist_FN <- scale(data$Dist_FN,center=TRUE, scale=TRUE)
  #z_agedist <- scale(data$Age_Dist,center=TRUE, scale=TRUE)
  
  
  # combine distances to one distance with equal weight
  data$totdist = wgt_lastname*abs(data$zDist_LN) + wgt_firstname*abs(data$zDist_FN) + wgt_birthyr*abs(data$zAge_Dist)
  
  # pick least distance by ID_A then ID_B
  minA <- data[ , min(totdist), by = ID_A]
  colnames(minA)<-c("ID_A","totdist")
  minA <- data.table(minA)
  setkey(data,ID_A,totdist)
  setkey(minA,ID_A,totdist)
  data <- data[minA]
  minB <- data[ , min(totdist), by = ID_B]
  colnames(minB)<-c("ID_B","totdist")
  setkey(data,ID_B,totdist)
  setkey(minB,ID_B,totdist)
  data <- data[minB]

  
  # write to csv
  if (dim(data)[1]>0){
    file<-paste("/homes/nber/eisere/bulk/cens1930.work/temp/links",year1small,year2small,"/links_minJW_",j,".csv",sep="")
    write.table(data,file, row.names=F)
  }
  
  rm(data,minA,minB)
  gc()
     
}

stopCluster(cl)


