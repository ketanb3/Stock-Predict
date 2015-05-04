# Stock-Predict
Big Data Analytics project to predict the value of the company stocks using sentiment analysis of Social Media (Twitter) and News Data Sets (Wall Street Journal)

Steps implemented in this project:
1.Twitter raw dataset collected using Tweepy API (Twitter's API in Python) for approximately around 2 months
2.Wall Street Journal Data sets collected by crawling news dataset using Dow Jones Newswrires API
3.Custom ETL processes using Java and Python programs
4.The sentiment analysis is done for both datasets using dictionary file and sentiment of each word is obtained.
5.Hive script is used to load the raw datasets into dictionary and to aggregate the sentiment result
6.Using MS-EXCEL Forecast() function the value of the stock of the company(eg.Apple) is predicted by considering the historical trend of the stocks and sentiment analysis of news and social media data.
