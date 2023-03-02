#!/usr/bin/bash

eval "$(conda shell.bash hook)"
conda activate quality_control


ls $1 | grep "_R1_001.fastq.gz" | sed 's/_R1_001.fastq.gz//' > file

mkdir -p $2/fastqs/

cat file | parallel --bar -j 2 \
        fastp -i $1/{}_R1_001.fastq.gz \
                -o $2/fastqs/{}_R1_001.fastq.gz \
                --json $2/{}.fastp.json

rm file
rm fastp.html

mkdir -p $3
multiqc --outdir $3 --title $4 $2/