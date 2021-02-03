-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE constants IS

  CONSTANT MaxNstub     : INTEGER := 4;
  CONSTANT MaxBendChi2  : INTEGER := 3;
  CONSTANT MaxChi2Sum   : INTEGER := 16;
  CONSTANT MaxSplitChi2 : INTEGER := 9;
  CONSTANT MaxTrackPt   : INTEGER := 128;

  CONSTANT EtaBins : INTEGER_VECTOR := (0,270,386,464,619,773,928);
  CONSTANT DeltaZBins  : INTEGER_VECTOR := (3,5,6,8,14,18);

END constants;
