# ==============================================================================
# SECTION 19: PETTITT CHANGE-POINT TEST & STRUCTURAL BREAK ANALYSIS (1981???2025)
# Academic Script for Peer-Reviewed Hydroclimatology Journals
# ==============================================================================

# 1. Load Required Libraries
required_packages <- c("tidyverse", "trend", "openxlsx")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages) > 0) install.packages(new_packages)

library(tidyverse)
library(trend)
library(openxlsx)

# ------------------------------------------------------------------------------
# 2. Pettitt Non-parametric Test Execution (1981???2025)
# ------------------------------------------------------------------------------
pettitt_summary_1981_2025 <- annual_counts %>%
  filter(Year >= 1981 & Year <= 2025) %>%
  group_by(Province) %>%
  group_modify(~ {
    # Ensure correct time ordering
    sub_df <- .x %>% arrange(Year)
    
    # Run Pettitt Change-Point Test
    res <- pettitt.test(sub_df$Annual_Events)
    
    cp_index <- as.numeric(res$estimate)
    cp_year <- sub_df$Year[cp_index]
    k_stat <- as.numeric(res$statistic)
    p_val <- as.numeric(res$p.value)
    
    status_label <- case_when(
      p_val < 0.05 ~ "Statistically Significant Shift (p < 0.05)",
      TRUE ~ "Non-significant Structural Change (p ??? 0.05)"
    )
    
    # Mean counts before and after the change point
    mean_before <- mean(sub_df$Annual_Events[1:cp_index], na.rm = TRUE)
    mean_after  <- mean(sub_df$Annual_Events[(cp_index + 1):nrow(sub_df)], na.rm = TRUE)
    
    tibble(
      `Period` = "1981???2025",
      `n_Years` = nrow(sub_df),
      `Change_Point_Year` = cp_year,
      `K_Statistic` = round(k_stat, 2),
      `p_value` = round(p_val, 4),
      `Mean_Before_Break` = round(mean_before, 2),
      `Mean_After_Break` = round(mean_after, 2),
      `Shift_Magnitude` = round(mean_after - mean_before, 2),
      `Status` = status_label
    )
  }) %>%
  ungroup() %>%
  arrange(Change_Point_Year)

# ------------------------------------------------------------------------------
# 3. Academic Visualization via ggplot2
# ------------------------------------------------------------------------------
p_pettitt_academic <- ggplot(pettitt_summary_1981_2025, 
                             aes(x = reorder(Province, Change_Point_Year), 
                                 y = Change_Point_Year, 
                                 fill = Status)) +
  geom_col(width = 0.65, color = "#1a1a1a", linewidth = 0.4) +
  geom_text(aes(label = Change_Point_Year), 
            hjust = -0.2, size = 3.5, fontface = "bold", color = "#1a1a1a") +
  coord_flip(ylim = c(1980, 2025)) +
  scale_fill_manual(values = c(
    "Statistically Significant Shift (p < 0.05)" = "#b22222",
    "Non-significant Structural Change (p ??? 0.05)" = "#b0bec5"
  )) +
  scale_y_continuous(breaks = seq(1980, 2025, by = 5)) +
  theme_classic(base_size = 12, base_family = "sans") +
  labs(
    title = "Pettitt Change-Point Detection Analysis (1981???2025)",
    subtitle = "Identification of Structural Shift Years in Annual Compound Hot-Dry Frequency",
    x = "Province",
    y = "Detected Structural Break Year (Change Point)",
    caption = "Note: Significance evaluated at alpha = 0.05 level using the non-parametric Pettitt test."
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 13, color = "#000000", hjust = 0),
    plot.subtitle = element_text(size = 10, color = "#333333", margin = margin(b = 10)),
    axis.title = element_text(face = "bold", size = 11),
    axis.text = element_text(color = "#000000", size = 10),
    legend.position = "bottom",
    legend.title = element_blank(),
    legend.text = element_text(size = 9),
    panel.grid.major.x = element_line(color = "#e0e0e0", linetype = "dashed", linewidth = 0.4)
  )

# Display Plot and Export High-Resolution File
print(p_pettitt_academic)
ggsave("Pettitt_Change_Point_1981_2025_Academic.png", plot = p_pettitt_academic, width = 8.5, height = 5.5, dpi = 300)

# ------------------------------------------------------------------------------
# 4. Append Results to Excel Master Workbook
# ------------------------------------------------------------------------------
excel_path <- "Bilesik_Sicak_Kurak_Analiz_Master_9_Il_Fixed.xlsx"
wb <- loadWorkbook(excel_path)

# Check if sheet exists, overwrite or create new
if ("19. Pettitt Change Point" %in% names(wb)) {
  removeWorksheet(wb, "19. Pettitt Change Point")
}

header_style <- createStyle(
  fontName = "Arial", fontSize = 11, fontColour = "#FFFFFF", fgFill = "#1F497D",
  textDecoration = "bold", halign = "center", valign = "center"
)

addWorksheet(wb, "19. Pettitt Change Point")
writeData(wb, "19. Pettitt Change Point", pettitt_summary_1981_2025, headerStyle = header_style)
saveWorkbook(wb, excel_path, overwrite = TRUE)

print("Pettitt Analysis Completed and Exported Successfully!")