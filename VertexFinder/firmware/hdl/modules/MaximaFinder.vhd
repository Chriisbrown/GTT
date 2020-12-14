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
ENTITY MaximaFinder IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0'; -- The algorithm clock
    VertexPipeIn  : IN VectorPipe;
    VertexPipeOut : OUT VectorPipe
  );
END MaximaFinder;
-- -------------------------------------------------------------------------

-- 256 entries decomposes to 2 ^ 8
-- We have no requirement to be pipelined, so we can reuse comparitors to save resources
-- but, for comparison, the minimum reasonable latency = 8 pipelined pairwise comparisons = 8 clock-cycles

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF MaximaFinder IS
  SIGNAL Comparitor : Vector( 0 TO 255 ) := NullVector( 256 );
  SIGNAL Output     : Vector( 0 TO 0 )   := NullVector( 1 );
BEGIN

-- -------------------------------------------------------------------------

  g1 : FOR i IN 0 TO 255 GENERATE
  BEGIN
    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN
        IF i > 127 THEN
          Comparitor( i ) <= VertexPipeIn( PipeOffset + 0 )( i );
        ELSE
          IF VertexPipeIn( PipeOffset + 0 )( i ) .DataValid THEN
            Comparitor( i ) <= VertexPipeIn( PipeOffset + 0 )( i );
          ELSE
            IF Comparitor( 2 * i ) > Comparitor( 2 * i + 1 ) THEN
              Comparitor( i ) <= Comparitor( 2 * i );
            ELSE
              Comparitor( i ) <= Comparitor( 2 * i + 1 );
            END IF;
          END IF;
        END IF;
      END IF;
    END PROCESS;
  END GENERATE;

  PROCESS( clk )
  BEGIN
    IF RISING_EDGE( clk ) THEN
      Output( 0 )             <= Comparitor( 0 ); --MaximaTree(8)(0);
      Output( 0 ) .SortKey    <= VertexPipeIn( PipeOffset + 9 )( 0 ) .SortKey;
      Output( 0 ) .DataValid  <= VertexPipeIn( PipeOffset + 9 )( 0 ) .DataValid;
      Output( 0 ) .FrameValid <= VertexPipeIn( PipeOffset + 9 )( 0 ) .FrameValid;
    END IF;
  END PROCESS;

-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Store the result in a pipeline
  OutputPipeInstance : ENTITY Vertex.DataPipe
  PORT MAP( clk , Output , VertexPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Write the debug information to file
  DebugInstance : ENTITY Vertex.Debug
  GENERIC MAP( "MaximaFinder" )
  PORT MAP( clk , Output );
-- -------------------------------------------------------------------------

END rtl;
