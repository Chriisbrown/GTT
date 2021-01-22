-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;

LIBRARY TrackSelection;
USE TrackSelection.constants.ALL;

-- -------------------------------------------------------------------------
ENTITY TrackSelection IS

  PORT(
    clk                 : IN  STD_LOGIC; -- The algorithm clock
    TTTrackPipeIn       : IN  TTTrack.ArrayTypes.VectorPipe;
    TTTrackPipeOut      : OUT TTTrack.ArrayTypes.VectorPipe
  );
END TrackSelection;

ARCHITECTURE rtl OF TrackSelection IS

  FUNCTION Nstub ( hitmask : STD_LOGIC_VECTOR ) RETURN BOOLEAN IS  --Function to calculate N stub from hitmask and return if > 3
  VARIABLE temp_count : NATURAL := 0;
  BEGIN
    FOR i IN hitmask'RANGE LOOP
      IF hitmask( i ) = '1' THEN temp_count := temp_count + 1;
      END IF;
    END LOOP;
  RETURN temp_count >= MaxNstub; 
  END FUNCTION Nstub;

  SIGNAL Output : TTTrack.ArrayTypes.Vector( 0 TO 17 ) := TTTrack.ArrayTypes.NullVector( 18 );
  
BEGIN
  g1              : FOR i IN 0 TO 17 GENERATE

    SIGNAL l1TTTrack      : TTTrack.DataType.tData := TTTrack.DataType.cNull;

  BEGIN
    l1TTTrack <= TTTrackPipeIn( 0 )( i );
    PROCESS( clk )

    VARIABLE Track_vld : BOOLEAN := FALSE;  --Track Selection flag
    BEGIN
      IF RISING_EDGE( clk ) THEN
        Track_vld := FALSE; -- Default track to false
        IF NOT l1TTTrack.FrameValid THEN
          Output( i ) <= TTTrack.DataType.cNull;

        ELSIF l1TTTrack.DataValid THEN
          IF    ( Nstub( STD_LOGIC_VECTOR( l1TTTrack.Hitpattern ) ) ) 
            AND ( TO_INTEGER( l1TTTrack.BendChi2 ) < MaxBendChi2  ) 
            AND ( TO_INTEGER( l1TTTrack.Chi2rphi ) + TO_INTEGER( l1TTTrack.Chi2rz ) <= MaxChi2Sum ) 
            AND ( TO_INTEGER( l1TTTrack.Chi2rphi ) <= MaxSplitChi2 ) 
            AND ( TO_INTEGER( l1TTTrack.Chi2rz   ) <= MaxSplitChi2 ) 
            AND ( TO_INTEGER( l1TTTrack.pt ) >= MaxTrackPt ) THEN  
              Track_vld := TRUE;
          END IF;
        END IF;
        Output( i ) <= l1TTTrack;
        Output( i ).DataValid <= Track_vld;
        Output( i ).FrameValid <= l1TTTrack.FrameValid; 
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
        
        
    
    


