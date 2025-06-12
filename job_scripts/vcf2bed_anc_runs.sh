#!/usr/bin/env bash

###############################################################################
#           Aydin Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           vcf2bed_anc_runs.sh
###############################################################################

#SBATCH --array=1-22
#SBATCH --cpus-per-task=1
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
module load gcc/13.3.0 bcftools/1.19 r/4.5.0

# define paths/vars
LOCAL_ANC="${JM1KG}/LocalAncestryFLARE"
POP="$1"
CHR="$SLURM_ARRAY_TASK_ID"

VCF="${LOCAL_ANC}/${POP}_local_ancestry_chr${CHR}.anc.vcf.gz"
mkdir -p "$SCRATCH/LocalAncestryFLARE_anc_tables"
ANC_POS="${SCRATCH}/LocalAncestryFLARE_anc_tables/${POP}_chr${CHR}_anc_pos.tsv.gz"
ANC_RUNS="${SCRATCH}/LocalAncestryFLARE_anc_tables/${POP}_chr${CHR}_anc_runs.bed.gz"

# build ancestry table of each position from vcf
date
echo "vcf2bed_anc_runs: creating table for $POP on chr$CHR"

samples=( $(bcftools query -l "$VCF") )
header="POS"
for s in "${samples[@]}"; do
    header+="\t${s}_AN1\t${s}_AN2"
done
(echo -e "$header"; bcftools query -f '%POS[\t%AN1\t%AN2]\n' "$VCF") \
    | gzip > "$ANC_POS"

# convert ancestry table to bed
date
echo "vcf2bed_anc_runs: generating bed of ancestral runs for $POP on chr$CHR"
Rscript "${JMPROJ2ME}/1kG_local_anc/job_scripts_anc_table2bed.R" \
    "$ANC_POS" "$ANC_RUNS"
