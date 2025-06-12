#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           download_1kG.sh
###############################################################################

#SBATCH --job-name=down1kg
#SBATCH --array=1-22
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:30:00
#SBATCH --partition=qcbr
#SBATCH --account=jazlynmo_738
#SBATCH --nodes=1
#SBATCH --output=/home1/karatas/logs/slurm.%A_%a.%x.out
#SBATCH --error=/home1/karatas/logs/slurm.%A_%a.%x.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=karatas@usc.edu

source ~/.bashrc

# define paths/vars
BASE_URL="http://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20201028_3202_phased"
OUTDIR="${SCRATCH}/1000GenomeNYGC_hg38_aydin"
mkdir -p "$OUTDIR"

# download VCF and index
wget -P "$OUTDIR" "$BASE_URL/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${SLURM_ARRAY_TASK_ID}.filtered.shapeit2-duohmm-phased.vcf.gz"
wget -P "$OUTDIR" "$BASE_URL/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${SLURM_ARRAY_TASK_ID}.filtered.shapeit2-duohmm-phased.vcf.gz.tbi"
