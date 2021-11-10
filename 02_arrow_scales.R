# This tutorial demonstrates that you can use arrow to query large datasets.

library(arrow)
library(dplyr)
library(purrr)

# Set this option as we'll be downloading large files and R has a default
# timeout of 60 seconds
options(timeout = max(300, getOption("timeout")))

# The S3 bucket where the data is stored
bucket <- "https://ursa-labs-taxi-data.s3.us-east-2.amazonaws.com"

# Download the data from S3
# Loops through the data files, downloading 1 at a time
# for (year in 2009:2019) {
#   if (year == 2019) {
#     # We only have through June 2019 there
#     months <- 1:6
#   } else {
#     months <- 1:12
#   }
#   for (month in sprintf("%02d", months)) {
#     file_path <- file.path("nyc-taxi", year, month)
#     if (!file.exists(file_path)) {
#       dir.create(file_path, recursive = TRUE)
#       try(download.file(
#         paste(bucket, year, month, "data.parquet", sep = "/"),
#         file.path("nyc-taxi", year, month, "data.parquet"),
#         mode = "wb"
#       ), silent = TRUE)
#     }
#
#   }
# }

# For the live version on the tutorial, here's one I made earlier!
data_path <- "../data/nyc-taxi/"

#
files <- list.files(data_path, recursive = TRUE, full.names =  TRUE)

total_bytes <- sum(map_dbl(files, file.size))
total_gb <- total_bytes/1e9

# 38.89Gb! Larger than memory on a lot of machines
total_gb

# Take a look at the data and we can see it's stored in partitioned files
files

# In this case, we supply the partitioning to `open_dataset()`
nyc_taxi <- open_dataset(data_path, partitioning = c("year", "month"))

# This is an Arrow object - a FileSystemDataset and it contains 123 files.
# It has not been read into memory
nyc_taxi

# This dataset has 1.5 billion rows
nrow(nyc_taxi)

# What is the mean fare across the dataset?
# This will take a moment to resolve but keep in mind the amount of data we're
#  querying here
nyc_taxi %>%
  summarise(mean(fare_amount)) %>%
  collect()

# Since v 6.0.0 we can use group_by and summarise together
# What is the mean fare by month since 2016?
monthly_fares <- nyc_taxi %>%
  group_by(year, month) %>%
  filter(year > 2016) %>%
  summarise(mean_fare = mean(fare_amount)) %>%
  collect()

# Look at the results of this
View(monthly_fares)


