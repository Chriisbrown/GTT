LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;



--library GBDT;
use work.Constants.all;
use work.Types.all;


entity RunningInput is
  port(
    clk    : in std_logic;
    feature_vector : in txArray(nFeatures - 1 downto 0) := (others => to_tx(0));
    feature_v : in boolean := false;
    X : out txArray(nFeatures - 1 downto 0) := (others => to_tx(0));
    v : out boolean := false
   
  );
end RunningInput;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
architecture rtl of RunningInput is

begin
  process(clk)
begin
  if rising_edge(clk) then


    X(20) <= to_tx(to_integer(unsigned(feature_vector(11 downto 0 ))));
    X(19) <= to_tx(to_integer(unsigned(feature_vector(23 downto 12))));
    X(18) <= to_tx(to_integer(unsigned(feature_vector(35 downto 24))));

    X(17) <= to_tx(to_integer(unsigned(feature_vector(47 downto 36))));
    X(16) <= to_tx(to_integer(unsigned(feature_vector(59 downto 48)))); 
    X(15) <= to_tx(to_integer(unsigned(feature_vector(71 downto 60)))); 

    X(14) <= to_tx(to_integer(unsigned(feature_vector(83 downto 72)))); 
    X(13) <= to_tx(to_integer(unsigned(feature_vector(95 downto 84))));
    X(12) <= to_tx(to_integer(unsigned(feature_vector(107 downto 96)))); 

    X(11) <= to_tx(to_integer(unsigned(feature_vector(119 downto 108)))); 
    X(10) <= to_tx(to_integer(unsigned(feature_vector(131 downto 120)))); 
    X(9) <= to_tx(to_integer(unsigned(feature_vector(143 downto 132)))); 

    X(8) <= to_tx(to_integer(unsigned(feature_vector(155 downto 144)))); 
    X(7) <= to_tx(to_integer(unsigned(feature_vector(167 downto 156)))); 
    X(6) <= to_tx(to_integer(unsigned(feature_vector(179 downto 168)))); 

    X(5) <= to_tx(to_integer(unsigned(feature_vector(191 downto 180)))); 
    X(4) <= to_tx(to_integer(signed(feature_vector(203 downto 192)))); 
    X(3) <= to_tx(to_integer(signed(feature_vector(215 downto 204)))); 

    X(2) <= to_tx(to_integer(signed(feature_vector(227 downto 216)))); 
    X(1) <= to_tx(to_integer(unsigned(feature_vector(239 downto 228)))); 
    X(0) <= to_tx(to_integer(unsigned(feature_vector(251 downto 240)))); 

    v <= to_boolean(feature_v);
  end if;

end process;

end architecture rtl;
