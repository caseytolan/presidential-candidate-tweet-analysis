# presidential-candidate-tweet-analysis
An analysis of Democratic presidential candidate tweets to determine which candidates are tweeting the most about President Trump. Used for data analysis in this San Jose Mercury News article: https://www.mercurynews.com/2019/06/13/california-primary-trump-twitter-presidential-candidates-swalwell/

I downloaded the most recent 3,200 tweets from the twitter accounts of 23 candidates using the Rtweet library, saving them all in CSV's in the output directory. The PresTwitterDirectory.csv includes the account names of all the candidates' main campaign accounts.

One candidate, Andrew Yang, tweets so much that at the time I was running this analysis he had already tweeted more than 3,200 times in 2019. So I combined his newer tweets with older ones I had previously downloaded -- the full dataset of his tweets and all other candidates' tweets are in the olderDownloadedTweets directory. 

The script then runs an anylsis to determine which candidates tweet the most about Trump, pulling the data from  olderDownloadedTweets. It excludes retweets and only counts for the first five months of 2019. I counted all tweets that included the word "Trump" in the text (including any permutation of the word, such as "Trumpism") or were quote-tweets of something tweeted by the president's accounts, @realDonaldTrump and @POTUS.

The final results of the analysis are in the TweetsAnalysisResults.csv file. 
