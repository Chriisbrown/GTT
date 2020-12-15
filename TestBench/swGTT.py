
import numpy as np
import util

def fastHisto(event, weight_field='pt', bins=np.arange(-15., 15., 30/256)):
  weights = None if weight_field is None else event[weight_field]
  h, b = np.histogram(event['z0'], bins=bins, weights=weights)
  vertex_i = np.argmax(np.convolve(h,np.ones(3),mode="same"))
  weight = np.max(np.convolve(h,np.ones(3),mode="same"))
  vertex = b[vertex_i] + 0.5*(b[1]-b[0])
  return vertex,weight


def swTrackToVertex(event,vertex):
    in_window = []
    for i in range(len(event["eta"])):
        if ( abs(event["eta"][i])>=0  and  abs(event["eta"][i])<0.7): 
          DeltaZ = 0.4
        elif ( abs(event["eta"][i])>=0.7 and  abs(event["eta"][i])<1.0):  
          DeltaZ = 0.6
        elif ( abs(event["eta"][i])>=1.0 and  abs(event["eta"][i])<1.2):  
          DeltaZ = 0.76
        elif ( abs(event["eta"][i])>=1.2 and  abs(event["eta"][i])<1.6): 
          DeltaZ = 1.0
        elif ( abs(event["eta"][i])>=1.6 and  abs(event["eta"][i])<2.0):  
          DeltaZ = 1.7
        elif ( abs(event["eta"][i])>=2.0 and  abs(event["eta"][i])<=2.4):
          DeltaZ = 2.2

        if ( abs(event["z0"][i] - vertex) <= DeltaZ):
            in_window.append(i)
    new_event = dict(list([(key,event[key][in_window].reset_index(drop=True)) for key in event.keys()]))

    return new_event

def swTrackSelection(event):

    purity_cut = []
    for i in range(len(event["pt"])):
    
      if ((event["pt"][i] >= 2) 
        and (event["nstub"][i]  >= 4 )
        and (event["bendchi2"][i] <= 2.4 )  
        and (abs(event["eta"][i]) <= 2.4 )
        and (abs(event["z0"][i]) <= 15 )
        and (event["chi2"][i]  <= 40 ) ) :
        purity_cut.append(i)

    new_event = dict(list([(key,event[key][purity_cut].reset_index(drop=True)) for key in event.keys()]))
    
    return new_event

def swTrackMET(event):
  px = event["pt"]*np.cos(event["phi"])
  py = event["pt"]*np.sin(event["phi"])
  sumpx = sum(px)
  sumpy = sum(py)
  MET = np.sqrt(sumpx**2+sumpy**2)
  MET_phi = np.arctan2(sumpy,sumpx)
  if MET_phi > 0:
    MET_phi -= np.pi
  elif MET_phi <= 0:
    MET_phi += np.pi

  return MET,MET_phi



def simulation(num_events,file_name):
    num_events = num_events
    events = util.loadDataSingleFile(file_name,[0,num_events])
    cmssw_v = util.loadVertexInformation(file_name,num_events=num_events)
    cmssw_met = util.loadMETInformation(file_name,num_events=num_events)

    vertex=np.zeros(len(cmssw_met))
    weight=np.zeros(len(cmssw_met))
    MET=np.zeros(len(cmssw_met))
    MET_phi=np.zeros(len(cmssw_met))




    for i,event in enumerate(events):
      if i % 100 == 0:
        print(i,"out of ",num_events)
      vertex[i],weight[i] = fastHisto(event)
      associate_tracks = swTrackToVertex(event,cmssw_v["Pv_z0"][i])
      Selected_tracks = swTrackSelection(associate_tracks)
      MET[i],MET_phi[i] = swTrackMET(Selected_tracks)

      '''
      print("Vertex: ",vertex, "[cm] Vertex Weight: ",weight,"[GeV] MET: ",MET,"[GeV] MET Phi: ",MET_phi,"[rad]")
      print("PV: ",cmssw_v.iloc[i][0][0]," [cm] FH Vertex: ",cmssw_v.iloc[i][3][0]," [cm] TDR Vertex: ",cmssw_v.iloc[i][2][0]," [cm]")
      print("MET: ",cmssw_met["TrkMet"].iloc[i], 
            " [GeV] MET Phi: ",cmssw_met["TrkMetPhi"].iloc[i],
            " [rad] Cut MET: ",cmssw_met["CutTrkMet"].iloc[i],
            " [GeV] Cut MET Phi: ",cmssw_met["CutTrkMetPhi"].iloc[i])
      print("=====================================================")
      '''


    cmssw_met = cmssw_met.join(cmssw_v)
    cmssw_met.insert(0,"SW_Vertex",vertex,True)
    cmssw_met.insert(1,"SW_Vtx_Weight",weight,True)
    cmssw_met.insert(2,"SW_MET",MET,True)
    cmssw_met.insert(3,"SW_MET_phi",MET_phi,True)
    return cmssw_met
    #print(cmssw_met[["SW_MET","SW_MET_phi","TrkMET","MCMET"]].head())
    #print(cmssw_met[["SW_Vertex","SW_Vtx_Weight","Pv_z0","Pv_weight","MCVertex"]].head())






      

      
