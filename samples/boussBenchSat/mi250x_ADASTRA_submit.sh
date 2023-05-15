#!/bin/bash
#SBATCH --job-name=MagIC
#SBATCH --account=cpa
#SBATCH --constraint=MI250
#SBATCH --ntasks=4
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=32   # -c 32 (=128/ntasks-per-node)
#SBATCH --gres=gpu:4
#SBATCH --exclusive 
#SBATCH --output=Magic_1N4MPI1OMP_%j.out
#SBATCH --time=00:20:00

module purge
module load craype/2.7.19 PrgEnv-cray/8.3.3
module load craype-x86-trento libfabric/1.15.2.0 craype-network-ofi cray-dsmml/0.2.2 cray-mpich/8.1.21
module load cpe/22.11 craype-accel-amd-gfx90a cray-fftw/3.3.10.3 cray-libsci/22.11.1.2 rocm/5.2.3
module use -a ${SHAREDHOMEDIR}/modulefiles
module load rocm/5.2.3
module load hipfort
module list

export HIPFORT_PATH=/lus/home/NAT/cpa2204/SHARED/INSTALL/hipfort/0.4-6f6ae98e/cpe-cray/15.0.0/rocm/5.2.3/cmpich/8.1.21
export LDFLAGS+="-L/opt/cray/pe/fftw/3.3.10.2/x86_trento/lib/"
export KMP_STACKSIZE=1g

ulimit -s unlimited

# Following export is needed to bypass the FS detection fail since CRAY-MPI has not been built with XFS support on the HPE dev machine
export ROMIO_FSTYPE_FORCE="ufs:"

echo "Running on: $SLURM_NODELIST"
echo "Total tasks: $TOTAL_NTASKS"

export OMP_NUM_THREADS=1
export AMD_LOG_LEVEL=2
export CRAY_ACC_DEBUG=1
export HIP_LAUNCH_BLOCKING=1

echo "----------------------------------------"
module list
echo "----------------------------------------"
env | grep SLURM
echo "----------------------------------------"
lscpu
echo "----------------------------------------"
numactl --hardware
echo "----------------------------------------"
rocminfo
echo "----------------------------------------"
hwloc-ls
echo "----------------------------------------"

# GPU direct communication can work in this context.
export MPICH_GPU_SUPPORT_ENABLED=1  # Default 0
export MPICH_OFI_NIC_POLICY=GPU

#export OMP_DISPLAY_AFFINITY=TRUE   # Trace CPU affinity at OpenMP level
#export MPICH_MEMORY_REPORT= 1 | 2 | 3 # Summary of memory usage
export MPICH_OFI_NIC_VERBOSE=1
#export MPICH_OFI_NIC_MAPPING="0:0-7; 2:8-31; 1:32-63"
#export MPICH_OFI_NUM_NICS=1:{0|1|2|3}[,{0|1|2|3}]*

env MAP_VERBOSE=1 srun -l --cpu-bind=verbose --cpus-per-task=${SLURM_CPUS_PER_TASK} --mpi=cray_shasta /lus/home/NAT/cpa/SHARED/TESTS/GetMapping/map_gpu.ordered.sh /lus/home/NAT/cpa/SHARED/TESTS/GetMapping/getMapping_cray_gpu
env MAP_VERBOSE=1 srun -l --cpu-bind=verbose --cpus-per-task=${SLURM_CPUS_PER_TASK} --mpi=cray_shasta /lus/home/NAT/cpa/SHARED/TESTS/GetMapping/map_gpu.ordered.sh ./magic.exe input.nml


