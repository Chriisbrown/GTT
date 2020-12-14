LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

use work.ipbus.all;
--use work.ipbus_reg_types.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;
LIBRARY LinkDecode;

ENTITY emp_payload IS
  PORT(
    clk         : IN STD_LOGIC; -- ipbus signals
    rst         : IN STD_LOGIC;
    ipb_in      : IN ipb_wbus;
    ipb_out     : OUT ipb_rbus;
    clk_payload : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
    rst_payload : IN STD_LOGIC_VECTOR( 2 DOWNTO 0 );
    clk_p       : IN STD_LOGIC; -- data clock
    rst_loc     : IN STD_LOGIC_VECTOR( N_REGION - 1 DOWNTO 0 );
    clken_loc   : IN STD_LOGIC_VECTOR( N_REGION - 1 DOWNTO 0 );
    ctrs        : IN ttc_stuff_array;
    bc0         : OUT STD_LOGIC;
    d           : IN ldata( 4 * N_REGION - 1 DOWNTO 0 );  -- data in
    q           : OUT ldata( 4 * N_REGION - 1 DOWNTO 0 ); -- data out
    gpio        : OUT STD_LOGIC_VECTOR( 29 DOWNTO 0 );    -- IO to mezzanine connector
    gpio_en     : OUT STD_LOGIC_VECTOR( 29 DOWNTO 0 )     -- IO to mezzanine connector( three-state enables )
  );
END emp_payload;


ARCHITECTURE rtl OF emp_payload IS
BEGIN

-- ---------------------------------------------------------------------------------
  AlgorithmInstance : ENTITY LinkDecode.LinkDecodeProcessorTop
  PORT MAP(
    clk       => clk_p ,
    LinksIn   => d ,
    LinksOut  => q 
  );
-- ---------------------------------------------------------------------------------

  gpio    <= ( OTHERS => '0' );
  gpio_en <= ( OTHERS => '0' );

END rtl;
