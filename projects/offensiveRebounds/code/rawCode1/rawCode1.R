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
library(ggplot2)
library(car)
library(lsr)
library(psych)
library(gridExtra)




############ Overview of teamsData
head(teamsData)
names(teamsData)
dim(teamsData)
str(teamsData)  # each column variable in correct datatype




############ List of analyses
# 1. Offensive/defensive rebound performance (raw numbers and percentages) by game outcome 
#
# 2. Opponent's offensive/defensive rebound performance (raw numbers and percentages) 
#    by game outcome 
#
# 3. Offensive rebound performance (raw numbers and percentages) by score group
# 
# 4. Defensive rebound performance (raw numbers and percentages) by opponent score group
#
# 5. Best offensive teams (that scored the most on average during regular season):
#    offensive rebound performance, points, and game outcomes
#
# 6. Worst offensive teams (that scored the least on average during regular season):
#    offensive rebound performance, points, and game outcomes
#
# 7. Best defensive teams (that allowed the least points from opponents on average during regular season):
#    defensive rebound performance, opponent team points, and game outcomes
#
# 8. Worst defensive teams (that allowed the most points from opponents on average during regular season):
#    defensive rebound performance, opponent team points, and game outcomes
#
# 9. Teams with the best winning records during the regular season:
#    offensive/defensive rebound performances compared to those of other teams
#
# 10. Teams with the worst winning records during the regular season:
#    offensive/defensive rebound performances compared to those of other teams
#
# 11. Best four teams in the playoffs (MIA, SAS, IND, MEM):
#    offensive/defensive rebound performances

###### subsetting won/lost games
rsTeamsData <- subset(teamsData, GameType=='regular season')
rsTeamsDataWins <- subset(rsTeamsData, GameOutcome=='win')
rsTeamsDataLosses <- subset(rsTeamsData, GameOutcome=='loss')




############ Saving key average metrics
rsAveragePoints <- mean(rsTeamsData$Points)
rsAverageOpponentPoints <- mean(rsTeamsData$OpponentPoints)
rsAverageOffensiveRebounds <- mean(rsTeamsData$OffensiveRebounds)
rsAverageDefensiveRebounds <- mean(rsTeamsData$DefensiveRebounds)
rsAverageOpponentOffensiveRebounds <- mean(rsTeamsData$OpponentOffensiveRebounds)
rsAverageOpponentDefensiveRebounds <- mean(rsTeamsData$OpponentDefensiveRebounds)

rsAverageOffensiveReboundPercentage <- 
  round(sum(rsTeamsData$OffensiveRebounds) / (sum(rsTeamsData$OffensiveRebounds) + sum(rsTeamsData$OpponentDefensiveRebounds)), 2)
rsAverageDefensiveReboundPercentage <-
  round(sum(rsTeamsData$DefensiveRebounds) / (sum(rsTeamsData$DefensiveRebounds) + sum(rsTeamsData$OpponentOffensiveRebounds)), 2)
rsAverageOpponentOffensiveReboundPercentage <- 
  round(sum(rsTeamsData$OpponentOffensiveRebounds) / (sum(rsTeamsData$OpponentOffensiveRebounds) + sum(rsTeamsData$DefensiveRebounds)), 2)
rsAverageOpponentDefensiveReboundPercentage <-
  round(sum(rsTeamsData$OpponentDefensiveRebounds) / (sum(rsTeamsData$OpponentDefensiveRebounds) + sum(rsTeamsData$OffensiveRebounds)), 2)


rsAveragePoints

rsAverageOffensiveRebounds
rsAverageDefensiveRebounds 
rsAverageOpponentOffensiveRebounds
rsAverageOpponentOffensiveRebounds

rsAverageOffensiveReboundPercentage
rsAverageDefensiveReboundPercentage
rsAverageOpponentOffensiveReboundPercentage
rsAverageOpponentDefensiveReboundPercentage

#### quick quality check
max(rsTeamsData$OffensiveReboundPercentage)
max(rsTeamsData$DefensiveReboundPercentage)
max(rsTeamsData$OpponentOffensiveReboundPercentage)
max(rsTeamsData$OpponentDefensiveReboundPercentage)




############ 1. Number of offensive/defensive performance by game outcome
######## offensive rebounds by game outcome
aa <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OffensiveRebounds, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Offensive Rebounds') + 
  labs(title='(aa) Offensive Rebounds by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOffensiveRebounds, 
                   yend=rsAverageOffensiveRebounds), 
               color='red'
  )
aa
dev.copy(png, './figures/rawFigures1/aa_offensive_rebounds_by_game_outcome.png')
dev.off()

######## comparing average offensive rebounds between won and lost games
#### 0. checking for roughly equal sample sizes
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. checking for normal distributions
hist(rsTeamsDataWins$OffensiveRebounds)
hist(rsTeamsDataLosses$OffensiveRebounds)
describe(rsTeamsDataWins$OffensiveRebounds)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$OffensiveRebounds)  # skew < 3 and kurtosis < 10; "normal enough"

#### 2. checking for homogeneity of variance
leveneTest(rsTeamsData$OffensiveRebounds ~ rsTeamsData$GameOutcome)  
var(rsTeamsDataWins$OffensiveRebounds)
var(rsTeamsDataLosses$OffensiveRebounds)
# p-value > 0.05; good; homogeneity of variance assumption satisfied

#### conducting independent t-test
t.test(rsTeamsDataWins$OffensiveRebounds, rsTeamsDataLosses$OffensiveRebounds,
       paired=F, var.equal=T)  
# p < 0.05; difference in mean offensive rebounds stat. sig.

mean(rsTeamsDataWins$OffensiveRebounds)
mean(rsTeamsDataLosses$OffensiveRebounds)
# At first, the fact that the average offensive rebounds for won games is smaller than that 
# for lost games may strike as a surprise. But it shouldn't. In games won, there bound to
# be less offensive rebound opportunities since more shots go in than miss.

#### calculating the effect size
cohensD(rsTeamsDataWins$OffensiveRebounds, rsTeamsDataLosses$OffensiveRebounds, method='pooled')
# notable effect size


######## defensive rebounds by game outcome
ab <- ggplot(rsTeamsData, aes(x=GameOutcome, y=DefensiveRebounds, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Defensive Rebounds') +
  labs(title='(ab) Defensive Rebounds by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageDefensiveRebounds, 
                   yend=rsAverageDefensiveRebounds), 
               color='red'
  )
ab
dev.copy(png, './figures/rawFigures1/ab_defensive_rebounds_by_game_outcome.png')
dev.off()

######## comparing average defensive rebounds between won and lost games
#### 0. checking for roughly equal sample sizes
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. checking for normal distributions
hist(rsTeamsDataWins$DefensiveRebounds)
hist(rsTeamsDataLosses$DefensiveRebounds)
describe(rsTeamsDataWins$DefensiveRebounds)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$DefensiveRebounds)  # skew < 3 and kurtosis < 10; "normal enough"

#### 2. checking for homogeneity of variance
leveneTest(rsTeamsData$DefensiveRebounds ~ rsTeamsData$GameOutcome)  
var(rsTeamsDataWins$DefensiveRebounds)
var(rsTeamsDataLosses$DefensiveRebounds)
# p-value ~= 0.05;
# homogeneity of variance assumption satisfied but will also conduct non-parametric test also

#### conducting independent t-test
t.test(rsTeamsDataWins$DefensiveRebounds, rsTeamsDataLosses$DefensiveRebounds, 
       paired=F, var.equal=T)  
# p << 0.05

#### conducting Mann-Whitney U test (in addition to independent t-test)
wilcox.test(rsTeamsDataWins$DefensiveRebounds, rsTeamsDataLosses$DefensiveRebounds, paired=F)
# p << 0.05

# difference in means defensive rebounds is stat. sig.
mean(rsTeamsDataWins$DefensiveRebounds)
mean(rsTeamsDataLosses$DefensiveRebounds)

#### calculating the effect size
cohensD(rsTeamsDataWins$DefensiveRebounds, rsTeamsDataLosses$DefensiveRebounds, method='pooled')
# very large effect size



######## offensive rebound percentages by game outcome
ac <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Offensive Rebound Percentage') + 
  labs(title='(ac) Offensive Rebound Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage), 
               color='red'
  )
ac
dev.copy(png, './figures/rawFigures1/ac_offensive_rebound_percentage_by_game_outcome.png')
dev.off()

######## comparing average offensive rebound percentages between won and lost games
#### 0. checking for roughly equal sample sizes
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. checking for normal distributions
hist(rsTeamsDataWins$OffensiveReboundPercentage)
hist(rsTeamsDataLosses$OffensiveReboundPercentage)
describe(rsTeamsDataWins$OffensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$OffensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"

#### 2. checking for homogeneity of variance
leveneTest(rsTeamsData$OffensiveReboundPercentage ~ rsTeamsData$GameOutcome)  
var(rsTeamsDataWins$OffensiveReboundPercentage)
var(rsTeamsDataLosses$OffensiveReboundPercentage)
# p-value < 0.05; no good; homogeneity of variance assumption violated

#### conducting Mann-Whitney U test (instead of independent t-test)
wilcox.test(rsTeamsDataWins$OffensiveReboundPercentage, 
            rsTeamsDataLosses$OffensiveReboundPercentage,
            paired=F)  
# p < 0.05; difference in mean offensive rebound percentages stat. sig.

mean(rsTeamsDataWins$OffensiveReboundPercentage)
mean(rsTeamsDataLosses$OffensiveReboundPercentage)

#### calculating the effect size
cohensD(rsTeamsDataWins$OffensiveReboundPercentage, 
        rsTeamsDataLosses$OffensiveReboundPercentage, 
        method='pooled')
# notable effect size


######## defensive rebound percentages by game outcome
ad <- ggplot(rsTeamsData, aes(x=GameOutcome, y=DefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Defensive Rebound Percentage') +
  labs(title='(ad) Defensive Rebound Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageDefensiveReboundPercentage, 
                   yend=rsAverageDefensiveReboundPercentage), 
               color='red'
  )
ad
dev.copy(png, './figures/rawFigures1/ad_defensive_rebound_percentage_by_game_outcome.png')
dev.off()

######## comparing average defensive rebound percentages between won and lost games
#### 0. checking for roughly equal sample sizezs
nrow(rsTeamsDataWins)
nrow(rsTeamsDataLosses)

#### 1. normal distributions
hist(rsTeamsDataWins$DefensiveReboundPercentage)
hist(rsTeamsDataLosses$DefensiveReboundPercentage)
describe(rsTeamsDataWins$DefensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"
describe(rsTeamsDataLosses$DefensiveReboundPercentage)  # skew < 3 and kurtosis < 10; "normal enough"

#### 2. homogeneity of variance
leveneTest(rsTeamsData$DefensiveReboundPercentage ~ rsTeamsData$GameOutcome)  
var(rsTeamsDataWins$DefensiveReboundPercentage)
var(rsTeamsDataLosses$DefensiveReboundPercentage)
# p-value < 0.05; not good; homogeneity of variance assumption violated

#### conducting Mann-Whitney U test (instead of independent t-test)
wilcox.test(rsTeamsDataWins$DefensiveReboundPercentage, 
            rsTeamsDataLosses$DefensiveReboundPercentage, 
            paired=F)  
# p << 0.05; difference in means defensive rebounds is stat. sig.

mean(rsTeamsDataWins$DefensiveReboundPercentage)
mean(rsTeamsDataLosses$DefensiveReboundPercentage)

#### calculating the effect size
cohensD(rsTeamsDataWins$DefensiveReboundPercentage, 
        rsTeamsDataLosses$DefensiveReboundPercentage, 
        method='pooled')
# notable effect size


######## histograms of offensive/defensive rebounds by game outcome
ae <- ggplot(rsTeamsData, aes(x=OffensiveRebounds, fill=GameOutcome)) + 
  geom_histogram(binwidth=1, position='dodge') +
  xlab('Offensive Rebounds') + 
  labs(title='(ae) Histogram of Offensive Rebounds by Game Outcome')
ae  
dev.copy(png, './figures/rawFigures1/ae_histogram_of_offensive_rebounds_by_game_outcome.png')
dev.off()

af <- ggplot(rsTeamsData, aes(x=DefensiveRebounds, fill=GameOutcome)) + 
  geom_histogram(binwidth=1, position='dodge') + 
  xlab('Defensive Rebounds') + 
  labs(title='(af) Histogram of Defensive Rebounds by Game Outcome')
af
dev.copy(png, './figures/rawFigures1/af_histogram_of_defensive_rebounds_by_game_outcome.png')
dev.off()


######## histograms of offensive/defensive rebound percentage by game outcome
ag <- ggplot(rsTeamsData, aes(x=OffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  labs(title='(ag) Histogram of Offensive Rebound \n Percentage by Game Outcome')
ag
dev.copy(png, './figures/rawFigures1/ag_histogram_of_offensive_rebound_percentage_by_game_outcome.png')
dev.off()

ah <- ggplot(rsTeamsData, aes(x=DefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  labs(title='(ah) Histogram of Defensive Rebound \n Percentage by Game Outcome')
ah
dev.copy(png, './figures/rawFigures1/ah_histogram_of_defensive_rebound_percentage_by_game_outcome.png')
dev.off()




############ 2. Number of opponent's offensive/defensive performance by game outcome

######## opponent offensive/defensive rebounds by game outcome
ai <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OpponentOffensiveRebounds, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Opponent Offensive Rebounds') + 
  labs(title='(ai) Opponent Offensive Rebounds by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOpponentOffensiveRebounds, 
                   yend=rsAverageOpponentOffensiveRebounds), 
               color='red'
  )
ai
dev.copy(png, './figures/rawFigures1/ai_opponent_offensive_rebounds_by_game_outcome.png')
dev.off()

aj <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OpponentDefensiveRebounds, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Opponent Defensive Rebounds') +
  labs(title='(aj) Opponent Defensive Rebounds by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOpponentDefensiveRebounds, 
                   yend=rsAverageOpponentDefensiveRebounds), 
               color='red'
  )
aj
dev.copy(png, './figures/rawFigures1/aj_opponent_defensive_rebounds_by_game_outcome.png')
dev.off()


######## opponent offensive/defensive rebound percentages by game outcome
ak <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OpponentOffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Opponent Offensive Rebound Percentage') + 
  labs(title='(ak) Opponent Offensive Rebound \n Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOpponentOffensiveReboundPercentage, 
                   yend=rsAverageOpponentOffensiveReboundPercentage), 
               color='red'
  )
ak
dev.copy(png, './figures/rawFigures1/ak_opponent_offensive_rebound_percentage_by_game_outcome.png')
dev.off()

al <- ggplot(rsTeamsData, aes(x=GameOutcome, y=OpponentDefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_boxplot() + 
  xlab('Game Outcome') +
  ylab('Opponent Defensive Rebound Percentage') +
  labs(title='(al) Opponent Defensive Rebound \n Percentage by Game Outcome') + 
  geom_segment(aes(x=0, xend=3, 
                   y=rsAverageOpponentDefensiveReboundPercentage, 
                   yend=rsAverageOpponentDefensiveReboundPercentage), 
               color='red'
  )
al
dev.copy(png, './figures/rawFigures1/al_opponent_defensive_rebound_percentage_by_game_outcome.png')
dev.off()


######## histograms of opponent offensive/defensive rebounds by game outcome
am <- ggplot(rsTeamsData, aes(x=OpponentOffensiveRebounds, fill=GameOutcome)) + 
  geom_histogram(binwidth=1, position='dodge') +
  xlab('Opponent Offensive Rebounds') + 
  labs(title='(am) Histogram of Opponent Offensive \n Rebounds by Game Outcome')
am
dev.copy(png, './figures/rawFigures1/am_histogram_of_opponent_offensive_rebounds_by_game_outcome.png')
dev.off()

an <- ggplot(rsTeamsData, aes(x=OpponentDefensiveRebounds, fill=GameOutcome)) + 
  geom_histogram(binwidth=1, position='dodge') + 
  xlab('Opponent Defensive Rebounds') + 
  labs(title='(an) Histogram of Opponent Defensive \n Rebounds by Game Outcome')
an
dev.copy(png, './figures/rawFigures1/an_histogram_of_opponent_defensive_rebounds_by_game_outcome.png')
dev.off()


######## histograms of opponent offensive/defensive rebound percentage by game outcome
ao <- ggplot(rsTeamsData, aes(x=OpponentOffensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  labs(title='(ao) Histogram of Opponent Offensive Rebound \n Percentage by Game Outcome')
ao 
dev.copy(png, './figures/rawFigures1/ao_histogram_of_opponent_offensive_rebound_percentage_by_game_outcome.png')
dev.off()

ap <- ggplot(rsTeamsData, aes(x=OpponentDefensiveReboundPercentage, fill=GameOutcome)) + 
  geom_histogram(binwidth=0.02, position='dodge') + 
  labs(title='(ap) Histogram of Opponent Defensive Rebound \n Percentage by Game Outcome')
ap
dev.copy(png, './figures/rawFigures1/ap_histogram_of_opponent_defensive_rebound_percentage_by_game_outcome.png')
dev.off()




############ 3. Offensive rebound performance by score group

######## offensive rebounds by score group
aq <- ggplot(rsTeamsData, aes(x=ScoreGroup, y=OffensiveRebounds, fill=ScoreGroup)) + 
  geom_boxplot() + 
  xlab('Score Group') +
  ylab('Offensive Rebounds') + 
  labs(title='(aq) Offensive Rebounds by Score Group')
aq
dev.copy(png, './figures/rawFigures1/aq_offensive_rebounds_by_score_group.png')
dev.off()

######## offensive rebound percentages by score group
ar <- ggplot(rsTeamsData, aes(x=ScoreGroup, y=OffensiveReboundPercentage, fill=ScoreGroup)) + 
  geom_boxplot() + 
  xlab('Score Group') +
  ylab('Offensive Rebound Percentage') + 
  labs(title='(ar) Offensive Rebound Percentage by Score Group')
ar
dev.copy(png, './figures/rawFigures1/ar_offensive_rebound_percentage_by_score_group.png')
dev.off()




############ 4. Defensive rebound performance by opponent team's score group
######## defensive rebounds by score group
as <- ggplot(rsTeamsData, aes(x=OpponentScoreGroup, y=DefensiveRebounds, fill=OpponentScoreGroup)) + 
  geom_boxplot() + 
  xlab('Opponent Score Group') +
  ylab('Defensive Rebounds') +
  labs(title='(as) Defensive Rebounds by Opponent Score Group')
as
dev.copy(png, './figures/rawFigures1/as_defensive_rebounds_by_opponent_score_group.png')
dev.off()

######## defensive rebound percentages by score group
at <- ggplot(rsTeamsData, aes(x=OpponentScoreGroup, y=DefensiveReboundPercentage, fill=OpponentScoreGroup)) + 
  geom_boxplot() + 
  xlab('Opponent Score Group') +
  ylab('Defensive Rebound Percentage') +
  labs(title='(at) Defensive Rebound Percentage \n by Opponent Score Group')
at
dev.copy(png, './figures/rawFigures1/at_defensive_rebound_percentage_by_score_group.png')
dev.off()




############ Prep for step 5 and 6.
###### regular season team points summary table
rsPointsSummaryTableByTeam <- describeBy(rsTeamsData$Points, rsTeamsData$Team)
rsPointsSummaryTableByTeam

###### subsetting
## top five offensive teams with the highest average team points 
bestOffenseTeams <- c('MIA', 'SAS', 'OKC', 'HOU', 'DEN')  # in order from the lowest mean scoring to the highest scoring mean

## bottom five offensive teams with the lowest average team points 
worstOffenseTeams <- c('PHI', 'CHI', 'WAS', 'MEM', 'CHA')  # in order from the lowest mean scoring to the higest scoring mean

## subsetting top five best offensive teams collectively
rsTeamsDataBestOffense <- subset(rsTeamsData, Team=='MIA' | Team=='SAS' | Team=='OKC' | 
                                   Team=='HOU' | Team=='DEN')
## subsetting top five worst offensive teams collectively
rsTeamsDataWorstOffense <- subset(rsTeamsData, Team=='PHI' | Team=='CHI' | Team=='WAS' |
                                    Team=='MEM' | Team=='CHA')




############ 5. Best offensive teams (by average points per game during regular 
############ season): offensive rebound performance, points, and game outcome

######## boxplot visual of best offensive teams' points
au <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(au) Points of Top 5 Offensive Teams')
au 
dev.copy(png, './figures/rawFigures1/au_points_of_top_5_offensive_teams.png')
dev.off()

######## boxplot visual of best offensive teams' offensive rebounds
av <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=OffensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, y=rsAverageOffensiveRebounds, yend=rsAverageOffensiveRebounds),
               color='red') +
  ylab('Offensive Rebounds') +
  labs(title='(av) Offensive Rebounds of Top 5 Offensive Teams')
av
dev.copy(png, './figures/rawFigures1/av_offensive_rebounds_of_top_5_offensive_teams.png')
dev.off()

######## boxplot visual of best offensive teams' offensive rebound percentage
aw <- ggplot(rsTeamsDataBestOffense, aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(aw) Offensive Rebound Percentage \n of Top 5 Offensive Teams')
aw
dev.copy(png, './figures/rawFigures1/aw_offensive_rebound_percentage_of_top_5_offensive_teams.png')
dev.off()

######## boxplot visual of best offensive teams' game outcome
ax <- ggplot(rsTeamsDataBestOffense, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(ax) Game Outcome of Top 5 Offensive Teams')  
ax
dev.copy(png, './figures/rawFigures1/ax_game_outcome_of_top_5_offensive_teams.png')
dev.off()




############ 6. Worst offensive teams (by average points per game during regular 
############ season): offensive rebound performance, points, and game outcome

######## boxplot visual of worst offensive teams' points
ay <- ggplot(rsTeamsDataWorstOffense, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, y=rsAveragePoints, yend=rsAveragePoints), color='red') +
  labs(title='(ay) Points of Bottom 5 Offensive Teams')
ay
dev.copy(png, './figures/rawFigures1/ay_points_of_bottom_5_offensive_teams.png')
dev.off()

######## boxplot visual of worst offensive teams' offensive rebounds
az <- ggplot(rsTeamsDataWorstOffense, aes(x=Team, y=OffensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, y=rsAverageOffensiveRebounds, yend=rsAverageOffensiveRebounds),
               color='red') +
  ylab('Offensive Rebounds') + 
  labs(title='(az) Offensive Rebounds of Bottom 5 Offensive Teams')
az
dev.copy(png, './figures/rawFigures1/az_offensive_rebounds_of_bottom_5_offensive_teams.png')
dev.off()

######## boxplot visual of worst offensive teams' offensive rebound percentage
ba <- ggplot(rsTeamsDataWorstOffense, aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') + 
  labs(title='(ba) Offensive Rebound Percentage \n of Bottom 5 Offensive Teams')
ba
dev.copy(png, './figures/rawFigures1/ba_offensive_rebound_percentage_of_bottom_5_offensive_teams.png')
dev.off()

######## boxplot visual of worst offensive teams' game outcome
bb <- ggplot(rsTeamsDataWorstOffense, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(bb) Game Outcome of Bottom 5 Offensive Teams')
bb
dev.copy(png, './figures/rawFigures1/bb_game_outcome_of_bottom_5_offensive_teams.png')
dev.off()




############ Prep for step 6 and 7.
######## regular season opponent team points summary table
rsOppPointsSummaryTableByTeam <- describeBy(rsTeamsData$OpponentPoints, rsTeamsData$Team)
rsOppPointsSummaryTableByTeam

######## top five defensive teams with the lowest average opponent team points
bestDefenseTeams <- c('MEM', 'IND', 'CHI', 'MIA', 'BRK')  # in order from the lowest mean scoring to the highest scoring mean

######## bottom five defensive teams with the highest average opponent team points
worseDefenseTeams <- c('CLE', 'PHO', 'DAL', 'CHA', 'SAC')  # in order from the lowest mean scoring to the highest scoring mean

## subsetting top five best defensive teams collectively
rsTeamsDataBestDefense <- subset(rsTeamsData, Team=='MEM' | Team=='IND' | Team=='CHI' | 
                                   Team=='LAC' | Team=='MIA')

## subsetting top five worst offensive teams collectively
rsTeamsDataWorstDefense <- subset(rsTeamsData, Team=='PHO' | Team=='DAL' | Team=='HOU' |
                                    Team=='CHA' | Team=='SAC')




############ 7. Best defensive teams (by average opponent team points per game 
############ during regular season): offensive rebound performance, opponent points, 
############ and game outcomes

######## boxplot visual of best defensive teams' opponent points
bc <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=OpponentPoints, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOpponentPoints, 
                   yend=rsAverageOpponentPoints), 
               color='red') +
  ylab('Opponent Points') +
  labs(title='(bc) Opponent Points of Top 5 Defensive Teams')
bc
dev.copy(png, './figures/rawFigures1/bc_opponent_points_of_top_5_defensive_teas.png')
dev.off()

######## boxplot visual of best defensive teams' defensive rebounds
bd <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=DefensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, y=rsAverageDefensiveRebounds, yend=rsAverageDefensiveRebounds),
               color='red') + 
  ylab('Defensive Rebounds') +
  labs(title='(bd) Defensive Rebounds of Top 5 Defensive Teams')
bd
dev.copy(png, './figures/rawFigures1/bd_defensive_rebounds_of_top_5_defensive_teams.png')
dev.off()

######## boxplot visual of best defensive teams' defensive rebound percentage
be <- ggplot(rsTeamsDataBestDefense, aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageDefensiveReboundPercentage, 
                   yend=rsAverageDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') +
  labs(title='(be) Defensive Rebound Percentage \n of Top 5 Defensive Teams')
be
dev.copy(png, './figures/rawFigures1/be_defensive_rebound_percentage_of_top_5_defensive_teams.png')
dev.off()

######## boxplot visual of best defensive teams' game outcome
bf <- ggplot(rsTeamsDataBestDefense, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(bf) Game Outcome of Top 5 Defensive Teams')
bf
dev.copy(png, './figures/rawFigures1/bf_game_outcome_of_top_5_defensive_teams.png')
dev.off()




############ 8. Worst defensive teams (by average opponent team points per game 
############ during regular season): offensive rebound performance, opponent points, 
############ and game outcomes

########## boxplot visual of worst defensive teams' opponent points
bg <- ggplot(rsTeamsDataWorstDefense, aes(x=Team, y=OpponentPoints, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOpponentPoints, 
                   yend=rsAverageOpponentPoints), 
               color='red') +
  ylab('Opponent Points') + 
  labs(title='(bg) Opponent Points of Bottom 5 Defensive Teams')
bg
dev.copy(png, './figures/rawFigures1/bg_opponent_points_of_bottom_5_defensive_teams.png')
dev.off()

######## boxplot visual of worst defensive teams' defensive rebounds
bh <- ggplot(rsTeamsDataWorstDefense, aes(x=Team, y=DefensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, y=rsAverageDefensiveRebounds, yend=rsAverageDefensiveRebounds),
               color='red') + 
  ylab('Defensive Rebounds') + 
  labs(title='(bh) Defensive Rebounds of Bottom 5 Defensive Teams')
bh
dev.copy(png, './figures/rawFigures1/bh_defensive_rebounds_of_bottom_5_defensive_teams.png')
dev.off()

######## boxplot visual of worst defensive teams' defensive rebound percentage
bi <- ggplot(rsTeamsDataWorstDefense, aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageDefensiveReboundPercentage, 
                   yend=rsAverageDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') + 
  labs(title='(bi) Defensive Rebound Percentage \n of Bottom 5 Defensive Teams')
bi
dev.copy(png, './figures/rawFigures1/bi_defensive_rebound_percentage_of_bottom_5_defensive_teams.png')
dev.off()

######## boxplot visual of worst defensive teams' game outcome
bj <- ggplot(rsTeamsDataWorstDefense, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(bj) Game Outcome of Bottom 5 Defensive Teams')
bj
dev.copy(png, './figures/rawFigures1/bj_game_outcome_of_bottom_5_defensive_teams.png')
dev.off()




############ Prep for step 9 and 10.
############ Teams with the highest percentages of wins and losses during the regular season

######## visually
bk <- ggplot(rsTeamsData, aes(x=Team, fill=GameOutcome)) +
  geom_bar(position='fill') + 
  theme(axis.text.x = element_text(angle=45, hjust=1)) +
  labs(title='(bk) Winning Percentage by Team')
bk  
dev.copy(png, './figures/rawFigures1/bk_winning_percentage_by_team.png')
dev.off()

######## via table
rsTeamsWLTable <- table(rsTeamsData$GameOutcome, rsTeamsData$Team)
rsTeamsWLPercentagesTable <- 
  round(rsTeamsWLTable[2, ] / (rsTeamsWLTable[1, ] + rsTeamsWLTable[2, ]), 2)  # win percentages
rsTeamsWLPercentagesTable <- rsTeamsWLPercentagesTable[order(rsTeamsWLPercentagesTable)]  # ordered

rsTeamsWLTable
rsTeamsWLPercentagesTable

######## subsetting
#### top five teams with the highest winning percentages during regular season
rsTeamsDataHighestWinPercentage <- subset(rsTeamsData, Team=='MEM' | Team=='LAC' | Team=='DEN' |
                                            Team=='SAS' | Team=='OKC' | Team=='MIA')

#### bottom five teams with the lowest winning percentages during regular season
rsTeamsDataLowestWinPercentage <- subset(rsTeamsData, Team=='ORL' | Team=='CHA' |
                                           Team=='CLE' | Team=='PHO' | Team=='NOH')




############ 9. Teams with the best winning records during the regular season:
############    offensive/defensive rebound performances compared to those of other teams

######## boxplot visual: points of top 5 teams with the highest winning percentages
bl <- ggplot(rsTeamsDataHighestWinPercentage, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=7, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(bl) Points of Top 5 Teams with \n the Highest Win Percentages')
bl 
dev.copy(png, './figures/rawFigures1/bl_points_of_top_5_teams_with_the_highest_win_percentages.png')
dev.off()

######## boxplot visual: offensive rebounds of top 5 teams with the highest winning percentages
bm <- ggplot(rsTeamsDataHighestWinPercentage, aes(x=Team, y=OffensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=7, y=rsAverageOffensiveRebounds, yend=rsAverageOffensiveRebounds),
               color='red') +
  ylab('Offensive Rebounds') +
  labs(title='(bm) Offensive Rebounds of Top 5 Teams \n with the Higest Win Percentages')
bm
dev.copy(png, './figures/rawFigures1/bm_offensive_rebounds_of_top_5_teams_with_the_highest_win_percentages.png')
dev.off()

######## boxplot visual: offensive rebound percentages of top 5 teams with the highest winning percentages
bn <- ggplot(rsTeamsDataHighestWinPercentage, 
             aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=7, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(bn) Offensive Rebound Percentage of \n Top 5 Teams with the Highest Win Percentages')
bn
dev.copy(png, './figures/rawFigures1/bn_offensive_rebound_percentage_of_top_5_teams_with_the_highest_win_percentages.png')
dev.off()

######## boxplot visual: game outcome of top 5 teams with the highest winning percentages
bo <- ggplot(rsTeamsDataHighestWinPercentage, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(bo) Game Outcome of Top 5 Teams \n with the Highest Win Percentages')  
bo
dev.copy(png, './figures/rawFigures1/bo_game_outcome_of_top_5_teams_with_the_highest_win_percentages.png')
dev.off()




############ 10. Teams with the worst winning records during the regular season:
############     offensive/defensive rebound performances compared to those of other teams

######## boxplot visual: points of bottom 5 teams with the lowest winning percentages
bp <- ggplot(rsTeamsDataLowestWinPercentage, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=6, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(bp) Points of Bottom 5 Teams with \n the Lowest Win Percentages')
bp 
dev.copy(png, './figures/rawFigures1/bp_points_of_bottom_5_teams_with_the_lowest_win_percentages.png')
dev.off()

######## boxplot visual: offensive rebounds of bottom 5 teams with the lowest winning percentages
bq <- ggplot(rsTeamsDataLowestWinPercentage, aes(x=Team, y=OffensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, y=rsAverageOffensiveRebounds, yend=rsAverageOffensiveRebounds),
               color='red') +
  ylab('Offensive Rebounds') +
  labs(title='(bq) Offensive Rebounds of Bottom 5 Teams \n with the Lowest Win Percentages')
bq
dev.copy(png, './figures/rawFigures1/bq_offensive_rebounds_of_bottom_5_teams_with_the_lowest_win_percentages.png')
dev.off()

######## boxplot visual: offensive rebound percentages of bottom 5 teams with the lowest winning percentages
br <- ggplot(rsTeamsDataLowestWinPercentage, 
             aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=6, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(br) Offensive Rebound Percentage of \n Bottom 5 Teams with the Lowest Win Percentages')
br
dev.copy(png, './figures/rawFigures1/br_offensive_rebound_percentage_of_bottom_5_teams_with_the_lowest_win_percentages.png')
dev.off()

######## boxplot visual: game outcome of bottom 5 teams with the lowest win percentages
bs <- ggplot(rsTeamsDataLowestWinPercentage, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(bs) Game Outcome of Bottom 5 Teams \n with the Lowest Win Percentages')  
bs
dev.copy(png, './figures/rawFigures1/bs_game_outcome_of_bottom_5_teams_with_the_lowest_win_percentages.png')
dev.off()




############ 11. Best four teams in the playoffs (MIA, SAS, IND, MEM):
############     offensive/defensive rebound performances

# Note: SAS lost to MIA and MIA won the championship
rsTeamsDataTop4Playoff <- subset(rsTeamsData, Team=='MIA' | Team=='SAS' | 
                                   Team=='IND' | Team=='MEM')

######## boxplot visual: points of top 4 playoff teams
bt <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, y=Points, fill=Team)) + 
  geom_boxplot() +
  geom_segment(aes(x=0, xend=5, y=rsAveragePoints, yend=rsAveragePoints), color='red') + 
  labs(title='(bt) Points of Top 4 Playoff Teams')
bt 
dev.copy(png, './figures/rawFigures1/bt_points_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: offensive rebounds of top 4 playoff teams
bu <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, y=OffensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, y=rsAverageOffensiveRebounds, yend=rsAverageOffensiveRebounds),
               color='red') +
  ylab('Offensive Rebounds') +
  labs(title='(bu) Offensive Rebounds of Top 4 Playoff Teams')
bu
dev.copy(png, './figures/rawFigures1/bu_offensive_rebounds_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: offensive rebound percentages of top 4 playoff teams
bv <- ggplot(rsTeamsDataTop4Playoff, 
             aes(x=Team, y=OffensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, 
                   y=rsAverageOffensiveReboundPercentage, 
                   yend=rsAverageOffensiveReboundPercentage),
               color='red') + 
  ylab('Offensive Rebound Percentage') +
  labs(title='(bv) Offensive Rebound Percentage of Top 4 Playoff Teams')
bv
dev.copy(png, './figures/rawFigures1/bv_offensive_rebound_percentage_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: defensive rebounds of top 4 playoff teams
bw <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, y=DefensiveRebounds, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, y=rsAverageDefensiveRebounds, yend=rsAverageDefensiveRebounds),
               color='red') +
  ylab('Defensive Rebounds') +
  labs(title='(bw) Defensive Rebounds of Top 4 Playoff Teams')
bw
dev.copy(png, './figures/rawFigures1/bw_defensive_rebounds_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: defensive rebound percentages of top 4 playoff teams
bx <- ggplot(rsTeamsDataTop4Playoff, 
             aes(x=Team, y=DefensiveReboundPercentage, fill=Team)) + 
  geom_boxplot() + 
  geom_segment(aes(x=0, xend=5, 
                   y=rsAverageDefensiveReboundPercentage, 
                   yend=rsAverageDefensiveReboundPercentage),
               color='red') + 
  ylab('Defensive Rebound Percentage') +
  labs(title='(bx) Defensive Rebound Percentage of Top 4 Playoff Teams')
bx
dev.copy(png, './figures/rawFigures1/bx_defensive_rebound_percentage_of_top_4_playoff_teams.png')
dev.off()

######## boxplot visual: game outcomes of top 4 playoff teams
by <- ggplot(rsTeamsDataTop4Playoff, aes(x=Team, fill=GameOutcome)) + 
  geom_bar(position='dodge') + 
  labs(title='(by) Game Outcome of Top 4 Playoff Teams')  
by
dev.copy(png, './figures/rawFigures1/by_game_outcome_of_top_4_playoff_teams.png')
dev.off()




############ Correlation tests
cor.test(rsTeamsData$Points, rsTeamsData$OffensiveRebounds)
cor.test(rsTeamsData$Points, rsTeamsData$OffensiveReboundPercentage)
cor.test(rsTeamsData$OpponentPoints, rsTeamsData$DefensiveRebounds)
cor.test(rsTeamsData$OpponentPoints, rsTeamsData$DefensiveReboundPercentage)




############ 
ggplot(rsTeamsData, aes(x=OffensiveRebounds, y=Points, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formula=y~x, size=2) + 
  xlab('Offensive Rebounds') +
  labs(title='Offensive Rebounds vs Points by Game Outcome')

ggplot(rsTeamsData, aes(x=OffensiveReboundPercentage, y=Points, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formua=y~x, size=2) +
  xlab('Offensive Rebound Percentage') +
  labs(title='Offensive Rebound Percentage vs Points by Game Outcome')
model1 <- lm(Points ~ OffensiveReboundPercentage, data=rsTeamsData)
model1$coefficients


############ 
ggplot(rsTeamsData, aes(x=DefensiveRebounds, y=OpponentPoints, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formula=y~x, size=2) + 
  xlab('Defensive Rebounds') +
  ylab('Opponent Points') + 
  labs(title='Defensive Rebounds vs. Opponent Points by Game Outcome')

ggplot(rsTeamsData, aes(x=DefensiveReboundPercentage, y=OpponentPoints, color=GameOutcome)) +
  geom_point() + 
  geom_smooth(method='lm', formua=y~x, size=2) +
  xlab('Defensive Rebound Percentage') +
  ylab('Opponent Points') +
  labs(title='Defensive Rebound Percentage Opponent Points by Game Outcome')
model2 <- lm(OpponentPoints ~ DefensiveReboundPercentage, data=rsTeamsData)
model2$coefficients


############
