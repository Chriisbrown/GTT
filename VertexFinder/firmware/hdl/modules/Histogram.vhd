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
-- .include types/PkgVertex.vhd
-- .include ReuseableElements/PkgArrayTypes.vhd in Vertex
-- .include ReuseableElements/DataRam.vhd in Vertex
-- .include ReuseableElements/DataPipe.vhd in Vertex
-- .include ReuseableElements/Debugger.vhd in Vertex


-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY Vertex;
USE Vertex.DataType.ALL;
USE Vertex.ArrayTypes.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY Histogram IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0'; -- The algorithm clock
    VertexPipeIn  : IN VectorPipe;
    VertexPipeOut : OUT VectorPipe
  );
END Histogram;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF Histogram IS
  SIGNAL Output : Vector( 0 TO 255 ) := NullVector( 256 );
BEGIN

-- -------------------------------------------------------------------------
  g1                               : FOR i IN 0 TO 255 GENERATE
    SIGNAL VertexIn , NextVertexIn : tData := cNull;
  BEGIN

    VertexIn     <= VertexPipeIn( PipeOffset + 1 )( i );
    NextVertexIn <= VertexPipeIn( PipeOffset + 0 )( i );

    PROCESS( clk )
    BEGIN

      IF RISING_EDGE( clk ) THEN

        IF NOT VertexIn.FrameValid THEN
          Output( i ) <= cNull;
        ELSIF VertexIn.DataValid THEN
          Output( i ) <= VertexIn + Output( i ); -- Ordering means VertexIn.z0 used for bin z0
        END IF;

--Output( i ).z0 <= VertexIn.z0;
        Output( i ) .FrameValid <= VertexIn.FrameValid;
        Output( i ) .DataValid  <= VertexIn.FrameValid AND NOT NextVertexIn.FrameValid;

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
  GENERIC MAP( "Histogram" )
  PORT MAP( clk , Output );
-- -------------------------------------------------------------------------

END rtl;
