-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE constants IS

TYPE   EtArray   IS ARRAY (0 to 35) OF SIGNED( 15 DOWNTO 0 );

CONSTANT PhiBins : INTEGER_VECTOR := (0,195,390,585,780);
CONSTANT CordicSteps : INTEGER := 4;
CONSTANT CordicNormalisation : INTEGER := 39;

--CONSTANT MACNormalisation : INTEGER := 4096;
--CONSTANT EtScale : INTEGER := 65536;
END constants;
