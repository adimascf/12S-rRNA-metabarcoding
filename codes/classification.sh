#!/usr/bin/bash

set -e
set -u
set -o pipefail

eval "$(conda shell.bash hook)"
conda activate qiime2-2022.11

mkdir -p $2

qiime feature-classifier classify-consensus-blast \
  --i-query $1/representative-sequences-dn-99.qza \
  --i-reference-reads mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep.qza \
  --i-reference-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep-formatted.qza \
  --p-perc-identity $3 \
  --p-min-consensus $4 \
  --o-classification $2/classification.qza \
  --o-search-results $2/search_results.qza


qiime metadata tabulate \
  --m-input-file $2/classification.qza \
  --o-visualization $2/classification.qzv

qiime metadata tabulate \
  --m-input-file $2/search_results.qza \
  --o-visualization $2/search_results.qzv

qiime krona collapse-and-plot \
  --i-table $1/table-dn-99.qza \
  --i-taxonomy $2/classification.qza \
  --p-level 7 \
  --o-krona-plot data/processed_data/qiime2-files/12s_krona.qzv

qiime tools export \
  --input-path $2/classification.qza \
  --output-path $2/

awk -v OFS="\t" -v FS="\t" '{print $1, $2}' $2/taxonomy.tsv > \
  $2/classification-no-consensus.tsv
rm $2/taxonomy.tsv

qiime tools import \
  --type 'FeatureData[Taxonomy]' \
  --input-path $2/classification-no-consensus.tsv \
  --output-path $2/classification-no-consensus.qza