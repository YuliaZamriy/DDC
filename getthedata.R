#setwd("C:/Users/yzamriy/Documents/Tools and Methodology/DS/Git/DDS")
setwd("/home/yulia/Documents/Career/DDS/")

library(tidyverse)

Projects <- read_csv("DDC_sampledata Projects.csv")

ctypes <- paste("cc", strrep("D", 49), sep = '')
Schedule <- read_csv("DDC_sampledata Schedule.csv")

Budget <- read_csv("DDC_sampledata Budget.csv")

str(Projects)
str(Schedule)
str(Budget)

datefor <- function(x) as.Date(x, format = '%Y-%m-%d')
Schedule[,3:51] <- lapply(Schedule[,3:51], datefor)

table(Schedule$ProjectedProjectStart)