#setwd("C:/Users/yzamriy/Documents/Tools and Methodology/DS/Git/DDS")
#setwd("/home/yulia/Documents/Career/DDS/")
setwd("C:/Users/Zamriyka/Documents/GitHub/DDS")

library(tidyverse)
library(gridExtra)

Projects <- read_csv("DDC_sampledata Projects.csv")
Schedule <- read_csv("DDC_sampledata Schedule.csv")
Budget <- read_csv("DDC_sampledata Budget.csv")

#str(Projects)
#str(Schedule)
#str(Budget)

#table(Schedule$ProjectedProjectStart)

str(Projects$ProjectId)
str(Schedule$ProjectId)
str(Budget$project_id)

Projects$ProjectId2 <- sub("-","",Projects$ProjectId)
Schedule$ProjectId2 <- sub("-","",Schedule$ProjectId)
Budget$ProjectId2 <- sub("-","",Budget$project_id)

Projects <- Projects[!apply(is.na(Projects), 1, all),]
Schedule <- Schedule[!apply(is.na(Schedule[, 3:50]), 1, all),]
Budget <- Budget[!apply(is.na(Budget), 1, all),]

length(unique(Projects$ProjectId2))
#943
length(unique(Schedule$ProjectId2))
#998
length(unique(Budget$ProjectId2))
#214

# sum(!is.na(Schedule$ActProjectCloseout))
# 23
# sum(!is.na(Schedule$OrgProjectCloseout))
# 673

BudgetTemp <- Budget %>% 
  group_by(ProjectId2, pobject) %>% 
  summarize(PlannedAmtTtl = sum(PlannedAmt),
            CommittedAmtTtl = sum(CommittedAmt),
            LiquidatedAmtTtl = sum(LiquidatedAmt),
            AvailableAmt = sum(AvailableAmt))

BudgetTemp1 <- BudgetTemp %>% 
  select(ProjectId2, pobject, PlannedAmtTtl) %>% 
  spread(pobject, PlannedAmtTtl, sep = ".PlanAmt.")

BudgetTemp2 <- BudgetTemp %>% 
  select(ProjectId2, pobject, CommittedAmtTtl) %>% 
  spread(pobject, CommittedAmtTtl, sep = ".ComAmt.")

BudgetTemp3 <- BudgetTemp %>% 
  select(ProjectId2, pobject, LiquidatedAmtTtl) %>% 
  spread(pobject, LiquidatedAmtTtl, sep = ".LiqAmt.")

BudgetTemp4 <- BudgetTemp %>% 
  select(ProjectId2, pobject, AvailableAmt) %>% 
  spread(pobject, AvailableAmt, sep = ".AvailAmt.")

Budget_aggr <- Budget %>% 
  group_by(ProjectId2) %>% 
  summarize(PlannedAmtTtl = sum(PlannedAmt),
            CommittedAmtTtl = sum(CommittedAmt),
            LiquidatedAmtTtl = sum(LiquidatedAmt),
            AvailableAmtTtl = sum(AvailableAmt),
            AgcyName = first(AgcyName)) %>% 
  left_join(BudgetTemp1, by = "ProjectId2") %>% 
  left_join(BudgetTemp2, by = "ProjectId2") %>% 
  left_join(BudgetTemp3, by = "ProjectId2") %>% 
  left_join(BudgetTemp4, by = "ProjectId2") 
  
rm(list = c("BudgetTemp1", "BudgetTemp2", "BudgetTemp3", "BudgetTemp4", "BudgetTemp"))

Budget_aggr <- Budget_aggr[, !apply(is.na(Budget_aggr), 2, all)]
Budget_aggr[is.na(Budget_aggr)] <- 0
#summary(Budget_aggr)

#summary(Schedule)

datefor <- function(x) as.Date(x, format = '%Y-%m-%d')
Schedule[,3:51] <- lapply(Schedule[,3:51], datefor)

AllDates <- data.frame(AllDates = colnames(Schedule[,3:52]), row.names = NULL)

Schedule[, grepl("ProjectStart", colnames(Schedule))]
Schedule[, grepl("ProjectCloseout", colnames(Schedule))]

ScheduleSub <- Schedule %>%
#  filter(!is.na(OrgProjectCloseout) | !is.na(ActProjectCloseout)) %>% 
  filter(!is.na(OrgProjectCloseout)) %>% 
  select(ProjectId, ProjectId2,
         OrgProjectStart,
         OrgDesignStart,
         OrgDesignCompletion,
         OrgConstructionStart,
         OrgConstructionCompletion,
         OrgProjectCloseout
         # ActProjectStart,
         # ActDesignStart,
         # ActDesignCompletion,
         # ActConstructionStart,
         # ActConstructionCompletion,
         # ActProjectCloseout
         ) %>% 
  mutate(
         OrgInitiationDur = as.numeric(OrgDesignStart - OrgProjectStart),
         OrgDesignDur = as.numeric(OrgConstructionStart - OrgDesignStart),
         OrgConstructionDur = as.numeric(OrgConstructionCompletion - OrgConstructionStart),
         OrgCloseoutDur = as.numeric(OrgProjectCloseout - OrgConstructionCompletion),
         OrgProjectDur = as.numeric(OrgProjectCloseout - OrgProjectStart),
         OrgInitiationDurPct = round(OrgInitiationDur / OrgProjectDur, 2),
         OrgDesignDurPct = round(OrgDesignDur / OrgProjectDur, 2),
         OrgConstructionDurPct = round(OrgConstructionDur / OrgProjectDur, 2),
         OrgCloseoutDurPct = round(OrgCloseoutDur / OrgProjectDur, 2),
         # ActInitiationDur = ActDesignStart - ActProjectStart,
         # ActDesignDur = ActConstructionStart - ActDesignStart,
         # ActConstructionDur = ActConstructionCompletion - ActConstructionStart,
         # ActCloseoutDur = ActProjectCloseout - ActConstructionCompletion,
         # ActProjectDur = ActProjectCloseout - ActProjectStart,
         OrgProjectStartYear = format(OrgProjectStart, "%Y"),
         OrgProjectStartMonth = format(OrgProjectStart, "%m"),
         OrgDesignStartMonth = format(OrgDesignStart, "%m"),
         OrgConstructionStartMonth = format(OrgConstructionStart, "%m"),
         OrgProjectCloseoutYear = format(OrgProjectCloseout, "%Y"),
         OrgProjectCloseoutMonth = format(OrgProjectCloseout, "%m")
         # ActProjectStartYear = format(ActProjectStart, "%Y"),
         # ActProjectStartMonth = format(ActProjectStart, "%m"),
         # ActDesignStartMonth = format(ActDesignStart, "%m"),
         # ActConstructionStartMonth = format(ActConstructionStart, "%m"),
         # ActProjectCloseoutYear = format(ActProjectCloseout, "%Y"),
         # ActProjectCloseoutMonth = format(ActProjectCloseout, "%m")
         )

# sum(!is.na(ScheduleSub$OrgProjectCloseout))
# 673
# sum(!is.na(ScheduleSub$ActProjectCloseout))
# 23
# ScheduleSub[!is.na(ScheduleSub$ActProjectCloseout),]

# table(Projects$DivisionName)
# table(tolower(Projects$UnitName))
# table(Projects$Borough)
# table(Projects$Sponsor)
# table(Projects$PhaseName)
# table(Projects$ProjectType)
# table(Projects$Priority)
# table(Projects$DesignContractType)
# table(Projects$ConstructionContractType)

ProjectsSub <- Projects %>% 
  select(ProjectId, ProjectId2,
         DivisionName,
         UnitName,
         Borough,
         Sponsor,
         PhaseName,
         ProjectType,
         Priority,
         DesignContractType,
         ConstructionContractType) %>% 
  mutate(UnitName = tolower(UnitName))

# sapply(ProjectsSub, function(x) sum(is.na(x)))
# 
# table(ProjectsSub$DivisionName)
# table(ProjectsSub$UnitName)
# table(ProjectsSub$Borough)
# table(ProjectsSub$Sponsor)
# table(ProjectsSub$PhaseName)
# table(ProjectsSub$ProjectType)
# table(ProjectsSub$Priority)
# table(ProjectsSub$DesignContractType)
# table(ProjectsSub$ConstructionContractType)

ProjectsSub$DivisionName[is.na(ProjectsSub$DivisionName)] <- "Unknown"
ProjectsSub$UnitName[is.na(ProjectsSub$UnitName)] <- "Unknown"
ProjectsSub$Borough[is.na(ProjectsSub$Borough)] <- "Unknown"
ProjectsSub$Sponsor[is.na(ProjectsSub$Sponsor)] <- "Unknown"
ProjectsSub$PhaseName[is.na(ProjectsSub$PhaseName)] <- "Unknown"
ProjectsSub$ProjectType[is.na(ProjectsSub$ProjectType)] <- "Unknown"
ProjectsSub$Priority[is.na(ProjectsSub$Priority)] <- "Unknown"
ProjectsSub$DesignContractType[is.na(ProjectsSub$DesignContractType)] <- "Unknown"
ProjectsSub$ConstructionContractType[is.na(ProjectsSub$ConstructionContractType)] <- "Unknown"

ProjectsSub$Priority[ProjectsSub$Priority == "Mayoral In"] <- "Mayoral Initiative"

ProjectsSub <- ProjectsSub[!duplicated(ProjectsSub), ]
length(unique(ProjectsSub$ProjectId2))
#943
length(unique(ProjectsSub$ProjectId))
#945

FullDataWBudget <- ScheduleSub %>% 
  inner_join(ProjectsSub, by = "ProjectId") %>% 
  left_join(Budget_aggr, by = c("ProjectId2.x" = "ProjectId2")) %>% 
  filter(!is.na(OrgProjectDur))

summary(FullDataWBudget$PlannedAmtTtl)

FullData <- ScheduleSub %>% 
  inner_join(ProjectsSub, by = "ProjectId") %>% 
  filter(!is.na(OrgProjectDur))

FullData$ProjectId2.y <- NULL
FullData$ProjectId2 <- FullData$ProjectId2.x
FullData$ProjectId2.x <- NULL

save(FullData, file = "FullData.Rdata")

summary(FullData$OrgProjectDur)

dev.off()
hist(FullData$OrgProjectDur, 
     breaks = seq(0, 12000, 500) - 250,
     main = "Histogram for Original Project Duration (in Days)",
     xlab = NULL,
     cex.main = 1,
     xaxt = "n",
     yaxt = "n",
     col = "lightgrey")
axis(side=1, 
     at=seq(0, 12000, 1000), 
     labels=seq(0, 12000, 1000), 
     cex.axis = 0.5)
axis(side=2, 
     at=seq(0, 200, 50), 
     labels=seq(0, 200, 50), 
     cex.axis = 0.6)

FullData %>% 
  group_by(DivisionName) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

t.test(FullData$OrgProjectDur[FullData$DivisionName == "Infrastructure"],
       FullData$OrgProjectDur[FullData$DivisionName == "Public Buildings"])

FullData %>% 
  group_by(UnitName) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(Borough) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(Sponsor) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(ProjectType) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(Priority) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(DesignContractType) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  group_by(ConstructionContractType) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  filter(DivisionName == "Infrastructure") %>% 
  group_by(ProjectType) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  filter(DivisionName == "Infrastructure") %>% 
  group_by(Borough) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

FullData %>% 
  filter(DivisionName == "Infrastructure" & 
           (grepl("Trans", Sponsor) | grepl("Protection", Sponsor))) %>% 
  group_by(Borough) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

ProjectTypes = c("Street Reconstruction", "Water", "Other", "Ped Ramps", "Sidewalks")

ByBorough2 <- FullData %>% 
  filter(DivisionName == "Infrastructure" &
           ProjectType %in% ProjectTypes) %>% 
  group_by(Borough, ProjectType) %>% 
  summarize(AvgProjDur = mean(OrgProjectDur)) 
  
ggplot(ByBorough2, aes(Borough, AvgProjDur, fill = Borough)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~ProjectType) +
  scale_fill_brewer(palette="Accent") +
  ylab("Original Average Project Duration") +
  ggtitle("Average Duration (in Days) for Selected Infrastructure Projects by Borough") +
  theme(axis.title.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.y = element_text(size = 8),
        axis.text.y = element_text(size = 6),
        plot.title = element_text(size = 10)) 
  
  
FullData %>% 
  group_by(OrgProjectStartMonth) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n()) %>% 
  arrange(desc(AvgProjDur))

round(cor(FullData[,  c("OrgProjectDur", "OrgInitiationDurPct", "OrgDesignDurPct", "OrgConstructionDurPct", "OrgCloseoutDurPct")], 
             use = "pairwise")[-1, 1], 2)

round(cor(FullData[,  c("OrgInitiationDur", "OrgDesignDur", "OrgConstructionDur", "OrgCloseoutDur")], 
             use = "pairwise"),2)

ggplot(FullData[FullData$DivisionName == "Infrastructure",], 
       aes(OrgInitiationDurPct, OrgProjectDur , color = Borough)) + 
  geom_point() +
  xlab("Share of Initiation Stage in Total Duration") +
  ylab("Average Project Duration") +
  ggtitle("Infrastructure Projects Overal Duration vs. Initiation Stage") +
  theme(axis.title.x = element_text(size = 10),
        axis.title.y = element_text(size = 10),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.title = element_text(size = 10))

ggplot(FullData[FullData$DivisionName == "Public Buildings",], 
       aes(OrgInitiationDurPct, OrgProjectDur , color = Borough)) + 
  geom_point() +
  xlab("Share of Initiation Stage in Total Duration") +
  ylab("Average Project Duration") +
  ggtitle("Public Building Projects Overal Duration vs. Initiation Stage") +
  theme(axis.title.x = element_text(size = 10),
        axis.title.y = element_text(size = 10),
        legend.title = element_blank(),
        legend.text = element_text(size = 8),
        plot.title = element_text(size = 10))

grid.arrange(infra, pub)

ProjectStartMonth <- 
  FullData %>% 
  group_by(OrgProjectStartMonth) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())

ggplot(ProjectStartMonth, aes(OrgProjectStartMonth, AvgProjDur)) +
  geom_bar(stat = "identity") +
  xlab("Original Project Start Month") +
  ylab("Original Average Project Duration") 

ggplot(ProjectStartMonth, aes(OrgProjectStartMonth, n)) +
  geom_bar(stat = "identity") +
  xlab("Original Project Start Month") +
  ylab("Number of Projects by Start Month") 

a <- 
ggplot(ProjectStartMonthDivName, 
       aes(OrgProjectStartMonth, 
           AvgProjDur)) +
  geom_bar(stat = "identity", fill = "darkblue") +
  xlab("Original Project Start Month") +
  ylab("Average Project Duration (in days)") +
  facet_grid(.~DivisionName) +
  theme(axis.title.x = element_text(size = 7),
        axis.title.y = element_text(size = 7))

ProjectStartMonthDivName <- 
  FullData %>% 
  group_by(OrgProjectStartMonth, DivisionName) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())
b <-
ggplot(ProjectStartMonthDivName, aes(OrgProjectStartMonth, n)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  xlab("Original Project Start Month") +
  ylab("Number of Projects") +
  facet_grid(.~DivisionName) +
  theme(axis.title.x = element_text(size = 7),
        axis.title.y = element_text(size = 7))

grid.arrange(a, b)

cor(as.numeric(FullData$OrgProjectStartMonth), FullData$OrgProjectDur)

FullData %>% 
  filter(DivisionName == "Public Buildings") %>% 
  select(OrgProjectStartMonth, OrgProjectDur) %>% 
  mutate(OrgProjectStartMonth = as.numeric(OrgProjectStartMonth)) %>% 
  cor()


# UnitName <- 
#   FullData %>% 
#   group_by(UnitName) %>%  
#   summarize(AvgProjDur = mean(OrgProjectDur),
#             n = n())
# 
# ggplot(UnitName, aes(UnitName, AvgProjDur)) +
#   geom_bar(stat = "identity") +
#   theme(axis.text.x = element_text(angle = 90, size = 7), 
#         axis.title.y = element_text(size = 7),
#         plot.title = element_text(size = 10, hjust = 0.5)) +
#   xlab("Unit Name") +
#   ylab("Original Average Project Duration (in days)") +
#   ggtitle("Average Project Duration by Unit Name")
#   
# Borough <- 
#   FullData %>% 
#   group_by(Borough) %>%  
#   summarize(AvgProjDur = mean(OrgProjectDur),
#             n = n())
# 
# ggplot(Borough, aes(Borough, AvgProjDur)) +
#   geom_bar(stat = "identity") +
#   theme(axis.text.x = element_text(angle = 90, size = 7), 
#         axis.title.y = element_text(size = 7),
#         plot.title = element_text(size = 10, hjust = 0.5)) +
#   xlab("Borough") +
#   ylab("Original Average Project Duration (in days)") +
#   ggtitle("Average Project Duration by Borough")

Sponsor <- 
  FullData %>% 
  group_by(Sponsor) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())

ggplot(Sponsor, aes(x = reorder(Sponsor, -AvgProjDur), y = AvgProjDur)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Sponsor") +
  ylab("Original Average Project Duration (in days)") +
  ggtitle("Average Project Duration by Sponsor")

ProjectType <- 
  FullData %>% 
  group_by(ProjectType) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())

ggplot(ProjectType, aes(x = reorder(ProjectType, -AvgProjDur), y = AvgProjDur)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Project Type") +
  ylab("Original Average Project Duration (in days)") +
  ggtitle("Average Project Duration by Project Type")

Priority <- 
  FullData %>% 
  group_by(Priority) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())

#q_priority1 <-
ggplot(Priority, aes(x = reorder(Priority, -AvgProjDur), y = AvgProjDur)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Priority") +
  ylab("Original Average Project Duration (in days)") +
  ggtitle("Average Project Duration by Priority")

#q_priority2 <-
ggplot(Priority, aes(x = reorder(Priority, -AvgProjDur), y = n)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Priority") +
  ylab("Number of Projects") +
  ggtitle("Average Project Duration by Priority")

#grid.arrange(q_priority1, q_priority2)

DesignType <- 
  FullData %>% 
  group_by(DesignContractType) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())  

ggplot(DesignType, aes(x = reorder(DesignContractType, -AvgProjDur), y = AvgProjDur)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Design Contract Type") +
  ylab("Original Average Project Duration (in days)") +
  ggtitle("Average Project Duration by Design Contract Type")

ConstrType <- 
  FullData %>% 
  group_by(ConstructionContractType) %>%  
  summarize(AvgProjDur = mean(OrgProjectDur),
            n = n())  

ggplot(ConstrType, aes(x = reorder(ConstructionContractType, -AvgProjDur), y = AvgProjDur)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, size = 7), 
        axis.title.y = element_text(size = 7),
        plot.title = element_text(size = 10, hjust = 0.5)) +
  xlab("Construction Contract Type") +
  ylab("Original Average Project Duration (in days)") +
  ggtitle("Average Project Duration by Construction Contract Type")


