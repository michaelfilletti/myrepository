# -*- coding: utf-8 -*-

#CREATING 2019 TRENDS BASED ON LEGACY AND NEW PLAYER DATA


import xlrd
import xlwt
import numpy as np
from numpy import inf
import pandas as pd
import scipy
from scipy import optimize
from sklearn.linear_model import LinearRegression
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import gspread_dataframe as gd
import datetime

#Limit dataframes to be correct up to 2 decimal points
pd.options.display.float_format = '{:20,.2f}'.format

#------------------------------------------------------------------------------
#LEGACY PLAYERS
#------------------------------------------------------------------------------

#PV OF LEGACY PLAYERS IS TAKEN TO BE THE AVERAGE OF THE PAST 3 MONTHS FOR ALL BRANDS
PVLegacy=pd.DataFrame(columns=range(1,13))
PVLegacy.insert(loc=0,column='Operator',value=lsum_customer_playervalue['Operator'])
PVLegacy.fillna(0, inplace=True)
PVLegacy.iloc[:,1:13]=pd.concat([lsum_customer_playervalue.iloc[:,-6:].mean(axis=1)]*13,axis=1) #UPDATE

#ADJUSTING PLAYER VALUES OF CERTAIN OPERATORS
PVLegacy.iloc[7,1:13]=lsum_customer_playervalue[lsum_customer_playervalue.Operator=='Dunder'].iloc[:,3:9].mean(axis=1).values[0]
PVLegacy.iloc[1,1:13]=lsum_customer_playervalue[lsum_customer_playervalue.Operator=='1xbet'].iloc[:,-7:].mean(axis=1).values[0]
PVLegacy.iloc[17,1:13]=lsum_customer_playervalue[lsum_customer_playervalue.Operator=='Wetten.com'].iloc[:,3:9].mean(axis=1).values[0]
PVLegacy.iloc[11,1:13]=lsum_customer_playervalue[lsum_customer_playervalue.Operator=='Mobilebet'].iloc[:,-3:].mean(axis=1).values[0]

#SET TOTAL NUMBER OF LEGACY PLAYERS TO BE THE MEAN OF THE LAST 6 MONTHS
PlayerNoLegacy=pd.DataFrame(columns=range(1,13)) 
PlayerNoLegacy.insert(loc=0,column='Operator',value=lsum_customers_number['Operator'])
PlayerNoLegacy.iloc[:,1:13]=pd.concat([lsum_customers_number.iloc[:,-6:].mean(axis=1)]*13,axis=1)

#MULTIPLYING NUMBER OF PLAYERS BY THEIR VALUE
RevenueLegacy=pd.DataFrame(columns=range(1,13)) 
RevenueLegacy.insert(loc=0,column='Operator',value=lsum_customers_number['Operator'])
RevenueLegacy.iloc[:,1:13]=PlayerNoLegacy.iloc[:,1:13].values*PVLegacy.iloc[:,1:13].values 


#------------------------------------------------------------------------------
#2018 PLAYERS
#------------------------------------------------------------------------------

#PV OF LEGACY PLAYERS IS TAKEN TO BE THE AVERAGE OF THE PAST 5 MONTHS FOR ALL BRANDS
PV2018=pd.DataFrame(columns=range(1,13)) #UPDATE
PV2018.insert(loc=0,column='Operator',value=sum_customer_playervalue['Operator'])
PV2018.iloc[:,1:13]=pd.concat([sum_customer_playervalue.iloc[:,-5:].mean(axis=1)]*13,axis=1) 


#OBTAINING PLAYER RETENTION
Retention2018=customer_playerretention.iloc[0:11][sum_customers_playerretention['Operator']].transpose() #UPDATE
Retention2018=Retention2018.reset_index(level=['Operator','Cohort Group'])
Retention18=sum_customers_playerretention
Retention18=Retention18[~Retention18.Operator.str.contains("ComeOn Brands")]
newdata=pd.DataFrame(columns=range(15,24)) #UPDATE
bigdatar = pd.concat([Retention18,newdata], axis=1)
bigdatar=bigdatar.sort_values(['Operator'])
bigdatar=bigdatar.reset_index()
bigdatar=bigdatar.drop(['index'],axis=1)

#FORECASTING PLAYER RETENTION
for i in range(0,len(bigdatar.iloc[:,0])):
    y=np.array(bigdatar.iloc[i,:][1:24])
    y=y.astype('float')
    while np.isnan(y).any()==True:
        if np.isnan(y)[len(y)-1]==True:
            y=y[0:len(y)-1]
        else:
            where_are_NaNs = np.isnan(y)
            y[where_are_NaNs] = 0
    while y[len(y)-1]>=0.51:
        y=y[0:len(y)-1]
        if len(y)==1:
            y=np.array(bigdatar.iloc[i,:][1:24])
            y=y.astype('float')
    while np.isnan(y).any()==True:
        if np.isnan(y)[len(y)-1]==True:
            y=y[0:len(y)-1]
        else:
            where_are_NaNs = np.isnan(y)
            y[where_are_NaNs] = 0
    x=np.array(range(1,len(y)+1))
    xl=1/np.exp(x.astype('float'))
    xl[xl == inf] = 999999
    reg = np.polyfit(xl,y,1)
    xtest = 1/np.exp(np.arange(len(xl)+1,25))
    ytest=reg[0]*xtest+reg[1]
    bigdatar.iloc[i,len(y)+1:25]=ytest


pv=sum_customer_playervalue[~sum_customer_playervalue.Operator.str.contains("ComeOn Brands")]
PV2018=pd.DataFrame(columns=range(0))
PV2018.insert(loc=0,column='Operator',value=pv['Operator'])
PV2018[1]=pv.iloc[:,-3:].mean(axis=1)

#Adjusting the player value for certain operators due to high level of skewness
PV2018.loc[PV2018['Operator']=='10bet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='10bet'].iloc[:,-5:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Novibet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Novibet'].iloc[:,-10:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Sportingbet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Sportingbet'].iloc[:,-7:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Bet-at-Home',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Bet-at-Home'].iloc[:,1:5].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Dunder',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Dunder'].iloc[:,-5:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Interwetten',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Interwetten'].iloc[:,-7:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Wetten.com',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Wetten.com'].iloc[:,-5:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Roy Richie',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Roy Richie'].mean(axis=1)
PV2018.loc[PV2018['Operator']=='LeoVegas',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='LeoVegas'].iloc[:,-7:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Dunder',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Dunder'].iloc[:,-5:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='22bet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='22bet'].iloc[:,2:9].mean(axis=1)
PV2018.loc[PV2018['Operator']=='SpinPalace',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='SpinPalace'].iloc[:,-2]
PV2018.loc[PV2018['Operator']=='Eurogrand',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Eurogrand'].iloc[:,-4:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Tipico',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Tipico'].iloc[:,-9:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Rizk Casino',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Rizk Casino'].iloc[:,-13:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='1xbet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='1xbet'].iloc[:,-7:].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Xtip.de',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Xtip.de'].iloc[:,-4:-1].mean(axis=1)
PV2018.loc[PV2018['Operator']=='Mobilebet',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Mobilebet'].iloc[:,-6:].mean(axis=1)


PV2018=pd.concat([sum_customer_playervalue.iloc[:,0:11],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1]
                ,PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1]],axis=1) #UPDATE
PV2018.columns=['Operator',0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23] #UPDATE
#PV2018.iloc[:,1:]=PV2018.iloc[:,1:].clip(lower=0)

#FIX OPERATORS WITH NOT ENOUGH DATA
#UPDATE
PV2018.loc[PV2018['Operator']=='22bet 2',:]=PV2018.loc[PV2018['Operator']=='22bet 2',:].fillna(float(sum_customer_playervalue[sum_customer_playervalue.Operator=='22bet 2'].iloc[:,1:3].mean(axis=1)))
#PV2018.loc[PV2018['Operator']=='Betfred',:]=PV2018.loc[PV2018['Operator']=='Betfred',:].fillna(float(sum_customer_playervalue[sum_customer_playervalue.Operator=='Betfred'].iloc[:,-5:].mean(axis=1)))
PV2018.loc[PV2018['Operator']=='Campobet',:]=PV2018.loc[PV2018['Operator']=='Campobet',:].fillna(float(sum_customer_playervalue[sum_customer_playervalue.Operator=='Campobet'].iloc[:,1:6].mean(axis=1)))
PV2018.loc[PV2018['Operator']=='Netbet',:]=PV2018.loc[PV2018['Operator']=='Netbet',:].fillna(float(sum_customer_playervalue[sum_customer_playervalue.Operator=='Netbet'].iloc[:,1:3].mean(axis=1)))
#PV2018.loc[PV2018['Operator']=='Casinoclub',1]=sum_customer_playervalue[sum_customer_playervalue.Operator=='Casinoclub'].iloc[:,-5:].mean(axis=1)

#Total Number of Players
#Assign Revenues for all current players we have in our pool
#Calculate Revenues using the following figures:
#Player Value - PV2018
#Number of customers - customers_number
#Retention Rate - bigdatar

count=-1
RevenueCurrent=pd.DataFrame(columns=range(1,13)) 
RevenueCurrent.insert(loc=0,column='Operator',value=PV2018['Operator'])
for i in PV2018['Operator']:
    count=count+1
    for l in range(1,11):
        for k in range(1,13):
            CohortRev=[0]*15
            count2=0
            for j in np.array(customers_number.index.levels[0][:-1]):
                count2+=1
                CohortRev[count2-1]=PV2018.iloc[count,len(customers_number.loc[(j,slice(None)),i])+l-1]*customers_number.loc[(j,0),i]*bigdatar.iloc[count,len(customers_number.loc[(j,slice(None)),i])+l-1] #update the +0 to -1
            RevenueCurrent.iloc[count,k]=np.nansum(CohortRev)

#--------------------------------2019 PLAYERS--------------------------------

#Player Value of legacy Players is taken to be the average of the past 3 months for all brands
pop2019=customers_number.loc[(slice(None),0),:].mean(axis=0)
Players2019=pd.DataFrame(columns=range(1,14)) #update 
Players2019.insert(loc=0,column='Operator',value=bigdatar['Operator'])
for i in range(1,14): #update
    Players2019.iloc[:,i]=np.array(bigdatar.iloc[:,i])*np.array(pop2019)
print(Players2019)

#Player Value for 2019 players is taken to be the average of all 2018 cohorts
PV2019=pd.concat([sum_customer_playervalue.iloc[:,0:9],PV2018[1],PV2018[1],PV2018[1],PV2018[1],PV2018[1]],axis=1) #UPDATE
PV2019.columns=['Operator',0,1,2,3,4,5,6,7,8,9, 10,11,12] #UPDATE
#PV2019.iloc[:,1:]=PV2019.iloc[:,1:].clip(lower=0)
 
#-----------------------------
#CHECK!!!
#-----------------------------
#No Deposit Bonus
#Exclude players that did not deposit anything in their first month when taking average
#Carry this out only for specific months
#Carry this out for certain operators
#Which operators still have a no deposit bonus

PV2019.loc[PV2019['Operator']=='Dunder',0]=dunderavg1
PV2019.loc[PV2019['Operator']=='Interwetten',0]=interwettenavg1
PV2019.loc[PV2019['Operator']=='Wetten.com',0]=wettenavg1
PV2019.loc[PV2019['Operator']=='Unibet',0]=unibetavg1

#Write
#bigdatar
#pop2019
#customers_playervalue

scope = ['https://spreadsheets.google.com/feeds',
         'https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('C:/Users/Michael Filetti/Downloads/client_secret.json', scope)
client = gspread.authorize(creds)
#email: baybets@expanded-future-218314.iam.gserviceaccount.com

sheet1=client.open('2019 Revenue Forecasts')
worksheet=sheet1.worksheet("bigdatar")
existing = gd.get_as_dataframe(worksheet)
updated = bigdatar
gd.set_with_dataframe(worksheet, updated)

sheet1=client.open('2019 Revenue Forecasts')
worksheet2=sheet1.worksheet("pop")
existing = gd.get_as_dataframe(worksheet2)
updated = pop2019.to_frame(name=None).reset_index()
gd.set_with_dataframe(worksheet2, updated)

sheet1=client.open('2019 Revenue Forecasts')
worksheet3=sheet1.worksheet("NewPlayerValue")
existing = gd.get_as_dataframe(worksheet3)
updated = PV2019.reset_index()
gd.set_with_dataframe(worksheet3, updated)

sheet1=client.open('2019 Revenue Forecasts')
worksheet4=sheet1.worksheet("RevenuesLegPl")
existing = gd.get_as_dataframe(worksheet4)
updated = RevenueLegacy
gd.set_with_dataframe(worksheet4, updated)

sheet1=client.open('2019 Revenue Forecasts')
worksheet5=sheet1.worksheet("RevenuesCurPl")
existing = gd.get_as_dataframe(worksheet5)
updated = RevenueCurrent
gd.set_with_dataframe(worksheet5, updated)

#Input into deal machine

#Player Retention
#Retention2019=customer_playerretention.iloc[0:10][sum_customers_playerretention['Operator']].transpose()
#Retention2019=Retention2019.reset_index(level=['Operator','Cohort Group'])

#Total Number of Players
#PlayerNoLegacy=pd.DataFrame(columns=range(1,13))
#PlayerNoLegacy.insert(loc=0,column='Operator',value=lsum_customers_number['Operator'])
#PlayerNoLegacy.iloc[:,1:13]=pd.concat([lsum_customers_number.iloc[:,-3:].mean(axis=1)]*13,axis=1)

#Total Revenue

