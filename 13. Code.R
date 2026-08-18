# ==============================================================================
# 4. MAXIMUM CONSECUTIVE DURATION OF COMPOUND HOT???DRY EVENTS (1994???2023)
# Criteria: Temperature >= Monthly P90 Threshold AND SPI <= -1.0
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
# 4. CALCULATE MAXIMUM CONSECUTIVE DURATION & DATES PER PROVINCE
# ------------------------------------------------------------------------------

max_duration_summary <- analysis_results %>%
  group_by(Province) %>%
  group_modify(~ {
    r <- rle(.x$Compound_Hot_Dry)
    
    # Identify run lengths for TRUE values
    true_indices <- which(r$values == TRUE)
    
    if (length(true_indices) > 0) {
      max_len <- max(r$lengths[true_indices])
      max_idx <- true_indices[which.max(r$lengths[true_indices])]
      
      # Calculate start and end indices in the original group
      end_pos <- sum(r$lengths[1:max_idx])
      start_pos <- end_pos - max_len + 1
      
      start_date <- .x$Date[start_pos]
      end_date <- .x$Date[end_pos]
      period_str <- paste0(format(start_date, "%b %Y"), " - ", format(end_date, "%b %Y"))
    } else {
      max_len <- 0
      period_str <- "None"
    }
    
    tibble(
      Max_Consecutive_Months = max_len,
      Peak_Period = period_str
    )
  }) %>%
  ungroup() %>%
  arrange(desc(Max_Consecutive_Months))

print("=== 4. MAXIMUM CONSECUTIVE DURATION SUMMARY ===")
print(max_duration_summary)

# ------------------------------------------------------------------------------
# 5. ENGLISH GGPLOT2 VISUALIZATION
# ------------------------------------------------------------------------------

p <- ggplot(max_duration_summary, aes(x = reorder(Province, Max_Consecutive_Months), 
                                      y = Max_Consecutive_Months, 
                                      fill = Max_Consecutive_Months)) +
  geom_col(show.legend = FALSE, width = 0.65) +
  geom_text(aes(label = paste0(Max_Consecutive_Months, ifelse(Max_Consecutive_Months == 1, " Month", " Months"))), 
            hjust = -0.15, size = 3.8, fontface = "bold", color = "#742a2a") +
  scale_fill_gradient(low = "#fc8d59", high = "#7f0000") +
  coord_flip() +
  scale_y_continuous(limits = c(0, max(max_duration_summary$Max_Consecutive_Months) + 2), 
                     breaks = scales::pretty_breaks()) +
  theme_minimal(base_size = 12) +
  labs(
    title = "Maximum Consecutive Duration of Compound Hot???Dry Events",
    subtitle = "Longest uninterrupted spell (months) with Temp ??? P90 (Monthly) AND SPI ??? -1.0",
    x = "Province",
    y = "Maximum Duration (Consecutive Months)",
    caption = "Study Period: 1994???2023 (30 Years / 360 Months)"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14, color = "#7f0000"),
    plot.subtitle = element_text(size = 10.5, color = "#4a5568"),
    axis.title = element_text(face = "bold"),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank()
  )

print(p)

# Save high-resolution graphic for publication
ggsave("Max_Consecutive_Compound_Duration_9_Provinces.png", plot = p, width = 9.5, height = 5.5, dpi = 300)