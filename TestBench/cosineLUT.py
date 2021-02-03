import numpy as np
from Formats import TrackWord_config
from Formats import toHWU,HWUto

precision = 2**8

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
  x = (x - tmin) / ((tmax - tmin) / (fracnbins-1))
  return round(x)

cos_LUT = [costoHWU(np.cos(i),lut_precision) for i in phi_iterator]
sin_LUT = [costoHWU(np.sin(i),lut_precision) for i in phi_iterator]


def toPhiHWU(t,fracnbins):
  tmin = -1.026
  tmax = +1.026

  x = tmax if t > tmax else t
  x = tmin if t < tmin else x
    # Get the bin index
  x = (x - tmin) / ((tmax - tmin) / (fracnbins-1))
  return round(x)



f = open("LUTS/TrigLUT.txt", "w")
for i in range(len(phi_iterator)):

  f.write(str(int(cos_LUT[i]))+",\n")

f.close()


f2 = open("LUTS/ShiftLUT.txt", "w")
for i in range(0,9):
  f2.write("("+str(i*2*toPhiHWU(-1.026+np.pi/9,precision))+"),\n")

f2.close()

f3 = open("LUTS/PhiBins.txt","w")
f3.write(str(int(0))+"\n")
f3.write(str(int(np.pi/(2*hwu_binsize)))+"\n")
f3.write(str(int(np.pi/(hwu_binsize)))+"\n")
f3.write(str(int(3*np.pi/(2*hwu_binsize)))+"\n")
f3.write(str(int(2*np.pi/(hwu_binsize)))+"\n")
f3.close()

f4 = open("LUTS/PhiParams.txt","w")
f4.write(str(int(precision/2))+"\n")
f4.write(str(0)+"\n")
f4.write(str(int(2*np.pi/(hwu_binsize)))+"\n")
f4.close()
