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

str(Projects$ProjectId)
str(Schedule$ProjectId)
str(Budget$project_id)

Fulldata1 <- Projects %>% 
  inner_join(Schedule, by = "ProjectId") 

Fulldata2 <- Schedule %>% 
  inner_join(Budget, by = c("ProjectId" = "project_id"))

table(Budget$project_id)

Projects$ProjectId2 <- gsub("-","",Projects$ProjectId)

