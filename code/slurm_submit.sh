#!/bin/bash

#SBATCH --mail-user=cstansbu@umich.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=36
#SBATCH --mem=80gb
#SBATCH --time=96:00:00
#SBATCH --account=indikar1
#SBATCH --partition=standard

threads=$1
snakemake --profile config/slurm -j $threads --latency-wait 90 -s workflow.smk 