#!/usr/bin/bash

set -e
set -u
set -o pipefail

eval "$(conda shell.bash hook)"
conda activate qiime2-2022.11

mkdir -p mammalian-12s-ref-seq

echo "Build the 12S reference sequences for Mammalian"

echo "Donwloading Mammalian 12S rRNA sequences DB from NCBI... "
qiime rescript get-ncbi-data \
    --p-query "txid40674[ORGN] AND (12S[Title] OR 12S ribosomal RNA[Title] OR 12S rRNA[Title]) AND (mitochondrion[Filter] OR plastid[Filter]) NOT environmental sample[Title] NOT environmental samples[Title] NOT environmental[Title] NOT uncultured[Title] NOT unclassified[Title] NOT unidentified[Title] NOT unverified[Title]" \
    --p-n-jobs 4 \
    --o-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs.qza \
    --o-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax.qza \
    --verbose

echo "Dereplicating the reference sequences..."
qiime rescript dereplicate \
    --i-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs.qza \
    --i-taxa mammalian-12s-ref-seq/mammalia-12S-ref-tax.qza \
    --p-mode 'uniq' \
    --p-threads 4 \
    --p-rank-handles 'disable' \
    --o-dereplicated-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-derep.qza \
    --o-dereplicated-taxa mammalian-12s-ref-seq/mammalia-12S-ref-tax-derep.qza

echo "Filtering out low quality sequences..."
qiime rescript cull-seqs \
    --i-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-derep.qza \
    --p-n-jobs 4 \
    --p-num-degenerates 5 \
    --p-homopolymer-length 8 \
    --o-clean-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-cull.qza

echo "Filtering out too short and too long sequences..."
qiime rescript filter-seqs-length \
    --i-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-cull.qza \
    --p-global-min 200 \
    --p-global-max 1200 \
    --o-filtered-seqs mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep.qza \
    --o-discarded-seqs mammalian-12s-ref-seq/mammalia-12S-ref-seqs-discard.qza

echo "Evaluationg the reference DB..."
qiime rescript filter-taxa \
    --i-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax.qza \
    --m-ids-to-keep-file mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep.qza \
    --o-filtered-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza

qiime rescript evaluate-taxonomy \
    --i-taxonomies mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza \
    --o-taxonomy-stats mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep-eval.qzv

qiime metadata tabulate \
    --m-input-file mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza \
    --o-visualization mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qzv

qiime rescript evaluate-seqs \
    --i-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep.qza \
    --p-kmer-lengths 32 16 8 \
    --o-visualization mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep-eval.qzv

echo "Building and evaluating the classifier..."
qiime rescript evaluate-fit-classifier \
    --i-sequences mammalian-12s-ref-seq/mammalia-12S-ref-seqs-keep.qza \
    --i-taxonomy mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza \
    --p-n-jobs 2 \
    --o-classifier mammalian-12s-ref-seq/ncbi-12S-mammalia-refseqs-classifier.qza \
    --o-evaluation mammalian-12s-ref-seq/ncbi-12S-mammalia-refseqs-classifier-evaluation.qzv \
    --o-observed-taxonomy mammalian-12s-ref-seq/ncbi-12S-mammalia-refseqs-predicted-taxonomy.qza

qiime rescript evaluate-taxonomy \
  --i-taxonomies mammalian-12s-ref-seq/mammalia-12S-ref-tax-keep.qza mammalian-12s-ref-seq/ncbi-12S-mammalia-refseqs-predicted-taxonomy.qza \
  --p-labels ref-taxonomy predicted-taxonomy \
  --o-taxonomy-stats mammalian-12s-ref-seq/ref-taxonomy-evaluation.qzv

echo "Finish successfully!"