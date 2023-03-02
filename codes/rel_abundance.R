# setwd("\\\\wsl.localhost/Ubuntu-22.04/home/adimascf/pandu/herbal/")

library(ggplot2)
library(phyloseq)
library(tidyverse)
library(psadd)
library(qiime2R)
library(xlsx)

args <- commandArgs(trailingOnly = TRUE)

taxonomy_qiime2 <- args[1]
feature_table_qiime2 <- args[2]
metadata <- args[3]
output_path <- args[4]

# 
# taxonomy_qiime2 <- "../data-sefsqr/processed_data/qiime2-files/blast-classification-formatted-trimleft18bp/classification-no-consensus.qza"
# feature_table_qiime2 <- "../data-sefsqr/processed_data/qiime2-files/DADA2_denoising_output-trimleft18bp/table-dn-99.qza"
# metadata <- "../data-sefsqr/raw_data/12S-metadata.tsv"
# output_path <- "../reports/cluster-12Srelative_abundance_trim18p.xlsx"

sample_names <- read_tsv(metadata) %>%
    pull(., `sample-id`) 

taxonomy <- read_qza(taxonomy_qiime2)$data %>%
    tibble() %>%
    rename_all(tolower) %>%
    select(feature.id, taxon) %>%
    separate(taxon,
             into=c("subkingdom", "phylum", "class", "order", "family", "genus", "species"),
             sep=";") %>%
    mutate(family = if_else(condition = is.na(family) | family == "NA",
                            true = paste0(order, " Unclassified", sep=""),
                            false = family),
           genus = if_else(condition = is.na(genus) | genus == "NA", 
                           true = paste0(family, " Unclassified", sep=""), 
                           false = genus),
           species = if_else(condition = is.na(species) | species == "NA", 
                             true = paste0(genus, " Unclassified", sep=""), 
                             false = species),
           class = if_else(class == "NA",
                           true = "Others Streptophyta",
                           false = class),
           class = if_else(condition = is.na(class),
                          true = paste0(phylum, " Unclassified", sep=""),
                          false = class))

table <- read_qza(feature_table_qiime2)

table <- table$data %>%
    as.data.frame()

table$feature.id <- row.names(table)

feature_rel_abund <- table %>%
    as_tibble(.) %>%
    inner_join(taxonomy, ., by="feature.id") %>%
    pivot_longer(sample_names,
                 names_to = "sample_id", values_to = "count") %>%
    group_by(sample_id) %>%
    mutate(rel_abund = count / sum(count)) %>%
    ungroup() %>%
    pivot_longer(c("subkingdom", "phylum", "class", "order", "family", "genus", "species", "feature.id"),
                 names_to="level",
                 values_to="taxon")


total_features <- table %>%
    as_tibble(.) %>%
    inner_join(taxonomy, ., by="feature.id") %>%
    pivot_longer(sample_names,
                 names_to = "sample_id", values_to = "count") %>%
    group_by(sample_id) %>%
    summarize(total = sum(count), .groups = "drop") %>%
    pivot_wider(names_from = sample_id, values_from = total) %>%
    cbind(tibble(taxon = "Total Features"), .)


# 
# feature_rel_abund %>%
#     filter(level == "order") %>%
#     group_by(sample_id, taxon) %>%
#     summarize(rel_abund = sum(rel_abund),
#               .groups = "drop") %>%
#     pivot_wider(names_from = sample_id, values_from = rel_abund)


level_rel_abund <- function(tax_level, f_rel_abund) {
    f_rel_abund %>%
        filter(level == tax_level) %>%
        group_by(sample_id, taxon) %>%
        summarize(rel_abund = sum(rel_abund)*100,
                  .groups = "drop") %>%
        mutate(rel_abund = round(rel_abund, digits = 2)) %>%
        pivot_wider(names_from = sample_id, values_from = rel_abund)
}

species_rel_abund <- level_rel_abund("species", feature_rel_abund) %>% 
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
genus_rel_abund <- level_rel_abund("genus", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
family_rel_abund <- level_rel_abund("family", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
order_rel_abund <- level_rel_abund("order", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
class_rel_abund <- level_rel_abund("class", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
phylum_rel_abund <- level_rel_abund("phylum", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)
subkingdom_rel_abund <- level_rel_abund("subkingdom", feature_rel_abund) %>%
    mutate(taxon = paste0(taxon, " (%)")) %>%
    bind_rows(., total_features)


if (file.exists(output_path)) {
    #Delete file if it exists
    print("Deleting existing file...")
    file.remove(output_path)
}

print("Writing result onto file...")
file.create(output_path)

write.xlsx(as.data.frame(species_rel_abund), file=output_path, sheetName="species", row.names=FALSE)
write.xlsx(as.data.frame(genus_rel_abund), file=output_path, sheetName="genus", append=TRUE, row.names=FALSE)
write.xlsx(as.data.frame(family_rel_abund), file=output_path, sheetName="family", append=TRUE, row.names=FALSE)
write.xlsx(as.data.frame(order_rel_abund), file=output_path, sheetName="order", append=TRUE, row.names=FALSE)
write.xlsx(as.data.frame(class_rel_abund), file=output_path, sheetName="class", append=TRUE, row.names=FALSE)
write.xlsx(as.data.frame(phylum_rel_abund), file=output_path, sheetName="phylum", append=TRUE, row.names=FALSE)
write.xlsx(as.data.frame(subkingdom_rel_abund), file=output_path, sheetName="subkingdom", append=TRUE, row.names=FALSE)


# 
# 
# 
# 
# 
# # Testing workflow ----
# taxonomy_qiime2 <- "../data-sefsqr/processed_data/qiime2-files/blast-classification-formatted/classification-no-consensus.qza"
# feature_table_qiime2 <- "../data-sefsqr/processed_data/qiime2-files/DADA2_denoising_output/table.qza"
# metadata <- "../data-sefsqr/raw_data/12S-metadata.tsv"
# output_path <- "../reports/ITS2_herbal_relative_abundance.xlsx"
# 
# 
# sample_name <- read_tsv(metadata) %>%
#     pull(., `sample-id`)
# 
# taxonomy <- read_qza(taxonomy_qiime2)$data %>%
#     tibble() %>%
#     rename_all(tolower) %>%
#     select(feature.id, taxon) %>%
#     separate(taxon,
#              into=c("subkingdom", "phylum", "class", "order", "family", "genus", "species"),
#              sep=";") %>%
#     mutate(family = if_else(condition = is.na(family) | family == "NA",
#                             true = paste0(order, " Unclassified", sep=" "),
#                             false = family),
#            genus = if_else(condition = is.na(genus) | genus == "NA", 
#                            true = paste0(family, " Unclassified", sep=" "), 
#                            false = genus),
#            species = if_else(condition = is.na(species) | species == "NA", 
#                              true = paste0(genus, " Unclassified", sep=" "), 
#                              false = species),
#            class = if_else(class == "NA",
#                            true = "Others Streptophyta",
#                            false = class),
#            class = if_else(condition = is.na(class),
#                            true = paste0(phylum, " Unclassified", sep=" "),
#                            false = class))
# 
# table <- read_qza(feature_table_qiime2)
# 
# table <- table$data %>%
#     as.data.frame()
# 
# table$feature.id <- row.names(table)
# 
# feature_rel_abund <- table %>%
#     as_tibble(.) %>%
#     inner_join(taxonomy, ., by="feature.id") %>%
#     pivot_longer(sample_name,
#                  names_to = "sample_id", values_to = "count") %>%
#     group_by(sample_id) %>%
#     mutate(rel_abund = count / sum(count)) %>%
#     ungroup()
# 
# feature_rel_abund %>%
#     filter(., species == "Bos taurus") %>% View()
# 
# 
# 















































