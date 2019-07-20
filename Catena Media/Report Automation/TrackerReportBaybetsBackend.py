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

#Add email in client_secret.json to Sheets sharing
#email: baybets@expanded-future-218314.iam.gserviceaccount.com

#Obtaining and joining data from all different sources

#Extracting columns for Nifty Stats
sheet0 = client.open("February 2019 Raw Data Baybets operators NS") #Select entire workbook
worksheet0=sheet0.worksheet("Back end")
C=worksheet0.get_all_values()
NS=pd.DataFrame(C[1:], columns=C[0])

c=CurrencyRates()
month = 2
year = 2019
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
#pymapper = sheet0.worksheet("Python Mapper")
currencies = sheet0.worksheet("Currencies")
conversions = sheet0.worksheet("Conversions")
#deals = sheet0.worksheet("Deals")
trackerdb=sheet0.worksheet("Trackers")

conversions.update_cell(3, 2, USDEUR)
conversions.update_cell(4, 2, GBPEUR)

#Pym=pymapper.get_all_values()
Cur=currencies.get_all_values()
Con=conversions.get_all_values()
#Deal=deals.get_all_values()
Tra=trackerdb.get_all_values()

#Pym=pd.DataFrame(data=Pym[1:],columns=Pym[0])
Cur=pd.DataFrame(data=Cur[1:],columns=Cur[0])
Con=pd.DataFrame(data=Con[1:],columns=Con[0])
#Deal=pd.DataFrame(data=Deal[1:],columns=Deal[0])
Tra=pd.DataFrame(data=Tra[1:],columns=Tra[0])
#Pym=Pym.set_index('Operator')

sheet1 = client.open("Baybets February NS Data Python") #Select entire workbook
worksheet1=sheet1.worksheet("Data")
D=worksheet1.get_all_values()
MF2=pd.DataFrame(columns=D[0])

#---------------------------------------------------------------------------------------------
#Extracting Operator data
#---------------------------------------------------------------------------------------------

OpTR=np.asarray(NS.Brand)
Op=np.unique(OpTR)
for i in Op:
    TR=pd.DataFrame(columns=D[0])
    OpData=NS[NS.Brand==i]
    OpData=OpData.reset_index()
    l=len(OpData)

    TR['Operator']=[i]*l
    TR['Year']=year
    TR['Month']=month
    TR['Currency']=OpData['Currency']
    TR['Tracker']=OpData['Tracker']
    TR['Clicks']=OpData['Clicks']
    TR['NRC']=OpData['NRCs']
    TR['NDC']=OpData['NDCs']
    TR['QNDCs']=OpData['CPA Qualified NDCs']
    TR['Deposits']=OpData['Deposits']
    TR['Net Revenue']=OpData['Net Revenue']
    TR['Total Commission Operator']=OpData['Commission']
    
    if (TR['Deposits'].sum() != 0) and (TR['Deposits'].sum()!=''):
        TR['Deposits']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Deposits'].astype(float)
    
    if (TR['Net Revenue'].sum() != 0) and (TR['Net Revenue'].sum()!=''):
        TR['Net Revenue']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Net Revenue'].astype(float)
        #TR['Revenue Share (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[1,-1])*TR['Net Revenue (€)'].astype(float)
        
    #if (TR['CPA Qualified NDCs'].isnull().sum() != 0):
        #TR['CPA (€)']=float(TR.merge(Deal, left_on='Operator', right_on='Brand', how='inner').iloc[1,-2])*TR['QNDCs'].astype(float)
    
    #TR['Commission Baybets (€)']=TR['Revenue Share (€)']+TR['CPA (€)']
    
    if (TR['Total Commission Operator'].sum() != 0) and (TR['Total Commission Operator'].sum()!=''):
        TR['Total Commission Operator']=float(TR.merge(Con, left_on='Currency', right_on='Currency', how='inner').iloc[0,-1])*TR['Total Commission Operator'].astype(float)
    
    #if TR['Commission Operator (€)'].isnull().all()==True:
    #    TR['Total Commission (€)']=TR['Commission Baybets (€)']
    #else:
    #    TR['Total Commission (€)']=TR['Commission Operator (€)']
    
    MF2=MF2.append(TR, ignore_index=True)

worksheet3=sheet1.worksheet("Python Data Backend")
existing = gd.get_as_dataframe(worksheet3)
updated = MF2
gd.set_with_dataframe(worksheet3, updated)