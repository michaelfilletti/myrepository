#News Scraper v2 - Script used to scrape data from the Reuters site, using rvest to carry this process out
#Headlines and article description scraped

library(rvest)

#Reuters - British Politics
#https://uk.reuters.com/news/archive/britain-politics?view=page&page=i&pageSize=10
rbplen=1000
rbph=character(rbplen*10)
rbpd=character(rbplen*10)
rbpt=character(rbplen*10)
for(i in 1:rbplen) {
  	#i1 <- sprintf('%02d', i) #Assigning the page 
  	#Setting up the URL and iterating for each page
  	url <- paste0("https://uk.reuters.com/news/archive/britain-politics?view=page&page=", i, "&pageSize=10")
  	scrheadlines <- html_nodes(read_html(url), "h3") %>% html_text() #Extract text from the 3rd largest heading
	scrdescription <- html_nodes(read_html(url), "p")  %>% html_text() #Extract text from the paragraph
	scrtimeperiod <- html_nodes(read_html(url), "span")  %>% html_text()
	l=length(scrheadlines) #Number of headlines
	actheadlines=substring(scrheadlines[-l+5:-l],10) #Remove irrelevant headlines and useless text
	a=length(actheadlines)
	actdescription=scrdescription[1:a] #Obtain relevant descriptions
	acttimeperiod=as.character(strptime(scrtimeperiod[6:(5+a)], format = "%d %b %Y",tz = "GMT")) #Convert time period from news format to R date format
	rbph[(1+(10*(i-1))):(i*10)]=actheadlines
	rbpd[(1+(10*(i-1))):(i*10)]=actdescription
	rbpt[(1+(10*(i-1))):(i*10)]=acttimeperiod
}
print(rbph)
print(rbpd)
print(rbpt)

rbpdf <- data.frame(rbph,rbpd,rbpt)
names(rbpdf) <- c('Headline','Description','Date')
write.csv(rbpdf, file = "Data/DataReutersBP.csv")

#Reuters - British Economy
#https://uk.reuters.com/news/archive/internal_reuterscoukservice_4?view=page&page=222&pageSize=10

rbelen=222
rbeh=character(rbplen*10)
rbed=character(rbplen*10)
rbet=character(rbplen*10)
for(i in 1:rbelen) {
  	#i1 <- sprintf('%02d', i)
  	url <- paste0("https://uk.reuters.com/news/archive/internal_reuterscoukservice_4?view=page&page=", i, "&pageSize=10")
  	scrheadlines <- html_nodes(read_html(url), "h3") %>% html_text() #Extract text from the 3rd largest heading
	scrdescription <- html_nodes(read_html(url), "p")  %>% html_text() #Extract text from the paragraph
	scrtimeperiod <- html_nodes(read_html(url), "span")  %>% html_text()
	l=length(scrheadlines) #List number of headlines
	actheadlines=substring(scrheadlines[-l+5:-l],10) #Remove irrelevant headlines and useless text
	a=length(actheadlines)
	actdescription=scrdescription[1:a] #Obtain relevant descriptions
	acttimeperiod=as.character(strptime(scrtimeperiod[6:(5+a)], format = "%d %b %Y",tz = "GMT")) #Convert time period from news format to R date format
	rbeh[(1+(10*(i-1))):(i*10)]=actheadlines
	rbed[(1+(10*(i-1))):(i*10)]=actdescription
	rbet[(1+(10*(i-1))):(i*10)]=acttimeperiod
}
print(rbeh)
print(rbed)
print(rbet)

rbedf <- data.frame(rbeh,rbed,rbet)
names(rbedf) <- c('Headline','Description','Date')
write.csv(rbedf, file = "Data/DataReutersBE.csv")

#Reuters - Brexit Section
#https://uk.reuters.com/news/archive/RCOMUK_Brexit?view=page&page=479&pageSize=10

rbslen=479
rbsh=character(rbslen*10)
rbsd=character(rbslen*10)
rbst=character(rbslen*10)
for(i in 1:rbslen) {
  	#i1 <- sprintf('%02d', i)
  	url <- paste0("https://uk.reuters.com/news/archive/RCOMUK_Brexit?view=page&page=", i, "&pageSize=10")
  	scrheadlines <- html_nodes(read_html(url), "h3") %>% html_text() #Extract text from the 3rd largest heading
	scrdescription <- html_nodes(read_html(url), "p")  %>% html_text() #Extract text from the paragraph
	scrtimeperiod <- html_nodes(read_html(url), "span")  %>% html_text()
	l=length(scrheadlines) #List number of headlines
	actheadlines=substring(scrheadlines[-l+5:-l],10) #Remove irrelevant headlines and useless text
	a=length(actheadlines)
	actdescription=scrdescription[1:a] #Obtain relevant descriptions
	acttimeperiod=as.character(strptime(scrtimeperiod[6:(5+a)], format = "%d %b %Y",tz = "GMT")) #Convert time period from news format to R date format
	rbsh[(1+(10*(i-1))):(i*10)]=actheadlines
	rbsd[(1+(10*(i-1))):(i*10)]=actdescription
	rbst[(1+(10*(i-1))):(i*10)]=acttimeperiod
}
print(rbsh)
print(rbsd)
print(rbst)

rbsdf <- data.frame(rbsh,rbsd,rbst)
names(rbsdf) <- c('Headline','Description','Date')
write.csv(rbsdf, file = "Data/DataReutersSE.csv")