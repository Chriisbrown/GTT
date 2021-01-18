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

  CONSTANT EtaBins : INTEGER_VECTOR := (32768,41443,45161,47639,52596,57554,62511);
  CONSTANT DeltaZBins  : INTEGER_VECTOR := (3,5,6,8,14,18);

END constants;
