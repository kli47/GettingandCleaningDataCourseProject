README.md for Getting and Cleaning Data Course Project
-Kevin Li (github: kli47) 7/1/21 

This README.md explains how all the scripts in run_analysis.R work and how they are connected. run_analysis.R is copied in full below

------
# loads dplyr (version 1.0.7) and tidyr (version 1.1.3)
library(dplyr)
library(tidyr)

# downloads Human Activity Recognition Using Smartphones Data Set from provided link and unzips file creating folder UCI HAR Dataset with in working directory
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

download.file(url, destfile = "project.zip", method = "curl")

unzip("project.zip")

# loads each data set file into R with column names as indicated by README.txt in UCI HAR Dataset folder 

features <- read.table("UCI HAR Dataset/features.txt", col.names = c("n", "feature"))

activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("activity_number", "activity"))

test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")

train_subjects <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")

test_data <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$feature)

train_data <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$feature)

test_labels <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "activity_number")

train_labels <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "activity_number")

# uses rbind to make df of both the training and test sets of data 
combined_data <- rbind(test_data, train_data)

# uses rbind to make df containing all the labels of training and test groups
labels <- rbind(test_labels, train_labels)

# uses rbind to create a df with all the subjects from the test and train groups
subjects <- rbind(test_subjects, train_subjects)

# cbind combines all columns to give a df with subjects, activity numbers, and features
merge <- cbind(combined_data, labels, subjects)

# uses dpylr select function to select() subject, activity number, and all columns containing "mean" or "std" using the selection helper contains(). This generates a data set (data) with the aforementioned columns
data <- select(merge, subject, activity_number, contains("mean"), contains("std"))

# changes activity names to lower case for readability (was originally capitalized)
activities$activity <- tolower(activities$activity)

# replaces underscores in activity names with spaces for readability
activities$activity <- gsub("_" , " " , activities$activity)

# changes code column of data df to the modified 
data$activity_number <- activities[data$activity_number, 2]

# Modified variable names for clarity. New names were primarly taken from features_info.txt in the original UCI HAR Dataset folder. This largely involved expanding abbreviations. This section utilizes names() and the gsub() function to replace identified arguments with clearer variable names. Note the use of ^t and ^f to only capture t and f in the beginning of the variable name.
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


# uses the dpylr group_by() function to group data df by Subject and Activity as instructed. Then used summarize_all(), a scoped variant of summarize(), to select every variable and take the mean. Creates new df tidy_data to store this data.
tidy_data <- group_by(data, Subject, Activity) %>% summarize_all(mean)

# uses gather() to reshape grouped data frame from wide to long format
exclude <- c("Subject", "Activity")
tidy_data <- tidy_data %>% gather(Feature, Mean, -exclude)

# creates new file called "tidy_data.txt" in default working directory, we do not have meaningful row names to retain
write.table(tidy_data, "tidy_data.txt", row.names = FALSE)
