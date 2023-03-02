library(tidyverse)
library(qiime2R)

args <- commandArgs(trailingOnly = TRUE)

input_file <- args[1]
output_file <- args[2]

# input_file <- "../mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza"
# output_file <- "../mammalian-12s-ref-seq/mammalian-12s-taxonomy-replacements.tsv"

taxonomy_table <- read_qza(input_file)
taxonomy_table$data %>%
    as.data.frame() %>%
    as_tibble() %>%
    select(Taxon) %>%
    rename(id = Taxon) %>%
    mutate(
        temp1 = str_replace_all(id, "\\s*[kpcofgs]__", "")
    ) %>%
    separate(temp1,
             into=c("kingdom", "phylum", "class", "order", "family", "genus", "species"),
             sep=";") %>%
    mutate(
        species = str_c(genus, species, sep = " ")
    ) %>%
    unite("replacements", kingdom:species, sep = ";") %>%
    distinct(.) %>%
    write_tsv(., output_file)
