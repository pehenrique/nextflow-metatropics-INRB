#!/usr/bin/env Rscript
library(ggplot2)
library(dplyr)
library(stringr)

# List all .txt files in the current directory
files <- list.files(pattern = "*.coverage.txt")

# Initialize an empty list to store data frames
data_list <- list()

# Loop through each file
for (file in files) {
  # Read the data
  data <- read.table(file, header = FALSE)
  
  # Extract sample name from file name
  sample_name <- sub("(.*)_T1\\.NC_.*", "\\1", file)
  
  # Assign column names
  colnames(data) <- c("reference", "position", "depth")
  
  # Change depth to numeric and calculate log depth
  data$depth <- as.numeric(data$depth)
  data$log_depth <- log10(data$depth)
  data$log_depth[is.infinite(data$log_depth)] <- 0
  
  # Add color column based on depth
  data$color <- ifelse(data$depth > 5, "Above 5", "Below 5")
  
  # Add sample name column
  data$name <- sample_name
  
  # Add to list
  data_list[[sample_name]] <- data
}

# Combine all data frames
combined_data <- do.call(rbind, data_list)

# Bin the data and calculate average depth
combined_data_binned <- combined_data %>%
  mutate(bin_start = floor(position / 50) * 50) %>%
  group_by(name, bin_start) %>%
  summarise(avg_depth = mean(log_depth), .groups = 'drop')

# Calculate log10(5)
log_5 <- log10(5)

# Create the plot
p <- ggplot(combined_data_binned, aes(x = bin_start, y = avg_depth)) +
  geom_line(color = "#057215") +
  geom_segment(data = subset(combined_data_binned, avg_depth < log_5),
               aes(xend = bin_start, y = 0, yend = -0.3),
               color = "darkred", alpha = 1, linewidth = 0.4) +
  geom_hline(yintercept = log_5, linetype = "dashed", color = "black") +
  theme_bw() +
  facet_wrap(~ name, scales = "free_x") +
  labs(title = "Coverage Distribution",
       x = "Position",
       y = "Log10(Depth)")

# Save the plot
ggsave("coverage_distribution.pdf", plot = p, width = 12, height = 8, units = "in")
