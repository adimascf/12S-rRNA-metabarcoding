#!/usr/bin/bash

set -e
set -u
set -o pipefail

eval "$(conda shell.bash hook)"
conda activate qiime2-2022.11

mkdir -p $2
mkdir -p $3

qiime tools import \
  --type 'SampleData[SequencesWithQuality]' \
  --input-path $1 \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path $2/single-end-12s.qza

qiime demux summarize --i-data data/processed/qiime2-files/single-end-12s.qza \
  --o-visualization data/processed/qiime2-files/single-end-12s.qzv

qiime dada2 denoise-single \
  --p-n-threads 4 \
  --i-demultiplexed-seqs data/processed/qiime2-files/single-end-12s.qza \
  --p-trim-left $4 \
  --p-trunc-len $7 \
  --o-table $3/table.qza \
  --o-representative-sequences $3/representative-sequences.qza \
  --o-denoising-stats $3/denoising-stats.qza \
  --verbose \
  &> DADA2_denoising.log


qiime feature-table filter-features \
  --i-table $3/table.qza \
  --p-min-frequency $5 \
  --o-filtered-table $3/filtered-table.qza

qiime feature-table filter-seqs \
  --i-data $3/representative-sequences.qza \
  --i-table $3/filtered-table.qza \
  --o-filtered-data $3/filtered-representative-sequences.qza

qiime vsearch cluster-features-de-novo \
  --i-table $3/filtered-table.qza \
  --i-sequences $3/filtered-representative-sequences.qza \
  --p-perc-identity 0.99 \
  --o-clustered-table $3/table.qza \
  --o-clustered-sequences $3/representative-sequences.qza

qiime metadata tabulate  \
  --m-input-file $3/denoising-stats.qza \
  --o-visualization $3/denoising-stats.qzv

qiime feature-table summarize \
  --i-table $3/table.qza \
  --o-visualization $3/table.qzv \
  --m-sample-metadata-file $6

qiime feature-table tabulate-seqs \
  --i-data $3/representative-sequences.qza \
  --o-visualization $3/representative-sequences.qzv
