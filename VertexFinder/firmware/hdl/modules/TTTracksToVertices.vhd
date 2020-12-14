-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- .library VertexFinder

-- .include types/PkgTrack.vhd
-- .include ReuseableElements/PkgArrayTypes.vhd in Track

-- .include types/PkgVertex.vhd
-- .include ReuseableElements/PkgArrayTypes.vhd in Vertex
-- .include ReuseableElements/DataPipe.vhd in Vertex
-- .include ReuseableElements/Debugger.vhd in Vertex


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


-- -------------------------------------------------------------------------
ENTITY TTTracksToVertices IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0'; -- The algorithm clock
    TTTrackPipeIn   : IN TTTrack.ArrayTypes.VectorPipe;
    VertexPipeOut : OUT Vertex.ArrayTypes.VectorPipe
  );
END TTTracksToVertices;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF TTTracksToVertices IS
  SIGNAL Output : Vertex.ArrayTypes.Vector( 0 TO 17 ) := Vertex.ArrayTypes.NullVector( 18 );
  
BEGIN

-- -------------------------------------------------------------------------
  g1              : FOR i IN 0 TO 17 GENERATE
    SIGNAL l1TTTrack    : TTTrack.DataType.tData := TTTrack.DataType.cNull;

  BEGIN
    l1TTTrack <= TTTrackPipeIn( PipeOffset )( i );

    PROCESS( clk )
    VARIABLE tmp_pt : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
    VARIABLE tmp_z  : INTEGER := 0;
    VARIABLE tmp_dv : BOOLEAN := FALSE;
    VARIABLE tmp_fv : BOOLEAN := FALSE;
    BEGIN
      IF RISING_EDGE( clk ) THEN

        IF l1TTTrack.Z0Frac(l1TTTrack.Z0Frac'left) = '1' THEN --negative
          IF l1TTTrack.Z0Int >= 15 THEN
            tmp_z := 0;
          ELSE
            tmp_z := -TO_INTEGER(l1TTTrack.Z0Int)*8 + TO_INTEGER(l1TTTrack.Z0Frac)/8 + TO_INTEGER(l1TTTrack.Z0Frac)/64 + 128 - TO_INTEGER(l1TTTrack.Z0Int)/2;
          END IF;
        ELSE  --positive
          IF l1TTTrack.Z0Int >= 15 THEN
            tmp_z := 255;
          ELSE
            tmp_z := TO_INTEGER(l1TTTrack.Z0Int)*8 + TO_INTEGER(l1TTTrack.Z0Frac)/8 + TO_INTEGER(l1TTTrack.Z0Frac)/64 + 128 + TO_INTEGER(l1TTTrack.Z0Int)/2;
          END IF;
        END IF;

        tmp_pt := l1TTTrack.Pt;
        tmp_dv := l1TTTrack.DataValid;
        tmp_fv := l1TTTrack.FrameValid;

        Output( i ) .z0         <= TO_UNSIGNED(tmp_z,8);
        Output( i ) .Weight     <= tmp_pt;
        Output( i ) .SortKey    <= tmp_z;
        Output( i ) .DataValid  <= tmp_dv;
        Output( i ) .FrameValid <= tmp_fv;

      END IF;
    END PROCESS;
  END GENERATE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Vertex.DataPipe
  PORT MAP( clk , Output , VertexPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Vertex.Debug
  GENERIC MAP( "TTTracksToVertices" )
  PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
