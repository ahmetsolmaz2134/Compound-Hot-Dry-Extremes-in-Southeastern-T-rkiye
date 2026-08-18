# 1. Gerekli K??t??phaneler
library(tidyverse)
library(openxlsx)
library(ggplot2)

# 2. Veri Setini Y??kleme
df <- read.csv("Guneydogu_NASA_POWER_1981_2025_Monthly.csv")

# ??ehir isimlerini d??zg??n s??rada fakt??r yapal??m
city_levels <- c("Adiyaman", "Batman", "Diyarbakir", "Gaziantep", 
                 "Kilis", "Mardin", "Sanliurfa", "Siirt", "Sirnak")

df <- df %>%
  mutate(city = factor(city, levels = city_levels))

# 3. S??cakl??k Temel ??statistiklerinin Hesaplanmas?? (1981???2025)
summary_stats <- df %>%
  group_by(city) %>%
  summarise(
    N_Months = n(),
    Mean = mean(T2M_Mean, na.rm = TRUE),
    Median = median(T2M_Mean, na.rm = TRUE),
    Min = min(T2M_Mean, na.rm = TRUE),
    Max = max(T2M_Mean, na.rm = TRUE),
    Std_Dev = sd(T2M_Mean, na.rm = TRUE),
    IQR = IQR(T2M_Mean, na.rm = TRUE)
  ) %>%
  rename(City = city)

# Genel B??lge Ortalamas?? (B??lgesel ??zet)
regional_summary <- df %>%
  summarise(
    City = "Southeastern Anatolia (Region)",
    N_Months = n(),
    Mean = mean(T2M_Mean, na.rm = TRUE),
    Median = median(T2M_Mean, na.rm = TRUE),
    Min = min(T2M_Mean, na.rm = TRUE),
    Max = max(T2M_Mean, na.rm = TRUE),
    Std_Dev = sd(T2M_Mean, na.rm = TRUE),
    IQR = IQR(T2M_Mean, na.rm = TRUE)
  )

# ??ehir bazl?? istatistikler ile b??lgesel ortalamay?? birle??tirme
final_summary <- bind_rows(summary_stats, regional_summary)

print(final_summary)

# 4. Akademik ??ngilizce Grafikler (Publication-Ready)

# Grafik 1: Boxplot ile ??ehir Bazl?? S??cakl??k Da????l??mlar?? ve ??statistiksel ??zeti
p1 <- ggplot(df, aes(x = city, y = T2M_Mean, fill = city)) +
  geom_boxplot(alpha = 0.7, outlier.size = 1, outlier.alpha = 0.5) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, color = "darkred") +
  scale_fill_brewer(palette = "Set3") +
  theme_bw(base_size = 12) +
  theme(
    legend.position = "none",
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 14),
    panel.grid.minor = element_blank()
  ) +
  labs(
    title = "Monthly Mean Temperature Distribution across Southeastern Anatolia (1981???2025)",
    subtitle = "Red diamonds represent mean values; box hinges indicate IQR and line indicates median",
    x = "Provinces",
    y = "Monthly Mean Temperature (??C)"
  )

ggsave("Temperature_Distribution_Boxplot.png", plot = p1, width = 10, height = 6, dpi = 300)

# Grafik 2: Y??ll??k Ortalama S??cakl??k Trendleri (??ehir Bazl??)
annual_temp <- df %>%
  group_by(city, Year) %>%
  summarise(Annual_Mean_Temp = mean(T2M_Mean, na.rm = TRUE), .groups = "drop")

p2 <- ggplot(annual_temp, aes(x = Year, y = Annual_Mean_Temp, color = city)) +
  geom_line(alpha = 0.8, linewidth = 0.8) +
  geom_smooth(method = "lm", se = FALSE, linetype = "dashed", linewidth = 0.6) +
  facet_wrap(~city, ncol = 3) +
  scale_color_brewer(palette = "Dark2") +
  theme_bw(base_size = 11) +
  theme(
    legend.position = "none",
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 14)
  ) +
  labs(
    title = "Annual Mean Temperature Trends by Province (1981???2025)",
    subtitle = "Dashed lines represent long-term linear trends",
    x = "Year",
    y = "Annual Mean Temperature (??C)"
  )

ggsave("Annual_Temperature_Trends_Facets.png", plot = p2, width = 12, height = 8, dpi = 300)

# 5. Excel ????kt??s?? Olu??turma (Openxlsx ile Stilize Tablo)
wb <- createWorkbook()

# Sayfa 1: Temel ??statistikler
addWorksheet(wb, "Temperature Summary Stats")
writeData(wb, "Temperature Summary Stats", final_summary, startRow = 1, startCol = 1)

# Ba??l??k stili
header_style <- createStyle(
  fontName = "Arial",
  fontSize = 11,
  textDecoration = "bold",
  halign = "center",
  fgFill = "#1F4E79",
  fontColour = "white"
)

addStyle(wb, "Temperature Summary Stats", header_style, rows = 1, cols = 1:ncol(final_summary), gridExpand = TRUE)

# Ondal??k say?? stili (2 basamak)
num_style <- createStyle(numFmt = "0.02")
addStyle(wb, "Temperature Summary Stats", num_style, rows = 2:(nrow(final_summary) + 1), cols = 3:ncol(final_summary), gridExpand = TRUE)

# S??tun geni??liklerini ayarlama
setColWidths(wb, "Temperature Summary Stats", cols = 1:ncol(final_summary), widths = "auto")

# Sayfa 2: Y??ll??k Ortalamalar Veri Tablosu
addWorksheet(wb, "Annual Mean Temperature")
writeData(wb, "Annual Mean Temperature", annual_temp, startRow = 1, startCol = 1)
addStyle(wb, "Annual Mean Temperature", header_style, rows = 1, cols = 1:ncol(annual_temp), gridExpand = TRUE)
setColWidths(wb, "Annual Mean Temperature", cols = 1:ncol(annual_temp), widths = "auto")

# Excel Dosyas??n?? Kaydetme
saveWorkbook(wb, "Southeastern_Anatolia_Temperature_Statistics_1981_2025.xlsx", overwrite = TRUE)

cat("\n????lem ba??ar??yla tamamland??!\n")
cat("1. 'Southeastern_Anatolia_Temperature_Statistics_1981_2025.xlsx' dosyas?? olu??turuldu.\n")
cat("2. 'Temperature_Distribution_Boxplot.png' ve 'Annual_Temperature_Trends_Facets.png' grafikleri kaydedildi.\n")