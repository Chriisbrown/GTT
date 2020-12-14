eosfusebind
export UHAL_ENABLE_IPBUS_PCIE=1
conda activate emp-tb
export PYTHONPATH=$PYTHONPATH:/usr/lib/python2.7/site-packages
export LD_LIBRARY_PATH=/opt/cactus/lib:$LD_LIBRARY_PATH
export PATH=/opt/cactus/bin/emp:$PATH
source /home/xilinx/Vivado_Lab/2018.3/settings64.sh
