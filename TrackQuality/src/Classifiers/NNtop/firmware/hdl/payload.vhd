LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;



entity emp_payload is
	port(
		clk: in std_logic; -- ipbus signals
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		clk_payload: in std_logic_vector(2 downto 0);
		rst_payload: in std_logic_vector(2 downto 0);
		clk_p: in std_logic; -- data clock
		rst_loc: in std_logic_vector(N_REGION - 1 downto 0);
		clken_loc: in std_logic_vector(N_REGION - 1 downto 0);
		ctrs: in ttc_stuff_array;
		bc0: out std_logic;
		d: in ldata(4 * N_REGION - 1 downto 0); -- data in
		q: out ldata(4 * N_REGION - 1 downto 0); -- data out
		gpio: out std_logic_vector(29 downto 0); -- IO to mezzanine connector
		gpio_en: out std_logic_vector(29 downto 0) -- IO to mezzanine connector (three-state enables)
	);
		
end emp_payload;

ARCHITECTURE rtl OF emp_payload IS
 -- pragma synthesis_off
signal const_v : boolean := false;
 -- pragma synthesis_on
BEGIN
  -- pragma synthesis_off
  WriteOut : entity work.ValidOutput
  generic map ("Validin.txt","./")
  port map (clk_p,d(0).valid,const_v);
  -- pragma synthesis_on

-- ---------------------------------------------------------------------------------
  AlgorithmInstance : ENTITY work.NNWrapper
  PORT MAP(
	ap_clk => clk_p ,
	ap_rst => '0',--rst,
	LinksIn  => d,
	LinksOut => q
  );
-- ---------------------------------------------------------------------------------

  gpio    <= ( OTHERS => '0' );
  gpio_en <= ( OTHERS => '0' );

END rtl;