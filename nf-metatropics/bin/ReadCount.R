#!/usr/bin/env Rscript

library(readr)
library(dplyr)
library(tidyr)
library(writexl)

count_reads <- function(file_path) {
  con <- gzfile(file_path, "r")
  n <- 0
  while (length(readLines(con, n = 4)) > 0) {
    n <- n + 1
  }
  close(con)
  return(n)
}

# Count raw reads
raw_reads <- list.files("read_count", pattern = "\\.fastq\\.gz$", full.names = TRUE) %>%
  setNames(basename(.) %>% sub("\\.fastq\\.gz$", "", .)) %>%
  lapply(count_reads) %>%
  bind_rows(.id = "sample") %>%
  rename(raw = value)

# Count trimmed reads
trimmed_reads <- list.files("read_count", pattern = "^trimmed_.*\\.fastq\\.gz$", full.names = TRUE) %>%
  setNames(basename(.) %>% sub("^trimmed_", "", .) %>% sub("\\.fastq\\.gz$", "", .)) %>%
  lapply(count_reads) %>%
  bind_rows(.id = "sample") %>%
  rename(trimmed = value)

# Count human-depleted reads
human_depleted_reads <- list.files("read_count/nohuman", pattern = "\\.fastq\\.gz$", full.names = TRUE) %>%
  setNames(basename(.) %>% sub("_.*$", "", .)) %>%
  lapply(count_reads) %>%
  bind_rows(.id = "sample") %>%
  rename(human_depleted = value)

# Count host-depleted reads (if present)
if (dir.exists("read_count/nohost")) {
  host_depleted_reads <- list.files("read_count/nohost", pattern = "\\.fastq\\.gz$", full.names = TRUE) %>%
    setNames(basename(.) %>% sub("_.*$", "", .)) %>%
    lapply(count_reads) %>%
    bind_rows(.id = "sample") %>%
    rename(host_depleted = value)
}

# Count viral reads
viral_reads <- list.files("read_count", pattern = "_viral_reads\\.fastq\\.gz$", full.names = TRUE) %>%
  setNames(basename(.) %>% sub("_viral_reads\\.fastq\\.gz$", "", .)) %>%
  lapply(count_reads) %>%
  bind_rows(.id = "sample") %>%
  rename(viral = value)

# Combine all data
all_data <- list(raw_reads, trimmed_reads, human_depleted_reads, viral_reads) %>%
  {if (exists("host_depleted_reads")) c(., list(host_depleted_reads)) else .} %>%
  reduce(full_join, by = "sample")

# Calculate additional columns
all_data <- all_data %>%
  mutate(
    trimmed_off = raw - trimmed,
    human_reads = trimmed - human_depleted,
    non_viral = if (exists("host_depleted_reads")) host_depleted - viral else human_depleted - viral
  )

if (exists("host_depleted_reads")) {
  all_data <- all_data %>%
    mutate(host_reads = human_depleted - host_depleted)
}

# Reorder columns
column_order <- c("sample", "raw", "trimmed", "trimmed_off", "human_depleted", "human_reads")
if (exists("host_depleted_reads")) {
  column_order <- c(column_order, "host_depleted", "host_reads")
}
column_order <- c(column_order, "viral", "non_viral")
all_data <- all_data %>% select(all_of(column_order))

# Save to Excel
write_xlsx(all_data, "read_counts.xlsx")
