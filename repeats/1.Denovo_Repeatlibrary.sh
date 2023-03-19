#!/bin/bash

#SBATCH --get-user-env
#SBATCH --mail-user=merondun@bio.lmu.de
#SBATCH --clusters=biohpc_gen
#SBATCH --partition=biohpc_gen_production
#SBATCH --cpus-per-task=20
#SBATCH --time=200:00:00

RUN=$1

#conda activate repmod
#RepeatModeler version 2.0.3
BuildDatabase -name ${RUN} ${RUN}.chr.fa
RepeatModeler -database ${RUN} -pa 20 -LTRStruct >& ${RUN}.out
