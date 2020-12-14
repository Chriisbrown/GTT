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


entity NNWrapper is
  port (
    ap_clk : in std_logic;
    LinksIn : in ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL );
    LinksOut : out ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL );
    ap_rst : in std_logic
    

  );
end entity NNWrapper;

architecture rtl of NNWrapper is
  signal input_1_V_ap_vld : STD_LOGIC := '0';
  signal input_1_V : STD_LOGIC_VECTOR ((NN_bit_width*nFeatures) -1 downto 0);
  signal layer13_out_0_V : STD_LOGIC_VECTOR (NN_bit_width -1 downto 0);
  signal layer13_out_0_V_ap_vld : STD_LOGIC := '0';


  signal ap_start : std_logic := '0';

  signal const_size_in_1 : STD_LOGIC_VECTOR (NN_bit_width -1 downto 0);
  signal const_size_in_1_ap_vld : std_logic := '0';
  signal const_size_out_1 : STD_LOGIC_VECTOR (NN_bit_width -1 downto 0);
  signal const_size_out_1_ap_vld : std_logic := '0';

  -- pragma synthesis_off
  signal const_v : boolean := true;
  signal temp_y : tyArray(0 to nClasses - 1) := (others => to_ty(0));
  signal temp_out : tyArray(0 to nClasses - 1) := (others => to_ty(0));
  -- pragma synthesis_on


  signal ap_done : STD_LOGIC := '0';
  signal ap_idle : STD_LOGIC := '0';
  signal ap_ready : STD_LOGIC := '0';
begin

    Input : entity work.NNFeatureTransform
    port map(ap_clk, input_1_V_ap_vld, input_1_V,ap_start,LinksIn);

    -- pragma synthesis_off

    temp_y(0) <= to_ty(to_integer(signed(input_1_V(15 downto 0))));

    WriteOut1 : entity work.SimulationOutput
    generic map ("Feature1.txt","./")
    port map (ap_clk,temp_y,const_v);
             
    -- pragma synthesis_on

    UUT : entity work.myproject
    port map( ap_clk,
              ap_rst,
              ap_start,
              ap_done,
              ap_idle,
              ap_ready,
              input_1_V_ap_vld,
              input_1_V,
              layer13_out_0_V,
              layer13_out_0_V_ap_vld,
              const_size_in_1,
              const_size_in_1_ap_vld,
              const_size_out_1,
              const_size_out_1_ap_vld);

     -- pragma synthesis_off

     temp_out(0) <= to_ty(to_integer(signed(layer13_out_0_V(15 downto 0))));

     WriteOut2 : entity work.SimulationOutput
     generic map ("Output1.txt","./")
     port map (ap_clk,temp_out,const_v); 
     -- pragma synthesis_on


    Output : entity work.RunningOutput
    port map(ap_clk, layer13_out_0_V,layer13_out_0_V_ap_vld,LinksOut);
    -- pragma synthesis_off
    WriteOut6 : entity work.ValidOutput
    generic map ("Validout.txt","./")
    port map (ap_clk,layer13_out_0_V_ap_vld,const_v);
    -- pragma synthesis_on

end architecture rtl;
