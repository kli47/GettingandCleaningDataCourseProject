library(dplyr)
## dplyr version 1.0.7

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "project.zip", method = "curl")
unzip("project.zip")

features <- read.table("UCI HAR Dataset/features.txt", 
		       col.names = c("n", "functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
			 col.names = c("code", "activity"))
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", 
		     col.names = features$functions)
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", 
			   col.names = "subject")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", 
		     col.names = "code")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", 
		      col.names = features$functions)
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", 
			    col.names = "subject")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

## Merges the training and the test sets to create one data set.
x <- rbind(x_test, x_train)
y <- rbind(y_test, y_train)
subject <- rbind(subject_test, subject_train)
merge<-cbind(x, y, subject)

## Extracts only the measurements on the mean and 
## standard deviation for each measurement. 
data <- select(merge, subject, code, contains("mean"), contains("std"))

## Uses descriptive activity names to name the activities in the data set
activities$activity <- tolower(activities$activity)
activities$activity <- gsub("_" , " " , activities$activity)
data$code <- activities[data$code, 2]

## Appropriately labels the data set with descriptive variable names. 
names(data)[1] = "Subject"
names(data)[2] = "Activity"
names(data) <- gsub("mean", "Mean", names(data))
names(data) <- gsub("std", "StandardDeviation", names(data))
names(data) <- gsub("^t", "Time", names(data))
names(data) <- gsub("^f", "Frequency", names(data))
names(data) <- gsub("Acc", "Accelerometer", names(data))
names(data) <- gsub("Gyro", "Gyroscope", names(data))
names(data) <- gsub("Mag", "Magnitutde", names(data))
names(data) <- gsub("angle", "Angle", names(data))
names(data) <- gsub("Ang", "Angle", names(data))
names(data) <- gsub("gravity", "Gravity", names(data))
names(data) <- gsub("BodyBody", "Body", names(data))
names(data) <- gsub("...X", "X-Axis", names(data))
names(data) <- gsub("...Y", "Y-Axis", names(data))
names(data) <- gsub("...Z", "Z-Axis", names(data))

## From the data set in step 4, creates a second, independent tidy data set 
## with the average of each variable for each activity and each subject.
tidy_data <- group_by(data, Subject, Activity) %>% summarize_all(mean)
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
