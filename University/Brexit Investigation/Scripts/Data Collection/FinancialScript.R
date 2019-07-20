#Importing the financial data and modelling it
library(ggplot2)
library(Quandl)

#GBPEUR=read.csv("/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Data/GBP_EUR Historical Data.csv")

#https://www.quandl.com/data/ECB/EURGBP-EUR-vs-GBP-Foreign-Exchange-Reference-Rate
GBPEUR = Quandl("ECB/EURGBP", api_key="orzfq8aWx2XQM8jhVxhc")
GBPEUR$Value=1/GBPEUR$Value
EURUSD = Quandl("ECB/EURUSD", api_key="orzfq8aWx2XQM8jhVxhc")
GBPUSD = Quandl("CHRIS/ICE_MP1", api_key="orzfq8aWx2XQM8jhVxhc")

#https://www.quandl.com/data/BITFINEX-Bitfinex
XRPUSD =Quandl("BITFINEX/XRPUSD", api_key="orzfq8aWx2XQM8jhVxhc")
BTCUSD =Quandl("BITFINEX/BTCUSD", api_key="orzfq8aWx2XQM8jhVxhc")
LTCUSD =Quandl("BITFINEX/LTCUSD", api_key="orzfq8aWx2XQM8jhVxhc")

#Writing all data into CSV files
write.csv(GBPEUR, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/GBPEUR")
write.csv(EURUSD, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/EURUSD")
write.csv(GBPUSD, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/GBPUSD")
write.csv(XRPUSD, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/XRPUSD")
write.csv(BTCUSD, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/BTCUSD")
write.csv(LTCUSD, file = "/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Scripts/Data/LTCUSD")

ggplot(data=GBPEUR[,c('Date','Value')],aes(x=Date, y=Value,group=1))+geom_line()

#YYYY-MM-DD format of date
#Selecting the period and extracting subset of data within that time period
#We need to find the:
#Estimation Window - Take 150 days prior to the event window
#Event Window - Take 5 days before and 5 days after
#Post Event Window

estimationwindow=150
eventwindow=11 #5 days prior
posteventwindow=50
event_date='2016-06-24'

#Finding dates of Estimation Window
start_Est_date=as.Date(event_date)-((eventwindow-1)/2)-estimationwindow+1 #+1 since not incl.
end_Est_date=as.Date(event_date)-((eventwindow-1)/2)

#Finding dates of Event Window
start_Evt_date=as.Date(event_date)-((eventwindow-1)/2)+1 #+1 since not incl.
end_Evt_date=as.Date(event_date)+((eventwindow-1)/2)

#Finding dates of Post Event Window
start_PEvt_date=as.Date(event_date)+((eventwindow-1)/2)+1 #+1 since not incl.
end_PEvt_date=as.Date(event_date)+((eventwindow-1)/2)+posteventwindow

dfevent1 = GBPEUR[GBPEUR$Date >= start_Est_date & GBPEUR$Date <= end_PEvt_date,]
diffdays=length(dfevent1$Date)

EstWin = GBPEUR[GBPEUR$Date >= start_Est_date & GBPEUR$Date <= end_Est_date,]
EvtWin = GBPEUR[GBPEUR$Date >= start_Evt_date & GBPEUR$Date <= end_Evt_date,]
PEvtWin = GBPEUR[GBPEUR$Date >= start_PEvt_date & GBPEUR$Date <= end_PEvt_date,]

ggplot(data=dfevent1[,c('Date','Value')],aes(x=Date, y=Value,group=1))+geom_line()

#Mean Adjusted Model - Mackinlay (1997)
ExpRate = mean(EstWin$Value)
#Market Model (Makes use of OLS)
#INPUT HERE

#Return of Exchange Rate
Ratet = dfevent1$Value

#Abnormal Returns
dfevent1$AR=Ratet-ExpRate

#Cumulative Abnormal Returns
dfevent1$CAR=cumsum(dfevent1$AR)

#Significance Tests

#Abnormal Returns
#Standard Deviation
SDAR=sqrt((1/(length(dfevent1$AR)-2))*sum((dfevent1$AR)^2))
#T-Statistic
dfevent1$TStatAR=dfevent1$AR/SDAR

#Cumulative Abnormal Returns
#Standard Deviation
SDCAR=sqrt((diffdays)*SDAR)
#T-Statistic
dfevent1$TStatCAR=dfevent1$CAR/SDCAR

#SignificanceTest
dfevent1$Sig90=pt(dfevent1$TStatAR,length(dfevent1$AR))<0.1
dfevent1$Sig95=pt(dfevent1$TStatAR,length(dfevent1$AR))<0.05
dfevent1$Sig99=pt(dfevent1$TStatAR,length(dfevent1$AR))<0.01