<!-- markdownlint-disable MD033 MD041 -->

<p align="center">
  <img src="www/logo.png" alt="LWRR Logo" width="200"/>
</p>


<h1 align="center">LWRR — Landscape of Wheat Rust Resistance</h1>

<p align="center">
  <strong>A comprehensive genomic database and online analysis platform for wheat stripe rust resistance</strong>
</p>

<p align="center">
  <a href="https://wheat.dftianyi.com/">
    <img src="https://img.shields.io/badge/Website-wheat.dftianyi.com-1289a7?style=flat-square" alt="Website"/>
  </a>
  <a href="https://github.com/CropCoder/LWRR">
    <img src="https://img.shields.io/badge/GitHub-CropCoder/LWRR-181717?style=flat-square&logo=github" alt="GitHub"/>
  </a>
  <img src="https://img.shields.io/badge/Version-4.0-brightgreen?style=flat-square" alt="Version"/>
  <img src="https://img.shields.io/badge/License-TBD-lightgrey?style=flat-square" alt="License"/>
  <img src="https://img.shields.io/badge/Made%20with-R%20Shiny-276DC3?style=flat-square&logo=r" alt="R Shiny"/>
</p>

---

<img width="1304" height="654" alt="image" src="https://github.com/user-attachments/assets/c3021c6f-5314-4a38-a148-b6a88206d482" />
https://doi.org/10.1007/s44154-025-00232-x



## 📖 Table of Contents

- [Introduction](#introduction)
- [Citation](#citation)
- [Features](#features)
- [Online Analysis Tools](#online-analysis-tools)
- [Architecture](#architecture)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Data Resources](#data-resources)
- [Contact & Support](#contact--support)
- [Acknowledgments](#acknowledgments)

---

## Introduction

Wheat stripe rust (yellow rust), caused by *Puccinia striiformis* f. sp. *tritici* (*Pst*), is one of the most devastating diseases threatening global wheat production and food security. Breeding disease-resistant varieties is the most effective and environmentally sustainable control strategy.

**LWRR (Landscape of Wheat Rust Resistance)** is an integrated genomic database and interactive online platform that systematically characterizes stripe rust resistance loci at the population level. Built upon a cloud-based R Shiny architecture, LWRR centralizes multi-omics data — including whole-genome resequencing, population genetics, GWAS, QTL mapping, and gene expression — for **2,191** wheat accessions across major Chinese breeding programs, spanning over 70 years of breeding history.

The platform provides real-time querying, visualization, and cloud-based candidate gene analysis, enabling researchers and breeders to explore resistance allele dynamics, population-level utilization patterns, and functional genic variation — all through an intuitive web interface.

> 🚀 Live site: [https://wheat.dftianyi.com/](https://wheat.dftianyi.com/)

---

## Citation

If you use LWRR in your research, please cite:

> **Wu J., Ma S., Niu J., Sun W., Dong H., Zheng S., Zhao J., et al.** (2025). Genomics-guided landscape unlocks superior alleles and genes for yellow rust resistance in wheat.

> **Zhao J., Dong H., Han J., Ou J., Chen T., Wang Y., Liu S., et al.** (2025). LWRR: Landscape of Wheat Rust Resistance towards practical breeding design.

---

## Features

### 🧬 Population Genetics
- **Population structure analysis** with STRUCTURE across multiple K values
- **Interactive 3D PCA** plots by subpopulation and breeding group
- **Genome-wide selection scans** — nucleotide diversity (π), F<sub>ST</sub>, and Tajima's D — with dynamic chromosomal-range queries
- Spatiotemporal distribution of breeding materials by geographic origin, release decade, and population assignment

### 🌾 Sample & Germplasm Explorer
- Searchable catalog of 2,191 wheat accessions by accession ID, Chinese name, or English name
- Per-sample QTL allele profiles with superior-allele highlighting
- Multi-environment phenotype summaries with disease reaction classification
- One-click navigation from sample QTLs to detailed QTL pages

### 📊 Phenotype Analytics
- Seedling-stage race-specific resistance profiles across multiple *Pst* races
- Adult-plant resistance (APR) phenotype distributions
- Interactive boxplots, frequency histograms, and heatmaps stratified by breeding group

### 🔬 GWAS Results
- Manhattan and QQ plots for all traits under **MLM** and **FarmCPU** models
- Chromosome-interval-based significance lookup with per-SNP details (position, effect, P-value)
- Downloadable tables of all suggestive and significant associations (−log<sub>10</sub>*P* > 3)

### 🧭 QTL Atlas
- Comprehensive catalog of published and novel YR resistance QTLs with physical intervals
- Population-level allele frequency spectra for each QTL
- Temporal utilization trends (1950–present) and breeding-group differentiation
- Allelic phenotypic effect sizes with T-test statistics in multiple environments
- Genome-wide QTL panorama with interactive region zoom
- Candidate gene lists within QTL intervals

### 🧬 Gene Information
- Disease resistance gene annotations
- Tissue/stress expression profiles (TPM) across RNA-seq datasets
- Gene structure visualization

---

## Online Analysis Tools

LWRR provides a suite of cloud-based analysis tools accessible directly from the browser:

| Tool | Description | Input | Output |
|---|---|---|---|
| **SGAT** (Smart Gene Analysis Toolkit) | End-to-end candidate-gene association analysis with rMVP engine | VCF + phenotype table | GWAS results, Manhattan plot, QQ plot, significance table |
| **Single Marker Analysis** | SNP-level association testing | VCF + phenotype table | Per-variant P-values, bar plot, Excel report |
| **Gene Haplotype Analysis** | Haplotype block clustering and phenotype association | VCF + phenotype table | Heatmap, haplotype cluster membership, boxplot with significance tests |
| **LD Block Visualization** | Pairwise linkage disequilibrium display | VCF | SVG LD heatmap, LD block coordinates |

> 🔒 **Security**: All uploaded data is transmitted via SSL/TLS encryption. Each user session receives a unique temporary identifier; uploaded files and intermediate results are stored in ephemeral cache and purged upon session termination.



**Key dependencies:**

| Layer | Technologies |
|---|---|
| **Frontend** | R Shiny, Bootstrap 4 (bslib), shinyWidgets, shinyjs |
| **Visualization** | ggplot2, plotly, echarts4r, pheatmap, chromoMap, DT, reactable |
| **Computation** | rMVP, vcfR, data.table, tidyverse, parallel |
| **Data** | SQLite (DBI + RSQLite), RDS, vroom |
| **External** | bcftools, LDBlockShow, Python (single-marker analysis) |
| **Infrastructure** | Shiny Server, Alibaba Cloud OSS, nginx, SSL/TLS |

---

## Getting Started

### Prerequisites

- **R** ≥ 4.2
- **Python** ≥ 3.8 (for single-marker analysis)
- **bcftools** ≥ 1.21
- **LDBlockShow** ≥ 1.40
- **SQLite** database file (`SQL_DataBase.db`)
- Preprocessed data files under `3_Data/` (RDS, CSV, VCF)

### Installation

```bash
# Clone the repository
git clone https://github.com/CropCoder/LWRR.git
cd LWRR

# Install R dependencies
R -e 'install.packages(c(
  "shiny", "bslib", "shinyWidgets", "shinyjs", "shinyalert",
  "ggplot2", "plotly", "echarts4r", "pheatmap", "DT", "reactable",
  "tidyverse", "data.table", "vcfR", "rMVP", "vroom",
  "DBI", "RSQLite", "openxlsx", "chromoMap", "ggpubr",
  "markdown", "jsonlite", "httr", "waiter", "shinycssloaders"
))'

# Set up external tools (bcftools, LDBlockShow)
# Place built binaries under build/bcftools-1.21/ and build/LDBlockShow-1.40/
```

### Configuration

1. Edit `2_Set/PATH.R` to set paths and developer info.
2. Ensure `SQL_DataBase.db` and all `3_Data/` files are in place.
3. Review `global.R` for runtime settings (e.g., max upload size, host URL).

### Launch

```bash
R -e 'shiny::runApp(port = 3838, host = "0.0.0.0")'
```

Or use Shiny Server for production deployment.

---

## Project Structure

```
LWRR/
├── app.R                    # Shiny app entry point (UI + server)
├── global.R                 # Global environment: packages, data, functions
├── SQL_DataBase.db          # SQLite database (not tracked)
├── 1_System/                # System utilities & data preprocessing
│   ├── Data_Prepare_to_RDS.R
│   ├── Data_GWAS.R
│   ├── Data_SQL_Mange.R
│   └── DataForChrmap.R
├── 2_Set/                   # Configuration files
│   ├── PATH.R
│   └── Color.R
├── 3_Data/                  # Preprocessed datasets (RDS, CSV, VCF)
├── 4_Page/                  # Shiny UI & server modules (12 pages)
│   ├── mod_home.R
│   ├── mod_population.R
│   ├── mod_sample.R
│   ├── mod_Trait.R
│   ├── mod_GWAS.R
│   ├── mod_QTL.R
│   ├── mod_Gene.R
│   ├── mod_tools.R
│   ├── mod_download.R
│   ├── mod_References.R
│   ├── mod_About.R
│   └── mod_use.R
├── 5_Function/              # Reusable analysis & helper functions
│   ├── run_singlemark.R
│   ├── run_GeneHAP.R
│   ├── run_LDBlock.R
│   ├── SGAT_init.R
│   ├── SGAT_rMVP.R
│   ├── get_search_gene_name.R
│   ├── get_home_global_search.R
│   └── ...
├── 6_Script/                # Standalone analysis pipelines
│   ├── pipline_SGAT.R
│   ├── pipline_singleMarker.R
│   ├── pipline_GeneHAP.R
│   ├── pipline_ResultRebuild.R
│   ├── single.marker.analysis.py
│   ├── app_send_email.R
│   └── get_vcf_fromWGS.R
├── build/                   # External binary tools
│   ├── bcftools-1.21/
│   └── LDBlockShow-1.40/
└── www/                     # Static assets
    ├── styles.css
    ├── LWDR.js
    ├── fig/                 # Images, logos, favicon
    ├── md/                  # Markdown content (about, usage)
    └── html/                # HTML include files
```

---

## Data Resources

LWRR integrates the following core datasets:

- **2,191 wheat accessions** from four major Chinese breeding programs (CK, YR, YS, YHR)
- **Genome-wide SNP genotypes** called from whole-genome resequencing
- **Multi-environment stripe rust phenotyping** across seedling-stage races and adult-plant field trials
- **Published and novel YR QTLs** curated from literature and population-level GWAS
- **Gene expression (TPM)** profiles across developmental stages and stress conditions
- **Reference genome:** Chinese Spring (IWGSC RefSeq v2.1)

---

## Contact & Support

| Role | Name | Email |
|---|---|---|
| **Technical Lead** | Jiwen Zhao | [zhaojiwen@nwafu.edu.cn](mailto:zhaojiwen@nwafu.edu.cn) |
| **Collaboration** | Jianhui Wu | [wujh@nwafu.edu.cn](mailto:wujh@nwafu.edu.cn) |

- 🐛 **Bug reports & feature requests:** [GitHub Issues](https://github.com/CropCoder/LWRR/issues)
- 🌐 **Website:** [https://wheat.dftianyi.com/](https://wheat.dftianyi.com/)
- 🏫 **Institution:** College of Agronomy, Northwest A&F University (NWAFU), Yangling, Shaanxi, China

---

## Acknowledgments

This work is supported by the College of Agronomy, Northwest A&F University and the State Key Laboratory of Crop Stress Resistance and High-Efficiency Production. We thank our colleagues at WheatOmics, TGT, and wGRN for their collaborative spirit in advancing wheat genomics research.

**Related projects:**
- [TGT](http://wheat.cau.edu.cn/TGT/) — Triticeae Gene Tribe
- [wGRN](http://wheat.cau.edu.cn/wGRN/) — Wheat Gene Regulatory Network
- [WheatOmics](http://wheatomics.sdau.edu.cn/) — Wheat Multi-Omics Database
