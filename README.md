Snakemake workflow for analyzing the 12S rRNA barcoding sequencing data
================
2023-05-15

This Snakemake pipeline is built for processing raw Illumina
metabarcoding data, identifying species in the samples, and counting
abundance. It will give abundance report per taxon level in excel and
generate krona plot.

### Dependencies:

- [QIIME 2 release:
  2023.2](https://docs.qiime2.org/2023.2/install/native/)
- [snakemake v. 7.25.3](https://snakemake.readthedocs.io/en/stable/)
- `wget`
- R version 4.1.2 (2021-11-01)
  - `BiocManager` (v. 1.30.20)
  - `tidyverse` (v. 2.0.0)
  - `phyloseq` (v. 1.38.0)
  - `ggplot2` (v. 3.4.2)
  - `psadd` (v. 0.1.3))
  - `qiime2R` (v. 0.99.6)
  - `xlsx` (v. 0.6.5)
  - `remotes` (v. 2.4.2)
  - `rmarkdown` (v. 2.21)

### My computer

    ## R version 4.1.2 (2021-11-01)
    ## Platform: x86_64-pc-linux-gnu (64-bit)
    ## Running under: Ubuntu 22.04.2 LTS
    ## 
    ## Matrix products: default
    ## BLAS:   /usr/lib/x86_64-linux-gnu/blas/libblas.so.3.10.0
    ## LAPACK: /usr/lib/x86_64-linux-gnu/lapack/liblapack.so.3.10.0
    ## 
    ## locale:
    ##  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
    ##  [3] LC_TIME=id_ID.UTF-8        LC_COLLATE=en_US.UTF-8    
    ##  [5] LC_MONETARY=id_ID.UTF-8    LC_MESSAGES=en_US.UTF-8   
    ##  [7] LC_PAPER=id_ID.UTF-8       LC_NAME=C                 
    ##  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
    ## [11] LC_MEASUREMENT=id_ID.UTF-8 LC_IDENTIFICATION=C       
    ## 
    ## attached base packages:
    ## [1] stats     graphics  grDevices utils     datasets  methods   base     
    ## 
    ## other attached packages:
    ##  [1] rmarkdown_2.21  lubridate_1.9.2 forcats_1.0.0   stringr_1.5.0  
    ##  [5] dplyr_1.1.2     purrr_1.0.1     readr_2.1.4     tidyr_1.3.0    
    ##  [9] tibble_3.2.1    ggplot2_3.4.2   tidyverse_2.0.0
    ## 
    ## loaded via a namespace (and not attached):
    ##  [1] pillar_1.9.0     compiler_4.1.2   tools_4.1.2      digest_0.6.31   
    ##  [5] timechange_0.2.0 evaluate_0.21    lifecycle_1.0.3  gtable_0.3.3    
    ##  [9] pkgconfig_2.0.3  rlang_1.1.1      cli_3.6.1        rstudioapi_0.14 
    ## [13] yaml_2.3.7       xfun_0.39        fastmap_1.1.1    withr_2.5.0     
    ## [17] knitr_1.42       generics_0.1.3   vctrs_0.6.2      hms_1.1.3       
    ## [21] grid_4.1.2       tidyselect_1.2.0 glue_1.6.2       R6_2.5.1        
    ## [25] fansi_1.0.4      tzdb_0.4.0       magrittr_2.0.3   scales_1.2.1    
    ## [29] htmltools_0.5.5  colorspace_2.1-0 utf8_1.2.3       stringi_1.7.12  
    ## [33] munsell_0.5.0
