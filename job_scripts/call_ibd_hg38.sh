#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           call_ibd_hg38.sh
###############################################################################

#SBATCH --array=1-22
#SBATCH --cpus-per-task=4
#SBATCH --mem=4G
#SBATCH --time=00:30:00
#SBATCH --partition=qcbr
#SBATCH --account=jazlynmo_738
#SBATCH --nodes=1
#SBATCH --output=/home1/karatas/logs/slurm.%A_%a.%x.out
#SBATCH --error=/home1/karatas/logs/slurm.%A_%a.%x.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=karatas@usc.edu

# setup environment
source ~/.bashrc
module purge
module load gcc/13.3.0 bcftools/1.19 htslib/1.19.1

# define paths/vars
POP="$1"
CHR="$SLURM_ARRAY_TASK_ID"

POP_DIR="${JM1KG}/FileInformation/pops"
IBD_DIR="${SCRATCH}/hap-ibd_hg38"
VCF_FILE="CCDG_14151_B01_GRM_WGS_2020-08-05_chr${CHR}.filtered.shapeit2-duohmm-phased.nodupmarkers.snps.vcf.gz"
VCF_PATH="${JM1KG}/vcfs/${VCF_FILE}"
OUT_VCF="${IBD_DIR}/${POP}_chr${CHR}.vcf.gz"
PLINK_MAP="/home1/karatas/references/plink.chr${CHR}.GRCh38.chr.map"

# create output directory
mkdir -p "$IBD_DIR"

# separate population from full panel
date
echo "call_ibd_hg38: isolate $POP on chr$CHR"
bcftools view -S "${POP_DIR}/${POP}_hg38.txt" "$VCF_PATH" \
        --threads 4 \
        -Oz -o "$OUT_VCF"
tabix -p vcf "$OUT_VCF"

# update env for hap-IBD
module load legacy/CentOS7 jdk/17.0.5

# call ibd with hap-IBD
date
echo "call_ibd_hg38: calling IBD of $POP on chr$CHR"
java -Xmx4G -jar ~/software/hap-ibd/hap-ibd.jar \
        nthreads=4 \
        gt="$OUT_VCF" \
        map="$PLINK_MAP" \
        out="${IBD_DIR}/${POP}_chr${CHR}"

# move intermediate files to sub-dir
mkdir -p "${IBD_DIR}/int"
mv "$OUT_VCF" "${OUT_VCF}.tbi" "${IBD_DIR}/int"
