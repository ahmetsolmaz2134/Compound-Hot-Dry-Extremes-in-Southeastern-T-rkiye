# 1. K??t??phaneler
library(tidyverse)
library(SPEI)
library(ggplot2)

# 2. Veri Okuma
if(!exists("df")) {
  df <- read.csv(file.choose())
}

# ---------------------------------------------------------
# D??NAM??K S??TUN TESP??T?? (Hata ??nleyici)
# ---------------------------------------------------------
# ??ehir s??tun ad??n?? tespit et (city, il, province)
city_col <- names(df)[grep("city|il|province", names(df), ignore.case = TRUE)][1]

# Ya?????? s??tun ad??n?? tespit et (PRECTOTCORR, PRECTOT, PRCP, PR, Yagis)
precip_col <- names(df)[grep("PREC|PRCP|PR|RAIN|YAGIS", names(df), ignore.case = TRUE)][1]

cat("Tespit Edilen ??ehir S??tunu :", city_col, "\n")
cat("Tespit Edilen Ya?????? S??tunu :", precip_col, "\n\n")

# Veriyi standartla??t??rma
df <- df %>%
  rename(city_var = !!sym(city_col), precip_var = !!sym(precip_col)) %>%
  mutate(
    city_var = as.character(city_var),
    precip_var = as.numeric(as.character(precip_var))
  ) %>%
  filter(!is.na(Year) & !is.na(Month)) %>%
  arrange(city_var, Year, Month)

# NA ya?????? verilerini 0 yap
df$precip_var[is.na(df$precip_var)] <- 0

# ---------------------------------------------------------
# 3. SPI-3 HESAPLAMA (Dinamik ??ehir D??ng??s??)
# ---------------------------------------------------------
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

# ---------------------------------------------------------
# 4. TAR??H VE GRAF??K ????Z??M??
# ---------------------------------------------------------
df_spi3 <- df_spi3 %>%
  mutate(
    Date = as.Date(paste(Year, Month, "01", sep = "-")),
    Is_Drought = ifelse(SPI3 < 0, TRUE, FALSE)
  ) %>%
  filter(!is.na(SPI3))

p1 <- ggplot(df_spi3, aes(x = Date, y = SPI3)) +
  geom_col(aes(fill = Is_Drought), width = 32) +
  scale_fill_manual(values = c("FALSE" = "#2b83ba", "TRUE" = "#d7191c"), 
                    labels = c("Wet / Normal", "Drought (SPI3 < 0)"),
                    name = "Condition") +
  geom_hline(yintercept = c(-1, -1.5, -2), linetype = "dashed", color = "black", alpha = 0.6) +
  facet_wrap(~city_var, ncol = 3) +
  theme_bw(base_size = 11) +
  theme(
    strip.background = element_rect(fill = "gray90"),
    strip.text = element_text(face = "bold"),
    axis.title = element_text(face = "bold"),
    legend.position = "bottom"
  ) +
  labs(
    title = "3-Month Standardized Precipitation Index (SPI-3) Timeseries",
    subtitle = "Dashed lines represent Drought Thresholds (-1.0 Moderate, -1.5 Severe, -2.0 Extreme)",
    x = "Date",
    y = "SPI-3 Index Value"
  )

print(p1)