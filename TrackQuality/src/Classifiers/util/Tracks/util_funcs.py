import uproot
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import pickle
import os

def pttoR(pt):
    B = 3.8112 #Tesla for CMS magnetic field

    return abs((B*(3e8/1e11))/(2*pt))

def tanL(eta):
    return abs(np.sinh(eta))

def logChi(chi2):
    return np.log(chi2)

def sum_digits3(N):
  R = np.zeros(len(N))

  for i in range(len(N)):
    n = N[i]
    r = 0
    while n:

      r, n = r + n % 10, n // 10
    R[i] = r
  return R

def nhotdisk(dataframe):

    disk = dataframe["trk_dhits"].astype(str)
    dataframe["disk1"] = np.zeros([len(disk)])
    dataframe["disk2"] = np.zeros([len(disk)])
    dataframe["disk3"] = np.zeros([len(disk)])
    dataframe["disk4"] = np.zeros([len(disk)])
    dataframe["disk5"] = np.zeros([len(disk)])

    for i in range(len(disk)):
        for k in range(len(disk[i])):
            dataframe["disk"+str(k+1)][i] = disk[i][-(k+1)]

    return(dataframe)

def nhotlayer(dataframe):
    layer = dataframe["trk_lhits"].astype(str)

    dataframe["layer1"] = np.zeros([len(layer)])
    dataframe["layer2"] = np.zeros([len(layer)])
    dataframe["layer3"] = np.zeros([len(layer)])  
    dataframe["layer4"] = np.zeros([len(layer)])
    dataframe["layer5"] = np.zeros([len(layer)])
    dataframe["layer6"] = np.zeros([len(layer)])

    for i in range(len(layer)):
        for j in range(len(layer[i])):
            dataframe["layer"+str(j+1)][i] = layer[i][-(j+1)]

    return(dataframe)

def predhitpattern(dataframe):
  

    hitpat = [str(bin(dataframe["trk_hitpattern"][i])) for i in range(len(dataframe["trk_hitpattern"]))]


    hit_array = np.zeros([7,len(hitpat)])
    expanded_hit_array = np.zeros([12,len(hitpat)])
    ltot = np.zeros(len(hitpat))
    dtot = np.zeros(len(hitpat))
    for i in range(len(hitpat)):
        for k in range(len(hitpat[i])-2):
            hit_array[k,i] = hitpat[i][-(k+1)]

    eta_bins = [0.0,0.2,0.41,0.62,0.9,1.26,1.68,2.08,2.5]
    conversion_table = np.array([[0, 1,  2,  3,  4,  5,  11],
                                 [0, 1,  2,  3,  4,  5,  11],
                                 [0, 1,  2,  3,  4,  5,  11],
                                 [0, 1,  2,  3,  4,  5,  11],
                                 [0, 1,  2,  3,  4,  5,  11],
                                 [0, 1,  2,  6,  7,  8,  9 ],
                                 [0, 1,  7,  8,  9, 10,  11],
                                 [0, 6,  7,  8,  9, 10,  11]])

    for i in range(len(hitpat)):
        #print(dataframe["trk_eta"][i])
        for j in range(8):
            if ((abs(dataframe["trk_eta"][i]) >= eta_bins[j]) & (abs(dataframe["trk_eta"][i]) < eta_bins[j+1])):
                for k in range(7):
                    expanded_hit_array[conversion_table[j][k]][i] = hit_array[k][i]


        ltot[i] = sum(expanded_hit_array[0:6,i])
        dtot[i] = sum(expanded_hit_array[6:11,i])

    
    dataframe["pred_layer1"] = expanded_hit_array[0,:]
    dataframe["pred_layer2"] = expanded_hit_array[1,:]
    dataframe["pred_layer3"] = expanded_hit_array[2,:]
    dataframe["pred_layer4"] = expanded_hit_array[3,:]
    dataframe["pred_layer5"] = expanded_hit_array[4,:]
    dataframe["pred_layer6"] = expanded_hit_array[5,:]
    dataframe["pred_disk1"] = expanded_hit_array[6,:]
    dataframe["pred_disk2"] = expanded_hit_array[7,:]
    dataframe["pred_disk3"] = expanded_hit_array[8,:]
    dataframe["pred_disk4"] = expanded_hit_array[9,:]
    dataframe["pred_disk5"] = expanded_hit_array[10,:]
    dataframe["pred_ltot"] = ltot
    dataframe["pred_dtot"] = dtot
    dataframe["pred_nstub"] = dtot + ltot



    return dataframe

def single_predhitpattern(hit_int,tanL):
    
    hitpat = str(bin(hit_int))
    hitpattern = np.zeros([7])

    for k in range(len(hitpat)-2):
      hitpattern[k] = hitpat[-(k+1)]

    
    #tanL scaling mean = -1.84935589 scale = 1.47322569
    # in 12 bit: mean = -160.6797625 scale = 86.88417591
    #if ((tanL >= 0.0) & (tanL < 1.620883730432806)):
    #if ((tanL >= -161) & (tanL < -20)):
    if ((tanL >= 0.0) & (tanL < 6639)):
      pred_layer1 = hitpattern[0]
      pred_layer2 = hitpattern[1]
      pred_layer3 = hitpattern[2]
      pred_layer4 = hitpattern[3]
      pred_layer5 = hitpattern[4]
      pred_layer6 = hitpattern[5]
      pred_disk1 = 0
      pred_disk2 = 0
      pred_disk3 = 0
      pred_disk4 = 0
      pred_disk5 = 0
    #elif ((tanL >= 1.620883730432806) & (tanL < 2.5895909975412823)):
    elif ((tanL >= 6639) & (tanL < 10607)):
    #elif ((tanL >= -20) & (tanL < 64)):  
      pred_layer1 = hitpattern[0]
      pred_layer2 = hitpattern[1]
      pred_layer3 = hitpattern[2]
      pred_layer4 = 0
      pred_layer5 = 0
      pred_layer6 = 0
      pred_disk1 = hitpattern[3]
      pred_disk2 = hitpattern[4]
      pred_disk3 = hitpattern[5]
      pred_disk4 = hitpattern[6]
      pred_disk5 = 0
    #elif ((tanL >= 2.5895909975412823) & (tanL < 3.9397693510488856)):
    elif ((tanL >= 10607) & (tanL < 16137)):
    #elif ((tanL >= 64) & (tanL < 181)):
      pred_layer1 = hitpattern[0]
      pred_layer2 = hitpattern[1]
      pred_layer3 = 0
      pred_layer4 = 0
      pred_layer5 = 0
      pred_layer6 = 0
      pred_disk1 = 0
      pred_disk2 = hitpattern[2]
      pred_disk3 = hitpattern[3]
      pred_disk4 = hitpattern[4]
      pred_disk5 = hitpattern[5]
    #elif ((tanL >= 3.9397693510488856) & (tanL < 6.0502044810397875)):
    elif ((tanL >= 16137) & (tanL < 24781)):
    #elif ((tanL >= 181) & (tanL < 365)):
      pred_layer1 = hitpattern[0]
      pred_layer2 = 0
      pred_layer3 = 0
      pred_layer4 = 0
      pred_layer5 = 0
      pred_layer6 = 0
      pred_disk1 = hitpattern[1]
      pred_disk2 = hitpattern[2]
      pred_disk3 = hitpattern[3]
      pred_disk4 = hitpattern[4]
      pred_disk5 = hitpattern[5]
    else:
      pred_layer1 = 0
      pred_layer2 = 0
      pred_layer3 = 0
      pred_layer4 = 0
      pred_layer5 = 0
      pred_layer6 = 0
      pred_disk1 = 0
      pred_disk2 = 0
      pred_disk3 = 0
      pred_disk4 = 0
      pred_disk5 = 0

    pred_ltot= pred_layer1 + pred_layer2 + pred_layer3 + pred_layer4 + pred_layer5 + pred_layer6
    pred_dtot = pred_disk1 + pred_disk2 + pred_disk3 + pred_disk4 + pred_disk5
    pred_nstub = pred_dtot + pred_ltot

    return [pred_layer1,pred_layer2,
           pred_layer3,pred_layer4,
           pred_layer5,pred_layer6,
           pred_disk1,pred_disk2,
           pred_disk3,pred_disk4,
           pred_disk5,pred_dtot,
           pred_ltot,pred_nstub]


def noscale_transformData(dataframe):
    dataframe["InvR"] = pttoR(dataframe["trk_pt"])
    dataframe["TanL"] = tanL(dataframe["trk_eta"])
    dataframe["trk_chi2"] = dataframe["trk_chi2rphi"]+dataframe["trk_chi2rz"]

    return dataframe


def bendchi_2_bins(trk_bendchi2):
  if ((trk_bendchi2 >= 0.0) & (trk_bendchi2 < 0.5)):
    return 0
  elif ((trk_bendchi2 >= 0.5) & (trk_bendchi2 < 1.25)):
    return 1
  elif ((trk_bendchi2 >= 1.25) & (trk_bendchi2 < 2)):
    return 2
  elif ((trk_bendchi2 >= 2) & (trk_bendchi2 < 3)):
    return 3
  elif ((trk_bendchi2 >= 3) & (trk_bendchi2 < 5)):
    return 4
  elif ((trk_bendchi2 >= 5) & (trk_bendchi2 < 10)):
    return 5
  elif ((trk_bendchi2 >= 10) & (trk_bendchi2 < 50)):
    return 6
  else: 
    return 7

def chi_2_bins(trk_chi2):
  if ((trk_chi2 >= 0.0) & (trk_chi2 < 0.25)):
    return 0
  elif ((trk_chi2 >= 0.25) & (trk_chi2 < 0.5)):
    return 1
  elif ((trk_chi2 >= 0.5) & (trk_chi2 < 1)):
    return 2
  elif ((trk_chi2 >= 1.0) & (trk_chi2 < 2)):
    return 3
  elif ((trk_chi2 >= 2) & (trk_chi2 < 3)):
    return 4
  elif ((trk_chi2 >= 3) & (trk_chi2 < 5)):
    return 5
  elif ((trk_chi2 >= 5) & (trk_chi2 < 7)):
    return 6
  elif ((trk_chi2 >= 7) & (trk_chi2 < 10)):
    return 7
  elif ((trk_chi2 >= 10) & (trk_chi2 < 20)):
    return 8
  elif ((trk_chi2 >= 20) & (trk_chi2 < 40)):
    return 9
  elif ((trk_chi2 >= 40) & (trk_chi2 < 100)):
    return 10
  elif ((trk_chi2 >= 100) & (trk_chi2 < 200)):
    return 11
  elif ((trk_chi2 >= 200) & (trk_chi2 < 500)):
    return 12
  elif ((trk_chi2 >= 500) & (trk_chi2 < 1000)):
    return 13
  elif ((trk_chi2 >= 1000) & (trk_chi2 < 3000)):
    return 14
  else: 
    return 15
  


    

def splitter(x,int_len,frac_len):

    dec_len = frac_len-int_len

    return int(x*(2**dec_len))

def bitdata(dataframe):
  #print(dataframe["trk_z0"].describe())

  fields = ["trk_chi2","trk_bendchi2","trk_chi2rphi", "trk_chi2rz", "trk_hitpattern","trk_d0","trk_phi",
            "InvR","TanL","trk_z0"]

  # int_length = max of feature in base 2
  # frac_length = bit width in track word
  # -1 off bit width if signed integer

  dataframe.loc[:,"bit_bendchi2"] = dataframe["trk_bendchi2"].apply(bendchi_2_bins)
  dataframe.loc[:,"bit_chi2rphi"] = dataframe["trk_chi2rphi"].apply(chi_2_bins)
  dataframe.loc[:,"bit_chi2rz"] = dataframe["trk_chi2rz"].apply(chi_2_bins)



  dataframe.loc[:,"bit_phi"] = dataframe["trk_phi"].apply(splitter,int_len=0,frac_len=7)
  dataframe.loc[:,"bit_TanL"] = dataframe["TanL"].apply(splitter,int_len=3,frac_len=15)
  dataframe.loc[:,"bit_z0"] = dataframe["trk_z0"].apply(splitter,int_len=5,frac_len=11)
  dataframe.loc[:,"bit_d0"] = dataframe["trk_d0"]*0
  dataframe.loc[:,"bit_hitpattern"] = dataframe["trk_hitpattern"].apply(splitter,int_len=7,frac_len=7)
  dataframe.loc[:,"bit_InvR"] = dataframe["InvR"].apply(splitter,int_len=0,frac_len=14)


  
  dataframe.loc[:,"trk_fake"].values[dataframe["trk_fake"].values > 0] = 1

  return dataframe






def loadDataSingleFile(filename,num,bit=False):
  """
  New method for loading training events. It assumes that only one root file is available (as a result of hadd command)
  """

  # check if filename links to a valid file
  if (not os.path.isfile(filename)):
    raise FileNotFoundError("Trying to load data from a file that does not exist: %s" % filename)

  #noevts = len(uproot.open(filename)['L1TrackNtuple/eventTree'])

  features = ["trk_chi2","trk_bendchi2","trk_chi2rphi", "trk_chi2rz", "trk_hitpattern","trk_d0","trk_phi",
              "InvR","TanL","trk_z0"]

  branches = ['trk_fake','trk_pt','trk_z0','trk_chi2rphi','trk_chi2rz','trk_phi','trk_eta','trk_chi2','trk_bendchi2','trk_d0','trk_hitpattern']
  events = [{}] * (num[1]-num[0])

  long_to_short = {'trk_fake':'trk_fake','trk_pt':'trk_pt','trk_z0':'trk_z0','trk_chi2rphi':'trk_chi2rphi',
                   'trk_chi2rz':'trk_chi2rz','trk_phi':'trk_phi','trk_eta':'trk_eta','trk_chi2':'trk_chi2',
                   'trk_bendchi2':'trk_bendchi2','trk_d0':'trk_d0','trk_hitpattern':'trk_hitpattern'}


  # Read the relevant branches into a list of events
  events = {}
  for branch in branches:
    events[long_to_short[branch]] = []

  # for i in range(1, 89):
  data = uproot.open(filename)["L1TrackNtuple"]["eventTree"].arrays(branches)
  

  for branch in data:
    for i,event in enumerate(data[branch]):
      if i > num[0] & i <= num[1]:  
        events[long_to_short[branch.decode("utf-8")]].append(event)
    

  # Pivot from dict of lists of arrays to list of dicts of arrays
  x = []
  for i in range((num[1]-num[0])):
    y = {}
    for branch in branches:
      y[long_to_short[branch]] = events[long_to_short[branch]][i]
    temp = pd.DataFrame(noscale_transformData(y))


    

    infs = np.where(np.asanyarray(np.isnan(temp)))[0]
    temp.drop(infs,inplace=True)
    if bit: (bitdata(temp))

    x.append(temp)
  events = x

  # Add some fields used to weight tracks
  

  return events 


def load_transformed_data(name,num_entries=100):
    store = pd.HDFStore(name+'.h5') 
    dataframe = store['df']
    store.close()
    return dataframe[0:num_entries]


def resample_event(event):
  import random
  

  fake_index = []
  true_index = []

  for index, row in event.iterrows():
    if row["trk_fake"] == 0:
      fake_index.append(index)
    else:
      true_index.append(index)

  
  true_index = random.sample(true_index,len(fake_index))


  
  fake_index.extend(true_index)


  
  return(event[event.index.isin(fake_index)])


    