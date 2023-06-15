#!/bin/bash --login 
#SBATCH --job-name=nxf-master 
#SBATCH --account=XXXXXXX 
#SBATCH --partition=work
#SBATCH --time=1-00:00:00
#SBATCH --no-requeue 
#SBATCH --export=none 
#SBATCH --nodes=1

unset SBATCH_EXPORT 
module load openjdk/17.0.0_35
module load singularity/3.8.6 
module load nextflow/22.04.3 

nextflow run main.nf -profile setonix -name nxf-${SLURM_JOB_ID} -resume --with-report


