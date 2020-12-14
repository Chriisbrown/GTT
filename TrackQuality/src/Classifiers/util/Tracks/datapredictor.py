import util_funcs
import codecs
import numpy as np
import bitstring as bs
import xgboost as xgb

from scipy.special import expit

import sys
mode = sys.argv[1]

if mode == "eval":
    index_num = int(sys.argv[2])


def loadmodelGBDT():
    import joblib
    model = joblib.load("/home/cb719/Documents/EMP/TrackQuality/src/GBDTbitOutput/GBDTsmallbit//GBDTOutput/Models/GBDT.pkl")

    return model

def loadmodelNN():
    from tensorflow.keras.models import load_model
    from qkeras.qlayers import QDense, QActivation
    from qkeras.quantizers import quantized_bits, quantized_relu
    from qkeras.utils import _add_supported_quantized_objects
    co = {}
    _add_supported_quantized_objects(co)

    model = load_model("/home/cb719/Documents/EMP/TrackQuality/src/NNOutput/Models/Final_model.h5",custom_objects=co)

    

    return model

if mode == "NN":
    model = loadmodelNN()
if mode == "GBDT":
    model= loadmodelGBDT()


model_parameters = ["trk_chi2","trk_bendchi2","trk_chi2rphi", "trk_chi2rz", "pred_nstub",
                        "pred_layer1","pred_layer2","pred_layer3","pred_layer4","pred_layer5","pred_layer6","pred_disk1","pred_disk2","pred_disk3",
                        "pred_disk4","pred_disk5","InvR","TanL","trk_z0","pred_dtot","pred_ltot"]

model_predictions = []
model_valid = []

Target = []

inputfile = open('input.txt', 'r') 
inLines = inputfile .readlines() 
input_data = []
for i,line in enumerate(inLines):
    if i > 3: 
        frame = line.partition(":")[0]
        removed_frame = line.partition(":")[2]
        #val1 = removed_frame.split("v")[0]
        link1 = removed_frame.split(" ")[1]
        link2 = removed_frame.split(" ")[2]

        val1 = link1.partition("v")[0]
        val2 = link2.partition("v")[0]
        data1 = link1.partition("v")[2].rstrip()
        data2 = link2.partition("v")[2].rstrip()

        binary_input1 = bs.BitArray(hex=data1)
        binary_input2 = bs.BitArray(hex=data2)

        BigInvR = ((binary_input1[49:64].int)/2**7) /2**4
       #phi = (binary_input1[37:49].int)
        TanL = (binary_input1[21:37].int)
        z0 =   (binary_input1[9:21].int)/2**7
        #do = (binary_input2[51:64].int)
        bendchi = (binary_input2[48:51].uint)/2**7
        hitmask = (binary_input2[41:48].uint)
        chi2rz = (binary_input2[37:41].uint)/2**7
        chi2rphi = (binary_input2[33:37].uint)/2**7
        trk_fake = int(binary_input2[32])
     
        chi2 = chi2rz + chi2rphi


        [layer1,layer2,layer3,layer4,
         layer5,layer6,disk1,disk2,disk3,
         disk4,disk5,pred_dtot,
         pred_ltot,pred_nstub] = util_funcs.single_predhitpattern(hitmask,TanL)

        TanL = (TanL/2**7) /2**5
      
        in_array = np.array([chi2,bendchi,chi2rphi,chi2rz,
                                pred_nstub,layer1,layer2,layer3,layer4,
                                layer5,layer6,disk1,disk2,disk3,
                                disk4,disk5,BigInvR,TanL,z0,pred_dtot,pred_ltot])

        in_array = np.expand_dims(in_array,axis=0)
        if mode == "NN":
            pred = model.predict(np.vstack((in_array,in_array)))[0]
        if mode == "GBDT":
            pred = model.predict_proba(in_array)[:,1]
        if mode == "eval":
            pred = in_array[:,index_num]

        if (val1 == '1'):
          model_predictions.append(pred[0])
          Target.append(trk_fake)
          model_valid.append(val1)

model_sim = []
model_simvalid = []


file1 = open('output.txt', 'r') 
Lines = file1.readlines() 


# Strips the newline character 
for i,line in enumerate(Lines):
    if i > 3: 
        frame = line.partition(":")[0]
        removed_frame = line.partition(":")[2]

        link1 = removed_frame.split(" ")[1]
        #link2 = removed_frame.split(" ")[2]
        #link3 = removed_frame.split(" ")[3]
        #link4 = removed_frame.split(" ")[4]

        val1 = link1.partition("v")[0]
        data1 = link1.partition("v")[2]
        
        a = bs.BitArray(hex=data1)
        
        if mode == "GBDT":
            b = ((a[53:64].int))/2**7
            b = expit(b)
        if mode == "NN":
            b = ((a[48:64].int))/2**10

        if mode == "eval":
            b = ((a[53:64].int))/2**7
        if (val1 == '1'):
          model_sim.append(b)
          model_simvalid.append(val1)
        

full_precision_model = []
import pandas as pd
df = pd.read_csv("full_precision_input.csv",names=model_parameters+["trk_fake"])

for i,row in df.iterrows():
    row = row
    if mode == "NN":
        in_array = np.expand_dims((row[0:21].to_numpy()),axis=0)
        full_precision_model.append(model.predict(in_array)[0][0])
    if mode == "GBDT":
        full_precision_model.append(model.predict_proba(row[0:21])[:,1][0])
    if mode == "eval":
        full_precision_model.append(row[index_num])

diff = []
diff2 = []
with open("predictions.txt", "w") as the_file:
    for i in range(len(model_sim)):
        diff.append((model_predictions[i] - model_sim[i])**2)
        diff2.append((model_predictions[i]- full_precision_model[i])**2)
        the_file.write('{0:4} FPGA: {1} : {2:8.6} \t CPU: {3} : {4:8.6} \t CPU_fullP: {5:8.6} \t,Target: {6} \n'.format(
                         i, model_simvalid[i],model_sim[i],model_valid[i],model_predictions[i],full_precision_model[i],Target[i]))
        
print("Simulated vs Truncated CPU MSE:",np.mean(diff))
print("Full Precision vs Truncated CPU MSE:",np.mean(diff2))
