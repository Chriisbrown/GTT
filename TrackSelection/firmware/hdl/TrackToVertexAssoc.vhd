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

  PROCEDURE DeltaZ ( SIGNAL TTTrack : IN TTTrack.DataType.tData := TTTrack.DataType.cNull;   --Procedure for selecting z window based on eta
                     SIGNAL delta_z : OUT INTEGER               := 0) IS
    VARIABLE temp_z : INTEGER := 0;

    BEGIN
        IF TTTrack.eta >= 32768 AND TTTrack.eta < 41443 THEN
          temp_z := 3;
        ELSIF TTTrack.eta >= 41443 AND TTTrack.eta < 45161 THEN
          temp_z := 5;
        ELSIF TTTrack.eta >= 45161 AND TTTrack.eta < 47639 THEN
          temp_z := 6;
        ELSIF TTTrack.eta >= 47639 AND TTTrack.eta < 52596 THEN
          temp_z := 8;
        ELSIF TTTrack.eta >= 52596 AND TTTrack.eta < 57554 THEN
          temp_z := 14;
        ELSIF TTTrack.eta >= 57554 AND TTTrack.eta <= 62511 THEN
          temp_z := 18;
        ELSE
          temp_z := 0;
        END IF;
    delta_z <= temp_z;

  END PROCEDURE DeltaZ;
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL l1TTTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;
    SIGNAL delayed_Track  : TTTrack.DataType.tData := TTTrack.DataType.cNull;  -- Delay the track to allow window choosing
    SIGNAL delta_z_vld    : BOOLEAN := FALSE; --track within dz window flag
    SIGNAL dz             : INTEGER := 0;

  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );

    DeltaZ( l1TTTrack, dz );

    PROCESS ( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN
        delayed_Track         <= l1TTTrack;
        delta_z_vld           <= ( abs( TO_INTEGER( l1TTTrack.z0 ) - TO_INTEGER( l1TTTrack.PV ) ) <= dz );
        Output( i )           <= delayed_Track;
        Output( i ).DataValid <= TRUE WHEN delta_z_vld AND delayed_Track.DataValid ELSE FALSE;  --If track is valid and within z window keep
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
        
        
    
    


