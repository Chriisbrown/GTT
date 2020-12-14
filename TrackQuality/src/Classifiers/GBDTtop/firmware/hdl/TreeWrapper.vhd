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



entity TreeWrapper is
  port (
    clk : in std_logic;
    LinksIn : in ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL );
    LinksOut : out ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL )
    
  );
end entity TreeWrapper;

architecture rtl of TreeWrapper is
  signal X : txArray(0 to nFeatures - 1) := (others => to_tx(0));
  signal X_vld : boolean := false;
  signal y : tyArray(0 to nClasses - 1) := (others => to_ty(0));
  signal y_vld : boolArray(0 to nClasses - 1) := (others => false);
  signal const_v : boolean := true;
  signal temp_y : tyArray(0 to nClasses - 1) := (others => to_ty(0));
begin


    Input : entity work.FeatureTransform
    port map(clk, X, X_vld,LinksIn);

    -- pragma synthesis_off

    temp_y(0) <= to_ty(to_integer(X(0)));

    WriteOut1 : entity work.SimulationOutput
    generic map ("Feature1.txt","./")
    port map (clk,temp_y,const_v);
            
    -- pragma synthesis_on

    UUT : entity work.BDTTop
    port map(clk, X, X_vld, y, y_vld);

    -- pragma synthesis_off

    WriteOut2 : entity work.SimulationOutput
    generic map ("Output1.txt","./")
    port map (clk,y,const_v);

    -- pragma synthesis_on

    Output : entity work.RunningOutput
    port map(clk, y, y_vld(0),LinksOut);

     -- pragma synthesis_off
    WriteOut3 : entity work.ValidOutput
    generic map ("Validout.txt","./")
    port map (clk,to_std_logic(y_vld(0)),const_v);
     -- pragma synthesis_on

end architecture rtl;
