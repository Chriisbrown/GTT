-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
-- -------------------------------------------------------------------------
LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;
-- -------------------------------------------------------------------------
PACKAGE constants IS

TYPE   EtArray   IS ARRAY (0 to (2*NumInputLinks) - 1) OF SIGNED( PtWidth DOWNTO 0 );


CONSTANT CordicSteps : INTEGER := 8;

CONSTANT CordicPhiScale : INTEGER := 2**METPhiWidth;


END constants;
