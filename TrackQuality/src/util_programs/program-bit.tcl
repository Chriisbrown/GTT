set bitfile /afs/cern.ch/user/c/cebrown/private/EMP/TrackClassifier_vcu118/package/src/top.bit
open_hw
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices xcvu9p_0]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu9p_0] 0]
set_property PROBES.FILE {} [get_hw_devices xcvu9p_0]
set_property FULL_PROBES.FILE {} [get_hw_devices xcvu9p_0]
#set_property PROGRAM.FILE {lindex $argv 0]} [get_hw_devices xcvu9p_0]
set_property PROGRAM.FILE {/afs/cern.ch/user/c/cebrown/private/EMP/TrackClassifier_vcu118/package/src/top.bit} [get_hw_devices xcvu9p_0]
program_hw_devices [get_hw_devices xcvu9p_0]
#refresh_hw_device [lindex [get_hw_devices xcvu9p_0] 0]
