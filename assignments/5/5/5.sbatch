#!/bin/bash

# Copy/paste this job script into a text file and submit with the command:
#    sbatch thefilename
# job standard output will go to the file slurm-%j.out (where %j is the job ID)

#SBATCH --time=10:30:00   # walltime limit (HH:MM:SS)
#SBATCH --nodes=1   # number of nodes
#SBATCH --ntasks-per-node=16   # 16 processor core(s) per node 
#SBATCH --job-name="5.5_assignment"
#SBATCH --mail-user=dpsaroud@iastate.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

# LOAD MODULES, INSERT CODE, AND RUN YOUR PROGRAMS HERE#!/bin/bash
cd /home/dpsaroud/EEOB563/assignments/5/5

/home/dpsaroud/bin/raxml-ng --all --msa ../alignment.phy --model GTR+G --seed 12 --threads 16 --bs-metric fbp --bs-trees 1000
