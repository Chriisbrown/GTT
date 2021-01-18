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

-- -------------------------------------------------------------------------
ENTITY SectorET IS

  PORT(
    clk                 : IN  STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe;
    EtOut              : OUT ET.ArrayTypes.VectorPipe
  );
END SectorET;

ARCHITECTURE rtl OF SectorET IS

  SIGNAL Output : ET.ArrayTypes.Vector( 0 TO 17 ) := ET.ArrayTypes.NullVector( 18 );

  PROCEDURE GlobalPhiLUT (SIGNAL TTTrack : IN TTTrack.DataType.tData ;  --Procedure for finding cos and sin of phi
                          SIGNAL Phix    : OUT INTEGER ;
                          SIGNAL Phiy    : OUT INTEGER ;
                          SIGNAL Pt      : OUT INTEGER ) IS
    VARIABLE GlobalPhi : INTEGER := 0;
    VARIABLE TempPt    : INTEGER := 0;
    BEGIN
        GlobalPhi := TO_INTEGER( TTTrack.phi );
        TempPt    := TO_INTEGER( TTTrack.pt );

        IF GlobalPhi >= 0 AND GlobalPhi < 1567 THEN
          Phix <= TrigArray( GlobalPhi )( 0 );  
          Phiy <= TrigArray( GlobalPhi )( 1 ); 
        ELSIF GlobalPhi >= 1567 AND GlobalPhi < 3134 THEN
          Phix <= -TrigArray( GlobalPhi-1567 )( 1 ); 
          Phiy <= TrigArray(  GlobalPhi-1567 )( 0 ); 
        ELSIF GlobalPhi >= 3134 AND GlobalPhi < 4701 THEN
          Phix <= -TrigArray( GlobalPhi-3134 )( 0 );  
          Phiy <= -TrigArray( GlobalPhi-3134 )( 1 ); 
        ELSIF GlobalPhi >= 4701 AND GlobalPhi < 6268 THEN
          Phix <= TrigArray(  GlobalPhi-4701 )( 1 ); 
          Phiy <= -TrigArray( GlobalPhi-4701 )( 0 ); 
        END IF;
        Pt <= TempPt;
  END PROCEDURE GlobalPhiLUT;

  CONSTANT frame_delay        : INTEGER := 5; --Constant latency of algorithm steps
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE

  SIGNAL vldTrack : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  
  SIGNAl tempPt   : INTEGER := 0;  --Temporaries for procedure outputs
  SIGNAL tempPhix : INTEGER := 0;
  SIGNAL tempPhiy : INTEGER := 0;

  SIGNAL reset : STD_LOGIC := '0';  --MAC reset signal
  SIGNAL SumPx : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );  --MAC outputs
  SIGNAL SumPy : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );

  SIGNAL frame_signal : STD_LOGIC := '0';
  SIGNAL frame_array  : STD_LOGIC_VECTOR(0 TO frame_delay - 1) :=  ( OTHERS => '0' );  --Delaying frame valid signals

  BEGIN

  PxMAC : ENTITY TrackMET.MAC  --Multiplier acumulator, finds cos/sin * px and sums until reset
    PORT MAP(
      clk   => clk, -- clock
      reset => reset,
      Pt    => tempPt,
      Phi   => tempPhix,
      SumPt => SumPx
    );

  PyMAC : ENTITY TrackMet.MAC  --Multiplier acumulator, finds cos/sin * py and sums until reset
    PORT MAP(
      clk   => clk, -- clock
      reset => reset,
      Pt    => tempPt,
      Phi   => tempPhiy,
      SumPt => SumPy
    );

    GlobalPhiLUT( vldTrack, tempPhix, tempPhiy, tempPt);

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

    reset <= '1' WHEN (frame_array( frame_delay -1 ) = '1') AND (frame_array(frame_delay -2) = '0') ELSE '0';  --Reset MACs when end of valid frames

    Output( i ) .DataValid  <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1') AND ( frame_array( frame_delay - 2 )  = '0') ELSE FALSE;
    Output( i ) .FrameValid <= TRUE WHEN ( frame_array( frame_delay - 1 ) = '1') ELSE FALSE;
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