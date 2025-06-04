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


#SBATCH --array=1-22%1
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=1:00:00
#SBATCH --partition=qcb
#SBATCH --nodes=1
#SBATCH --job-name=chranc
#SBATCH --output=/home1/karatas/job_out/slurm.%A_%a.%x.out
#SBATCH --error=/home1/karatas/job_err/slurm.%A_%a.%x.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=karatas@usc.edu


source ~/.bashrc
module purge
module load gcc/13.3.0 bcftools/1.19

SCRATCH="/scratch1/karatas"
LocalAncestryFLARE="/project/jazlynmo_738/DataRepository/Human/1000GenomeNYGC_hg38/LocalAncestryFLARE"
pop=$1
chr=$SLURM_ARRAY_TASK_ID
vcf="${LocalAncestryFLARE}/${pop}_local_ancestry_chr${chr}.anc.vcf.gz"
mkdir -p "$SCRATCH/LocalAncestryFLARE_anc_tables"
output="${SCRATCH}/${pop}_chr${chr}.tsv"


# build tsv from vcf
date
echo "vcf2anc_table: starting population $pop on chromosome $chr"

samples=( $(bcftools query -l "$vcf") )
header="POS"
for s in "${samples[@]}"; do
    header+="\t${s}_AN1\t${s}_AN2"
done

(echo -e "$header"; bcftools query -f '%POS[\t%AN1\t%AN2]\n' "$vcf") \
    | gzip > "${output}.gz"
date

echo "vcf2anc_table: finsihed population $pop on chromosome $chr"
