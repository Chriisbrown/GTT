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

-- .library Utilities

-- .include TopLevelInterfaces/mp7_data_types.vhd
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

LIBRARY Interfaces;
USE Interfaces.mp7_data_types.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY MP7CaptureFileReader IS
GENERIC( FileName                : STRING;
         StartFrameInclAnyHeader : INTEGER;
         GapLength               : INTEGER;
         HeaderLength            : INTEGER;
         PayloadLength           : INTEGER;
         DebugMessages           : IN BOOLEAN := FALSE
       );
PORT( clk        : IN STD_LOGIC;
        LinkData : OUT ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
     );
END ENTITY MP7CaptureFileReader;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF MP7CaptureFileReader IS

  TYPE tCurrentReadState IS( Uninitialized , Gap , Header , Payload , Finished );

-- -------------------------------------------------------------------------
  PROCEDURE READ( L : INOUT LINE ; VALUE : OUT lword ) IS
    VARIABLE TEMP   : CHARACTER;
  BEGIN
    READ( L , TEMP );
    READ( L , VALUE.valid );
    READ( L , TEMP );
    HREAD( L , VALUE.data );
  END PROCEDURE READ;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  PROCEDURE READ( L : INOUT LINE ; VALUE : OUT ldata( 71 DOWNTO 0 ) ) IS
    VARIABLE S      : STRING( 1 TO 12 );
  BEGIN
    READ( L , S ); -- "Frame XXXX : "
    FOR i IN 0 TO 71 LOOP
      READ( L , VALUE( i ) );
    END LOOP;
  END PROCEDURE READ;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  PROCEDURE WRITE( L : INOUT LINE ; VALUE : IN lword := LWORD_NULL ) IS
    VARIABLE TEMP    : CHARACTER;
  BEGIN
    WRITE( L , VALUE.valid );
    WRITE( L , STRING' ( "v" ) );
    HWRITE( L , VALUE.data );
  END PROCEDURE WRITE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
  PROCEDURE WRITE( L : INOUT LINE ; VALUE : IN ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL ) ) IS
  BEGIN
    FOR i IN 0 TO 71 LOOP
      WRITE( L , STRING' ( " " ) );
      WRITE( L , VALUE( i ) );
    END LOOP;
  END PROCEDURE WRITE;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
  PROCEDURE MP7CaptureFileReaderProc( FileName                : IN STRING;
                                      StartFrameInclAnyHeader : IN INTEGER;
                                      GapLength               : IN INTEGER;
                                      HeaderLength            : IN INTEGER;
                                      PayloadLength           : IN INTEGER;
                                      FILE InFile             : TEXT;
                                      CurrentReadState        : INOUT tCurrentReadState;
                                      Counter                 : INOUT INTEGER;
                                      LinkData                : INOUT ldata( 71 DOWNTO 0 );
                                      DebugMessages           : IN BOOLEAN := TRUE
                                    ) IS
    VARIABLE L , DEBUG : LINE;
  BEGIN
    IF CurrentReadState = Uninitialized THEN
-- Debug
      IF DebugMessages THEN
        WRITE( DEBUG , STRING' ( "UNINITIALIZED : " ) );
        WRITE( DEBUG , Counter );
        WRITELINE( OUTPUT , DEBUG );
      END IF;
-- Open File
      FILE_OPEN( InFile , FileName , READ_MODE );
-- Strip Headers
      FOR i IN 0 TO 2 LOOP
        READLINE( InFile , L );
        WRITELINE( OUTPUT , DEBUG );
      END LOOP;
-- Strip LinkData pre-header
      IF StartFrameInclAnyHeader > 0 THEN
        FOR i IN 0 TO StartFrameInclAnyHeader-1 LOOP
          READLINE( InFile , L );
          WRITELINE( OUTPUT , DEBUG );
        END LOOP;
      END IF;
-- We will return empty LinkData
      LinkData := ( OTHERS => LWORD_NULL );
-- We are changing state
      IF HeaderLength /= 0 THEN
        CurrentReadState := Header;
      ELSE
        CurrentReadState := Payload;
      END IF;
      Counter := 0;
      RETURN;
    END IF;

    IF CurrentReadState = Finished THEN
-- Debug
      IF DebugMessages THEN
        WRITE( DEBUG , STRING' ( "FINISHED" ) );
        WRITELINE( OUTPUT , DEBUG );
      END IF;
      LinkData := ( OTHERS => LWORD_NULL );
      Counter  := 0;
      RETURN;
    END IF;

    READLINE( InFile , L );

    CASE CurrentReadState IS
-- -------------------------------------------------------------------------
      WHEN Gap =>
-- Debug
        IF DebugMessages THEN
          WRITE( DEBUG , STRING' ( "GAP : " ) );
          WRITE( DEBUG , Counter );
          WRITELINE( OUTPUT , DEBUG );
        END IF;
-- We will return empty LinkData
        LinkData := ( OTHERS => LWORD_NULL );
        IF Counter = ( GapLength-1 ) THEN
-- We are changing state
          IF HeaderLength /= 0 THEN
            CurrentReadState := Header;
          ELSE
            CurrentReadState := Payload;
          END IF;
          Counter := 0;
        ELSE
          Counter := Counter + 1;
        END IF;
-- -------------------------------------------------------------------------
      WHEN Header =>
-- Debug
        IF DebugMessages THEN
          WRITE( DEBUG , STRING' ( "HEADER : " ) );
          WRITE( DEBUG , Counter );
          WRITELINE( OUTPUT , DEBUG );
        END IF;
        LinkData := ( OTHERS => LWORD_NULL );
        IF Counter = ( HeaderLength-1 ) THEN
-- We are changing state
          CurrentReadState := Payload;
          Counter          := 0;
        ELSE
          Counter := Counter + 1;
        END IF;
-- -------------------------------------------------------------------------
      WHEN Payload =>
        READ( L , LinkData );
-- Debug
        IF DebugMessages THEN
          WRITE( DEBUG , STRING' ( "PAYLOAD : " ) );
          WRITE( DEBUG , Counter );
          WRITE( DEBUG , STRING' ( " : " ) );
          WRITE( DEBUG , LinkData );
          WRITELINE( OUTPUT , DEBUG );
        END IF;
        IF Counter = ( PayloadLength-1 ) THEN
-- We are changing state
          CurrentReadState := Gap;
          Counter          := 0;
        ELSE
          Counter := Counter + 1;
        END IF;
-- -------------------------------------------------------------------------
      WHEN OTHERS =>
        WRITE( DEBUG , STRING' ( "SOMETHING HAS GONE WRONG" ) );
        WRITELINE( OUTPUT , DEBUG );
-- -------------------------------------------------------------------------
    END CASE;

    IF endfile( InFile ) THEN
      Counter          := 0;
      CurrentReadState := Finished;
      RETURN;
    END IF;

  END PROCEDURE MP7CaptureFileReaderProc;
-- -------------------------------------------------------------------------

BEGIN
  PROCESS( clk )
    FILE InFile               : TEXT;
    VARIABLE CurrentReadState : tCurrentReadState    := Uninitialized;
    VARIABLE Counter          : INTEGER              := 0;
    VARIABLE TempData         : ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
  BEGIN
    IF RISING_EDGE( clk ) THEN
      MP7CaptureFileReaderProc( FileName , StartFrameInclAnyHeader , GapLength , HeaderLength , PayloadLength , InFile , CurrentReadState , Counter , TempData , DebugMessages );
      LinkData               <= TempData;
      SimulationClockCounter <= SimulationClockCounter + 1;
    END IF;
  END PROCESS;
END ARCHITECTURE rtl;
