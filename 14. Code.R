# ==============================================================================
# 5. COMPOUND EVENT SEVERITY & INTENSITY ANALYSIS (1994???2023)
# Methodology: Standardized Temp Anomaly + Drought Severity (-SPI)
# ==============================================================================

# 1. Load required packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("lubridate")) install.packages("lubridate")

library(tidyverse)
library(lubridate)

# ------------------------------------------------------------------------------
# 2. SAMPLE DATA GENERATION (Skip if using your actual dataset)
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
# 3. STANDARDIZED ANOMALY & COMPOUND SEVERITY CALCULATION
# ------------------------------------------------------------------------------

# Monthly Mean & Standard Deviation for Standardized Temperature Anomaly
monthly_stats <- df %>%
  group_by(Province, Month) %>%
  summarise(
    Mean_Temp = mean(Temp, na.rm = TRUE),
    Std_Temp = sd(Temp, na.rm = TRUE),
    P90_Temp = quantile(Temp, probs = 0.90, na.rm = TRUE),
    .groups = "drop"
  )

analysis_results <- df %>%
  inner_join(monthly_stats, by = c("Province", "Month")) %>%
  mutate(
    # Standardized Temperature Anomaly
    Temp_Anomaly_Std = (Temp - Mean_Temp) / Std_Temp,
    # Compound Conditions
    Is_Hot = Temp >= P90_Temp,
    Is_Dry = SPI <= -1.0,
    Compound_Hot_Dry = Is_Hot & Is_Dry,
    # Severity Metrics (Calculated for Compound Events)
    Compound_Severity = Temp_Anomaly_Std + (-1 * SPI),
    Euclidean_Intensity = sqrt(Temp_Anomaly_Std^2 + SPI^2)
  )

# Filter compound events only
compound_events <- analysis_results %>%
  filter(Compound_Hot_Dry == TRUE)

# ------------------------------------------------------------------------------
# 4. SEVERITY SUMMARY BY PROVINCE
# ------------------------------------------------------------------------------

severity_summary <- compound_events %>%
  group_by(Province) %>%
  summarise(
    Event_Count = n(),
    Mean_Severity = round(mean(Compound_Severity), 2),
    Max_Severity = round(max(Compound_Severity), 2),
    Mean_Intensity = round(mean(Euclidean_Intensity), 2),
    Max_Intensity = round(max(Euclidean_Intensity), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(Max_Severity))

print("=== 5. COMPOUND EVENT SEVERITY SUMMARY ===")
print(severity_summary)

# ------------------------------------------------------------------------------
# 5. GRAPH 1: MEAN & MAXIMUM SEVERITY BY PROVINCE
# ------------------------------------------------------------------------------

p1 <- ggplot(severity_summary, aes(x = reorder(Province, Max_Severity))) +
  geom_segment(aes(xend = Province, y = 0, yend = Max_Severity), color = "#e2e8f0", size = 1.2) +
  geom_point(aes(y = Max_Severity, color = "Maximum Severity"), size = 4.5) +
  geom_point(aes(y = Mean_Severity, color = "Mean Severity"), size = 4.5) +
  geom_text(aes(y = Max_Severity, label = Max_Severity), vjust = -0.8, size = 3.5, fontface = "bold", color = "#7f0000") +
  geom_text(aes(y = Mean_Severity, label = Mean_Severity), vjust = 1.8, size = 3.5, color = "#2b6cb0") +
  scale_color_manual(
    values = c("Mean Severity" = "#3182ce", "Maximum Severity" = "#7f0000"),
    name = "Severity Metric"
  ) +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(severity_summary$Max_Severity) + 1)) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Compound Hot???Dry Event Severity Across 9 Provinces",
    subtitle = "Combined index of standardized temperature anomaly and drought magnitude (-SPI)",
    x = "Province",
    y = "Compound Severity Index (CSI)",
    caption = "Study Period: 1994???2023 | Criteria: Temp ??? P90 & SPI ??? -1.0"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#7f0000"),
    plot.subtitle = element_text(size = 10.5, color = "#4a5568"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.major.y = element_blank()
  )

print(p1)
ggsave("Compound_Event_Severity_9_Provinces.png", plot = p1, width = 10, height = 6, dpi = 300)

# ------------------------------------------------------------------------------
# 6. GRAPH 2: BIVARIATE SCATTER PLOT (TEMP ANOMALY VS. SPI SEVERITY)
# ------------------------------------------------------------------------------

p2 <- ggplot(compound_events, aes(x = SPI, y = Temp_Anomaly_Std, color = Province)) +
  geom_point(size = 3, alpha = 0.8) +
  geom_vline(xintercept = -1.0, linetype = "dashed", color = "#e53e3e") +
  theme_minimal(base_size = 12) +
  labs(
    title = "Bivariate Distribution of Compound Hot???Dry Events",
    subtitle = "Standardized Temperature Anomaly vs. SPI (Drought Severity)",
    x = "Standardized Precipitation Index (SPI)",
    y = "Standardized Temperature Anomaly (??)",
    caption = "Dashed line indicates drought threshold (SPI ??? -1.0)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#7f0000"),
    plot.subtitle = element_text(size = 10.5, color = "#4a5568"),
    axis.title = element_text(face = "bold")
  )

print(p2)
ggsave("Bivariate_Compound_Event_Scatter.png", plot = p2, width = 9.5, height = 6, dpi = 300)