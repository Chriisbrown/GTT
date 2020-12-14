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
ENTITY ExponentialSmearingKernel IS
  GENERIC(
    PipeOffset : INTEGER := 0
  );
  PORT(
    clk           : IN STD_LOGIC := '0'; -- The algorithm clock
    VertexPipeIn  : IN VectorPipe;
    VertexPipeOut : OUT VectorPipe
  );
END ExponentialSmearingKernel;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF ExponentialSmearingKernel IS

  SIGNAL VerticesIn , NextVerticesIn , LatchedLeft , LatchedRight : Vector( -11 TO 268 ) := NullVector( 280 );
  SIGNAL Output                                                   : Vector( 0 TO 255 )   := NullVector( 256 );

  CONSTANT cWidth                                                 : INTEGER              := 12;

BEGIN

-- -------------------------------------------------------------------------
  g1 : FOR i IN 0 TO 255 GENERATE
  BEGIN

    VerticesIn( i ) <= VertexPipeIn( PipeOffset + 0 )( i );

    PROCESS( clk )
    BEGIN
      IF RISING_EDGE( clk ) THEN

        IF VerticesIn( i ) .DataValid THEN
          LatchedLeft( i )  <= VerticesIn( i - 1 ) / 2;
          LatchedRight( i ) <= VerticesIn( i + 1 ) / 2;
          Output( i )       <= VerticesIn( i );
        ELSE
          LatchedLeft( i )  <= LatchedLeft( i ) / 2;
          LatchedRight( i ) <= LatchedRight( i ) / 2;
          Output( i )       <= Output( i ) + LatchedLeft( i ) + LatchedRight( i );
        END IF;

        Output( i ) .DataValid  <= VertexPipeIn( PipeOffset + cWidth )( i ) .DataValid;
        Output( i ) .FrameValid <= VertexPipeIn( PipeOffset + cWidth )( i ) .FrameValid;

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
  GENERIC MAP( "ExponentialSmearingKernel" )
  PORT MAP( clk , Output );
-- -------------------------------------------------------------------------

END rtl;
