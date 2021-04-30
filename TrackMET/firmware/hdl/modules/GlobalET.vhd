-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;

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

  FUNCTION AnyFrameValid (EtVector : Vector := NullVector( NumInputLinks ) ) return BOOLEAN IS
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

  FUNCTION AnyDataValid (EtVector : Vector := NullVector( NumInputLinks ) ) return BOOLEAN IS
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

  FUNCTION SumTracks (EtVector : Vector := NullVector( NumInputLinks );
                      PreviousTracks : INTEGER := 0 ) return INTEGER IS
  VARIABLE track_count : INTEGER := 0;
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        track_count := track_count + TO_INTEGER(EtVector( i ).NumTracks);
      ELSE
        track_count := track_count;
      END IF;
    END LOOP;
  RETURN track_count + PreviousTracks;
  END FUNCTION SumTracks;

  FUNCTION PtUnpacker (EtVector : Vector := NullVector( NumInputLinks ) ) return EtArray IS
  VARIABLE temp_pt : EtArray := ( OTHERS => ( OTHERS => '0' ) );
  BEGIN
    FOR i IN EtVector'RANGE LOOP
      IF EtVector( i ).DataValid THEN
        temp_pt( i ) := EtVector( i ).px;
        temp_pt( i + NumInputLinks ) := EtVector( i ).py;
      END IF;
    END LOOP;
  RETURN temp_pt;
  END FUNCTION PtUnpacker;

  PROCEDURE RecentrePhi (SIGNAL ExSignal     : IN    SIGNED( PtWidth DOWNTO 0 );
                         SIGNAL EySignal     : IN    SIGNED( PtWidth DOWNTO 0 );
                         SIGNAL Phi          : IN  UNSIGNED( METPhiWidth - 1 DOWNTO 0 ); 
                         SIGNAL RecentredPhi : OUT UNSIGNED( METPhiWidth - 1 DOWNTO 0 )) IS  --Pt pass through to maintain synch with Phi
  
  BEGIN
    IF    ExSignal(ExSignal'left) = '1' AND EySignal(EySignal'left) = '1' then
      RecentredPhi <= TO_UNSIGNED(TO_INTEGER(Phi) - (2**(METPhiWidth))/2,METPhiWidth);
    ELSIF ExSignal(ExSignal'left) = '0' AND EySignal(EySignal'left) = '0' then
      RecentredPhi <= TO_UNSIGNED(TO_INTEGER(Phi) + (2**(METPhiWidth))/2,METPhiWidth);
    ELSIF ExSignal(ExSignal'left) = '0' AND EySignal(EySignal'left) = '1' then
      RecentredPhi <= TO_UNSIGNED(TO_INTEGER(Phi) - (2**(METPhiWidth))/2,METPhiWidth);
    ELSIF ExSignal(ExSignal'left) = '1' AND EySignal(EySignal'left) = '0' then
      RecentredPhi <= TO_UNSIGNED(TO_INTEGER(Phi) - 3*(2**(METPhiWidth))/2,METPhiWidth);
    END IF;
  
  END PROCEDURE RecentrePhi;


  SIGNAL Output  : Vector( 0 TO 0 )  := NullVector( 1 );
  SIGNAL InputEt : Vector( 0 TO NumInputLinks - 1 ) := NullVector( NumInputLinks );
  SIGNAL vldEt   : EtArray := ( OTHERS => ( OTHERS => '0' ) );

  SIGNAL ExSignal    : SIGNED( PtWidth DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL EySignal    : SIGNED( PtWidth DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL resetSignal : STD_LOGIC := '0';

  SIGNAL   frame_signal : STD_LOGIC                              := '0';
  CONSTANT frame_delay  : INTEGER                                := 8 + CordicSteps;
  SIGNAL   frame_array  : STD_LOGIC_VECTOR(0 TO frame_delay - 1) := ( OTHERS => '0' );

  SIGNAL NumTracks   : INTEGER := 0;
  SIGNAL Num_array : INTEGER_VECTOR(0 TO frame_delay - 1) := ( OTHERS => 0 );

  SIGNAL RootSum      : UNSIGNED( METMagWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL Phi          : UNSIGNED( METPhiWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL RecentredPhi : UNSIGNED( METPhiWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );

  BEGIN
  Sqrt : ENTITY TrackMET.CordicSqrt
  GENERIC MAP ( n_steps => CordicSteps
  ) 
  PORT MAP(
    clk  => clk,
    Xin  => ExSignal,
    Yin  => EySignal,
    Root => RootSum,
    Phi  => Phi
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
          NumTracks <= SumTracks(InputEt,NumTracks);
        ELSE
          vldEt <= ( OTHERS => ( OTHERS => '0' ) );
          NumTracks <= NumTracks;
        END IF;
      ELSE 
        frame_signal <= '0';
        NumTracks <= 0;
        vldEt <= ( OTHERS => ( OTHERS => '0' ) );
      END IF;

      frame_array <= frame_signal & frame_array( 0 TO frame_delay - 2 );
      Num_array <= NumTracks & Num_array( 0 TO frame_delay - 2 );

    END IF;
  END PROCESS;

  resetSignal <= '0' WHEN ( frame_array( 0 ) = '1' )  ELSE '1'; -- Only accumulate if frame is valid, else set accumulator to 0
  RecentrePhi(ExSignal,EySignal,Phi,RecentredPhi);
  
  Output( 0 ) .Et  <= RootSum;
  Output( 0 ) .Phi <= RecentredPhi;
  Output( 0 ) .Px <= ExSignal;
  Output( 0 ) .Py <= EySignal;
  Output( 0 ) .NumTracks <= TO_UNSIGNED(Num_array( frame_delay - 1),METNtrackWidth);
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