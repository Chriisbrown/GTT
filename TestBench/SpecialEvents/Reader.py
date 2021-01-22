import bitstring as bs
import os
import sys
import Formats
import numpy as np
import util


filename = sys.argv[1]

z0_array = []
weight_array = []
MET_array = []
Px_array = []
Py_array = []
Tracks_array = []
Tracks_array_pt = []


inputfile = open(filename, 'r') 
inLines = inputfile .readlines() 

def fwInvRLUT(invr):
  pt_array = []
  
  with open('../ComponentTest/InvRtest/InvRarrays.npy', 'rb') as f:
    new_InvR = np.load(f)

    new_IntOut = np.load(f)
    new_FracOut = np.load(f)

    #invr = Formats.toHWU("InvR",event["InvR"].iloc[i])
    idx = (np.abs(new_InvR - invr)).argmin()
    return (int((new_IntOut[idx]*2**18 + new_FracOut[idx])/2**18))

for i,line in enumerate(inLines):
    if i > 3: 
        frame = line.partition(":")[0]
        removed_frame = line.partition(":")[2]
    

        link1 = removed_frame.split(" ")[1]
        val1 = link1.partition("v")[0]
        if val1 == '1':
            data1 = link1.partition("v")[2]
                                
            a = bs.BitArray(hex=data1)

            z0 = (a[56:64].uint)
            weight = (a[40:56].uint)  
   
            z0_array.append(int(z0))
            weight_array.append(int(weight))

        link2 = removed_frame.split(" ")[2]
        val2 = link2.partition("v")[0]
        if val2 == '1':
            data2 = link2.partition("v")[2]
                                
            a = bs.BitArray(hex=data2)

            MET = (a[48:64].uint)  
            MET_array.append(int(MET))

            link3 = removed_frame.split(" ")[3]
            val3 = link3.partition("v")[0]
            if val3 == '1':
                data3 = link3.partition("v")[2]
                                
                a = bs.BitArray(hex=data3)

                Px = (a[48:64].uint)  
                Py = (a[32:48].uint)  
                Px_array.append(int(Px))
                Py_array.append(int(Py))


        link4 = removed_frame.split(" ")[4]
        val4 = link4.partition("v")[0]
        if val4 == '1':
            data4 = link4.partition("v")[2]
                                
            a = bs.BitArray(hex=data4)

            TracksIn = (a[49:64].int)  
 
            Tracks_array.append(int(TracksIn))
            pt = fwInvRLUT(TracksIn)
            Tracks_array_pt.append(pt)



print("Z0")
print(z0_array)
print("Z0 Weight")
print(weight_array)
print("MET")
print(MET_array)
print("Px")
print(Px_array)
print("Py")
print(Py_array)
print("In Tracks InvR")
print(Tracks_array)
print("In Tracks Pt")
print(Tracks_array_pt)
     
                            
