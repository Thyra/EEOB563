#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=1:30:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 16 processor core(s) per node 
#SBATCH --job-name="5.4_assignment"
#SBATCH --mail-user=dpsaroud@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE#!/bin/bash
cd /home/dpsaroud/EEOB563/assignments/5/4

raxml-ng --search --msa ../alignment.phy --model model_codons --prefix codons --seed 12 --brlen scaled
raxml-ng --search --msa ../alignment.phy --model model_genes --prefix genes --seed 12 --brlen scaled
