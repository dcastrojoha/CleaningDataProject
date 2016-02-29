## DOWNLOADING THE DATA AND UNZIPPING
  if(!file.exists("./project")){dir.create("./project")}
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, "./project/raw_data.zip")

  unzip('./project/raw_data.zip', exdir = './project/unzip_data', junkpaths = TRUE)

## READING THE DATA INTO R AND MERGING
  ## TEST DATA
  test <- read.table('./project/unzip_data/X_test.txt', header = FALSE, sep = "")
  test_labels <- read.table('./project/unzip_data/y_test.txt', header = FALSE, sep = "", col.names = 'label')
  test_subjects <- read.table('./project/unzip_data/subject_test.txt', header = FALSE, sep = "", col.names = 'subject')
  
  ## TRAIN DATA
  train <- read.table('./project/unzip_data/X_train.txt', header = FALSE, sep = "")
  train_labels <- read.table('./project/unzip_data/y_train.txt', header = FALSE, sep = "", col.names = 'label')
  train_subjects <- read.table('./project/unzip_data/subject_train.txt', header = FALSE, sep = "", col.names = 'subject')

  ## GENERAL DATA
  features <- read.table('./project/unzip_data/features.txt', header = FALSE, sep = "")  
  act_labels <- read.table('./project/unzip_data/activity_labels.txt', header = FALSE, sep = "")

## ROW SUBJECTS AND LABELS, AND COLUMN NAMES  
  colnames(test) <- features[,2]
  colnames(train) <- features[,2]
  
  test <- cbind(test_subjects, test)
  test <- cbind(test_labels, test)
  train <- cbind(train_subjects, train)
  train <- cbind(train_labels, train)
  
## MERGE TRAINING DATA AND TEST SETS TO CREATE ONE DATA SET
  merged <- rbind(test, train)
  
## SELECT ONLY  MEASUREMENTS ON THE MEAN AND STANDARD DEVIATION 
  a <- grep("[Ss]td\\()", names(merged))
  b <- grep("[Mm]ean\\()", names(merged))
  c <- sort(c(1,2,a,b))     # will keep the row labels for subject and activity
  merged_means_std <- merged[,c]
  
## USE DESCRIPTIVE ACTIVITY NAMES TO NAME THE ACTIVITIES IN THE DATASET
  merged_means_std[merged_means_std$label == 1, "label"] = "Walking"  
  merged_means_std[merged_means_std$label == 2, "label"] = "Walking Upstairs" 
  merged_means_std[merged_means_std$label == 3, "label"] = "Walking Downstairs" 
  merged_means_std[merged_means_std$label == 4, "label"] = "Sitting" 
  merged_means_std[merged_means_std$label == 5, "label"] = "Standing" 
  merged_means_std[merged_means_std$label == 6, "label"] = "Laying"
  
##APPROPRIATELY LABEL DATASET WITH DESCRIPTIVE VARIABLE NAMES
  names(merged_means_std) <- gsub("tBodyAcc-","Body Accelerometer(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tGravityAcc-","Gravity Accelerometer(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyAccJerk-","Body Accelerometer Jerk(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyGyro-","Body Gyro(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyGyroJerk-","Body Gyro Jerk(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyAccMag-","Body Accelerometer Magnitude(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tGravityAccMag-","Gravity Accelerometer Magnitude(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyAccJerkMag-","Body Accelerometer Jerk Magnitude(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyGyroMag-","Body Gyro Magnitude(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("tBodyGyroJerkMag-","Body Gyro Jerk Magnitude(time) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyAcc-","Body Accelerometer(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyAccJerk-","Body Accelerometer Jerk(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyGyro-","Body Gyro(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyAccMag-","Body Accelerometer Magnitude(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyBodyAccJerkMag-","Body Accelerometer Jerk Magnitude(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyBodyGyroMag-","Body Gyro Magnitude(frequency) ", names(merged_means_std))
  names(merged_means_std) <- gsub("fBodyBodyGyroJerkMag-","Body Gyro Jerk Magnitude(frequency) ", names(merged_means_std))

  names(merged_means_std) <- gsub("mean\\()","mean ", names(merged_means_std))
  names(merged_means_std) <- gsub("std\\()","std", names(merged_means_std))
  names(merged_means_std) <- gsub("mean \\()","mean ", names(merged_means_std))
  names(merged_means_std) <- gsub("std \\()","std", names(merged_means_std))

## CREATE SECOND TIDY DATA SET WITH THE AVERAGE OF EACH VARIABLE FOR EACH ACTIVITY AND EACH SUBJECT
  library(dplyr); library(plyr); library(reshape2)
  merged_means_std_grouped <- group_by(merged_means_std, subject, label)
  summary <- summarise_each(merged_means_std_grouped, funs(mean))
  write.table(summary, file = './project/tidydata.txt', row.names = FALSE)
