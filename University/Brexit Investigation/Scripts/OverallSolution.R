#Overview of the entire solution, carrying out 4 steps:
#1. Running the cleaning financial data function
#2. Investigating the correlation of these function through multiple different approaches
#3. Investigating Abnormal Returns of specified dates
#3I. Obtaining dates using the Window Correlation Approach
#3II. Obtaining dates using the Top 95% of Articles Approach
#4. Running an LDA on the obtained dates and investigating what the events are about

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 0
#Preparing the functions 
#------------------------------------------------------------------------------------------------------------------------------------------------
source("/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Solutionv3.R") #REPLACE PATH WITH YOUR OWN
source("Solutionv32.R")
source("Solutionv33.R")
source("Solutionv34.R")

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 0.1
#Comparing the number of times Brexit is mentioned vs the number of articles published
#------------------------------------------------------------------------------------------------------------------------------------------------

ggplot()+geom_line(data=FinalData,aes(x=Date, y= WordCount,colour='blue'))+geom_line(data=FinalData,aes(x=Date, y=ArticleCount,colour='red')) + labs(title = "Number of times Brexit mentioned vs Number of Brexit articles published by the Times of Malta")+xlab("Date")+ylab("Count")+scale_color_discrete(name="Type",labels = c("Brexit Mentions", "Brexit Articles"))

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 1
#Cleaning the currency data, user expected to input whichever currency they wish
#GBPEUR, GBPUSD, EURUSD, XRPUSD, BTCUSD, LTCUSD
#------------------------------------------------------------------------------------------------------------------------------------------------

FinalData=CurrencyDataClean(GBPEUR) #Select whichever currency you wish


#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 2
#Investigating the correlation of these functions and obtaining a list of dates using the WindowCorrelation function
#------------------------------------------------------------------------------------------------------------------------------------------------

OverallCorrelation(FinalData)
CumulativeCorrelation(FinalData)
WindowCorrelation(FinalData)
AutoFinalDataCorrelation(FinalData)

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 3
#To investigate the Abnormal Returns within a specific event window
#------------------------------------------------------------------------------------------------------------------------------------------------

AbnormalReturns(GBPUSD,"2016-06-24",100,-5,5,30)


#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 3
#APPROACH I
#Dates obtained from the Window Correlation approach of identifying major events
#------------------------------------------------------------------------------------------------------------------------------------------------

#List of dates obtained from the Window Correlation Approach
WCdatelist=c("2016-04-07", "2016-05-25", "2016-06-09", "2016-06-24", "2016-07-28", "2016-10-14", "2016-12-07", "2016-12-15", "2017-01-18", "2017-01-23", "2017-03-29", "2017-05-30", "2017-07-24", "2017-10-17", "2017-11-20", "2017-11-30", "2018-07-13" ,"2018-11-27", "2018-12-04","2018-12-31", "2019-01-03", "2019-01-15", "2019-01-30")

#To identify dates at which there was a significant change in the exchange rate
for (i in as.character(WCdatelist)){
	AbnormalReturns(GBPEUR,i,150,-5,5,30)
}

#List of dates obtained from the loop above that showed a significant change in the GBP/EUR rate
WCARdatelist=c("2016-05-24" ,"2016-06-01","2016-06-06","2016-06-20", "2016-06-24", "2016-06-27", "2016-10-07" ,"2016-12-01" ,"2016-12-09",  "2017-01-25", "2017-07-18", "2017-07-21", "2017-10-13" ,"2017-11-29" ,"2018-11-29", "2018-12-10", "2018-12-31", "2019-01-02", "2019-01-14", "2019-01-23")

#Testing these dates for other exchange rates
for (i in as.character(WCARdatelist)){
	if (i %in% GBPUSD$Date){
		AbnormalReturns(GBPUSD,i,150,-5,5,30)
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 3
#APPROACH II
#Dates obtained from the Top 90% Article Count days approach of identifying major events
#------------------------------------------------------------------------------------------------------------------------------------------------

#Obtaining the dates when the number of articles published is within the top 5%
Top5AC=quantile(FinalData$ArticleCount, probs = 0.95)
TFdatelist=FinalData[FinalData$ArticleCount> Top5AC,]$Date

#Running the abnormal returns on those dates
for (i in as.character(TFdatelist)){
	AbnormalReturns(GBPEUR,i,150,-5,5,30)
}

#List of dates obtained from the loop above that showed a significant change in the GBP/EUR rate
TFARdatelist=c("2016-06-20", "2016-06-24", "2016-06-27", "2016-07-01", "2018-12-10", "2019-01-14", "2019-01-23" ,"2019-02-26", "2019-03-20", "2019-03-22")

#Testing these dates for other exchange rates
for (i in as.character(TFARdatelist)){
	if (i %in% GBPUSD$Date){
		AbnormalReturns(GBPEUR,i,150,-5,5,30)
	}
}

#------------------------------------------------------------------------------------------------------------------------------------------------
#STEP 4
#Using list of dates from the TFARdatelist and WCAR datelist
#------------------------------------------------------------------------------------------------------------------------------------------------

#Running a topic extraction for a specific window
TopicExtraction('2016-06-24',-5,5,2)

#Running a topic extraction for windows belonging to the below dates
#Returns a graph illustrating the top topics across these various windows
LDAdatelist=c("2016-05-24" ,"2016-06-01","2016-06-06","2016-06-20", "2016-06-24", "2016-06-27", "2016-10-07" ,"2016-12-01" ,"2016-12-09",  "2017-01-25", "2017-07-18", "2017-07-21", "2017-10-13" ,"2017-11-29" , "2018-12-10", "2018-12-31", "2019-01-02", "2019-01-14", "2019-01-23","2019-02-26", "2019-03-20", "2019-03-22")
TopicAnalysis(LDAdatelist)