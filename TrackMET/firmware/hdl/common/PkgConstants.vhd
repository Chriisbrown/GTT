-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE constants IS

CONSTANT PhiBins : INTEGER_VECTOR := (0,1567,3134,4701,6268);
CONSTANT CordicSteps : INTEGER := 4;
CONSTANT CordicNormalisation : INTEGER := 39901;

CONSTANT MACNormalisation : INTEGER := 4096;
EtScale : INTEGER := 65536
END constants;
