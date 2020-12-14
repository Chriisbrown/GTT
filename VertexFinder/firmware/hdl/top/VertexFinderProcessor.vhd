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
-- .include TopLevelInterfaces/mp7_data_types.vhd

-- .include modules/LinksToTracks.vhd
-- .include modules/TracksToVertices.vhd
-- .include modules/VertexDistribution.vhd
-- .include modules/Fanout.vhd
-- .include modules/Histogram.vhd
-- -- .include modules/ExponentialSmearingKernel.vhd
-- .include modules/MaximaFinder.vhd
-- .include modules/VertexToLink.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;

LIBRARY Vertex;
USE Vertex.DataType;
USE Vertex.ArrayTypes;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY VertexFinder;
LIBRARY LinkDecode;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY VertexFinderProcessorTop IS
  PORT(
    clk             : IN STD_LOGIC; -- The algorithm clock
    LinksIn         : IN ldata;
    LinksOut        : OUT ldata;
-- Prevent all the logic being synthesized away when running standalone
    DebuggingOutput : OUT Vertex.ArrayTypes.Vector( 0 TO 0 ) := Vertex.ArrayTypes.NullVector( 1 )
  );
END VertexFinderProcessorTop;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF VertexFinderProcessorTop IS

  SUBTYPE tWordTrackPipe IS TTTrack.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 17 );
  CONSTANT NullWordTrackPipe : tWordTrackPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 );

  SUBTYPE tVertexPipe18 IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 17 );
  CONSTANT NullVertexPipe18 : tVertexPipe18 := Vertex.ArrayTypes.NullVectorPipe( 10 , 18 );

  SUBTYPE tVertexPipe64 IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 63 );
  CONSTANT NullVertexPipe64 : tVertexPipe64 := Vertex.ArrayTypes.NullVectorPipe( 10 , 64 );

  SUBTYPE tVertexPipe IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 255 );
  CONSTANT NullVertexPipe : tVertexPipe := Vertex.ArrayTypes.NullVectorPipe( 10 , 256 );

  SUBTYPE tMaximaPipe IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 0 );
  CONSTANT NullMaximaPipe      : tMaximaPipe   := Vertex.ArrayTypes.NullVectorPipe( 10 , 1 );


  SIGNAL InputPipe             : tWordTrackPipe    := NullWordTrackPipe;
  SIGNAL TrackPipe             : tWordTrackPipe    := NullWordTrackPipe;
  SIGNAL VertexPipe            : tVertexPipe18 := NullVertexPipe18;
  SIGNAL DistributedPipe       : tVertexPipe64 := NullVertexPipe64;
  SIGNAL DistributedFannedPipe : tVertexPipe   := NullVertexPipe;
  SIGNAL HistogramPipe         : tVertexPipe   := NullVertexPipe;
  SIGNAL SmearedVertexPipe     : tVertexPipe   := NullVertexPipe;
  SIGNAL MaximaPipe            : tMaximaPipe   := NullMaximaPipe;

BEGIN

-- -------------------------------------------------------------------------
  LinksToTTTracksInstance : ENTITY LinkDecode.LinksToTTTracks
  PORT MAP(
    clk          => clk ,
    linksIn      => LinksIn ,
    WordTrackPipeOut => InputPipe
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  PtCalculateInstance : ENTITY LinkDecode.PtCalculate
  PORT MAP(
    clk              => clk ,
    TTTrackPipeIn    => InputPipe ,
    TTTrackPipeOut   => TrackPipe 
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  TTTracksToVerticexInstance : ENTITY VertexFinder.TTTrackstoVertices
  PORT MAP(
    clk          => clk ,
    TTTrackPipeIn => TrackPipe ,
    VertexPipeOut => VertexPipe
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  VertexDistributionInstance : ENTITY VertexFinder.VertexDistribution
  PORT MAP(
    clk           => clk ,
    VertexPipeIn  => VertexPipe ,
    VertexPipeOut => DistributedPipe
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  VertexFanoutInstance : ENTITY VertexFinder.Fanout64_256
  PORT MAP(
    clk           => clk ,
    VertexPipeIn  => DistributedPipe ,
    VertexPipeOut => DistributedFannedPipe
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  HistogramInstance : ENTITY VertexFinder.Histogram
  PORT MAP(
    clk           => clk ,
    VertexPipeIn  => DistributedFannedPipe ,
    VertexPipeOut => HistogramPipe
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--  ExponentialSmearingKernelInstance : ENTITY VertexFinder.ExponentialSmearingKernel
--  PORT MAP(
--    clk         => clk ,
--    VertexPipeIn  => HistogramPipe ,
--    VertexPipeOut => SmearedVertexPipe
--  );
SmearedVertexPipe <= HistogramPipe;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
  MaximaFinderInstance : ENTITY VertexFinder.MaximaFinder
  PORT MAP(
    clk           => clk ,
    VertexPipeIn  => SmearedVertexPipe ,
    VertexPipeOut => MaximaPipe
  );
-- -------------------------------------------------------------------------

  LinksOutInstance : ENTITY VertexFinder.VertexToLink
  PORT MAP(
    clk => clk,
    VertexPipeIn => MaximaPipe,
    linksOut => LinksOut
  );

-- MAKE SURE THIS IS THE LAST ENTRY IN THE CHAIN FOR STANDALONE SYNTHESIS
  DebuggingOutput <= MaximaPipe( 0 );

END rtl;
