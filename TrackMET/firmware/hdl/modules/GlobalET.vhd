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
USE TrackMET.Constants.all;

-- -------------------------------------------------------------------------
ENTITY GlobalET IS

  PORT(
    clk                  : IN  STD_LOGIC;-- The algorithm clock
    SectorEtPipeIn       : IN  VectorPipe;
    EtOut                : OUT VectorPipe
  );
END GlobalET;


  ARCHITECTURE rtl OF GlobalET IS

  FUNCTION AnyFrameValid (EtVector : Vector := NullVector( 18 ) ) return BOOLEAN IS
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

  FUNCTION AnyDataValid (EtVector : Vector := NullVector( 18 ) ) return BOOLEAN IS
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

  FUNCTION PtUnpacker (EtVector : Vector := NullVector( 18 ) ) return EtArray IS
  VARIABLE temp_pt : EtArray := ( OTHERS => ( OTHERS => '0' ) );
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        temp_pt( i ) := EtVector( i ).px;
        temp_pt( i + 18 ) := EtVector( i ).py;
      END IF;
    END LOOP;
  RETURN temp_pt;
  END FUNCTION PtUnpacker;


  SIGNAL Output  : Vector( 0 TO 0 )  := NullVector( 1 );
  SIGNAL InputEt : Vector( 0 TO 17 ) := NullVector( 18 );
  SIGNAL vldEt   : EtArray := ( OTHERS => ( OTHERS => '0' ) );

  SIGNAL ExSignal    : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL EYSignal    : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL resetSignal : STD_LOGIC := '0';

  SIGNAL   frame_signal : STD_LOGIC                              := '0';
  CONSTANT frame_delay  : INTEGER                                := 12;
  SIGNAL   frame_array  : STD_LOGIC_VECTOR(0 TO frame_delay - 1) := ( OTHERS => '0' );

  SIGNAL RootSum : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );

  BEGIN
  Sqrt : ENTITY TrackMET.CordicSqrt
  GENERIC MAP ( n_steps => CordicSteps,
                multiplier => CordicNormalisation ) 
  PORT MAP(
    clk  => clk,
    Xin  => ExSignal,
    Yin  => EySignal,
    Root => RootSum
  );

  Accumulator : ENTITY TrackMET.AC
  PORT MAP(
    clk   => clk,
    reset => resetSignal,
    Et    => vldEt,
    SumEx => ExSignal,
    SumEy => EySignal
  );


  InputEt <= SectorEtPipeIn( 0 );

  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      IF AnyFrameValid( InputEt ) THEN
        frame_signal <= '1';
        IF AnyDataValid( InputEt ) THEN
          vldEt <= PtUnpacker(InputEt);
        ELSE
          vldEt <= ( OTHERS => ( OTHERS => '0' ) );
        END IF;
      ELSE 
        frame_signal <= '0';
        vldEt <= ( OTHERS => ( OTHERS => '0' ) );
      END IF;

      frame_array <= frame_signal & frame_array( 0 TO frame_delay - 2 );

    END IF;
  END PROCESS;

  resetSignal <= '0' WHEN ( frame_array( 0 ) = '1' )  ELSE '1'; -- Only accumulate if frame is valid, else set accumulator to 0

  
  Output( 0 ) .Et <= RootSum;
  Output( 0 ) .Px <= ExSignal;
  Output( 0 ) .Py <= EySignal;
  Output( 0 ) .DataValid  <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1' ) AND ( frame_array( frame_delay - 2 ) = '0' ) ELSE FALSE;
  Output( 0 ) .FrameValid <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1' ) AND ( frame_array( frame_delay - 2 ) = '0' ) ELSE FALSE;


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