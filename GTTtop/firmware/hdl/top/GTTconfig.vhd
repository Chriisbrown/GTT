-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

LIBRARY GTT;
USE GTT.GTTDataFormats.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE GTTconfig IS

CONSTANT NumInputLinks : NATURAL := 18;
CONSTANT MaxMETMag     : NATURAL := 4096;

-- Scale factors to take TTTrack Input widths to internal widths
CONSTANT TrackZ0Scale  : INTEGER := widthZ0 - VertexZ0Width;
CONSTANT TrackPtScale  : INTEGER := widthInvR - PtWidth;
CONSTANT TrackEtaScale : INTEGER := widthTanL - EtaWidth;
CONSTANT TrackPhiScale : INTEGER := widthPhi0 - (GlobalPhiWidth - GlobalPhiWidthExtra);


CONSTANT MaxZ0         : INTEGER := (2 ** VertexZ0Width ) - 1;
CONSTANT MaxPt     : NATURAL := 512;

-- Local to Global Phi Conversion Config
CONSTANT PhiShift : INTEGER := 2**(GlobalPhiWidth-GlobalPhiWidthExtra) - 1; --Initial Shift to put edge of bin at 0 rad
CONSTANT PhiMin : INTEGER := 0;            
CONSTANT PhiMax : INTEGER := 1020;   --2pi in integer format

constant Phi_shift : INTEGER_VECTOR := (0,
                                        113,
                                        226,
                                        340,
                                        453,
                                        566,
                                        680,
                                        793,
                                        906,
                                        0,
                                        113,
                                        226,
                                        340,
                                        453,
                                        566,
                                        680,
                                        793,
                                        906
                                          );

-- Track Quality Cuts

CONSTANT MaxNstub     : INTEGER := 4;
CONSTANT MaxBendChi2  : INTEGER := 3;
CONSTANT MaxChi2Sum   : INTEGER := 16;
CONSTANT MaxSplitChi2 : INTEGER := 8;
CONSTANT MaxTrackPt   : INTEGER := 129; --2 GeV in integer format


-- Eta bins for track to vertex association windows
CONSTANT EtaBins : INTEGER_VECTOR := (0,
                                      358,
                                      512,
                                      614,
                                      819,
                                      1024,
                                      1228);
-- Z0 tolerance for each eta bin
CONSTANT DeltaZBins  : INTEGER_VECTOR := (2,
                                          3,
                                          4,
                                          6,
                                          10,
                                          13);


-- pi/2 phi bins for accessing cos LUT
CONSTANT PhiBins : INTEGER_VECTOR := (0,
                                      255,
                                      510,
                                      764,
                                      1020);



END GTTconfig;
