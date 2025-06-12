#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           submit_call_ibd_hg38.sh
###############################################################################

POPS="pops.txt"
while read -r pop; do
    sbatch --job-name="${pop}ibd" job_scripts/call_ibd_hg38.sh "$pop"
done < "$POPS"
