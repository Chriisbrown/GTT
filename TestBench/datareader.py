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
                            MET = (a[24:40].uint)*2 
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


def fw_hw_reader(num_events,filename):
    sim_z0_array = []
    sim_weight_array = []
    sim_MET_array = []

    all_filenames = os.listdir(filename)
    filenames = [file for file in all_filenames if file.endswith(".txt")]
    sorted_filenames = sorted(filenames, key=lambda x: int(x.split('_')[2].split('.')[0]))
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
    ref = pd.DataFrame({"fpga_z0" : sim_z0_array[0:num_events], 
                        "fpga_z0_weight" : sim_weight_array[0:num_events], 
                        "fpga_MET" : sim_MET_array[0:num_events]})
    return ref
    

def fw_sim4link_reader(num_events,filename):
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
                            #valid = (a[39])  
                            if z0 != 0:  
                                sim_z0_array.append(Formats.HWUto("HWUz0",int(z0)))
                                sim_weight_array.append(Formats.HWUto("Pt",int(weight)))

                                #sim_z0_array.append(z0)
                                #sim_weight_array.append(weight)

                        link2 = removed_frame.split(" ")[2]
                        val2 = link2.partition("v")[0]
                        if val2 == '1':
                            data2 = link2.partition("v")[2]
                                
                            a = bs.BitArray(hex=data2)

                            MET = (a[48:64].uint)*2 
                            if MET != 0:  
                                sim_MET_array.append(Formats.HWUto("Pt",int(MET)))

                        
    ref = pd.DataFrame({"fw_z0" : sim_z0_array[0:num_events], 
                      "fw_z0_weight" : sim_weight_array[0:num_events], 
                      "fw_MET" : sim_MET_array[0:num_events]})
    return ref