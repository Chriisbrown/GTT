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
    clk             : IN STD_LOGIC; -- The algorithm clock
    LinksIn         : IN ldata;
    LinksOut        : OUT ldata;
-- Prevent all the logic being synthesized away when running standalone
    DebuggingOutput : OUT Vertex.ArrayTypes.Vector( 0 TO 0 ) := Vertex.ArrayTypes.NullVector( 1 )
  );
END GTTTop;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF GTTTop IS

  SUBTYPE tWordTrackPipe IS TTTrack.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 17 );
  CONSTANT NullWordTrackPipe : tWordTrackPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 );

  SUBTYPE tPrimaryVertexPipe IS Vertex.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 0 );
  CONSTANT NullPrimaryVertexPipe      : tPrimaryVertexPipe   := Vertex.ArrayTypes.NullVectorPipe( 10 , 1 );

  SUBTYPE tEtPipe IS Et.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 17 );
  CONSTANT NullEtPipe      : tEtPipe   := Et.ArrayTypes.NullVectorPipe( 10 , 18 );

  SUBTYPE tGlobEtPipe IS Et.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 0 );
  CONSTANT NullGlobEtPipe      : tGlobEtPipe   := Et.ArrayTypes.NullVectorPipe( 10 , 1 );

  SIGNAL InputPipe             : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAL TrackPipe             : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAl DelayedTracks         : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAl PVTracks              : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAl CutTracks             : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAL PrimaryVertexPipe     : tPrimaryVertexPipe    := NullPrimaryVertexPipe;
  SIGNAL EtPipe                : tEtPipe               := NullEtPipe;
  SIGNAL GlobalEtPipe          : tGlobEtPipe           := NullGlobEtPipe;
 
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
