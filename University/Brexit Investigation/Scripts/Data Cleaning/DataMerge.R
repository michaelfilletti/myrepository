#Script used to merge the data from the Times of Malta and Reuters to be places in the BrexitNewsData.csv file

#Data Extraction
fdrbp=read.csv("Data/FinalDataReutersBP.csv")
fdrbe=read.csv("Data/FinalDataReutersBE.csv")
fdrse=read.csv("Data/FinalDataReutersSE.csv")
fdtom=read.csv("Data/FinalDataToM.csv")

names(fdtom)=c("X", "Date", "Article", "Tokens")
#Cleaning up the dataframe
#Removing any extra columns for the dataframes
fdtom$X = NULL
fdrbp$X = NULL
fdrbe$X = NULL
fdrse$X = NULL

#Combining the columns to match the TimesOfMalta format
fdrbp$Article <- paste(fdrbp$Headline, fdrbp$Description, sep=" ")
fdrbp$Tokens <- paste(fdrbp$HeadlineTerms, fdrbp$DescriptionTerms, sep=" ")
fdrbe $Article <- paste(fdrbe $Headline, fdDrbe $Description, sep=" ")
fdrbe $Tokens <- paste(fdrbe $HeadlineTerms, fdrbe $DescriptionTerms, sep=" ")
fdrse $Article <- paste(fdrse $Headline, fdrse $Description, sep=" ")
fdrse $Tokens <- paste(fdrse $HeadlineTerms, fdrse $DescriptionTerms, sep=" ")

#Dropping the extra columns
fdrbp$Headline = NULL
fdrbp$HeadlineTerms = NULL
fdrbp$Description = NULL
fdrbp$DescriptionTerms = NULL

fdrbe $Headline = NULL
fdrbe $HeadlineTerms = NULL
fdrbe $Description = NULL
fdrbe $DescriptionTerms = NULL

fdrse $Headline = NULL
fdrse $HeadlineTerms = NULL
fdrse $Description = NULL
fdrse $DescriptionTerms = NULL

#Adding source of news
fdtom$Source = "Times of Malta"
fdrbp$Source = "Reuters British Politics"
fdrbe$Source = "Reuters British Economy"
fdrse$Source = "Reuters Brexit"

BrexitData=rbind(fdtom,fdrbp,fdrbe,fdrse)
write.csv(BrexitData, file = "Data/BrexitNewsDataTest.csv")