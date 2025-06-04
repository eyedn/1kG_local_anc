#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           submit_vcf2bed_anc_runs.sh
###############################################################################

pops="/project/jazlynmo_738/aydin/pops_in_LocalAncestryFlare.txt"
for pop in $(cat "$pops"); do
    sbatch --job-name=${pop}anc vcf2bed_anc_runs.sh "$pop"
done
