LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;

--library work;
--use work.emp_data_types.all;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;

LIBRARY Vertex;
USE Vertex.DataType;
USE Vertex.ArrayTypes;

LIBRARY InTTTrack;
USE InTTTrack.DataType;
USE InTTTrack.ArrayTypes;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY Et;
USE Et.DataType;
USE Et.ArrayTypes;

LIBRARY VertexFinder;
LIBRARY LinkDecode;
LIBRARY TrackSelection;
LIBRARY TrackMET;
LIBRARY GTT;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY GTTTop IS
  PORT(
    clk       : IN STD_LOGIC; -- The algorithm clock
    LinksIn         : IN ldata;
    LinksOut        : OUT ldata;
-- Prevent all the logic being synthesized away when running standalone
    DebuggingOutput : OUT Vertex.ArrayTypes.Vector( 0 TO 0 ) := Vertex.ArrayTypes.NullVector( 1 )
  );
END GTTTop;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF GTTTop IS

  SUBTYPE tInTrackPipe IS InTTTrack.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO NumInputLinks - 1 );
  CONSTANT NullInTrackPipe : tInTrackPipe := InTTTrack.ArrayTypes.NullVectorPipe( 10 , NumInputLinks );

  SUBTYPE tWordTrackPipe IS TTTrack.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO NumInputLinks - 1 );
  CONSTANT NullWordTrackPipe : tWordTrackPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , NumInputLinks );

  SUBTYPE tPrimaryVertexPipe IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 0 );
  CONSTANT NullPrimaryVertexPipe      : tPrimaryVertexPipe   := Vertex.ArrayTypes.NullVectorPipe( 10 , 1 );

  SUBTYPE tEtPipe IS Et.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO NumInputLinks - 1 );
  CONSTANT NullEtPipe      : tEtPipe   := Et.ArrayTypes.NullVectorPipe( 10 , NumInputLinks );

  SUBTYPE tGlobEtPipe IS Et.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 0 );
  CONSTANT NullGlobEtPipe      : tGlobEtPipe   := Et.ArrayTypes.NullVectorPipe( 10 , 1 );

  SIGNAL InputPipe             : tInTrackPipe          := NullInTrackPipe;    --Initial Input tracks, taken from links
  SIGNAL TrackPipe             : tWordTrackPipe        := NullWordTrackPipe;  --Transformed Tracks
  SIGNAl DelayedTracks         : tWordTrackPipe        := NullWordTrackPipe;  --Tracks from FIFO after vertexing
  SIGNAl PVTracks              : tWordTrackPipe        := NullWordTrackPipe;  --Tracks of Primary Vertex
  SIGNAl CutTracks             : tWordTrackPipe        := NullWordTrackPipe;  --Tracks after quality selection
  SIGNAL PrimaryVertexPipe     : tPrimaryVertexPipe    := NullPrimaryVertexPipe; -- Primary Vertex 
  SIGNAL EtPipe                : tEtPipe               := NullEtPipe;            -- Sector Et
  SIGNAL GlobalEtPipe          : tGlobEtPipe           := NullGlobEtPipe;        -- Global Et


 
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
--TrackTransformInstance : ENTITY LinkDecode.TrackTransform
--PORT MAP(
--  clk              => clk ,
--  TTTrackPipeIn    => InputPipe ,
--  TTTrackPipeOut   => TrackPipe 
--  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
ByPassTrackTransformInstance : ENTITY LinkDecode.ByPassTrackTransform
PORT MAP(
  clk              => clk ,
  TTTrackPipeIn    => InputPipe ,
  TTTrackPipeOut   => TrackPipe 
  );
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
TrackSaverInstance : ENTITY LinkDecode.TTTrackSaver
PORT MAP(
  clk    => clk ,
  TTTrackPipeIn  => TrackPipe ,
  PrimaryVertexPipeIn => PrimaryVertexPipe,
  TTTrackPipeOut => DelayedTracks
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
VertexFinderInstance : ENTITY VertexFinder.VertexFinderModule
PORT MAP(
  clk => clk ,
  TrackPipe => TrackPipe ,
  PrimaryVertexPipeOut => PrimaryVertexPipe
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
TrackAssociatonInstance : ENTITY TrackSelection.TrackToVertexAssoc
PORT MAP(
  clk => clk ,
  TTTrackPipeIn => DelayedTracks,
  TTTrackPipeOut => PVTracks
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
TrackSelectionInstance : ENTITY TrackSelection.TrackSelection
PORT MAP(
  clk => clk ,
  TTTrackPipeIn => PVTracks,
  TTTrackPipeOut => CutTracks
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
SectorEtInstance : ENTITY TrackMET.SectorET
PORT MAP(
  clk => clk ,
  TTTrackPipeIn => CutTracks,
  EtOut => EtPipe
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
GlobalEtInstance : ENTITY TrackMET.GlobalET
PORT MAP(
  clk => clk ,
  SectorEtPipeIn => EtPipe,
  EtOut => GlobalEtPipe
);
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
ObjectsToLinksInstance : ENTITY GTT.ObjectsToLinks
PORT MAP(
  clk => clk ,
  VertexPipeIn => PrimaryVertexPipe,
  METPipeIn => GlobalEtPipe,
  linksOut => LinksOut
);

END rtl;
