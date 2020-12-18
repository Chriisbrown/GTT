-- -------------------------------------------------------------------------
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
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL l1TTTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;

    SIGNAL tempfvld1 : BOOLEAN := FALSE;
    SIGNAL tempfvld2 : BOOLEAN := FALSE;
    SIGNAL tempfvld3 : BOOLEAN := FALSE;

    SIGNAL tempdvld1 : BOOLEAN := FALSE;
    SIGNAL tempdvld2 : BOOLEAN := FALSE;

    SIGNAL tempPt1 : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );

    SIGNAL tempPhix : UNSIGNED( 11 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL tempPhiy : UNSIGNED( 11 DOWNTO 0 ) := ( OTHERS => '0' );

    SIGNAL PhixSign : BOOLEAN := FALSE;
    SIGNAL PhiySign : BOOLEAN := FALSE;
    SIGNAL PhixSign2 : BOOLEAN := FALSE;    SIGNAL tempfvld4 : BOOLEAN := FALSE;
    SIGNAL tempfvld5 : BOOLEAN := FALSE;
    SIGNAL PhiySign2 : BOOLEAN := FALSE;

    SIGNAL tempPx : UNSIGNED( 27 DOWNTO 0) := ( OTHERS => '0' );
    SIGNAL tempPy : UNSIGNED( 27 DOWNTO 0) := ( OTHERS => '0' );

  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );

    PROCESS( clk )
      VARIABLE sumPx : INTEGER := 0;
      VARIABLE sumPy : INTEGER := 0;

      VARIABLE DSPfullPx : UNSIGNED(27 DOWNTO 0) := ( OTHERS => '0' );
      VARIABLE DSPfullPy : UNSIGNED(27 DOWNTO 0) := ( OTHERS => '0' );

      VARIABLE GlobalPhi : INTEGER := 0;
    BEGIN
      
      IF RISING_EDGE( clk ) THEN

-- ----------------------------------------------------------------------------------------------
-- Clock 1
        GlobalPhi := l1TTTrack.phi;
        IF GlobalPhi >= 0 AND GlobalPhi < 1567 THEN
            tempPhix <= TO_UNSIGNED(TrigArray(GlobalPhi)(0),12);  
            tempPhiy <= TO_UNSIGNED(TrigArray(GlobalPhi)(1),12); 
            PhixSign <= FALSE;
            PhiySign <= FALSE;
              
        ELSIF GlobalPhi >= 1567 AND GlobalPhi < 3134 THEN
            tempPhix <= TO_UNSIGNED(TrigArray(GlobalPhi-1567)(1),12); 
            tempPhiy <= TO_UNSIGNED(TrigArray(GlobalPhi-1567)(0),12); 
            PhixSign <= TRUE;
            PhiySign <= FALSE;

        ELSIF GlobalPhi >= 3134 AND GlobalPhi < 4701 THEN
            tempPhix <= TO_UNSIGNED(-TrigArray(GlobalPhi-3134)(0),12);  
            tempPhiy <= TO_UNSIGNED(-TrigArray(GlobalPhi-3134)(1),12); 
            PhixSign <= TRUE;
            PhiySign <= TRUE;

        ELSIF GlobalPhi >= 4701 AND GlobalPhi < 6268 THEN
            tempPhix <= TO_UNSIGNED(TrigArray(GlobalPhi-4701)(1),12); 
            tempPhiy <= TO_UNSIGNED(-TrigArray(GlobalPhi-4701)(0),12); 
            PhixSign <= FALSE;
            PhiySign <= TRUE;
        END IF;

        tempfvld1 <= l1TTTrack.FrameValid;
        tempdvld1 <= l1TTTrack.DataValid;
        tempPt1   <= l1TTTrack.Pt;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 2
        DSPfullPx := (tempPhix * tempPt1);
        DSPfullPy := (tempPhiy * tempPt1);
        tempPx <= DSPfullPx;
        tempPy <= DSPfullPy;
        PhixSign2 <= PhixSign; 
        PhiySign2 <= PhiySign;
        tempfvld2 <= tempfvld1;
        tempdvld2 <= tempdvld1;

-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 3
        tempfvld3 <= tempfvld2;

        IF tempdvld2 THEN
          IF PhixSign2 THEN
            SumPx := SumPx - TO_INTEGER(tempPx)/2**12;
          ELSE
            SumPx := SumPx +  TO_INTEGER(tempPx)/2**12;
          END IF;

          IF PhiySign2 THEN
            SumPy := SumPy - TO_INTEGER( tempPy)/2**12;
          ELSE
            SumPy := SumPy +  TO_INTEGER(tempPy)/2**12;
          END IF;
        ELSE
          SumPx := SumPx;
          SumPy := SumPy;
        END IF;


        IF tempfvld3 AND NOT tempfvld2 THEN
          SumPx := 0;
          SumPy := 0;
          Output( i ) <= ET.DataType.cNull;
        ELSE
          Output( i ) .Px <= TO_SIGNED(SumPx,16);
          Output( i ) .Py <=  TO_SIGNED(SumPy,16);
          Output( i ) .Sector <=  TO_UNSIGNED(i/2,4);
        END IF;

        Output( i ) .DataValid  <= tempfvld2 AND NOT tempfvld1;
        Output( i ) .FrameValid <= tempfvld2;
  
      END IF;
    END PROCESS;
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