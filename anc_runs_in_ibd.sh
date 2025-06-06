#!/usr/bin/env bash

###############################################################################
#           Aydin Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           anc_runs_in_ibd.sh
###############################################################################

#SBATCH --job-name=runs_ibd
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

# set up environment
source ~/.bashrc
module purge
module load gcc/13.3.0 bedtools2/2.31.1 

# define paths/variables
SCRATCH="/scratch1/karatas"
LocalAncestryFLARE_anc_tables="${SCRATCH}/LocalAncestryFLARE_anc_tables"
IBDSeq_hg38="/project/jazlynmo_738/DataRepository/Human/1000GenomeNYGC_hg38/IBDSeq_hg38"
LocalAncestryFLARE_int_IBDSeq_hg38="${SCRATCH}/LocalAncestryFLARE_int_IBDSeq_hg38"
pop=$(head -n "${SLURM_ARRAY_TASK_ID}" pops_in_LocalAncestryFlare.txt | tail -n 1 | xargs)

allChrom_runs="${LocalAncestryFLARE_anc_tables}/${pop}_allChroms_anc_runs.bed.gz"
ibd="${IBDSeq_hg38}/${pop}_allChroms.ibd"
ibd_bed="${LocalAncestryFLARE_int_IBDSeq_hg38}/${pop}_allChroms_ibd.bed.gz"
anc_runs_in_ibd="${LocalAncestryFLARE_int_IBDSeq_hg38}/${pop}_allChroms_anc_runs_in_ibd.bed.gz"

mkdir -p "$LocalAncestryFLARE_int_IBDSeq_hg38"

# combine and sort ancestral run bed files
date
echo "anc_runs_in_ibd: combining ancestral runs for all chromosomes of $pop"
zcat ${LocalAncestryFLARE_anc_tables}/${pop}_chr*_anc_runs.bed.gz \
    | bedtools sort -i - | gzip > "$allChrom_runs"

# convert and sort ibd file to bed
date
echo "anc_runs_in_ibd: converting $pop ibd file to bed format"
awk -F'\t' '{print $5"\t"$6"\t"$7"\t"$1"_"$3}' "$ibd" \
    | bedtools sort -i - | gzip > "$ibd_bed"

# intersect ancestral runs with ibd segments
# filter out rows where the ancestry sample is not in the IBD pair
date
echo "anc_runs_in_ibd: intersecting $pop anc. runs with ibd"
echo "anc_runs_in_ibd: filter out rows where the ancestry sample is not in the IBD pair"
bedtools intersect \
    -a "$ibd_bed" \
    -b "$allChrom_runs" \
    -wa -wb \
    | awk '{split($4, a, "_"); split($8, b, "_"); if (b[1] == a[1] || b[1] == a[2]) print;}' \
    | gzip > "$anc_runs_in_ibd"
