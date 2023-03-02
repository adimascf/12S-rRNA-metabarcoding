configfile: 'config.yaml'

print(type(config))
print(config)

## Inputs
fastqs_path = config['input']['fastqs_path']
metadata_path = config['input']['metadata']
project_name = config['input']['project_name']

if config['params']['preprocessing']['pair_end'] == 1:
    pass
elif config['params']['preprocessing']['pair_end'] == 0:
    fastp_script = "codes/fastp_qc.sh"
    preprocessing_script = "codes/preprocessing.sh"

# Settings
multiqc_name = config['params']['report_name']['multiqc_report_name']
primer_length = config['params']['preprocessing']['primer_length']
threshold = config['params']['preprocessing']['num_samples'] * config['params']['preprocessing']['reads_threshold']
pident = config['params']['classification']['pident']
min_cons = config['params']['classification']['min_consensus']
group_by = config['params']['krona_chart']['group_by']

# Outputs
rel_abund_report_name = "reports/" + project_name + ".xlsx"
krona_report_name = "reports/" + "krona_" + project_name +".html"
krona_title = "".join(krona_report_name.split('/')[1:])
print(threshold)

## Main rules definitions ###
rule run_fastp_preprocessing:
    input:
        script = fastp_script,
        input_path = fastqs_path
    params:
        output_path = "data/processed_data/",
        title = multiqc_name,
        output_report = "reports/"
    output:
        directory("data/processed_data/fastqs"),
        "reports/" + multiqc_name + "_multiqc_report" + ".html"
    shell:
        """
        {input.script} {input.input_path} {params.output_path} {params.output_report} {params.title}
        """

rule run_preprocessing:
    input:
        script = preprocessing_script,
        input_path = "data/processed_data/fastqs",
        metadata_path = metadata_path
    params:
        output_dir = "data/processed_data/qiime2-files/DADA2_denoising_output/",
        primer_length = primer_length,
        threshold = threshold
    output:
        directory("data/processed_data/qiime2-files/DADA2_denoising_output/"),
        "data/processed_data/qiime2-files/DADA2_denoising_output/table-dn-99.qza",
        "data/processed_data/qiime2-files/DADA2_denoising_output/representative-sequences-dn-99.qza"
    shell:
        """
        {input.script} {input.input_path} {params.output_dir} {params.primer_length} \
        {params.threshold} {input.metadata_path}
        """

rule run_classification:
    input:
        script = "codes/classification.sh",
        denoise_outdir = "data/processed_data/qiime2-files/DADA2_denoising_output/"
    params:
        output_dir = "data/processed_data/qiime2-files/blast-classification/",
        pident = pident,
        min_cons = min_cons
    output:
        "data/processed_data/qiime2-files/blast-classification/classification-no-consensus.qza",
    shell:
        """
        {input.script} {input.denoise_outdir} {params.output_dir} {params.pident} {params.min_cons}
        """

rule run_create_krona:
    input:
        script = "codes/krona_chart.R",
        table = "data/processed_data/qiime2-files/DADA2_denoising_output/table-dn-99.qza",
        taxonomy = "data/processed_data/qiime2-files/blast-classification/classification-no-consensus.qza",
        metadata = metadata_path,
        repseqs = "data/processed_data/qiime2-files/DADA2_denoising_output/representative-sequences-dn-99.qza"
    params:
        title = krona_title,
        group_by = group_by
    output:
        krona_report_name
    shell:
        """
        eval "$(conda shell.bash hook)" && conda activate krona_env && \
        Rscript {input.script} {input.table} {input.taxonomy} {input.metadata} \
        {input.repseqs} {params.title} {params.group_by}
        """

rule run_relative_abundance:
    input:
        script = "codes/rel_abundance.R",
        taxonomy = "data/processed_data/qiime2-files/blast-classification/classification-no-consensus.qza",
        table = "data/processed_data/qiime2-files/DADA2_denoising_output/table-dn-99.qza",
        metadata = metadata_path
    params:
        output_file = rel_abund_report_name
    output:
        rel_abund_report_name
    shell:
        """
        Rscript {input.script} {input.taxonomy} {input.table} {input.metadata} {params.output_file}
        """
