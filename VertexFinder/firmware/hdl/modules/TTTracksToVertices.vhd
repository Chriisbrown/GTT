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

    BEGIN
      IF RISING_EDGE( clk ) THEN
        Output( i ) .z0         <= l1TTTrack.z0;
        Output( i ) .Weight     <= l1TTTrack.Pt;
        Output( i ) .SortKey    <= TO_INTEGER(l1TTTrack.z0;)
        Output( i ) .DataValid  <= l1TTTrack.DataValid;
        Output( i ) .FrameValid <= l1TTTrack.FrameValid;
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
