import util
import Formats
import sys
import numpy as np
import pandas as pd

def writeSpecificEvents(numEvents=1):

    events = []

    for i in range(0,10):
        num_events = 18

        invR_array = 0.0002*np.ones(num_events)
        #sector_array = np.zeros(num_events,dtype=np.int64)
        phi_array = 0*np.ones(num_events)
        tan_array = 0*np.ones(num_events)
        eta_array = -1*np.ones(num_events)
        z0_array = 0*np.ones(num_events)
        mva_array = 0*np.ones(num_events)
        otherMVA_array = 0*np.ones(num_events)
        d0_array = 0*np.ones(num_events)
        chi2rphi_array = 1*np.ones(num_events)
        chi2rz_array = 1*np.ones(num_events)
        bendchi2_array = 1*np.ones(num_events)
        hitpattern_array = 63*np.ones(num_events)

        sector_array = np.array([0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6,7,8])
        eta_array = np.array([-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1])
        additional_phi = np.array([0,1,2,3,4,5,6,7,8,0,1,2,3,4,5,6,7,8])
        additional_eta= np.array([-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1,-1,1])

        #for i in range(int(num_events/18 )):
        #  sector_array = np.append(sector_array,additional_phi)
        #  tan_array = np.append(tan_array,additional_tanl)



    
        event = pd.DataFrame({"InvR":invR_array,"pt":invR_array,"phiSector":sector_array,"Sector_Phi":phi_array,"TanL":tan_array,"eta":eta_array,
                "z0":z0_array,"MVA":mva_array,"otherMVA":otherMVA_array,
                "d0":d0_array,"chi2rphi":chi2rphi_array,"chi2rz":chi2rz_array,
                "bendchi2":bendchi2_array,"hitpattern":hitpattern_array,"nstub": 4*np.ones(num_events)})
        events.append(event)

    return events


if __name__ == "__main__":
  events = writeSpecificEvents()
  Formats.writemultipfile("input_files/SpecialEvents/inputfile_", events, weight='InvR')



