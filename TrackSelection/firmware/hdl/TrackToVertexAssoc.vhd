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

    SIGNAL tmp_trk1 : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_trk2 : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_trk3 : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL tmp_trk4 : TTTrack.DataType.tData := TTTrack.DataType.cNull;

    SIGNAL tmp_z1 : INTEGER := 0;
    SIGNAL tmp_z2 : INTEGER := 0;
    SIGNAL tmp_PV1 : INTEGER := 0;
    SIGNAL tmp_PV2 : INTEGER := 0;

    SIGNAL temp_vld : BOOLEAN := FALSE;

    SIGNAL delta_z : INTEGER := 0;
    SIGNAL delta_z2 : INTEGER := 0;

    SIGNAL z_diff : INTEGER := 0;

    SIGNAL tmp_eta : INTEGER := 0;


  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );
    PROCESS( clk )

    
    
    BEGIN
      IF RISING_EDGE( clk ) THEN
-- ----------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------
-- Clock 1
        tmp_eta <= TO_INTEGER(l1TTTrack.eta);
        tmp_trk1 <= l1TTTrack;
        tmp_z1 <= TO_INTEGER(l1TTTrack.z0);
        tmp_PV1 <= TO_INTEGER(l1TTTrack.PV);
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------  
-- Clock 2

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
          delta_z <= 18;
        ELSE
          delta_z <= 0;
        END IF;

        tmp_trk2 <= tmp_trk1;
        tmp_z2 <= tmp_z1;
        tmp_PV2 <= tmp_PV1;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------  
-- Clock 3
        z_diff <= abs(tmp_z2 - tmp_PV2);
        delta_z2 <= delta_z;
        tmp_trk3 <= tmp_trk2;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 4
        IF tmp_trk3.DataValid AND z_diff <= delta_z2 THEN
            temp_vld <= TRUE;
        ELSE
            temp_vld <= FALSE;
        END IF;
        tmp_trk4 <= tmp_trk3;
-- ----------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------
-- Clock 5     
        Output( i ) <= tmp_trk4;
        Output( i ).FrameValid <= tmp_trk4.FrameValid;
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
        
        
    
    


