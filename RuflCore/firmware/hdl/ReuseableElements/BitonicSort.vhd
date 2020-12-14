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

-- Based on code for CMS Phase 1 Level 1 Trigger Calo Layer2
-- Originally by Andrew Rose
-- Adapted for RUFL by Sioni Summers

library ieee;
use ieee.std_logic_1164.all;

use work.DataType.all;
use work.ArrayTypes.all;

library Utilities;
use Utilities.Utilities.all;

entity BitonicSort is
  generic(
    InSize : integer := 0;
    OutSize : integer := 0;
    d : boolean := true; -- sort direction
    id : string
  );
  port(
    clk : in std_logic := '0';
    VectorIn : in Vector;
    VectorOut : out Vector
  );
end BitonicSort;

ARCHITECTURE behavioral OF BitonicSort IS
  CONSTANT LowerInSize      : INTEGER := InSize / 2;
  CONSTANT UpperInSize      : INTEGER := InSize - LowerInSize; -- UpperSize >= LowerSize
 
  CONSTANT LowerOutSize     : INTEGER := MINIMUM( OutSize , LowerInSize );
  CONSTANT UpperOutSize     : INTEGER := MINIMUM( OutSize , UpperInSize );
 
  CONSTANT LowerSortLatency : INTEGER := LatencyOfBitonicSort( LowerInSize , LowerOutSize );
  CONSTANT UpperSortLatency : INTEGER := LatencyOfBitonicSort( UpperInSize , UpperOutSize );
 
  CONSTANT PipeLength       : INTEGER := MAXIMUM( UpperSortLatency-LowerSortLatency , 2 );
 
  SIGNAL T1 : VectorPipe(0 to PipeLength)(0 to LowerOutSize + UpperOutSize-1) := NullVectorPipe(PipeLength+1, LowerOutSize + UpperOutSize);
  SIGNAL T2 : Vector( 0 TO LowerOutSize + UpperOutSize-1 ) := NullVector(LowerOutSize + UpperOutSize);
  SIGNAL T3 : Vector( 0 TO LowerOutSize + UpperOutSize-1 ) := NullVector(LowerOutSize + UpperOutSize); 
  SIGNAL I1 : Vector( 0 TO InSize - LowerInSize - 1 ) := NullVector(InSize - LowerInSize);
  SIGNAL O1 : Vector( 0 TO UpperOutSize-1 ) := NullVector(UpperOutSize);

  COMPONENT BitonicSort IS
    GENERIC(
      InSize  : INTEGER := 0;
      OutSize : INTEGER := 0;
      D       : BOOLEAN := false; -- sort direction
      ID      : STRING
    );
    PORT(
      clk : IN STD_LOGIC; -- clock
      VectorIn : IN Vector( 0 TO InSize-1 )     := NullVector(InSize);
      VectorOut : INOUT Vector( 0 TO OutSize-1 ) := NullVector(OutSize)
    );
  END COMPONENT BitonicSort;
 
  COMPONENT BitonicMerge IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false; -- sort direction
      ID   : STRING
    );
    PORT(
      clk : IN STD_LOGIC; -- clock
      VectorIn : IN Vector( 0 TO Size-1 )    := NullVector(Size);
      VectorOut : INOUT Vector( 0 TO Size-1 ) := NullVector(Size)
    );
  END COMPONENT BitonicMerge;
 
BEGIN
 
-- If size is 1 , just pass through
  G1 : IF InSize <= 1 GENERATE
    VectorOut            <= VectorIn;
  END GENERATE G1;
 
-- If size is greater than 1 , sort lower "half" and upper "half" separately and then merge
  G2   : IF InSize > 1 GENERATE
 
    S1 : BitonicSort
    GENERIC MAP(
      InSize  => LowerInSize ,
      OutSize => LowerOutSize ,
      D       => NOT D ,
      ID      => ID & ".SL"
    )
    PORT MAP(
      clk => clk ,
      VectorIn => VectorIn( 0 TO LowerInSize-1 ) ,
      VectorOut => T1( 0 )( 0 TO LowerOutSize-1 )
    );
 
-- Just needs to be long enough - anything unused will be synthesized away....
    G21 : FOR x IN PipeLength DOWNTO 1 GENERATE
      T1( x ) <= T1( x-1 ) WHEN RISING_EDGE( clk );
    END GENERATE G21;
 
    T2( 0 TO LowerOutSize-1 ) <= T1( UpperSortLatency-LowerSortLatency )( 0 TO LowerOutSize-1 );
    I1( 0 TO InSize - LowerInSize-1 ) <= VectorIn( LowerInSize TO InSize-1 );
    T2( LowerOutSize TO LowerOutSize + UpperOutSize-1 ) <= O1( 0 TO UpperOutSize-1 );
 
    S2 : BitonicSort
    GENERIC MAP(
      InSize  => UpperInSize ,
      OutSize => UpperOutSize ,
      D       => D ,
      ID      => ID & ".SU"
    )
    PORT MAP(
      clk => clk ,
      VectorIn => I1 , --VectorIn( LowerInSize TO InSize-1 ) ,
      VectorOut => O1 --T2( LowerOutSize TO LowerOutSize + UpperOutSize-1 )
    );
 
    M : BitonicMerge
    GENERIC MAP(
      Size => LowerOutSize + UpperOutSize ,
      D    => D ,
      ID   => ID & ".M"
    )
    PORT MAP(
      clk => clk ,
      VectorIn => T2 ,
      VectorOut => T3
    );
 
    G22 : IF NOT D GENERATE
      VectorOut( 0 TO OutSize-1 ) <= T3( 0 TO OutSize-1 );
    END GENERATE G22;
 
    G23 : IF D GENERATE
      VectorOut( 0 TO OutSize-1 ) <= T3( LowerOutSize + UpperOutSize-OutSize TO LowerOutSize + UpperOutSize-1 );
    END GENERATE G23;
 
 
  END GENERATE G2;
 
END ARCHITECTURE behavioral; -- BitonicSort

-- ----------------------------------------------------------------------------------------------------
--! Using the IEEE Library
LIBRARY IEEE;
--! Using STD_LOGIC
USE IEEE.STD_LOGIC_1164.ALL;

use work.DataType.all;
use work.ArrayTypes.all;

library Utilities;
use Utilities.Utilities.all;


--! @brief An entity providing a BitonicMerge
--! @details Detailed description
ENTITY BitonicMerge IS
  GENERIC(
    Size : INTEGER := 0;
    D    : BOOLEAN := true; -- sort direction
    ID   : STRING
  );
  PORT(
    clk : IN STD_LOGIC; -- clock
    VectorIn : IN Vector( 0 TO Size-1 )    := ( OTHERS => cNull );
    VectorOut : INOUT Vector( 0 TO Size-1 ) := ( OTHERS => cNull )
  );
END BitonicMerge;
-- ----------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------
--! @brief Architecture definition for entity BitonicMerge
--! @details Detailed description
ARCHITECTURE behavioral OF BitonicMerge IS
  SIGNAL T1                  : Vector( 0 TO Size-1 ) := NullVector(Size);
  SIGNAL T2                  : Vector( 0 TO Size-1 ) := NullVector(Size);

  CONSTANT LowerSize         : INTEGER                  := PowerOf2LessThan( Size ); -- LowerSize >= Size / 2
  CONSTANT UpperSize         : INTEGER                  := Size - LowerSize; -- UpperSize < LowerSize

  CONSTANT LowerMergeLatency : INTEGER                  := LatencyOfBitonicMerge( LowerSize );
  CONSTANT UpperMergeLatency : INTEGER                  := LatencyOfBitonicMerge( UpperSize );

  CONSTANT PipeLength        : INTEGER                  := MAXIMUM( LowerMergeLatency-UpperMergeLatency , 2 );

  TYPE tOffsetPipe IS ARRAY( NATURAL RANGE <> ) OF Vector( LowerSize TO Size-1 );
  SIGNAL T3 : tOffsetPipe( PipeLength DOWNTO 0 ) := ( OTHERS => ( OTHERS => cNull ) );
  SIGNAL I1                  : Vector( 0 TO Size - LowerSize-1 ) := NullVector(Size - LowerSize);

  COMPONENT BitonicMerge IS
    GENERIC(
      Size : INTEGER := 0;
      D    : BOOLEAN := false; -- sort direction
      ID     : STRING
    );
    PORT(
      clk : IN STD_LOGIC; -- clock
      VectorIn : IN Vector( 0 TO Size-1 )    := ( OTHERS => cNull );
      VectorOut : INOUT Vector( 0 TO Size-1 ) := ( OTHERS => cNull )
    );
  END COMPONENT BitonicMerge;

BEGIN



  G1 : IF Size <= 1 GENERATE
    VectorOut          <= VectorIn;
  END GENERATE G1;

  G2    : IF Size > 1 GENERATE

    G21 : FOR x IN 0 TO UpperSize-1 GENERATE
      PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
        
          IF( ( VectorIn( x ) > VectorIn( x + LowerSize ) ) = D ) THEN
            T1( x )             <= VectorIn( x + LowerSize );
            T1( x + LowerSize ) <= VectorIn( x );
          ELSE
            T1( x )             <= VectorIn( x );
            T1( x + LowerSize ) <= VectorIn( x + LowerSize );
          END IF;

        END IF;
      END PROCESS;
    END GENERATE G21;

    G22 : IF LowerSize > UpperSize GENERATE
      T1( UpperSize TO LowerSize-1 ) <= VectorIn( UpperSize TO LowerSize-1 ) WHEN RISING_EDGE( clk );
    END GENERATE G22;

    M1 : BitonicMerge
      GENERIC MAP(
        Size => LowerSize ,
        D    => D ,
        ID   => ID & ".ML"
      )
      PORT MAP(
        clk => clk ,
        VectorIn => T1( 0 TO LowerSize-1 ) ,
        VectorOut => T2( 0 TO LowerSize-1 )
      );

    I1( 0 TO Size - LowerSize-1 ) <= T1( LowerSize TO Size-1 );
    M2 : BitonicMerge
      GENERIC MAP(
        Size => UpperSize ,
        D    => D ,
        ID   => ID & ".MU"
      )
      PORT MAP(
        clk => clk ,
        VectorIn => I1 ,
        VectorOut => T3( 0 )( LowerSize TO Size-1 )
      );

-- Just needs to be long enough - anything unused will be synthesized away....
    G23 : FOR x IN PipeLength DOWNTO 1 GENERATE
      T3( x ) <= T3( x-1 ) WHEN RISING_EDGE( clk );
    END GENERATE G23;

    VectorOut( 0 TO LowerSize-1 )    <= T2( 0 TO LowerSize-1 );
    VectorOut( LowerSize TO Size-1 ) <= T3( LowerMergeLatency-UpperMergeLatency )( LowerSize TO Size-1 );

  END GENERATE G2;

END ARCHITECTURE behavioral; -- BitonicMerge
-- ----------------------------------------------------------------------------------------------------

