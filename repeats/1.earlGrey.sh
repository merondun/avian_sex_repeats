#!/bin/bash

#SBATCH --get-user-env
#SBATCH --mail-user=merondun@bio.lmu.de
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_production
#SBATCH --cpus-per-task=8
#SBATCH --time=200:00:00

SPECIES=$1

for CHR in Z W; do 

echo "Running earlGrey pipeline for ${SPECIES} on chr${CHR}"

earlGrey -r chicken -e yes -t 8 -g chrom_${CHR}/${SPECIES}.${CHR}.fna -s ${SPECIES} -o output/${SPECIES}_${CHR}

done 
