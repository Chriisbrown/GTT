LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.Constants.all;
use work.Types.all;

entity RunningInput is
  port(
    ap_clk    : in std_logic;
    input_1_V_ap_vld : OUT STD_LOGIC;
    input_1_V : OUT STD_LOGIC_VECTOR (NN_bit_width*nFeatures -1 downto 0);
    feature_vector : in txArray(0 to nFeatures - 1) := (others => to_tx(0));
    feature_v : boolean := false;
    ap_start : out std_logic
  );
end RunningInput;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
architecture rtl of RunningInput is

begin
  process(ap_clk)
begin
  if rising_edge(ap_clk) then

    input_1_V(0*NN_bit_width + NN_bit_width-1 downto 0*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(0)),NN_bit_width));
    input_1_V(1*NN_bit_width + NN_bit_width-1 downto 1*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(1)),NN_bit_width));
    input_1_V(2*NN_bit_width + NN_bit_width-1 downto 2*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(2)),NN_bit_width));
    input_1_V(3*NN_bit_width + NN_bit_width-1 downto 3*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(3)),NN_bit_width));
    input_1_V(4*NN_bit_width + NN_bit_width-1 downto 4*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(4)),NN_bit_width));
    input_1_V(5*NN_bit_width + NN_bit_width-1 downto 5*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(5)),NN_bit_width));
    input_1_V(6*NN_bit_width + NN_bit_width-1 downto 6*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(6)),NN_bit_width));
    input_1_V(7*NN_bit_width + NN_bit_width-1 downto 7*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(7)),NN_bit_width));
    input_1_V(8*NN_bit_width + NN_bit_width-1 downto 8*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(8)),NN_bit_width));
    input_1_V(9*NN_bit_width + NN_bit_width-1 downto 9*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(9)),NN_bit_width));
    input_1_V(10*NN_bit_width + NN_bit_width-1 downto 10*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(10)),NN_bit_width));
    input_1_V(11*NN_bit_width + NN_bit_width-1 downto 11*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(11)),NN_bit_width));
    input_1_V(12*NN_bit_width + NN_bit_width-1 downto 12*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(12)),NN_bit_width));
    input_1_V(13*NN_bit_width + NN_bit_width-1 downto 13*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(13)),NN_bit_width));
    input_1_V(14*NN_bit_width + NN_bit_width-1 downto 14*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(14)),NN_bit_width));
    input_1_V(15*NN_bit_width + NN_bit_width-1 downto 15*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(15)),NN_bit_width));
    input_1_V(16*NN_bit_width + NN_bit_width-1 downto 16*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(16)),NN_bit_width));
    input_1_V(17*NN_bit_width + NN_bit_width-1 downto 17*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(17)),NN_bit_width));
    input_1_V(18*NN_bit_width + NN_bit_width-1 downto 18*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(18)),NN_bit_width));
    input_1_V(19*NN_bit_width + NN_bit_width-1 downto 19*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(19)),NN_bit_width));
    input_1_V(20*NN_bit_width + NN_bit_width-1 downto 20*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(20)),NN_bit_width));
    --vector_to_array : for i in 0 to nFeatures-1 loop
    --  input_1_V(i*NN_bit_width + NN_bit_width-1 downto i*NN_bit_width) <= std_logic_vector(to_signed(to_integer(feature_vector(i)),NN_bit_width));
    --end loop vector_to_array;
    


    input_1_V_ap_vld <= '1';--<= to_std_logic(feature_v);
    ap_start <= '1';--LinksIn(0).start;
    
  end if;

end process;

end architecture rtl;
