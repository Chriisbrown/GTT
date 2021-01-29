import numpy as np
from Formats import TrackWord_config
from Formats import toHWU,HWUto

precision = 2**11

hwu_binsize = 2*1.026/(precision-1)
phi_iterator = np.linspace(0,np.pi/2,round(np.pi/(2*hwu_binsize)))
lut_precision = precision



def costoHWU(t,fracnbins):

  fracnbins = fracnbins
  tmin = 0
  tmax = 1

  x = tmax if t > tmax else t
  x = tmin if t < tmin else x
    # Get the bin index
  x = (x - tmin) / ((tmax - tmin) / fracnbins)
  return round(x)

cos_LUT = [costoHWU(np.cos(i),lut_precision) for i in phi_iterator]
sin_LUT = [costoHWU(np.sin(i),lut_precision) for i in phi_iterator]





f = open("TrigLUT.txt", "w")
for i in range(len(phi_iterator)):

  f.write("("+str(int(cos_LUT[i]))+","+str(int(sin_LUT[i]))+"),\n")

f.close()


f2 = open("ShiftLUT.txt", "w")
for i in range(0,9):
  f2.write("("+str(i*2*toHWU("Phi",-1.026+np.pi/9))+"),\n")

f2.close()


