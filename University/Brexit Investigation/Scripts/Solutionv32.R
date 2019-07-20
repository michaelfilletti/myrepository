#--------------------------------------------------------------------------------------------------------------------------------------------
#Testing the correlation in various different ways
#Step 3a - Correlation over entire span of days
#Step 3b - Obtaining cumulative correlation to view how this changes over time
#Step 3c - Running correlation tests over a certain window
#Step 3d - Investigating the ACF (shows correlation in terms of lag)
#--------------------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------------------
#3a. Correlation over entire span of days
#--------------------------------------------------------------------------------------------------------------------------------------------

OverallCorrelation=function(FinalData){
	
#Approach 1 - Running the correlation test of our rate against the number of times the term appears
MAcorr=running(FinalData $Value, FinalData $WordCount, fun=cor, width=nrow(FinalData))
corr=mean(as.vector(MAcorr),na.rm=TRUE)
print("Full correlation test of our rate against number of time term appears")
print(corr)

#Approach 2 - Running the correlation test of % change in GBP/EUR rate against the number of times the term appears
laggeddata=c(NA,FinalData$Value[1:nrow(FinalData)-1])
FinalData$Change=FinalData$Value-laggeddata
FinalData$ValuePctChange=FinalData$Change/laggeddata
MAcorr=running(FinalData$ValuePctChange[2:836], FinalData $WordCount[2:836], fun=cor, width=835)
corr=mean(as.vector(MAcorr),na.rm=TRUE)
print("Full correlation test of our % Change in rate against number of time term appears")
print(corr)

#Approach 3 - Absolute % Change in exchange rate against Count
MAcorr=running(abs(FinalData$ValuePctChange[2:836]), FinalData $WordCount[2:836], fun=cor, width=835)
corr=mean(as.vector(MAcorr),na.rm=TRUE)
print("Full correlation test of our Absolute % Change in rate against number of time term appears")
print(corr)
}

#--------------------------------------------------------------------------------------------------------------------------------------------
#3b. Obtaining a cumulative correlation and viewing how this changes over time, when it peaks/dips
#--------------------------------------------------------------------------------------------------------------------------------------------

CumulativeCorrelation=function(FinalData){

#Approach 1 - Running the correlation test of  our GBP/EUR rate against the number of times the term appears
corr=integer(835)
for (i in 2:836) {
	MAcorr=running(FinalData$Value[2:i], FinalData $WordCount[2:i], fun=cor, width=i-2+1)
	corr[i-1]=mean(as.vector(MAcorr),na.rm=TRUE)
}
plot(corr,type='l',xlab="Cumulative Days",ylab="Correlation")
title("Cumulative Correlation of GBP/EUR Exchange Rate")

#Used for the next two approaches
laggeddata=c(NA,FinalData$Value[1:nrow(FinalData)-1])
FinalData$Change=FinalData$Value-laggeddata
FinalData$ValuePctChange=FinalData$Change/laggeddata

#Approach 2 - Running the correlation test of % change in GBP/EUR rate against the number of times the term appears
corr=integer(835)
for (i in 2:836) {
	MAcorr=running(FinalData$ValuePctChange[2:i], FinalData $WordCount[2:i], fun=cor, width=i-2+1)
	corr[i-1]=mean(as.vector(MAcorr),na.rm=TRUE)
}

#Approach 3 - Absolute % Change in exchange rate against Count
corr=integer(835)
for (i in 2:836) {
	MAcorr=running(abs(FinalData$ValuePctChange[2:i]), FinalData $WordCount[2:i], fun=cor, width=i-2+1)
	corr[i-1]=mean(as.vector(MAcorr),na.rm=TRUE)
}

}

#--------------------------------------------------------------------------------------------------------------------------------------------
#3c. Running the correlation test for the a window of 10 days (i.e. event window)
#--------------------------------------------------------------------------------------------------------------------------------------------

WindowCorrelation=function(FinalData){
w=11
mincorr=0.602 #The critical value of the Pearson correlation for 90% significance and 8 DoF (since d=n-2)

#Approach 1 - Running the correlation test of  our GBP/EUR rate against the number of times the term appears
MAcorr=running(FinalData$Value, FinalData $WordCount, fun=cor, width=w)
corr=as.vector(MAcorr)
#print(corr)
plot(corr,type='l',xlab="Windows",ylab="Correlation")
abline(h=mincorr, col="red",lty=2)
abline(h=-mincorr, col="red",lty=2)
title("11-Day Window Correlation of GBP/EUR Exchange Rate")


#Considering indices where the correlation is at least mincorr
#Considering dates that had an above average number of articles released
ind=which(abs(MAcorr) > mincorr)
datelist=FinalData[ind,][FinalData[ind,]$ArticleCount>mean(FinalData$ArticleCount,na.rm=TRUE),]$Date
print(datelist)
}

#--------------------------------------------------------------------------------------------------------------------------------------------
#3d. Investigating the ACF
#--------------------------------------------------------------------------------------------------------------------------------------------

AutoFinalDataCorrelation=function(FinalData){
#Approach 1 - Running the correlation test of  our GBP/EUR rate against the number of times the term appears
ccf (FinalData$Value, FinalData$WordCount, lag = 1) #Effects should be practically instantaneous
ccf (FinalData$Value, FinalData$WordCount, lag = nrow(FinalData)) #Still check how it evolves over time

#Approach 2 - Running the correlation test of % change in GBP/EUR rate against the number of times the term appears
#ccf (FinalData$ValuePctChange, FinalData$WordCount, lag = 1) #Effects should be practically instantaneous
#ccf (FinalData$ValuePctChange, FinalData$WordCount, lag = nrow(FinalData)) #Still check how it evolves over time

#Approach 3 - Absolute % Change in exchange rate against Count
#ccf (abs(FinalData$ValuePctChange), FinalData$WordCount, lag = 1) #Effects should be practically instantaneous
#ccf (abs(FinalData$ValuePctChange), FinalData$WordCount, lag = nrow(FinalData)) #Still check how it evolves over time
}