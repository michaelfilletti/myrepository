#Creating Data Frame
library(openxlsx)
library(xlsx)
library(cluster)
library(kernlab)
library(ggplot2) #In the case that we need to use alpha, which is masked by this package we apply the command kernlab::alpha

mydata <- read.xlsx("/Users/michaelfilletti/Desktop/ThesisData/Edited Data copy.xlsx", sheetIndex = 1, startRow = 1, colNames = TRUE)
a <- mydata[,c(2,3,4,6,7,8,9,14,21,22,23,24,25,26,27,30)]
a<-a[-1001,]
a<-transform(a, gender = as.numeric(Sex)) #1 is female, 2 is male
a<-transform(a, country = as.numeric(countryName)) #Sorted in alphabetical order (i.e. Australia=1, UK=24 etc.)
BetPreference<-ifelse(a[,7]>a[,8],1,0) #1>Singles Bettor; 0>Combi Bettor
Loser<-ifelse(a[,6]>0,1,0) #1>Lost Money; 0>Won Money
PlatformPreference<-ifelse(a[,10]>a[,11],1,0) #1>Mobile Bettor; 0>Web Bettor
a<-a[,c(-2,-3)]
a5 <- a[,-1]
rownames(a5) <- a[,1]
#b3<-read.xlsx("/Users/michaelfilletti/Desktop/GPCR15.xlsx", startRow = 1, sheetIndex=1)

#TRAINING DATA
#To select 500 training points instead of using the entire data set
#Selecting half of each cluster
c[,20]<-factor(c[,20])
m1<-matrix(,0,0)
for (i in 1:9) {
	r<-c[c[,20]==i,]
	r1<-r[sample.int(nrow(r)/2),]
	m1<-rbind(m1,r1)
}

#Dataset is now halved
## CLASSIFICATION MODE
# default with factor response:
w<-c(10,10,10,15,15,5,5,5,5,5,2,2,15,1,1,3,3,3)
w<-matrix(w)
#w<-t(w)
sdata<-scale(m1[,-c(1,15,16,17,18,19,20)])
m<-cbind(sdata,m1[,c(15,16,17,18,19)])
for (j in 1:18) {
	m[,j]=m[,j]*w[j,1]
}
m<-data.frame(m)
m1<-data.matrix(m1, rownames.force = colnames(m1)) #Can be left as a dataframe
m1[,20]<-factor(m1[,20])
m2<-m1[,20]
m2<-factor(m2)
#Gaussian Classification
#Types of Kernels

#Spline Kernel
model <- gausspr(m,m2,kernel="splinedot",scaled=FALSE) #Standard GPC command #~Syntax for model formulae

print(model)
summary(model)

#TEST DATA
#Took predictions in pieces as R would not run everything together
sdata<-scale(c[,-c(1,15,16,17,18,19,20)])
btest<-cbind(sdata,c[,c(15,16,17,18,19)])
for (j in 1:18) {
	btest[,j]=btest[,j]*w[j,1]
}
btest<-data.frame(btest)
btest<-data.matrix(btest, rownames.force = colnames(c)) #Can be left as a dataframe
test<-predict(model,btest[c(1:400),-20])
test<-matrix(test)
test2<-predict(model,btest[c(401:800),-20])
test2<-matrix(test2)
test3<-predict(model,btest[c(801:996),-20])
test3<-matrix(test3)
pred<-rbind(test,test2,test3)

# Check accuracy:
table(pred,c[,20]) #essentially maps the predicted class of each entry and compares it to it's actual class
cnew<-cbind(c[,-20],pred)

#CLUSTER STATS
C<-matrix(,27,14)
s2<-matrix(,0,0)
n<-matrix(,9,1)
g<-matrix(,9,3)
for (i in 1:9)
{
p<-cnew[ cnew[,20] == i,-20]
q<-matrix(,0,0)
	for (j in 1:nrow(p))
	{
		q<-rbind(q,cnew[p[j,1]==cnew[,1],c(-15,-16,-17,-18,-19,-20)])
	}
avg<-colMeans(q[,-20])
avg <- format(avg, scientific = FALSE )

library(matrixStats) #Important package to extract stats from matrices
w1<-rownames(q)
o<-data.matrix(q, rownames.force = w)
max<-colMaxs(o)
min<-colMins(o)
ttt<-colnames(avg)
rbind(ttt,max)
rbind(ttt,min)

sums<-matrix(colSums(cnew[ cnew[,20] == i,c(17,18,19)]))
g[i,]<-t(sums)

C[(1+(3*(i-1))):(3+(3*(i-1))),]<-rbind(avg,max,min)
n[i,]<-nrow(cnew[cnew[,20]==i,])
}
n<-cbind(n,g)
write.xlsx(n, "/Users/michaelfilletti/Desktop/GPClusterSize4.xlsx")
write.xlsx(C, "/Users/michaelfilletti/Desktop/GPCR154test.xlsx")

#Illustrations - Test
m1plot<-data.frame(m1)
Cluster<-m1plot[,17]
CC<-Cluster[1:494,]
CC<-factor(CC)
ggplot (m1plot[1:494,], aes (x = m1plot[1:494,2], y = m1plot[1:494,3], color = CC)) + stat_density2d ()
Cluster<-bnew[,17]
CC<-Cluster
CC<-factor(CC)
ggplot (bnew, aes (x = bnew[,2], y = bnew[,3], color = CC)) + stat_density2d ()m

#ILLUSTRATIONS
fit <- prcomp(cnew[,-cnew(15,16,17,18,19,20)],retx=TRUE,center=TRUE,scale=TRUE) #Principal Component Analysis
scores<-fit$x #PCA values

#Select first two columns of PCA
PC1<-scores[,1] 
PC2<-scores[,2]

#Convert to matrices
PC1<-matrix(PC1)
PC2<-matrix(PC2)

#Create dataframe containing first two columns of PCA and categorical variable which we will base our graph on. In this case we are considering Clusters, however, we may include other categorical variables such as winners/losers, country, gender etc.
dat <- data.frame(x=PC1[1:996,],y=PC2[1:996,],
        grp = cnew[1:996,20]) 

#Create a custom color scale
myColors <- brewer.pal(9,"Set1") #Can contain at most 9 colours
dat$grp <- factor(cnew[1:996,20])
names(myColors) <- levels(dat$grp)
colScale <- scale_colour_manual(name = "grp",values = myColors)

p <- ggplot(dat,aes(x,y,colour = grp)) + geom_point() + ylim(-10, 20) + xlim(-22,3)
q <- ggplot(dat,aes(x,y,colour = grp)) + geom_point()
p10 <- p + colScale
#pc plots common customers
#px plots extreme customers
#Scaled plots
pc1 <- q %+% droplevels(subset(dat[(dat[,3]==1|dat[,3]==2|dat[,3]==3|dat[,3]==4|dat[,3]==5),])) + colScale
px1 <- q %+% droplevels(subset(dat[(dat[,3]==6|dat[,3]==7|dat[,3]==8|dat[,3]==9),])) + colScale
#Fixed axis plots
pc <- p %+% droplevels(subset(dat[(dat[,3]==1|dat[,3]==2|dat[,3]==3|dat[,3]==4|dat[,3]==5),])) + colScale
px <- p %+% droplevels(subset(dat[(dat[,3]==6|dat[,3]==7|dat[,3]==8|dat[,3]==9),])) + colScale

#Plot for each Cluster individually
p1 <- p %+% droplevels(subset(dat[(dat[,3]==1),])) + colScale
p2 <- p %+% droplevels(subset(dat[(dat[,3]==2),])) + colScale
p3 <- p %+% droplevels(subset(dat[(dat[,3]==3),])) + colScale
p4 <- p %+% droplevels(subset(dat[(dat[,3]==4),])) + colScale
p5 <- p %+% droplevels(subset(dat[(dat[,3]==5),])) + colScale
p6 <- p %+% droplevels(subset(dat[(dat[,3]==6),])) + colScale
p7 <- p %+% droplevels(subset(dat[(dat[,3]==7),])) + colScale
p8 <- p %+% droplevels(subset(dat[(dat[,3]==8),])) + colScale
p9 <- p %+% droplevels(subset(dat[(dat[,3]==9),])) + colScale