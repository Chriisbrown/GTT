import util_funcs
import DualLinkFormat

import sys
import os

os.system("rm full_precision_input.csv")
#index_num = int(sys.argv[1])


model_parameters = ["trk_chi2","trk_bendchi2","trk_chi2rphi", "trk_chi2rz", "pred_nstub",
                        "pred_layer1","pred_layer2","pred_layer3","pred_layer4","pred_layer5","pred_layer6","pred_disk1","pred_disk2","pred_disk3",
                        "pred_disk4","pred_disk5","InvR","TanL","trk_z0","pred_dtot","pred_ltot"]


events = util_funcs.loadDataSingleFile("/home/cb719/Documents/TrackFinder/Data/hybrid10kv11.root",[0,100])
linked_events = []

for i,event in enumerate(events):
    event = util_funcs.predhitpattern(event)
    if i % 100 == 0:
        print(i)

    sample_event = util_funcs.resample_event(event)
    

    if len(sample_event) > 0:


        temp = model_parameters + ["trk_fake"]

        #trunc_sample_event = util_funcs.trunc_data(sample_event)
        

        sample_event.to_csv("full_precision_input.csv",columns=temp,index=False,header=False,mode='a')
        bit_event = util_funcs.bitdata(sample_event)
        sample_event = DualLinkFormat.assignLinksRandom(bit_event, nlinks=2)
        linked_events.append(sample_event)

    
DualLinkFormat.writepfile("input.txt", linked_events, nlinks=2, emptylinks_valid=True)


    
