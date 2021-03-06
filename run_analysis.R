library(dplyr)
## dplyr version 1.0.7
library(tidyr)
## tidyr version 1.1.3

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, destfile = "project.zip", method = "curl")
unzip("project.zip")

features <- read.table("UCI HAR Dataset/features.txt", 
		       col.names = c("n", "feature"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
			 col.names = c("activity_number", "activity"))
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", 
			   col.names = "subject")
train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", 
			     col.names = "subject")
test_data <- read.table("UCI HAR Dataset/test/X_test.txt", 
		     col.names = features$feature)
train_data <- read.table("UCI HAR Dataset/train/X_train.txt", 
			 col.names = features$feature)
test_labels <- read.table("UCI HAR Dataset/test/y_test.txt", 
		     col.names = "activity_number")
train_labels <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_number")

## Merges the training and the test sets to create one data set.
combined_data <- rbind(test_data, train_data)
labels <- rbind(test_labels, train_labels)
subjects <- rbind(test_subjects, train_subjects)
merge <- cbind(combined_data, labels, subjects)

## Extracts only the measurements on the mean and 
## standard deviation for each measurement. 
data <- select(merge, subject, activity_number, contains("mean"), contains("std"))

## Uses descriptive activity names to name the activities in the data set
activities$activity <- tolower(activities$activity)
activities$activity <- gsub("_" , " " , activities$activity)
data$activity_number <- activities[data$activity_number, 2]

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
## with the average of each variable for each activity and each subject
tidy_data <- group_by(data, Activity, Subject) %>% 
	summarize_all(mean, na.rm = TRUE)

exclude <- c("Subject", "Activity")
tidy_data <- tidy_data %>% gather(Feature, Mean, -exclude)

write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
