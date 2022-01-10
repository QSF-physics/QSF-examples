#!/bin/bash -l
#SBATCH --job-name=Ar2e-re
#SBATCH --nodes=4                
#SBATCH --ntasks-per-node=16
#SBATCH --mem-per-cpu=1Gb
#SBATCH --time=72:00:00             # max-time (format HH:MM:SS)
#SBATCH -A plgqmsf                  # account id    (change this or pass by cmd line) 
#SBATCH -p plgrid                   # partition     (change this or pass by cmd line)
#SBATCH --output="%x_%A_%a.out"     # x:job-name A:job, a:task
#SBATCH --error="%x_%A_%a.err"
#SBATCH --array=1-5                 # Array range
#SBATCH --mail-type=BEGIN,END,FAIL  # Add ARRAY_TASKS for per task emails
#SBATCH --mail-user=masteranza+slurm@gmail.com 

srun /bin/hostname

module load plgrid/tools/cmake plgrid/libs/fftw/3.3.9 plgrid/libs/mkl/2021.3.0 plgrid/tools/intel/2021.3.0

cd $SLURM_SUBMIT_DIR
prj=`basename "$PWD"`
PARAMS=$(sed -n "${SLURM_ARRAY_TASK_ID}p" < ${SLURM_JOB_NUM_NODES}.param)
echo "Running task ${prj} with params: ${PARAMS}"
mpiexec ./qsf-${prj}-re ${PARAMS} -r
