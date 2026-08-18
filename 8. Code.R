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

# 3. SPI-3 HESAPLAMA
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

df_spi3 <- bind_rows(df_list) %>%
  filter(!is.na(SPI3)) %>%
  mutate(Date = as.Date(paste(Year, Month, "01", sep = "-")))

# ---------------------------------------------------------
# 4. KURAK D??NEMLER??N TESP??T?? (Run Theory Algorithm)
# ---------------------------------------------------------
drought_events_list <- list()

for(c_name in unique_cities) {
  c_data <- df_spi3 %>% filter(city_var == c_name) %>% arrange(Date)
  
  in_drought <- FALSE
  event_id <- 0
  
  start_date <- NULL
  end_date <- NULL
  spi_vals <- c()
  dates <- c()
  
  events <- data.frame()
  
  for(i in 1:nrow(c_data)) {
    val <- c_data$SPI3[i]
    dt  <- c_data$Date[i]
    
    # Kurak d??nem ba??lang??c?? (SPI <= -1.0)
    if(!in_drought && val <= -1.0) {
      in_drought <- TRUE
      event_id <- event_id + 1
      start_date <- dt
      spi_vals <- c(val)
      dates <- c(dt)
    } 
    # Kurak d??nemin devam etmesi (SPI < 0)
    else if(in_drought && val < 0) {
      spi_vals <- c(spi_vals, val)
      dates <- c(dates, dt)
    } 
    # Kurak d??nemin sonlanmas?? (SPI >= 0 veya veri sonu)
    else if(in_drought && (val >= 0 || i == nrow(c_data))) {
      in_drought <- FALSE
      end_date <- dates[length(dates)]
      
      duration <- length(spi_vals)
      severity <- sum(abs(spi_vals))
      intensity <- severity / duration
      peak_spi <- min(spi_vals)
      
      events <- rbind(events, data.frame(
        city_var = c_name,
        Event_ID = event_id,
        Start_Date = start_date,
        End_Date = end_date,
        Duration_Months = duration,
        Severity = round(severity, 2),
        Intensity = round(intensity, 2),
        Peak_SPI = round(peak_spi, 2)
      ))
      
      spi_vals <- c()
      dates <- c()
    }
  }
  drought_events_list[[c_name]] <- events
}

all_drought_events <- bind_rows(drought_events_list)

# ---------------------------------------------------------
# 5. ??L BAZLI KURAK D??NEM ??ZET ??STAT??ST??KLER??
# ---------------------------------------------------------
drought_summary_by_city <- all_drought_events %>%
  group_by(city_var) %>%
  summarise(
    Total_Drought_Events = n(),
    Max_Duration_Months = max(Duration_Months),
    Mean_Duration_Months = round(mean(Duration_Months), 1),
    Max_Severity = max(Severity),
    Mean_Severity = round(mean(Severity), 2),
    Worst_Peak_SPI = min(Peak_SPI),
    .groups = "drop"
  )

# ---------------------------------------------------------
# 6. GRAF??K 1: En Uzun S??reli Kurak D??nemlerin Kar????la??t??r??lmas??
# ---------------------------------------------------------
p1 <- ggplot(all_drought_events, aes(x = Start_Date, y = Duration_Months, size = Severity, color = Peak_SPI)) +
  geom_point(alpha = 0.7) +
  scale_color_gradient(low = "#800026", high = "#feb24c", name = "Peak SPI Value") +
  scale_size_continuous(range = c(2, 8), name = "Severity (Cumulative |SPI|)") +
  facet_wrap(~city_var, ncol = 3) +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    plot.title = element_text(face = "bold", size = 13),
    legend.position = "bottom"
  ) +
  labs(
    title = "Identified Drought Events Across Southeastern Anatolia (1981???2025)",
    subtitle = "Each point represents a distinct drought episode. Y-axis shows drought duration in months.",
    x = "Event Start Date",
    y = "Drought Duration (Months)"
  )

print(p1)
ggsave("Identified_Drought_Events.png", plot = p1, width = 13, height = 8, dpi = 300)

# ---------------------------------------------------------
# 7. EXCEL ??IKTISI
# ---------------------------------------------------------
wb <- createWorkbook()

# Sayfa 1: Tespit Edilen T??m Kurak D??nemlerin Listesi
addWorksheet(wb, "All Drought Episodes")
writeData(wb, "All Drought Episodes", all_drought_events)

# Sayfa 2: ??l Bazl?? ??zet
addWorksheet(wb, "City Drought Summary")
writeData(wb, "City Drought Summary", drought_summary_by_city)

# Bi??imlendirme
header_style <- createStyle(fontName = "Arial", fontSize = 11, textDecoration = "bold",
                            halign = "center", fgFill = "#1F4E79", fontColour = "white")
num_style <- createStyle(numFmt = "0.00")

for (sheet in c("All Drought Episodes", "City Drought Summary")) {
  addStyle(wb, sheet, header_style, rows = 1, cols = 1:8, gridExpand = TRUE)
  addStyle(wb, sheet, num_style, rows = 2:1000, cols = 5:8, gridExpand = TRUE, stack = TRUE)
  setColWidths(wb, sheet, cols = 1:8, widths = "auto")
}

saveWorkbook(wb, "Southeastern_Anatolia_Drought_Episodes_1981_2025.xlsx", overwrite = TRUE)

cat("\n>>> Kurak D??nemlerin Belirlenmesi Analizi Ba??ar??yla Tamamland??! <<<\n")
cat("1. 'Identified_Drought_Events.png' grafi??i kaydedildi.\n")
cat("2. 'Southeastern_Anatolia_Drought_Episodes_1981_2025.xlsx' dosyas??na t??m kurak d??nem bilgileri aktar??ld??.\n")