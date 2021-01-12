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

  PROCEDURE GlobalPhiLUT (signal TTTrack : IN TTTrack.DataType.tData;
                          signal Phix : OUT Integer;
                          signal Phiy : OUT Integer;
                          signal Pt : OUT Integer) is
    VARIABLE GlobalPhi : INTEGER := 0;
    VARIABLE TempPt : INTEGER := 0;
    BEGIN
        GlobalPhi := TO_INTEGER(TTTrack.phi);
        TempPt := TO_INTEGER(TTTrack.pt);

        IF GlobalPhi >= 0 AND GlobalPhi < 1567 THEN
          Phix <= TrigArray(GlobalPhi)(0);  
          Phiy <= TrigArray(GlobalPhi)(1); 
        ELSIF GlobalPhi >= 1567 AND GlobalPhi < 3134 THEN
          Phix <= -TrigArray(GlobalPhi-1567)(1); 
          Phiy <= TrigArray(GlobalPhi-1567)(0); 
        ELSIF GlobalPhi >= 3134 AND GlobalPhi < 4701 THEN
          Phix <= -TrigArray(GlobalPhi-3134)(0);  
          Phiy <= -TrigArray(GlobalPhi-3134)(1); 
        ELSIF GlobalPhi >= 4701 AND GlobalPhi < 6268 THEN
          Phix <= TrigArray(GlobalPhi-4701)(1); 
          Phiy <= -TrigArray(GlobalPhi-4701)(0); 
        END IF;

        Pt <= TempPt;
  END PROCEDURE GlobalPhiLUT;


  COMPONENT MAC IS
    PORT(
        clk  : IN STD_LOGIC; -- clock
        rst  : IN STD_LOGIC;
        Pt   : IN INTEGER := 0;
        Phi  : IN INTEGER := 0;
        SumPt : OUT SIGNED ( 15 DOWNTO 0 ) := ( OTHERS => '0' )
    );
  END COMPONENT MAC;
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE

  SIGNAL vldTrack       : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  
  SIGNAl tempPt : INTEGER := 0;
  SIGNAL tempPhix : INTEGER := 0;
  SIGNAL tempPhiy : INTEGER := 0;

  SIGNAL reset : STD_LOGIC := '0';
  SIGNAL SumPx : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL SumPy : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );


  SIGNAL vld : STD_LOGIC := '0';
  constant dn: INTEGER := 5;
  signal delay: std_logic_vector(0 to dn - 1);

  BEGIN

  PxMAC : ENTITY TrackMET.MAC
    PORT MAP(
      clk => clk, -- clock
      reset => reset,
      Pt => tempPt,
      Phi => tempPhix,
      SumPt => SumPx
    );

  PyMAC : ENTITY TrackMet.MAC
    PORT MAP(
      clk => clk, -- clock
      reset => reset,
      Pt => tempPt,
      Phi => tempPhiy,
      SumPt => SumPy
    );

    

    GlobalPhiLUT(vldTrack,tempPhix,tempPhiy,tempPt);

    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN
        IF TTTrackPipeIn( 0 )( i ).FrameValid THEN
          IF TTTrackPipeIn( 0 )( i ).DataValid THEN
            vldTrack <= TTTrackPipeIn( 0 )( i );
          ELSE
            vldTrack <= TTTrack.DataType.cNull;
          END IF;
        ELSE 
          vldTrack <= TTTrack.DataType.cNull;
        END IF;

        IF TTTrackPipeIn( 1 )( i ).FrameValid AND NOT TTTrackPipeIn( 0 )( i ).FrameValid THEN
          vld <= '1';
        ELSE
          vld <= '0';
        END IF;

        delay <= vld & delay(0 to dn - 2);



      END IF;
    END PROCESS;

    reset <= delay(dn - 1);

    Output( i ) .DataValid  <= TRUE WHEN (delay(dn -1) = '1' AND delay(dn -2) = '0') ELSE FALSE;
    Output( i ) .FrameValid <= TRUE WHEN (delay(dn -1) = '1' AND delay(dn -2) = '0') ELSE FALSE;
    Output( i ) .Px <= SumPx;
    Output( i ) .Py <= SumPy;
    Output( i ) .Sector <= TO_UNSIGNED(i/2,4);

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