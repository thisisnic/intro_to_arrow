# This tutorial demonstrates that you can use arrow to query large datasets.

library(arrow)
library(dplyr)
library(purrr)

download_from_s3 <- function(already_downloaded = TRUE){

  if (!already_downloaded) {

    # Set this option as we'll be downloading large files and R has a default
    # timeout of 60 seconds
    options(timeout = 300)

    # The S3 bucket where the data is stored
    bucket <- "https://ursa-labs-taxi-data.s3.us-east-2.amazonaws.com"

    # Download the data from S3
    # Loops through the data files, downloading 1 file at a time
    for (year in 2009:2019) {
      if (year == 2019) {
        # We only have through June 2019 there
        months <- 1:6
      } else {
        months <- 1:12
      }
      for (month in sprintf("%02d", months)) {
        file_path <- file.path("nyc-taxi", year, month)
        if (!file.exists(file_path)) {
          dir.create(file_path, recursive = TRUE)
          try(download.file(
            paste(bucket, year, month, "data.parquet", sep = "/"),
            file.path("nyc-taxi", year, month, "data.parquet"),
            mode = "wb"
          ), silent = TRUE)
        }
      }
    }
  }
}

# Change `already_downloaded` to `FALSE` to download the data files
download_from_s3(already_downloaded = TRUE)

# For the live version on the tutorial, here's one I made earlier!
data_path <- "/data/nyc-taxi/"

files <- list.files(data_path, recursive = TRUE, full.names =  TRUE)
files

# In this case, we supply the partitioning to `open_dataset()`
nyc_taxi <- open_dataset(data_path, partitioning = c("year", "month"))

nyc_taxi

# Calculate mean across last few years' data
nyc_taxi %>%
  summarise(mean_fare = mean(fare_amount)) %>%
  collect()

# So how big exactly *is* this data?

total_bytes <- sum(map_dbl(files, file.size))
total_gb <- total_bytes/1e9

# 38.89Gb! Larger than memory on a lot of machines
total_gb

# Take a look at the data and we can see it's stored in partitioned files
files

# This is an Arrow object - a FileSystemDataset and it contains 123 files.
# It has not been read into memory
nyc_taxi

# This dataset has 1.5 billion rows
nrow(nyc_taxi)

# Since v 6.0.0 we can use group_by and summarise together
# What is the mean fare by month since 2016? (add new groupby/summarise example here)
nyc_taxi %>%
  filter(month > 2016) %>%
  group_by(year, month) %>%
  summarise(mean_fare = mean(fare_amount)) %>%
  collect()

