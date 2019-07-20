# -*- coding: utf-8 -*-

#   PREPARING THE DATA
#1. OBTAINING DATA
#2. CREATING A PLAYER DATABASE
#3. CREATING COHORTS AND OBTAINING COHORT PERIODS
#4. OVERALL DATA FOR ALL OPERATORS - NEW PLAYERS
#5. OVERALL DATA FOR ALL OPERATORS - LEGACY PLAYERS

import xlrd
import xlwt
import numpy as np
import pandas as pd
from scipy import optimize

#Extraction of data from XLS file
workbook = xlrd.open_workbook(r'C:\Users\Michael Filetti\Downloads\Deal Machine v4 - March.xlsx') #UPDATE
worksheet = workbook.sheet_by_name('Player Data')

#Convert extracted data into a Pandas Dataframe
list1=[]
for i in range(worksheet.ncols):
    list1.append(worksheet.cell(0, i).value)
data=pd.DataFrame(columns=list1)
for col in range(worksheet.ncols):
    list2=[]
    for rows in range(1,worksheet.nrows):
         list2.append(worksheet.cell(rows, col).value)
    data.iloc[:,col]=list2
data['Player ID']=data['Player ID'].astype(str)
data.loc[(data['Year'] == 2019), 'Month'] = 12+data['Month'].astype('int')
data['Month']=data.Month.astype(int).astype(str)

#------------------------------------------------------------------------------
#CREATING A PLAYER DATABASE
#------------------------------------------------------------------------------
#Grouping data into a player database
list3=['Operator','PlayerID','Country','Tracker','Vertical','Market','RegistrationMonth','RegistrationYear','1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','Total'] #UPDATE
playerdata=pd.DataFrame(columns=list3)
pldata1=data.groupby(['Operator', 'Player ID']).size().reset_index(name='MonthsActive')

#Assigning the Operator and PlayerID into the playerdata df
playerdata['Operator']=pldata1['Operator']
playerdata['PlayerID']=pldata1['Player ID']

#Obtaining descriptive data and assigning it to each player by using a merge (Country, Tracker, Vertical, Reg Date etc.)
plmerge=playerdata.merge(data, left_on=['Operator','PlayerID'], right_on=['Operator','Player ID'], how='inner')
playerdata['Country']=plmerge['Country_y']
playerdata['Tracker']=plmerge['Tracker_y']
playerdata['Vertical']=plmerge['Vertical_y']
playerdata['Market']=plmerge['Market_y']
playerdata['RegistrationMonth']=plmerge['Registration Month']
playerdata['RegistrationYear']=plmerge['Registration Year']

#Assigning revenues to each month of the player database from the original data
number=data['Month'].unique()
for i in number:
    playerdata[i]=playerdata.merge(plmerge[plmerge['Month']==i],left_on=['Operator','PlayerID'], right_on=['Operator','Player ID'], how='left')['Net Revenue']
    playerdata[i]=playerdata[i].fillna(0)
playerdata['Total']=playerdata.iloc[:,8:22].sum(axis=1) #UPDATE

#Removing maximum values to remove the effect of certain VIP players in data df
vipplayers=playerdata.loc[playerdata.groupby('Operator')['Total'].idxmax()][['Operator','PlayerID']]
for i in range(0,len(data['Operator'].unique())):
    data=data.drop(data[(data['Operator']==vipplayers.iloc[i,0])&(data['Player ID']==vipplayers.iloc[i,1])].index)

#Removing maximum & minimum values to remove the effect of certain VIP players in playerdata df
playerdata=playerdata.drop(playerdata.groupby('Operator')['Total'].idxmax())
playerdata=playerdata.drop(playerdata.groupby('Operator')['Total'].idxmin())
playerdata = playerdata.reset_index(drop=True)

#------------------------------------------------------------------------------
#CREATING COHORTS AND OBTAINING COHORT PERIODS
#------------------------------------------------------------------------------

#Creating Cohort Analysis Tables
#https://assemblinganalytics.com/post/cohort-analysis-python/

df=pd.DataFrame(data=data[['Operator','Player ID','Registration Month','Registration Year','Registration MY','Month','Year','Deposits','Net Revenue']],columns=['Operator','Player ID','Registration Month','Registration Year','Registration MY','Month','Year','Deposits','Net Revenue'])
#df['Month']=np.where(df['Year']==2019.0,df['Month'].astype('int')+12,df['Month'])
df=df[df['Registration Month']!='']
df=df[df['Net Revenue']!=0] #Excludes all customers that generated nothing
df['Registration Year']=df['Registration Year'].astype('str')
df['Cohort Group']='nan'
#df['Cohort Group']=np.where(df['Registration Year'].str.contains('2018|2018.0'),df['Registration Month'],'Legacy')
df['Cohort Group']=np.where(df['Registration Year']=='2018.0',df['Registration Month'],np.where(df['Registration Year']=='2019.0',df['Registration Month']+12,np.where(df['Registration Year']=='2018',df['Registration Month'],'Legacy')))
#df['Cohort Group']=np.where(df['Registration Year']=='2019.0|2019',13,df['Cohort Group'])

#df['CohortPeriod'] = np.where(df['Registration Year']=='2019.0',df['Month'].astype('int')-13,(df['Month'].astype('int')-df['Registration Month'].astype('float')).astype('int'))
df['CohortPeriod'] = np.where(df['Cohort Group']=='Legacy',df['Month'].astype('int')-1,(df['Month'].astype('int')-df['Registration Month'].astype('float')).astype('int'))
df.loc[(data['Registration Year'] == 2019), 'CohortPeriod'] = df['Month'].astype('int')-12-df['Registration Month'].astype('int')

#All periods of players (incl. Legacy)
test1=['Legacy','0','1','2','3','4','5','6','7','8','9','10','11','12','13','14'] #UPDATE

#Removing any negative cohorts that may show (this rarely occurs however may happen due to a date formatting issue)
for r in range(1,16): #UPDATE
    df=df[df['CohortPeriod']!=-r]

#Removing operators that are not necessary/required
df=df[~df.Operator.str.contains("Skybet.de")]
df=df[~df.Operator.str.contains("ComeOn Brands")]
df=df[~df.Operator.str.contains("Bet3000 CPA")]
df=df[~df.Operator.str.contains("Bethard")]

#Obtaining all cohort periods, groups and the operator list
cohort_month=df['CohortPeriod'].unique()
cohort_group=df['Cohort Group'].unique()
operatorlist=df['Operator'].unique()

#Building the dataframe containing all cohorts and number of players
cohorts = df.groupby(['Cohort Group', 'CohortPeriod','Operator']).agg({'Player ID': pd.Series.nunique,'Net Revenue': np.sum})
cohorts.rename(columns={'Player ID': 'TotalCustomers'}, inplace=True)

#Reset indices to allow for merging and cleaning up
cohorts = cohorts.reset_index()

#def cohort_period(df):
    #Step 1, take the length of the dataframe; step 2, calculate a range from 0 
    #to the length of the df; step 3, apply the calculated range as new column to
    #the df (memo: this works because "Period" is sorted ascending already)
    #df['CohortPeriod'] = np.where(df['Cohort Group']=='Legacy',df['Month'].astype('int'),df['Month'].astype('int')-df['Registration Month'].astype('float'))
    #return df

#cohorts = cohorts.groupby(['Cohort Group','Operator']).apply(cohort_period)

#print(cohorts.head())

# Pivot with unstack(0) so that we have a column for each period, then divide by total
# customers per cohort group

#Modifies the dataframe and set index based on operator, cohort group and period
cohorts.set_index(['Operator','Cohort Group','CohortPeriod'], inplace=True)

#Calling only legacy players
#cohorts.loc[(slice(None),'Legacy',slice(None)),:]['TotalCustomers'].unstack(0)

#Splitting New and Legacy Players
legacycohorts=cohorts.loc[(slice(None),'Legacy',slice(None)),:]
cohorts=cohorts.loc[(slice(None),cohort_group[0:16],slice(None)),:]#UPDATE

#Obtaining the initial number of players each cohort has
cohort_group_size = cohorts.groupby(['Operator','Cohort Group'])['TotalCustomers'].first()
lcohort_group_size = legacycohorts.groupby(['Operator','Cohort Group'])['TotalCustomers'].first()

#Obtaining the total number of customers obtained, total rev, retention and player value for each cohort
#New Players
customers_number = cohorts['TotalCustomers'].unstack(0)
customer_totalrevenue = cohorts['Net Revenue'].unstack(0)
customer_playerretention = customers_number.unstack(0).divide(cohort_group_size,axis=1)
customer_playervalue = cohorts['Net Revenue'].unstack(0).divide(customers_number, axis=1)

#Legacy Players
lcustomers_number = legacycohorts['TotalCustomers'].unstack(0)
lcustomer_totalrevenue = legacycohorts['Net Revenue'].unstack(0)
lcustomer_playerretention = lcustomers_number.unstack(0).divide(lcohort_group_size,axis=1)
lcustomer_playervalue = legacycohorts['Net Revenue'].unstack(0).divide(lcustomers_number, axis=1)

#------------------------------------------------------------------------------
#OVERALL DATA FOR ALL OPERATORS - NEW PLAYERS
#------------------------------------------------------------------------------

#Dataframe containing number of players within each cohort period
sum_customers_number=pd.DataFrame(columns=range(0,15)) #UPDATE
sum_customers_number.insert(loc=0,column='Operator',value=list(customers_number))
for i in range(0,15): #UPDATE
    sum_customers_number.iloc[:,i+1]=np.array(customers_number.loc[(slice(None),i),:].sum())
print(sum_customers_number)

#Dataframe containing total revenue within each cohort period
sum_customers_revenue=pd.DataFrame(columns=range(0,15)) #UPDATE
sum_customers_revenue.insert(loc=0,column='Operator',value=list(customer_totalrevenue))
for i in range(0,15): #UPDATE
    sum_customers_revenue.iloc[:,i+1]=np.array(customer_totalrevenue.loc[(slice(None),i),:].sum())
print(sum_customers_revenue)

#Dataframe containing retention within each cohort period
sum_customers_playerretention=pd.DataFrame(columns=range(0,15)) #UPDATE
sum_customers_playerretention.insert(loc=0,column='Operator',value=operatorlist)
count=0
for i in operatorlist:
    sum_customers_playerretention.iloc[count,1:16]=np.array(customer_playerretention.loc[:,(i,slice(None))].mean(axis=1)) #UPDATE
    count=count+1
print(sum_customers_playerretention)

#Dataframe containing customer value  within each cohort period
sum_customer_playervalue=pd.DataFrame(data=sum_customers_revenue.iloc[:,1:16].divide(sum_customers_number.iloc[:,1:16],axis=1),columns=range(0,15)) #UPDATE
sum_customer_playervalue.insert(loc=0,column='Operator',value=list(customer_playervalue))
print(sum_customer_playervalue)

#------------------------------------------------------------------------------
#OVERALL DATA FOR ALL OPERATORS - LEGACY PLAYERS
#------------------------------------------------------------------------------

#Dataframe containing number of players within each cohort period
lsum_customers_number=pd.DataFrame(columns=range(0,15)) #UPDATE
lsum_customers_number.insert(loc=0,column='Operator',value=list(lcustomers_number))
for i in range(0,15): #UPDATE
    lsum_customers_number.iloc[:,i+1]=np.array(lcustomers_number.loc[(slice(None),i),:].sum())
print(lsum_customers_number)

#Dataframe containing total revenue within each cohort period
lsum_customers_revenue=pd.DataFrame(columns=range(0,15)) #UPDATE
lsum_customers_revenue.insert(loc=0,column='Operator',value=list(lcustomer_totalrevenue))
for i in range(0,15): #UPDATE
    lsum_customers_revenue.iloc[:,i+1]=np.array(lcustomer_totalrevenue.loc[(slice(None),i),:].sum())
print(lsum_customers_revenue)

#Dataframe containing retention within each cohort period
lsum_customers_playerretention=pd.DataFrame(columns=range(0,15)) #UPDATE
lsum_customers_playerretention.insert(loc=0,column='Operator',value=list(lcustomers_number))
count=0
for i in list(lcustomers_number):
    lsum_customers_playerretention.iloc[count,1:16]=np.array(lcustomer_playerretention.loc[:,(i,slice(None))].mean(axis=1)) #UPDATE
    count=count+1
print(lsum_customers_playerretention)

#Dataframe containing customer value  within each cohort period
lsum_customer_playervalue=pd.DataFrame(data=lsum_customers_revenue.iloc[:,1:16].divide(lsum_customers_number.iloc[:,1:16],axis=1),columns=range(0,15)) #UPDATE
lsum_customer_playervalue.insert(loc=0,column='Operator',value=list(lcustomer_playervalue))
print(lsum_customer_playervalue)

#Obtaining the average revenue excl. no deposit bonus
dunderavg1=np.mean(df[(df['Operator']=='Dunder')&(df['Month'].apply(int)==df['Registration Month'])&(df['Registration Year'].astype(float).astype(int)==2018)&(df['Deposits']!=0)]['Net Revenue'])
interwettenavg1=np.mean(df[(df['Operator']=='Interwetten')&(df['Month'].apply(int)==df['Registration Month'])&(df['Registration Year'].astype(float).astype(int)==2018)&(df['Deposits']!=0)]['Net Revenue'])
wettenavg1=np.mean(df[(df['Operator']=='Wetten.com')&(df['Month'].apply(int)==df['Registration Month'])&(df['Registration Year'].astype(float).astype(int)==2018)&(df['Deposits']!=0)]['Net Revenue'])
unibetavg1=np.mean(df[(df['Operator']=='Unibet')&(df['Month'].apply(int)==df['Registration Month'])&(df['Registration Year'].astype(float).astype(int)==2018)&(df['Deposits']!=0)]['Net Revenue'])