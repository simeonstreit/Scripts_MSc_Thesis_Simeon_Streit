# Analysis: Why did we switch from PERMANOVA to MRPP?
# This script quantifies the dispersion heterogeneity problem
# Run AFTER strain_analysis_5.qmd to have res.permanova_pig_worker

library(tidyverse)

# ============================================================================
# 1. DIAGNOSTIC: How many SGBs have significant dispersion differences?
# ============================================================================
cat("\n=== DISPERSION ANALYSIS SUMMARY ===\n")

# Categorize all SGBs by PERMANOVA and Dispersion results
disp_summary <- res.permanova_pig_worker %>%
  mutate(
    permanova_sig = p_value < 0.05,
    dispersion_sig = perm_disp_p < 0.05  # Use permutation test version (robust)
  ) %>%
  mutate(
    category = case_when(
      permanova_sig & !dispersion_sig ~ "Location effect (dispersion homogeneous)",
      permanova_sig & dispersion_sig ~ "Location + Dispersion effect (CONFOUNDED)",
      !permanova_sig & dispersion_sig ~ "Only dispersion differs (no location)",
      !permanova_sig & !dispersion_sig ~ "No effect detected"
    )
  )

# Count by category
cat("\nSGB Classifications (based on PERMANOVA + PERMDISP):\n")
summary_table <- disp_summary %>%
  filter(!is.na(category)) %>%
  count(category) %>%
  mutate(pct = round(100 * n / sum(n), 1))
print(summary_table)

# ============================================================================
# 2. KEY FINDING: Confounded results
# ============================================================================
confounded <- disp_summary %>%
  filter(permanova_sig & dispersion_sig) %>%
  nrow()

cat("\n=== KEY FINDING ===")
cat("\nNumber of SGBs with CONFOUNDED results")
cat(" (significant PERMANOVA with significant dispersion difference):\n")
cat(sprintf("  %d SGBs (%.1f%% of all)\n", 
            confounded, 
            100 * confounded / nrow(disp_summary)))
cat("\n→ These SGBs show location + dispersion effects together")
cat("\n→ Cannot separate which drives the PERMANOVA p-value")
cat("\n→ MRPP avoids this problem by testing within-group cohesion directly\n")

# ============================================================================
# 3. FILTERING STORY: What strain_analysis_5 did
# ============================================================================
cat("\n=== FILTERING APPROACH IN strain_analysis_5.qmd ===\n")

# SGBs passing quality filters (both tests non-significant)
clean_sgbs <- disp_summary %>%
  filter(p_value >= 0.05 & perm_disp_p >= 0.05) %>%
  nrow()

cat(sprintf("SGBs passing filter (p-PERMANOVA ≥0.05 AND p-Dispersion ≥0.05):\n"))
cat(sprintf("  %d SGBs\n", clean_sgbs))
cat(sprintf("  %.1f%% of %d total\n\n", 
            100 * clean_sgbs / nrow(disp_summary), 
            nrow(disp_summary)))

# SGBs removed due to dispersion
removed_dispersion <- disp_summary %>%
  filter(p_value >= 0.05 & perm_disp_p < 0.05) %>%
  nrow()

cat(sprintf("SGBs removed only due to dispersion heterogeneity:\n"))
cat(sprintf("  %d SGBs (non-significant location BUT significant dispersion)\n\n", 
            removed_dispersion))

# ============================================================================
# 4. REASON FOR SWITCH: MRPP is better suited
# ============================================================================
cat("\n=== WHY MRPP IS SUPERIOR ===\n")
cat("PERMANOVA issues with heterogeneous dispersion:\n")
cat("  • Can give false positives (Type I error)\n")
cat("  • Hard to interpret when both location AND dispersion differ\n")
cat("  • Requires homogeneity of dispersions assumption\n\n")

cat("MRPP advantages:\n")
cat("  • Tests within-group clustering directly\n")
cat("  • Robust to dispersion differences\n")
cat("  • A-statistic directly interpretable:\n")
cat("    - A > 0: stronger within-group structure (host-specific)\n")
cat("    - A ≤ 0: weak/no within-group structure (shared strains)\n")

# ============================================================================
# 5. VISUALIZATION: Distribution of p-values
# ============================================================================
cat("\n=== GENERATING FIGURES ===\n")

# Figure 1: Scatter plot of PERMANOVA p-value vs Dispersion p-value
library(ggplot2)

fig1 <- ggplot(disp_summary %>% filter(!is.na(permanova_sig)), 
               aes(x = p_value, y = perm_disp_p, color = category)) +
  geom_point(size = 2, alpha = 0.6) +
  geom_hline(yintercept = 0.05, linetype = "dashed", color = "gray50", size = 0.5) +
  geom_vline(xintercept = 0.05, linetype = "dashed", color = "gray50", size = 0.5) +
  scale_color_manual(
    values = c(
      "✓ Location effect (dispersion homogeneous)" = "steelblue",
      "⚠️ Location + Dispersion effect (CONFOUNDED)" = "orangered",
      "⚠️ Only dispersion differs (no location)" = "orange",
      "- No effect detected" = "lightgray"
    )
  ) +
  labs(
    title = "PERMANOVA vs Dispersion Heterogeneity",
    subtitle = "Why we needed to switch to MRPP",
    x = "PERMANOVA p-value (location/centroid)",
    y = "PERMDISP p-value (dispersion/spread)",
    color = "Category"
  ) +
  theme_bw() +
  theme(
    legend.position = "bottom",
    legend.text = element_text(size = 9)
  )

print(fig1)
ggsave(
  "../figures/dispersion_analysis_scatter.png",
  plot = fig1,
  width = 10,
  height = 8,
  dpi = 300
)

# Figure 2: Bar chart of categories
fig2 <- disp_summary %>%
  filter(!is.na(category)) %>%
  count(category) %>%
  ggplot(aes(x = reorder(category, n), y = n, fill = category)) +
  geom_col() +
  geom_text(aes(label = n), vjust = 1.5, size = 4) +
  scale_fill_manual(
    values = c(
      "Location effect (dispersion homogeneous)" = "steelblue",
      "Location + Dispersion effect (CONFOUNDED)" = "orangered",
      "Only dispersion differs (no location)" = "orange",
      "No effect detected" = "lightgray"
    )
  ) +
  coord_flip() +
  labs(
    title = "SGB Distribution: Why MRPP was Needed",
    x = "",
    y = "Number of SGBs",
    fill = "Category"
  ) +
  theme_bw() +
  theme_publication()+
  theme(
    legend.position = "none",
    axis.text.x = element_text(size = 10)
  )

print(fig2)
ggsave(
  "../Simeon/figures/dispersion_analysis_categories.svg",
  plot = fig2,
  width = 14,
  height = 6,
  dpi = 300
)

# ============================================================================
# 6. TABLE FOR METHODS SECTION
# ============================================================================
cat("\n=== STATISTICS FOR METHODS SECTION ===\n")

stats_for_methods <- disp_summary %>%
  filter(!is.na(permanova_sig)) %>%
  summarise(
    total_sgbs = n(),
    permanova_sig_n = sum(permanova_sig),
    permanova_sig_pct = round(100 * sum(permanova_sig) / n(), 1),
    dispersion_sig_n = sum(dispersion_sig),
    dispersion_sig_pct = round(100 * sum(dispersion_sig) / n(), 1),
    confounded_n = sum(permanova_sig & dispersion_sig),
    confounded_pct = round(100 * sum(permanova_sig & dispersion_sig) / n(), 1)
  )

cat("\nTo report in your Methods section:\n\n")
cat(sprintf("\"We first applied PERMANOVA (adonis2) to test for host-type effects\n"))
cat(sprintf("on strain genetic distance matrices. However, initial analysis revealed\n"))
cat(sprintf("heterogeneity of multivariate dispersions in %d SGBs (%.1f%%), which can\n",
            stats_for_methods$dispersion_sig_n,
            stats_for_methods$dispersion_sig_pct))
cat(sprintf("confound location-based tests (n=%d SGBs with both location AND dispersion\n", 
            stats_for_methods$confounded_n))
cat(sprintf("effects significant). Accordingly, we employed Multi-Response Permutation\n"))
cat(sprintf("Procedure (MRPP), which tests within-group agreement directly without\n"))
cat(sprintf("assumptions about dispersion homogeneity. MRPP is more robust for detecting\n"))
cat(sprintf("host-specific strain clustering when dispersion heterogeneity is present.\"\n\n"))

# ============================================================================
# 7. Export summary table
# ============================================================================
write.csv(
  disp_summary %>% select(SGB, p_value, perm_disp_p, category),
  "../data/processed/dispersion_analysis_summary.csv",
  row.names = FALSE
)

cat("✓ Summary table saved: ../data/processed/dispersion_analysis_summary.csv\n")
cat("✓ Figures saved:\n")
cat("  - ../figures/dispersion_analysis_scatter.png\n")
cat("  - ../figures/dispersion_analysis_categories.png\n")
