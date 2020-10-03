Introduction
============

It is now possible to collect a large amount of data about personal
movement using activity monitoring devices such as a Fitbit, Nike
Fuelband, or Jawbone Up. These type of devices are part of the
“quantified self” movement – a group of enthusiasts who take
measurements about themselves regularly to improve their health, to find
patterns in their behavior, or because they are tech geeks. But these
data remain under-utilized both because the raw data are hard to obtain
and there is a lack of statistical methods and software for processing
and interpreting the data.

This assignment makes use of data from a personal activity monitoring
device. This device collects data at 5 minute intervals through out the
day. The data consists of two months of data from an anonymous
individual collected during the months of October and November, 2012 and
include the number of steps taken in 5 minute intervals each day.

The data for this assignment can be downloaded from the course web site:
[Activity monitoring
data](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip)

The variables included in this dataset are:

**steps**: Number of steps taking in a 5-minute interval (missing values
are coded as `NA`)  
**date**: The date on which the measurement was taken in YYYY-MM-DD
format  
**interval**: Identifier for the 5-minute interval in which measurement
was taken The dataset is stored in a comma-separated-value (CSV) file
and there are a total of 17,568 observations in this dataset.

Goal of the code and this markdown file
=======================================

1.  Code for reading in the dataset and/or processing the data
2.  Histogram of the total number of steps taken each day
3.  Mean and median number of steps taken each day
4.  Time series plot of the average number of steps taken
5.  The 5-minute interval that, on average, contains the maximum number
    of steps
6.  Code to describe and show a strategy for imputing missing data
7.  Histogram of the total number of steps taken each day after missing
    values are imputed
8.  Panel plot comparing the average number of steps taken per 5-minute
    interval across weekdays and weekends
9.  All of the R code needed to reproduce the results (numbers, plots,
    etc.) in the report

### Obtaining data

Data is taken from course website and is available from [data
source](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip)

Check if file is already existing and if not, download the file. If the
file is present, check if it has already been unzipped and if not, unzip
file. We also need to make sure we know when the data was downloaded in
case it changes over time.

    url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
    path <- getwd()
    dataFile <- "dataFiles.zip"

    if (!file.exists(dataFile)){
      download.file(url, file.path(path, dataFile))
    }
    if (!file.exists("activity.csv")){
      unzip(dataFile)
    }
    tstp <- date()
    tstp

    ## [1] "Sat Oct 03 14:26:48 2020"

Read the data and display summary

    activity <- data.table::fread(input = "activity.csv")
    summary(activity)

    ##      steps             date               interval     
    ##  Min.   :  0.00   Min.   :2012-10-01   Min.   :   0.0  
    ##  1st Qu.:  0.00   1st Qu.:2012-10-16   1st Qu.: 588.8  
    ##  Median :  0.00   Median :2012-10-31   Median :1177.5  
    ##  Mean   : 37.38   Mean   :2012-10-31   Mean   :1177.5  
    ##  3rd Qu.: 12.00   3rd Qu.:2012-11-15   3rd Qu.:1766.2  
    ##  Max.   :806.00   Max.   :2012-11-30   Max.   :2355.0  
    ##  NA's   :2304

### Summarize steps per day with a histogram

    totalDaily <- tapply(activity$steps, activity$date, sum)

    hist(totalDaily, xlab = "Number of Steps", main = "Histogram: Steps per Day",col="lightseagreen")

![](PA1_template_files/figure-markdown_strict/dailyHistogram-1.png)

Find mean and median for steps per day

    meanDaily <- mean(totalDaily,na.rm=TRUE)
    medianDaily <- median(totalDaily,na.rm=TRUE)

    cat("Mean is",meanDaily," and median is", medianDaily)

    ## Mean is 10766.19  and median is 10765

### Timeseries of mean steps daily and interval with max steps

Create a dataset that contains the mean number of steps per interval and
plot in a line graph using ggplot

    intervalMean <- activity[, c(lapply(.SD, mean, na.rm = TRUE)), 
                             .SDcols = c("steps"), 
                             by = .(interval)] 

    library(ggplot2)
    ggplot(intervalMean, aes(x = interval , y = steps)) + 
      geom_line(color="forestgreen", size=1) + 
      labs(title = "Average Daily Steps", 
           x = "Interval", 
           y = "Average Steps per day")

![](PA1_template_files/figure-markdown_strict/meanSteps-1.png)

Find 5-minute interval with the maximum number of steps

Find the 5 minute interval with max steps

    intervalMean[steps == max(steps), .(max_interval = interval)]

    ##    max_interval
    ## 1:          835

### Imputing missing values

First, we check how many NAs we have in the dataset

    nrow(activity[is.na(activity$steps),])

    ## [1] 2304

Next, we decide on the approach we want to take in filling the missing
inputs. Note that in general, we want to fill it in a way that doesn’t
alter the results. To do this, I have chosen to fill the data with the
mean for the 5-minute interval it belongs to.

The first step is to get the mean per interval.

    totalInterval <- tapply(activity$steps, activity$interval, sum)

Then, we want to split the bigger dataset per interval.

    activity.split <- split(activity, activity$interval)

Finally, we want to take the mean for each interval and use it to fill
the NAs. We do this with a for loop. We then bind the result into a new

    for(i in 1:length(activity.split)){
      activity.split[[i]]$steps[is.na(activity.split[[i]]$steps)] <- totalInterval[i]
    }

    activity.imputed <- do.call("rbind", activity.split)

Taking both data with NA and data with no NAs to create a histogram

    totalDaily.imputed <- tapply(activity$steps, activity$date, sum)

    hist(totalDaily.imputed, xlab = "Number of Steps", main = "Histogram: Steps per Day",col="aquamarine")
    hist(totalDaily, xlab = "Number of Steps", main = "Histogram: Steps per Day",col="lightseagreen",add=T)
    legend("topright", c("Imputed Data", "Non-NA Data"), fill=c("aquamarine", "lightseagreen") )

![](PA1_template_files/figure-markdown_strict/imputed-1.png)

Visually, there’s not much difference between the Imputed Data and
non-NA data. We can also take the mean and median for the imputed data
and compare it with our initial observations.

    meanDaily.imputed <- mean(totalDaily.imputed,na.rm=TRUE)
    medianDaily.imputed <- median(totalDaily.imputed,na.rm=TRUE)

    cat("Mean for non-NA data:",meanDaily,"and mean for imputed data", meanDaily.imputed)

    ## Mean for non-NA data: 10766.19 and mean for imputed data 10766.19

    cat("Median for non-NA data:",medianDaily,"and median for imputed data", medianDaily.imputed)

    ## Median for non-NA data: 10765 and median for imputed data 10765

Are there differences in the activity pattern between weekdays and weekends?
----------------------------------------------------------------------------

First, we create a new dataset which is original activity dataset with
an additional column that tags an observation as either weekend or
weekday.

    activity.imputed$day <- ifelse(weekdays(as.Date(activity.imputed$date)) == "Saturday" | weekdays(as.Date(activity.imputed$date)) == "Sunday", "weekend", "weekday")

Take the mean observations for weekdays and weekends respectively

    library(plyr); library(dplyr)

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:plyr':
    ## 
    ##     arrange, count, desc, failwith, id, mutate, rename, summarise,
    ##     summarize

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    totalDay <- ddply(activity.imputed, .(interval, day), summarize, meanDay = mean(steps, na.rm=TRUE))

Create a two panel plot

    library(lattice)
    xyplot(meanDay~interval|day, data=totalDay, type="l",  layout = c(1,2),
           main="Average Steps per Interval Based on Type of Day", 
           ylab="Average Number of Steps", xlab="Interval")

![](PA1_template_files/figure-markdown_strict/weekPlot-1.png)
