import util
import Formats
import sys
import numpy as np
import pandas as pd

invR_min = 0
invR_max = 32767


events = util.loadDataSingleFile("/home/cb719/Documents/L1Trigger/GTT/EMP/fw-work/src/GTT/DataFiles/TT_object_300k.root",[0,10])
#print(events)
#events = []

#tracks_per_events = 144
'''
for i in range(0,227):
    invR_array = np.linspace(i*tracks_per_events,i*tracks_per_events+tracks_per_events-1,tracks_per_events)
    invR_array = np.append(invR_array,np.zeros(18))
    Sector_Phi_array = np.array([0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6,7,8])
    TanL_array = np.array([-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1])
    additional_phi = np.array([0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6,7,8])
    additional_tanl = np.array([-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1])

    for i in range(int(tracks_per_events/18 )):
      Sector_Phi_array = np.append(Sector_Phi_array,additional_phi)
      TanL_array = np.append(TanL_array,additional_tanl)

    rest_array = np.ones(tracks_per_events+18)
   
    event = pd.DataFrame({"InvR":invR_array,"phiSector":Sector_Phi_array,"Sector_Phi":rest_array,"TanL":rest_array,"eta":TanL_array,
             "z0":rest_array,"MVA":rest_array,"otherMVA":rest_array,
             "d0":rest_array,"chi2rphi":rest_array,"chi2rz":rest_array,
             "bendchi2":rest_array,"hitpattern":rest_array})
    events.append(event)
'''
#Formats.writepfile("input_files/input.txt", events, weight='InvR')
Formats.writemultipfile("input_files/FullGTT/inputfile_with1frames_", events,ninitialframes=1, weight='InvR')
#Formats.writeSWReference("output_files/python_predictions.txt",events=events,weight='InvR')


