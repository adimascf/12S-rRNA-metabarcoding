#!/usr/bin/bash

set -e
set -u
set -o pipefail

eval "$(conda shell.bash hook)"

Rscript codes/tax-replacement.R mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza \
    mammalian-12s-ref-seq/mammalian-12s-taxonomy-replacements.tsv

conda activate qiime2-2022.11

qiime rescript edit-taxonomy \
    --i-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza \
    --m-replacement-map-file mammalian-12s-ref-seq/mammalian-12s-taxonomy-replacements.tsv \
    --m-replacement-map-column replacements \
    --o-edited-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep-formatted.qza