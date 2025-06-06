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

pops="pops_in_LocalAncestryFlare.txt"
total_pops=$(wc -l < "$pops")
sbatch --array=1-${total_pops} anc_runs_in_ibd.sh
