import pandas as pd
import yaml
from pathlib import Path

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
 
 
rule write_tiffs:
    input:
    output:
    shell: