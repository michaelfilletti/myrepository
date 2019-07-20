--------------------------------------------------------------------------
BREXIT STUDY README FILE
--------------------------------------------------------------------------

--------------------------------------------------------------------------
Required packages - R
--------------------------------------------------------------------------

Collecting & Cleaning the Data:
- rvest
- Quandl
- tm
- plyr
- mipfp

Running the functions:
NOTE: When running on Ubuntu 18.04 tidytext, tm, dplyr and topicmodels require XML2 and GSL to be installed

- gtools
- chron
- stringr
- data.table
- tidyr
- xts (installs zoo package with it)
- tidytext
- topicmodels
- tm
- dplyr
- NLP

--------------------------------------------------------------------------
Required packages - Python
--------------------------------------------------------------------------

Collecting the Data:
- requests
- BeautifulSoup
- time
- urllib
- http.cookiejar
- urllib.request
- datetime
- re


--------------------------------------------------------------------------
Running the solution
--------------------------------------------------------------------------

1. Open OverallSolution.R found in "/Set/Your/Path/Here/Scripts/
2. Run the command source("/Set/Your/Path/Here/Scripts/Solutionv3.R") to begin the experiments. Using the setwd(dirname(sys.frame(1)$ofile))
   command, the working space will be set to the location of the file
3. Now run the other source commands (e.g. source("Solutionv32.R"))
4. Run each part of the OverallSolution.R file on a per step basis, not all at once, to be able to get results in the best format


--------------------------------------------------------------------------
File Structure and Info
--------------------------------------------------------------------------
The Assignment file contains the following:
- Documentation File
- Scripts Folder

The Scripts file is broken down as follows:
Data Folder
- Contains all data collected and required to run the solution
Data Collections Folder
- Contains all scripts that collect data. Note that the TOMScraper.ipynb file is a Jupyter Notebook, used to scrape the Times of Malta site
Data Cleaning Folder
- Contains all scripts related to preprocessing of collected data

Script Files:
OverallSolution.R
- This is the main script that will be used to run our functions and other scripts. It is broken down in steps, requesting the user to run the
scripts in order. For the first script to be run, it is important to input the path of the script on your own machine to be able to run the
rest of the scripts. Other scripts are run using relative paths. Each step should be run alone to understand the results best.

Solutionv3.R
- This is the first script that will be run by the OverallSolution.R script. It contains all required packages to run the solution, and extracts
the data from the data files. Its role is to prepare the data for the following scripts. SThe output of the CurrencyDataClean function is used to
run the other functions that follow.
Functions - CurrencyDataClean(CurrencyData)

Solutionv32.R
- This script is used to test the correlation of our news and financial data. Various functions and approaches are taken within this script, to
try and understand how the two datasets vary along the time period
Functions - OverallCorrelation(FinalData), CumulativeCorrelation(FinalData), WindowCorrelation(FinalData), AutoFinalDataCorrelation(FinalData)

Solutionv33.R
- This script focuses on the Abnormal Returns aspect of our solution. The results obtained from this function can vary, and depend on what the
user would like to see. The various prints have been commented out, however the user may experiment and comment/uncomment certain commands
Functions - AbnormalReturns(CurrencyData,eventdate,estimationwindow,eventwindowstart,eventwindowend,posteventwindow)

Solutionv34.R
-This file is all about using a topic extraction (LDA) approach taken to further investigate the obtained dates.
Functions - TopicExtraction(eventdate,eventwindowstart,eventwindowend,topics), TopicAnalysis(DateList)
