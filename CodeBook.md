Code book for Getting and Cleaning Data Course Project
-Kevin Li (github: kli47) 6/30/21 

This markdown file explains the variables, data, and transformations preformed in run_analysis.R.

# 0. Load requites packages: we load dplyr package (version 1.0.7) and tidyr (version 1.1.3)

# 1. Download and inspect dataset
Dataset downloaded from provided link "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
which unzips to a folder called "UCI HAR Dataset"

folder "UCI HAR Dataset" contains:

activity_labels.txt

features_info.txt

features.txt

README.txt

test (file format: folder) 

	-> subject_test.txt

	-> X_test.txt

	-> y_test.txt

	-> Inertial Signals (file format: folder) - file is not accessed for analysis

train (file format: folder)

	-> subject_train.txt

	-> X_train.txt

	-> y_train.txt

	-> Inertial Signals (file format: folder) - file is not accessed for analysis



# 2. Input and store data into R
Descriptions of the various files contained in the "UCI HAR Dataset" folder are 
primarily found in file README.txt with some additional information in 
features_info.txt

Note: the volunteers in this data were split between a train group 
(70% of volunteers) and a test group (30% of volunteers) and thus both groups
have distinct data sets.

Data is stored according to the following variables 

features <- features.txt

a data frame of 561 rows and 2 columns. Columns are named n (to count the
feature number) and feature (to display the feature name). 

As stated in features_info.txt
"The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ."

activities <- activity_labels.txt

a data frame of 6 rows and 2 columns. Columns are named "activity_number" for 
the number corresponding to the activity and "activity" for the name of the activity

x_test <- X_test.txt

a data frame of 2947 rows and 561 columns
represents all the features of the test group (30% volunteers), 
columns correspond to each feature (see 1. features) 
and therefore their names borrow from features$functions

subject_test <- subject_test.txt

a data frame of 2947 rows and 1 column
contains subject number for test group (30% volunteers)

y_test <- y_test.txt

a data frame of 2947 rows and 1 column 
contains activity code corresponding to each test group data point 

x_train <- X_train.txt

a data frame of 7352 rows and 561 columns
represents all the features of the train group (70% volunteers), 
columns correspond to each feature (see 1. features) 
and therefore their names borrow from features$functions

subject_train <- subject_train.txt

a data frame of 7352 rows and 1 column
contains subject number for train group (70% volunteers)

y_train <- y_train.txt

a data frame of 7352 rows and 1 column
contains activity code corresponding to each train group data point 

# 3. Merge the train and test data into one set
We know that x_train and x_test share the same column names (because they both
take their column names from features$functions as their columns represent
the 561 functions in this dataset. Therefore we can merge them with rbind().

x_data <- rbind(x_train, x_test)

a data frame with 10299 rows and 561 columns representing all the features
for the train and test data

Similarly we know that y_train and y_test share the same column variable (the 
activity code for each data point)

y_data <- rbind(y_train, y_test)

a data frame with 10299 rows, 1 column representing all the activity codes for
the train and test data

We know that subject_train and subject_test share the same column variable
(the subject number)

subject <- rbind(subject_train, subject_test)

a data frame with 10299 rows and 1 column representing all the subject numbers
for the train and test data

We then combine all three into one data frame using cbind
merge <- cbind(x_data, y_data, subject)

a data frame with 10299 rows and 563 columns containing the subject number, 
activity code, and all the features for the train and test data set

# 4. Create a tidy data set with just the mean and standard deviation of each measurement
We can utilize the dplyr package that we loaded at the beginning of the script.
Using the select() function we can make a data set with the subject, activity 
number, and then all features that contain "mean" or "std" using the selection
helper contains(). 

data <- select(merge, subject, activity_number, contains("mean"), contains("std"))

This data set has 10299 rows and 88 columns. 

# 5. Add activity names to the data set
We clean up the activity names in the "activities" data frame

We use tolower(activities$activity) to lowercase the activities names which were 
all uppercase. We use gsub("_" , " " , activities$activity) to remove 
underscores and replace them with spaces. 

We then apply our modified activity names into the tidy data set 
data$activity_number <- activities[data$activity_number, 2]

# 6. Label the tidy data set with descriptive variable names
This section utilizes names() and the gsub() function to replace identified 
arguments with clearer variable names. Modified variable names were made in 
accordance to features_info.txt in the original UCI HAR Dataset folder. 
They were largely abbreviations.

Specifically:

-data column one was renamed "Subject"

-data column two was renamed "Activity"

-All "mean" in column names are replaced with "Mean"

-All "std" in column names are replaced with "StandardDeviation"

-All column names starting with "t" was replaced by "Time"

-All column names starting with "f" was replaced by "Frequency"

-All "Acc" in column names are replaced with "Accelerometer"

-All "Gyro" in column names are replaced with "Gyroscope"

-All "Mag" in column names are replaced with "Magnitude"

-All "angle"" in column names are replaced with "Angle"

-All "Ang" in column names are replaced with "Angle"

-All "gravity" in column names are replaced with "Gravity"

-All "BodyBody" in column names are replaced with "Body"

-All "...X" in column names are replaced with "X-Axis"

-All "...Y" in column names are replaced with "Y-Axis"

-All "...Z" in column names are replaced with "Z-Axis"

# 7. Create a second tidy data set with the average of each variable for each activity and each subject
We use dplyr function group_by() to group by activity and subject
We use dplyr function summarize_all() to apply function mean() to 
create the data frame tidy_data

We use gather() to reshape wide data into long data

We then export the data frame to the directory with write.table()