#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(tidyr)

# Set working directory to the 'read_count' folder
setwd("read_count")

# Print current working directory and list files
cat("Current working directory:", getwd(), "\n")
cat("Files in current directory:\n")
system("ls -R")

count_reads <- function(file_path) {
  tryCatch({
    con <- gzfile(file_path, "r")
    n <- 0
    while (length(readLines(con, n = 4)) > 0) {
      n <- n + 1
    }
    close(con)
    return(n)
  }, error = function(e) {
    warning(paste("Error reading file:", file_path, "-", e$message))
    return(0)
  })
}

extract_sample_name <- function(filename) {
  if (grepl("_viral", filename)) {
    sub("_viral.*", "", filename)
  } else {
    sub("_T1.*", "", filename)
  }
}

count_and_create_df <- function(pattern, dir = ".") {
  cat("Searching for files matching pattern:", pattern, "in directory:", dir, "\n")
  files <- list.files(dir, pattern = pattern, full.names = TRUE)
  cat("Found", length(files), "files:\n")
  cat(paste(files, collapse = "\n"), "\n")
  if (length(files) == 0) {
    warning(paste("No files found matching pattern:", pattern, "in directory:", dir))
    return(data.frame(sample = character(), count = numeric()))
  }
  names <- basename(files)
  sample_names <- sapply(names, extract_sample_name)
  
  counts <- sapply(files, count_reads)
  df <- data.frame(sample = sample_names, count = counts)
  rownames(df) <- df$sample
  return(df)
}

raw_reads <- count_and_create_df("^.*_T1\\.fastq\\.gz$")
if (nrow(raw_reads) > 0) raw_reads <- raw_reads %>% rename(raw = count)

trimmed_reads <- count_and_create_df("\\.fastp\\.fastq\\.gz$")
if (nrow(trimmed_reads) > 0) trimmed_reads <- trimmed_reads %>% rename(trimmed = count)

human_depleted_reads <- count_and_create_df("\\.fastq\\.gz$", dir = "nohuman")
if (nrow(human_depleted_reads) > 0) human_depleted_reads <- human_depleted_reads %>% rename(human_depleted = count)

host_depleted_reads <- if (dir.exists("nohost")) {
  df <- count_and_create_df("\\.fastq\\.gz$", dir = "nohost")
  if (nrow(df) > 0) df %>% rename(host_depleted = count) else df
} else {
  data.frame(sample = character(), host_depleted = numeric())
}

viral_reads <- count_and_create_df("_viral_reads\\.fastq\\.gz$")
if (nrow(viral_reads) > 0) viral_reads <- viral_reads %>% rename(viral = count)

all_data <- Reduce(function(x, y) full_join(x, y, by = "sample"),
                   list(raw_reads, trimmed_reads, human_depleted_reads, host_depleted_reads, viral_reads))

if (nrow(all_data) == 0) {
  cat("No data found. Check if files are present in the correct directories.\n")
} else {
  all_data <- all_data %>%
    mutate(across(everything(), ~replace_na(., 0))) %>%
    mutate(
      trimmed_reads = raw - trimmed,
      human_reads = trimmed - human_depleted,
      host_reads = human_depleted - host_depleted,
      non_viral = host_depleted - viral
    )

  all_data <- all_data %>%
    select(sample, raw, trimmed_reads, human_reads, host_reads, viral, non_viral)

  # Calculate percentages
  all_data <- all_data %>%
    mutate(
      trimmed_reads_pct = round(trimmed_reads / raw * 100, 2),
      human_reads_pct = round(human_reads / raw * 100, 2),
      host_reads_pct = round(host_reads / raw * 100, 2),
      viral_pct = round(viral / raw * 100, 2),
      non_viral_pct = round(non_viral / raw * 100, 2)
    )

  # Reorder columns to group absolute numbers with their percentages
  all_data <- all_data %>%
    select(sample, raw, 
           trimmed_reads, trimmed_reads_pct, 
           human_reads, human_reads_pct, 
           host_reads, host_reads_pct, 
           viral, viral_pct, 
           non_viral, non_viral_pct)

  rownames(all_data) <- all_data$sample
  all_data <- all_data %>% select(-sample)

  # Write the CSV file to the parent directory
  write.csv(all_data, "read_counts.csv")

  cat("Data processing completed. Results written to read_counts.csv\n")
  print(all_data)
}

cat("R script completed.\n")
