tidy-data-wearables
===================

Course project for "Getting and Cleaning Data" https://class.coursera.org/getdata-007/

All the work is performed in *run_analysis.R*.  

The original data is downloaded (if not already present) and unzipped in the work directory.  
Unzipping creates the "UCI HAR Dataset" directory containg all the data files. When referring to a
data file in the following we will always assume it is in this directory.  

The *features.txt* file is read to obtain all the feature names. These are transformed to lower case,
have all the non-alphanumeric characters removed (a "," is substituted with the word "to") and have 
eventual errors removed ("bodybody" is substituted with "body").  
Example: "tGravityAcc-mean()-Y" becomes "tgravityaccmeany".  
Transformation is accomplished using the *stringr* function *str_replace_all*.  
The transformed names will be used as column names when reading the features measurements files.  

The test dataset is read from the *test/X_test.txt* (feature measurements), *test/y_test.txt* (activities)
and *test/subject_test.txt* (subjects) files. Observations in the 3 files are ceidentifiedlinked by their row number:
data from the same observation would be found at the same row in each of the 3 files.

The train dataset is read applying the same logic (files would be found under the *train* subdirectory).  

The test and train dataset are concatenated and transformed into a *dplyr* data frame tbl.  

From this complete dataset we select only the columns pertaining to the mean or standard deviation from a
feature measurement.  
These are selected using a regular expression (further explained in the *run_analysis.R* commented code).  
Variables where the words "mean" or "std" do not appear at the end of the name have been excluded as in
this case the variable would not be a mean or a standard deviation of a feature measurement but instead
the feature itself is a mean or standard variation. Also mean frequencies have been excluded.
e.g. "tgravityaccmeanx" is included but "fbodyaccmeanfreqz" has been excluded.  
Similarly angle measurements have been excluded as they have been estimated using a signal processing technique
inconsistent with the technique used for the time and frequency component measurements. (Also it is
unclear from the *features_info.txt* documentation whether the angle measurements are
themselves means or not).

The resulting dataset is enriched with the activity labels from *activity_labels.txt* using "activityid"
as the key in an ineer join operation. The activityid column is then removed as no longer useful.  

A second independent dataset is created averaging each measurement by subject and activity.  
This is accomplished using the *gather* and *spread* functions from the *tidyr* package and the
*group_by* and *summarize* functions from the *dplyr* package.  
First the dataset is made into a "skinny" tall table containing the activity, subjectid, measurement name and value for each measurement.  
Then the average value is taken across rows with the same activity, subjectid and measurement name.  
Finallly the dataset is cast back into a "fat" table by turning each measurement name back into a column whose value is given by the average just taken.  

The dataset thus obtained is saved to disk.  
