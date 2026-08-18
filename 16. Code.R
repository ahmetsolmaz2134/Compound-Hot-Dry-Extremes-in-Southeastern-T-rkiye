# ==============================================================================
# SPEARMAN RANK CORRELATION ANALYSIS (1981???2025)
# Publication-Quality Academic Visualization for Journal Submission
# ==============================================================================

if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)

# 1. Non-parametric Monotonic Trend Analysis (1981???2025)
spearman_results_1981_2025 <- annual_counts %>%
  filter(Year >= 1981 & Year <= 2025) %>%
  group_by(Province) %>%
  group_modify(~ {
    res <- cor.test(.x$Year, .x$Annual_Events, method = "spearman", exact = FALSE)
    
    rho_val <- as.numeric(res$estimate)
    p_val <- as.numeric(res$p.value)
    
    status_label <- case_when(
      p_val < 0.05 & rho_val > 0 ~ "Statistically Significant Increase (p < 0.05)",
      p_val < 0.05 & rho_val < 0 ~ "Statistically Significant Decrease (p < 0.05)",
      TRUE ~ "Non-significant Monotonic Trend (p ??? 0.05)"
    )
    
    tibble(
      `Period` = "1981-2025",
      `n_Years` = nrow(.x),
      `Spearman_Rho` = round(rho_val, 4),
      `p_value` = round(p_val, 4),
      `Status` = status_label
    )
  }) %>%
  ungroup() %>%
  arrange(Spearman_Rho)

# 2. Publication-Ready Figure Generation using ggplot2
p_spearman_1981_2025 <- ggplot(spearman_results_1981_2025, 
                               aes(x = reorder(Province, Spearman_Rho), 
                                   y = Spearman_Rho, 
                                   fill = Status)) +
  geom_col(width = 0.65, color = "#1a1a1a", linewidth = 0.4) +
  geom_hline(yintercept = 0, color = "#000000", linewidth = 0.6) +
  scale_fill_manual(values = c(
    "Statistically Significant Increase (p < 0.05)" = "#b22222",
    "Statistically Significant Decrease (p < 0.05)" = "#1f77b4",
    "Non-significant Monotonic Trend (p ??? 0.05)" = "#b0bec5"
  )) +
  coord_flip() +
  scale_y_continuous(limits = c(-0.1, 0.4), breaks = seq(-0.1, 0.4, by = 0.1)) +
  theme_classic(base_size = 12, base_family = "sans") +
  labs(
    title = "Monotonic Trends in Annual Compound Hot-Dry Events (1981???2025)",
    subtitle = "Spearman Rank Correlation Analysis across Selected Provinces",
    x = "Province",
    y = expression("Spearman Rank Correlation Coefficient ("*rho*")"),
    caption = "Note: Statistical significance evaluated at alpha = 0.05 level."
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

# Display figure in RStudio Plots pane and export 300 DPI image file
print(p_spearman_1981_2025)
ggsave("Spearman_Rank_Correlation_1981_2025_Academic.png", plot = p_spearman_1981_2025, width = 8.5, height = 5.5, dpi = 300)