import pandas as pd
import yaml
from pathlib import Path
from utils import snakemake_utils

# Define config and input and output directories
BASE_DIR = Path(workflow.basedir)
configfile: BASE_DIR/"config/config.yaml"

IMG_PATH = f"{config['img_path']}"
OUTPUTS = f"{config['output']}"

##### load rules #####
include: "rules/preprocessing.smk"  # image preparation
include: "rules/segmentation.smk"  # nuclear segementation
include: "rules/tracking.smk"  # track linkning
include: "rules/signal_processing.smk"  # QA and signal processing


rule all:
    input:
        f"{OUTPUTS}config.yaml",
        f"{OUTPUTS}reports/raw_image_statistics.csv",
        
        
# put a copy of the chosen parameters in the output file        
rule copy_config:
    input:
        "config/config.yaml"
    output:
        f"{OUTPUTS}config.yaml"
    shell:
        "cp {input} {output}"
        
           
rule split_channels:
    input:
        "config/config.yaml",
    output:
        f"{OUTPUTS}reports/raw_image_statistics.csv"
    shell:
        "python scripts/split_channels.py {input} {output}"
 

# get the list of arrays from the directory - this is sloppy
output_dir =  f"{OUTPUTS}raw_channel_arrays/"
SAMPLES = snakemake_utils.get_sample_list(output_dir)


rule prepare:
    input:
        expand(f"raw_channel_arrays/{{sample}}.npy", sample=SAMPLES)
    output:
        f"{OUTPUTS}clean_arrays/{{sample}}.npy"
    threads:
        config['threads']
    shell:
        f"python scripts/prepare.py {input}"