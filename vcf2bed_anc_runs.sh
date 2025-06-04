#!/usr/bin/env bash

###############################################################################
#           Aydin Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           vcf2anc_table.sh
###############################################################################


#SBATCH --array=1-22
#SBATCH --cpus-per-task=1
#SBATCH --mem=80G
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
SCRATCH="/scratch1/karatas"
LocalAncestryFLARE="/project/jazlynmo_738/DataRepository/Human/1000GenomeNYGC_hg38/LocalAncestryFLARE"
pop="$1"
chr="$SLURM_ARRAY_TASK_ID"
vcf="${LocalAncestryFLARE}/${pop}_local_ancestry_chr${chr}.anc.vcf.gz"
mkdir -p "$SCRATCH/LocalAncestryFLARE_anc_tables"
anc_table="${SCRATCH}/LocalAncestryFLARE_anc_tables/${pop}_chr${chr}_anc_pos.tsv.gz"
anc_runs="${SCRATCH}/LocalAncestryFLARE_anc_tables/${pop}_chr${chr}_anc_runs.bed"

# build ancestry table of each position from vcf
date
echo "vcf2bed_anc_runs: creating table for $pop on  chr$chr"

samples=( $(bcftools query -l "$vcf") )
header="POS"
for s in "${samples[@]}"; do
    header+="\t${s}_AN1\t${s}_AN2"
done
(echo -e "$header"; bcftools query -f '%POS[\t%AN1\t%AN2]\n' "$vcf") \
    | gzip > "$anc_table"

# convert ancestry table to bed
date
echo "vcf2bed_anc_runs: generate bed of ancentral runs for $pop on  chr$chr"
Rscript anc_table2bed.R "$anc_table" "$anc_runs"