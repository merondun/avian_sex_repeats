#!/bin/bash

#SBATCH --get-user-env
#SBATCH --mail-user=merondun@bio.lmu.de
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_production
#SBATCH --cpus-per-task=20
#SBATCH --time=200:00:00

#conda activate repmod
RUN=$1

#Now run repeatmasker with that library against the autosomes, W, and Z independently
for CHR in $(cat CHRS.list); do 
seqtk subseq ${RUN}.chr.fa ${CHR}.list > ${RUN}-${CHR}.fa
RepeatMasker -pa 20 -a -s -gff -no_is -lib Avian-cdhit.fa ${RUN}-${CHR}.fa &> RMaves_${RUN}-${CHR}.run.out
done 
