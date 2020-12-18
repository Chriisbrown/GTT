import bitstring as bs
import os
import util
import Formats
import pandas as pd


'''
FPGA_z0_array = []
FPGA_weight_array = []
python_z0_array = []
python_weight_array = []
CMSSW_z0_array = []
CMSSW_weight_array = []
sim_z0_array = []
sim_weight_array = []


filenames = os.listdir("output_files/fpga")
sorted_filenames = sorted(filenames, key=lambda x: int(x.split('_')[2].split('.')[0]))
for file in sorted_filenames:
    if file.endswith(".txt"):
        inputfile = open(os.path.join("output_files/fpga", file), 'r') 
        inLines = inputfile .readlines() 

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
                        valid = (a[39])  
                        if z0 != 0:  
                            FPGA_z0_array.append(Formats.HWUto("HWUz0",int(z0)))
                            FPGA_weight_array.append(Formats.HWUto("Pt",int(weight)))
                            #FPGA_z0_array.append(z0)
                            #FPGA_weight_array.append(weight)

'''
def fw_sim_reader(num_events,filename):
    sim_z0_array = []
    sim_weight_array = []
    sim_MET_array = []

    all_filenames = os.listdir(filename)
    filenames = [file for file in all_filenames if file.endswith(".txt")]
    sorted_filenames = sorted(filenames, key=lambda x: int(x.split('_')[1].split('.')[0]))
    for file in sorted_filenames:
        if file.endswith(".txt"):
            inputfile = open(os.path.join(filename, file), 'r') 
            inLines = inputfile .readlines() 

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
                            MET = (a[24:40].uint)
                            #valid = (a[39])  
                            if z0 != 0:  
                                sim_z0_array.append(Formats.HWUto("HWUz0",int(z0)))
                                sim_weight_array.append(Formats.HWUto("Pt",int(weight)))
                                sim_MET_array.append(Formats.HWUto("Pt",int(MET)))
                                #sim_z0_array.append(z0)
                                #sim_weight_array.append(weight)
    ref = pd.DataFrame({"fw_z0" : sim_z0_array[0:num_events], 
                      "fw_z0_weight" : sim_weight_array[0:num_events], 
                      "fw_MET" : sim_MET_array[0:num_events]})
    return ref
    


'''
file1 = open('output_files/python_predictions.txt', 'r') 
Lines = file1.readlines() 
for i,line in enumerate(Lines):
    if i != 0:
        values = line.strip('\n')
        refz0 = values.split(',')[1]
        refpt = values.split(',')[2]
        
        python_z0_array.append(Formats.HWUto("HWUz0",int(refz0)))
        python_weight_array.append(Formats.HWUto("Pt",int(refpt)))
        #python_z0_array.append(refz0)
        #python_weight_array.append(refpt)

file3 = open('output_files/CMSSW_predictions.txt', 'r') 
Lines = file3.readlines() 
for i,line in enumerate(Lines):
    if i != 0:
        values = line.strip('\n')
        refz0 = values.split(',')[1]
        refz0 = refz0[1:-1]
        refpt = values.split(',')[2]
        refpt = refz0[1:-1]
        CMSSW_z0_array.append(float(refz0))
        CMSSW_weight_array.append(float(refpt))



CMSSW_diff = []
python_diff =[]
sim_diff=[]
FPGA_diff=[]

CMSSW = []
python =[]
sim=[]
FPGA=[]

for i,value in enumerate(FPGA_z0_array):
    #print(python_z0_array[i],sim_z0_array[i])
    
    if abs(FPGA_z0_array[i] - sim_z0_array[i]) < 0.001:
      #print(FPGA_z0_array[i] - sim_z0_array[i])
      CMSSW_diff.append(CMSSW_z0_array[i]-CMSSW_z0_array[i])
      python_diff.append(CMSSW_z0_array[i]-python_z0_array[i])
      sim_diff.append(CMSSW_z0_array[i]-sim_z0_array[i])
      FPGA_diff.append(CMSSW_z0_array[i]-FPGA_z0_array[i])


      CMSSW.append(CMSSW_z0_array[i])
      python.append(python_z0_array[i])
      sim.append(sim_z0_array[i])
      FPGA.append(FPGA_z0_array[i])
    

    if i > 224:
        break


import matplotlib.pyplot as plt
import mplhep as hep
plt.style.use(hep.cms.style.ROOT)
fig,ax = plt.subplots(1,2,figsize=(18,9))

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)
ax[0].set_title("Residual CMSSW vs Predictions",fontsize=16)
#ax[0].hist(CMSSW_diff,bins=20,histtype="step",range=(-1,1),label="CMSSW Floating Point")
ax[0].hist(python_diff,bins=20,histtype="step",range=(-1,1),label="Python Fixed Point")
ax[0].hist(sim_diff,bins=20,histtype="step",range=(-1,1),label="C-Sim")
ax[0].hist(FPGA_diff,bins=20,histtype="step",range=(-1,1),label="FPGA")
ax[0].legend(fontsize=16,loc="upper left")
ax[0].grid()
ax[0].set_xlabel("CMSSW Predicition - Prediction",ha="right",fontsize=16)
ax[0].set_ylabel("a.u.",ha="right",fontsize=16)

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)
ax[1].set_title("CMSSW vs Predictions",fontsize=16)
#ax[1].scatter(CMSSW_z0_array[0:224],CMSSW_z0_array[0:224],label="CMSSW Floating Point")
ax[1].scatter(python,CMSSW,label="Python Fixed Point")
ax[1].scatter(sim,CMSSW,label="C-Sim")
ax[1].scatter(FPGA,CMSSW,label="FPGA")
ax[1].legend(fontsize=16,loc="upper left")
ax[1].grid()
ax[1].set_xlabel("CMSSW Prediction",fontsize=16)
ax[1].set_ylabel("Prediction",fontsize=16)
#plt.tight_layout()
plt.savefig("performance.png")
#for i,value in enumerate(FPGA_weight_array):
#    print(value,',',python_weight_array[i],CMSSW_weight_array[i])


'''
