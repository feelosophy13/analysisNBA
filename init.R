############ Objective
# The original dataset, playersGameDetailsNBA_2012-2013.csv, contains information about all 
# the NBA games for the 2012-2013 season, broken down by individual players.
#
# The purpose of this file (init.R) is to:
# 1. Rename columns by removing "." character in the players' data.
#
# 2. Rename columns 9 through 11 from X3.Point.Field.Goals, X3.Point.Field.Goal.Attempts,
# and X3.Point.Field.Goal.Percentage to ThreePointersMade, ThreePointerAttempts, and
# ThreePointerPercentage in the players' data.
#
# 3. Convert GameID (factor) column to a character variable in the players' data.
# 
# 4. Convert MinutesPlayed (character) column to a numeric variable with decimal time scale
# in the players' data.
#
# 5. Add new column: TwoPointersMade (integer), TwoPointerAttempts (integer), and 
# TwoPointerPercentage (integer) in the players' data.
#
# 6. Add new columns: GameDate, HomeGame (binary 'home' or 'away'), GameType (binary 
# 'playoffs' or 'regular season'), Utilization (tertiary 'overplayed', 'underplayed' or 
# 'moderate') in the players' data.
#
# 7. Create a new dataset, teamsData, in which information about all the NBA games for the 
# 2012-2013 season is broken down by teams (not individuals players). 
#
# 8. Add new columns: GameDuration (numeric), Overtime (numeric), OpponentTeam (factor), 
# GameOutcome (binary 'win' or 'loss'), and TeamPoints (numeric) in the players' data.
#
# 9. Add new columns for opponent stats: OpponentNumPlayers, OpponentFieldGoals, 
# OpponentFieldGoalAttempts, OpponentThreePointersMade, etc. to the teams' data
# 
# 10. Add new columns: OffensiveReboundPercentage, DefensiveReboundPercentage, 
# OpponentOffensiveReboundPercentage, OpponentDefensiveReboundPercentage to the teams' data
#
# 11. Add new column: ScoreGroup and OpponentScoreGroup to the teams' data
#
# 12. Export the processed data (playersData and teamsData) to the processed data folder.



############ Setting working directory
getwd()
setwd('/Users/hawooksong/Desktop/programming_projects/analysisNBA')



############ Loading data and R packages
#### loading data
playersData <- read.csv('./data/rawData/playersGameDetailsNBA_2012-2013.csv', header=T)
names(playersData)
head(playersData)
str(playersData)



############ Defining functions
# this function takes in players' or teams' minutes and converts to seconds
convertMinutesPlayedToSeconds <- function(minutesPlayed) {
  minutesPlayed <- as.character(minutesPlayed)
  split <- strsplit(minutesPlayed, ':')
  minutes <- split[[1]][1]
  minutes <- as.numeric(minutes)
  seconds <- split[[1]][2]
  seconds <- as.numeric(seconds)
  totalSeconds <- minutes * 60 + seconds
  return(totalSeconds)
}

# this function takes in rows of players' data for a single team in a single game and 
# converts to a single row of a team data
condenseSingleGamePlayersData <- function(singleGamePlayersData) {
  colNames <- colnames(singleGamePlayersData)
  n <- length(colNames)
  outputData <- data.frame(NumPlayers=nrow(singleGamePlayersData))
  
  for (i in 1:n) {
    colname <- colNames[i]
    if (colname == 'GameID' || colname == 'Team' || colname == 'Date' || colname == 'HomeGame' || colname == 'GameType') {
      outputData[colname] <- unique(singleGamePlayersData[colname])
    }
    else if (colname == 'Player' || colname == 'PlayerID' || colname == 'Utilization') {
      next 
    }
    else if (colname == 'FieldGoalPercentage' || colname == 'ThreePointerPercentage' || colname == 'FreeThrowPercentage' || colname == 'TwoPointerPercentage') {
      outputData[colname] <- NA  # this is patched later
    }
    else {
      outputData[colname] <- sum(singleGamePlayersData[colname])
    }
  }
  
  # creating three columns for numbers of overplayed, underplayed, and moderately played players
  utilizationTable <- table(singleGamePlayersData$Utilization)

  outputData$NumModeratelyPlayed <- utilizationTable[1]
  outputData$NumOverplayed <- utilizationTable[2]
  outputData$NumUnderplayed <- utilizationTable[3]
  
  return(outputData)
}

# this function takes in takes in rows of players' data and converts to rows of teams' data
# specific argument: playersData
createTeamsData <- function(playersData) {
  primaryKeys <- unique(playersData$GameID)
  n <- length(primaryKeys)
  nRowsTeamData <- n * 2  # x2 because there are two teams per each game (or per each game ID)
  teamsData <- data.frame()
  
  # for all players' data for both teams per each game
  for (i in 1:n) {
    primaryKey <- primaryKeys[i]
    singleGamePlayersData <- playersData[playersData$GameID==primaryKey, ]
    
    opposingTeams <- unique(singleGamePlayersData$Team)
    singleGamePlayersDataTeam1 <- subset(singleGamePlayersData, Team==opposingTeams[1])
    singleGamePlayersDataTeam2 <- subset(singleGamePlayersData, Team==opposingTeams[2])
    
    singleGameTeamDataT1 <- condenseSingleGamePlayersData(singleGamePlayersDataTeam1)
    singleGameTeamDataT2 <- condenseSingleGamePlayersData(singleGamePlayersDataTeam2)
    
    # creating a column for game outcome
    singleGamePointsTeam1 <- singleGameTeamDataT1$Points
    singleGamePointsTeam2 <- singleGameTeamDataT2$Points
    
    if (singleGamePointsTeam1 > singleGamePointsTeam2) {
      singleGameTeamDataT1$GameOutcome = factor('win')
      singleGameTeamDataT2$GameOutcome = factor('loss')
    } else {
      singleGameTeamDataT1$GameOutcome = factor('loss')
      singleGameTeamDataT2$GameOutcome = factor('win')
    }
    
    # creating a column for opponent team
    singleGameTeamDataT1$OpponentTeam <- opposingTeams[2]
    singleGameTeamDataT2$OpponentTeam <- opposingTeams[1]
    
    singleGameDataBothTeams <- rbind(singleGameTeamDataT1, singleGameTeamDataT2)
    teamsData <- rbind(teamsData, singleGameDataBothTeams)

    # remaining iteration counter
    print(n - i) 
  }    

  # patching columns with NA values for percentage calculations
  teamsData$FieldGoalPercentage <- round(teamsData$FieldGoals / teamsData$FieldGoalAttempts, 2)
  teamsData$ThreePointerPercentage <- round(teamsData$ThreePointers / teamsData$ThreePointerAttempts, 2)
  teamsData$FreeThrowPercentage <- round(teamsData$FreeThrows / teamsData$FreeThrowAttempts, 2)
  teamsData$TwoPointerPercentage <- round(teamsData$TwoPointers / teamsData$TwoPointerAttempts, 2)
  
  # removing MinutesPlayed variable and replacing with GameDuration
  gameDurations <- round(teamsData$MinutesPlayed)
  teamsData <- subset(teamsData, select = - MinutesPlayed)
  teamsData$GameDuration <- gameDurations
  
  # creating a variable for the number of overtimes (OTs) from players' cumulative minutes 
  teamsData$Overtime <- (gameDurations - 240) / 25

  # return final version  
  return(teamsData)
}



############ Step 1 & 2. Remove "." character in playersData columns and renaming columns 9
############ through 11 for the players' data
colnames(playersData)
colnames(playersData)[1] <- 'GameID'
colnames(playersData)[4] <- 'PlayerID'
colnames(playersData)[5] <- 'MinutesPlayed'
colnames(playersData)[6] <- 'FieldGoals'
colnames(playersData)[7] <- 'FieldGoalAttempts'
colnames(playersData)[8] <- 'FieldGoalPercentage'
colnames(playersData)[9] <- 'ThreePointersMade'
colnames(playersData)[10] <- 'ThreePointerAttempts'
colnames(playersData)[11] <- 'ThreePointerPercentage'
colnames(playersData)[12] <- 'FreeThrows'
colnames(playersData)[13] <- 'FreeThrowAttempts'
colnames(playersData)[14] <- 'FreeThrowPercentage'
colnames(playersData)[15] <- 'OffensiveRebounds'
colnames(playersData)[16] <- 'DefensiveRebounds'
colnames(playersData)[17] <- 'TotalRebounds'
colnames(playersData)[22] <- 'PersonalFouls'
colnames(playersData)[24] <- 'PlusMinus'



############ Step 3. Convert GameID column datatype for the playersData
playersData$GameID <- as.character(playersData$GameID)



############ Step 4. Convert MinutesPlayed column to a numeric variable with decimal time 
############ scale in the players' data
head(playersData$MinutesPlayed)
playersData$MinutesPlayed <- as.character(playersData$MinutesPlayed)
secondsPlayed <- sapply(playersData$MinutesPlayed, convertMinutesPlayedToSeconds)
playersData$MinutesPlayed <- round(secondsPlayed / 60, 2)
head(playersData$MinutesPlayed)



############ Step 5. Add new columns: TwoPointersMade, TwoPointerAttempts, and 
############ TwoPointerPercentage in players' data.

#### creating TwoPointerAttempts column
playersData$TwoPointersMade <- playersData$FieldGoals - playersData$ThreePointersMade

#### creating TwoPointersMade column
playersData$TwoPointerAttempts <- playersData$FieldGoalAttempts - playersData$ThreePointerAttempts

#### creating TwoPointerPercentage column
playersData$TwoPointerPercentage <- round(playersData$TwoPointersMade / playersData$TwoPointerAttempts, 2)
naCond <- is.na(playersData$TwoPointerPercentage)
playersData[naCond, ]$TwoPointerPercentage <- NA  # replacing NaN with NA
head(playersData[naCond, ])



############ Step 6. Add new columns: GameDate, HomeGame (binary 'home' or 'away'), 
############ GameType (binary 'playoffs' or 'regular season'), Utilization (tertiary 
############ 'overplayed', 'underplayed', or 'moderate') to the playersData

#### creating GameDate column
playersData$Date <- as.Date(substr(playersData$GameID, 1, 8), format='%Y%m%d')

#### creating HomeGame column
hostTeam <- substr(playersData$GameID, 10, 12)
playersData$HomeGame <- ifelse(hostTeam==playersData$Team, 'home', 'away')

#### creating GameType column 
# Note: NBA playoffs began April 20, 2013 for the 2012 - 2013 season.
playoffStart <- as.Date('4-20-2013', format='%m-%d-%Y')
playersData$GameType <- ifelse(playersData$Date < playoffStart, 'regular season', 'playoffs')
playersData$GameType <- as.factor(playersData$GameType)

#### creating Utilization (teriary variable) column
# a player is classified as "overplayed" if his play minutes belonged in the top 10% quantile 
quantile(playersData$MinutesPlayed, probs=c(0.1, 0.9))  
overplayedThreshold <- quantile(playersData$MinutesPlayed, probs=c(0.1, 0.9))[2]
overplayedThreshold
underplayedThreshold <- quantile(playersData$MinutesPlayed, probs=c(0.1, 0.9))[1]
underplayedThreshold
p <- nrow(playersData); p
playersData$Utilization <- rep(NA, p)

#### teriary ifelse vectorized
playersData$Utilization <- ifelse(playersData$Minutes >= overplayedThreshold, 'overplayed',
                                  ifelse(playersData$Minutes <= underplayedThreshold, 
                                         'underplayed', 'moderate'))

#### converting to a factor variable
playersData$Utilization <- as.factor(playersData$Utilization)

#### quick check
table(playersData$Utilization)  
# good; roughly equal numbers of overplayed and underplayed players



############ Step 7. Create a new dataset, teamsData, in which information about all the NBA 
############ games for the 2012-2013 season is broken down by teams (not individuals players). 
############
############ Exclude unnecessary columns from playersData: Player, PlayerID, MinutesPlayed 
############ (of individual players'), or Utilization. 
############
############ Include GameDuration, Overtime, NumModeratelyPlayed, NumOverplayed, 
############ NumUnderplayed, GameOutcome, and OpponentTeam columns

# note that the below code may take several minutes 
teamsData <- createTeamsData(playersData)

#### teamsData dataset quality check
head(teamsData)
names(teamsData)
table(teamsData$FieldGoalAttempts == teamsData$ThreePointerAttempts + teamsData$TwoPointerAttempts)
table(teamsData$TwoPointersMade * 2 + teamsData$ThreePointersMade * 3 + teamsData$FreeThrows * 1 == teamsData$Points)



############ Step 8. Add new columns: GameDuration (integer), Overtime (integer),
############ OpponentTeam (factor), GameOutcome (binary 'win' or 'loss'), and TeamPoints 
############ (integer) in the players' data.
p <- nrow(playersData); p
t <- nrow(teamsData); t
gameIDs <- teamsData$GameID

#### creating dummy columns in the playersData dataset
playersData$GameDuration <- rep(NA, p)
playersData$Overtime <- rep(NA, p)
playersData$OpponentTeam <- rep(NA, p)
playersData$GameOutcome <- rep(NA, p)
playersData$TeamPoints <- rep(NA, p)

#### loop over all the game IDs and populate missing values for the five new columns 
#### in playersData
#### below code is very slow; it may take up to several hours
for (i in 1:t) {
  # for game duration (in minutes) and number of overtimes
  # columns can be specified only by using game ID b/c both teams in a single game
  # share the same game duration and number of overtimes
  playersData[playersData$GameID==gameIDs[i], ]$GameDuration <- teamsData$GameDuration[i]
  playersData[playersData$GameID==gameIDs[i], ]$Overtime <- teamsData$Overtime[i]
  
  # creating handles
  teamsSingleGame <- teamsData[teamsData$GameID==gameIDs[i], ]  
  teams <- as.character(teamsSingleGame$Team)
  gameOutcomes <- as.character(teamsSingleGame$GameOutcome)
  opponentTeams <- as.character(teamsSingleGame$OpponentTeam)
  teamPoints <- teamsSingleGame$Points
  
  # for game outcome, opponent team, team points
  # columns must be specified using playersData subsetted by game ID AND team name since
  # game outcome, opponent tea, and team points differ between the opposing teams
  # in a single game
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[1], ]$GameOutcome <- gameOutcomes[1]
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[1], ]$OpponentTeam <- opponentTeams[1]
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[1], ]$TeamPoints <- teamPoints[1]
  
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[2], ]$GameOutcome <- gameOutcomes[2]
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[2], ]$OpponentTeam <- opponentTeams[2]
  playersData[playersData$GameID==gameIDs[i] & playersData$Team==teams[2], ]$TeamPoints <- teamPoints[2]

  # remaining iterations counter
  print(t - i)
}



############ Step 9. Add new columns for opponent stats: OpponentNumPlayers, 
############ OpponentFieldGoals, OpponentFieldGoalAttempts, OpponentThreePointersMade, etc.
############ in the teams' data

## initial setup
t <- nrow(teamsData)
selectCond1 <- rep(c(TRUE, FALSE), t/2)
selectCond2 <- !selectCond1
head(selectCond1)
head(selectCond2)
length(selectCond1) 
length(selectCond2)
t

## columns to duplicate for opponent team's stats
columnSelectors <- c('NumPlayers', 'FieldGoals', 'FieldGoalAttempts', 'FieldGoalPercentage', 
                     'ThreePointersMade', 'ThreePointerAttempts', 'ThreePointerPercentage',
                     'FreeThrows', 'FreeThrowAttempts', 'FreeThrowPercentage', 
                     'OffensiveRebounds', 'DefensiveRebounds', 'TotalRebounds', 'Assists',
                     'Steals', 'Blocks', 'Turnovers', 'PersonalFouls', 'Points',
                     'TwoPointersMade', 'TwoPointerAttempts', 'TwoPointerPercentage', 
                     'NumModeratelyPlayed', 'NumOverplayed', 'NumUnderplayed')

## quick check for spelling error
columnSelectors %in% names(teamsData) 

## looping over the column selectors for opponent team's stats
n <- length(columnSelectors); n
for (i in 1:n) {
  columnSelector <- columnSelectors[i]
  columnVector <- teamsData[, columnSelector]
  columnVector1 <- columnVector[selectCond1]
  columnVector2 <- columnVector[selectCond2]
  flippedColumnVector <- as.vector(rbind(columnVector2, columnVector1))
  newColumnName <- paste('Opponent', columnSelector, sep='')
  teamsData[newColumnName] <- flippedColumnVector
}

## quality check
names(teamsData)
head(teamsData)



############ Step 10. Add new columns: OffensiveReboundPercentage, DefensiveReboundPercentage, 
############ OpponentOffensiveReboundPercentage, OpponentDefensiveReboundPercentage
############ in the teams' data

# ORB% = OffReb / (OffReb + OppDefReb)
# DRB% = DefReb / (DefReb + OppOffReb)
# OppORB% = OppOffReb / (OppOffReb + DefReb)
# OppDRB% = OppDefReb / (OppDefReb + OffReb)

###### creating a column for offensive rebound percentage
teamsData$OffensiveReboundPercentage <-
  round(teamsData$OffensiveRebounds / (teamsData$OffensiveRebounds + teamsData$OpponentDefensiveRebounds), 2)

###### creating a column for defensive rebound percentage
teamsData$DefensiveReboundPercentage <- 
  round(teamsData$DefensiveRebounds / (teamsData$DefensiveRebounds + teamsData$OpponentOffensiveRebounds), 2)

###### creating a column for opponent's offensive rebound percentage
teamsData$OpponentOffensiveReboundPercentage <- 
  round(teamsData$OpponentOffensiveRebounds / (teamsData$OpponentOffensiveRebounds + teamsData$DefensiveRebounds), 2)

###### creating a column for opponent's defensive rebound percentage
teamsData$OpponentDefensiveReboundPercentage <-
  round(teamsData$OpponentDefensiveRebounds / (teamsData$OpponentDefensiveRebounds + teamsData$OffensiveRebounds), 2)

###### quality check
min(teamsData$OffensiveReboundPercentage)
min(teamsData$DefensiveReboundPercentage)
max(teamsData$OffensiveReboundPercentage)
max(teamsData$DefensiveReboundPercentage)
min(teamsData$OpponentOffensiveReboundPercentage)
min(teamsData$OpponentDefensiveReboundPercentage)
max(teamsData$OpponentOffensiveReboundPercentage)
max(teamsData$OpponentDefensiveReboundPercentage)



############ Step 11. Add new column: ScoreGroup and OpponentScoreGroup in the teams' data
#### preliminary tests
min(teamsData$Points)
max(teamsData$Points)

#### adding a new column
teamsData$ScoreGroup <- factor(round(teamsData$Points, -1))
teamsData$OpponentScoreGroup <- factor(round(teamsData$OpponentPoints, -1))
# note that the code above doesn't always round down teams' points
# for example, 96 points does NOT belong to the 90s groups; it is rounded up and belongs
# to the 100s groups



############ Step 12. Export the processed data into the processed data folder

#### final brief review of data
head(playersData)
tail(playersData)
head(teamsData)
tail(teamsData)

#### exporting data
save(playersData, file='./data/processedData/playersData.RData')
save(teamsData, file='./data/processedData/teamsData.RData')



############ Clearing all variable names
rm(list=ls())

