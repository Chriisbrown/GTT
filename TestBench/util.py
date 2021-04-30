''' Utility to read the ntuples of tracks for vertex related studies '''

import uproot
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pickle

import joblib

import os

import random
#import algos

# --------------------- utility functions start ------------------- #
def ptToInv2R(pt):
  B = 3.8112 # Tesla
  return abs((B * (3e8 / 1e11)) / (2 * pt))

def tanL(eta):
  '''Obtain tan lambda track fitting parameter from eta'''
  return abs(1. / np.tan(2 * np.arctan(np.exp(-eta))))

def transformEvent(event):
  ''' Put the transformed variables into the event for the BDT '''
  event['InvR'] = ptToInv2R(event['pt'])
  event['TanL'] = tanL(event['eta'])
  event["Sector_Phi"] = np.zeros(len(event["phi"]))
  for i,phi in enumerate(event["phi"]):

    if event["phiSector"][i] < 4:
      event["Sector_Phi"][i] = phi - event["phiSector"][i] * (2*np.pi)/9 
    elif event["phiSector"][i] > 5:
      event["Sector_Phi"][i] = phi + (9-event["phiSector"][i]) * (2*np.pi)/9 
    elif event["phiSector"][i] == 4:
      if phi > 0:
        event["Sector_Phi"][i] = phi - event["phiSector"][i] * (2*np.pi)/9 
      else:
         event["Sector_Phi"][i] = phi + (9-event["phiSector"][i]) * (2*np.pi)/9 
    elif event["phiSector"][i] == 5:
      if phi < 0:
        event["Sector_Phi"][i] = phi + (9-event["phiSector"][i]) * (2*np.pi)/9 
      else:
         event["Sector_Phi"][i] = phi -event["phiSector"][i] * (2*np.pi)/9 

  event['MVA'] = event["fake"]/2
  event['otherMVA'] = event["fake"]/2
  return event

def pvTracks(event):
  ''' Return all tracks associated with the primary vertex '''
  return event[event['fromPV']]

def nonPVTracks(event):
  ''' Return all tracks not associated with the primary vertex '''
  return event[event['fromPV'] == False]

def genuineTracks(event):
  ''' Return all genuine tracks '''
  return event[event['genuine'].astype('bool')]

def fakeTracks(event):
  ''' Return all fake tracks '''
  return event[event['genuine'].astype('bool') == False]

def pvz0(event):
  ''' Return the z0 of the PV. When multiple PVs, return the one with smallest dxy '''
  pvts = pvTracks(event)
  # TODO get the PV from other info if non of the tracks match
  if len(pvts['z0']) == 0:
    return False
  elif len(np.unique(pvts['tpz0'])) == 1:
    return pvts['tpz0'].iloc[0]
  else:
    return pvts['tpz0'].iloc[pvts['tpd0'].values.argmin()]

def pvz0_avg(event):
  ''' Return the z0 of the PV. When multiple PVs, return the one with smallest dxy '''
  pvts = pvTracks(event)
  # TODO get the PV from other info if non of the tracks match
  if len(pvts['z0']) == 0:
    return False
  else:
    return np.mean(pvts['z0'])

def pvd0(event):
  ''' Return the z0 of the PV. When multiple PVs, return the one with smallest dxy '''
  pvts = pvTracks(event)
  # TODO get the PV from other info if non of the tracks match
  if len(pvts['tpd0']) == 0:
    return False
  elif len(np.unique(pvts['tpd0'])) == 1:
    return pvts['tpd0'].iloc[0]
  else:
    return pvts['tpd0'].min()


def loadDataSingleFile(filename, num):
  """
  New method for loading training events. It assumes that only one root file is available (as a result of hadd command)
  """

  # check if filename links to a valid file
  if (not os.path.isfile(filename)):
    raise FileNotFoundError("Trying to load data from a file that does not exist: %s" % filename)

  noevts = len(uproot.open(filename)['L1TrackNtuple/eventTree'])
  #print(noevts)
  
  branches = ['trk_fake','trk_pt','trk_z0','trk_chi2rphi','trk_chi2rz','trk_phi','trk_eta','trk_chi2','trk_bendchi2','trk_d0','trk_hitpattern','trk_nstub','trk_phiSector']
  events = [{}] * (num[1]-num[0])

  long_to_short = {'trk_fake':'fake','trk_pt':'pt','trk_z0':'z0','trk_chi2rphi':'chi2rphi',
                   'trk_chi2rz':'chi2rz','trk_phi':'phi','trk_eta':'eta','trk_chi2':'chi2',
                   'trk_bendchi2':'bendchi2','trk_d0':'d0','trk_hitpattern':'hitpattern','trk_nstub':'nstub','trk_phiSector':'phiSector'}

  # Read the relevant branches into a list of events
  events = {}
  for branch in branches:
    events[long_to_short[branch]] = []

  # for i in range(1, 89):
  data = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays(branches)
  for branch in branches:
    for event in data[branch]:
      events[long_to_short[branch]].append(event)



  # Pivot from dict of lists of arrays to list of dicts of arrays
  x = []
  for i in range((num[1]-num[0])):
    y = {}
    for branch in branches:
      y[long_to_short[branch]] = events[long_to_short[branch]][i]
    x.append(pd.DataFrame(transformEvent(y)))
  events = x

  for i,event in enumerate(events):

    event['pt2'] = event['pt']**2
    #for j,eta in enumerate(event["eta"]):
    #  if eta == 0:
    #    print(i,j,eta,event["pt"][j])

  return events

def loadVertexInformation(filename,num_events=-1,write_to_file=False):

  #TkPrimaryVertex = uproot.open(filename)["Events"].array("l1tTkPrimaryVertexs_L1TkPrimaryVertex_TrkVertex_L1TrackMET.obj.zvertex_")
  TkPrimaryVertex = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays("pv_L1reco")
  TkPrimaryVertex_array = np.zeros(len(TkPrimaryVertex))
  #TkPrimaryweight = uproot.open(filename)["Events"].array("l1tTkPrimaryVertexs_L1TkPrimaryVertex_TrkVertex_L1TrackMET.obj.sum_")
  TkPrimaryWeight = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays("pv_L1reco_sum")
  TkPrimaryWeight_array = np.zeros(len(TkPrimaryWeight))
  #TkVertextdr = uproot.open(filename)["Events"].array("l1tVertexs_VertexProducer_l1vertextdr_L1TrackMET.obj.z0_")
  #TkVertextdr_array = np.zeros(len(TkVertextdr))
  #TkVertex = uproot.open(filename)["Events"].array("l1tVertexs_VertexProducer_l1vertices_L1TrackMET.obj.z0_")
  #TkVertex_array = np.zeros(len(TkVertex))

  MCVertex = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays("pv_MC")
  MCVertex_array = np.zeros(len(MCVertex))

  for i in range(num_events):
    TkPrimaryVertex_array[i] =  TkPrimaryVertex[i]["pv_L1reco"][0]
    TkPrimaryWeight_array[i] =  TkPrimaryWeight[i]["pv_L1reco_sum"][0]
    MCVertex_array[i] = MCVertex[i]["pv_MC"][0]



  ref = pd.DataFrame({"Pv_z0" : TkPrimaryVertex_array[0:num_events], 
                      "Pv_weight" : TkPrimaryWeight_array[0:num_events], 
                      "MCVertex" : MCVertex_array[0:num_events]})
  if write_to_file:
    ref.to_csv("output_files/CMSSW_predictions.txt")
    return ref

  return ref



def loadMETInformation(filename,num_events=-1,write_to_file=False):

  MCMET = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays("trueMET")
  MCMET_array = np.zeros(len(MCMET))
  TrkMET = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays("trkMET")
  TrkMET_array = np.zeros(len(TrkMET))

  for i in range(num_events):
    MCMET_array[i] =  MCMET[i]["trueMET"]
    TrkMET_array[i] =  TrkMET[i]["trkMET"]

  ref = pd.DataFrame({"TrkMET" : TrkMET_array[0:num_events], 
                      "MCMET" : MCMET_array[0:num_events]
                      })

  if write_to_file:
    ref.to_csv("output_files/CMSSW_MET_predictions.txt")
    return ref

  return ref

