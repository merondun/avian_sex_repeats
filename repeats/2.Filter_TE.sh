#!/bin/bash

#SBATCH --get-user-env
#SBATCH --mail-user=merondun@bio.lmu.de
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_highmem
#SBATCH --cpus-per-task=10
#SBATCH --time=200:00:00

#conda activate te_ann
#USES cd-hit and pfam to identify redundant repeats and any which overlap proteins 

pfamdb=/dss/dsslegfs01/pr53da/pr53da-dss-0021/projects/2021__Cuckoo_Resequencing/wchrom/repeats/2023mar/pfam

#merge bird RM families, exclue the reptiles 
cat $(egrep -v 'Poda|Lacer|Crotal' RUNS.list | sed 's/$/-families.fa/g') > Avian-families.fa

#ensure there's no duplicate sequence IDs
seqkit rename Avian-families.fa > Avian-families.id.fa

#identify redundant hits 
cd-hit-est -T 10 -i Avian-families.id.fa -o Avian-cdhit.fa -M 0 -d 0 -aS 0.8 -c 0.8 -G 0 -g 1 -b 500

#and scan for proteins
getorf -sequence Avian-cdhit.fa -outseq Avian-cdhit.trns.fa
pfam_scan.pl -fasta Avian-cdhit.trns.fa -dir $pfamdb > pfam.results
