import numpy as np
import util
import math

int_precision = 2**3
frac_precision = 2**7
eta_precision = int_precision*frac_precision

etagrid = np.zeros([int_precision,frac_precision],dtype=np.int32)
newtanl_intbins  = 7/(int_precision-1)
newtanl_fracbins = 1/(frac_precision -1) 
neweta_bins      = 2.644120761058629/(eta_precision-1)
tanl = np.linspace(0,7,eta_precision)
    #### POPULATE LUT ########
for tanl_i in tanl:
    eta_i = -np.log(np.tan(0.5*np.arctan(1/abs(tanl_i))))
    tanl_int = math.modf(tanl_i)[1]
    tanl_frac = math.modf(tanl_i)[0]

    hwu_tanl_int  = int(tanl_int/newtanl_intbins)
    hwu_tanl_frac = int(tanl_frac/newtanl_fracbins)

    try:
        hwu_eta = int(eta_i/neweta_bins)
    except ValueError:
        eta_i = 0



    etagrid[hwu_tanl_int][hwu_tanl_frac] = hwu_eta
    

f = open("LUTS/TanLUT.txt", "w")
for i in range(frac_precision):
  f.write("(")
  line = [(str(etagrid[j][i])+",") for j in range(2**3-1)]
  line[-1] = line[-1][:-1]
  [f.write(l) for l in line]
  f.write("),\n")

f.close()

f = open("LUTS/etabins.txt", "w")
f.write(str(int(0/neweta_bins))+"\n"
           +str(int(0.7/neweta_bins))+"\n"
           +str(int(1.0/neweta_bins))+"\n"
           +str(int(1.2/neweta_bins))+"\n"
           +str(int(1.6/neweta_bins))+"\n"
           +str(int(2.0/neweta_bins))+"\n"
           +str(int(2.4/neweta_bins)))
  
f.close()


#import matplotlib.pyplot as plt
#plt.scatter(tanl,eta)
#plt.show() 

'''
eta_test = np.linspace(-2.5,2.5,2**16)
tanl_test = util.tanL(eta_test)
TanLUTf = open("TanLUT.txt")
TanLUTlines = TanLUTf.readlines()

LUTeta = []
realeta = []
for i,tanl in enumerate(tanl_test):
    tanl_int,tanl_frac = toHWU("TanL",tanl)
    temp_str = TanLUTlines[int(tanl_frac)].split(",")[int(tanl_int)]
    
    if temp_str[0] == '(':
        eta = int(temp_str[1:])
    elif temp_str[-1] == ')':
        eta = int(temp_str[:-1])
    else:
         eta = int(temp_str)

    if eta_test[i] < 0:
        sign = -1
        eta = 2**16 - eta 
    else:
        eta = eta
        sign = 1
        

    LUTeta.append(eta)
    realeta.append(int(toHWU("HWUeta",sign*eta_test[i]) ))
    
    
import matplotlib.pyplot as plt
plt.scatter(eta_test,LUTeta)
plt.show() 
'''

eta_precision = 2**10

etagrid = np.zeros([eta_precision],dtype=np.int32)
newtanl_intbins  = 8/(eta_precision-1)
neweta_bins      = 2.644120761058629/(eta_precision-1)
tanl = np.linspace(0,8,eta_precision)
    #### POPULATE LUT ########
for tanl_i in tanl:
    eta_i = -np.log(np.tan(0.5*np.arctan(1/abs(tanl_i))))

    hwu_tanl = int(tanl_i/newtanl_intbins)

    try:
        hwu_eta = int(eta_i/neweta_bins)
    except ValueError:
        eta_i = 0



    etagrid[hwu_tanl] = hwu_eta
    

f = open("LUTS/TanLUT.txt", "w")
for i in range(eta_precision):
  f.write(str(etagrid[i]))
  f.write(",\n")

f.close()