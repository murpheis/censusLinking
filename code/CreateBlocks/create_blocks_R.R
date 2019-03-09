# CODE TO CREATE BLOCKS BY FIRST LETTER OF FIRST AND LAST NAME AND STATE OF BIRTH
# ADAPTED FROM THE create_blocks.do CODE DEVELOPED BY ABRAMITZKY ET AL

# Emily Eisner, January 2019

# PACKAGES
#install.packages("data.table")
library("data.table")


# SET WORKING DIRECTORY
setwd("~/")


# DEFINE YEARS I WANT TO LINK
year1 <- 1910
year2 <- 1920
year1short <- year1-1900
year2short <- year2-1900

# VARIABLES TO IMPORT FROM DATA
#selectcols <- c("YEAR" ,  "DATANUM", "SERIAL",  "NUMPREC" ,  "SUBSAMP"   , "AGE"  , "SEX" , "RACE", "BPL", "NAMEFRST", "NAMELAST","BIRTHYR")


# READ IN DATA 
datafileA <- paste("/homes/nber/eisere/bulk/cens1930.work/input/ForLinking_",year1short,".csv",sep="")
datafileB <- paste("/homes/nber/eisere/bulk/cens1930.work/input/ForLinking_",year2short,".csv",sep="")
dataA <- fread(datafileA)  
dataB <- fread(datafileB)  
dataA <- as.data.table(dataA)
dataB <- as.data.table(dataB)


# ADD HEADERS
colnames(dataA)<- c("YEAR" , "AGE"  , "SEX" , "RACE", "BPL","BIRTHYR", "NAMEFRST", "NAMELAST")
colnames(dataB)<- c("YEAR" , "AGE"  , "SEX" , "RACE", "BPL","BIRTHYR", "NAMEFRST", "NAMELAST")


# CREATE ID IN EACH DATASET
dataA[,"id"] <- 1:nrow(dataA)
dataB[,"id"] <- 1:nrow(dataB)

# CREATE YEAR IDENTIFIER
#dataA[,"YEAR"] <- year1
#dataB[,"YEAR"] <- year2


# COMBINE DATASETS 
data <- rbind(dataA,dataB)
rm(dataA)
rm(dataB)
gc()

# CLEAN VARIABLES
data[,"NAMEFRST" := enc2native(NAMEFRST)]
data[,"NAMEFRST" := toupper(NAMEFRST)]
data[,"NAMEFRST" := gsub("[^[:alnum:] ]", "", NAMEFRST)]
data[,"NAMELAST" := enc2native(NAMELAST)]
data[,"NAMELAST" := toupper(NAMELAST)]
data[,"NAMELAST" := gsub("[^[:alnum:] ]", "", NAMELAST)]
data[,"AGE" := as.numeric(AGE)]



# CREATE VARIABLES WITH JUST FIRST LETTER OF FIRST AND LAST NAME
data[,"firstLetterFirst"] <- substr(data$NAMEFRST,1,1)
data[,"firstLetterLast"] <- substr(data$NAMELAST,1,1)


# CREATE GROUPS BASED ON FIRST LETTER OF FIRST AND LAST NAME AND PLACE OF BIRTH
data[,grp := .GRP , by = list(firstLetterFirst,firstLetterLast,BPL)]
#data[,grp := .GRP , by = list(BPL)]

# LOOP OVER BLOCKS AND SAVE EACHd
for (i in 1:length(unique(data$grp))) {
  temp = data[grp == i]
  years = unique(temp$YEAR)
  if  (length(years) == 2) {
    filename = paste("/homes/nber/eisere/bulk/cens1930.work/temp/blocks/data_",year1,"_",year2 ,"_", i,".csv", sep = "")
    write.csv(temp,filename)
  }
  print(i)
 }




