#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           submit_anc_runs_in_ibd.sh
###############################################################################

POPS="pops_in_LocalAncestryFlare.txt"
TOTAL_POPS=$(wc -l < "$POPS")
sbatch --array=1-${TOTAL_POPS} job_scripts/anc_runs_in_ibd.sh
