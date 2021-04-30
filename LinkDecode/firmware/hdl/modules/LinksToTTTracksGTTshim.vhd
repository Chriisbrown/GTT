LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;
use xil_defaultlib.gtt_interface_pkg; 

--library work;
--use work.emp_data_types.all;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;

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
    linksIn      : IN gtt_interface_pkg.link_array;
    WordTrackPipeOut : OUT VectorPipe
  );
END LinksToTTTracks;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF LinksToTTTracks IS
  SIGNAL Output : Vector( 0 TO NumInputLinks - 1 ) := NullVector( NumInputLinks );

BEGIN
  g1 : FOR i IN 0 TO NumInputLinks-1 GENERATE

  SIGNAL temp_framevalid1   : BOOLEAN := FALSE;
  SIGNAL temp_framevalid2   : BOOLEAN := FALSE;
  SIGNAL temp_framevalid3   : BOOLEAN := FALSE;

  SIGNAL track_words : STD_LOGIC_VECTOR(WordLength*2 - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL clockCounter : INTEGER := 1;

  BEGIN

    PROCESS( clk )
      
    BEGIN
      IF RISING_EDGE( clk ) THEN
          
          track_words(   WordLength - 1 DOWNTO   0)          <= linksIn( i ) .data( WordLength-1 DOWNTO 0 );
          track_words( 2*WordLength - 1 DOWNTO   WordLength) <= track_words(   WordLength - 1 DOWNTO 0 );

          temp_framevalid1 <= to_boolean(linksIn( i ) .valid);
          temp_framevalid2 <= temp_framevalid1;
          temp_framevalid3 <= temp_framevalid2;

          IF clockCounter = 2 THEN
            --Output( i ) . ExtraMVA   <= UNSIGNED( track_words( bitloc.ExtraMVAh   DOWNTO bitloc.ExtraMVAl   ));
            --Output( i ) . TQMVA      <= UNSIGNED( track_words( bitloc.TQMVAh      DOWNTO bitloc.TQMVAl      ));
            --Output( i ) . Hitpattern <= UNSIGNED( track_words( bitloc.Hitpatternh DOWNTO bitloc.Hitpatternl ));
            --Output( i ) . BendChi2   <= UNSIGNED( track_words( bitloc.BendChi2h   DOWNTO bitloc.BendChi2l   ));
            --Output( i ) . D0         <= UNSIGNED( track_words( bitloc.D0h         DOWNTO bitloc.D0l         ));

            --Output( i ) . Chi2rz     <= UNSIGNED( track_words( bitloc.Chi2rzh     DOWNTO bitloc.Chi2rzl ));
            --Output( i ) . z0         <= UNSIGNED( track_words( bitloc.Z0h         DOWNTO bitloc.Z0l     ));
            --Output( i ) . TanL       <= UNSIGNED( track_words( bitloc.TanLh       DOWNTO bitloc.TanLl   ));

            --Output( i ) . Chi2rphi   <= UNSIGNED( track_words( bitloc.Chi2rphih   DOWNTO bitloc.Chi2rphil ));
            --Output( i ) . Phi0       <= UNSIGNED( track_words( bitloc.Phi0h       DOWNTO bitloc.Phi0l ));
            --Output( i ) . InvR       <= UNSIGNED( track_words( bitloc.InvRh       DOWNTO bitloc.InvRl ));

            Output( i ) . ExtraMVA   <= UNSIGNED( track_words( WordLength + bitloc.ExtraMVAh   DOWNTO WordLength + bitloc.ExtraMVAl   ));
            Output( i ) . TQMVA      <= UNSIGNED( track_words( WordLength + bitloc.TQMVAh      DOWNTO WordLength + bitloc.TQMVAl      ));
            Output( i ) . Hitpattern <= UNSIGNED( track_words( WordLength + bitloc.Hitpatternh DOWNTO WordLength + bitloc.Hitpatternl ));
            Output( i ) . BendChi2   <= UNSIGNED( track_words( WordLength + bitloc.BendChi2h   DOWNTO WordLength + bitloc.BendChi2l   ));
            Output( i ) . D0         <= UNSIGNED( track_words( WordLength + bitloc.D0h         DOWNTO WordLength + bitloc.D0l         ));

            Output( i ) . Chi2rz     <= UNSIGNED( track_words( WordLength + bitloc.Chi2rzh     DOWNTO WordLength + bitloc.Chi2rzl ));
            Output( i ) . z0         <= UNSIGNED( track_words( WordLength + bitloc.Z0h         DOWNTO WordLength + bitloc.Z0l     ));
            Output( i ) . TanL       <= UNSIGNED( track_words( WordLength + bitloc.TanLh       DOWNTO WordLength + bitloc.TanLl   ));

            Output( i ) . Chi2rphi   <= UNSIGNED( track_words( bitloc.Chi2rphih - WordLength  DOWNTO bitloc.Chi2rphil - WordLength  ));
            Output( i ) . Phi0       <= UNSIGNED( track_words( bitloc.Phi0h - WordLength      DOWNTO bitloc.Phi0l - WordLength ));
            Output( i ) . InvR       <= UNSIGNED( track_words( bitloc.InvRh - WordLength      DOWNTO bitloc.InvRl - WordLength  ));
            Output( i ) . TrackValid <= UNSIGNED( track_words( bitloc.TrackValidi - WordLength DOWNTO bitloc.TrackValidi - WordLength ));
            
            Output( i ) .DataValid  <= to_boolean( track_words(bitloc.TrackValidi - WordLength));
            Output( i ) .FrameValid <= temp_framevalid1;
            clockCounter <= 3;
            
          
          ELSIF clockCounter = 3 THEN
            --Output( i ) . ExtraMVA   <= UNSIGNED( track_words( WordLength/2 + bitloc.ExtraMVAh   DOWNTO WordLength/2 + bitloc.ExtraMVAl   ));
            --Output( i ) . TQMVA      <= UNSIGNED( track_words( WordLength/2 + bitloc.TQMVAh      DOWNTO WordLength/2 + bitloc.TQMVAl      ));
            --Output( i ) . Hitpattern <= UNSIGNED( track_words( WordLength/2 + bitloc.Hitpatternh DOWNTO WordLength/2 + bitloc.Hitpatternl ));
            --Output( i ) . BendChi2   <= UNSIGNED( track_words( WordLength/2 + bitloc.BendChi2h   DOWNTO WordLength/2 + bitloc.BendChi2l   ));
            --Output( i ) . D0         <= UNSIGNED( track_words( WordLength/2 + bitloc.D0h         DOWNTO WordLength/2 + bitloc.D0l         ));

            --Output( i ) . Chi2rz     <= UNSIGNED( track_words( WordLength/2 + bitloc.Chi2rzh     DOWNTO WordLength/2 + bitloc.Chi2rzl ));
            --Output( i ) . z0         <= UNSIGNED( track_words( WordLength/2 + bitloc.Z0h         DOWNTO WordLength/2 + bitloc.Z0l     ));
            --Output( i ) . TanL       <= UNSIGNED( track_words( WordLength/2 + bitloc.TanLh       DOWNTO WordLength/2 + bitloc.TanLl   ));

            --Output( i ) . Chi2rphi   <= UNSIGNED( track_words( WordLength/2 + bitloc.Chi2rphih   DOWNTO WordLength/2 + bitloc.Chi2rphil ));
            --Output( i ) . Phi0       <= UNSIGNED( track_words( WordLength/2 + bitloc.Phi0h       DOWNTO WordLength/2 + bitloc.Phi0l ));
            --Output( i ) . InvR       <= UNSIGNED( track_words( WordLength/2 + bitloc.InvRh       DOWNTO WordLength/2 + bitloc.InvRl ));

            Output( i ) . ExtraMVA   <= UNSIGNED( track_words( WordLength + WordLength/2 + bitloc.ExtraMVAh   DOWNTO WordLength + WordLength/2 + bitloc.ExtraMVAl   ));
            Output( i ) . TQMVA      <= UNSIGNED( track_words( WordLength + WordLength/2 + bitloc.TQMVAh      DOWNTO WordLength + WordLength/2 + bitloc.TQMVAl      ));
            Output( i ) . Hitpattern <= UNSIGNED( track_words( WordLength + WordLength/2 + bitloc.Hitpatternh DOWNTO WordLength + WordLength/2 + bitloc.Hitpatternl ));
            Output( i ) . BendChi2   <= UNSIGNED( track_words( WordLength + WordLength/2 + bitloc.BendChi2h   DOWNTO WordLength + WordLength/2 + bitloc.BendChi2l   ));
            Output( i ) . D0         <= UNSIGNED( track_words( WordLength + WordLength/2 + bitloc.D0h         DOWNTO WordLength + WordLength/2 + bitloc.D0l         ));

            Output( i ) . Chi2rz     <= UNSIGNED( track_words( bitloc.Chi2rzh - WordLength/2    DOWNTO bitloc.Chi2rzl - WordLength/2 ));
            Output( i ) . z0         <= UNSIGNED( track_words( bitloc.Z0h  - WordLength/2       DOWNTO bitloc.Z0l - WordLength/2     ));
            Output( i ) . TanL       <= UNSIGNED( track_words( bitloc.TanLh - WordLength/2      DOWNTO bitloc.TanLl - WordLength/2   ));

            Output( i ) . Chi2rphi   <= UNSIGNED( track_words( bitloc.Chi2rphih - WordLength/2   DOWNTO bitloc.Chi2rphil - WordLength/2 ));
            Output( i ) . Phi0       <= UNSIGNED( track_words( bitloc.Phi0h - WordLength/2       DOWNTO bitloc.Phi0l - WordLength/2 ));
            Output( i ) . InvR       <= UNSIGNED( track_words( bitloc.InvRh - WordLength/2      DOWNTO bitloc.InvRl - WordLength/2 ));
            Output( i ) . TrackValid  <= UNSIGNED( track_words( bitloc.TrackValidi - WordLength/2  DOWNTO  bitloc.TrackValidi - WordLength/2 ));

            Output( i ) . DataValid  <= to_boolean( track_words( bitloc.TrackValidi - WordLength/2 ));
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
