#Script used to preprocess Times of Malt data, trimming the article, removing stopwords, punctuation, numbers and tokenizing

tomdata=read.csv('Data/news5.csv')
library(stringr)
library(tm)
library(plyr)
library(mipfp)

urls<-as.vector(tomdata$Article_URL)
article<-as.vector(tomdata$Article)

#Function to obtain the date from the URL
trimTOMurl<-function(url){
	cleanurl <- gsub("http://www.timesofmalta.com/articles/view/","",url) #Removing the first part of the URL
	urldate <- ISOdate(year=substr(cleanurl,1,4),month=substr(cleanurl,5,6),day=substr(cleanurl,7,8)) #Constructing a date from the date part of the URL
	urldate<-gsub(x=urldate,pattern=" 12:00:00",replacement="",fixed=T)
	return(urldate)
}

#Times of Malta articles need to have parts of the articles removed as they contribute nothing (and are in every article), so we mark their position and remove the part of the string in our function
tomtrimstart=285
tomtrimend=650
#Function to remove the irrelevant parts of the article
trimTOMarticle<-function(article){
	cleanarticle<-substring(article, tomtrimstart,nchar(article)-tomtrimend)
	return(cleanarticle)
}

#Running text preprocessing
#Converting to lower case
#Removing non-ASCII text and punctuationo
#Setting spaces between words
#Tokenizing
#Remoing any trails
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
stopWords <- stopwords("en")
Remove_Stopwords <- function(list){
	newlist=list[!(list %in% stopWords)]
}

#Removing numbers
Remove_Numbers <- function(list){
	removeNumbers(list)
}


dates=lapply(urls, trimTOMurl)
trimarticle=lapply(article,trimTOMarticle)
cleanarticletom=lapply(lapply(lapply(lapply(article, trimTOMarticle), Clean_String), Remove_Stopwords),Remove_Numbers)

tomdf=data.frame("Date"=array(unlist(dates)))
tomdf$Article=array(unlist(trimarticle))
tomdf$Tokens=array(cleanarticletom)
tomdf$Tokens <- vapply(tomdf $Tokens, paste, collapse = " ", character(1L))

#Writing the data to our 
write.csv(tomdf, file = "Data/FinalDataToMTest.csv")