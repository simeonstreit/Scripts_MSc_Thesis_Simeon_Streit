# Master Thesis Simeon Streit - Scripts and Data for metagnomic data analysis

**NOTE:** This repository contains all scripts and files for analyzing and visualizing metagenomic data acquired during my master's thesis. The dataset includes samples from pig farmers, pigs, and their respective control groups.
This repository contains the public scripts, metadata, and processed outputs used to reproduce the main analyses from my master's thesis on metagenomic data from pig farmers, pigs, and control groups.

The full in-depth analysis, exploratory work, and any files that should remain local to IFIK are stored outside this GitHub repository.

## Repository Layout

- `code/` contains the analysis notebooks and scripts.
- `data/raw/` contains raw input data used by the scripts. Some of these files may be too large or sensitive for public sharing.
- `data/processed/` contains derived tables created during the analysis.
- `Metadata/` contains supporting metadata such as color codes and sample metadata.

## How To Use This Repository

1. Open the project in RStudio or Positron.
2. Restore the R environment if a lockfile is provided.
3. Place any required local-only input files in the expected paths.
4. Run the scripts in `code/` in the documented order for the analysis you want to reproduce.

## Reproducibility Notes

- This repository is designed to make the thesis results reproducible from the public files alone.
- If you want strict package version control, add an `renv.lock` file.
- `renv.lock` records the exact package versions used for the project, along with their sources and dependencies.
- It does not mean every package installed on your machine. It is a project snapshot of the packages that were actually used when the lockfile was created.

## Analysis Scripts

### Microbiome analysis

This group covers the main microbiome workflows in `code/`.

- `quality_control.qmd` checks the microbiome input data before downstream analyses.
- `microbiome_richness.qmd` calculates richness metrics from `data/raw/MF_SGB_abundance.txt` and `Metadata/metadata_silas.csv`.
- `microbiome_alpha_diversity.qmd` calculates alpha diversity from `data/raw/MF_SGB_abundance.txt`, `data/raw/MF_abundance.txt`, `Metadata/metadata_silas.csv`, and `Metadata/color_codes.yaml`.
- `microbiome_betadiversity.qmd` performs beta diversity / NMDS analyses from `data/raw/MF_SGB_percent.txt`, `Metadata/metadata_silas.csv`, and `Metadata/color_codes.yaml`.
- `microbiome_differential_abundance.qmd` performs differential abundance analysis from `data/raw/MF_SGB_abundance.txt`, `Metadata/metadata_silas.csv`, and `Metadata/color_codes.yaml`.
- `microbiome_vennplot_richness_filtering copy.qmd` creates the richness filtering / Venn plot workflow from `data/raw/MF_SGB_abundance.txt` and `metadata/metadata_samples.csv`.
- `Procrustes.qmd` and `mrpp_permanova.R` support ordination-based comparison and permutation testing for the microbiome analyses.

### Subspecies and strain analysis

This workflow focuses on strain- and subspecies-level distance matrix analysis.

- `sub-species_strains.qmd` reads the GD distance matrices from `data/raw/GD/`, combines them with `Metadata/metadata_silas.csv` and `Metadata/sgb_annotation.csv`, and writes processed results to `data/processed/GD/`.

### ARG analysis

This workflow covers the antibiotic resistance gene analysis.

- `ARG.qmd` uses the ARG count and feature tables in `data/rgi_combined/`, the mapping summary in `data/rgi_map_results/bam_stats.tsv`, and `Metadata/metadata_silas.csv`. It writes figures to `figures/` and summary outputs to `rgiresults/`.

---
Simeon Streit, 06.05.2026
