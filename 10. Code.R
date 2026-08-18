# ==============================================================================
# ANNUAL FREQUENCY OF COMPOUND HOT???DRY EVENTS (1994???2023)
# Methodology: Monthly Temp >= P90 AND SPI <= -1.0
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
    # Simulating temperature with an increasing trend over time
    Temp_Trend = (Year - 1994) * 0.04,
    Temp = round(Base_Temp + 15 * sin((Month - 4) * pi / 6) + Temp_Trend + rnorm(n(), mean = 0, sd = 2), 2),
    SPI = round(rnorm(n(), mean = 0, sd = 1), 2)
  ) %>%
  select(-Base_Temp, -Temp_Trend)

# ------------------------------------------------------------------------------
# 3. P90 THRESHOLD & COMPOUND EVENT CALCULATION
# ------------------------------------------------------------------------------

# Calculate P90 threshold for each province and each month
p90_thresholds <- df %>%
  group_by(Province, Month) %>%
  summarise(P90_Temp = quantile(Temp, probs = 0.90, na.rm = TRUE), .groups = "drop")

# Identify Compound Hot-Dry Events
analysis_results <- df %>%
  inner_join(p90_thresholds, by = c("Province", "Month")) %>%
  mutate(
    Is_Hot = Temp >= P90_Temp,
    Is_Dry = SPI <= -1.0,
    Compound_Hot_Dry = Is_Hot & Is_Dry
  )

# ------------------------------------------------------------------------------
# 4. ANNUAL FREQUENCY AGGREGATION
# ------------------------------------------------------------------------------

# A) Annual count per province
annual_by_province <- analysis_results %>%
  group_by(Province, Year) %>%
  summarise(Annual_Events = sum(Compound_Hot_Dry), .groups = "drop")

# B) Annual count aggregated across all 9 provinces
annual_total <- analysis_results %>%
  group_by(Year) %>%
  summarise(Total_Events = sum(Compound_Hot_Dry), .groups = "drop")

# ------------------------------------------------------------------------------
# 5. GRAPH 1: ANNUAL FREQUENCY BY PROVINCE (FACETED BAR CHART)
# ------------------------------------------------------------------------------

p1 <- ggplot(annual_by_province, aes(x = Year, y = Annual_Events, fill = Province)) +
  geom_col(show.legend = FALSE, fill = "#c53030") +
  facet_wrap(~ Province, ncol = 3) +
  scale_x_continuous(breaks = c(1995, 2005, 2015, 2023)) +
  scale_y_continuous(breaks = scales::pretty_breaks()) +
  theme_minimal(base_size = 11) +
  labs(
    title = "Annual Frequency of Compound Hot???Dry Events by Province",
    subtitle = "Number of months per year with Temp ??? P90 (Monthly) AND SPI ??? -1.0",
    x = "Year",
    y = "Event Count (Months / Year)",
    caption = "Data Period: 1994???2023"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#800000"),
    plot.subtitle = element_text(size = 10, color = "#4a5568"),
    strip.background = element_rect(fill = "#edf2f7", color = NA),
    strip.text = element_text(face = "bold", color = "#2d3748"),
    panel.grid.minor = element_blank()
  )

print(p1)
ggsave("Annual_Compound_Events_by_Province.png", plot = p1, width = 11, height = 7, dpi = 300)

# ------------------------------------------------------------------------------
# 6. GRAPH 2: TOTAL ANNUAL FREQUENCY ACROSS ALL 9 PROVINCES (TREND)
# ------------------------------------------------------------------------------

p2 <- ggplot(annual_total, aes(x = Year, y = Total_Events)) +
  geom_col(fill = "#e53e3e", width = 0.7, alpha = 0.85) +
  geom_smooth(method = "loess", se = TRUE, color = "#742a2a", fill = "#feb2b2", size = 1) +
  scale_x_continuous(breaks = seq(1994, 2023, by = 4)) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Total Annual Compound Hot???Dry Events Across 9 Provinces",
    subtitle = "Aggregated monthly compound events per year with LOESS trendline",
    x = "Year",
    y = "Total Event Count (Aggregated Months)",
    caption = "Criteria: Temperature ??? Monthly P90 Threshold AND SPI ??? -1.0"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#742a2a"),
    plot.subtitle = element_text(size = 11, color = "#4a5568"),
    axis.title = element_text(face = "bold"),
    panel.grid.minor = element_blank()
  )

print(p2)
ggsave("Total_Annual_Compound_Events_Trend.png", plot = p2, width = 10, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# 7. GRAPH 3: HEATMAP OF ANNUAL COMPOUND EVENTS
# ------------------------------------------------------------------------------

p3 <- ggplot(annual_by_province, aes(x = Year, y = Province, fill = Annual_Events)) +
  geom_tile(color = "white", linewidth = 0.3) +
  scale_fill_gradient(low = "#fff5f5", high = "#9b2c2c", name = "Event Count") +
  scale_x_continuous(breaks = seq(1994, 2023, by = 2)) +
  theme_minimal(base_size = 11) +
  labs(
    title = "Heatmap of Annual Compound Hot???Dry Events",
    subtitle = "Frequency distribution across 9 provinces (1994???2023)",
    x = "Year",
    y = "Province",
    caption = "Thresholds: Temp ??? P90 (Monthly) & SPI ??? -1.0"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#800000"),
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right"
  )

print(p3)
ggsave("Heatmap_Annual_Compound_Events.png", plot = p3, width = 11, height = 5, dpi = 300)