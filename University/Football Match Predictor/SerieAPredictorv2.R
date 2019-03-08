#ITALIAN SERIE A PREDICTOR

data<-read.csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Science/I1.csv')
data$HomeTeam #This is the vector containing the home team
data$AwayTeam #This is the vector containing the away team
data$FTHG #This is the vector containing the number of goals of the home team
data$FTAG #This is the vector containing the number of goals of the away team

HomeGP=table(data$HomeTeam)
AwayGP=table(data$AwayTeam)

HomeGS=data.frame(aggregate(data$FTHG, by=list(Category=data$HomeTeam), FUN=sum))
HomeGA=data.frame(aggregate(data$FTAG, by=list(Category=data$HomeTeam), FUN=sum))

AwayGS=data.frame(aggregate(data$FTAG, by=list(Category=data$AwayTeam), FUN=sum))
AwayGA=data.frame(aggregate(data$FTHG, by=list(Category=data$AwayTeam), FUN=sum))

teamstats=data.frame(cbind(HomeGP,HomeGS[2],HomeGA[2],AwayGP,AwayGS[2],AwayGA[2]))
colnames(teamstats)=c('Team', 'HomeGP','HomeGS', 'HomeGA','AwayTeam','AwayGP','AwayGS', 'AwayGA')
teamstats <- subset(teamstats, select = -c(AwayTeam))

teamstats$AvgHomeGS=teamstats$HomeGS/teamstats$HomeGP
teamstats$AvgHomeGA=teamstats$HomeGA/teamstats$HomeGP
teamstats$AvgAwayGS=teamstats$AwayGS/teamstats$AwayGP
teamstats$AvgAwayGA=teamstats$AwayGA/teamstats$AwayGP

noteams=20
AvgHomeGS=sum(teamstats$AvgHomeGS)/noteams
AvgHomeGA=sum(teamstats$AvgHomeGA)/noteams
AvgAwayGS=sum(teamstats$AvgAwayGS)/noteams
AvgAwayGA=sum(teamstats$AvgAwayGA)/noteams

teamstats$HomeAttPower=teamstats$AvgHomeGS/AvgHomeGS
teamstats$HomeDefPower=teamstats$AvgHomeGA/AvgHomeGA
teamstats$AwayAttPower=teamstats$AvgAwayGS/AvgAwayGS
teamstats$AwayDefPower=teamstats$AvgAwayGA/AvgAwayGA

teamstats$HomeW<-0
teamstats$HomeD<-0
teamstats$HomeL<-0
teamstats$AwayW<-0
teamstats$AwayD<-0
teamstats$AwayL<-0

for (i in c(1:20)){
	
#HomeStats
teamstats$HomeW[i]<-sum(data[data$HomeTeam==teamstats$Team[i],]$FTHG>data[data$HomeTeam==teamstats$Team[i],]$FTAG)
teamstats$HomeD[i]<-sum(data[data$HomeTeam==teamstats$Team[i],]$FTHG==data[data$HomeTeam==teamstats$Team[i],]$FTAG)
teamstats$HomeL[i]<-sum(data[data$HomeTeam==teamstats$Team[i],]$FTHG<data[data$HomeTeam==teamstats$Team[i],]$FTAG)

#AwayStats
teamstats$AwayW[i]<-sum(data[data$AwayTeam==teamstats$Team[i],]$FTHG<data[data$AwayTeam==teamstats$Team[i],]$FTAG)
teamstats$AwayD[i]<-sum(data[data$AwayTeam==teamstats$Team[i],]$FTHG==data[data$AwayTeam==teamstats$Team[i],]$FTAG)
teamstats$AwayL[i]<-sum(data[data$AwayTeam==teamstats$Team[i],]$FTHG>data[data$AwayTeam==teamstats$Team[i],]$FTAG)	

}

teamstats$HomePoints=3*teamstats$HomeW+teamstats$HomeD
teamstats$AwayPoints=3*teamstats$AwayW+teamstats$AwayD
teamstats$TotalPoints=teamstats$HomePoints+teamstats$AwayPoints

teamstats$Position=rank(-teamstats$TotalPoints,ties.method="random")
teamstats$Level=ifelse(teamstats$Position<=8,1,ifelse(teamstats$Position<=14,2,3))

dataA=merge(data, teamstats, by.x="AwayTeam", by.y="Team")
dataB=merge(data, teamstats, by.x="HomeTeam", by.y="Team")

MySerieAPredictor<-function(TeamA,TeamB){
	
#Obtaining original the dataset and merging it to the level of the opposing team
dataC=merge(data, teamstats, by.x="AwayTeam", by.y="Team")
dataD=merge(data, teamstats, by.x="HomeTeam", by.y="Team")
colnames(dataD)[ncol(dataD)]="HomeLevel"
dataE=merge(dataD, teamstats, by.x="AwayTeam", by.y="Team")
colnames(dataE)[ncol(dataE)]="AwayLevel"

#Select the data which contains ALL instances of a Level A Team playing a Level B Team
functiondata=dataE[(dataE$HomeLevel==teamstats[teamstats$Team==TeamA,]$Level)&(dataE$AwayLevel==teamstats[teamstats$Team==TeamB,]$Level),]

#---------------------MY TEST--------------------------

HomeGP=data.frame(table(functiondata$HomeTeam))
HomeGP<-HomeGP[!(HomeGP$Freq==0),]
AwayGP=data.frame(table(functiondata$AwayTeam))
AwayGP<-AwayGP[!(AwayGP$Freq==0),]

HomeGS=data.frame(aggregate(functiondata$FTHG, by=list(Category=functiondata$HomeTeam), FUN=sum))
HomeGA=data.frame(aggregate(functiondata$FTAG, by=list(Category=functiondata$HomeTeam), FUN=sum))

AwayGS=data.frame(aggregate(functiondata$FTAG, by=list(Category=functiondata$AwayTeam), FUN=sum))
AwayGA=data.frame(aggregate(functiondata$FTHG, by=list(Category=functiondata$AwayTeam), FUN=sum))

noteams=nrow(HomeGS)

functionteamstatsH=data.frame(cbind(HomeGP,HomeGS[2],HomeGA[2]))
colnames(functionteamstatsH)=c('Team', 'HomeGP','HomeGS', 'HomeGA')

functionteamstatsA=data.frame(cbind(AwayGP,AwayGS[2],AwayGA[2]))
colnames(functionteamstatsA)=c('Team','AwayGP','AwayGS', 'AwayGA')

functionteamstatsH$AvgHomeGS=functionteamstatsH$HomeGS/functionteamstatsH$HomeGP
functionteamstatsH$AvgHomeGA=functionteamstatsH$HomeGA/functionteamstatsH$HomeGP
functionteamstatsA$AvgAwayGS=functionteamstatsA$AwayGS/functionteamstatsA$AwayGP
functionteamstatsA$AvgAwayGA=functionteamstatsA$AwayGA/functionteamstatsA$AwayGP

AvgHomeGS=sum(functionteamstatsH$AvgHomeGS)/noteams
AvgHomeGA=sum(functionteamstatsH$AvgHomeGA)/noteams
AvgAwayGS=sum(functionteamstatsA$AvgAwayGS)/noteams
AvgAwayGA=sum(functionteamstatsA$AvgAwayGA)/noteams

functionteamstatsH$HomeAttPower=functionteamstatsH$AvgHomeGS/AvgHomeGS
functionteamstatsH$HomeDefPower=functionteamstatsH$AvgHomeGA/AvgHomeGA
functionteamstatsA$AwayAttPower=functionteamstatsA$AvgAwayGS/AvgAwayGS
functionteamstatsA$AwayDefPower=functionteamstatsA$AvgAwayGA/AvgAwayGA

TeamAGS=functionteamstatsH[functionteamstatsH$Team==TeamA,]$HomeAttPower
TeamAGA=functionteamstatsH[functionteamstatsH$Team==TeamA,]$HomeDefPower

TeamBGS=functionteamstatsA[functionteamstatsA$Team==TeamB,]$AwayAttPower
TeamBGA=functionteamstatsA[functionteamstatsA$Team==TeamB,]$AwayDefPower

TeamAExpGoal=TeamAGS*TeamBGA*AvgHomeGS
TeamBExpGoal=TeamBGS*TeamAGA*AvgAwayGS

maxprob=0
probdraw=0
probAW=0
probBW=0
for (i in c(0:9)){
	for (j in c(0:9)){
		probA=((exp(-TeamAExpGoal))*(TeamAExpGoal^i))/factorial(i)
		probB=((exp(-TeamBExpGoal))*(TeamBExpGoal^j))/factorial(j)
		prob=probA*probB
		if (i==j){
			probdraw=probdraw+prob
		}
		if (i>j){
			probAW=probAW+prob
		}
		if (i<j){
			probBW=probBW+prob
		}
		if (prob>maxprob){
			maxprob=prob
			scoreA=i
			scoreB=j
		}
	}
}

#print(TeamA)
#print(scoreA)
#print("-")
#print(scoreB)
#print(TeamB)

maxprobAB=max(probAW,probBW)
maxoutcome=max(maxprobAB,probdraw)

if (maxoutcome==probAW){
	print(TeamA)
}

if (maxoutcome==probBW){
	print(TeamB)
}

if (maxoutcome==probdraw){
	print('Draw')
}
	
}
