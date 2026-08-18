# 1. Gerekli K??t??phaneler
library(tidyverse)
library(openxlsx)
library(ggplot2)

# 2. Veri Okuma (E??er 'df' haf??zada yoksa dosyadan okur)
if(!exists("df")) {
  if(file.exists("Guneydogu_NASA_POWER_1981_2025_Monthly.csv")) {
    df <- read.csv("Guneydogu_NASA_POWER_1981_2025_Monthly.csv")
  } else {
    df <- read.csv(file.choose()) # Dosya se??me penceresi a????l??r
  }
}

city_levels <- c("Adiyaman", "Batman", "Diyarbakir", "Gaziantep", 
                 "Kilis", "Mardin", "Sanliurfa", "Siirt", "Sirnak")

df <- df %>%
  mutate(city = factor(city, levels = city_levels))

# ---------------------------------------------------------
# 3. ??KL??MSEL REFERANS VE ANOMAL?? HESAPLAMA (1981-2010 Baseline)
# ---------------------------------------------------------
baseline_monthly <- df %>%
  filter(Year >= 1981 & Year <= 2010) %>%
  group_by(city, Month) %>%
  summarise(T2M_Baseline = mean(T2M_Mean, na.rm = TRUE), .groups = "drop")

df_anomaly <- df %>%
  left_join(baseline_monthly, by = c("city", "Month")) %>%
  mutate(Monthly_Anomaly = T2M_Mean - T2M_Baseline)

annual_anomaly <- df_anomaly %>%
  group_by(city, Year) %>%
  summarise(
    Annual_Anomaly = mean(Monthly_Anomaly, na.rm = TRUE),
    Annual_T2M = mean(T2M_Mean, na.rm = TRUE),
    .groups = "drop"
  )

regional_annual_anomaly <- annual_anomaly %>%
  group_by(Year) %>%
  summarise(
    city = "Southeastern Anatolia (Region)",
    Annual_Anomaly = mean(Annual_Anomaly, na.rm = TRUE),
    Annual_T2M = mean(Annual_T2M, na.rm = TRUE)
  )

# ---------------------------------------------------------
# 4. GRAF??K 1: B??lgesel Is??nma Anomalisi (B??lge Geneli)
# ---------------------------------------------------------
p1 <- ggplot(regional_annual_anomaly, aes(x = Year, y = Annual_Anomaly, fill = Annual_Anomaly > 0)) +
  geom_bar(stat = "identity", width = 0.8) +
  scale_fill_manual(values = c("TRUE" = "#d73027", "FALSE" = "#4575b4"), 
                    labels = c("Cooler than Baseline", "Warmer than Baseline"),
                    name = "Anomaly Condition") +
  geom_smooth(method = "loess", color = "black", se = FALSE, linetype = "solid", linewidth = 0.8) +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "bottom",
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Regional Annual Temperature Anomalies in Southeastern Anatolia (1981???2025)",
    subtitle = "Relative to 1981???2010 baseline. Black line denotes LOESS smoothed trend.",
    x = "Year",
    y = "Temperature Anomaly (??C)"
  )

# Ekrana ??izdir
print(p1)

# Dosyaya Kaydet
ggsave("Regional_Temperature_Anomalies_Barplot.png", plot = p1, width = 10, height = 6, dpi = 300)

# ---------------------------------------------------------
# 5. GRAF??K 2: ??ehir Bazl?? Y??ll??k Anomali Paneli (9 ??l)
# ---------------------------------------------------------
p2 <- ggplot(annual_anomaly, aes(x = Year, y = Annual_Anomaly, fill = Annual_Anomaly > 0)) +
  geom_bar(stat = "identity", show.legend = FALSE) +
  scale_fill_manual(values = c("TRUE" = "#d73027", "FALSE" = "#4575b4")) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "black", linewidth = 0.5) +
  facet_wrap(~city, ncol = 3) +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13)
  ) +
  labs(
    title = "Annual Temperature Anomalies by Province (1981???2025)",
    subtitle = "Relative to 1981???2010 baseline (??C)",
    x = "Year",
    y = "Anomaly (??C)"
  )

# Ekrana ??izdir
print(p2)

# Dosyaya Kaydet
ggsave("Annual_Temperature_Anomalies_Facets.png", plot = p2, width = 12, height = 8, dpi = 300)

# ---------------------------------------------------------
# 6. EXCEL ??IKTISI (Geli??mi?? Stilize Format)
# ---------------------------------------------------------
wb <- createWorkbook()

addWorksheet(wb, "Annual Anomalies")
writeData(wb, "Annual Anomalies", annual_anomaly)

addWorksheet(wb, "Regional Anomaly")
writeData(wb, "Regional Anomaly", regional_annual_anomaly)

addWorksheet(wb, "Monthly Anomalies Data")
writeData(wb, "Monthly Anomalies Data", df_anomaly %>% select(city, Year, Month, T2M_Mean, T2M_Baseline, Monthly_Anomaly))

header_style <- createStyle(fontName = "Arial", fontSize = 11, textDecoration = "bold",
                            halign = "center", fgFill = "#1F4E79", fontColour = "white")

sheets <- c("Annual Anomalies", "Regional Anomaly", "Monthly Anomalies Data")
for (sheet in sheets) {
  addStyle(wb, sheet, header_style, rows = 1, cols = 1:6, gridExpand = TRUE)
  setColWidths(wb, sheet, cols = 1:6, widths = "auto")
}

saveWorkbook(wb, "Southeastern_Anatolia_Temperature_Anomalies_1981_2025.xlsx", overwrite = TRUE)

cat("\n>>> ????lem Tamamland??! <<<\n")
cat("1. Grafik 1 ve Grafik 2 ekranda (Plots) g??sterildi.\n")
cat("2. G??rseller 'Regional_Temperature_Anomalies_Barplot.png' ve 'Annual_Temperature_Anomalies_Facets.png' olarak kaydedildi.\n")
cat("3. Excel 'Southeastern_Anatolia_Temperature_Anomalies_1981_2025.xlsx' olarak haz??rland??.\n")