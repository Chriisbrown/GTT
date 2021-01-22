LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY ET;
USE ET.DataType;
USE ET.ArrayTypes;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;

LIBRARY TrackMET;
USE TrackMET.ROMConstants.all;
USE TrackMET.MAC;
USE TrackMET.constants.all;

-- -------------------------------------------------------------------------
ENTITY SectorET IS

  PORT(
    clk                 : IN  STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe :=  TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 );
    EtOut              : OUT ET.ArrayTypes.VectorPipe := Et.ArrayTypes.NullVectorPipe( 10 , 18 )
  );
END SectorET;

ARCHITECTURE rtl OF SectorET IS

  SIGNAL Output : ET.ArrayTypes.Vector( 0 TO 17 ) := ET.ArrayTypes.NullVector( 18 );

  PROCEDURE GlobalPhiLUT (SIGNAL TTTrack : IN TTTrack.DataType.tData ;  --Procedure for finding cos and sin of phi
                          SIGNAL Phix    : OUT INTEGER ;
                          SIGNAL Phiy    : OUT INTEGER ;
                          SIGNAL Pt      : OUT INTEGER ) IS  --Pt pass through to maintain synch with Phi
    VARIABLE GlobalPhi : INTEGER := 0;
    VARIABLE TempPt    : INTEGER := 0;
    BEGIN
        GlobalPhi := TO_INTEGER( TTTrack.phi );
        TempPt    := TO_INTEGER( TTTrack.pt );

        IF GlobalPhi >= PhiBins( 0 ) AND GlobalPhi < PhiBins( 1 ) THEN
          Phix <= TrigArray( GlobalPhi )( 0 );  
          Phiy <= TrigArray( GlobalPhi )( 1 ); 
        ELSIF GlobalPhi >= PhiBins( 1 ) AND GlobalPhi < PhiBins( 2 ) THEN
          Phix <= -TrigArray( GlobalPhi - PhiBins( 1 ) )( 1 ); 
          Phiy <= TrigArray(  GlobalPhi - PhiBins( 1 ) )( 0 ); 
        ELSIF GlobalPhi >= PhiBins( 2 ) AND GlobalPhi < PhiBins( 3 ) THEN
          Phix <= -TrigArray( GlobalPhi - PhiBins( 2 ) )( 0 );  
          Phiy <= -TrigArray( GlobalPhi - PhiBins( 2 ) )( 1 ); 
        ELSIF GlobalPhi >= PhiBins( 3 ) AND GlobalPhi < PhiBins( 4 ) THEN
          Phix <= TrigArray(  GlobalPhi - PhiBins( 3 ) )( 1 ); 
          Phiy <= -TrigArray( GlobalPhi - PhiBins( 3 ) )( 0 ); 
        END IF;
        Pt <= TempPt;
  END PROCEDURE GlobalPhiLUT;

  CONSTANT frame_delay : INTEGER := 2; --Constant latency of algorithm steps
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE

  SIGNAL vldTrack : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  
  SIGNAl Pt_Buffer   : INTEGER := 0;  --Temporaries for procedure outputs
  SIGNAL Phix_Buffer : INTEGER := 0;
  SIGNAL Phiy_Buffer : INTEGER := 0;

  SIGNAL reset : STD_LOGIC := '0';  --MAC reset signal
  SIGNAL SumPx : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );  --MAC outputs
  SIGNAL SumPy : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );

  SIGNAL frame_signal : STD_LOGIC := '0';
  SIGNAL frame_array  : STD_LOGIC_VECTOR(0 TO frame_delay - 1) :=  ( OTHERS => '0' );  --Delaying frame valid signals

  BEGIN

  PxMAC : ENTITY TrackMET.MAC  --Multiplier acumulator, finds cos/sin * px and sums until reset
    PORT MAP(
      clk    => clk, -- clock
      reset  => reset,
      Pt     => Pt_Buffer,
      Phi    => Phix_Buffer,
      SumPt  => SumPx
    );

  PyMAC : ENTITY TrackMet.MAC  --Multiplier acumulator, finds cos/sin * py and sums until reset
    PORT MAP(
      clk    => clk, -- clock
      reset  => reset,
      Pt     => Pt_Buffer,
      Phi    => Phiy_Buffer,
      SumPt  => SumPy
    );

    GlobalPhiLUT( vldTrack, Phix_Buffer, Phiy_Buffer, Pt_Buffer);

    PROCESS( clk )  --Clocked process for storing frame valids and sending to MACs
    BEGIN
      IF RISING_EDGE( clk ) THEN
        IF TTTrackPipeIn( 0 )( i ).FrameValid THEN
          frame_signal <= '1';
          IF TTTrackPipeIn( 0 )( i ).DataValid THEN
            vldTrack <= TTTrackPipeIn( 0 )( i );
          ELSE
            vldTrack <= TTTrack.DataType.cNull;
          END IF;
        ELSE 
          frame_signal <= '0';
          vldTrack <= TTTrack.DataType.cNull;
        END IF;

        frame_array <= frame_signal & frame_array( 0 TO frame_delay - 2 );

      END IF;
    END PROCESS;

    reset <= '0' WHEN ( frame_array( 1 ) = '1' )  ELSE '1'; -- Only accumulate if frame is valid + one clock for Phi LUT, else set accumulator to 0

    Output( i ) .DataValid  <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1') AND ( frame_array( frame_delay - 2 )  = '0') ELSE FALSE; -- DataValid when all tracks read
    Output( i ) .FrameValid <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1') ELSE FALSE; -- FrameValid when track frame valid
    Output( i ) .Px <= SumPx;
    Output( i ) .Py <= SumPy;
    Output( i ) .Sector <= TO_UNSIGNED( i / 2, 4 );

  END GENERATE;

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Et.DataPipe
  PORT MAP( clk , Output , EtOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Et.Debug
  GENERIC MAP( "SectorET" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;