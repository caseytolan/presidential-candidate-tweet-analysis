### ANALYZING PRESIDENTIAL CANDIDATE TWEETS
### By Casey Tolan
### Downloads all tweets from the Democratic presidential candidates and analyzes them based on how often they mention Trump
### Used for data analysis in this San Jose Mercury News article: https://www.mercurynews.com/2019/06/13/california-primary-trump-twitter-presidential-candidates-swalwell/

# Getting started:
rm(list = ls()) #clear existing variables
setwd("~/Desktop/presidential-candidate-twitter-analysis/")
library("dplyr")
library("data.table")
library("readr")
library("rtweet")

# This is a list of all the candidates' twitter handles
tweetDirectory <- read.csv("PresTwitterDirectory.csv",stringsAsFactors=FALSE)

# ----------------------------------------------------------------------
# DOWNLOADING PRESIDENTIAL CANDIDATE TWEETS
# The Rtweet library can download the most recent 3,200 tweets from any account. This takes them from all 23 Dem candidates and saves a list of each of their tweets as a CSV
pb <- txtProgressBar(min = 0, max = nrow(tweetDirectory), style = 3)
for (row in 1:nrow(tweetDirectory)) {
  
  # Retry on rate limit is important to get all the tweets
  timeline <- get_timelines(tweetDirectory$TwitterHandle[row], n = 3200, retryonratelimit = TRUE)
  
  # Only keeping values we need -- could keep all data if wanted
  timeline <- select(timeline,"created_at","screen_name","text","source","is_quote","is_retweet","favorite_count","retweet_count","quoted_screen_name","retweet_screen_name","status_url","place_full_name")
  write.csv(timeline, paste("output/Tweets-",tweetDirectory$CandidateName[row],".csv",sep=""))
  
  setTxtProgressBar(pb,row) #for viewing progress
}

# At the time I ran this analysis, 3,200 tweets was enough to get all 2019 tweets from every candidate except Andrew Yang. I had older tweets from him previously downloaded, and I added those into his CSV. 
# The full Andrew Yang dataset with all of his tweets from 2019 is in the downloadedTweets directory we use for analysis. A more recent one is in the output directory
# For future analyses, I plan to download the most recent tweets and append them to our already downloaded datasets of past tweets

# ----------------------------------------------------------------------
# ANALYSIS OF TWEETS
# This will analyze tweets to determine the number of tweets they sent in 2019 that mention any permutation of the word "Trump" -- including @realDonaldTrump -- or quote-tweet the president
# I also analyzed how many tweets were replies (did not use that data in this story)

resultsChart <- data.frame(matrix(ncol = 9, nrow = 1)) # To collect results
colnames(resultsChart) <- c("CandidateName","TotalTweets","EarliestTweet","TweetsIn2019","TrumpTweetsIn2019","TrumpPercentIn2019","TrumpTaggedTweetsIn2019","RepliesIn2019","ReplyPercentIn2019")

pb <- txtProgressBar(min = 0, max = nrow(tweetDirectory), style = 3)
for (file in 1:nrow(tweetDirectory)) {
  
  # Read in the database of tweets (this reads in the previously downloaded data that includes all 2019 tweets for Yang)
  tweetList <- read.csv(paste("olderDownloadedTweets/Tweets-",tweetDirectory$CandidateName[file],"-6-7-19.csv",sep=""),stringsAsFactors=F)
  colnames(tweetList) <- c("X","created_at","screen_name","tweet_text","tweet_source","is_quote","is_retweet","favorite_count","retweet_count","quoted_screen_name","retweet_screen_name","status_url","place_full_name")
  
  # This is helpful for seeing how far back our database of 3,200 tweets goes
  earliestTweet <- tweetList$"created_at"[nrow(tweetList)]
  
  # We're excluding retweets from the analysis
  tweetList <- filter(tweetList,tweetList$"is_retweet" == FALSE) 

  # Get tweets in the first five months of 2019
  tweetsLastYear <- filter(tweetList,(as.Date(tweetList$"created_at") > as.Date("2018-12-31"))&(as.Date(tweetList$"created_at") < as.Date("2019-06-01"))) 
  
  # Get tweets that mention the word Trump or are a quote-tweet of @realDonaldTrump or @POTUS, and determine their percent of all tweets
  trumpTweetsLastYear <- filter(tweetsLastYear,grepl("Trump|TRUMP|trump",tweet_text)|grepl("realDonaldTrump|POTUS",quoted_screen_name))
  trumpRatio <- (nrow(trumpTweetsLastYear)/nrow(tweetsLastYear))*100
  
  # Get tweets that tag Trump in them or quote-tweet Trump
  trumpTaggedTweetsLastYear <- filter(tweetsLastYear,grepl("@realdonaldtrump|@RealDonaldTrump|@realDonaldTrump|@realdonaldTrump|@REALDONALDTRUMP|@POTUS|@potus",tweet_text)|grepl("realDonaldTrump|POTUS",quoted_screen_name))

  # Get replies (tweets that start with "@") -- didn't end up using this in the story
  replies <- filter(tweetsLastYear,substr(tweet_text,1,1)=="@")
  repliesratio <- (nrow(replies)/nrow(tweetsLastYear))*100
  
  # Compile results and save in resultsChart
  # Columns of resultsChart: "CandidateName","TotalTweets","EarliestTweet","TweetsIn2019","TrumpTweetsIn2019","TrumpPercentIn2019","TrumpTaggedTweetsIn2019","RepliesIn2019","ReplyPercentIn2019"
  MyResults <- c(tweetDirectory$CandidateName[file],
                 nrow(tweetList),
                 earliestTweet,
                 nrow(tweetsLastYear),
                 nrow(trumpTweetsLastYear),
                 trumpRatio,
                 nrow(trumpTaggedTweetsLastYear),
                 nrow(replies),
                 repliesratio)
  resultsChart <- rbind(resultsChart,MyResults)
  
  setTxtProgressBar(pb,file) #for viewing progress
  
}

# ----------------------------------------------------------------------
# FINISHING UP
# Arrange and save our results
resultsChart <- arrange(resultsChart,desc(as.numeric(TrumpPercentIn2019)))
write.csv(resultsChart, "TweetsAnalysisResults.csv")