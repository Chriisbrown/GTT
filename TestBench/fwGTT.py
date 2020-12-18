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
  
  with open('ComponentTest/InvRtest/InvRarrays.npy', 'rb') as f:
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
  z0 = []

  for i in range(len(event["z0"])):
    z = toHWU('Z0',event["z0"][i])
    if np.signbit(z[1]):
      z0.append(-z[0]*8 - int(z[0]/2) + int(z[1]/8) + int(z[1]/64) + 128 )  #fw estimate
    else:
      z0.append( z[0]*8 + int(z[0]/2) + int(z[1]/8) + int(z[1]/64) + 128 )    #fw estimate

  if fwpt:
    weight = event["fwPt"]
  else:
    weight = [toHWU( "Pt",p) for p in event[ "pt"]]
  h, b = np.histogram(z0, bins=bins, weights=weight)

  if ret_all:
    return b, h
  return (b[h.argmax()]), h.max()

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
          HWUz =  -z0[0]*8 - int(z0[0]/2) + int(z0[1]/8) + int(z0[1]/64) + 128   #fw estimate
        else:
          HWUz = z0[0]*8 + int(z0[0]/2) + int(z0[1]/8) + int(z0[1]/64) + 128    #fw estimate

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

def fwCordicSqrt(x,y,n_steps=4):
  mag_bits = 16
  hypoteneuse_scale = 1<<mag_bits

  
  phi_bits = 12 
  phi_scale = 2304

  def rotation( i ):
    return round( phi_scale * np.arctan( 2**-i ) / (2*np.pi) )

  def mag_renormalization(n_steps=4):
    val = 1.0
    for i in range(n_steps):
      val = val / ((1+(4**-i))**0.5)
    return round( hypoteneuse_scale * val )

  if( x >= 0 and y >= 0 ) :
    phi = 0
    sign = True
    x = x
    y = y
  elif( x < 0 and y >= 0 ) :
    phi = ( 0.5 * phi_scale )
    sign = False
    x = -x
    y = y
  elif( x < 0 and y < 0 ) :
    phi = ( 0.5 * phi_scale )
    sign = True
    x = -x
    y = -y    
  else:
    phi = ( phi_scale )
    sign = False
    x = x
    y = -y    

  for i in range(n_steps):
    
    if y<0:
      new_x = x - (y >> i)
      new_y = y + (x >> i)
    else:    
      new_x = x + (y >> i)
      new_y = y - (x >> i)

    if (y < 0) == sign :
      new_phi = phi - rotation( i )
    else:    
      new_phi = phi + rotation( i )


    x = new_x
    y = new_y
    phi = new_phi

  return(int(phi),int(x * mag_renormalization(n_steps=n_steps)) >> mag_bits)

def fwTrackMET(event,fwpt=True,Cordic=True):
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
            sumpx_sectors[sector] += int(pt*int(TrigLUT[0][1:])/(lut_precision*2))
            sumpy_sectors[sector] += int(pt*int(TrigLUT[1][:-1])/(lut_precision*2))
        elif (phi >= int(np.pi/(2*hwu_binsize))  and phi < int(np.pi/(hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-np.pi/(2*hwu_binsize))].split(',')
            sumpx_sectors[sector] -= int(pt*int(TrigLUT[1][:-1])/(lut_precision*2))
            sumpy_sectors[sector] += int(pt*int(TrigLUT[0][1:])/(lut_precision*2))
        elif (phi >= int(np.pi/(hwu_binsize) )  and phi < int(3*np.pi/(2*hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-np.pi/(hwu_binsize))].split(',')
            sumpx_sectors[sector] -= int(pt*int(TrigLUT[0][1:])/(lut_precision*2))
            sumpy_sectors[sector] -= int(pt*int(TrigLUT[1][:-1])/(lut_precision*2))
        elif (phi >= int(3*np.pi/(2*hwu_binsize) )  and phi < int(2*np.pi/(hwu_binsize))):
            TrigLUT = TrigLUTlines[int(phi-3*np.pi/(2*hwu_binsize) )].split(',')
            sumpx_sectors[sector] += int(pt*int(TrigLUT[1][:-1])/(lut_precision*2))
            sumpy_sectors[sector] -= int(pt*int(TrigLUT[0][1:])/(lut_precision*2))

  print(sumpx_sectors)
  print(sumpy_sectors)

  sumpx = np.sum(sumpx_sectors)
  sumpy = np.sum(sumpy_sectors)

  if Cordic:
    MET_phi,MET = fwCordicSqrt(int(sumpx),int(sumpy),4)
    MET_phi = MET_phi*2*np.pi/2304
    MET = MET/2**5

  else:
    MET = int(np.sqrt(sumpx*sumpx+sumpy*sumpy))/2**5
    MET_phi = np.arctan2(sumpy,sumpx)

    if MET_phi > 0:
      MET_phi -= np.pi
    elif MET_phi <= 0:
      MET_phi += np.pi

  return MET,MET_phi
  
def emulation(num_events,file_name,specific_event=False,specific_id=0):
    num_events = num_events
    print("==== Events ====")
    events = util.loadDataSingleFile(file_name,[0,num_events])
    print(".... loaded  ....")
    print("==== Vertex ====")
    cmssw_v = util.loadVertexInformation(file_name,num_events=num_events)
    print(".... loaded  ....")
    print("===== MET ======")
    cmssw_met = util.loadMETInformation(file_name,num_events=num_events)
    print(".... loaded  ....")
    vertex=np.zeros(len(cmssw_met))
    weight=np.zeros(len(cmssw_met))
    MET=np.zeros(len(cmssw_met))
    MET_phi=np.zeros(len(cmssw_met))


    if not specific_event:
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

      cmssw_met = cmssw_met.join(cmssw_v)
      cmssw_met.insert(0,"EM_Vertex",vertex,True)
      cmssw_met.insert(1,"EM_Vtx_Weight",weight,True)
      cmssw_met.insert(2,"EM_MET",MET,True)
      cmssw_met.insert(3,"EM_MET_phi",MET_phi,True)
      return cmssw_met
    
    else:
        event = events[specific_id]
        fwInvRLUT(event)
        printTracks(event,"Debug/emulation/hwuLinksToTTTrack.txt",fwpt=True)
        printTracks(event,"Debug/emulation/natLinksToTTTrack.txt",hwu=False)
        vertex,weight = fwFastHisto(event,fwpt=True)

        vertex = HWUto("HWUz0",vertex)
        weight = HWUto("Pt",weight)
        fw_associate_tracks = fwTrackToVertex(event,vertex)
        printTracks(fw_associate_tracks,"Debug/emulation/hwuTrackToVertex.txt")
        fw_selected_tracks = fwTrackSelection(fw_associate_tracks,fwpt=True)
        printTracks(fw_selected_tracks,"Debug/emulation/hwuTrackSelection.txt")
        MET,MET_phi = fwTrackMET(fw_selected_tracks,fwpt=True)

        print("Vertex: ",vertex, "[cm] Vertex Weight: ",weight,"[GeV]")
        print("SW FH: ",cmssw_v["Pv_z0"].iloc[specific_id]," [cm] SW FH Weight: ",cmssw_v["Pv_weight"].iloc[specific_id]," [cm] MC Vertex: ",cmssw_v["MCVertex"].iloc[specific_id]," [cm]")
        print("MET: ",MET, 
              " [GeV] MET Phi: ",MET_phi,
              " [rad] SW MET: ",cmssw_met["TrkMET"].iloc[specific_id],
              " [GeV] SW MET MC: ",cmssw_met["MCMET"].iloc[specific_id], "[GeV]")
        print("=====================================================")

if __name__=="__main__":

  #cmssw_met = emulation(2,"/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object.root")
  #print(cmssw_met[["EM_MET","EM_MET_phi","TrkMET","MCMET"]].head())
  #print(cmssw_met[["EM_Vertex","EM_Vtx_Weight","Pv_z0","Pv_weight","MCVertex"]].head())

  emulation(1,"/home/cb719/Documents/L1Trigger/GTT/EMP/DataFiles/TT_object.root",True,0)
