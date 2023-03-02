#!/usr/bin/bash

set -e
set -u
set -o pipefail

eval "$(conda shell.bash hook)"
conda activate qiime2-2022.11

mkdir -p $2

qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path $1 \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path data/processed_data/qiime2-files/single-end-12s.qza

qiime demux summarize --i-data data/processed_data/qiime2-files/single-end-12s.qza \
  --o-visualization data/processed_data/qiime2-files/single-end-12s.qzv

qiime dada2 denoise-single \
--p-n-threads 4 \
--i-demultiplexed-seqs data/processed_data/qiime2-files/single-end-12s.qza \
--p-trim-left $3 \
--p-trunc-len 135 \
--o-table $2/table.qza \
--o-representative-sequences $2/representative-sequences.qza \
--o-denoising-stats $2/denoising-stats.qza \
--verbose \
&> DADA2_denoising.log


qiime feature-table filter-features \
  --i-table $2/table.qza \
  --p-min-frequency $4 \
  --o-filtered-table $2/filtered-table.qza

qiime feature-table filter-seqs \
  --i-data $2/representative-sequences.qza \
  --i-table $2/filtered-table.qza \
  --o-filtered-data $2/filtered-representative-sequences.qza

qiime vsearch cluster-features-de-novo \
  --i-table $2/filtered-table.qza \
  --i-sequences $2/filtered-representative-sequences.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table $2/table-dn-99.qza \
  --o-clustered-sequences $2/representative-sequences-dn-99.qza

qiime metadata tabulate  \
  --m-input-file $2/denoising-stats.qza \
  --o-visualization $2/denoising-stats.qzv

qiime feature-table summarize \
--i-table $2/table-dn-99.qza \
--o-visualization $2/table-dn-99.qzv \
--m-sample-metadata-file $5


qiime feature-table tabulate-seqs \
--i-data $2/representative-sequences-dn-99.qza \
--o-visualization $2/representative-sequences-dn-99.qzv
