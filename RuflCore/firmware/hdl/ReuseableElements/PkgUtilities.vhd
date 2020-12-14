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

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
PACKAGE Utilities IS

-- -------------------------------------------------------------------------       
  FUNCTION TO_STD_LOGIC( arg               : BOOLEAN ) RETURN std_ulogic;
  FUNCTION TO_BOOLEAN( arg                 : STD_LOGIC ) RETURN BOOLEAN;
  FUNCTION PowerOf2LessThan( ARG           : INTEGER ) RETURN INTEGER;
  FUNCTION LatencyOfBitonicMerge( Size     : INTEGER ) RETURN INTEGER;
  FUNCTION LatencyOfBitonicSort( InSize    : INTEGER ; OutSize : INTEGER ) RETURN INTEGER;
  FUNCTION CeilLog2(x : integer) return integer;
  FUNCTION LatencyOfPairReduce(InSize : integer) return integer;


  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT SIGNED );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT UNSIGNED );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC_VECTOR );
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC );
-- -------------------------------------------------------------------------       

END PACKAGE Utilities;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
PACKAGE BODY Utilities IS

-- -------------------------------------------------------------------------       
  FUNCTION TO_BOOLEAN( arg : STD_LOGIC ) RETURN BOOLEAN IS
  BEGIN
    RETURN( arg = '1' );
  END FUNCTION TO_BOOLEAN;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  FUNCTION TO_STD_LOGIC( arg : BOOLEAN ) RETURN std_ulogic IS
  BEGIN
    IF arg THEN
        RETURN( '1' );
    ELSE
        RETURN( '0' );
    END IF;
  END FUNCTION TO_STD_LOGIC;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT SIGNED ) IS
    VARIABLE rand                          : REAL; -- Random real-number value in range 0 to 1.0
  BEGIN
    UNIFORM( seed1 , seed2 , rand ); -- generate random number
    RESULT := TO_SIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );
  END SET_RANDOM_VAR;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT UNSIGNED ) IS
    VARIABLE rand                          : REAL; -- Random real-number value in range 0 to 1.0
  BEGIN
    UNIFORM( seed1 , seed2 , rand ); -- generate random number
    RESULT := TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH );
  END SET_RANDOM_VAR;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC_VECTOR ) IS
    VARIABLE rand                          : REAL; -- Random real-number value in range 0 to 1.0
  BEGIN
    UNIFORM( seed1 , seed2 , rand ); -- generate random number
    RESULT := STD_LOGIC_VECTOR( TO_UNSIGNED( INTEGER( rand * REAL( 2 ** 30 ) ) , RESULT'LENGTH ) );
  END SET_RANDOM_VAR;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  PROCEDURE SET_RANDOM_VAR( VARIABLE SEED1 : INOUT POSITIVE ; SEED2 : INOUT POSITIVE ; VARIABLE RESULT : OUT STD_LOGIC ) IS
    VARIABLE rand                          : REAL; -- Random real-number value in range 0 to 1.0
    VARIABLE int_rand                      : INTEGER; -- Random integer value in range 0 to 1
  BEGIN
    UNIFORM( seed1 , seed2 , rand ); -- generate random number
    int_rand := INTEGER( ROUND( rand ) );
    IF int_rand = 1 THEN
      RESULT := '1';
    ELSE
      RESULT := '0';
    END IF;
  END SET_RANDOM_VAR;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  FUNCTION PowerOf2LessThan( ARG : INTEGER ) RETURN INTEGER IS
    VARIABLE comp                : INTEGER := 1;
  BEGIN
    FOR i IN 0 TO 63 LOOP
      IF ARG <= comp THEN
        RETURN comp / 2;
      END IF;
      comp := comp * 2;
    END LOOP;
    RETURN -1;
  END FUNCTION PowerOf2LessThan;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  FUNCTION LatencyOfBitonicMerge( Size     : INTEGER ) RETURN INTEGER IS
    VARIABLE Merge1Latency , Merge2Latency : INTEGER := 0;
  BEGIN
    IF size <= 1 THEN
      RETURN 0;
    ELSE
      Merge1Latency := LatencyOfBitonicMerge( PowerOf2LessThan( Size ) );
      Merge2Latency := LatencyOfBitonicMerge( Size - PowerOf2LessThan( Size ) );
      RETURN 1 + MAXIMUM( Merge1Latency , Merge2Latency );
    END IF;
  END FUNCTION LatencyOfBitonicMerge;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  FUNCTION LatencyOfBitonicSort( InSize  : INTEGER ; OutSize : INTEGER ) RETURN INTEGER IS
    VARIABLE Sort1Size , Sort2Size       : INTEGER := 0;
    VARIABLE Sort1Latency , Sort2Latency : INTEGER := 0;
    VARIABLE MergeLatency                : INTEGER := 0;
  BEGIN
    IF InSize <= 1 THEN
      RETURN 0;
    ELSE
      Sort1Size    := InSize / 2;
      Sort2Size    := InSize - Sort1Size;

      Sort1Latency := LatencyOfBitonicSort( Sort1Size , OutSize );
      Sort2Latency := LatencyOfBitonicSort( Sort2Size , OutSize );
      MergeLatency := LatencyOfBitonicMerge( MINIMUM( Sort1Size , OutSize ) + MINIMUM( Sort2Size , OutSize ) );

      RETURN MAXIMUM( Sort1Latency , Sort2Latency ) + MergeLatency;
    END IF;
  END FUNCTION LatencyOfBitonicSort;
-- -------------------------------------------------------------------------       

-- -------------------------------------------------------------------------       
  FUNCTION CeilLog2(x : integer) return integer is
    --variable y : integer := 0;
  begin
    for y in 0 to 64 loop
      if 2 ** y >= x then
        return y;
      end if;
    end loop;
    return -1;
  end function CeilLog2;

  FUNCTION LatencyOfPairReduce(InSize : integer) return integer is
  begin
    return CeilLog2(InSize);
  end function LatencyOfPairReduce;

END Utilities;
