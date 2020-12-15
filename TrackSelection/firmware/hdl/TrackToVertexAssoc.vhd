-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY Vertex;
USE Vertex.DataType;
USE Vertex.ArrayTypes;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;

-- -------------------------------------------------------------------------
ENTITY TrackToVertexAssoc IS

  PORT(
    clk                 : IN  STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe
  );
END TrackToVertexAssoc;

ARCHITECTURE rtl OF TrackToVertexAssoc IS

  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL l1TTTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_trk : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_trk2 : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_z : INTEGER := 0;
    SIGNAL tmp_eta : INTEGER := 0;
    SIGNAL temp_vld : BOOLEAN := FALSE;
    SIGNAL delta_z : INTEGER := 0;


  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );
    PROCESS( clk )
    
    
    
    BEGIN
      IF RISING_EDGE( clk ) THEN
-- ----------------------------------------------------------------------------------------------
-- Clock 1
        IF l1TTTrack.Z0Frac(l1TTTrack.Z0Frac'left) = '1' THEN --negative
          tmp_z <= -TO_INTEGER(l1TTTrack.Z0Int)*8 + TO_INTEGER(l1TTTrack.Z0Frac)/8 + TO_INTEGER(l1TTTrack.Z0Frac)/64 + 128 - TO_INTEGER(l1TTTrack.Z0Int)/2;
        ELSE  --positive
          tmp_z <= TO_INTEGER(l1TTTrack.Z0Int)*8 + TO_INTEGER(l1TTTrack.Z0Frac)/8 + TO_INTEGER(l1TTTrack.Z0Frac)/64 + 128 + TO_INTEGER(l1TTTrack.Z0Int)/2;
        END IF;

        tmp_eta <= TO_INTEGER(l1TTTrack.eta);
        tmp_trk <= l1TTTrack;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 2
          
        IF tmp_trk.DataValid THEN
          IF tmp_eta >= 32768 AND tmp_eta < 41443 THEN
            delta_z <= 3;
          ELSIF tmp_eta >= 41443 AND tmp_eta < 45161 THEN
            delta_z <= 5;
          ELSIF tmp_eta >= 45161 AND tmp_eta < 47639 THEN
            delta_z <= 6;
          ELSIF tmp_eta >= 47639 AND tmp_eta < 52596 THEN
            delta_z <= 8;
          ELSIF tmp_eta >= 52596 AND tmp_eta < 57554 THEN
            delta_z <= 14;
          ELSIF tmp_eta >= 57554 AND tmp_eta <= 62511 THEN
            delta_z <= 19;
          ELSE
            delta_z <= 0;
          END IF;
        tmp_trk2 <= tmp_trk;
        tmp_z2 <= tmp_z;
-- ----------------------------------------------------------------------------------------------
          
-- ----------------------------------------------------------------------------------------------
-- Clock 3
        IF abs(tmp_z2 - TO_INTEGER(tmp_trk2.PV)) < delta_z THEN
            temp_vld <= TRUE; 
          ELSE
            temp_vld <= FALSE;
        END IF;  

      Output( i ) <= tmp_trk2;
      Output( i ).DataValid <= temp_vld;
      Output( i ).PrimaryTrack <= temp_vld;
-- ----------------------------------------------------------------------------------------------
      END IF;
    END PROCESS;
  END GENERATE;

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY TTTrack.DataPipe
  PORT MAP( clk , Output , TTTrackPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY TTTrack.Debug
  GENERIC MAP( "TracksToVertexAssoc" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
        
        
    
    


