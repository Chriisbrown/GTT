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

-- .include ReuseableElements/PkgDebug.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

USE work.DataType.ALL;
USE work.ArrayTypes.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;

-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY Debug IS
  GENERIC(
    FileName : STRING;
    FilePath : STRING := Path -- Path from Utilities.debugging
  );
  PORT(
    clk    : IN STD_LOGIC;
    DataIn : IN Vector
  );
END Debug;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF Debug IS
BEGIN
-- pragma synthesis_off
  PROCESS( Clk )
    FILE f     : TEXT OPEN write_mode IS FilePath & FileName & ".txt";
    VARIABLE s : LINE;
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF SimulationClockCounter < 0 THEN
        WRITE( s , FileName );
        WRITE( s , STRING' ( "     |     " ) );
        WRITE( s , TimeStamp );
        WRITELINE( f , s );

        WRITE( s , STRING' ( "Clock" ) , RIGHT , 15 );
        WRITE( s , STRING' ( "Index" ) , RIGHT , 15 );
        WRITE( s , WriteHeader );
        WRITELINE( f , s );
      ELSE
        FOR i IN DataIn'RANGE LOOP
          IF DataIn( i ) .DataValid THEN
            WRITE( s , SimulationClockCounter , RIGHT , 15 );
            WRITE( s , i , RIGHT , 15 );
            WRITE( s , WriteData( DataIn( i ) ) );
            WRITELINE( f , s );
          END IF;
        END LOOP;
      END IF;
    END IF;
  END PROCESS;
-- pragma synthesis_on    
END ARCHITECTURE rtl;
