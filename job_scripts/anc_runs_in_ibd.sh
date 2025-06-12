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
LOCAL_ANC="${SCRATCH}/LocalAncestryFLARE_anc_tables"
IBD_HG38="${SCRATCH}/1000GenomeNYGC_hg38_aydin/hap-ibd_hg38"
LOCAL_ANC_INT_IBD_HG38="${SCRATCH}/LocalAncestryFLARE_int_hap-ibd_hg38"
POP=$(head -n "${SLURM_ARRAY_TASK_ID}" pops_in_LocalAncestryFlare.txt | tail -n 1 | xargs)

ALLCHROM_ANC="${LOCAL_ANC}/${POP}_allChroms_anc_runs.bed.gz"
ALLCHROM_IBD="${IBD_HG38}/${POP}_allChroms.ibd.gz"
IBD_BED="${LOCAL_ANC_INT_IBD_HG38}/${POP}_allChroms_ibd.bed.gz"
ANC_IN_IBD="${LOCAL_ANC_INT_IBD_HG38}/${POP}_allChroms_anc_in_ibd.bed.gz"

mkdir -p "$LOCAL_ANC_INT_IBD_HG38"

# combine and sort ancestral run bed files
date
echo "anc_runs_in_ibd: combining ancestral runs for all chromosomes of $POP"
zcat ${LOCAL_ANC}/${POP}_chr*_anc_runs.bed.gz \
    | bedtools sort -i - | gzip > "$ALLCHROM_ANC"

# combine all chromosome ibd files for this population
date
echo "anc_runs_in_ibd: combining indiv. chromosome ibd files of $POP"
zcat ${IBD_HG38}/${POP}_chr*.ibd.gz \
    | gzip > "$ALLCHROM_IBD"

# convert and sort ibd file to bed
date
echo "anc_runs_in_ibd: converting $POP ibd file to bed format"
zcat "$ALLCHROM_IBD" \
    | awk -F'\t' '{print $5"\t"$6"\t"$7"\t"$1"_AN"$2"_"$3"_AN"$4}'  \
    | bedtools sort -i - | gzip > "$IBD_BED"

# intersect ancestral runs with ibd segments
# filter out rows where the ancestry sample is not in the IBD pair
date
echo "anc_runs_in_ibd: intersecting $POP anc. runs with ibd"
echo "anc_runs_in_ibd: filter out rows where the ancestry sample is not in the IBD pair"
bedtools intersect \
    -a "$IBD_BED" \
    -b "$ALLCHROM_ANC" \
    -wa -wb \
    | awk '{
            split($4, ibd_parts, "_");
            split($8, anc_parts, "_");
            anc_id = anc_parts[1] "_" anc_parts[2];
            if ((ibd_parts[1] "_" ibd_parts[2] == anc_id) || (ibd_parts[3] "_" ibd_parts[4] == anc_id)) 
                print;
        }' \
    | gzip > "$ANC_IN_IBD"
