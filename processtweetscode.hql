--JAR to convert JSon format raw data to the tabular form
add jar s3://elasticmapreduce/samples/hive-ads/libs/jsonserde.jar;

--Get the raw json format into the table
CREATE EXTERNAL TABLE tweets_raw (
   id BIGINT,
   created_at STRING,
   source STRING,
   favorited BOOLEAN,
   retweet_count INT,
   retweeted_status STRING,
   entities STRING,
   text STRING,
   user STRING,
   in_reply_to_screen_name STRING,
   year int,
   month int,
   day int,
   hour int
)
ROW FORMAT SERDE 'com.amazon.elasticmapreduce.JsonSerde' with serdeproperties ( 
      'paths'='id, created_at, source, favourited, retweet_count, retweeted_status, entities, text, user, in_reply_to_screen_name, year, month, day, hour '
    )
LOCATION 's3://stockpredict/input/'
;


--Create a table for the dictionary with polarity
CREATE EXTERNAL TABLE dictionary (
    type string,
    length int,
    word string,
    pos string,
    stemmed string,
    polarity string
)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' 
STORED AS TEXTFILE
LOCATION 's3://stockpredict/input2/';


--Clean up the raw data into a view
CREATE VIEW tweets_simple AS
SELECT
  id,
  cast ( from_unixtime( unix_timestamp(concat( '2014 ', substring(created_at,5,15)), 'yyyy MMM dd')) as timestamp) ts,
  text 
FROM tweets_raw
;

--Create views to match the words with the ones in the dictionary
 create view l1 as select id,words from tweets_simple lateral view explode(sentences(lower(text))) dummy as words;
 create view l2 as select id,word from l1 lateral view explode( words ) dummy as word ;
 create view l3 as select 
     id,
     l2.word, 
     case d.polarity 
       when  'negative' then -1
       when 'positive' then 1 
       else 0 end as polarity 
  from l2 left outer join dictionary d on l2.word = d.word;

  
--Create a table to store the overall sentiment for tweet 
create table tweets_sentiment as select 
  id, 
  case 
    when sum( polarity ) > 0 then 1
    when sum( polarity ) < 0 then -1  
    else 0 end as sentiment 
 from l3 group by id;

--Get all the tweets with date to group them so that we get the sentiment date wise
CREATE TABLE tweets_final
AS
SELECT 
  t.id,t.ts,sentiment  
FROM tweets_simplified t LEFT OUTER JOIN tweets_sentiment s on t.id = s.id;

--Finally sum up the sentiment of all the tweets according to the dates
CREATE table tweets_final_table
AS
SELECT ts,
  case 
    when sum(sentiment) > 0 then 1
    when sum(sentiment) < 0 then -1
    else 0 end as final_sentiment
FROM tweets_final where ts is NOT NULL group by ts;

//Add the result into the cluster folder
insert overwrite directory 's3://stockpredict/twitter_output/' select * from tweets_final_table;

=======================================WSJ====================================

--Create table similar to twitter for raw wsj data
create external table wsj_raw(
time STRING,
date STRING,
headline STRING,
content String)
ROW FORMAT SERDE 'com.amazon.elasticmapreduce.JsonSerde' with serdeproperties ( 
      'paths'='Time, Date, Headline, Content'
    )
LOCATION 's3://stockpredict/wsjinput/'
;

--create view to get the polarity by matching them with the dictioary
create view h1 as select date, words from wsj_raw lateral view explode(sentences(lower(headline))) dummy as words;
create view h2 as select date, word from h1 lateral view explode( words ) dummy as word ;
create view h3 as select 
     date, 
     h2.word, 
     case d.polarity 
       when  'negative' then -1
       when 'positive' then 1 
       else 0 end as polarity 
from h2 left outer join dictionary d on h2.word = d.word;


--Analyse polarity only for the headline of the news
create table wsj_headline_sentiment as select 
  date, 
  case 
    when sum( polarity ) > 0 then 1
    when sum( polarity ) < 0 then -1  
    else 0 end as sentiment 
 from h3 group by date;
 
 ====================================================WSJ=====================================
 
--Analyzing polarity similar to the able queries
create view c1 as select date, words from wsj_raw lateral view explode(sentences(lower(content))) dummy as words;
create view c2 as select date, word from c1 lateral view explode( words ) dummy as word ;
create view c3 as select 
     date, 
     c2.word, 
     case d.polarity 
       when  'negative' then -1
       when 'positive' then 1 
       else 0 end as polarity 
from c2 left outer join dictionary d on c2.word = d.word;
 
 --Analyse the polarity for the content of the wsj news
create table wsj_content_sentiment as select 
  date, 
  case 
    when sum( polarity ) > 0 then 1 
    when sum( polarity ) < 0 then -1
    else 0 end as sentiment 
 from c3 group by date;

 --Finally get headline and content sentiment together in a table
create table wsj_final as 
select * from (
SELECT date, sentiment FROM wsj_headline_sentiment
UNION ALL SELECT date, sentiment FROM wsj_content_sentiment group by date);

--create a new table to get the final output
create table wsj_final (
date String,
sentiment int
);

--insert the the headline and content to the wsj_final table
insert into table wsj_final select * from wsj_content_sentiment;
insert into table wsj_final select * from wsj_headline_sentiment;


--get the sum of sentiment of wsj data in total and store them in the final table
create table wsj_output as
select date,
case
  when sum(sentiment) > 0 then 1
  when sum(sentiment) < 0 then -1
  else 0 end as sentiment
from wsj_final group by date;

//insert the result into the s3 bucket folder
insert overwrite directory 's3://stockpredict/wsj_output/' select * from wsj_output; 



=====================================================================================================

