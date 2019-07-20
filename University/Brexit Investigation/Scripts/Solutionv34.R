#--------------------------------------------------------------------------------------------
#Two functions used to run LDA - TopicExtraction & Topic Analysis
#Running the LDA on specific days, or looping to obtain entire timelines
#Returning a plot which shows the top topics (based on probabilities)
#--------------------------------------------------------------------------------------------

#TopicExtraction is a function that will identify the top 20 topics within a specific event window

TopicExtraction=function(event_date,StartEventTime,EndEventTime,k){
	
	#Filtering by the event window
	StartEventWindow=as.Date(as.Date(event_date)+StartEventTime)
	EndEventWindow=as.Date(as.Date(event_date)+EndEventTime)
	tokens=BrexitData[(as.Date(BrexitData$Date)<=EndEventWindow)&(as.Date(BrexitData$Date)>=StartEventWindow),]$Tokens
	corpus <- Corpus(VectorSource(tokens)) #Obtaining the corpus
	tdm=DocumentTermMatrix(corpus) #Setting up the Document Term Matrix
	
	#Running the LDA and obtaining its importance
	lda=LDA(tdm,k)
	test=tidy(lda,matrix="beta") #Using tidytext to obtain the beta probabilities
	TopTopics <- test %>% group_by(topic) %>% ungroup() %>%arrange(topic, -beta) #Sorting out the topics according in descending order (hence -beta)
	
	#Printing the results
	print(StartEventWindow)
	print(EndEventWindow)
	print(terms(lda))
	print(TopTopics)
	print(class(TopTopics))
	print(data.frame(TopTopics)[1:20,])
}
#TopicExtraction('2016-06-24',-5,5,2)


#TopicAnalysis is a function that will run the LDA in batches for many event windows, returning the results for all dates inputted and combining them into dataframe
#Once this is done, the function will plot a graph based on the words inputted in the InterestingTerms vector that will show whether the terms are popular or not within specific windows

TopicAnalysis=function(ListofDates){
	dataf=data.frame(matrix(ncol = 4, nrow = 0))
	colnames(dataf)=c("date","topic","term","beta")
	for (i in as.character(ListofDates)){
		test=TopicExtraction(i,-5,5,2)
		test=cbind(i,test)
		dataf=rbind(dataf,test)
	}

	#Cleaning the terms to avoid any punctuations
	dataf$term<-stringr::str_replace_all(dataf$term,"[^a-zA-Z\\s]","") #Remove anything that is not a number or letter

	#Words chosen when running the table(dataf$terms), there were around 100 words to be chose, however we chose some of the more interesting terms
	InterestingTerms=c("brexit","deal","delay","extension","referendum","theresa","vote")
	FilteredDataf=dataf[dataf$term %in% InterestingTerms, ]
	print(head(FilteredDataf))
	
	#Plotting terms that were within top 20 topics on specific dates
	print(ggplot(FilteredDataf, aes(fill= FilteredDataf$term, y= FilteredDataf$topic, x= FilteredDataf$i)) + 
	geom_bar( stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
	labs(title = "Frequency of topics in top 20 terms suggested by LDA", x = "Date", y="Topic Mentioned", fill="Topic"))
}

#TopicAnalysis(datelist)