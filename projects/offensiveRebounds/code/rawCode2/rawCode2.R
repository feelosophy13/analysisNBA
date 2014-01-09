############ Objective
# This analysis attempts to determine whether NBA teams should place high emphasis
# on getting offensive rebounds (as opposed to getting quickly back on defense).




############ Some notes on NBA games
# There are 4 quarters and each quarter is 12 minutes long. Each overtime is 5 minutes.
#
# NBA playoffs began April 20, 2013 for the 2012 - 2013 season.
#
# Field goals include both 2-point and 3-point shots. It does not, however, include free
# throws.
#
# For playersData, an example of plus/minus (+/-) is as follows: suppose a player's team
# was 7.5 points better than their opponents when he was in the game (+7.5). When our player
# was not in the game, however, the team was 3.3 points worse than their opponents (-3.3). 
# To find this player's +/- rating, you simply take the difference of the two numbers, 
# which yields a rating of +10.8.
#
# The final four teams that played in the playoffs include San Antonio Spurs, 
# Miami Heat, Indiana Pacers, and Memphis Grizzlies. Miami Heat won the championship title.




############ Setting working directory
getwd()
setwd('/Users/hawooksong/Desktop/programming_projects/analysisNBA/projects/offensiveRebounds')
dir()




############ Loading data and R packages
#### loading processed data
load('../../data/processedData/teamsData.RData')

#### loading R packages
# install.packages('coin')
library(coin)  # for wilcox_test()
library(ggplot2)  # for ggplot()
library(car)
library(lsr)  # for leveneTest()
library(psych)  # for describe() and describeBy()
library(gridExtra)  # for grid.arrange()




############ Overview of teamsData
head(teamsData)
names(teamsData)
dim(teamsData)
str(teamsData)  # each column variable in correct datatype




###### subsetting won/lost games
rsTeamsData <- subset(teamsData, GameType=='regular season')
rsTeamsDataWins <- subset(rsTeamsData, GameOutcome=='win')
rsTeamsDataLosses <- subset(rsTeamsData, GameOutcome=='loss')




############ Saving key average metrics
rsAveragePoints <- round(mean(rsTeamsData$Points), 2)
rsAverageOpponentPoints <- round(mean(rsTeamsData$OpponentPoints), 2)
rsMedianOffensiveReboundPercentage <- median(rsTeamsData$OffensiveReboundPercentage)
rsMedianDefensiveReboundPercentage <- median(rsTeamsData$DefensiveReboundPercentage)
rsMedianOpponentOffensiveReboundPercentage <- median(rsTeamsData$OpponentOffensiveReboundPercentage)
rsMedianOpponentDefensiveReboundPercentage <- median(rsTeamsData$OpponentDefensiveReboundPercentage)

rsAveragePoints
rsAverageOpponentPoints
rsMedianOffensiveReboundPercentage
rsMedianOpponentOffensiveReboundPercentage
rsMedianDefensiveReboundPercentage
rsMedianOpponentDefensiveReboundPercentage

#### quick data quality check
max(rsTeamsData$OffensiveReboundPercentage)
max(rsTeamsData$DefensiveReboundPercentage)
max(rsTeamsData$OpponentOffensiveReboundPercentage)
max(rsTeamsData$OpponentDefensiveReboundPercentage)




############ Determing and subsetting best offensive teams, best defensive teams, teams
############ with the highest win percentages, and top 4 teams in the playoffs

######## best offensive teams (by average points per game during the regular season)
#### plot visual 
rsTeamsData$Team <- with(rsTeamsData, reorder(Team, Points, mean))  # Team factor reordered by average points per game
a1 <- ggplot(rsTeamsData, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  guides(fill=F) + 
  labs(title='(a1) Points by Team') + 
  theme(axis.text.x = element_text(angle=45, hjust=1))
a1 
dev.copy(png, './figures/rawFigures2/a1_boxplot_points_by_team.png')
dev.off()

#### regular season team points summary table
rsPointsSummaryTableByTeam <- describeBy(rsTeamsData$Points, rsTeamsData$Team)
rsPointsSummaryTableByTeam

#### subsetting top five best offensive teams
rsTeamsDataBestOffense <- subset(rsTeamsData, Team=='MIA' | Team=='SAS' | Team=='OKC' | 
                                   Team=='HOU' | Team=='DEN')
rsTeamsDataBestOffense$Team <- factor(as.character(rsTeamsDataBestOffense$Team))

#### overview
describeBy(rsTeamsDataBestOffense$Points, rsTeamsDataBestOffense$Team)


######## best defensive teams (by average opponent points per game during the regular season)
#### plot visual
rsTeamsData$Team <- with(rsTeamsData, reorder(Team, OpponentPoints, mean))
a2 <- ggplot(rsTeamsData, aes(x=Team, y=OpponentPoints, fill=Team)) + 
  geom_boxplot() + 
  guides(fill=F) + 
  ylab('Opponent Points') + 
  labs(title='(a2) Opponent Points by Team') +
  theme(axis.text.x = element_text(angle=45, hjust=1))
a2
dev.copy(png, './figures/rawFigures2/a2_boxplot_opponent_points_by_team.png')
dev.off()

#### regular season opponent team points summary table
rsOppPointsSummaryTableByTeam <- describeBy(rsTeamsData$OpponentPoints, rsTeamsData$Team)
rsOppPointsSummaryTableByTeam

#### subsetting top five best defensive teams
rsTeamsDataBestDefense <- subset(rsTeamsData, Team=='MEM' | Team=='IND' | Team=='CHI' | 
                                   Team=='LAC' | Team=='MIA')
rsTeamsDataBestDefense$Team <- factor(as.character(rsTeamsDataBestDefense$Team))

#### overview
describeBy(rsTeamsDataBestDefense$OpponentPoints, rsTeamsDataBestDefense$Team)


######## Teams with the highest win percentages during the regular season
#### plot visual
rsTeamsData$Team <- reorder(rsTeamsData$Team, as.numeric(rsTeamsData$GameOutcome))
a3 <- ggplot(rsTeamsData, aes(x=Team, fill=GameOutcome)) +
  geom_bar(position='fill') + 
  theme(axis.text.x = element_text(angle=45, hjust=1)) + 
  ylab('Win/Loss Percentage') + 
  labs(title='(a3) Win/Loss Percentage by Team')
a3
dev.copy(png, './figures/rawFigures2/a3_barplot_win_loss_percentage_by_team.png')
dev.off()

#### via table
rsTeamsWLTable <- table(rsTeamsData$GameOutcome, rsTeamsData$Team)
rsTeamsWLPercentagesTable <- 
  round(rsTeamsWLTable[2, ] / (rsTeamsWLTable[1, ] + rsTeamsWLTable[2, ]), 2)  # win percentages
rsTeamsWLPercentagesTable <- rsTeamsWLPercentagesTable[order(rsTeamsWLPercentagesTable)]  # ordered

rsTeamsWLTable
rsTeamsWLPercentagesTable

#### subsetting the top 5 teams with the highest win percentages
rsTeamsDataHighestWinPercentage <- subset(rsTeamsData, Team=='MEM' | Team=='LAC' | Team=='DEN'
                                          | Team=='SAS' | Team=='OKC' | Team=='MIA')
rsTeamsDataHighestWinPercentage$Team <- factor(as.character(rsTeamsDataHighestWinPercentage$Team))


######## Teams with the highest median offensive rebound percentages during the regular season
#### plot visual
rsTeamsData$Team <- with(rsTeamsData, reorder(Team, OffensiveReboundPercentage, median))
a4 <- ggplot(rsTeamsData, aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  guides(fill=F) + # this command removes the legend
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  ylab('Offensive Rebound Percentage') + 
  labs(title='(a4) Offensive Rebound Percentage by Team')
a4
dev.copy(png, './figures/rawFigures2/a4_boxplot_offensive_rebound_percentage_by_team.png')
dev.off()

#### subsetting the top 5 teams with the highest offensive rebound percentages 
rsTeamsDataHighestOffensiveReboundPercentage <- subset(rsTeamsData, 
                                                       Team=='CHI' | Team=='IND' | 
                                                         Team=='BRK' | Team=='MEM' | 
                                                         Team=='DEN')
rsTeamsDataHighestOffensiveReboundPercentage$Team <-
  factor(as.character(rsTeamsDataHighestOffensiveReboundPercentage$Team))

#### overview
describeBy(rsTeamsDataHighestOffensiveReboundPercentage$OffensiveReboundPercentage,
           rsTeamsDataHighestOffensiveReboundPercentage$Team)


######## Teams with the highest median defensive rebound percentages during the regular season
#### plot visual
rsTeamsData$Team <- with(rsTeamsData, reorder(Team, DefensiveReboundPercentage, median))
a5 <- ggplot(rsTeamsData, aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  guides(fill=F) + # this command removes the legend
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  ylab('Defensive Rebound Percentage') + 
  labs(title='(a5) Defensive Rebound Percentage by Team')
a5
dev.copy(png, './figures/rawFigures2/a5_boxplot_defensive_rebound_percentage_by_team.png')
dev.off()

#### subsetting the top 5 teams with the highest defensive rebound percentages
rsTeamsDataHighestDefensiveReboundPercentage <- subset(rsTeamsData, 
                                                       Team=='POR' | Team=='GSW' | 
                                                         Team=='WAS' | Team=='ORL' | 
                                                         Team=='HOU')
rsTeamsDataHighestDefensiveReboundPercentage$Team <-
  factor(as.character(rsTeamsDataHighestDefensiveReboundPercentage$Team))

#### overview
describeBy(rsTeamsDataHighestDefensiveReboundPercentage$DefensiveReboundPercentage, 
           rsTeamsDataHighestDefensiveReboundPercentage$Team)

######## top 4 teams in the playoffs
rsTeamsDataTop4Playoff <- subset(rsTeamsData, Team=='MIA' | Team=='SAS' | 
                                   Team=='IND' | Team=='MEM')




############ 1. Is there a positive correlation between offensive rebound percentage and 
############ team points?

######## offensive rebound percentage by score group
b1 <- ggplot(rsTeamsData, aes(x=ScoreGroup, y=OffensiveReboundPercentage, fill=ScoreGroup)) + 
  geom_boxplot() + 
  xlab('Score Group') +
  ylab('Offensive Rebound Percentage') + 
  labs(title='(b1) Offensive Rebound Percentage by Score Group') + 
  guides(fill=F)
b1
dev.copy(png, './figures/rawFigures2/b1_boxplot_offensive_rebound_percentage_by_score_group.png')
dev.off()

######## offensive rebound percentage vs. points by game outcome
b2 <- ggplot(rsTeamsData, aes(x=OffensiveReboundPercentage, y=Points, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formua=y~x, size=2) +
  xlab('Offensive Rebound Percentage') +
  labs(title='(b2) Offensive Rebound Percentage \n vs Points by Game Outcome') 
b2 
dev.copy(png, './figures/rawFigures2/b2_scatterplot_offensive_rebound_percentage_vs_points_by_game_outcome.png')
dev.off()

model1 <- lm(Points ~ OffensiveReboundPercentage, data=rsTeamsData)
summary(model1)

cor.test(rsTeamsData$OffensiveReboundPercentage, rsTeamsData$Points)  
# correlation stat. sig.

######## Answer: yes




############ 2. Is there a negative correlation between defensive rebound percentage and 
############ opponent opponent team points?

######## defensive rebound percentage by opponent score group
c1 <- ggplot(rsTeamsData, aes(x=OpponentScoreGroup, y=DefensiveReboundPercentage, fill=OpponentScoreGroup)) + 
  geom_boxplot() + 
  xlab('Opponent Score Group') +
  ylab('Defensive Rebound Percentage') +
  labs(title='(c1) Defensive Rebound Percentage by Opponent Score Group') + 
  guides(fill=F)
c1
dev.copy(png, './figures/rawFigures2/c1_boxplot_defensive_rebound_percentage_by_opponent_score_group.png')
dev.off()

######## defensive rebound percentage vs. opponent points by game outcome
c2 <- ggplot(rsTeamsData, aes(x=DefensiveReboundPercentage, y=OpponentPoints, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formua=y~x, size=2) +
  xlab('Defensive Rebound Percentage') +
  ylab('Opponent Points') +
  labs(title='(c2) Defensive Rebound Percentage vs. \n Opponent Points by Game Outcome')
c2
dev.copy(png, './figures/rawFigures2/c2_scatterplot_defensive_rebound_percentage_vs_opponent_points_by_game_outcome.png')
dev.off()

model2 <- lm(OpponentPoints ~ DefensiveReboundPercentage, data=rsTeamsData)
summary(model2)

cor.test(rsTeamsData$DefensiveReboundPercentage, rsTeamsData$OpponentPoints)
# correlation stat. sig.

######## Answer: yes




############ 3. Number of offensive/defensive reound performance by game outcome

######## offensive rebound percentages by game outcome
d1 <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Offensive Rebound Percentage') + 
  labs(title='(d1) Offensive Rebound Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsMedianOffensiveReboundPercentage, 
                   yend=rsMedianOffensiveReboundPercentage), 
               color='red'
  ) + 
  annotate('text', x=2.5, y=0.45, 
           label=paste('NBA teams\' \n median offensive \n rebound \n percentage:', 
                       rsMedianOffensiveReboundPercentage)) + 
  guides(fill=F) 
d1
dev.copy(png, './figures/rawFigures2/d1_boxplot_offensive_rebound_percentage_by_game_outcome.png')
dev.off()

######## comparing median offensive rebound percentages between won and lost games with
######## Mann-Whitney U test
#### 0. checking for roughly equal sample sizes
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. checking for normal/similar distributions
hist(rsTeamsDataWins$OffensiveReboundPercentage)
hist(rsTeamsDataLosses$OffensiveReboundPercentage)
describe(rsTeamsDataWins$OffensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$OffensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"

#### conducting Mann-Whitney U test
wilcox.test(rsTeamsDataWins$OffensiveReboundPercentage, 
            rsTeamsDataLosses$OffensiveReboundPercentage,
            paired=F)  
# p < 0.05; difference in median offensive rebound percentages stat. sig.

median(rsTeamsDataWins$OffensiveReboundPercentage)
median(rsTeamsDataLosses$OffensiveReboundPercentage)


######## defensive rebound percentages by game outcome
d2 <- ggplot(rsTeamsData, aes(x=GameOutcome, y=DefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Defensive Rebound Percentage') +
  labs(title='(d2) Defensive Rebound Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsMedianDefensiveReboundPercentage, 
                   yend=rsMedianDefensiveReboundPercentage), 
               color='red'
  ) + 
  annotate('text', x=2.5, y=0.87, 
           label=paste('NBA teams\' \n median defensive \n rebound \n percentage:', 
                       rsMedianDefensiveReboundPercentage)) +
  guides(fill=F)
d2
dev.copy(png, './figures/rawFigures2/d2_boxplot_defensive_rebound_percentage_by_game_outcome.png')
dev.off()

######## comparing median defensive rebound percentages between won and lost games with 
######## Mann-Whitney U test
#### 0. checking for roughly equal sample sizezs
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. checking for normal/similar distributions
hist(rsTeamsDataWins$DefensiveReboundPercentage)
hist(rsTeamsDataLosses$DefensiveReboundPercentage)
describe(rsTeamsDataWins$DefensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$DefensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"

#### conducting Mann-Whitney U test
wilcox.test(rsTeamsDataWins$DefensiveReboundPercentage, 
            rsTeamsDataLosses$DefensiveReboundPercentage, 
            paired=F)  
# p << 0.05; difference in median defensive rebound percentages is stat. sig.

median(rsTeamsDataWins$DefensiveReboundPercentage)
median(rsTeamsDataLosses$DefensiveReboundPercentage)


######## histogram of offensive rebound percentage by game outcome
d3 <- ggplot(rsTeamsData, aes(x=OffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  xlab('Offensive Rebound Percentage') + 
  labs(title='(d3) Histogram of Offensive Rebound \n Percentage by Game Outcome') 
d3
dev.copy(png, './figures/rawFigures2/d3_histogram_offensive_rebound_percentage_by_game_outcome.png')
dev.off()


######## histogram of defensive rebound percentage by game outcome
d4 <- ggplot(rsTeamsData, aes(x=DefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  xlab('Defensive Rebound Percentage') + 
  labs(title='(d4) Histogram of Defensive Rebound \n Percentage by Game Outcome')
d4
dev.copy(png, './figures/rawFigures2/d4_histogram_defensive_rebound_percentage_by_game_outcome.png')
dev.off()




############ 4 (part 1). Is there a correlation between offensive rebound percentage and 
############ defensive performance (opponent points or opponent field goal percentage)
############ among teams overall?

cor.test(rsTeamsData$OffensiveReboundPercentage, rsTeamsData$OpponentPoints)
cor.test(rsTeamsData$OffensiveReboundPercentage, rsTeamsData$OpponentFieldGoalAttempts)
cor.test(rsTeamsData$OffensiveReboundPercentage, rsTeamsData$OpponentFreeThrowAttempts)
# offensive rebound performance doesn't appear to correlate with opponent’s scoring efficiency

cor.test(rsTeamsData$DefensiveReboundPercentage, rsTeamsData$OpponentPoints)
cor.test(rsTeamsData$DefensiveReboundPercentage, rsTeamsData$FieldGoalAttempts)
cor.test(rsTeamsData$DefensiveReboundPercentage, rsTeamsData$FreeThrowAttempts)
# defensive rebound performance doesn't appear to correlate with scoring efficiency

######## Answer: doesn't appear to be so.




############ 4 (part 2). Is there a correlation between offensive rebound percentage and 
############ defensive performance (opponent points or opponent field goal percentage)
############ when each team is examined individually?

######## creating a table for p-values to run multiple correlational test programmatically
teamNames <- unique(as.character(rsTeamsData$Team))
n <- length(teamNames); n

pVal.ORebP.OppPoints.cor <- rep(NA, n)
pVal.ORebP.OppFGP.cor <- rep(NA, n)
pVal.ORebP.OppFTAttempts.cor <- rep(NA, n)

pValueTable <- cbind(pVal.ORebP.OppPoints.cor, pVal.ORebP.OppFGP.cor)
pValueTable <- cbind(pValueTable, pVal.ORebP.OppFTAttempts.cor)
pValueTable <- as.data.frame(pValueTable)
rownames(pValueTable) <- teamNames
pValueTable

######## populating the p-value table with a forloop
for (i in 1:n) {
  teamName <- teamNames[i]
  rsTeamData <- subset(rsTeamsData, Team==teamName)

  corResult1 <- cor.test(rsTeamData$OffensiveReboundPercentage, rsTeamData$OpponentPoints)
  corResult2 <- cor.test(rsTeamData$OffensiveReboundPercentage, rsTeamData$OpponentFieldGoalPercentage)
  corResult3 <- cor.test(rsTeamData$OffensiveReboundPercentage, rsTeamData$OpponentFreeThrowAttempts)
  
  pValueTable[i, ] <- c(corResult1$p.value, corResult2$p.value, corResult3$p.value)
}

pValueTable <- round(pValueTable, 3)
pValueTable

######## teams that *may* be negatively affected by higher offensive rebound percentages
cond1 <- pValueTable[ , 1] <= 0.05
cond2 <- pValueTable[ , 2] <= 0.05
cond3 <- pValueTable[ , 3] <= 0.05
cond.1.2 <- cond1 | cond2
cond <- cond.1.2 | cond3
pValueTable[cond, ]

######### WAS, NOH, GSW, TOR, ATL
## subsetting teams
rsTeamsDataWAS <- subset(rsTeamsData, Team=='WAS')
rsTeamsDataNOH <- subset(rsTeamsData, Team=='NOH')
rsTeamsDataGSW <- subset(rsTeamsData, Team=='GSW')
rsTeamsDataTOR <- subset(rsTeamsData, Team=='TOR')
rsTeamsDataATL <- subset(rsTeamsData, Team=='ATL')

## correlation tests for WAS (Washington Wizards)
cor.test(rsTeamsDataWAS$OffensiveReboundPercentage, rsTeamsDataWAS$OpponentPoints)
cor.test(rsTeamsDataWAS$OffensiveReboundPercentage, rsTeamsDataWAS$OpponentFieldGoalPercentage)

## correlation test for NOH (New Orleans Hornets)
cor.test(rsTeamsDataNOH$OffensiveReboundPercentage, rsTeamsDataNOH$OpponentPoints)  

## correlation test for GSW (Golden State Warriors)
cor.test(rsTeamsDataGSW$OffensiveReboundPercentage, rsTeamsDataGSW$OpponentFreeThrowAttempts)

## correlation test for TOR (Toronto Raptors)
cor.test(rsTeamsDataTOR$OffensiveReboundPercentage, rsTeamsDataTOR$OpponentFieldGoalPercentage)

## correlation test for ATL (Atlanta Hawks)
cor.test(rsTeamsDataATL$OffensiveReboundPercentage, rsTeamsDataATL$OpponentFreeThrowAttempts)

######## Answer: doesn't appear to be so except possibly for WAS, GSW, and TOR.




############ 5. Best four teams in the playoffs (MIA, SAS, IND, MEM):
############    points and offensive/defensive rebound performances

# Note: SAS lost to MIA in the finals and MIA won the championship

######## boxplot visual: points of top 4 playoff teams
e1 <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=5, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(e1) Points of Top 4 Playoff Teams') + 
  guides(fill=F) +
  annotate('text', x=3.95, y=135,
           label=paste('NBA teams\' average \n points per game:',
                       rsAveragePoints))
e1 
dev.copy(png, './figures/rawFigures2/e1_boxplot_points_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: offensive rebound percentages of top 4 playoff teams
e2 <- ggplot(rsTeamsDataTop4Playoff, 
             aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, 
                   y=rsMedianOffensiveReboundPercentage, 
                   yend=rsMedianOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(e2) Offensive Rebound Percentage of Top 4 Playoff Teams') +
  guides(fill=F) +
  annotate('text', x=2.5, y=0.45,
           label=paste('NBA teams\' median offensive \n rebound percentage:',
                       rsMedianOffensiveReboundPercentage))
e2
dev.copy(png, './figures/rawFigures2/e2_boxplot_offensive_rebound_percentage_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: defensive rebound percentages of top 4 playoff teams
e3 <- ggplot(rsTeamsDataTop4Playoff, 
             aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, 
                   y=rsMedianDefensiveReboundPercentage, 
                   yend=rsMedianDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') +
  labs(title='(e3) Defensive Rebound Percentage of Top 4 Playoff Teams') + 
  guides(fill=F) +
  annotate('text', x=1.4, y=0.55,
           label=paste('NBA teams\' median defensive \n rebound percentage:',
                       rsMedianDefensiveReboundPercentage))
e3
dev.copy(png, './figures/rawFigures2/e3_boxplot_defensive_rebound_percentage_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: game outcomes of top 4 playoff teams
e4 <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(e4) Game Outcome of Top 4 Playoff Teams')
e4
dev.copy(png, './figures/rawFigures2/e4_barplot_game_outcome_of_top_4_playoff_teams.png')
dev.off()




############ 6. Teams with the highest win percentages during the regular season:
############    points and offensive rebound performances

######## boxplot visual: points of top 6 teams with the highest winning percentages
f1 <- ggplot(rsTeamsDataHighestWinPercentage, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=7, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(f1) Points of Top 6 Teams with the Highest Win Percentages') + 
  guides(fill=F) +
  annotate('text', x=2.5, y=135,
           label=paste('NBA teams\' average \n points per game:',
                       rsAveragePoints))
f1
dev.copy(png, './figures/rawFigures2/f1_boxplot_points_of_top_6_teams_with_the_highest_win_percentages.png')
dev.off()

######## boxplot visual: offensive rebound percentages of top 6 teams with the highest winning percentages
f2 <- ggplot(rsTeamsDataHighestWinPercentage, 
             aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=7, 
                   y=rsMedianOffensiveReboundPercentage, 
                   yend=rsMedianOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(f2) Offensive Rebound Percentage of Top 6 \n Teams with the Highest Win Percentages') +
  guides(fill=F) +
  annotate('text', x=1.75, y=.12,
           label=paste('NBA teams\' median offensive \n rebound percentage:',
                       rsMedianOffensiveReboundPercentage))
f2
dev.copy(png, './figures/rawFigures2/f2_boxplot_offensive_rebound_percentage_of_top_6_teams_with_the_highest_win_percentages.png')
dev.off()

######## boxplot visual: defensive rebound percentages of top 6 teams with the highest winning percentages
f3 <- ggplot(rsTeamsDataHighestWinPercentage, 
             aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=7, 
                   y=rsMedianDefensiveReboundPercentage, 
                   yend=rsMedianDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') +
  labs(title='(f3) Defensive Rebound Percentage of Top 6 \n Teams with the Highest Win Percentages') +
  guides(fill=F) + 
  annotate('text', x=2.5, y=0.95,
           label=paste('NBA teams\' median defensive \n rebound percentage:',
                       rsMedianDefensiveReboundPercentage))
f3
dev.copy(png, './figures/rawFigures2/f3_boxplot_defensive_rebound_percentage_of_top_6_teams_with_the_highest_win_percentages.png')
dev.off()




############ 7. Best offensive teams (by average points per game during regular 
############ season): points and offensive/defensive rebound performance

######## boxplot visual of best offensive teams' points
g1 <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(g1) Points of Top 5 Offensive Teams') +
  guides(fill=F) + 
  annotate('text', x=4.5, y=80, 
           label=paste('NBA teams\' average \n points per game:', rsAveragePoints))
g1 
dev.copy(png, './figures/rawFigures2/g1_boxplot_points_of_top_5_offensive_teams.png')
dev.off()

######## boxplot visual of best offensive teams' offensive rebound percentage
g2 <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsMedianOffensiveReboundPercentage, 
                   yend=rsMedianOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(g2) Offensive Rebound Percentage \n of Top 5 Offensive Teams') + 
  guides(fill=F) +
  annotate('text', x=1.5, y=0.1, 
           label=paste('NBA teams\' median offensive \n rebound percentage:', 
                       rsMedianOffensiveReboundPercentage))
g2
dev.copy(png, './figures/rawFigures2/g2_boxplot_offensive_rebound_percentage_of_top_5_offensive_teams.png')
dev.off()

######## boxplot visual of best offensive teams' defensive rebound percentage
g3 <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6,
                   y=rsMedianDefensiveReboundPercentage,
                   yend=rsMedianDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') + 
  labs(title='(g3) Defensive Rebound Percentage of Top 5 Offensive Teams') + 
  guides(fill=F) + 
  annotate('text', x=2.5, y=0.93,
           label=paste('NBA teams\' median defensive \n rebound percentage:',
                       rsMedianDefensiveReboundPercentage))
g3
dev.copy(png, './figures/rawFigures2/g3_boxplot_defensive_rebound_percentage_of_top_5_offensive_teams.png')
dev.off()





############ 8. Best defensive teams (by average opponent team points per game 
############ during regular season): opponent points and offensive rebound performance, 

######## boxplot visual of best defensive teams' opponent points
h1 <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=OpponentPoints, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOpponentPoints, 
                   yend=rsAverageOpponentPoints), 
               color='red') +
  ylab('Opponent Points') +
  labs(title='(h1) Opponent Points of Top 5 Defensive Teams') +
  guides(fill=F) +
  annotate('text', x=2.5, y=65, 
           label=paste('NBA teams\' average opponent \n points per game:', 
                       rsAverageOpponentPoints))
h1
dev.copy(png, './figures/rawFigures2/h1_boxplot_opponent_points_of_top_5_defensive_teams.png')
dev.off()

######## boxplot visual of best defensive teams' defensive rebound percentage
h2 <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsMedianDefensiveReboundPercentage, 
                   yend=rsMedianDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') +
  labs(title='(h2) Defensive Rebound Percentage of Top 5 Defensive Teams') + 
  guides(fill=F) +
  annotate('text', x=1.5, y=0.57,
           label=paste('NBA teams\' median defensive \n rebound percentage:',
                       rsMedianDefensiveReboundPercentage))
h2
dev.copy(png, './figures/rawFigures2/h2_boxplot_defensive_rebound_percentage_of_top_5_defensive_teams.png')
dev.off()

######## boxplot visual of best defensive teams' offensive rebound percentage
h3 <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6,
                   y=rsMedianOffensiveReboundPercentage,
                   yend=rsMedianOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') + 
  labs(title='(h3) Offensive Rebound Percentage of Top 5 Defensive Teams') + 
  guides(fill=F) +
  annotate('text', x=2, y=0.1, 
           label=paste('NBA teams\' median offensive \n rebound percentage:',
                       rsMedianOffensiveReboundPercentage))
h3
dev.copy(png, './figures/rawFigures2/h3_boxplot_offensive_rebound_percentage_of_top_5_defensive_teams.png')
dev.off()
