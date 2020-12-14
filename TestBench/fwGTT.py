import numpy as np
import util
from Formats import TrackWord_config
from Formats import toHWU,HWUto,printTracks
import math
from cosineLUT import lut_precision,hwu_binsize

from swGTT import swTrackToVertex, swTrackSelection, swTrackMET

def fwInvR(event):
  pt_array = []
  for i in range(len(event["pt"])):
    pt_array.append(2*math.modf(350286/toHWU("InvR",event["InvR"].iloc[i]))[1])
  event["fwPt"] = pt_array

def fwInvRLUT(event):
  pt_array = []
  
  with open('Debug/parser/InvRarrays.npy', 'rb') as f:
    new_InvR = np.load(f)

    new_IntOut = np.load(f)
    new_FracOut = np.load(f)
    for i in range(len(event["pt"])):
      invr = toHWU("InvR",event["InvR"].iloc[i])
      idx = (np.abs(new_InvR - invr)).argmin()
      pt_array.append(int((new_IntOut[idx]*2**18 + new_FracOut[idx])/2**18))

  

  event["fwPt"] = pt_array

def fwFastHisto(event, ret_all=False, weight='pt',fwpt=True):
  ''' Return the index and weight of the maximum bin '''
  bins = range(TrackWord_config['HWUz0']['nbins'])
  z0 = [toHWU('HWUz0',z) for z in event['z0']]
  if fwpt:
    weight = event["fwPt"]
  else:
    weight = [toHWU( "Pt",p) for p in event[ "pt"]]
  h, b = np.histogram(z0, bins=bins, weights=weight)
  mid_bin = TrackWord_config['HWUz0']['nbins']/2
  if b[h.argmax()] > mid_bin:
    sign = 1
  else: 
    sign = -1

  if ret_all:
    return b, h
  return (b[h.argmax()])-sign, h.max()

def fwTrackToVertex(event,vertex):
    in_window = []
    TanLUTf = open("TanLUT.txt")
    TanLUTlines = TanLUTf.readlines()
    bin_width = 30/(2**8-1)
    
    for i in range(len(event["eta"])):
        tanl_int,tanl_frac = toHWU("TanL",event["TanL"][i])
        temp_str = TanLUTlines[int(tanl_frac)].split(",")[int(tanl_int)]

        if temp_str[0] == '(':
          eta = int(temp_str[1:])
        elif temp_str[-1] == ')':
          eta = int(temp_str[:-1])
        else:
          eta = int(temp_str)

        z0 = toHWU('Z0',event["z0"][i])
        if np.signbit(z0[1]):
          HWUz = int( -z0[0]*8 - z0[0]/2 + z0[1]/8 + z0[1]/64 + 128 )  #fw estimate
        else:
          HWUz = int( z0[0]*8 + z0[0]/2 + z0[1]/8 + z0[1]/64 + 128 )   #fw estimate

        #HWUz = round(sign*(abs(z0[0]*255/(30)) + z0[1]*255/(63*30)) + 255/2)  #true fw
        bin_width = 30/(2**8-1)
        
        if ( eta>= toHWU("HWUeta",0)  and eta< toHWU("HWUeta",0.7) ): 
          DeltaZ = int(0.4/bin_width)
        elif (  eta >= toHWU("HWUeta",0.7)  and eta< toHWU("HWUeta",1.0) ):  
          DeltaZ = int(0.6/bin_width)

        elif ( eta >= toHWU("HWUeta",1.0)  and eta< toHWU("HWUeta",1.2) ):  
          DeltaZ = int(0.76/bin_width)

        elif ( eta >= toHWU("HWUeta",1.2) and eta< toHWU("HWUeta",1.6) ): 
          DeltaZ = int(1.0/bin_width)

        elif ( eta >= toHWU("HWUeta",1.6)  and eta < toHWU("HWUeta",2.0)  ):  
          DeltaZ = int(1.7/bin_width)

        elif ( eta >= toHWU("HWUeta",2.0)  and eta <= toHWU("HWUeta",2.4)  ):
          DeltaZ = int(2.2/bin_width)
        if ( abs(HWUz - toHWU('HWUz0',vertex)) <= DeltaZ):
            in_window.append(i)

    new_event = dict(list([(key,event[key][in_window].reset_index(drop=True)) for key in event.keys()]))

    return new_event

def fwTrackSelection(event,fwpt=True):

    purity_cut = []
    for i in range(len(event["pt"])):
      if fwpt:
        pt = event["fwPt"][i]
      else:
        pt = toHWU("Pt",event["pt"][i])

      chi = toHWU("Chi2rz",event["chi2rz"][i])  + toHWU("Chi2rphi",event["chi2rphi"][i])
        
      if ( pt >= 128
          and (event["nstub"][i]  >= 4 ) 
          and (toHWU("Bendchi2",event["bendchi2"][i]) < 3) 
          and (chi <= 16 )
          and (toHWU("Chi2rz",event["chi2rz"][i]) <= 9 )
          and (toHWU("Chi2rphi",event["chi2rphi"][i]) <= 9 ) ):
          purity_cut.append(i)

    new_event = dict(list([(key,event[key][purity_cut].reset_index(drop=True)) for key in event.keys()]))
    
    return new_event

def fwTrackMET(event,fwpt=True):
  shiftLUTf = open("ShiftLUT.txt")
  shiftLUTlines = shiftLUTf.readlines()

  TrigLUTf = open("TrigLUT.txt")
  TrigLUTlines = TrigLUTf.readlines()

  sumpx_sectors = np.zeros([9])
  sumpy_sectors = np.zeros([9])

  for i in range(len(event["phi"])):
    for sector in range(0,9):
      if event["phiSector"][i] == sector:
        if fwpt:
          pt = event["fwPt"][i]
        else:
          pt = toHWU("Pt",event["pt"][i])/2**6
        
        shift = int(shiftLUTlines[event["phiSector"][i]][1:-3])
        phi = toHWU("Phi",event["Sector_Phi"][i]) + shift
        phi = phi -(2**11)/2

        if phi < 0:
            phi = phi + 2*np.pi/hwu_binsize
        elif phi > 2*np.pi/hwu_binsize:
            phi = phi - 2*np.pi/hwu_binsize  

        if (phi >= 0  and phi < int(np.pi/(2*hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi)].split(',')
            sumpx_sectors[sector] += int(pt*int(TrigLUT[0][1:])/lut_precision)
            sumpy_sectors[sector] += int(pt*int(TrigLUT[1][:-1])/lut_precision)
        elif (phi >= int(np.pi/(2*hwu_binsize))  and phi < int(np.pi/(hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-np.pi/(2*hwu_binsize))].split(',')
            sumpx_sectors[sector] -= int(pt*int(TrigLUT[1][:-1])/lut_precision)
            sumpy_sectors[sector] += int(pt*int(TrigLUT[0][1:])/lut_precision)
        elif (phi >= int(np.pi/(hwu_binsize) )  and phi < int(3*np.pi/(2*hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-np.pi/(hwu_binsize))].split(',')
            sumpx_sectors[sector] -= int(pt*int(TrigLUT[0][1:])/lut_precision)
            sumpy_sectors[sector] -= int(pt*int(TrigLUT[1][:-1])/lut_precision)
        elif (phi >= int(3*np.pi/(2*hwu_binsize) )  and phi < int(2*np.pi/(hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-3*np.pi/(2*hwu_binsize) )].split(',')
            sumpx_sectors[sector] += int(pt*int(TrigLUT[1][:-1])/lut_precision)
            sumpy_sectors[sector] -= int(pt*int(TrigLUT[0][1:])/lut_precision)

  #print(sumpx_sectors)
  #print(sumpy_sectors)

  sumpx = np.sum(sumpx_sectors)
  sumpy = np.sum(sumpy_sectors)

  #print(sumpx)
  #print(sumpy)

  MET = int(np.sqrt(sumpx*sumpx+sumpy*sumpy))/2**6
  MET_phi = np.arctan2(sumpy,sumpx)

  if MET_phi > 0:
    MET_phi -= np.pi
  elif MET_phi <= 0:
    MET_phi += np.pi

  return MET,MET_phi
  

def emulation(num_events):
    num_events = num_events
    print("==== Events ====")
    events = util.loadDataSingleFile("/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object_300k.root",[0,num_events])
    print(".... loaded  ....")
    print("==== Vertex ====")
    cmssw_v = util.loadVertexInformation("/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object_300k.root",num_events=num_events)
    print(".... loaded  ....")
    print("===== MET ======")
    cmssw_met = util.loadMETInformation("/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object_300k.root",num_events=num_events)
    print(".... loaded  ....")
    vertex=np.zeros(len(cmssw_met))
    weight=np.zeros(len(cmssw_met))
    MET=np.zeros(len(cmssw_met))
    MET_phi=np.zeros(len(cmssw_met))



    for i,event in enumerate(events):
      if i % 100 == 0:
        print(i,"out of ",num_events)
      fwInvRLUT(event)
      printTracks(event,"Debug/emulation/hwuLinksToTTTrack.txt",fwpt=True)
      printTracks(event,"Debug/emulation/natLinksToTTTrack.txt",hwu=False)
      vertex[i],weight[i] = fwFastHisto(event,fwpt=True)

      vertex[i] = HWUto("HWUz0",vertex[i])
      weight[i] = HWUto("Pt",weight[i])
      fw_associate_tracks = fwTrackToVertex(event,vertex[i])
      printTracks(fw_associate_tracks,"Debug/emulation/hwuTrackToVertex.txt")
      fw_selected_tracks = fwTrackSelection(fw_associate_tracks,fwpt=True)
      printTracks(fw_selected_tracks,"Debug/emulation/hwuTrackSelection.txt")
      MET[i],MET_phi[i] = fwTrackMET(fw_selected_tracks,fwpt=True)
      

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
    cmssw_met.insert(0,"EM_Vertex",vertex,True)
    cmssw_met.insert(1,"EM_Vtx_Weight",weight,True)
    cmssw_met.insert(2,"EM_MET",MET,True)
    cmssw_met.insert(3,"EM_MET_phi",MET_phi,True)
    return cmssw_met

if __name__=="__main__":

  cmssw_met = emulation(2)
  print(cmssw_met[["EM_MET","EM_MET_phi","TrkMET","MCMET"]].head())
  print(cmssw_met[["EM_Vertex","EM_Vtx_Weight","Pv_z0","Pv_weight","MCVertex"]].head())