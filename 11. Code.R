# ==============================================================================
# DURATION OF COMPOUND HOT???DRY EVENTS (1994???2023)
# Methodology: Consecutive Months with Temp >= P90 AND SPI <= -1.0
# ==============================================================================

# 1. Load required packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")

library(tidyverse)
library(lubridate)

# ------------------------------------------------------------------------------
# 2. SAMPLE DATA GENERATION (Skip if using your actual dataframe)
# ------------------------------------------------------------------------------
set.seed(42)

provinces <- c("Diyarbakir", "Sanliurfa", "Gaziantep", "Mardin", 
               "Batman", "Siirt", "Adana", "Izmir", "Ankara")

dates <- seq.Date(from = as.Date("1994-01-01"), to = as.Date("2023-12-01"), by = "month")

df <- expand.grid(Province = provinces, Date = dates) %>%
  mutate(
    Year = year(Date),
    Month = month(Date),
    Base_Temp = ifelse(Province %in% c("Izmir", "Ankara"), 14, 18),
    Temp_Trend = (Year - 1994) * 0.04,
    Temp = round(Base_Temp + 15 * sin((Month - 4) * pi / 6) + Temp_Trend + rnorm(n(), mean = 0, sd = 2), 2),
    SPI = round(rnorm(n(), mean = 0, sd = 1), 2)
  ) %>%
  select(-Base_Temp, -Temp_Trend)

# ------------------------------------------------------------------------------
# 3. P90 THRESHOLD & COMPOUND EVENT IDENTIFICATION
# ------------------------------------------------------------------------------

p90_thresholds <- df %>%
  group_by(Province, Month) %>%
  summarise(P90_Temp = quantile(Temp, probs = 0.90, na.rm = TRUE), .groups = "drop")

analysis_results <- df %>%
  inner_join(p90_thresholds, by = c("Province", "Month")) %>%
  arrange(Province, Date) %>%
  mutate(
    Is_Hot = Temp >= P90_Temp,
    Is_Dry = SPI <= -1.0,
    Compound_Hot_Dry = Is_Hot & Is_Dry
  )

# ------------------------------------------------------------------------------
# 4. CALCULATE EVENT DURATIONS (CONSECUTIVE MONTHS)
# ------------------------------------------------------------------------------

# Function to calculate run lengths of TRUE values for each province
calculate_durations <- function(data) {
  data %>%
    group_by(Province) %>%
    group_modify(~ {
      r <- rle(.x$Compound_Hot_Dry)
      tibble(
        Event_ID = seq_along(r$lengths[r$values]),
        Duration_Months = r$lengths[r$values]
      )
    }) %>%
    ungroup()
}

event_durations <- calculate_durations(analysis_results)

# Duration Summary Statistics by Province
duration_summary <- event_durations %>%
  group_by(Province) %>%
  summarise(
    Total_Events = n(),
    Mean_Duration = round(mean(Duration_Months), 2),
    Max_Duration = max(Duration_Months),
    Single_Month_Events = sum(Duration_Months == 1),
    Multi_Month_Events = sum(Duration_Months > 1),
    .groups = "drop"
  )

print("=== COMPOUND EVENT DURATION SUMMARY ===")
print(duration_summary)

# ------------------------------------------------------------------------------
# 5. GRAPH 1: DURATION DISTRIBUTION BY PROVINCE (STACKED / GROUPED BAR)
# ------------------------------------------------------------------------------

# Categorize duration lengths (1 Month, 2 Months, 3+ Months)
event_durations_cat <- event_durations %>%
  mutate(
    Duration_Class = case_when(
      Duration_Months == 1 ~ "1 Month",
      Duration_Months == 2 ~ "2 Months",
      Duration_Months >= 3 ~ "3+ Months"
    ),
    Duration_Class = factor(Duration_Class, levels = c("1 Month", "2 Months", "3+ Months"))
  )

p1 <- ggplot(event_durations_cat, aes(x = Province, fill = Duration_Class)) +
  geom_bar(position = "stack", width = 0.7) +
  scale_fill_manual(
    values = c("1 Month" = "#fbd38d", "2 Months" = "#ed8936", "3+ Months" = "#9b2c2c"),
    name = "Event Duration"
  ) +
  coord_flip() +
  theme_minimal(base_size = 12) +
  labs(
    title = "Duration Distribution of Compound Hot???Dry Events",
    subtitle = "Number of distinct compound events categorized by consecutive duration",
    x = "Province",
    y = "Number of Events",
    caption = "Period: 1994???2023 | Criteria: Temp ??? P90 AND SPI ??? -1.0"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#742a2a"),
    plot.subtitle = element_text(size = 11, color = "#4a5568"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.major.y = element_blank()
  )

print(p1)
ggsave("Compound_Event_Duration_Distribution.png", plot = p1, width = 10, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# 6. GRAPH 2: AVERAGE AND MAXIMUM EVENT DURATION BY PROVINCE
# ------------------------------------------------------------------------------

# Reshape duration summary for plotting mean vs max
duration_long <- duration_summary %>%
  pivot_longer(cols = c(Mean_Duration, Max_Duration), 
               names_to = "Metric", 
               values_to = "Months") %>%
  mutate(
    Metric = ifelse(Metric == "Mean_Duration", "Mean Duration", "Maximum Duration")
  )

p2 <- ggplot(duration_summary, aes(x = reorder(Province, Mean_Duration))) +
  geom_segment(aes(xend = Province, y = 0, yend = Max_Duration), color = "#cbd5e0", size = 1.2) +
  geom_point(aes(y = Max_Duration, color = "Maximum Duration"), size = 4) +
  geom_point(aes(y = Mean_Duration, color = "Mean Duration"), size = 4) +
  geom_text(aes(y = Max_Duration, label = paste0(Max_Duration, "m")), vjust = -0.8, size = 3.2, fontface = "bold") +
  geom_text(aes(y = Mean_Duration, label = paste0(Mean_Duration, "m")), vjust = 1.8, size = 3.2, color = "#2b6cb0") +
  scale_color_manual(
    values = c("Mean Duration" = "#3182ce", "Maximum Duration" = "#9b2c2c"),
    name = "Metric"
  ) +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(duration_summary$Max_Duration) + 1.5), breaks = scales::pretty_breaks()) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Mean and Maximum Duration of Compound Hot???Dry Events",
    subtitle = "Persistence of consecutive compound hot-dry months per province",
    x = "Province",
    y = "Duration (Months)",
    caption = "m = Months | Period: 1994???2023"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#742a2a"),
    plot.subtitle = element_text(size = 11, color = "#4a5568"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.major.y = element_blank()
  )

print(p2)
ggsave("Mean_Max_Compound_Event_Duration.png", plot = p2, width = 10, height = 6, dpi = 300)