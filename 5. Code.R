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

# 3. ??L BAZLI P90 E????K HESABI VE EKSTREM AYLARIN TESP??T?? (1981-2010 Baseline)
p90_thresholds <- df %>%
  filter(Year >= 1981 & Year <= 2010) %>%
  group_by(city) %>%
  summarise(P90_Threshold = quantile(T2M_Mean, 0.90, na.rm = TRUE), .groups = "drop")

# S??cak Ekstrem Aylar??n Filtrelenmesi ve ??zellikleri
df_hot_extremes <- df %>%
  left_join(p90_thresholds, by = "city") %>%
  mutate(
    Is_Hot_Extreme = ifelse(T2M_Mean >= P90_Threshold, TRUE, FALSE),
    Anomaly_from_P90 = T2M_Mean - P90_Threshold
  ) %>%
  filter(Is_Hot_Extreme == TRUE) %>%
  arrange(city, Year, Month)

# 4. AYLIK VE MEVS??MSEL FREKANS DA??ILIMI (Ekstrem Aylar Hangi Aylarda Yo??unla????yor?)
month_names <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

hot_extremes_by_month <- df_hot_extremes %>%
  mutate(Month_Name = factor(month_names[Month], levels = month_names)) %>%
  group_by(city, Month_Name) %>%
  summarise(
    Extreme_Count = n(),
    Mean_Extreme_Temp = mean(T2M_Mean, na.rm = TRUE),
    Max_Extreme_Temp = max(T2M_Mean, na.rm = TRUE),
    .groups = "drop"
  )

# 5. GRAF??K 1: S??cak Ekstrem Aylar??n Y??llara G??re Da????l??m?? ve ??iddeti (Scatterplot + Bubble)
p1 <- ggplot(df_hot_extremes, aes(x = Year, y = T2M_Mean, color = Anomaly_from_P90, size = Anomaly_from_P90)) +
  geom_point(alpha = 0.8) +
  scale_color_gradient(low = "#fdb863", high = "#b2182b", name = "Exceedance above P90 (??C)") +
  scale_size_continuous(range = c(2, 6), guide = "none") +
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
    title = "Identification and Intensity of Hot Extreme Months (1981???2025)",
    subtitle = "Points represent months where T2M >= P90 threshold. Color intensity indicates excess temperature.",
    x = "Year",
    y = "Monthly Mean Temperature (??C)"
  )

print(p1)
ggsave("Hot_Extreme_Months_Distribution.png", plot = p1, width = 12, height = 8, dpi = 300)

# 6. GRAF??K 2: S??cak Ekstrem Aylar??n Ayl??k Yo??unla??ma Matrisi (Heatmap)
p2 <- ggplot(hot_extremes_by_month, aes(x = Month_Name, y = city, fill = Extreme_Count)) +
  geom_tile(color = "white", linewidth = 0.5) +
  geom_text(aes(label = Extreme_Count), color = "black", fontface = "bold", size = 3.5) +
  scale_fill_gradient(low = "#ffedd5", high = "#c2410c", name = "Extreme Month Count") +
  theme_bw(base_size = 12) +
  theme(
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13),
    panel.grid = element_blank(),
    legend.position = "right"
  ) +
  labs(
    title = "Seasonal Occurrence Matrix of Hot Extreme Months",
    subtitle = "Total count of extreme hot months by province and calendar month (1981???2025)",
    x = "Month",
    y = "Province"
  )

print(p2)
ggsave("Hot_Extreme_Months_Heatmap.png", plot = p2, width = 10, height = 6, dpi = 300)

# 7. EXCEL ??IKTISI (T??m S??cak Ekstrem Aylar??n Listesi ve Ayl??k ??zet)
wb <- createWorkbook()

# Sayfa 1: S??cak Ekstrem Aylar??n Tam Listesi (T??m Olaylar)
addWorksheet(wb, "Identified Hot Extreme Months")
writeData(wb, "Identified Hot Extreme Months", df_hot_extremes %>% select(city, Year, Month, T2M_Mean, P90_Threshold, Anomaly_from_P90))

# Sayfa 2: Ayl??k Yo??unla??ma ??statistikleri
addWorksheet(wb, "Monthly Occurrence Summary")
writeData(wb, "Monthly Occurrence Summary", hot_extremes_by_month)

# Stil Tan??mlamalar??
header_style <- createStyle(fontName = "Arial", fontSize = 11, textDecoration = "bold",
                            halign = "center", fgFill = "#1F4E79", fontColour = "white")
num_style <- createStyle(numFmt = "0.00")

sheets <- c("Identified Hot Extreme Months", "Monthly Occurrence Summary")
for (sheet in sheets) {
  addStyle(wb, sheet, header_style, rows = 1, cols = 1:6, gridExpand = TRUE)
  addStyle(wb, sheet, num_style, rows = 2:2000, cols = 4:6, gridExpand = TRUE, stack = TRUE)
  setColWidths(wb, sheet, cols = 1:6, widths = "auto")
}

saveWorkbook(wb, "Southeastern_Anatolia_Hot_Extreme_Months_1981_2025.xlsx", overwrite = TRUE)

cat("\n>>> S??cak Ekstrem Ay Analizi Ba??ar??yla Tamamland??! <<<\n")
cat("1. 'Hot_Extreme_Months_Distribution.png' ve 'Hot_Extreme_Months_Heatmap.png' kaydedildi ve ekranda g??sterildi.\n")
cat("2. 'Southeastern_Anatolia_Hot_Extreme_Months_1981_2025.xlsx' dosyas??na t??m ekstrem aylar aktar??ld??.\n")