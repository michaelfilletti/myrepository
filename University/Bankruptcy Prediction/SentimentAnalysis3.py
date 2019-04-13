import numpy as np
import pandas as pd
import datetime

#Year to run the query for
year=2016

#AVIATION
datacleaner(aviationdata,year)
words=""
for i in list(new.columns):
    words=words+" "+ new[i].map(str)

words=' '.join(words)
words=words.replace("None", "")
words=words.replace("nan", "")
words = nltk.word_tokenize(words)

words = normalize(words)
stems, lemmas = stem_and_lemmatize(words)

words=lemmas

p=np.sum(np.isin(np.array(words),np.array(dict[dict.Positive==1].Word)))
n=np.sum(np.isin(np.array(words),np.array(dict[dict.Negative==1].Word)))
u=np.sum(np.isin(np.array(words),np.array(dict[dict.Uncertainty==1].Word)))
l=np.sum(np.isin(np.array(words),np.array(dict[dict.Litigious==1].Word)))
c=np.sum(np.isin(np.array(words),np.array(dict[dict.Constraining==1].Word)))
s=np.sum(np.isin(np.array(words),np.array(dict[dict.Superfluous==1].Word)))
i=np.sum(np.isin(np.array(words),np.array(dict[dict.Interesting==1].Word)))
sent=pd.DataFrame(columns=['Sector', 'Negative', 'Positive', 'Uncertainty', 'Litigious', 'Constraining', 'Superfluous', 'Interesting', 'Total'])
sent.loc[len(sent)] = ['Aviation',n,p,u,l,c,s,i,len(words)]


#GAMING
datacleaner(gamingdata,year)
words=""
for i in list(new.columns):
    words=words+" "+ new[i].map(str)

words=' '.join(words)
words=words.replace("None", "")
words=words.replace("nan", "")
words = nltk.word_tokenize(words)

words = normalize(words)
stems, lemmas = stem_and_lemmatize(words)

words=lemmas
p=np.sum(np.isin(np.array(words),np.array(dict[dict.Positive==1].Word)))
n=np.sum(np.isin(np.array(words),np.array(dict[dict.Negative==1].Word)))
u=np.sum(np.isin(np.array(words),np.array(dict[dict.Uncertainty==1].Word)))
l=np.sum(np.isin(np.array(words),np.array(dict[dict.Litigious==1].Word)))
c=np.sum(np.isin(np.array(words),np.array(dict[dict.Constraining==1].Word)))
s=np.sum(np.isin(np.array(words),np.array(dict[dict.Superfluous==1].Word)))
i=np.sum(np.isin(np.array(words),np.array(dict[dict.Interesting==1].Word)))

sent.loc[len(sent)] = ('Gaming',n,p,u,l,c,s,i,len(words))

#MANUFACTURING
words=""
for i in list(new.columns):
    words=words+" "+ new[i].map(str)

words=' '.join(words)
words=words.replace("None", "")
words=words.replace("nan", "")
words = nltk.word_tokenize(words)

words = normalize(words)
stems, lemmas = stem_and_lemmatize(words)

words=lemmas
p=np.sum(np.isin(np.array(words),np.array(dict[dict.Positive==1].Word)))
n=np.sum(np.isin(np.array(words),np.array(dict[dict.Negative==1].Word)))
u=np.sum(np.isin(np.array(words),np.array(dict[dict.Uncertainty==1].Word)))
l=np.sum(np.isin(np.array(words),np.array(dict[dict.Litigious==1].Word)))
c=np.sum(np.isin(np.array(words),np.array(dict[dict.Constraining==1].Word)))
s=np.sum(np.isin(np.array(words),np.array(dict[dict.Superfluous==1].Word)))
i=np.sum(np.isin(np.array(words),np.array(dict[dict.Interesting==1].Word)))

sent.loc[len(sent)] = ('Manufacturing',n,p,u,l,c,s,i,len(words))

#PHARMACEUTICALS
datacleaner(pharmadata,year)
words=""
for i in list(new.columns):
    words=words+" "+ new[i].map(str)

words=' '.join(words)
words=words.replace("None", "")
words=words.replace("nan", "")
words = nltk.word_tokenize(words)

words = normalize(words)
stems, lemmas = stem_and_lemmatize(words)

words=lemmas
p=np.sum(np.isin(np.array(words),np.array(dict[dict.Positive==1].Word)))
n=np.sum(np.isin(np.array(words),np.array(dict[dict.Negative==1].Word)))
u=np.sum(np.isin(np.array(words),np.array(dict[dict.Uncertainty==1].Word)))
l=np.sum(np.isin(np.array(words),np.array(dict[dict.Litigious==1].Word)))
c=np.sum(np.isin(np.array(words),np.array(dict[dict.Constraining==1].Word)))
s=np.sum(np.isin(np.array(words),np.array(dict[dict.Superfluous==1].Word)))
i=np.sum(np.isin(np.array(words),np.array(dict[dict.Interesting==1].Word)))

sent.loc[len(sent)] = ('Pharmaceuticals',n,p,u,l,c,s,i,len(words))

#TOURISM
datacleaner(tourismdata,year)
words=""
for i in list(new.columns):
    words=words+" "+ new[i].map(str)

words=' '.join(words)
words=words.replace("None", "")
words=words.replace("nan", "")
words = nltk.word_tokenize(words)

words = normalize(words)
stems, lemmas = stem_and_lemmatize(words)


words=lemmas
p=np.sum(np.isin(np.array(words),np.array(dict[dict.Positive==1].Word)))
n=np.sum(np.isin(np.array(words),np.array(dict[dict.Negative==1].Word)))
u=np.sum(np.isin(np.array(words),np.array(dict[dict.Uncertainty==1].Word)))
l=np.sum(np.isin(np.array(words),np.array(dict[dict.Litigious==1].Word)))
c=np.sum(np.isin(np.array(words),np.array(dict[dict.Constraining==1].Word)))
s=np.sum(np.isin(np.array(words),np.array(dict[dict.Superfluous==1].Word)))
i=np.sum(np.isin(np.array(words),np.array(dict[dict.Interesting==1].Word)))

sent.loc[len(sent)] = ('Tourism',n,p,u,l,c,s,i,len(words))


#Creating the final dataset to work with
sectors=pd.value_counts(findata.nace).to_frame().reset_index()[1:5].iloc[:,0]
mydata=findata[findata['year_of_assessment']==year+1]

mydata=mydata[(mydata.nace==sectors.iloc[0])|(mydata.nace==sectors.iloc[1])|(mydata.nace==sectors.iloc[2])|(mydata.nace==sectors.iloc[3])]

mydata.nace.unique()
mydata['Positive%']=0
mydata['Negative%']=0
mydata['Total']=0
mydata['PositiveToNegative']=0
mydata['NegativeToPositive']=0

for i in range(0,4):
    mydata.loc[mydata['nace'] == sectors.iloc[i], 'Positive%'] = sent.Positive[i]/sent.Total[i]
    mydata.loc[mydata['nace'] == sectors.iloc[i], 'Negative%'] = sent.Negative[i]/sent.Total[i]
    #mydata.loc[mydata['nace'] == sectors.iloc[i], 'Total'] = sent.Total[i]
    mydata.loc[mydata['nace'] == sectors.iloc[i], 'PositiveToNegative'] = sent.Positive[i]/sent.Negative[i]
    #mydata.loc[mydata['nace'] == sectors.iloc[i], 'NegativeToPositive'] = sent.Negative[i]/sent.Positive[i]

mydata.to_csv('/Users/michaelfilletti/Desktop/mydata20161.csv')
