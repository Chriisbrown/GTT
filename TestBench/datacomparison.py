from fwGTT import emulation
from swGTT import simulation
from datareader import fw_sim_reader
from scipy import stats
import matplotlib.pyplot as plt
import mplhep as hep
plt.style.use(hep.cms.style.ROOT)

emulation_df = emulation(98,"/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object_300k.root")
print(".........Emulated...........")
simulation_df = simulation(98,"/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object_300k.root")
print("........Simulated...........")
fw_sim_df = fw_sim_reader(98)
print(".....FPGA file read.........")

MET_df_old = emulation_df[["EM_MET","EM_MET_phi"]].join(simulation_df[["SW_MET","SW_MET_phi","TrkMET","MCMET"]])
MET_df_old.insert(0,"fw_MET",fw_sim_df["fw_MET"],True)

vtx_df = fw_sim_df[["fw_z0","fw_z0_weight"]].join(emulation_df[["EM_Vertex","EM_Vtx_Weight"]].join(simulation_df[["SW_Vertex","SW_Vtx_Weight","Pv_z0","Pv_weight","MCVertex"]]))



#for i in range(len(MET_df_old)):
#  print(MET_df_old[["EM_MET","fw_MET"]].iloc[i])
  #print(vtx_df.iloc[i])
MET_df_old2 = MET_df_old[MET_df_old["TrkMET"] < 1000]#375]
MET_df = MET_df_old2[MET_df_old2["fw_MET"] < 1000]#600]

MET_df["MET_EM_error"] = MET_df["fw_MET"] - MET_df["EM_MET"]
MET_df["VTX_EM_error"] = vtx_df["fw_z0"] - vtx_df["EM_Vertex"]

MET_df["MET_SW_error"] = MET_df["fw_MET"] - MET_df["SW_MET"]
MET_df["VTX_SW_error"] = vtx_df["fw_z0"] - vtx_df["SW_Vertex"]

print(MET_df.nlargest(10,'MET_EM_error'))

name = "performance_plots/indepth/"

#=========================================Emulation Vertex========================================================#
fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(vtx_df["EM_Vertex"],vtx_df["fw_z0"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("PV$_{emul}$ [cm]",loc="right",fontsize=16)
ax[0].set_ylabel("PV$_{fw}$ [cm]",loc="top",fontsize=16)
ax[0].scatter(vtx_df["EM_Vertex"],vtx_df["fw_z0"])
ax[0].plot(vtx_df["EM_Vertex"], intercept + slope*vtx_df["EM_Vertex"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].set_xlim(-15,15)
ax[0].set_ylim(-15,15)
ax[0].legend(fontsize=16)
ax[0].grid()


ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("PV$_{emul}$ - PV$_{fw}$ [cm]",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((vtx_df["EM_Vertex"]-vtx_df["fw_z0"]),histtype="step",bins=17,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"vertexemvsfpga.png")

#=========================================Simulation Vertex========================================================#
fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(vtx_df["SW_Vertex"],vtx_df["fw_z0"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("PV$_{cmssw}$ [cm]",loc="right",fontsize=16)
ax[0].set_ylabel("PV$_{fw}$ Vertex [cm]",loc="top",fontsize=16)
ax[0].scatter(vtx_df["SW_Vertex"],vtx_df["fw_z0"])
ax[0].plot(vtx_df["SW_Vertex"], intercept + slope*vtx_df["SW_Vertex"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].set_xlim(-15,15)
ax[0].set_ylim(-15,15)
ax[0].legend(fontsize=16)
ax[0].grid()

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("PV$_{cmssw}$ - PV$_{fw}$ [cm]",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((vtx_df["SW_Vertex"]-vtx_df["fw_z0"]),histtype="step",bins=17,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"vertexsimvsfpga.png")



#=========================================Emul vs Sim Vertex========================================================#
fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(vtx_df["SW_Vertex"],vtx_df["EM_Vertex"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("PV$_{cmssw}$ [cm]",loc="right",fontsize=16)
ax[0].set_ylabel("PV$_{emul}$ Vertex [cm]",loc="top",fontsize=16)
ax[0].scatter(vtx_df["SW_Vertex"],vtx_df["EM_Vertex"])
ax[0].plot(vtx_df["SW_Vertex"], intercept + slope*vtx_df["SW_Vertex"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].set_xlim(-15,15)
ax[0].set_ylim(-15,15)
ax[0].legend(fontsize=16)
ax[0].grid()

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("PV$_{cmssw}$ - PV$_{emul}$ [cm]",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((vtx_df["SW_Vertex"]-vtx_df["EM_Vertex"]),histtype="step",bins=17,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"vertexsimvsem.png")


#========================================Emulation MET=========================================================#
fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(MET_df["EM_MET"],MET_df["fw_MET"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("$E^T_{miss,emul}$ [GeV]",loc="right",fontsize=16)
ax[0].set_ylabel("$E^T_{miss,fw} [GeV]$",loc="top",fontsize=16)
ax[0].scatter(MET_df["EM_MET"],MET_df["fw_MET"])
ax[0].plot(MET_df["EM_MET"], intercept + slope*MET_df["EM_MET"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].set_xlim(0,600)
ax[0].set_ylim(0,600)
#ax[0].set_xscale("log")
#ax[0].set_yscale("log")
ax[0].legend(fontsize=16)
ax[0].grid()


ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("$( E^T_{miss,emul} - E^T_{miss,fw} ) / E^T_{miss,fw}$",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((MET_df["EM_MET"]-MET_df["fw_MET"])/MET_df["fw_MET"],histtype="step",bins=19,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"metemvsfpga.png")

#=======================================Simulation MET==========================================================#

fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(MET_df["SW_MET"],MET_df["fw_MET"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("$E^T_{miss,cmssw}$ [GeV]",loc="right",fontsize=16)
ax[0].set_ylabel("$E^T_{miss,fw}$ [GeV]",loc="top",fontsize=16)
#ax[0].set_xlim(0,350)
#ax[0].set_ylim(0,350)
#ax[0].set_xscale("log")
#ax[0].set_yscale("log")
ax[0].scatter(MET_df["SW_MET"],MET_df["fw_MET"])
ax[0].plot(MET_df["SW_MET"], intercept + slope*MET_df["SW_MET"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].legend(fontsize=16)
ax[0].grid()

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("$( E^T_{miss,cmssw} - E^T_{miss,fw} ) / E^T_{miss,fw}$",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((MET_df["SW_MET"]-MET_df["fw_MET"])/MET_df["fw_MET"],histtype="step",bins=19,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"metsimvsfpga.png")



#=======================================Emul vs Sim MET==========================================================#

fig,ax = plt.subplots(1,2,figsize=(18,9))
slope, intercept, r_value, p_value, std_err = stats.linregress(MET_df["SW_MET"],MET_df["EM_MET"])

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("$E^T_{miss,cmssw}$ [GeV]",loc="right",fontsize=16)
ax[0].set_ylabel("$E^T_{miss,emul}$ [GeV]",loc="top",fontsize=16)
ax[0].set_xlim(0,600)
ax[0].set_ylim(0,600)
#ax[0].set_xscale("log")
#ax[0].set_yscale("log")
ax[0].scatter(MET_df["SW_MET"],MET_df["EM_MET"])
ax[0].plot(MET_df["SW_MET"], intercept + slope*MET_df["SW_MET"], 'r', label="slope: %f    intercept: %f" % (slope, intercept))
ax[0].legend(fontsize=16)
ax[0].grid()

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("$( E^T_{miss,cmssw} - E^T_{miss,emul} ) / E^T_{miss,emul}$",loc="right",fontsize=16)
ax[1].set_ylabel("# Events",loc="top",fontsize=16)
ax[1].hist((MET_df["SW_MET"]-MET_df["EM_MET"])/MET_df["EM_MET"],histtype="step",bins=19,range=(-1,1))
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"metsimvsemul.png")

#=================================================================================================#

#==========================================Error Correlation =====================================#

fig,ax = plt.subplots(1,2,figsize=(18,9))

ax[0].tick_params(axis='x', labelsize=16)
ax[0].tick_params(axis='y', labelsize=16)    
ax[0].set_xlabel("$E^T_{miss}$ Error [GeV] (EM vs FPGA)",loc="right",fontsize=16)
ax[0].set_ylabel("$Vertex$ Error [GeV] (EM vs FPGA)",loc="top",fontsize=16)
#ax[0].set_xlim(0,600)
#ax[0].set_ylim(0,600)
#ax[0].set_xscale("log")
#ax[0].set_yscale("log")
ax[0].scatter(MET_df["MET_EM_error"],MET_df["VTX_EM_error"])
ax[0].legend(fontsize=16)
ax[0].grid()

ax[1].tick_params(axis='x', labelsize=16)
ax[1].tick_params(axis='y', labelsize=16)    
ax[1].set_xlabel("$Relative E^T_{miss}$ Error [GeV] (EM vs FPGA)",loc="right",fontsize=16)
ax[1].set_ylabel("$Relative Vertex$ Error [GeV] (EM vs FPGA)",loc="top",fontsize=16)
#ax[0].set_xlim(0,600)
#ax[0].set_ylim(0,600)
#ax[0].set_xscale("log")
#ax[0].set_yscale("log")
ax[1].scatter(MET_df["MET_EM_error"]/MET_df["fw_MET"],MET_df["VTX_EM_error"]/vtx_df["fw_z0"])
ax[1].grid()
plt.tight_layout()
plt.savefig(name+"errorcorrelations.png")
