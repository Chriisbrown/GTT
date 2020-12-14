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
ENTITY TrackSelection IS

  PORT(
    clk                 : IN  STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn       : IN TTTrack.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe
  );
END TrackSelection;

ARCHITECTURE rtl OF TrackSelection IS

  FUNCTION Nstub (hitmask : std_logic_vector) return BOOLEAN IS
  VARIABLE temp_count : NATURAL := 0;
  BEGIN
    FOR i IN hitmask'RANGE LOOP
      IF hitmask(i) = '1' THEN temp_count := temp_count + 1;
      END IF;
    END LOOP;

  RETURN temp_count > 3;
  END FUNCTION Nstub;

  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL l1TTTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;
  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );
    PROCESS( clk )
    VARIABLE Temp_vld : BOOLEAN := FALSE;
    BEGIN
      IF RISING_EDGE( clk ) THEN
        Temp_vld := FALSE;
        IF NOT l1TTTrack.FrameValid THEN
          Output( i ) <= TTTrack.DataType.cNull;
        ELSIF l1TTTrack.DataValid THEN
          IF (Nstub(std_logic_vector(l1TTTrack.Hitpattern))) AND (TO_INTEGER(l1TTTrack.BendChi2) < 3) 
            AND (TO_INTEGER(l1TTTrack.Chi2rphi) + TO_INTEGER(l1TTTrack.Chi2rz)  <= 16) 
            AND (TO_INTEGER(l1TTTrack.Chi2rphi) <= 9) AND (TO_INTEGER(l1TTTrack.Chi2rz)  <= 9) 
            AND (TO_INTEGER(l1TTTrack.pt )>= 128 ) THEN
              Temp_vld := TRUE;
          END IF;
        END IF;
        Output( i ) <= l1TTTrack;
        Output( i ).DataValid <= Temp_vld;
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
  GENERIC MAP( "TrackSelection" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
        
        
    
    


