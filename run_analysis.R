library(stringr)
library(dplyr)
library(tidyr)

# download the original zipped source file if not present
zipped_file <- "UCI_HAR_Dataset.zip"
if(!file.exists(zipped_file)) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  destfile=zipped_file,
                  method="curl")
}

# unzip the source file
unzip(zipped_file)

# read in the features dataset
features <- read.table("UCI HAR Dataset/features.txt", col.names=c("id","name"))
# manipulate it in a way that makes it usable for column names
# (everything to lower case, remove all non alphabetic characters)
X_col_names <- tolower(as.vector(features$name))
X_col_names <- str_replace_all(X_col_names,"-","")
X_col_names <- str_replace_all(X_col_names,",","to")
X_col_names <- str_replace_all(X_col_names,"\\(","")
X_col_names <- str_replace_all(X_col_names,"\\)","")
X_col_names <- str_replace_all(X_col_names,"bodybody","body")

# load train and test datasets
# (Appropriately label the data sets with descriptive variable names using the features dataset)
# each dataset is composed by 3 files (X_, y_ and subject_ )
X_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names=X_col_names)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names=c("activityid"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names=c("subjectid"))
test <- cbind(y_test, subject_test, X_test)

X_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names=X_col_names)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names=c("activityid"))
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names=c("subjectid"))
train <- cbind(y_train, subject_train, X_train)

# concatenate the two datasets into a dplyr data frame tbl
complete_data <- tbl_df(rbind(test, train))


# extract only the measurements on the mean and standard deviation for each measurement
# we use dplyr select() with the clause matches and a regular expression
# regular expression "^[ft].*(mean|std)[xyz]?$" in human words:
# all variable names
#       beginning with "f" or "t"
#       and ending with "mean" or "std" possibly followed by one of "x", "y" or "z"
mean_std_data <- select(complete_data, activityid, subjectid, matches("^[ft].*(mean|std)[xyz]?$"))

# attach descriptive activity names to name the activities in the data set
# enrich the dataset with activity and features complete information
# read in the activity dataset
activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names=c("activityid","activity"))
# merge, remove the activityid column and overwrite mean_std_data
mean_std_data <- inner_join(activities, mean_std_data, by= "activityid") %>%
                select(-activityid) %>%
                tbl_df

# create a second, independent tidy data set with the average of each variable for each activity and each subject
avg_by_activity_and_subject <- mean_std_data %>%
    gather(measure, value, -(activity:subjectid)) %>%
    group_by(activity, subjectid, measure) %>%
    summarize(avg = mean(value)) %>%
    spread(measure, avg)

# save the summary tidy dataset to disk
final_output_file = "summary_by_activity_and_subject.txt"
write.table(avg_by_activity_and_subject , file=final_output_file, row.names=FALSE)

