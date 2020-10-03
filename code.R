#Gets sum of steps per date
totalDaily <- tapply(activity$steps, activity$date, sum)

#Generates histogram of steps per day
hist(totalDaily, 
     xlab = "Number of Steps",
     main = "Histogram: Steps per Day",
     col="lightseagreen")

#Gets mean and median and prints result to console
meanDaily <- mean(totalDaily,na.rm=TRUE)
medianDaily <- median(totalDaily,na.rm=TRUE)
cat("Mean is",meanDaily," and median is", medianDaily)

#Gets time series of mean steps per day
intervalMean <- activity[, c(lapply(.SD, mean, na.rm = TRUE)), 
                         .SDcols = c("steps"), 
                         by = .(interval)] 

#plot intervalMean
ggplot(intervalMean, aes(x = interval , y = steps)+
         geom_line(color="forestgreen", size=1)+
         labs(title = "Average Daily Steps", 
              x = "Interval", 
              y = "Average Steps per day")
       )

#Interval with max steps
intervalMean[steps == max(steps), .(max_interval = interval)]

#Imputing missing values
totalInterval <- tapply(activity$steps, activity$interval, sum)
activity.split <- split(activity, activity$interval)
for(i in 1:length(activity.split)){
  activity.split[[i]]$steps[is.na(activity.split[[i]]$steps)] <- totalInterval[i]
}
activity.imputed <- do.call("rbind", activity.split)

#Taking mean and median for imputed data
meanDaily.imputed <- mean(totalDaily.imputed,na.rm=TRUE)
medianDaily.imputed <- median(totalDaily.imputed,na.rm=TRUE)

#Assign weekday/weekend tagging to obs 
activity.imputed$day <- ifelse(weekdays(as.Date(activity.imputed$date)) == "Saturday" | weekdays(as.Date(activity.imputed$date)) == "Sunday", "weekend", "weekday")

#Take mean per date per day category
library(plyr); library(dplyr)
totalDay <- ddply(activity.imputed, .(interval, day), summarize, meanDay = mean(steps, na.rm=TRUE))

#Plot in lattice
library(lattice)
xyplot(meanDay~interval|day, data=totalDay, type="l",  layout = c(1,2),
       main="Average Steps per Interval Based on Type of Day", 
       ylab="Average Number of Steps", xlab="Interval")