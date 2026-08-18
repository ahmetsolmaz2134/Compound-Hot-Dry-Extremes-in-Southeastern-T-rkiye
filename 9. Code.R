# ==============================================================================
# COMPOUND HOT???DRY EVENT ANALYSIS
# Methodology: Same Month Temperature >= P90 AND SPI <= -1.0
# ==============================================================================

# 1. Load required packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")
if (!require("scales")) install.packages("scales")

library(tidyverse)
library(lubridate)
library(scales)

# ------------------------------------------------------------------------------
# 2. SAMPLE DATA GENERATION (Skip this section if using your own dataframe)
# ------------------------------------------------------------------------------
set.seed(42)

provinces <- c("Diyarbakir", "Sanliurfa", "Gaziantep", "Mardin", 
               "Batman", "Siirt", "Adana", "Izmir", "Ankara")

dates <- seq.Date(from = as.Date("1994-01-01"), to = as.Date("2023-12-01"), by = "month")

df <- expand.grid(Province = provinces, Date = dates) %>%
  mutate(
    Year = year(Date),
    Month = month(Date),
    # Simulating seasonal mean temperature
    Base_Temp = ifelse(Province %in% c("Izmir", "Ankara"), 14, 18),
    Temp = Base_Temp + 15 * sin((Month - 4) * pi / 6) + rnorm(n(), mean = 0, sd = 2),
    Temp = round(Temp, 2),
    # Standard normal SPI values
    SPI = round(rnorm(n(), mean = 0, sd = 1), 2)
  ) %>%
  select(-Base_Temp)

# ------------------------------------------------------------------------------
# 3. P90 TEMPERATURE THRESHOLD & COMPOUND EVENT IDENTIFICATION
# ------------------------------------------------------------------------------

# Calculate monthly P90 temperature threshold for each province and month
p90_thresholds <- df %>%
  group_by(Province, Month) %>%
  summarise(
    P90_Temp = quantile(Temp, probs = 0.90, na.rm = TRUE),
    .groups = "drop"
  )

# Merge P90 thresholds and identify Compound Hot-Dry Events
analysis_results <- df %>%
  inner_join(p90_thresholds, by = c("Province", "Month")) %>%
  mutate(
    Is_Hot = Temp >= P90_Temp,
    Is_Dry = SPI <= -1.0,
    Compound_Hot_Dry = Is_Hot & Is_Dry
  )

# ------------------------------------------------------------------------------
# 4. SUMMARY TABLE CREATION
# ------------------------------------------------------------------------------
summary_table <- analysis_results %>%
  group_by(Province) %>%
  summarise(
    Total_Months = n(),
    Mean_Temp = round(mean(Temp), 2),
    Max_Temp = round(max(Temp), 2),
    Min_SPI = round(min(SPI), 2),
    Compound_Event_Count = sum(Compound_Hot_Dry),
    Frequency_Pct = round((Compound_Event_Count / Total_Months) * 100, 2)
  ) %>%
  arrange(desc(Compound_Event_Count))

print("=== COMPOUND HOT-DRY SUMMARY TABLE ===")
print(summary_table)

# ------------------------------------------------------------------------------
# 5. ENGLISH GGPLOT2 VISUALIZATION
# ------------------------------------------------------------------------------

p <- ggplot(summary_table, aes(x = reorder(Province, Compound_Event_Count), 
                               y = Compound_Event_Count, 
                               fill = Compound_Event_Count)) +
  geom_col(show.legend = FALSE, width = 0.7) +
  geom_text(aes(label = paste0(Compound_Event_Count, " Months (", Frequency_Pct, "%)")), 
            hjust = -0.15, size = 3.5, fontface = "bold") +
  scale_fill_gradient(low = "#f87171", high = "#8b0000") +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(summary_table$Compound_Event_Count) + 3)) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Compound Hot???Dry Events Across 9 Provinces",
    subtitle = "Criteria: Temperature ??? Monthly P90 Threshold AND SPI ??? -1.0",
    x = "Province",
    y = "Number of Compound Hot???Dry Months",
    caption = "Period: 1994???2023 (30 Years / 360 Months)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#8b0000"),
    plot.subtitle = element_text(size = 11, color = "#333333"),
    axis.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank()
  )

print(p)

# Save plot in high resolution
ggsave("Compound_Hot_Dry_Events_9_Provinces.png", plot = p, width = 10, height = 6, dpi = 300)