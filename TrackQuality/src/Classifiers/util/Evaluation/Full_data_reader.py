import matplotlib.pyplot as plt
import matplotlib
import mplhep as hep
plt.style.use(hep.cms.style.ROOT)
from sklearn import metrics
import numpy as np

file1 = open('1024.txt', 'r') 
Lines = file1.readlines() 

vsim = []
xgboost = []
Conifer_hls = []
Conifer_vhdl = []
FPGA = []
Target = []
# Strips the newline character 
for i,line in enumerate(Lines):
    frame = line.split(":")

    vsim.append(float(frame[2].split(' ')[1]))
    xgboost.append(float(frame[4].split(' ')[1]))
    Conifer_hls.append(float(frame[5]))
    Conifer_vhdl.append(float(frame[6].split(' ')[1]))
    FPGA.append(float(frame[8].split(' ')[1]))
    Target.append(int(frame[9].split(' ')[1]))




vsim_fpr, vsim_tpr, thresholds = metrics.roc_curve(Target,vsim)
vsim_auc = metrics.roc_auc_score(Target,vsim)

xgboost_fpr, xgboost_tpr, thresholds = metrics.roc_curve(Target,xgboost)
xgboost_auc = metrics.roc_auc_score(Target,xgboost)

Coniferhls_fpr, Coniferhls_tpr, thresholds = metrics.roc_curve(Target,Conifer_hls)
Coniferhls_auc = metrics.roc_auc_score(Target,Conifer_hls)

Conifervhdl_fpr, Conifervhdl_tpr, thresholds = metrics.roc_curve(Target,Conifer_vhdl)
Conifervhdl_auc = metrics.roc_auc_score(Target,Conifer_vhdl)

FPGA_fpr, FPGA_tpr, thresholds = metrics.roc_curve(Target,FPGA)
FPGA_auc = metrics.roc_auc_score(Target,FPGA)



fig, ax = plt.subplots(1,1, figsize=(9,9)) 
ax.tick_params(axis='x', labelsize=16)
ax.tick_params(axis='y', labelsize=16)


ax.set_title("Reciever Operator Characteristic Curves (Tested on "+str(len(Target))+" samples)" ,loc='left',fontsize=16)
ax.plot(vsim_fpr, vsim_tpr,label="VHDL Simulation " + "AUC: %.3f"%vsim_auc)
ax.plot(xgboost_fpr, xgboost_tpr,label="XGBoost " + "AUC: %.3f"%xgboost_auc)
ax.plot(Coniferhls_fpr, Coniferhls_tpr,label="Conifer HLS backend " + "AUC: %.3f"%Coniferhls_auc)
ax.plot(Conifervhdl_fpr, Conifervhdl_tpr,label="Conifer VHDL backend " + "AUC: %.3f"%Conifervhdl_auc)
ax.plot(FPGA_fpr, FPGA_tpr,label="FPGA " + "AUC: %.3f"%FPGA_auc)

ax.set_xlim(0.0,0.4)
ax.set_ylim(0.7,1.01)

ax.set_xlabel("False Positive Rate",ha="right",x=1,fontsize=16)
ax.set_ylabel("Identification Efficiency",ha="right",y=1,fontsize=16)
ax.legend()
ax.grid()    

plt.tight_layout
<<<<<<< HEAD
plt.savefig("ROC.png",dpi=600)
=======
plt.savefig("ROC.png",dpi=600)
>>>>>>> c0b637db17f69472cf054fee1c71c090b4d44fa2
