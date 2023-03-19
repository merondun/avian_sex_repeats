#!/bin/bash

#SBATCH --get-user-env
#SBATCH --mail-user=merondun@bio.lmu.de
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_highmem
#SBATCH --cpus-per-task=3
#SBATCH --time=24:00:00

#conda activate orthofinder
RUN=$1

#Now run repeatmasker with that library against the autosomes, W, and Z independently
for CHR in $(cat CHRS.list); do
perl /dss/dsslegfs01/pr53da/pr53da-dss-0021/assemblies/Cuculus.canorus/VGP.bCucCan1.pri/repeatmodeler/Parsing-RepeatMasker-Outputs/parseRM.pl -i ${RUN}-${CHR}.fa.align -p -f ${RUN}.chr.fa -r Avian-cdhit.fa -v
done

