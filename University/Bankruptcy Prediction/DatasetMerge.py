#Import packages
import numpy as np
import pandas as pd

#Dataset Merge and Financial Ratio creation
balancedata=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/OneDrive_1_29-10-2018/company_balance_sheet_data_uom.csv')
incomedata=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/OneDrive_1_29-10-2018/company_income_statement_data_uom.csv')
bidata=pd.merge(balancedata,incomedata,how='inner',left_on=list(incomedata)[0:10], right_on=list(balancedata)[0:10])
#Z-Score = 1.2A + 1.4B + 3.3C + 0.6D + 1.0E
bidata['A']=(bidata['2298']-bidata['3499'])/bidata['2299']
bidata['B']=bidata['7600']/bidata['2299']
bidata['C']=bidata['7050']/bidata['2299']
bidata['D']=bidata['2000']/bidata['3799']
bidata['D2']=(bidata['2299']-bidata['3799'])/bidata['3998']
bidata['E']=bidata['5099']/bidata['2299']
bidata['Zorig']=1.2*bidata['A'] + 1.4*bidata['B'] + 3.3*bidata['C'] + 0.6*bidata['D'] + 1.0*bidata['E']
bidata['Zalt']=0.717*bidata['A'] + 0.847*bidata['B'] + 3.107*bidata['C'] + 0.42*bidata['D2'] + 0.998*bidata['E']
bidata['TotalAssets']=bidata['2299']
bidata['TotalLiabilities']=bidata['3799']
bidata['TotalSales']=bidata['5099']
bidata['TotalRevenue']=bidata['5499']
bidata['TotalShareholderEquity']=bidata['3998']
bidata['RetainedEarnings']=bidata['7600']

#Using those columns that are relevant to us only
#df.loc[df['colA'] == 'a', 'colC'] = df['colB']
bidata['Z'] = np.where((bidata['D'] == 0), bidata['Zalt'],bidata['Zorig'])
findata=bidata[['company_ref_id','currency','status','year_of_assessment','nace','TotalAssets','TotalLiabilities',
                'TotalSales','TotalRevenue','TotalShareholderEquity','RetainedEarnings','A','B','C','D','D2','E','Zorig','Zalt','Z']]

#Removal of rows containing infinite or NA values
findata=findata.replace([np.inf, -np.inf], np.nan)
findata=findata.dropna()
findata.isna().sum()
pre=len(findata)
findata=findata.drop(findata[findata.status.isin(['DORMANT', 'NEXT RETUR'])].index)
post=len(findata)

#Conversion of string to classes
stat = {'LIVE': 0,'DEAD': 1} 
findata.status = [stat[item] for item in findata.status]
findata.status = findata.status.astype('category')