library(ggplot2)
library(phyloseq)
library(tidyverse)
library(psadd)
library(microbiomeMarker)
library(qiime2R)

# setwd("\\\\wsl.localhost/Ubuntu-22.04/home/adimascf/pandu/herbal/")

args <- commandArgs(trailingOnly = TRUE)

table <- args[1]
taxonomy <- args[2]
metadata <- args[3]
repseqs <- args[4]
title <- args[5]
group <- args[6]

physeq_do <- import_qiime2(
  otu_qza = table,
  sam_tab = metadata,
  refseq_qza = repseqs,
  taxa_qza = taxonomy
)

group <- str_replace(group, "-", ".")
plot_krona(physeq_do, str_c("reports", title, sep="/"),  group, trim = F)

# table <- "../data-sefsqr/processed_data/qiime2-files/DADA2_denoising_output/table.qza"
# taxonomy <- "../data-sefsqr/processed_data/qiime2-files/blast-classification/classification.qza"
# metadata <- "../data-sefsqr/raw_data/12S-metadata.tsv"
# repseqs <- "../data-sefsqr/processed_data/qiime2-files/DADA2_denoising_output/representative-sequences.qza"

# physeq_do <- import_qiime2(
#   otu_qza = table,
#   sam_tab = metadata,
#   refseq_qza = repseqs,
# )
# 
# taxa_qiime2 <- read_qza(taxonomy)
# 
# taxa <- taxa_qiime2$data %>%
#     as.data.frame() %>%
#     tibble() %>%
#     rename_all(tolower) %>%
#     select(feature.id, taxon) %>%
    # separate(taxon,
    #          into=c("ingdom", "phylum", "class", "order", "family", "genus", "species"),
    #          sep="; ") %>%
#     mutate(
#         kingdom = str_replace(kingdom, "[kpcofgs]__", ""),
#         phylum = str_replace(phylum, "[kpcofgs]__", ""),
#         class = str_replace(class, "[kpcofgs]__", ""),
#         order = str_replace(order, "[kpcofgs]__", ""),
#         family = str_replace(family, "[kpcofgs]__", ""),
#         genus = str_replace(genus, "[kpcofgs]__", ""),
#         species = str_replace(species, "[kpcofgs]__", "")
#     ) %>% 
#     mutate(
#         species = str_c(genus, species, sep=" ")
#     ) %>%
#     # mutate(
#     #     phylum = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = phylum),
#     #     class = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = class),
#     #     order = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = order),
#     #     family = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = family),
#     #     genus = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = genus),
#     #     species = if_else(kingdom == "Unassigned",
#     #                      true = "Unassigned",
#     #                      false = species)
#     #     
#     # ) %>%
#     # mutate(
#     #     family = if_else(condition = is.na(family) | family == "NA",
#     #                         true = paste0(order, " Unclassified", sep=" "),
#     #                         false = family),
#     #     genus = if_else(condition = is.na(genus) | genus == "NA", 
#     #                        true = paste0(family, " Unclassified", sep=" "), 
#     #                        false = genus),
#     #     species = if_else(condition = is.na(species) | species == "NA", 
#     #                          true = paste0(genus, " Unclassified", sep=" "), 
#     #                          false = species)
    # ) %>%
#     select(-feature.id) %>%
#     as.matrix()
# # 
# # 
# taxtab <- tax_table(taxa)
# 
# taxa_names(taxtab) <- taxa_names(physeq_do)
# physeq_do_complete <- merge_phyloseq(physeq_do, taxtab)
# 
# plot_krona(physeq_do_complete, str_c("reports", title, sep="/"), "sample.id", trim = F)

# 



