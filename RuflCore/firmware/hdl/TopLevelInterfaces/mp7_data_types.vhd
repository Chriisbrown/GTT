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

-- .library Interfaces

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
PACKAGE mp7_data_types IS

  CONSTANT LWORD_WIDTH : INTEGER := 32;

  TYPE lword IS
    RECORD
      data   : STD_LOGIC_VECTOR( LWORD_WIDTH - 1 DOWNTO 0 );
      valid  : STD_LOGIC;
      start  : STD_LOGIC;
      strobe : STD_LOGIC;
    END RECORD;

  TYPE ldata IS ARRAY( NATURAL RANGE <> ) OF lword;

  CONSTANT LWORD_NULL : lword               := ( ( OTHERS => '0' ) , '0' , '0' , '0' );
  CONSTANT LDATA_NULL : ldata( 0 DOWNTO 0 ) := ( 0        => LWORD_NULL );

END mp7_data_types;
