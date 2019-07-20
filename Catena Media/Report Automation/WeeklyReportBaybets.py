# -*- coding: utf-8 -*-

import gspread
from oauth2client.service_account import ServiceAccountCredentials
import numpy as np
import pandas as pd
import gspread_dataframe as gd
import datetime
import calendar
from forex_python.converter import CurrencyRates

# use creds to create a client to interact with the Google Drive API
scope = ['https://spreadsheets.google.com/feeds',
         'https://www.googleapis.com/auth/drive']
creds = ServiceAccountCredentials.from_json_keyfile_name('C:/Users/Michael Filetti/Downloads/client_secret.json', scope)
client = gspread.authorize(creds)

month = 7
week='27'
year = 2019

#Add email in client_secret.json to Sheets sharing
#email: baybets@expanded-future-218314.iam.gserviceaccount.com

#Obtaining and joining data from all different sources

#Extracting columns for Nifty Stats
sheet0 = client.open("Baybets July Weekly report by tracker") #Select entire workbook
worksheet0=sheet0.worksheet("Nifty stats")
C=worksheet0.get_all_values()
NS=pd.DataFrame(C[1:], columns=C[0])

c=CurrencyRates()
l=calendar.monthrange(year,month)[1]
USDEURArray=np.zeros(l)
GBPEURArray=np.zeros(l)
for i in range(0,l):
    date_obj=datetime.datetime(year, month, i+1)
    USDEURArray[i]=c.get_rate('USD', 'EUR', date_obj)
    GBPEURArray[i]=c.get_rate('GBP', 'EUR', date_obj)
USDEUR=np.mean(USDEURArray)
GBPEUR=np.mean(GBPEURArray)

#Extracting Operator info
pymapper = sheet0.worksheet("PyMapper")
currencies = sheet0.worksheet("Currencies")
conversions = sheet0.worksheet("Conversions")
deals = sheet0.worksheet("Deals")
trackerdb=sheet0.worksheet("Trackers")

conversions.update_cell(3, 2, USDEUR)
conversions.update_cell(4, 2, GBPEUR)

Pym=pymapper.get_all_values()
Cur=currencies.get_all_values()
Con=conversions.get_all_values()
Deal=deals.get_all_values()
Tra=trackerdb.get_all_values()
Pym=pd.DataFrame(data=Pym[1:],columns=Pym[0])
Cur=pd.DataFrame(data=Cur[1:],columns=Cur[0])
Con=pd.DataFrame(data=Con[1:],columns=Con[0])
Deal=pd.DataFrame(data=Deal[1:],columns=Deal[0])
Tra=pd.DataFrame(data=Tra[1:],columns=Tra[0])
Pym=Pym.set_index('Operator')

sheet1 = client.open("Baybets Weekly KPI Report v2.2") #Select entire workbook
worksheet1=sheet1.worksheet("Data")
D=worksheet1.get_all_values()
MF2=pd.DataFrame(columns=D[0])

#---------------------------------------------------------------------------------------------
#Extracting Operator data (Nifty Stats)
#---------------------------------------------------------------------------------------------

Op=np.asarray(Pym.index)
OpTR=np.asarray(list(Pym))
for i in Op:
    TR=pd.DataFrame(columns=D[0])
    OpNS=np.asarray(Pym.loc[i])
    #OpData=NS[(NS.Operator==i)&((NS['Week number']==week))]
    OpData=NS[(NS.Operator==i)]
    OpData=OpData.reset_index()
    l=len(OpData)

    TR['Operator']=[i]*l
    TR['Currency']=TR.merge(Cur, left_on='Operator', right_on='Brand', how='inner').iloc[:,-1]
    TR['Week number']=OpData['Week number']
    TR['Month']=month
    TR['Year']=year
    TR['Tracker']=OpData['Program']
    TR['Clicks']=OpData[Pym.loc[i].Clicks]
    TR['NRCs']=OpData[Pym.loc[i].NRCs]
    TR['NDCs']=OpData[Pym.loc[i].NDCs]
    TR['CPA Qualified NDCs']=OpData[Pym.loc[i].CPAQualifiedNDCs]
    TR['Deposits']=OpData[Pym.loc[i].Deposits]
    TR['Net Revenue']=OpData[Pym.loc[i].NetRevenue]
    TR['Commission']=OpData[Pym.loc[i].Commission]

    if (TR['Deposits'].sum() != 0) and (TR['Deposits'].sum()!=''):
        TR['Deposits (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Deposits'].astype(float)

    if (TR['Net Revenue'].sum() != 0) and (TR['Net Revenue'].sum()!=''):
        TR['Net Revenue (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Net Revenue'].astype(float)
        #TR['Revenue Share (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[0,-1])*TR['Net Revenue (€)'].astype(float)
    
    if (TR['Net Revenue'].sum()==''):
        TR['Net Revenue (€)']=0
    
    if (TR['Commission'].sum() != 0) and (TR['Commission'].sum()!=''):
        TR['Commission Operator (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Commission'].astype(float)
    
    #if (TR['CPA Qualified NDCs'].sum() != 0) and (TR['CPA Qualified NDCs'].sum()!=''):
        #TR['CPA (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[0,-2])*TR['CPA Qualified NDCs'].astype(float)
    
    #TR['Commission Baybets (€)']=TR['Revenue Share (€)']+TR['CPA (€)']

    #if (TR['Commission Operator (€)'].sum() != 0) and (TR['Commission Operator (€)'].sum()!=''):
    #    TR['Total Commission (€)']=TR['Commission Operator (€)']
    #else:
    #    TR['Total Commission (€)']=TR['Commission Baybets (€)']

    MF2=MF2.append(TR, ignore_index=True)

#---------------------------------------------------------------------------------------------
#Extracting Operator data (Backend)
#---------------------------------------------------------------------------------------------

worksheet0=sheet0.worksheet("Back end")
M=worksheet0.get_all_values()
BE=pd.DataFrame(M[1:], columns=M[0])
OpBE=np.asarray(BE.Brand)
OpBElist=np.unique(OpBE)
for i in OpBElist:
    TR=pd.DataFrame(columns=D[0])
    #OpData=BE[((BE.Brand==i)&(BE['Week number']==week))]
    OpData=BE[(BE.Brand==i)]
    OpData=OpData.reset_index()
    l=len(OpData)

    TR['Operator']=[i]*l
    TR['Currency']=TR.merge(Cur, left_on='Operator', right_on='Brand', how='inner').iloc[:,-1]
    TR['Week number']=OpData['Week number']
    TR['Month']=month
    TR['Year']=year
    TR['Tracker']=OpData['Tracker']
    TR['Clicks']=OpData['Clicks']
    TR['NRCs']=OpData['NRCs']
    TR['NDCs']=OpData['NDCs']
    TR['CPA Qualified NDCs']=OpData['CPA Qualified NDCs']
    TR['Deposits']=OpData['Deposits']
    TR['Net Revenue']=OpData['Net Revenue']
    TR['Commission']=OpData['Commission']

    if (TR['Deposits'].sum() != 0) and (TR['Deposits'].sum()!=''):
        TR['Deposits (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Deposits'].astype(float)

    if (TR['Net Revenue'].sum() != 0) and (TR['Net Revenue'].sum()!=''):
        TR['Net Revenue (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Net Revenue'].astype(float)
        #TR['Revenue Share (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[0,-1])*TR['Net Revenue (€)'].astype(float)
    
    if (TR['Net Revenue'].sum()==''):
        TR['Net Revenue (€)']=0
    
    if (TR['Commission'].sum() != 0) and (TR['Commission'].sum()!=''):
        TR['Commission Operator (€)']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Commission'].astype(float)
    
    #if (TR['CPA Qualified NDCs'].sum() != 0) and (TR['CPA Qualified NDCs'].sum()!=''):
        #TR['CPA (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[0,-2])*TR['CPA Qualified NDCs'].astype(float)

    #TR['Commission Baybets (€)']=TR['Revenue Share (€)']+TR['CPA (€)']

    #if (TR['Commission Operator (€)'].sum() != 0) and (TR['Commission Operator (€)'].sum()!=''):
    #    TR['Total Commission (€)']=TR['Commission Operator (€)']
    #else:
    #    TR['Total Commission (€)']=TR['Commission Baybets (€)']

    MF2=MF2.append(TR, ignore_index=True)

#Function to convert to an integer (and handle strings)
def mk_int(s):
    if isinstance(s, str)==True:
        s = s.strip()
    return int(s) if s else 0

#Function to convert to a float (and handle strings)
def mk_float(s):
    if isinstance(s, str)==True:
        s = s.strip()
    return float(s) if s else 0

#Mapping the trackers' domain, vertical and market
MF2.Domain=MF2.merge(Tra.drop_duplicates(subset=['Trackers']), left_on='Tracker', right_on='Trackers', how='left').iloc[:,-1]
MF2.Product=MF2.merge(Tra.drop_duplicates(subset=['Trackers']), left_on='Tracker', right_on='Trackers', how='left').iloc[:,-2]
MF2.Market=MF2.merge(Tra.drop_duplicates(subset=['Trackers']), left_on='Tracker', right_on='Trackers', how='left').iloc[:,-3]

#Finding the RS, CPA and Total Commission
MF2['Revenue Share (€)']=MF2.merge(Deal, left_on=['Operator'], right_on=['Brand'], how='left').iloc[:,-2].astype(float)*MF2['Net Revenue (€)'].apply(mk_float)
MF2['CPA (€)']=MF2.merge(Deal, left_on=['Operator'], right_on=['Brand'], how='left').iloc[:,-1].astype(float)*MF2['CPA Qualified NDCs'].apply(mk_int)

#MF2['Revenue Share (€)']=MF2.merge(Deal, left_on=['Operator','Account'], right_on=['Brand','Accounts'], how='inner').iloc[:,-2].astype(float)*MF2['Net Revenue'].apply(mk_float)
#MF2['CPA (€)']=MF2.merge(Deal, left_on=['Operator','Account'], right_on=['Brand','Accounts'], how='inner').iloc[:,-2].astype(float)*MF2['CPA Qualified NDCs'].apply(mk_int)

MF2['Commission Baybets (€)']=MF2['Revenue Share (€)']+MF2['CPA (€)']

#Finding the RS, CPA and Total Commission
MF2.loc[MF2['Commission']=='','Total Commission (€)']=MF2['Commission Baybets (€)']
MF2.loc[MF2['Commission']!='','Total Commission (€)']=MF2['Commission Operator (€)']

#Dealing with Negative Revenues and converting negative revs to 0 (unless they have a loss carry forward)
worksheet5=sheet1.worksheet("LCF")
R=worksheet5.get_all_values()
LCF=pd.DataFrame(R[1:], columns=R[0])
lcft=pd.DataFrame(MF2.groupby(['Operator'])['Total Commission (€)'].agg('sum'))
lcft['Operator']=lcft.index
negremove=list(lcft[(lcft['Total Commission (€)']<0)&(-lcft['Operator'].isin(list(LCF['Brand'])))]['Operator'])
MF2[MF2['Operator'].isin(negremove)]['Total Commission (€)']=0

#Pasting the data to the Python data sheet
worksheet3=sheet1.worksheet("Python Data")
existing = gd.get_as_dataframe(worksheet3)
updated = MF2
gd.set_with_dataframe(worksheet3, updated)

#keysheet = sheet1.worksheet("Key Sheet")
#keysheet.update_cell(3, 6, USDEUR)
#keysheet.update_cell(4, 6, GBPEUR)