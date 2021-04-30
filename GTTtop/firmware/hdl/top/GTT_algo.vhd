library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

use work.gtt_interface_pkg;
library GTT;

entity gtt_algo is
  port (
    clock   : in std_logic;
    inputs  : in gtt_interface_pkg.link_array(53 downto 0);
    outputs : out gtt_interface_pkg.link_array(2 downto 0)
    );
end gtt_algo;

architecture rtl of gtt_algo is

  constant N_INPUT_STREAMS  : integer := 54;
  constant N_OUTPUT_STREAMS : integer := 54;

begin

  -- Generate 3 copies of the GTT
  GenAlgos:
  for i in 0 to 2 generate
    signal inputsTMP : gtt_interface_pkg.link_array(17 downto 0);
    signal outputsTMP : gtt_interface_pkg.link_array(0 downto 0);
  begin
    inputsTMP(17 downto 0) <= inputs(18*(i+1)-1 downto 18*i);
    outputs(i downto i) <= outputsTMP(0 downto 0);
    GTTInstance : entity GTT.GTTTop
    port map(
      clk => clock,
      LinksIn => inputsTMP,
      LinksOut => outputsTMP
    );
  end generate;
end rtl;
