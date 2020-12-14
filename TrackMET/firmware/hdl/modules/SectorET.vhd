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
    SIGNAL tempfvld4 : BOOLEAN := FALSE;
    SIGNAL tempfvld5 : BOOLEAN := FALSE;

  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );

    PROCESS( clk )
    
    VARIABLE GlobalPhi2 : INTEGER := 0;
    VARIABLE GlobalPhi : INTEGER := 0;

    VARIABLE tempPt : INTEGER := 0;
    VARIABLE tempPt2 : INTEGER := 0;
    VARIABLE tempPx : INTEGER := 0;
    VARIABLE tempPy : INTEGER := 0;
    VARIABLE tempPhix : INTEGER := 0;
    VARIABLE tempPhiy : INTEGER := 0;

    VARIABLE SumPx : INTEGER := 0;
    VARIABLE SumPy : INTEGER := 0;

    BEGIN
      
      IF RISING_EDGE( clk ) THEN
        tempfvld1 <= l1TTTrack.FrameValid;
        tempfvld2 <= tempfvld1;
        tempfvld3 <= tempfvld2;
        tempfvld4 <= tempfvld3;
        tempfvld5 <= tempfvld4;

        IF tempfvld5 AND NOT tempfvld4 THEN
          GlobalPhi := 0;
          GlobalPhi2 := 0;
          tempPhix := 0;
          tempPhiy := 0;
          tempPt := 0;
          tempPt2 := 0;
          tempPx := 0;
          tempPy := 0;
          SumPx := 0;
          SumPy := 0;
          Output( i ) <= ET.DataType.cNull;

        
        ELSIF l1TTTrack.DataValid THEN
          GlobalPhi := TO_INTEGER(l1TTTrack.phi) + Phi_shift(i) - 1024; 
          tempPt := TO_INTEGER(l1TTTrack.PT);
          
            
          IF GlobalPhi < 0 THEN
            GlobalPhi2 := GlobalPhi + 6268;
          ELSIF GlobalPhi > 6268 THEN
            GlobalPhi2 := GlobalPhi - 6268; 
          ELSE
            GlobalPhi2 := GlobalPhi;
          END IF;

          tempPt2 := tempPt;

          IF GlobalPhi2 >= 0 AND GlobalPhi2 < 1567 THEN
              tempPhix := TrigArray(GlobalPhi2)(0);  
              tempPhiy := TrigArray(GlobalPhi2)(1); 
            
          ELSIF GlobalPhi2 >= 1567 AND GlobalPhi2 < 3134 THEN
              tempPhix := -TrigArray(GlobalPhi2-1567)(1); 
              tempPhiy := TrigArray(GlobalPhi2-1567)(0); 

          ELSIF GlobalPhi2 >= 3134 AND GlobalPhi2 < 4701 THEN
              tempPhix := -TrigArray(GlobalPhi2-3134)(0);  
              tempPhiy := -TrigArray(GlobalPhi2-3134)(1); 

          ELSIF GlobalPhi2 >= 4701 AND GlobalPhi2 < 6268 THEN
              tempPhix := TrigArray(GlobalPhi2-4701)(1); 
              tempPhiy := -TrigArray(GlobalPhi2-4701)(0); 
          END IF;

          tempPx := (tempPhix * tempPt2)/2**11;
          tempPy := (tempPhiy * tempPt2)/2**11;
          
          SumPx := SumPx + tempPx;
          SumPy := SumPy + tempPy;

          Output( i ) .Px <= TO_SIGNED(SumPx,16);
          Output( i ) .Py <=  TO_SIGNED(SumPy,16);
          Output( i ) .Sector <=  TO_UNSIGNED(i/2,4);

        END IF;

      Output( i ) .FrameValid <= tempfvld4;
      Output( i ) .DataValid  <= tempfvld4 AND NOT tempfvld3;
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