# 1. Gerekli K??t??phaneler
library(nasapower)
library(tidyverse)
library(lubridate)

# 2. G??neydo??u Anadolu ??llerinin Merkez Koordinatlar?? (9 ??ehir)
cities <- data.frame(
  city = c("Diyarbakir", "Siirt", "Batman", "Mardin", "Sirnak", "Sanliurfa", "Gaziantep", "Adiyaman", "Kilis"),
  lat  = c(37.9144, 37.9326, 37.8874, 37.3129, 37.5164, 37.1674, 37.0662, 37.7644, 36.7184),
  lon  = c(40.2306, 41.9403, 41.1322, 40.7350, 42.4610, 38.7955, 37.3833, 38.2763, 37.1147)
)

# 3. NASA POWER Verilerini ??ekme
all_cities_data <- list()

for(i in 1:nrow(cities)) {
  cat("Veri indiriliyor:", cities$city[i], "...\n")
  
  power_data <- get_power(
    community = "AG",
    pars = c("T2M", "PRECTOTCORR"),
    temporal_api = "monthly",
    lonlat = c(cities$lon[i], cities$lat[i]),
    dates = c(1981, 2025)
  )
  
  power_data$city <- cities$city[i]
  all_cities_data[[cities$city[i]]] <- power_data
}

# 4. Verileri Birle??tirme
raw_df <- bind_rows(all_cities_data)
colnames(raw_df) <- tolower(colnames(raw_df))

# 5. Ay ??simlerini Say??ya D??n????t??ren Harita
month_map <- c(
  "jan" = 1, "feb" = 2, "mar" = 3, "apr" = 4, "may" = 5, "jun" = 6,
  "jul" = 7, "aug" = 8, "sep" = 9, "oct" = 10, "nov" = 11, "dec" = 12
)

# 6. S??tun Yap??s??n?? Kontrol Edip Tabloyu D??zenleme
# Yap?? geni?? ise (JAN, FEB vb. s??tunlar varsa) pivot yap, de??ilse do??rudan i??le
if ("jan" %in% colnames(raw_df)) {
  climate_clean <- raw_df %>%
    pivot_longer(
      cols = any_of(names(month_map)),
      names_to = "month_str",
      values_to = "value"
    ) %>%
    filter(parameter %in% c("T2M", "PRECTOTCORR")) %>%
    mutate(
      Year = as.numeric(year),
      Month = month_map[month_str]
    ) %>%
    pivot_wider(
      names_from = parameter,
      values_from = value
    ) %>%
    rename(T2M_Mean = T2M, PRCP_Daily_Mean = PRECTOTCORR)
} else {
  # E??er veri zaten uzun formatta ise
  climate_clean <- raw_df %>%
    mutate(
      Year = as.numeric(year),
      Month = as.numeric(if("month" %in% colnames(.)) month else yyyymm %% 100)
    ) %>%
    rename(T2M_Mean = t2m, PRCP_Daily_Mean = prectotcorr)
}

# 7. Ayl??k Toplam Ya?????? Hesab?? (mm/g??n -> mm/ay) ve Temizlik
climate_final <- climate_clean %>%
  filter(!is.na(Month) & Month >= 1 & Month <= 12) %>%
  mutate(
    Days_in_Month = days_in_month(as.Date(paste(Year, Month, "01", sep = "-"))),
    PRCP_Total_mm = PRCP_Daily_Mean * Days_in_Month
  ) %>%
  select(city, lat, lon, Year, Month, T2M_Mean, PRCP_Total_mm) %>%
  arrange(city, Year, Month)

# 8. Kaydet
write.csv(climate_final, "Guneydogu_NASA_POWER_1981_2025_Monthly.csv", row.names = FALSE)
cat("\n????lem ba??ar??yla tamamland??! Veri kaydedildi: Guneydogu_NASA_POWER_1981_2025_Monthly.csv\n")