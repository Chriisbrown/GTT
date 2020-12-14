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

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY EventNonant;
USE EventNonant.DataType;
USE EventNonant.ArrayTypes;

LIBRARY LinkDecode;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY LinkDecodeProcessorTop IS
  PORT(
    clk             : IN STD_LOGIC; -- The algorithm clock
    LinksIn         : IN ldata;
    LinksOut        : OUT ldata;
-- Prevent all the logic being synthesized away when running standalone
    DebuggingOutput : OUT Vertex.ArrayTypes.Vector( 0 TO 0 ) := Vertex.ArrayTypes.NullVector( 1 )
  );
END LinkDecodeProcessorTop;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF LinkDecodeProcessorTop IS

  SUBTYPE tWordTrackPipe IS TTTrack.ArrayTypes.VectorPipe( 0 TO 9 )( 0 TO 17 );
  CONSTANT NullWordTrackPipe : tWordTrackPipe := TTTrack.ArrayTypes.NullVectorPipe( 10 , 18 );

  SUBTYPE EventNonantPipeOut IS EventNonant.ArrayTypes.VectorPipe( 0 TO 17 );
  CONSTANT NullWordEventNonantPipe : EventNonantPipeOut := EventNonant.ArrayTypes.NullVectorPipe( 18 );

  SIGNAL InputPipe             : tWordTrackPipe        := NullWordTrackPipe;
  SIGNAL OutputPipe            : EventNonantPipeOut    := NullWordEventNonantPipe;
 
BEGIN

-- -------------------------------------------------------------------------
  LinksToTTTracksInstance : ENTITY LinkDecode.LinksToTTTracks
  PORT MAP(
    clk          => clk ,
    linksIn      => LinksIn ,
    WordTrackPipeOut => InputPipe
  );
-- -------------------------------------------------------------------------

  TrackSaverInstance : ENTITY LinkDecode.TTTrackSaver
  PORT MAP(
    clk          => clk ,
    TTTrackPipeIn  => InputPipe,
    EventNonantPipeOut => OutputPipe
  );

END rtl;
