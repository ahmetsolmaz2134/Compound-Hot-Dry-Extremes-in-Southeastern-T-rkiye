# 1. Gerekli K??t??phaneler
library(tidyverse)
library(SPEI)
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

# Dynamic S??tun Tespiti
city_col   <- names(df)[grep("city|il|province", names(df), ignore.case = TRUE)][1]
precip_col <- names(df)[grep("PREC|PRCP|PR|RAIN|YAGIS", names(df), ignore.case = TRUE)][1]

cat("??ehir S??tunu  :", city_col, "\n")
cat("Ya?????? S??tunu  :", precip_col, "\n\n")

# Veriyi Standartla??t??rma
df <- df %>%
  rename(city_var = !!sym(city_col), precip_var = !!sym(precip_col)) %>%
  mutate(
    city_var = as.character(city_var),
    precip_var = as.numeric(as.character(precip_var))
  ) %>%
  filter(!is.na(Year) & !is.na(Month)) %>%
  arrange(city_var, Year, Month)

df$precip_var[is.na(df$precip_var)] <- 0

# 3. SPI-3 HESAPLAMA VE WMO SINIFLANDIRMASI
unique_cities <- unique(df$city_var)
df_list <- list()

for(c_name in unique_cities) {
  sub_df <- df %>% filter(city_var == c_name)
  
  if(nrow(sub_df) > 0) {
    p_ts <- ts(sub_df$precip_var, start = c(sub_df$Year[1], sub_df$Month[1]), frequency = 12)
    spi_calc <- spi(p_ts, scale = 3, na.rm = TRUE)
    
    sub_df$SPI3 <- as.numeric(spi_calc$fitted)
    df_list[[c_name]] <- sub_df
  }
}

df_spi3 <- bind_rows(df_list)

# WMO SPI S??n??f Seviyeleri
spi_levels <- c(
  "Extreme Drought (<= -2.00)",
  "Severe Drought (-1.99 to -1.50)",
  "Moderate Drought (-1.49 to -1.00)",
  "Near Normal (-0.99 to 0.99)",
  "Moderately Wet (1.00 to 1.49)",
  "Very Wet (1.50 to 1.99)",
  "Extremely Wet (>= 2.00)"
)

df_classified <- df_spi3 %>%
  filter(!is.na(SPI3)) %>%
  mutate(
    Date = as.Date(paste(Year, Month, "01", sep = "-")),
    SPI_Class = case_when(
      SPI3 <= -2.00 ~ "Extreme Drought (<= -2.00)",
      SPI3 > -2.00 & SPI3 <= -1.50 ~ "Severe Drought (-1.99 to -1.50)",
      SPI3 > -1.50 & SPI3 <= -1.00 ~ "Moderate Drought (-1.49 to -1.00)",
      SPI3 > -1.00 & SPI3 < 1.00  ~ "Near Normal (-0.99 to 0.99)",
      SPI3 >= 1.00 & SPI3 < 1.50  ~ "Moderately Wet (1.00 to 1.49)",
      SPI3 >= 1.50 & SPI3 < 2.00  ~ "Very Wet (1.50 to 1.99)",
      SPI3 >= 2.00 ~ "Extremely Wet (>= 2.00)"
    ),
    SPI_Class = factor(SPI_Class, levels = spi_levels)
  )

# 4. ??EH??R BAZLI SINIFLANDIRMA ??ZET TABLOSU (Frekans & Y??zde)
spi_summary_table <- df_classified %>%
  group_by(city_var, SPI_Class) %>%
  summarise(Count = n(), .groups = "drop_last") %>%
  mutate(
    Total_Months = sum(Count),
    Percentage = (Count / Total_Months) * 100
  ) %>%
  ungroup()

# 5. GRAF??K 1: ??ehir Bazl?? SPI S??n??f Da????l??m?? (Oransal Y??????n Bar Grafi??i)
color_palette <- c(
  "Extreme Drought (<= -2.00)"      = "#7f0000",
  "Severe Drought (-1.99 to -1.50)"   = "#d73027",
  "Moderate Drought (-1.49 to -1.00)" = "#fc8d59",
  "Near Normal (-0.99 to 0.99)"       = "#e0e0e0",
  "Moderately Wet (1.00 to 1.49)"    = "#91bfdb",
  "Very Wet (1.50 to 1.99)"          = "#4575b4",
  "Extremely Wet (>= 2.00)"          = "#08519c"
)

p1 <- ggplot(spi_summary_table, aes(x = city_var, y = Percentage, fill = SPI_Class)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = color_palette, name = "WMO SPI Categories") +
  theme_bw(base_size = 12) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "right"
  ) +
  labs(
    title = "SPI Category Distribution Across Southeastern Anatolia Provinces",
    subtitle = "Relative proportions of drought and wetness categories (1981???2025)",
    x = "Province",
    y = "Proportion of Total Months"
  )

print(p1)
ggsave("SPI_Class_Distribution_Provinces.png", plot = p1, width = 11, height = 7, dpi = 300)

# 6. GRAF??K 2: Y??ll??k Kurakl??k S??n??flar?? Zaman Serisi Heatmap
p2 <- df_classified %>%
  group_by(city_var, Year, SPI_Class) %>%
  summarise(Count = n(), .groups = "drop") %>%
  filter(SPI_Class %in% c("Moderate Drought (-1.49 to -1.00)", 
                          "Severe Drought (-1.99 to -1.50)", 
                          "Extreme Drought (<= -2.00)")) %>%
  ggplot(aes(x = Year, y = city_var, fill = Count)) +
  geom_tile(color = "white") +
  facet_wrap(~SPI_Class, ncol = 1) +
  scale_fill_gradient(low = "#ffeda0", high = "#800026", name = "Drought Months/Year") +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13)
  ) +
  labs(
    title = "Annual Occurrences of Drought Categories by Province",
    subtitle = "Number of months per year under moderate, severe, and extreme drought conditions",
    x = "Year",
    y = "Province"
  )

print(p2)
ggsave("SPI_Drought_Categories_Heatmap.png", plot = p2, width = 12, height = 9, dpi = 300)

# 7. EXCEL ??IKTISI
wb <- createWorkbook()

addWorksheet(wb, "SPI Class Summary")
writeData(wb, "SPI Class Summary", spi_summary_table)

addWorksheet(wb, "Classified Monthly Data")
writeData(wb, "Classified Monthly Data", df_classified %>% select(city_var, Year, Month, Date, SPI3, SPI_Class))

# Bi??imlendirme
header_style <- createStyle(fontName = "Arial", fontSize = 11, textDecoration = "bold",
                            halign = "center", fgFill = "#1F4E79", fontColour = "white")
num_style <- createStyle(numFmt = "0.00")

for (sheet in c("SPI Class Summary", "Classified Monthly Data")) {
  addStyle(wb, sheet, header_style, rows = 1, cols = 1:6, gridExpand = TRUE)
  addStyle(wb, sheet, num_style, rows = 2:6000, cols = 5:5, gridExpand = TRUE, stack = TRUE)
  setColWidths(wb, sheet, cols = 1:6, widths = "auto")
}

saveWorkbook(wb, "Southeastern_Anatolia_SPI_Classification_1981_2025.xlsx", overwrite = TRUE)

cat("\n>>> SPI S??n??fland??rma Analizi Ba??ar??yla Tamamland??! <<<\n")
cat("1. 'SPI_Class_Distribution_Provinces.png' ve 'SPI_Drought_Categories_Heatmap.png' kaydedildi.\n")
cat("2. 'Southeastern_Anatolia_SPI_Classification_1981_2025.xlsx' dosyas?? olu??turuldu.\n")