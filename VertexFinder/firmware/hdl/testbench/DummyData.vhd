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
-- .include ReuseableElements/PkgUtilities.vhd
-- .include common/PkgConstants.vhd

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY VertexFinder;
USE VertexFinder.constants.ALL;

LIBRARY Interfaces;
USE Interfaces.mp7_data_types.ALL;

LIBRARY Utilities;
USE Utilities.debugging.ALL;
USE Utilities.Utilities.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY DummyData IS
PORT( clk        : IN STD_LOGIC;
        LinkData : OUT ldata( 71 DOWNTO 0 ) := ( OTHERS => LWORD_NULL )
     );
END ENTITY DummyData;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF DummyData IS
BEGIN
  references               : PROCESS( clk )
    VARIABLE SEED1 , SEED2 : POSITIVE := 1226828063;
    VARIABLE RandBit       : STD_LOGIC;
    VARIABLE RandVector    : STD_LOGIC_VECTOR( 8 DOWNTO 0 );

  BEGIN

    IF( RISING_EDGE( clk ) ) THEN

      FOR i IN 0 TO 71 LOOP
        LinkData( i ) <= LWORD_NULL;

-- Frame Valid
        IF SimulationClockCounter < ( cTimeMultiplexingPeriod * cFramesPerBx ) -6 THEN
          LinkData( i ) .valid <= '1';
        END IF;

-- IF SimulationClockCounter > 5 AND SimulationClockCounter < 216 THEN
-- IF (SimulationClockCounter > 0) and (SimulationClockCounter < 5) THEN
        IF( SimulationClockCounter = 5 ) THEN

-- if i mod 8 = 0 then
          IF i = 5 THEN

-- R_over_Z
            SET_RANDOM_VAR( SEED1 , SEED2 , RandVector );
            LinkData( i ) .data( 10 DOWNTO 0 ) <= "00100001010"; --STD_LOGIC_VECTOR( UNSIGNED( LinkData( i ) .data( 10 DOWNTO 0 ) ) + UNSIGNED( RandVector( 4 DOWNTO 0 ) ) );

-- Energy
            SET_RANDOM_VAR( SEED1 , SEED2 , RandVector );
            LinkData( i ) .data( 31 DOWNTO 24 ) <= RandVector( 7 DOWNTO 0 );

-- Local-phi
            SET_RANDOM_VAR( SEED1 , SEED2 , RandVector );
-- LinkData( i ) .data( 19 DOWNTO 11 ) <= RandVector;
            LinkData( i ) .data( 19 DOWNTO 11 ) <= ( OTHERS => '0' );

--SET_RANDOM_VAR( SEED1 , SEED2 , RandBit );
-- Sector identifier
            CASE i MOD 8 IS
              WHEN 0 | 1  => LinkData( i ) .data( 20 ) <= '1'; --RandBit; -- CURRENTLY NOTHING IN THE OVERLAP!
              WHEN 2 | 3  => LinkData( i ) .data( 20 ) <= '0';
              WHEN 4 | 5  => LinkData( i ) .data( 20 ) <= '1';
              WHEN 6 | 7  => LinkData( i ) .data( 20 ) <= '0'; --RandBit; -- CURRENTLY NOTHING IN THE OVERLAP! 
              WHEN OTHERS => NULL; -- Can'tData believe I'm having to specify this...
            END CASE;

          END IF;
        END IF;

      END LOOP;

      SimulationClockCounter <= SimulationClockCounter + 1;

    END IF;
  END PROCESS;
END ARCHITECTURE rtl;
