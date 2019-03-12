#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=1:00:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=6   # 16 processor core(s) per node 
#SBATCH --job-name="E2.4"
#SBATCH --mail-user=dpsaroud@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --output="E2.4.slurm.log"

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE
cd /home/dpsaroud/EEOB563/labs/4
raxml-ng --msa data/fasta.fs --model GTR+G+FC --prefix E2.4 --threads 6 --seed 12 --tree pars{25},rand{25}
