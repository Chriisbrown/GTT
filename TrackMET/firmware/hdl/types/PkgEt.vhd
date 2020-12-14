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

-- .library Vertex
-- .include ReuseableElements/PkgUtilities.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

LIBRARY Utilities;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE DataType IS

-- -------------------------------------------------------------------------       
  TYPE tData IS RECORD
    Px                 : SIGNED( 15 DOWNTO 0 );
    Py                 : SIGNED( 15 DOWNTO 0 );
    Sector             : UNSIGNED( 3 DOWNTO 0 );
    Et                 : UNSIGNED( 15 DOWNTO 0 );
 
    DataValid    : BOOLEAN;
    FrameValid   : BOOLEAN;
  END RECORD;
  
  ATTRIBUTE SIZE : NATURAL;
  ATTRIBUTE SIZE of tData : TYPE IS 52; -- Actual is 34, roundup to 36 for BRAM boundary

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    Pxl     : INTEGER;
    Pxh     : INTEGER;
    Pyl : INTEGER;
    Pyh : INTEGER;
    Sectorl : INTEGER;
    Sectorh : INTEGER;
    Etl : INTEGER;
    Eth : INTEGER;


  END RECORD;

  CONSTANT bitloc                      : tFieldLocations := ( 0 , 15 , 16 , 31, 32, 35,36,51); --, 24, 31);
  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ), false , false );

  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;
-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( tData'Size-1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lRet( bitloc.Pxh DOWNTO bitloc.Pxl )                     := STD_LOGIC_VECTOR( aData.Px );
    lRet( bitloc.Pyh DOWNTO bitloc.Pyl )                     := STD_LOGIC_VECTOR( aData.Py );
    lRet( bitloc.Sectorh DOWNTO bitloc.Sectorl )             := STD_LOGIC_VECTOR( aData.Sector );
    lRet( bitloc.Eth DOWNTO bitloc.Etl )                     := STD_LOGIC_VECTOR( aData.Et );
    lRet( bitloc.Eth + 1 )                                   := to_std_logic( aData.DataValid );
    
    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN
    lRet.Px           := SIGNED( aStdLogicVector( bitloc.Pxh DOWNTO bitloc.Pxl ) );
    lRet.Py           := SIGNED( aStdLogicVector( bitloc.Pyh DOWNTO bitloc.Pyl ) );
    lRet.Sector       := UNSIGNED( aStdLogicVector( bitloc.Sectorh DOWNTO bitloc.Sectorl ) );
    lRet.Et           := UNSIGNED( aStdLogicVector( bitloc.Eth DOWNTO bitloc.Etl ) );
    lRet.DataValid    := to_boolean( aStdLogicVector( bitloc.Sectorh + 1 ) );

    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "Px" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Py" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Sector" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Et" ) , RIGHT , 15 );

    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( aData.Px ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Py ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Sector ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Et ) , RIGHT , 15 );

    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

END DataType;
