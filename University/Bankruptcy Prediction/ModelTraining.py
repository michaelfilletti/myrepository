#Model Testing
import pandas as pd
import numpy as np

from sklearn import linear_model
from sklearn import preprocessing
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
from imblearn.over_sampling import SMOTE
from sklearn.model_selection import cross_validate

from sklearn.linear_model import LogisticRegression
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.ensemble import IsolationForest
from sklearn.neural_network import MLPClassifier

from sklearn.feature_selection import RFECV
from mlxtend.feature_selection import SequentialFeatureSelector as sfs
from sklearn.decomposition import PCA


#---------------------Training and Test Set Split---------------------
#Financial Data + Sentimental Data
#X_train1, X_test1, y_train1, y_test1 = train_test_split(preprocessing.normalize(mydata[['D','Z','Positive%','Negative%','Total','PositiveToNegative','NegativeToPositive']].values), mydata['status'], test_size=0.2)
mydata2013=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/mydata20131.csv')
mydata2014=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/mydata20141.csv')
mydata2015=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/mydata20151.csv')
mydata2016=pd.read_csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Mining/Assignment/mydata20161.csv')

X_train, X_test, y_train, y_test = train_test_split(preprocessing.normalize(mydata2013[['A','B','C','D2','E','Z']].values), mydata2013['status'], test_size=0.2)

#Using Positive% sentiment scores
#X_train1, X_test1, y_train1, y_test1 = train_test_split(preprocessing.normalize(mydata2013[['A','B','C','D2','E','Z','Positive%']].values), mydata2013['status'], test_size=0.2)

#Using Negative% sentiment scores
#X_train1, X_test1, y_train1, y_test1 = train_test_split(preprocessing.normalize(mydata2013[['A','B','C','D2','E','Z','Negative%']].values), mydata2013['status'], test_size=0.2)

#Using PositiveToNegative sentiment scores
#X_train1, X_test1, y_train1, y_test1 = train_test_split(preprocessing.normalize(mydata2013[['A','B','C','D2','E','Z','PositiveToNegative']].values), mydata2013['status'], test_size=0.2)

#Using All sentiment scores
#X_train1, X_test1, y_train1, y_test1 = train_test_split(preprocessing.normalize(mydata2013[['A','B','C','D2','E','Z','Positive%','Negative%','PositiveToNegative']].values), mydata2013['status'], test_size=0.2)


#SMOTE
sm = SMOTE(k_neighbors=4,random_state=2)
X_train_res, y_train_res = sm.fit_sample(X_train, y_train)


#Logistic Regression
LR=linear_model.LogisticRegression(random_state=0, class_weight={0:1,1:14})
lrmodel=LR.fit(X_train, y_train) 
pred=LR.predict(X_test)
cmLR=confusion_matrix(pred,y_test)

#Decision Trees
dtmodel = DecisionTreeClassifier(max_features=3)
dtmodel.fit(X_train_res, y_train_res)
pred = dtmodel.predict(X_test)
cmDT=confusion_matrix(pred,y_test)

#Gradient Boosting Classifier
clfgbc = GradientBoostingClassifier(n_estimators=100, learning_rate=0.2, max_depth=4, random_state=0).fit(X_train, y_train)
clfgbc.fit(X_train_res, y_train_res)
y_pred=clfgbc.predict(X_test)
cmGB=confusion_matrix(y_pred,y_test)

#Neural Network
mlp = MLPClassifier(hidden_layer_sizes=(6,6),learning_rate='adaptive')
mlp.fit(X_train_res, y_train_res) 
y_pred=mlp.predict(X_test)
cmNN=confusion_matrix(y_pred,y_test)

#Isolation Forests
#ifclf = IsolationForest(random_state=0)
#ifclf.fit(X_train, y_train) 
#y_pred=ifclf.predict(X_test)
#cm=confusion_matrix(y_pred,y_test)
#print('Isolation Forest')
#print(cm)
#print('')

#Evaluation Method
TP=cmLR[0,0]
FP=cmLR[0,1]
TN=cmLR[1,1]
FN=cmLR[1,0]
AccLR=(TP+TN)/(TP+TN+FP+FN)
FNRateLR=FP/(FP+TN)

TP=cmDT[0,0]
FP=cmDT[0,1]
TN=cmDT[1,1]
FN=cmDT[1,0]
AccDT=(TP+TN)/(TP+TN+FP+FN)
FNRateDT=FP/(FP+TN)

TP=cmGB[0,0]
FP=cmGB[0,1]
TN=cmGB[1,1]
FN=cmGB[1,0]
AccGB=(TP+TN)/(TP+TN+FP+FN)
FNRateGB=FP/(FP+TN)

TP=cmNN[0,0]
FP=cmNN[0,1]
TN=cmNN[1,1]
FN=cmNN[1,0]
AccNN=(TP+TN)/(TP+TN+FP+FN)
FNRateNN=FP/(FP+TN)

print('Accuracy')
#print('Logistic Regression',AccLR)
#print('Decision Trees',AccDT)
#print('Gradient Boosting',AccGB)
print('Neural Networks',AccNN)
print('')
print('FN Rate')
#print('Logistic Regression',FNRateLR)
#print('Decision Trees',FNRateDT)
#print('Gradient Boosting',FNRateGB)
print('Neural Networks',FNRateNN)
print('')