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

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.Constants.all;


entity RunningOutput is
  port(
    ap_clk : IN STD_LOGIC;
    layer13_out_0_V : IN STD_LOGIC_VECTOR (NN_bit_width -1  downto 0);
    layer13_out_0_V_ap_vld : IN STD_LOGIC;
    LinksOut : out ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL )
  );
end RunningOutput;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
architecture rtl of RunningOutput is

  signal dr: ldata(N_REGION * 4 - 1 downto 0);
  
begin
process(ap_clk)
begin
  if rising_edge(ap_clk) then
    dr(0).data(NN_bit_width - 1 downto 0) <= layer13_out_0_V;
    dr(0).valid <= layer13_out_0_V_ap_vld;
    dr(0).strobe <= '1';
    LinksOut(0) <= dr(0);
    
  end if;
end process;

  


  

end architecture rtl;
