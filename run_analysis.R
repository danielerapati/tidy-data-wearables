# download the original zipped source file if not present
zipped_file <- "FUCI_HAR_Dataset.zip"
if(!file.exists(zipped_file)) {
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                  destfile=zipped_file,
                  method="curl")
}

# unzip the source file
unzip(zipped_file)

# load first dataset


# tidy it up


# load second dataset


# tidy it up


# merge the two datasets


# save the merged tidy dataset to disk


