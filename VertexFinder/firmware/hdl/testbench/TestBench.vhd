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
-- .include TopLevelInterfaces/mp7_data_types.vhd
-- .include ReuseableElements/PkgDebug.vhd
-- .include common/PkgConstants.vhd

-- .include testbench/DummyData.vhd
-- .include TestingAndDebugging/MP7CaptureFileReader.vhd

-- .include top/VertexFinderProcessor.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY Interfaces;
USE Interfaces.mp7_data_types.ALL;

LIBRARY VertexFinder;
USE VertexFinder.constants.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY top IS
END top;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF top IS

-- CLOCK SIGNALS
  SIGNAL clk                : STD_LOGIC            := '1';

-- LINK SIGNALS
  SIGNAL linksIn , linksInA : ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );
  SIGNAL linksOut           : ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL );

-- SELECT THE STIMULUS
-- CONSTANT Stimulus        : STRING               := "Dummy";
  CONSTANT Stimulus         : STRING               := "MP7file";

BEGIN

    clk <= NOT clk AFTER 2.5 ns;

-- -------------------------------------------------------------------------
-- STIMULII FOR THE ALGORITHMS
    g0                  : IF Stimulus = "Dummy" GENERATE
      DummyDataInstance : ENTITY work.DummyData
      PORT MAP( clk      => clk ,
                LinkData => linksIn
      );
    END GENERATE;
    g1                             : IF Stimulus = "MP7file" GENERATE
      MP7CaptureFileReaderInstance : ENTITY Utilities.MP7CaptureFileReader
      GENERIC MAP( FileName                => "" ,
                   StartFrameInclAnyHeader => 0 ,
                   GapLength               => 8 ,
                   HeaderLength            => 0 ,
                   PayloadLength           => 108 ,
                   DebugMessages           => FALSE
      )
      PORT MAP( clk      => clk ,
                LinkData => linksIn --A
      );

-- Hack to make the frames fixed length - should probably be added as an option into the file reader
        /* PROCESS( clk )
      BEGIN
        IF( RISING_EDGE( clk ) ) THEN
          LinksIn <= ( OTHERS => LWORD_NULL );
          IF( ( SimulationClockCounter - 1 ) MOD cPacketLength ) < cPacketLength-6 THEN
            FOR i IN 0 TO 71 LOOP
              LinksIn( i ) .data  <= linksInA( i ) .data;
              LinksIn( i ) .valid <= '1';
            END LOOP;
          END IF;
        END IF;
      END PROCESS ; */
    END GENERATE;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
-- THE ALGORITHMS UNDER TEST
  VertexFinderProcessorInstance : ENTITY work.VertexFinderProcessorTop
  PORT MAP(
    clk      => clk ,
    LinksIn  => linksIn ,
    LinksOut => linksOut
  );
-- -------------------------------------------------------------------------

END ARCHITECTURE rtl;
