#!/usr/bin/env bash

###############################################################################
#           Aydin Loid Karatas
#           ---
#           University of Southern California
#           Department of Quantitative and Computational Biology 
#           Mooney Lab
#           ---
#           submit_vcf2anc_table.sh
###############################################################################


pops="/project/jazlynmo_738/aydin/pops_in_LocalAncestryFlare.txt"
for pop in $(cat $pops); do
    echo "submitting vcf2anc_table.sh on ${pop}"
    sbatch vcf2anc_table.sh $pop
done
