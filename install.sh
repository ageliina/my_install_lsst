#!/bin/bash -ex
#
# Author: Akke Viitanen
# Email: akke.viitanen@inaf.it

if [ -z $PATH_LSST ] ; then
    echo "Error! Please set the PATH_LSST variable to continue with the installation"
    exit
fi
export PATH_LSST

###############################################################################
# LSST Science Pipelines
#   https://pipelines.lsst.io/index.html
#   https://pipelines.lsst.io/install/lsstinstall.html
###############################################################################
mkdir -vp $PATH_LSST/lsst_stack
cd $PATH_LSST/lsst_stack

curl -OL "https://ls.st/lsstinstall"
chmod u+x lsstinstall
./lsstinstall -T v26_0_0

source loadLSST.sh

eups distrib install -t v26_0_0 lsst_distrib
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/main/shebangtron | python
setup lsst_distrib

###############################################################################
# imSim
###############################################################################
mkdir -v $PATH_LSST/imsim
cd $PATH_LSST/imsim

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-$(uname)-$(uname -m).sh"
bash Mambaforge-$(uname)-$(uname -m).sh

conda create -n imSim
conda activate imSim

git clone https://github.com/LSSTDESC/imSim.git
git clone https://github.com/LSSTDESC/skyCatalogs

# conda dependencies:
mamba install -y --file imSim/etc/standalone_conda_requirements.txt
mamba install rubin-sim

# # Install imSim:
pip install --no-deps imSim/
pip install --no-deps skyCatalogs/

mkdir -p rubin_sim_data/sims_sed_library
curl https://s3df.slac.stanford.edu/groups/rubin/static/sim-data/rubin_sim_data/skybrightness_may_2021.tgz | tar -C rubin_sim_data -xz
curl https://s3df.slac.stanford.edu/groups/rubin/static/sim-data/rubin_sim_data/throughputs_2023_09_07.tgz | tar -C rubin_sim_data -xz
curl https://s3df.slac.stanford.edu/groups/rubin/static/sim-data/sed_library/seds_170124.tar.gz  | tar -C rubin_sim_data/sims_sed_library -xz

conda env config vars set RUBIN_SIM_DATA_DIR=$(pwd)/rubin_sim_data
conda env config vars set SIMS_SED_LIBRARY_DIR=$(pwd)/rubin_sim_data/sims_sed_library
