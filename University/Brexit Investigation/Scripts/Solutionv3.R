#----------------------------------------------------------------------
#This script involves two main steps:
#Step 1: Extracts the data from the FOREX files & News files
#Step 2a: Cleaning and merging the ToM data and the currency data
#Step 2b: Testing whether weekends should be included
#----------------------------------------------------------------------


#--------------------------------------------------------------------------------------------------------------------------------------------
#Installing relevant packages and setting the working directory
#--------------------------------------------------------------------------------------------------------------------------------------------

#NOTE: WHEN RUNNING ON UBUNTU 18.04
#Installing the following libraries may require XML2 and GSL

library(gtools) #Installed
library(chron) #Installed
library(ggplot2) #Installed
library(stringr) #Installed
library(data.table) #Installed
library(tidyr) #Installed
library(xts) #Installed - zoo package will be installed with it
library(tm) #Should install and call NLP with it
library(dplyr)
library(tidytext) 
library(topicmodels) 


#library(Quandl) #Required for the Quandl functions, however returning some issues on Ubuntu
#library(tidyverse) #Giving serious issues on my version of Ubuntu. Required to run complete() function.
#library(erer) #Is this needed?
#library(rprojroot) #Not needed
#library(here) #Not needed

#Setting the working directory to be that of the file
setwd(dirname(sys.frame(1)$ofile))  #Should work for Ubuntu

#----------------------------------------------------------------------
#1. Data Extraction
#----------------------------------------------------------------------

#Extract Financial Data
GBPEUR=read.csv('Data/GBPEUR')
EURUSD=read.csv('Data/EURUSD')
GBPUSD=read.csv('Data/GBPUSD')
XRPUSD=read.csv('Data/XRPUSD')
BTCUSD=read.csv('Data/BTCUSD')
LTCUSD=read.csv('Data/LTCUSD')

#Selecting relevant currency data
#Set the value for each dataset
GBPUSD = GBPUSD[,c("Date","Settle")]
colnames(GBPUSD)=c("Date","Value")

XRPUSD = XRPUSD[,c("Date","Mid")]
colnames(XRPUSD)=c("Date","Value")

BTCUSD = BTCUSD[,c("Date","Mid")]
colnames(BTCUSD)=c("Date","Value")

LTCUSD = LTCUSD[,c("Date","Mid")]
colnames(LTCUSD)=c("Date","Value")

#Extracting Brexit Data
#This data is already from 1 January onwards so we do not need to set it
BrexitData=read.csv("Data/BrexitNewsData.csv")

#Cleaning any further punctuation
BrexitData$Tokens=stringr::str_replace_all(BrexitData$Tokens,"[^a-zA-Z\\s]","") #Remove anything that is not a number or letter

#----------------------------------------------------------------------
#2a. Data Cleaning & Transforming
#----------------------------------------------------------------------

#Cleaning & Transforming News Article Data
#Count number of times Brexit is mentioned in each article
BrexitDataToM=BrexitData[BrexitData$Source=='Times of Malta',]

#Searching the number of times per row the word Brexit was mentioned
RawBrexitCounter=data.frame("Date"=BrexitDataToM$Date,"Count"=str_count(BrexitDataToM$Tokens, "brexit"))

#Grouping data and summing counts by date
DT <- as.data.table(RawBrexitCounter)
BrexitCounter =data.frame(DT[ , lapply(.SD, sum), by = "Date"])

#Ordering by date
BrexitCounter <- BrexitCounter[order(BrexitCounter$Date),]  

#Converting to date type from string
BrexitCounter $Date=as.Date(BrexitCounter $Date)

#Filling empty dates (for days when we have no Brexit articles published)
BrexitCounter<-merge(data.frame(Date= as.Date(min(BrexitCounter $Date):max(BrexitCounter $Date),"1970-01-01")),
          BrexitCounter, by = "Date", all = TRUE)
BrexitCounter[is.na(BrexitCounter)] <- 0
colnames(BrexitCounter)=c("Date","WordCount")


#Alternative to carry out the above is to make use of the tidyverse/dplyr package, however this has some trouble on Linux
#BrexitCounter = BrexitCounter %>% complete(Date = seq(Date[1], Sys.Date(), by = "1 day"),fill = list(Count = 0))

#Removing index (affected due to sorting)
rownames(BrexitCounter) <- NULL


#Cleaning & Transforming Financial Data (Function since we want to apply this to multiple currencies)
CurrencyDataClean=function(dataset){
#Order data by date
dataset <- dataset[order(dataset$Date),]  

#Select data January 2016 onwards (when news articles first began to appear)
dataset <- dataset[as.Date(dataset $Date)>=as.Date('2016-01-01'),]

#Converting columns to date
#BrexitCounter$Date=as.Date(BrexitCounter$Date) #Is this necessary?
dataset$Date= as.Date(dataset$Date)

#Obtaining the number of articles per day
ArticleCountDF=data.frame(table(BrexitDataToM$Date))
colnames(ArticleCountDF)=c("Date","ArticleCount")
ArticleCountDF $Date =as.Date(ArticleCountDF $Date)

#Filling empty dates (for days when we have no Brexit articles published)
ArticleCountDF <-merge(data.frame(Date= as.Date(min(ArticleCountDF $Date):max(ArticleCountDF $Date),"1970-01-01")),
          ArticleCountDF, by = "Date", all = TRUE)
ArticleCountDF[is.na(ArticleCountDF)] <- 0

#Alternative to carry out the above is to make use of the tidyverse/dplyr package, however this has some trouble on Linux
#ArticleCountDF = ArticleCountDF %>% complete(Var1 = seq(Var1[1], Sys.Date(), by = "1 day"),fill = list(Count = 0)) #Setting days with no articles to 0

#Merging the final data
FinalData=merge(x = merge(x = dataset, y = data.frame(BrexitCounter), by.x = "Date",by.y="Date"), y = data.frame(ArticleCountDF), by = "Date")

}

#FinalData=CurrencyDataClean(GBPEUR)

#----------------------------------------------------------------------
#2b. Should weekends be included?
#----------------------------------------------------------------------

#SCENARIO A - EXCLUDING WEEKENDS
#Using the command below we find the average number of times Brexit is mentioned during the weekends vs number of times mentioned on weekdays
wkndcount=mean(BrexitCounter $WordCount[is.weekend(BrexitCounter $Date)])
print('Average Times Brexit is mentioned during weekend')
print(wkndcount)

#SCENARIO B - INCLUDING WEEKENDS
#Using the command below we find the average number of times Brexit is mentioned during the weekends vs number of times mentioned on weekdays
weekcount=mean(BrexitCounter $WordCount[!is.weekend(BrexitCounter $Date)])
print('Average Times Brexit is mentioned during weekday')
print(weekcount)

#The results indicate that there are a fairly high amount of articles released over the weekend (similar to during the week). Since these will influence correlation (as whatever happens with the number of articles the rate will remain the same), we decide to use scenario A and EXCLUDE weekends.