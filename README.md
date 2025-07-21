# LWRR: Landscape of Wheat Rust Resistance towards practical breeding design

> An information-rich landscape for wheat rust resistance loci facilitating design breeding for resistance improvement A dynamic database with multiple functions for wheat design breeding of disease resistance

![image](https://github.com/user-attachments/assets/001a143d-ca0b-4658-b225-70496d467c4b)

## Introduction

The LWRR panel comprises a diverse and representative collection of wheat accessions from major wheat-growing regions worldwide, including 272 from Africa, 929 from Asia, 640 from Europe, 298 from the Americas, and 52 from Oceania. This panel includes 684 landraces and 1,507 cultivars, representing 70 years of breeding history (1950—2020). Based on distinct YR resistance profiles observed across regions, these cultivars were further classified into four BGs (BG1—BG4). The dataset includes seedling-stage resistance evaluations against 12 Pst races (Chinese Yellow Rust physiological race CYR17, CYR23, CYR29, CYR31, Sull-4, Sull-5, CYR32, CYR33, CYR34, V26/GS, V26/SC, and TSA-V5) and adult-plant-stage resistance assessments under 12 environmental conditions. Field trials were conducted in Yangling city (2019—2022) in Shaanxi Province; Jiangyou City (2019—2021) in Sichuan Province; Tianshui City (2019—2021) in Gansu Province; Chongqing City (2021); and Guiyang City (2021) in Guizhou Province.

## Method

During the development of LWRR, the R programming language (<https://www.R-project.org>) was used for data processing and website construction. The frontend was built using Shiny and Bootstrap, with dynamic interactive charts implemented via echarts4r, plotly, and JavaScript. Tabular data visualization was achieved using reactable and DT packages. For backend processing, the tidyverse package was used for file reading and standardized data processing, while the parallel package enabled parallel computing and high-concurrency optimization. The DBI package was used for database connection and query. Candidate gene association analyses were performed with the rMVP package (Yin et al. 2021). The ggideogram package was used for the visualization of the genome-wide QTL distribution maps. In the “Tool” module, bcftools and LDBlockShow (Dong et al. 2021) was used for background processing. The LWRR platform was developed on Ubuntu using Docker container technology and deployed on an Elastic Cloud Server to ensure accessibility and scalability.

### cite

Zhao, J., Dong, H., Han, J. et al. LWRR: Landscape of Wheat Rust Resistance towards practical breeding design. Stress Biology 5, 25 (2025).

### DOI

<https://doi.org/10.1007/s44154-025-00232-x>
