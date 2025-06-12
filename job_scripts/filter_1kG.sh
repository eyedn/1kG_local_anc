#!/bin/bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           filter_1kG.sh
###############################################################################

#SBATCH --job-name=fltr1kG
#SBATCH --array=1-22
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=01:00:00
#SBATCH --partition=qcbr
#SBATCH --account=jazlynmo_738
#SBATCH --nodes=1
#SBATCH --output=/home1/karatas/logs/slurm.%A_%a.%x.out
#SBATCH --error=/home1/karatas/logs/slurm.%A_%a.%x.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=karatas@usc.edu

source ~/.bashrc
module purge
module load gcc/13.3.0 htslib/1.19.1 bcftools/1.19

CHR=${SLURM_ARRAY_TASK_ID}
DIR="${SCRATCH}/1000GenomeNYGC_hg38_aydin"
INFILE=${DIR}/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${CHR}.filtered.shapeit2-duohmm-phased.vcf.gz
OUTFILE=${DIR}/CCDG_14151_B01_GRM_WGS_2020-08-05_chr${CHR}.filtered.shapeit2-duohmm-phased.nodupmarkers.snps.vcf.gz

# filter for biallelic SNPs and remove duplicate markers
bcftools norm --rm-dup all --threads 4 "$INFILE" \
    | bcftools view --types snps --min-alleles 2 --max-alleles 2 --threads 4 \
    -Oz -o "$OUTFILE"

# index the output
tabix -p vcf "$OUTFILE"
