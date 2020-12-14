import numpy as np
from Formats import TrackWord_config
from Formats import toHWU,HWUto
import util

tanl = np.linspace(0,7,2**16)
#eta = np.linspace(-2.5,2.5,2**20)
etagrid = np.zeros([2**3,2**12],dtype=np.int32)

eta=[]

for tanl_i in tanl:
    eta_i = -np.log(np.tan(0.5*np.arctan(1/abs(tanl_i))))

    tanl_int,tanl_frac = toHWU("TanL",tanl_i)

    try:
        eta_i = int(toHWU("HWUeta",eta_i) )
    except ValueError:
        eta_i = 0
    eta.append(eta_i)
    etagrid[int(tanl_int)][tanl_frac] = eta_i
    

f = open("TanLUT.txt", "w")
for i in range((2**12)):
  f.write("(")
  line = [(str(etagrid[j][i])+",") for j in range(2**3)]
  line[-1] = line[-1][:-1]
  [f.write(l) for l in line]
  f.write("),\n")

f.close()

#import matplotlib.pyplot as plt
#plt.scatter(tanl,eta)
#plt.show() 


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
