library(dplyr)
library(tidyr)

# Subset the dataframe to include the specified variables and sodium_cat
subset_df <- dataframe_for_sup_table1 %>%
    select(sodium_cat, MAP, temperature, heartrate, respiratoryrate, day1fio2, day1pao2, pco2, ph, urine, albumin, bilirubin, wbc)

# Calculate the statistics for each variable within each sodium_cat group
summary_table <- subset_df %>%
    pivot_longer(cols = -sodium_cat, names_to = "variable") %>%
    group_by(sodium_cat, variable) %>%
    summarise(mean = mean(value, na.rm = TRUE),
              sd = sd(value, na.rm = TRUE),
              median = median(value, na.rm = TRUE),
              Q1 = quantile(value, probs = 0.25, na.rm = TRUE),
              Q3 = quantile(value, probs = 0.75, na.rm = TRUE),
              pearson_asymmetry = sum((value - mean(value, na.rm = TRUE))^3) / (length(value) * sd(value, na.rm = TRUE)^3))

# Add rows for the additional variables
additional_variables <- c("temperature", "heartrate", "respiratoryrate", "day1fio2", "day1pao2", "pco2", "ph", "urine", "albumin", "bilirubin", "wbc")
summary_table <- bind_rows(summary_table, data.frame(sodium_cat = unique(subset_df$sodium_cat), variable = additional_variables))

# Transpose the table
summary_table_transposed <- summary_table %>%
    pivot_wider(names_from = sodium_cat, values_from = c(mean, sd, median, Q1, Q3, pearson_asymmetry))

summary_table_transposed