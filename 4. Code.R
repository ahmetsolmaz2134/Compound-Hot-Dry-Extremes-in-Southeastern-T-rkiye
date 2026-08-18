# 1. Gerekli K??t??phaneler
library(tidyverse)
library(openxlsx)
library(ggplot2)

# 2. Veri Okuma
if(!exists("df")) {
  if(file.exists("Guneydogu_NASA_POWER_1981_2025_Monthly.csv")) {
    df <- read.csv("Guneydogu_NASA_POWER_1981_2025_Monthly.csv")
  } else {
    df <- read.csv(file.choose())
  }
}

city_levels <- c("Adiyaman", "Batman", "Diyarbakir", "Gaziantep", 
                 "Kilis", "Mardin", "Sanliurfa", "Siirt", "Sirnak")

df <- df %>%
  mutate(city = factor(city, levels = city_levels))

# 3. ??L BAZLI P90 SICAKLIK E???????? HESAPLAMA (1981???2010 Baseline)
p90_thresholds <- df %>%
  filter(Year >= 1981 & Year <= 2010) %>%
  group_by(city) %>%
  summarise(
    P90_Threshold_C = quantile(T2M_Mean, 0.90, na.rm = TRUE),
    Mean_Temp = mean(T2M_Mean, na.rm = TRUE),
    Max_Temp = max(T2M_Mean, na.rm = TRUE),
    .groups = "drop"
  )

regional_p90 <- df %>%
  filter(Year >= 1981 & Year <= 2010) %>%
  summarise(
    city = factor("Southeastern Anatolia (Region)"),
    P90_Threshold_C = quantile(T2M_Mean, 0.90, na.rm = TRUE),
    Mean_Temp = mean(T2M_Mean, na.rm = TRUE),
    Max_Temp = max(T2M_Mean, na.rm = TRUE)
  )

final_p90_table <- bind_rows(p90_thresholds, regional_p90)

# 4. P90 A??IMLARININ (EKSTREM SICAKLIK OLAYLARI) TESP??T?? (S??ZD??Z??M?? D??ZELT??LD??)
df_p90_events <- df %>%
  left_join(p90_thresholds %>% select(city, P90_Threshold_C), by = "city") %>%
  mutate(Is_P90_Extreme = ifelse(T2M_Mean >= P90_Threshold_C, 1, 0))

# Y??ll??k P90 Ekstrem Frekans??
annual_p90_counts <- df_p90_events %>%
  group_by(city, Year) %>%
  summarise(
    P90_Exceedance_Months = sum(Is_P90_Extreme, na.rm = TRUE),
    Max_Monthly_Temp = max(T2M_Mean, na.rm = TRUE),
    .groups = "drop"
  )

# 5. GRAF??K 1: ??ehir Bazl?? P90 S??cakl??k E??ikleri
p1 <- ggplot(p90_thresholds, aes(x = reorder(city, P90_Threshold_C), y = P90_Threshold_C, fill = P90_Threshold_C)) +
  geom_bar(stat = "identity", width = 0.6) +
  geom_text(aes(label = paste0(round(P90_Threshold_C, 1), " ??C")), vjust = -0.5, fontface = "bold", size = 3.8) +
  scale_fill_gradient(low = "#fdae61", high = "#d73027") +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13)
  ) +
  coord_cartesian(ylim = c(20, max(p90_thresholds$P90_Threshold_C) + 3)) +
  labs(
    title = "90th Percentile (P90) Extreme Heat Thresholds by Province",
    subtitle = "Calculated based on 1981???2010 baseline period (??C)",
    x = "Province",
    y = "P90 Temperature Threshold (??C)"
  )

print(p1)
ggsave("P90_Temperature_Thresholds_Barplot.png", plot = p1, width = 9, height = 6, dpi = 300)

# 6. GRAF??K 2: Y??ll??k P90 A????m Frekanslar?? Trendi (9 ??l Facet)
p2 <- ggplot(annual_p90_counts, aes(x = Year, y = P90_Exceedance_Months, fill = P90_Exceedance_Months)) +
  geom_bar(stat = "identity") +
  geom_smooth(method = "lm", color = "black", linetype = "dashed", se = FALSE, linewidth = 0.6) +
  scale_fill_gradient(low = "#fee090", high = "#a50026", name = "Months >= P90") +
  facet_wrap(~city, ncol = 3) +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom"
  ) +
  labs(
    title = "Annual Frequency of Extreme Temperature Months (>= P90 Threshold)",
    subtitle = "Dashed trend line shows the increase in extreme heat frequency (1981???2025)",
    x = "Year",
    y = "Number of Months Exceeding P90 Threshold"
  )

print(p2)
ggsave("Annual_P90_Exceedance_Trends.png", plot = p2, width = 12, height = 8, dpi = 300)

# 7. EXCEL ??IKTISI
wb <- createWorkbook()

addWorksheet(wb, "P90 Thresholds")
writeData(wb, "P90 Thresholds", final_p90_table)

addWorksheet(wb, "Annual P90 Exceedances")
writeData(wb, "Annual P90 Exceedances", annual_p90_counts)

header_style <- createStyle(fontName = "Arial", fontSize = 11, textDecoration = "bold",
                            halign = "center", fgFill = "#1F4E79", fontColour = "white")
num_style <- createStyle(numFmt = "0.00")

sheets <- c("P90 Thresholds", "Annual P90 Exceedances")
for (sheet in sheets) {
  addStyle(wb, sheet, header_style, rows = 1, cols = 1:5, gridExpand = TRUE)
  addStyle(wb, sheet, num_style, rows = 2:500, cols = 2:5, gridExpand = TRUE, stack = TRUE)
  setColWidths(wb, sheet, cols = 1:5, widths = "auto")
}

saveWorkbook(wb, "Southeastern_Anatolia_P90_Thresholds_1981_2025.xlsx", overwrite = TRUE)

cat("\n>>> P90 S??cakl??k E??ik Analizi Ba??ar??yla Tamamland??! <<<\n")