#Script used to preprocess Reuters data, trimming the article, removing stopwords, punctuation, numbers and tokenizing

library(stringr)
library(tm)
library(plyr)

#Cleaning Functions
stopWords <- stopwords("en")

#Cleaning the strings
Clean_String <- function(article){
	temp<-tolower(article) #LowerCase
	temp<-stringr::str_replace_all(temp,"[^a-zA-Z\\s]"," ") #Remove anything that is not a number or letter
	temp<-stringr::str_replace_all(temp,"[\\s]+"," ") #Shrink to one white space
	temp<-stringr::str_split(temp, " ")[[1]] #Split i.e. tokenize
	indexes<-which(temp == "") #Remove trails
	if (length(indexes)>0){
		temp<-temp[-indexes]
	}
	return(temp)
}

#Removing stopwords
Remove_Stopwords <- function(list){
	newlist=list[!(list %in% stopWords)]
}

#Removing numbers
Remove_Numbers <- function(list){
	removeNumbers(list)
}

#Applying Cleaning Functions
#Reuters - British Politics Data
reutersbpdata=read.csv('Data/DataReutersBP.csv')
headlinebp<-as.vector(reutersbpdata$Headline)
descriptionbp<-as.vector(reutersbpdata$Description)
datebp<-as.vector(reutersbpdata$Date)

cleanheadlinereutersbp=lapply(lapply(headlinebp, Clean_String), Remove_Stopwords)
cleandescriptionreutersbp=lapply(lapply(descriptionbp, Clean_String), Remove_Stopwords)

#Setup dataframe
dfbp=data.frame("Date"=datebp)
dfbp$Headline=headlinebp
dfbp$Description=descriptionbp
dfbp$HeadlineTerms= cleanheadlinereutersbp
dfbp$DescriptionTerms= cleandescriptionreutersbp

#Filter out non-Brexit items
brexitdfbp=data.frame()
for (i in 1:nrow(dfbp)){
	if((('brexit' %in% dfbp$HeadlineTerms[[i]]) || ('brexit' %in% dfbp$DescriptionTerms[[i]]))=='TRUE'){
		brexitdfbp <- rbind(brexitdfbp, dfbp[i,])
	}
}

brexitdfbp$HeadlineTerms <- vapply(brexitdfbp$HeadlineTerms, paste, collapse = " ", character(1L))
brexitdfbp$DescriptionTerms <- vapply(brexitdfbp$DescriptionTerms, paste, collapse = " ", character(1L))

#Reuters - British Economy Data
reutersbedata=read.csv('/Users/michaelfilletti/Desktop/Uni/AI/Data Science/Assignment/Data/DataReutersBE.csv')
headlinebe<-as.vector(reutersbedata$Headline)
descriptionbe<-as.vector(reutersbedata$Description)
datebe<-as.vector(reutersbedata$Date)

cleanheadlinereutersbe=lapply(lapply(lapply(headlinebe, Clean_String), Remove_Stopwords),Remove_Numbers)
cleandescriptionreutersbe=lapply(lapply(lapply(descriptionbe, Clean_String), Remove_Stopwords),Remove_Numbers)

#Setup dataframe
dfbe=data.frame("Date"=datebe)
dfbe$Headline=headlinebe
dfbe$Description=descriptionbe
dfbe$HeadlineTerms= cleanheadlinereutersbe
dfbe$DescriptionTerms= cleandescriptionreutersbe

#Filter out non-Brexit items
brexitdfbe=data.frame()
for (i in 1:nrow(dfbe)){
	if((('brexit' %in% dfbe$HeadlineTerms[[i]]) || ('brexit' %in% dfbe$DescriptionTerms[[i]]))=='TRUE'){
		brexitdfbe <- rbind(brexitdfbe, dfbe[i,])
	}
}

brexitdfbe$HeadlineTerms <- vapply(brexitdfbe$HeadlineTerms, paste, collapse = " ", character(1L))
brexitdfbe$DescriptionTerms <- vapply(brexitdfbe$DescriptionTerms, paste, collapse = " ", character(1L))

#Reuters - Brexit Section
reuterssedata=read.csv('Data/DataReutersSE.csv')
headlinese<-as.vector(reuterssedata$Headline)
descriptionse<-as.vector(reuterssedata$Description)
datese<-as.vector(reuterssedata$Date)

cleanheadlinereutersse=lapply(lapply(headlinese, Clean_String), Remove_Stopwords)
cleandescriptionreutersse=lapply(lapply(descriptionse, Clean_String), Remove_Stopwords)

#Setup dataframe
brexitdfse=data.frame("Date"=datese)
brexitdfse$Headline=headlinese
brexitdfse$Description=descriptionse
brexitdfse$HeadlineTerms= cleanheadlinereutersse
brexitdfse$DescriptionTerms= cleandescriptionreutersse

brexitdfse$HeadlineTerms <- vapply(brexitdfse$HeadlineTerms, paste, collapse = " ", character(1L))
brexitdfse$DescriptionTerms <- vapply(brexitdfse$DescriptionTerms, paste, collapse = " ", character(1L))

#Printing the results
print(head(brexitdfbp))
print(head(brexitdfbe))
print(head(brexitdfse))

write.csv(brexitdfbp, file = "Data/FinalDataReutersBP.csv")
write.csv(brexitdfbe, file = "Data/FinalDataReutersBE.csv")
write.csv(brexitdfse, file = "Data/FinalDataReutersSE.csv")