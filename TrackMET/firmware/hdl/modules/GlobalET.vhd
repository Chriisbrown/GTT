-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;

LIBRARY TrackMET;
USE TrackMET.ROMConstants.all;
USE TrackMET.CordicSqrt;
USE TrackMET.AC;

-- -------------------------------------------------------------------------
ENTITY GlobalET IS

  PORT(
    clk                  : IN  STD_LOGIC := '0'; -- The algorithm clock
    SectorEtPipeIn       : IN VectorPipe;
    EtOut                : OUT VectorPipe
  );
END GlobalET;


  ARCHITECTURE rtl OF GlobalET IS

  FUNCTION AnyFrameValid (EtVector : Vector) return BOOLEAN IS
  VARIABLE valid_count : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).FrameValid THEN
        valid_count := valid_count + 1;
      ELSE
        valid_count := valid_count;
      END IF;
    END LOOP;
  RETURN valid_count > 0;
  END FUNCTION AnyFrameValid;

  FUNCTION AnyDataValid (EtVector : Vector) return BOOLEAN IS
  VARIABLE valid_count : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        valid_count := valid_count + 1;
      ELSE
        valid_count := valid_count;
      END IF;
    END LOOP;
  RETURN valid_count > 0;
  END FUNCTION AnyDataValid;


  SIGNAL Output : Vector( 0 TO 0 ) := NullVector( 1 );
  SIGNAL InputEt : Vector( 0 TO 17 ) := NullVector( 18 );
  SIGNAL vldEt : Vector( 0 TO 17 ) := NullVector( 18 );

  SIGNAL ExSignal : INTEGER := 0;
  SIGNAL EYSignal : INTEGER := 0;
  SIGNAL resetSignal : STD_LOGIC := '0';

  SIGNAL framesignal : STD_LOGIC := '0';
  constant full_dn : INTEGER := 9;
  signal framedelay: std_logic_vector(0 to full_dn - 1);

  SIGNAL NormedEt : INTEGER := 0;
  SIGNAL RootSum : SIGNED( 15 DOWNTO 0 ) := (OTHERS=>'0');

  BEGIN
  Sqrt : ENTITY TrackMET.CordicSqrt
  GENERIC MAP (n_steps => 4)
  PORT MAP(
    clk => clk,
    Xin => TO_SIGNED(ExSignal,16),
    Yin => TO_SIGNED(EySignal,16),
    Root  => RootSum
  );

  Accumulator : ENTITY TrackMET.AC
  PORT MAP(
    clk => clk,
    reset => resetSignal,
    Et => vldEt,
    SumEx  => ExSignal,
    SumEy => EySignal
  );


  InputEt <= SectorEtPipeIn( 0 );

  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF AnyFrameValid(InputEt) THEN
        framesignal <= '1';
        IF AnyDataValid(InputEt) THEN
          vldEt <= InputEt;
        ELSE
          vldEt <= NullVector( 18 );
        END IF;
      ELSE 
        framesignal <= '0';
        vldEt <= NullVector( 18 );
      END IF;

      framedelay <= framesignal & framedelay(0 to full_dn - 2);

    END IF;
  END PROCESS;

  resetSignal <= '1' WHEN (framedelay(full_dn  -1) = '1') AND (framedelay(full_dn - 2) = '0') ELSE '0';
  NormedEt <= TO_INTEGER(RootSum)*39901/2**16;
  Output( 0 ) .Et <= TO_UNSIGNED(NormedEt,16);   
  Output( 0 ) .DataValid  <= TRUE WHEN (framedelay(full_dn -1) = '1') AND (framedelay(full_dn - 2) = '0') ELSE FALSE;
  Output( 0 ) .FrameValid <= TRUE WHEN (framedelay(full_dn -1) = '1') AND (framedelay(full_dn - 2) = '0') ELSE FALSE;


-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Et.DataPipe
  PORT MAP( clk , Output , EtOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Et.Debug
  GENERIC MAP( "GlobalET" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;