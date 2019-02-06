library(xlsx)
library(cluster)
library(ggplot2)
library(RColorBrewer)

mydata <- read.xlsx("/Users/michaelfilletti/Desktop/ThesisData/Edited Data copy.xlsx", startRow = 1, sheetIndex = 1, colNames = TRUE)
a <- mydata[,c(2,3,4,6,7,8,9,14,21,22,23,24,25,26,27,30)]
a<-a[-1001,]
a[, 'countryName']<-as.factor(a[, 'countryName'])
a[, 'Sex']<-as.factor(a[, 'Sex'])
country<-as.integer(a[, 'countryName'])
gender<-as.integer(a[, 'Sex'])
a<-cbind(a[,c(-2,-3)],country,gender)
a5<-a
rownames(a5) <- a[,1]

#Imports IDs of outliers
k<-read.xlsx("/Users/michaelfilletti/Desktop/LandR15.xlsx", sheetIndex = 1, startRow = 1)
k<-k[-383,]
g<-matrix(,0,0)
for(i in 1:nrow(k))
{
	g<-rbind(a[k[i,2]==a[,1],],g)
}
g1<-g[,-1]
sdata<-scale(g1)
aa<-g[,c(15,16)]
aa<-ifelse(sdata[,14]==2,1,0) #Convert country into factor

g[, 'country']<-as.factor(g[, 'country'])
g[, 'gender']<-as.factor(g[, 'gender'])
country<-as.integer(g[, 'country'])
gender<-as.integer(g[, 'gender'])
g<-cbind(g[,c(-15,-16)],country,gender)
BetPreference<-ifelse(g[,7]>g[,8],1,0) #1>Singles Bettor; 0>Combi Bettor
Loser<-ifelse(g[,6]>0,1,0) #1>Lost Money; 0>Won Money
PlatformPreference<-ifelse(g[,10]>g[,11],1,0) #1>Mobile Bettor; 0>Web Bettor
a5<-g
rownames(a5) <- g[,1]

#Standardizing the continuous variables
sdata<-scale(a5[,c(-1,-15,-16)])
gender<-g[,c(15,16)]
sdata<-cbind(sdata,gender)
gender<-ifelse(sdata[,15]==2,1,0)
sdata<-cbind(sdata[,c(-15)],gender,BetPreference,PlatformPreference,Loser)
rownames(sdata) <- g[,1]

w<-c(10,10,10,15,15,5,5,5,5,5,2,2,15,1,1,3,3,3)

#Important to note that in this case we are saving the customers removed and placing them in their own cluster

a12<-sdata #Backup of g1
k= matrix(, nrow=400, ncol=1)
gt=matrix(0, nrow=30, ncol=1)

#Selecting the outliers
#1st Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 6 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[1,]<-x1
k[(1):(colSums(gt)),]<-t(head(bt2,x1))
k1<-rownames(t1)
a12<-a12[c(-p[,3]),]

#2nd Iteration
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 6 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[2,]<-x1
k[(1+colSums(gt)-x1):(colSums(gt)),]<-t(head(bt2,x1))
k2<-rownames(t1)
a12<-a12[c(-p[,3]),]

#3rd Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 6 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[3,]<-x1
k[(1+colSums(gt)-x1):(colSums(gt)),]<-t(head(bt2,x1))
k3<-rownames(t1)
a12<-a12[c(-p[,3]),]

#4th Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 6 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[4,]<-x1
k[(1+colSums(gt)-x1):(colSums(gt)),]<-t(head(bt2,x1))
k4<-rownames(t1)
a12<-a12[c(-p[,3]),]

#5th Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 3 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[5,]<-x1
k[(1+colSums(gt)-x1):(colSums(gt)),]<-t(head(bt2,x1))
k5<-rownames(t1)
a12<-a12[c(-p[,3]),]

#6th Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,2) #Assigns 3 cluster variables to each customer
table(r2)

#Identifying the outliers
r13<-matrix(r2)
m<-cbind(a12[,1],r13)
m<- cbind(m, "index"=1:nrow(m)) 
p<-m[ m[,2] == 2,]
t1<-a12[c(p[,3]),]
bt2<-rownames(t1, do.NULL = TRUE, prefix = "row")
bt2<-matrix(bt2)
x1<-nrow(bt2)
gt[6,]<-x1
k[(1+colSums(gt)-x1):(colSums(gt)),]<-t(head(bt2,x1))
k6<-rownames(t1)
a12<-a12[c(-p[,3]),]

#7th Iteration 
d<-daisy(a12,"gower",TRUE,type=list(ordratio=14,asymm=c(15,16,17,18)),w) 
hc <- hclust(d, "complete") #Carries out complete hierarchical clustering using Sqrd Euclidean distance 
plot(hc, hang=-1) #Plots the dendogram of the clustering
r2 <- cutree(hc,5) #Assigns 5 cluster variables to each customer
table(r2)

#FINDING STATS OF CLUSTERS
#Clustered Customers
#Cluster Membership

r11<-matrix(r2)
m<-cbind(a12,r11)
s2<-matrix(,0,0)
for (i in 1:5)
{
	p<-m[ m[,19] == i,-19]
	aa<-rownames(p)
	p<-cbind(aa,p)
	q<-matrix(,0,0)
	for (j in 1:nrow(p))
	{
		q<-rbind(q,a[p[j,1]==a[,1],])
	}
#Assign Cluster Membership
s<-matrix(,0,0)
	for (k in 1:nrow(q))
	{
		s<-rbind(s,a[(q[k,1]==a[,1]),])
	}
s2<-rbind(s2,cbind(s,i+6))
}

#Removed Customers
#CLUSTER STATS
k1<-matrix(k1)
k1<-cbind(k1,12)
k2<-matrix(k2)
k2<-cbind(k2,13)
k3<-matrix(k3)
k3<-cbind(k3,14)
k4<-matrix(k4)
k4<-cbind(k4,15)
k5<-matrix(k5)
k5<-cbind(k5,16)
k6<-matrix(k6)
k6<-cbind(k6,17)
k0<-rbind(k1,k2,k3,k4,k5,k6)

#Cluster Membership
p2<-matrix(,0,0)
for (i in 1:nrow(k0))
{
p2<-rbind(p2,g[ k0[i,1] == g[,1],])
}
p2<-cbind(p2,k0[,2])

test<-colnames(b1)
colnames(p2)<-test
colnames(s2)<-test
b2<-rbind(s2,p2)
b<-rbind(b1,b2)
BetPreference<-ifelse(b[,7]>b[,8],1,0) #1>Singles Bettor; 0>Combi Bettor
Loser<-ifelse(b[,6]>0,1,0) #1>Lost Money; 0>Won Money
PlatformPreference<-ifelse(b[,10]>b[,11],1,0) #1>Mobile Bettor; 0>Web Bettor
b<-cbind(b[,-17],BetPreference,Loser,PlatformPreference,b[,17])

c<-matrix(,0,0)
c<-rbind(c,b[b[,20]==1,],b[b[,20]==2,])
d<-b[(b[,18]==1)&(b[,20]==4),]
d<-cbind(d[,-20],3)
colnames(d)<-colnames(c)
c<-rbind(c,b[b[,20]==3,],d)
e<-b[(b[,20]==5),]
e<-cbind(e[,-20],4)
d<-b[(b[,18]==0)&(b[,20]==4),]
d<-cbind(d[,-20],4)
colnames(d)<-colnames(c)
colnames(e)<-colnames(c)
c<-rbind(c,e,d)
e<-b[(b[,20]==6),]
e<-cbind(e[,-20],5)
colnames(e)<-colnames(c)
c<-rbind(c,e)
e<-b[(b[,20]==7),]
e<-cbind(e[,-20],6)
colnames(e)<-colnames(c)
c<-rbind(c,e)
e<-b[(b[,20]==8|b[,20]==16),]
e<-cbind(e[,-20],7)
colnames(e)<-colnames(c)
c<-rbind(c,e)
e<-b[(b[,20]==9|b[,20]==10|b[,20]==11|b[,20]==17),]
e<-cbind(e[,-20],8)
colnames(e)<-colnames(c)
c<-rbind(c,e)
e<-b[(b[,20]==12|b[,20]==13|b[,20]==14),]
e<-cbind(e[,-20],9)
colnames(e)<-colnames(c)
c<-rbind(c,e)
c

write.xlsx(c, "/Users/michaelfilletti/Desktop/GPR15.xlsx")

#CLUSTER STATS
C<-matrix(,27,14)
s2<-matrix(,0,0)
n<-matrix(,9,1)
g<-matrix(,9,3)
for (i in 1:9)
{
p<-c[ c[,20] == i,-20]
q<-matrix(,0,0)
	for (j in 1:nrow(p))
	{
		q<-rbind(q,a[p[j,1]==a[,1],c(-15,-16)])
	}
avg<-colMeans(q)
avg <- format(avg, scientific = FALSE )

library(matrixStats) #Important package to extract stats from matrices
w1<-rownames(q)
o<-data.matrix(q, rownames.force = w)
max<-colMaxs(o)
min<-colMins(o)
ttt<-colnames(avg)
rbind(ttt,max)
rbind(ttt,min)

sums<-matrix(colSums(c[ c[,20] == i,c(17,18,19)]))
g[i,]<-t(sums)

C[(1+(3*(i-1))):(3+(3*(i-1))),]<-rbind(avg,max,min)
n[i,]<-nrow(c[c[,20]==i,])
}
#Change column names
colnames(C)<-colnames(a[,c(-15,-16)])
#Exports matrix of averages, maximums and minimums of clusters to spreadsheet
write.xlsx(C, "/Users/michaelfilletti/Desktop/ClusterStatistics.xlsx")
n<-cbind(n,g)
write.xlsx(n, "/Users/michaelfilletti/Desktop/ClusterSize.xlsx")

#ILLUSTRATION OF CLUSTERING USING PCA
fit <- prcomp(c[,-c(1,15,16,17,18,19,20)],retx=TRUE,center=TRUE,scale=TRUE) #Principal Component Analysis
scores<-fit$x #PCA values

#Select first two columns of PCA
PC1<-scores[,1] 
PC2<-scores[,2]

#Convert to matrices
PC1<-matrix(PC1)
PC2<-matrix(PC2)

W1<-fit$rotation[,1] #Weights on PC1 variable
W2<-fit$rotation[,2] #Weights on PC2 variable
fit$rotation #Weights on all variables

screeplot(fit)
sdev$x #Returns the square roots of the eigenvalues of the components

#Create dataframe containing first two columns of PCA and categorical variable which we will base our graph on. In this case we are considering Clusters, however, we may include other categorical variables such as winners/losers, country, gender etc.
dat <- data.frame(x=PC1[1:996,],y=PC2[1:996,],
        grp = c[1:996,20]) 

dat$grp <- factor(c[1:996,20])

#Plot of clustered data
q <- ggplot(dat,aes(x,y,colour = grp)) + geom_point()

#pc1 plots common customers
#px1 plots extreme customers
pc1 <- q %+% droplevels(subset(dat[(dat[,3]==1|dat[,3]==2|dat[,3]==3|dat[,3]==4|dat[,3]==5),])) + xlab("PC1")+ylab("PC2")
px1 <- q %+% droplevels(subset(dat[(dat[,3]==6|dat[,3]==7|dat[,3]==8|dat[,3]==9),])) + xlab("PC1")+ylab("PC2")

#Individual plot for each cluster
p1 <- q %+% droplevels(subset(dat[(dat[,3]==1),])) + xlab("PC1")+ylab("PC2")
p2 <- q %+% droplevels(subset(dat[(dat[,3]==2),])) + xlab("PC1")+ylab("PC2")
p3 <- q %+% droplevels(subset(dat[(dat[,3]==3),])) + xlab("PC1")+ylab("PC2")
p4 <- q %+% droplevels(subset(dat[(dat[,3]==4),])) + xlab("PC1")+ylab("PC2")
p5 <- q %+% droplevels(subset(dat[(dat[,3]==5),])) + xlab("PC1")+ylab("PC2")
p6 <- q %+% droplevels(subset(dat[(dat[,3]==6),])) + xlab("PC1")+ylab("PC2")
p7 <- q %+% droplevels(subset(dat[(dat[,3]==7),])) + xlab("PC1")+ylab("PC2")
p8 <- q %+% droplevels(subset(dat[(dat[,3]==8),])) + xlab("PC1")+ylab("PC2")
p9 <- q %+% droplevels(subset(dat[(dat[,3]==9),])) + xlab("PC1")+ylab("PC2")