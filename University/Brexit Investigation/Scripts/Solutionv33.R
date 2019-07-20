#----------------------------------------------------------------------
#Running the Abnormal Returns to test significance
#Return dataframe with AR, Change in Value, and T-Stat
#Can also return CAR, which we do not investigate in our
#documentation
#----------------------------------------------------------------------

#YYYY-MM-DD format of date
#Selecting the period and extracting subset of data within that time period
#We need to find the:
#Estimation Window - Take 150 days prior to the event window
#Event Window - Take 5 days before and 5 days after
#Post Event Window -Take 50 days after the event - Included for completion purposes

#dataset inputted needs to be of the original format (e.g. GBPEUR, EURUSD etc.)

AbnormalReturns=function(dataset,event_date,estimationwindow,starteventtime,endeventtime,posteventwindow){
	
#Finding the length of the event window
eventwindow=endeventtime-starteventtime+1 #5 days prior

#Finding dates of Estimation Window
start_Est_date=as.Date(event_date)-((eventwindow-1)/2)-estimationwindow+1 #+1 since not incl.
end_Est_date=as.Date(event_date)-((eventwindow-1)/2)

#Finding dates of Event Window
start_Evt_date=as.Date(event_date)-((eventwindow-1)/2)+1 #+1 since not incl.
end_Evt_date=as.Date(event_date)+((eventwindow-1)/2)

#Finding dates of Post Event Window
start_PEvt_date=as.Date(event_date)+((eventwindow-1)/2)+1 #+1 since not incl.
end_PEvt_date=as.Date(event_date)+((eventwindow-1)/2)+posteventwindow

dataset$Date=as.Date(dataset $Date)

#Filtering the dataset to fit our estimation and post event window dates
dfevent1 = dataset[dataset $Date >= start_Est_date & as.Date(dataset $Date) <= end_PEvt_date,]
dfevent1 = dfevent1[order(dfevent1$Date),]
rownames(dfevent1) <- NULL
dfevent1$Date=as.Date(dfevent1$Date) 
dfevent1$ValueLag=c(NA,dfevent1$Value[1:nrow(dfevent1)-1])
dfevent1$Diff=dfevent1$Value-dfevent1$ValueLag
dfevent1$Return=(dfevent1$Diff)/dfevent1$ValueLag
dfevent1=dfevent1[2:nrow(dfevent1),]

posteventrows=nrow(dfevent1[dfevent1 $Date >= event_date & as.Date(dfevent1 $Date) <= end_PEvt_date,])-1
estimationrows=nrow(dfevent1[dfevent1 $Date >= start_Est_date & as.Date(dfevent1 $Date) <= event_date,])-1
dfevent1$Time=c(-estimationrows:posteventrows) #Setting time periods with even listed as 0

#ggplot(data=dfevent1[,c('Date','Value')],aes(x=Date, y=Value,group=1))+geom_line()

#Mean Adjusted Model - Mackinlay (1997)
#Average return during Estimation Window
ExpRate = mean(dfevent1[dfevent1 $Date >= start_Est_date & dfevent1 $Date <= end_Est_date,]$Return)
#Market Model (Makes use of OLS)
#INPUT HERE

#Return of Exchange Rate
Ratet = dfevent1$Return

#Abnormal Returns
dfevent1$AR=Ratet-ExpRate

#Constructing parts of the dataframe that belong to the Estimation Window, Event Window and Post Event Window
EstWin = dfevent1[dfevent1 $Date >= start_Est_date & dfevent1 $Date <= end_Est_date,]
EvtWin = dfevent1[dfevent1 $Date >= start_Evt_date & dfevent1 $Date <= end_Evt_date,]
PEvtWin = dfevent1[dfevent1 $Date >= start_PEvt_date & dfevent1 $Date <= end_PEvt_date,]

#Cumulative Abnormal Returns during Event Window
CAR=sum(dfevent1[(dfevent1$Time>=endeventtime)&(dfevent1$Time<=starteventtime),]$AR)
CAR=sum(EvtWin$AR)

#Significance Tests

#Abnormal Returns
#Standard Deviation
SDAR=sqrt((1/(length(dfevent1[dfevent1$Time<=(endeventtime),]$AR)-2))*sum((dfevent1[dfevent1$Time<=(starteventtime),]$AR)^2))
#T-Statistic
dfevent1$TStatAR=dfevent1$AR/SDAR

#ARSignificanceTest
dfevent1$ARSig90= 0.05>pt(dfevent1$TStatAR,length(dfevent1$AR)) | pt(dfevent1$TStatAR,length(dfevent1$AR))>0.95
dfevent1$ARSig95= 0.025>pt(dfevent1$TStatAR,length(dfevent1$AR)) | pt(dfevent1$TStatAR,length(dfevent1$AR))>0.975
dfevent1$ARSig99= 0.005>pt(dfevent1$TStatAR,length(dfevent1$AR)) | pt(dfevent1$TStatAR,length(dfevent1$AR))>0.995

#dfevent1 within the time window, used to to ease results onto the user, and not return a gigantic table
DFEventWind=dfevent1[(dfevent1$Time<= endeventtime) & (dfevent1$Time>= starteventtime),]

#Cumulative Abnormal Returns
#Standard Deviation
SDCAR=sqrt(eventwindow)*SDAR
#T-Statistic
TStatCAR=CAR/SDCAR

#CAR SignificanceTest
CARSig90= 0.05>pt(TStatCAR,eventwindow) | pt(TStatCAR, eventwindow)>0.95
CARSig95= 0.025>pt(TStatCAR,eventwindow) | pt(TStatCAR, eventwindow)>0.975
CARSig99= 0.005>pt(TStatCAR,eventwindow) | pt(TStatCAR, eventwindow)>0.995

#print('Cumulative Abnormal Returns Result')
#print(TStatCAR)
#print(pt(TStatCAR,eventwindow))
#print(CARSig90)
#print(CARSig95)
#print(CARSig99)

#Obtaining results, multiple different approaches - User can experiment here and comment/uncomment certain results out

#Returns entire dataframe
print(DFEventWind)

#Returns dates with significant AR
#print(DFEventWind[DFEventWind $ARSig95==TRUE,]$Date)

#Returns relevant statistics on the specified event date
#print(DFEventWind[DFEventWind $Date==event_date,]) #Return event date statistics

#print(event_date) #Used to remind the user which dates are being looked into
#print(TRUE %in% DFEventWind $ARSig90) #Used to return TRUE if there is any significance at all in the event window

#Plotting the abnormal returns within the event window
ggplot(data=dfevent1[(dfevent1$Time<=endeventtime)&(dfevent1$Time>=starteventtime),][,c('Time','AR')],aes(x=Time, y=AR,group=1))+geom_line() + labs(title = "Abnormal Returns of selected Exchange Rate")+xlab("Time")+ylab("Abnormal Returns")+ scale_x_continuous(breaks=c(starteventtime: endeventtime))
}

#Used to find the main dates
#Comment out the print of DFEventWind as it's useless
#for (i in as.character(datelist)){
#	AbnormalReturns(GBPEUR,i,100,-5,5,30)
#}
