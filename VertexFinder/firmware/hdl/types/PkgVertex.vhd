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
    Z0           : UNSIGNED( 7 DOWNTO 0 );
    Weight       : UNSIGNED( 15 DOWNTO 0 );
-- Utility field, used for the key in the distribution server and the row index in the histogram
    SortKey      : INTEGER RANGE 0 TO 255;
-- -------------------------------------------------------------------------       
    --MaximaOffset : INTEGER RANGE -7 TO 7;
-- -------------------------------------------------------------------------       
    DataValid    : BOOLEAN;
    FrameValid   : BOOLEAN;
  END RECORD;
  
  ATTRIBUTE SIZE : NATURAL;
  ATTRIBUTE SIZE of tData : TYPE IS 36; -- Actual is 34, roundup to 36 for BRAM boundary

-- A record to encode the bit location of each field of the tData record
-- when packaged into a std_logic_vector
  TYPE tFieldLocations IS RECORD
    z0l     : INTEGER;
    z0h     : INTEGER;
    Weightl : INTEGER;
    Weighth : INTEGER;
--SortKeyl : integer;
--SortKeyh : integer;
--MaximaOffsetl : integer;
--MaximaOffseth : integer;
--DV : integer;
--FV : integer;
  END RECORD;

  CONSTANT bitloc                      : tFieldLocations := ( 0 , 7 , 8 , 23 ); --, 24, 31);
--CONSTANT cNull : tData := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , ( OTHERS => '0' ) , 0 , -- S , X , Y , N
--  0 , -7 , -- SortKey , MaximaOffset
--  FALSE , FALSE ); -- DataValid , FrameValid 
  CONSTANT cNull                       : tData           := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , 0 , false , false );

  FUNCTION "+" ( Left , Right          : tData ) RETURN tData;
--FUNCTION "/" ( Numerator             : tData ; Denomentator : INTEGER ) RETURN tData;
  FUNCTION ">" ( Left , Right          : tData ) RETURN BOOLEAN;


  FUNCTION ToStdLogicVector( aData     : tData ) RETURN STD_LOGIC_VECTOR;
  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData;

  FUNCTION WriteHeader RETURN STRING;
  FUNCTION WriteData( aData : tData ) RETURN STRING;
-- -------------------------------------------------------------------------       

END DataType;
-- -------------------------------------------------------------------------



-- -------------------------------------------------------------------------
PACKAGE BODY DataType IS

  FUNCTION "+" ( Left , Right : tData ) RETURN tData IS
    VARIABLE lRet             : tData := cNull;
    VARIABLE lWeight          : UNSIGNED(bitloc.weightH - bitloc.weightL + 1 downto 0) := (others => '0');
    VARIABLE rWeight          : UNSIGNED(bitloc.weightH - bitloc.weightL + 1 downto 0) := (others => '0');
    VARIABLE WeightSum        : UNSIGNED(bitloc.weightH - bitloc.weightL + 1 downto 0) := (others => '0');
  BEGIN
    lRet.Z0           := Left.Z0;
    --lRet.Weight       := Left.Weight + Right.Weight;
    lRet.SortKey      := Left.SortKey;
    --lRet.MaximaOffset := Left.MaximaOffset;
    lRet.FrameValid   := Left.FrameValid;
    lRet.DataValid    := Left.DataValid;
    -- Sum the weights, with saturation in the event of overflow
    lWeight(lweight'high - 1 downto 0) := Left.Weight;
    rWeight(rweight'high - 1 downto 0) := Right.Weight;
    WeightSum         := lWeight + rWeight;
    IF WeightSum(WeightSum'high) = '1' THEN -- Overflow
      lRet.Weight     := (others => '1');
    ELSE
      lRet.Weight     := WeightSum(WeightSum'high - 1 downto 0);
    END IF;
    RETURN lRet;
  END FUNCTION "+";

--FUNCTION "/" ( Numerator : tData ; Denomentator : INTEGER ) RETURN tData IS
--  VARIABLE lRet          : tData := cNull;
--BEGIN
--  lRet.S            := TO_SIGNED( TO_INTEGER( Numerator.S ) / Denomentator , 16 );
--  lRet.X            := TO_SIGNED( TO_INTEGER( Numerator.X ) / Denomentator , 25 );
--  lRet.Y            := TO_SIGNED( TO_INTEGER( Numerator.Y ) / Denomentator , 25 );
--  lRet.N            := Numerator.N;

--  lRet.SortKey      := Numerator.SortKey;
--  lRet.MaximaOffset := Numerator.MaximaOffset;
--  lRet.FrameValid   := Numerator.FrameValid;
--  lRet.DataValid    := Numerator.DataValid;

--  RETURN lRet;
--END FUNCTION "/";

  FUNCTION ">" ( Left , Right : tData ) RETURN BOOLEAN IS
  BEGIN
    IF Left.Weight > Right.Weight THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END FUNCTION;



  FUNCTION ToStdLogicVector( aData : tData ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE lRet                  : STD_LOGIC_VECTOR( tData'Size-1 DOWNTO 0 ) := ( OTHERS => '0' );
  BEGIN
    lRet( bitloc.z0h DOWNTO bitloc.z0l )                 := STD_LOGIC_VECTOR( aData.z0 );
    lRet( bitloc.weighth DOWNTO bitloc.weightl )         := STD_LOGIC_VECTOR( aData.Weight );
    lRet( bitloc.weighth + 1 )                           := to_std_logic( aData.DataValid );
    lRet( bitloc.weighth + 9 DOWNTO bitloc.weighth + 2 ) := STD_LOGIC_VECTOR( TO_UNSIGNED( aData.SortKey , 8 ) );
    RETURN lRet;
  END FUNCTION;

  FUNCTION ToDataType( aStdLogicVector : STD_LOGIC_VECTOR ) RETURN tData IS
    VARIABLE lRet                      : tData := cNull;
  BEGIN
    lRet.z0        := UNSIGNED( aStdLogicVector( bitloc.z0h DOWNTO bitloc.z0l ) );
    lRet.Weight    := UNSIGNED( aStdLogicVector( bitloc.weighth DOWNTO bitloc.weightl ) );
    lRet.DataValid := to_boolean( aStdLogicVector( bitloc.weighth + 1 ) );
    lRet.SortKey   := TO_INTEGER( UNSIGNED( aStdLogicVector( bitloc.weighth + 9 DOWNTO bitloc.weighth + 2 ) ) );
    RETURN lRet;
  END FUNCTION;

  FUNCTION WriteHeader RETURN STRING IS
    VARIABLE aLine : LINE;
  BEGIN
    WRITE( aLine , STRING' ( "Z0" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "Weight" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "SortKey" ) , RIGHT , 15 );
    --WRITE( aLine , STRING' ( "MaximaOffset" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "FrameValid" ) , RIGHT , 15 );
    WRITE( aLine , STRING' ( "DataValid" ) , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteHeader;

  FUNCTION WriteData( aData : tData ) RETURN STRING IS
    VARIABLE aLine          : LINE;
  BEGIN
    WRITE( aLine , TO_INTEGER( aData.z0 ) , RIGHT , 15 );
    WRITE( aLine , TO_INTEGER( aData.Weight ) , RIGHT , 15 );
    WRITE( aLine , aData.SortKey , RIGHT , 15 );
    --WRITE( aLine , aData.MaximaOffset , RIGHT , 15 );
    WRITE( aLine , aData.FrameValid , RIGHT , 15 );
    WRITE( aLine , aData.DataValid , RIGHT , 15 );
    RETURN aLine.ALL;
  END WriteData;

END DataType;
