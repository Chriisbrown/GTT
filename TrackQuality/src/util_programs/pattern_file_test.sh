# Setup paths
                           
cfile=/afs/cern.ch/user/c/cebrown/private/EMP/TrackClassifier_vcu118/package/src/addrtab/connections.xml
# Reset the firmware (just clears some registers)
empbutler -c $cfile do vcu118 reset internal
# Configure the rx (receiver) buffers of links 0-35 in 'PlayOnce' mode.
# The file PatternFile5Events.txt is written (over IPBus over PCIe) into buffers (memories) next to each receiver link.
empbutler -c $cfile do vcu118 buffers rx PlayOnce -c 0-1 --inject file:///afs/cern.ch/user/c/cebrown/private/EMP/input_files/inputfile1.txt
# Configure the tx (transmit) buffer of link 0 to Capture. The algorithm only outputs to one link
empbutler -c $cfile do vcu118 buffers tx Capture -c 0
# Play the data from rx buffer, through algorithm, to tx buffer
empbutler -c $cfile do vcu118 capture --rx 0-1 --tx 0
