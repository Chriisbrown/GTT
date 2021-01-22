LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;

LIBRARY InTTTrack;
USE InTTTrack.DataType.ALL;
USE InTTTrack.ArrayTypes.ALL;

LIBRARY LinkDecode;
USE LinkDecode.constants.all;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY LinksToTTTracks IS
  PORT(
    clk          : IN STD_LOGIC; -- The algorithm clock
    linksIn      : IN ldata;
    WordTrackPipeOut : OUT VectorPipe      := NullVectorPipe( 10 , 18 );
  );
END LinksToTTTracks;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF LinksToTTTracks IS
  SIGNAL Output : Vector( 0 TO 17 ) := NullVector( 18 );
  CONSTANT LinkWordLength : INTEGER := WordLength;

BEGIN
  g1 : FOR i IN 0 TO 17 GENERATE

  SIGNAL temp_framevalid1   : BOOLEAN := FALSE;
  SIGNAL temp_framevalid2   : BOOLEAN := FALSE;
  SIGNAL temp_framevalid3   : BOOLEAN := FALSE;

  SIGNAL track_words : STD_LOGIC_VECTOR(LinkWordLength*3 - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL clockCounter : INTEGER := 1;

  BEGIN

    PROCESS( clk )
      
    BEGIN
      IF RISING_EDGE( clk ) THEN
          
          track_words(   LinkWordLength - 1 DOWNTO   0)              <= linksIn( i ) .data( LinkWordLength-1 DOWNTO 0 );
          track_words( 2*LinkWordLength - 1 DOWNTO   LinkWordLength) <= track_words(   LinkWordLength - 1 DOWNTO 0 );
          track_words( 3*LinkWordLength - 1 DOWNTO 2*LinkWordLength) <= track_words( 2*LinkWordLength - 1 DOWNTO LinkWordLength );

          temp_framevalid1 <= to_boolean(linksIn( i ) .valid);
          temp_framevalid2 <= temp_framevalid1;
          temp_framevalid3 <= temp_framevalid2;
          
          IF clockCounter = 2 THEN
            Output( i ) . InvR       <=   SIGNED( track_words( LinkWordLength+bitloc.InvRh      DOWNTO LinkWordLength+bitloc.InvRl ));
            Output( i ) . Phi        <=   SIGNED( track_words( LinkWordLength+bitloc.Phih       DOWNTO LinkWordLength+bitloc.Phil ));
            Output( i ) . TanLInt    <=   SIGNED( track_words( LinkWordLength+bitloc.TanLinth   DOWNTO LinkWordLength+bitloc.TanLintl ));
            Output( i ) . TanLFrac   <= UNSIGNED( track_words( LinkWordLength+bitloc.TanLfrach  DOWNTO LinkWordLength+bitloc.TanLfracl ));
            Output( i ) . z0Int      <= UNSIGNED( track_words( LinkWordLength+bitloc.Z0inth     DOWNTO LinkWordLength+bitloc.Z0intl ));
            Output( i ) . z0Frac     <=   SIGNED( track_words( LinkWordLength+bitloc.Z0frach    DOWNTO LinkWordLength+bitloc.Z0fracl ));
            Output( i ) . MVAtrackQ  <= UNSIGNED( track_words( LinkWordLength+bitloc.MVAtrackQh DOWNTO LinkWordLength+bitloc.MVAtrackQl ));
            Output( i ) . OtherMVA   <= UNSIGNED( track_words( LinkWordLength+bitloc.OtherMVAh  DOWNTO LinkWordLength+bitloc.OtherMVAl ));

            Output( i ) . d0Int      <=   SIGNED( track_words( LinkWordLength/2 + bitloc.D0inth      DOWNTO LinkWordLength/2 + bitloc.D0intl ));
            Output( i ) . d0Frac     <= UNSIGNED( track_words( LinkWordLength/2 + bitloc.D0frach     DOWNTO LinkWordLength/2 + bitloc.D0fracl ));
            Output( i ) . Chi2rphi   <= UNSIGNED( track_words( LinkWordLength/2 + bitloc.Chi2rphih   DOWNTO LinkWordLength/2 + bitloc.Chi2rphil ));
            Output( i ) . Chi2rz     <= UNSIGNED( track_words( LinkWordLength/2 + bitloc.Chi2rzh     DOWNTO LinkWordLength/2 + bitloc.Chi2rzl ));
            Output( i ) . BendChi2   <= UNSIGNED( track_words( LinkWordLength/2 + bitloc.BendChi2h   DOWNTO LinkWordLength/2 + bitloc.BendChi2l ));
            Output( i ) . Hitpattern <= UNSIGNED( track_words( LinkWordLength/2 + bitloc.Hitpatternh DOWNTO LinkWordLength/2 + bitloc.Hitpatternl ));
            
            Output( i ) .DataValid  <= to_boolean( track_words( LinkWordLength/2 + bitloc.TrackValidi));
            Output( i ) .FrameValid <= temp_framevalid1;
            clockCounter <= 3;
            
          
          ELSIF clockCounter = 3 THEN
            Output( i ) . InvR       <=   SIGNED( track_words( bitloc.InvRh      DOWNTO bitloc.InvRl ));
            Output( i ) . Phi        <=   SIGNED( track_words( bitloc.Phih       DOWNTO bitloc.Phil ));
            Output( i ) . TanLInt    <=   SIGNED( track_words( bitloc.TanLinth   DOWNTO bitloc.TanLintl ));
            Output( i ) . TanLFrac   <= UNSIGNED( track_words( bitloc.TanLfrach  DOWNTO bitloc.TanLfracl ));
            Output( i ) . z0Int      <= UNSIGNED( track_words( bitloc.Z0inth     DOWNTO bitloc.Z0intl ));
            Output( i ) . z0Frac     <=   SIGNED( track_words( bitloc.Z0frach    DOWNTO bitloc.Z0fracl ));
            Output( i ) . MVAtrackQ  <= UNSIGNED( track_words( bitloc.MVAtrackQh DOWNTO bitloc.MVAtrackQl ));
            Output( i ) . OtherMVA   <= UNSIGNED( track_words( bitloc.OtherMVAh  DOWNTO bitloc.OtherMVAl ));

            Output( i ) . d0Int      <=   SIGNED( track_words( LinkWordLength + bitloc.D0inth      DOWNTO LinkWordLength + bitloc.D0intl ));
            Output( i ) . d0Frac     <= UNSIGNED( track_words( LinkWordLength + bitloc.D0frach     DOWNTO LinkWordLength + bitloc.D0fracl ));
            Output( i ) . Chi2rphi   <= UNSIGNED( track_words( LinkWordLength + bitloc.Chi2rphih   DOWNTO LinkWordLength + bitloc.Chi2rphil ));
            Output( i ) . Chi2rz     <= UNSIGNED( track_words( LinkWordLength + bitloc.Chi2rzh     DOWNTO LinkWordLength + bitloc.Chi2rzl ));
            Output( i ) . BendChi2   <= UNSIGNED( track_words( LinkWordLength + bitloc.BendChi2h   DOWNTO LinkWordLength + bitloc.BendChi2l ));
            Output( i ) . Hitpattern <= UNSIGNED( track_words( LinkWordLength + bitloc.Hitpatternh DOWNTO LinkWordLength + bitloc.Hitpatternl ));
          
            Output( i ) . DataValid  <= to_boolean( track_words( LinkWordLength + bitloc.TrackValidi ));
            Output( i ) . FrameValid <= temp_framevalid1;
            clockCounter <= 1;

          ELSE
            Output( i ) . DataValid  <= FALSE;
            Output( i ) . FrameValid <= temp_framevalid3;
            IF to_boolean(linksIn( i ) .valid)  OR temp_framevalid1 OR temp_framevalid2 THEN
              clockCounter <= clockCounter + 1;
            ELSE
              clockCounter <= 0;
            END IF;
          END IF;

      END IF;
    END PROCESS;

  END GENERATE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- Store the result in a pipeline  
  OutputPipeInstance : ENTITY InTTTrack.DataPipe
  PORT MAP( clk , Output , WordTrackPipeOut );
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
 --Write the debug information to file
    DebugInstance : ENTITY InTTTrack.Debug
    GENERIC MAP( "LinksToTTTrack" )
    PORT MAP( clk , Output ) ;
-- -------------------------------------------------------------------------

END rtl;
