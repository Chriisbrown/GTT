-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

USE work.FunkyMiniBus.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY GenRomClocked IS
  GENERIC(
          FileName : STRING
         );
  PORT(
        clk       : IN STD_LOGIC; -- The algorithm clock
        AddressIn : IN STD_LOGIC_VECTOR;
        DataOut   : OUT STD_LOGIC_VECTOR
      );
END ENTITY GenRomClocked;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF GenRomClocked IS

  CONSTANT WidthIn  : INTEGER := AddressIn'LENGTH;
  CONSTANT WidthOut : INTEGER := DataOut'LENGTH;

  TYPE mem_type IS ARRAY( 0 TO( 2 ** WidthIn ) -1 ) OF STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 );

  IMPURE FUNCTION InitRomFromFile( RomFileName : IN STRING ) RETURN mem_type IS
    FILE RomFile                               : TEXT;
    VARIABLE RomFileLine , Debug               : LINE;
    VARIABLE TEMP                              : CHARACTER;
    VARIABLE Value                             : STD_LOGIC_VECTOR( 19 DOWNTO 0 );
    VARIABLE ROM                               : mem_type;
  BEGIN

    FILE_OPEN( RomFile , RomFileName , READ_MODE );

    FOR i IN mem_type'RANGE LOOP
      READLINE( RomFile , RomFileLine );
      READ( RomFileLine , TEMP );
      READ( RomFileLine , TEMP );
      HREAD( RomFileLine , Value );
      rom( i ) := Value( WidthOut -1 DOWNTO 0 );
    END LOOP;
    FILE_CLOSE( RomFile );

    RETURN ROM;
  END FUNCTION InitRomFromFile;

  SHARED VARIABLE ROM        : mem_type := InitRomFromFile( FileName );

  ATTRIBUTE rom_style        : STRING;
  ATTRIBUTE rom_style OF ROM : VARIABLE IS "block";

BEGIN

-- LUT port
  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      DataOut <= ROM( TO_INTEGER( UNSIGNED( AddressIn ) ) );
    END IF;
  END PROCESS;


END ARCHITECTURE rtl;
