# -*- coding: utf-8 -*-
# NiftyStats - Data Transformation - Step 1
# Extract data from Nifty Stats
#

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

sheet0 = client.open("19 May Weekly NS Data") #Select entire workbook
worksheet1=sheet0.worksheet("PyMapper")
D=worksheet1.get_all_values()
PM=pd.DataFrame(D[1:], columns=D[0])

worksheet0=sheet0.worksheet("Baybets")
C=worksheet0.get_all_values()
NS=pd.DataFrame(C[1:], columns=C[0])

month = 5
week='20'
year = 2019

indices=np.where(NS['Program'].isin(PM.iloc[:,0]))
#Flatten the list
flat_list = []
for sublist in indices:
    for item in sublist:
        flat_list.append(item)
df2=pd.DataFrame()        

for i in range(1,len(flat_list)):
    dfcache=NS.iloc[flat_list[i-1]:flat_list[i],:] #Section containing NS data
    Operator=dfcache['Program'].iloc[0]
    if (len(dfcache)>2):
        if dfcache['Total'].iloc[0]!='0':
            if ((dfcache.iloc[0,3]==dfcache.iloc[1,3])&(dfcache.iloc[0,1]==dfcache.iloc[1,1])):
                dfcache=dfcache.drop(dfcache.index[1])
            if (len(dfcache)>2):
                if ((dfcache.iloc[0,3]==dfcache.iloc[1,3])&(dfcache.iloc[0,1]==dfcache.iloc[1,1])):
                    dfcache=dfcache.drop(dfcache.index[1])
    if dfcache['Total'].iloc[0]=='0':
        dfcache=dfcache.drop(dfcache.index[1])
    dfcache=dfcache.drop(dfcache.index[0])
    l=len(dfcache)
    df=pd.DataFrame()
    df['Operator']=[Operator]*l
    df = df.set_index(dfcache.index)
    df['Week number']=week
    df['Program']=dfcache['Program']
    df['Total']=dfcache['Total']
    df['Impressions']=dfcache['Impressions']
    df['Raw']=dfcache['Raw']
    df['Unique']=dfcache['Unique']
    df['Registrations']=dfcache['Registrations']
    df['Sales']=dfcache['Sales']
    df['Rebills']=dfcache['Rebills']
    df['Refunds']=dfcache['Refunds']
    df['Chargebacks']=dfcache['Chargebacks']
    df['Points']=dfcache['Points']
    df2=df2.append(df, ignore_index=True)

df2=df2[df2['Program']!='Sites (Company Profit)']
df2=df2[df2['Program']!='Site Name (Net Revenue)']
df2=df2[df2['Program']!='Marketing Sources']
df2=df2[df2['Program']!='Channels (Net Rev)']
df2=df2[df2['Program']!='Profiles (Net Revenue)']
df2=df2[df2['Program']!='Brands (Net Rev) + Channels (Net Rev)']
df2=df2[df2['Program']!='Marketing Sources + Deposits']
df2=df2[df2['Program']!='Websites (Net Revenue)']
df2=df2[df2['Program']!='Campaigns (Net Revenue)']
df2=df2[df2['Program']!='Traffic Sources (Net Revenue)']

#Add email in client_secret.json to Sheets sharing
#email: baybets@expanded-future-218314.iam.gserviceaccount.com


worksheet3=sheet0.worksheet("Baybets NS Data")
existing = gd.get_as_dataframe(worksheet3)
updated = df2
gd.set_with_dataframe(worksheet3, updated)
