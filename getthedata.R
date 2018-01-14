
# install.packages("RSocrata")
# library("RSocrata")
# allSitesDataFrame <- ls.socrata("https://soda.demo.socrata.com")
# nrow(allSitesDataFrame) # Number of datasets
# allSitesDataFrame$title # Names of each dataset
#Schedule <- read_csv("DDC_sampledata Schedule.csv", col_types = ctypes)

#setwd("C:/Users/yzamriy/Documents/Tools and Methodology/DS/Git/DDS")
setwd("/home/yulia/Documents/Career/DDS/")

install.packages("tidyverse")
library(tidyverse)

Projects <- read_csv("DDC_sampledata Projects.csv")

ctypes <- paste("cc", strrep("D", 49), sep = '')
Schedule <- read_csv("DDC_sampledata Schedule.csv")
Budget <- read_csv("DDC_sampledata Budget.csv")

str(Projects)
str(Schedule)
str(Budget)

x <- as.Date(Schedule$ProjectedProjectStart, format = '%Y-%m-%d')

datefor <- function(x) as.Date(x, format = '%Y-%m-%d')
Schedule[,3:51] <- lapply(Schedule[,3:51], datefor)

table(Schedule$ProjectedProjectStart)