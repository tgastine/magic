#!/bin/sh

### Env for Lumi02
module purge
module load craype/2.7.19 PrgEnv-cray/8.3.3
module load craype-x86-rome libfabric/1.13.1 craype-network-ofi cray-mrnet/5.0.4 cray-mpich/8.1.21
module load cce/15.0.0 craype-accel-amd-gfx90a cray-fftw/3.3.10.1 cray-libsci/21.08.1.2 rocm/5.2.0

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/pe/mpich/8.1.21/gtl/lib/
export LDFLAGS+="-L/opt/cray/pe/fftw/3.3.10.1/x86_rome/lib/"
export HIP_LAUNCH_BLOCKING=1
export AMD_LOG_LEVEL=1
export OMP_NUM_THREADS=1
export FC=ftn
export CRAY_ACC_DEBUG=0

module use -a /common/magic/modulefiles/
module load hipfort
export HIPFORT_PATH=/common/magic/INSTALL/hipfort/0.4-6f6ae98e/cpe-cray/15.0.0/rocm/5.2.0/gfx90a/cmpich/8.1.21

### Create a build directory
if [ -e "build" ];then rm -rf "build" ; fi
mkdir -p build
cd build

### Compile (assume SHTns is installed in $HOME/local
cmake .. -DUSE_SHTNS=yes -DUSE_GPU=yes
make -j16

### Submit a job for the boussBenchSat sample
cd ../samples/boussBenchSat
chmod +x clear.sh
./clear.sh
cp ../../build/magic.exe .
sbatch submit_lumi02.sh

squeue

cd -
