# ==============================================================================
# MASTER ANALYSIS SCRIPT FOR COMPOUND HOT-DRY EVENTS (9 PROVINCES)
# Includes:
#   - Section 4: Maximum Consecutive Duration Analysis
#   - Section 5: Compound Event Severity Index (CSI) & Intensity Analysis
#   - Section 16: Mann-Kendall Trend Test & Sen's Slope Estimator
# Output: Publication-Ready Plots (PNG) & Multi-Sheet Excel Workbook (.xlsx)
# ==============================================================================

# 1. INSTALL AND LOAD REQUIRED PACKAGES
required_packages <- c("tidyverse", "trend", "openxlsx", "lubridate", "scales")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) install.packages(new_packages)

library(tidyverse)
library(trend)
library(openxlsx)
library(lubridate)
library(scales)

# ------------------------------------------------------------------------------
# 2. SAMPLE DATA GENERATION (Skip/Replace with your actual dataset)
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
# 3. BASELINE CALCULATION & COMPOUND EVENT IDENTIFICATION
# ------------------------------------------------------------------------------
monthly_stats <- df %>%
  group_by(Province, Month) %>%
  summarise(
    Mean_Temp = mean(Temp, na.rm = TRUE),
    Std_Temp = sd(Temp, na.rm = TRUE),
    P90_Temp = quantile(Temp, probs = 0.90, na.rm = TRUE),
    .groups = "drop"
  )

analysis_df <- df %>%
  inner_join(monthly_stats, by = c("Province", "Month")) %>%
  arrange(Province, Date) %>%
  mutate(
    Temp_Anomaly_Std = (Temp - Mean_Temp) / Std_Temp,
    Is_Hot = Temp >= P90_Temp,
    Is_Dry = SPI <= -1.0,
    Compound_Hot_Dry = Is_Hot & Is_Dry,
    Compound_Severity = Temp_Anomaly_Std + (-1 * SPI),
    Euclidean_Intensity = sqrt(Temp_Anomaly_Std^2 + SPI^2)
  )

# ==============================================================================
# SECTION 4: MAXIMUM CONSECUTIVE DURATION ANALYSIS
# ==============================================================================
section4_summary <- analysis_df %>%
  group_by(Province) %>%
  group_modify(~ {
    r <- rle(.x$Compound_Hot_Dry)
    true_indices <- which(r$values == TRUE)
    
    if (length(true_indices) > 0) {
      max_len <- max(r$lengths[true_indices])
      max_idx <- true_indices[which.max(r$lengths[true_indices])]
      end_pos <- sum(r$lengths[1:max_idx])
      start_pos <- end_pos - max_len + 1
      
      start_d <- format(.x$Date[start_pos], "%b %Y")
      end_d <- format(.x$Date[end_pos], "%b %Y")
    } else {
      max_len <- 0; start_d <- "N/A"; end_d <- "N/A"
    }
    
    tibble(
      `Max Consecutive Months` = max_len,
      `Start Period` = start_d,
      `End Period` = end_d
    )
  }) %>%
  ungroup() %>%
  arrange(desc(`Max Consecutive Months`))

# ==============================================================================
# SECTION 5: COMPOUND EVENT SEVERITY & INTENSITY ANALYSIS
# ==============================================================================
section5_summary <- analysis_df %>%
  filter(Compound_Hot_Dry == TRUE) %>%
  group_by(Province) %>%
  summarise(
    `Total Compound Events` = n(),
    `Mean Severity (CSI)` = round(mean(Compound_Severity), 2),
    `Max Severity (CSI)` = round(max(Compound_Severity), 2),
    `Mean Intensity (ECI)` = round(mean(Euclidean_Intensity), 2),
    `Max Intensity (ECI)` = round(max(Euclidean_Intensity), 2),
    .groups = "drop"
  ) %>%
  arrange(desc(`Max Severity (CSI)`))

# ==============================================================================
# SECTION 16: MANN-KENDALL TREND TEST & SEN'S SLOPE ESTIMATOR
# ==============================================================================
annual_counts <- analysis_df %>%
  group_by(Province, Year) %>%
  summarise(Annual_Events = sum(Compound_Hot_Dry), .groups = "drop")

section16_summary <- annual_counts %>%
  group_by(Province) %>%
  group_modify(~ {
    ts_data <- ts(.x$Annual_Events, start = 1994, end = 2023)
    mk_test <- mk.test(ts_data)
    sen_test <- sens.slope(ts_data)
    
    z_stat <- mk_test$statistic
    p_val <- mk_test$p.value
    slope <- sen_test$estimates
    
    trend_sign <- case_when(
      p_val < 0.05 & z_stat > 0 ~ "Significant Increase",
      p_val < 0.05 & z_stat < 0 ~ "Significant Decrease",
      TRUE ~ "No Significant Trend"
    )
    
    tibble(
      `Period` = "1994-2023",
      `n (Years)` = length(ts_data),
      `MK Statistic (S)` = round(mk_test$estimates["S"], 2),
      `Z Score` = round(z_stat, 3),
      `p-value` = round(p_val, 4),
      `Sen's Slope` = round(slope, 4),
      `Trend Status (alpha=0.05)` = trend_sign
    )
  }) %>%
  ungroup() %>%
  arrange(`p-value`)

# ==============================================================================
# CREATE MULTI-SHEET EXCEL WORKBOOK (.XLSX)
# ==============================================================================
wb <- createWorkbook()

header_style <- createStyle(
  fontName = "Arial", fontSize = 11, fontColour = "#FFFFFF", fgFill = "#1F497D",
  textDecoration = "bold", halign = "center", valign = "center"
)

# Sheet 1: Max Duration
addWorksheet(wb, "4. Max Ard??s??k Sure")
writeData(wb, "4. Max Ard??s??k Sure", section4_summary, headerStyle = header_style)

# Sheet 2: Severity
addWorksheet(wb, "5. Bilesik Siddet")
writeData(wb, "5. Bilesik Siddet", section5_summary, headerStyle = header_style)

# Sheet 3: Mann-Kendall
addWorksheet(wb, "16. Mann-Kendall & Sen Slope")
writeData(wb, "16. Mann-Kendall & Sen Slope", section16_summary, headerStyle = header_style)

# Sheet 4: Annual Series
annual_pivot <- annual_counts %>% pivot_wider(names_from = Province, values_from = Annual_Events)
addWorksheet(wb, "Y??ll??k Zaman Serisi")
writeData(wb, "Y??ll??k Zaman Serisi", annual_pivot, headerStyle = header_style)

# Save Master Excel
saveWorkbook(wb, "Bilesik_Sicak_Kurak_Analiz_Master_9_Il.xlsx", overwrite = TRUE)
print("Master Excel Dosyasi Basariyla Olusturuldu: Bilesik_Sicak_Kurak_Analiz_Master_9_Il.xlsx")

# ==============================================================================
# GENERATE AND SAVE PLOTS
# ==============================================================================

# Plot 1: Max Duration Plot
p1 <- ggplot(section4_summary, aes(x = reorder(Province, `Max Consecutive Months`), y = `Max Consecutive Months`)) +
  geom_col(fill = "#9b2c2c", width = 0.65) +
  coord_flip() +
  theme_minimal(base_size = 12) +
  labs(title = "Maximum Consecutive Duration of Compound Hot-Dry Events", x = "Province", y = "Consecutive Months")

ggsave("4_Max_Consecutive_Duration.png", plot = p1, width = 9, height = 5, dpi = 300)

# Plot 2: Mann-Kendall Z-score Plot
p2 <- ggplot(section16_summary, aes(x = reorder(Province, `Z Score`), y = `Z Score`, fill = `Trend Status (alpha=0.05)`)) +
  geom_col(width = 0.65) +
  geom_hline(yintercept = c(-1.96, 1.96), linetype = "dashed", color = "#e53e3e") +
  coord_flip() +
  theme_minimal(base_size = 12) +
  labs(title = "Mann-Kendall Z-Score Trend Analysis", x = "Province", y = "Z-Score")

ggsave("16_Mann_Kendall_Trend.png", plot = p2, width = 9, height = 5, dpi = 300)

print("T??m Analizler, Grafik ????kt??lar?? ve Excel Dosyas?? Ba??ar??yla Tamamland??.")