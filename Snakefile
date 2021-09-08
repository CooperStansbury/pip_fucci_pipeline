import pandas as pd
import yaml
from pathlib import Path
from utils import snakemake_utils

# Define config and input and output directories
BASE_DIR = Path(workflow.basedir)
configfile: BASE_DIR/"config/config.yaml"

OUTPUTS = f"{config['output']}"
READS = f"{config['reads']}"
REFERENCE = f"{config['reference']}"
ASSEMBLY = f"{config['assembly']}"


##### load rules #####
include: "rules/alignment.smk"  # alignment rules
include: "rules/reporting.smk"  # coverage statistics
include: "rules/create_alignment_table.smk"  # build alignment table
include: "rules/create_aux_outputs.smk"  # build other outputs


rule all:
    input:
        f"{OUTPUTS}merged_sorted.bam",
        f"{OUTPUTS}config.yaml",
        f"{OUTPUTS}stats/merged_sorted_stats.txt",
        f"{OUTPUTS}stats/coverage_table.txt",
        f"{OUTPUTS}stats/samtools_coverage.txt",
        f"{OUTPUTS}stats/custom_coverage_table.csv",
        f"{OUTPUTS}tables/raw_alignment_table.csv",
        f"{OUTPUTS}tables/digested_fragments_table.csv",
        f"{OUTPUTS}tables/alignment_table_mapped.csv",
        f"{OUTPUTS}tables/alignment_table.csv",
        f"{OUTPUTS}tables/incidence_table.csv",
        
# put a copy of the chosen parameters in the output file        
rule copy_config:
    input:
        "config/config.yaml"
    output:
        f"{OUTPUTS}config.yaml"
    shell:
        "cp {input} {output}"
       