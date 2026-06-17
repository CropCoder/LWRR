
### Background


Wheat is one of the most important cereal crops, with a global cultivation area exceeding 300 million acres. In recent years, factors such as global warming have lead to an increase in extreme weather events, which disrupt the prevalence patterns of crop diseases and pests, posing significant challenges to food security (Schulthess et al., 2022). Wheat yellow rust (YR) or stripe rust, caused by the biotrophic fungal *Puccinia striiformis* Westend f. sp. *tritici*, is one of the most critical diseases affecting wheat production worldwide, presenting a substantial threat to wheat safety and security. Breeding disease-resistant varieties is the most effective measure to control wheat yellow rust.

<img src="https://jewin.oss-cn-hangzhou.aliyuncs.com/image-20241219144142363.png" style="width: 100%;"/>

However, the discovery and utilization of effective resistance loci remain challenging in current wheat breeding practices. Comprehensive analysis of wheat stripe rust resistance loci at the population level is required to enhance flexibility in their application within breeding research (He et al., 2024). With the rapid advancements in genomics, the availability of multi-omics data on wheat has expanded significantly. Published online databases such as WheatOmics (Ma et al., 2021) and TGT (Chen et al., 2020) have accelerated the progress of wheat research. However, there is currently no publicly available, practical database specifically focused on wheat stripe rust resistance.

To address this gap, we have constructed a dynamic landscape of wheat yellow rust resistance loci to provide a valuable reference for research in wheat disease resistance genetics and breeding. Based on cloud computing architecture, we have developed an interactive online platform (<https://wheat.dftianyi.com/>), freely accessible to wheat genetic and breeding researchers worldwide. This platform offers real-time query and analysis modules for wheat rust resistance loci, aiming to expedite the intelligent design of wheat breeding in the future.


### Usage method

The main functional modules of LWRR include: population genetic structure analysis, material information query, phenotype data analytics, GWAS result analysis, QTL information retrieval, disease resistance candidate gene analysis, etc., and provide online cloud tools to upload genotype and phenotype files to quickly complete candidate gene analysis. LWRR is designed with a dynamic responsive architecture, including 12 sub-menu pages (from population-level genetic analysis to individual-level phenotypic attributes, which is convenient for users to quickly browse). It has the characteristics of online access, easy use, dynamic interaction, and comprehensive . So that breeding researchers can quickly inquire about the change law of wheat rust resistance check point population level, the difference of QTL check point between different materials, and the online analysis of disease resistance candidate genes in the study, providing support for future wheat disease resistance design and breeding.

#### 1. Population genetic structure analysis
The "Population" module provides information on material sources and population structure, as well as comparison and analysis between different breeding groups. Through Structure analysis of population genetic composition, users can select different K values to view specific results, and can zoom the horizontal axis to view the results of the specified sample. The mouse click will display the information of the corresponding sample in real time. In addition, PCA interactive 3D query of different subpopulations and different breeding groups is provided, which is convenient for obtaining population characteristics and structural grouping information. In order to facilitate the study of selective domestication patterns and genetic characteristics between different subpopulations, we calculated the results of Pi, Fst, TajimD and other results of different breeding groups and farmers at the genome level, and provided a dynamic query function. Users can enter any chromosome region to query the corresponding detailed data. We conducted statistical analysis of the four breeding groups, and displayed them according to the source region, breeding age, and population structure, so that users can easily understand the characteristics and information of the breeding groups.

#### 2. Sample information query
The "sample" module provides information and attribute queries for individual samples, as well as the QTL status of embroidery resistance they contain. When the user enters a material number or name, the page will display the material's attribute information and QTL distribution, such as querying the "S0073" sample. The page provides the disease resistance of the sample under different phenotypic conditions, and shows the presence of different QTLs in the material, as well as the allele types with excellent disease resistance. When the user clicks on the blue QTL hyperlinke, it will automatically jump to the corresponding QTL information interface. Through the panorama at the full chromosome level, it can quickly find which QTLs are potential key check points.


#### 3. Phenotype data analytics
The "Phenotype" module provides statistical analysis of phenotype information of different materials. Generally speaking, the resistance of wheat to stripe rust can be divided into two types: seedling stage and adult stage. The resistance at seedling stage is specific to small species. Therefore, this module provides phenotype analysis of different physiological races of wheat stripe rust. Users can choose to view the phenotype data of different physiological races at seedling stage. Through boxplot, they can quickly understand the material resistance differences of different breeding groups. According to the frequency distribution histogram, they can clearly understand the distribution trend of phenotype data. Heat map shows the specific values corresponding to different materials in different phenotypes.


#### 4. GWAS result analysis
The "GWAS" module provides the result query of genome-wide association analysis, including all the check points obtained by association analysis that have significant association points with phenotypes. The website provides Manhattan graphs and qq graphs obtained by each phenotype under MLM and FarmCPU models. In order to further facilitate users to obtain the results of an interval of interest, we use the online query function to provide more fine-grained functions. Users can select a phenotype, query the significant check points corresponding to a certain interval, and view the specific information of a significant SNP (physical precise location and effect value, etc.) by clicking the mouse. It is convenient for users to make full use of the significant check points for extended analysis. We label all the significance thresholds -log10 (P) greater than 3 The check points are provided in the form of tables, and when users find a GWAS candidate interval of interest, they can also perform in-depth analysis based on the check point information.


#### 5. QTL information retrieval
The "QTL" module provides a one-stop query and analysis of QTL check points for wheat resistance to stripe rust, including specific information such as the location interval of each QTL check point, and can query the proportion of different alleles at the population level, as well as the utilization differences of different ages and breeding groups . For example, search for "Yr30" (you can enter known gene numbers, QTL numbers, reported QTL numbers, etc., the server uses a global search engine), the page will show the QTL corresponding to the Yr30 gene and the change in the utilization trend of the gene since 1950, as well as the difference in utilization among the four breeding groups. The page automatically displays the phenotypic differences of different genotypes of alleles corresponding to the check point, and statistical analysis is carried out through T-test. The above calculation results are based on population-level variant check point genotype data and statistical analysis of phenotype data in multiple environments. Users can view the panorama of the distribution of disease-resistant QTL check points at the genome-wide level, and select a green area with the mouse to jump to the corresponding QTL to view. In addition, the page also shows the list of candidate genes in the corresponding interval of QTL, which is convenient for users to view candidate genes.


#### 6. Disease resistance candidate gene analysis
The "Tools" module integrates online analysis tools, allowing users to upload candidate genes for quick analysis by themselves. Based on the cloud computing service framework, users can upload VCF genotype files and Excel phenotype files of candidate genes (the tool provides sample data and file formats), and then calculate and analyze in real time in the LWRR cloud. One-stop gene mutation check point analysis, candidate gene association analysis, single marker check point significance statistical test, linkage imbalance analysis, gene haplotype analysis, etc. The analysis results can be quickly viewed on the page, or they can be saved locally through the download function provided by the tool. For security and confidentiality, all data is encrypted and transmitted through SSL, and each user session has a unique temporary random number. Uploaded files and results are stored in the temporary cache space, which is automatically deleted after the user exits the use.


-----


### Feedback on the issue

https://github.com/CropCoder/LWRR/issues

> If you have any questions or suggestions, please feel free to give feedback on the above website.

- Technology:  Jiwen Zhao  (zhaojiwen@nwafu.edu.cn)
- Cooperation:  Jianhui Wu  (wujh@nwafu.edu.cn)
- Website: https://wheat.dftianyi.com/
- Github: https://github.com/CropCoder/LWRR