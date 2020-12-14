LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.math_real.all;


use work.ipbus.all;
use work.emp_data_types.all;
use work.emp_project_decl.all;

use work.emp_device_decl.all;
use work.emp_ttc_decl.all;

use work.Constants.all;
use work.Types.all;


entity NNFeatureTransform is
    port(
      ap_clk    : in std_logic;
      input_1_V_ap_vld : out STD_LOGIC;
      input_1_V : out STD_LOGIC_VECTOR (NN_bit_width*nFeatures -1 downto 0);
      ap_start : out std_logic;
      LinksIn : in ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL )
    );
  end NNFeatureTransform;

architecture rtl of NNFeatureTransform is
    signal tw_qR   : integer;
    signal tw_phi  : integer;
    signal tw_tanL : integer;
    signal tw_z0   : integer;
    signal tw_d0   : integer;
    signal tw_bendchi : integer;
    signal tw_hitmask : std_logic_vector(6 downto 0);

    signal tw_chirz   : integer;
    signal tw_chirphi : integer;
    signal tw_valid1 : std_logic;
    signal tw_valid2 : std_logic;
    

    signal Feature_layer1: integer;
    signal Feature_layer2: integer;
    signal Feature_layer3: integer;
    signal Feature_layer4: integer;
    signal Feature_layer5: integer;
    signal Feature_layer6: integer;

    signal Feature_disk1: integer;
    signal Feature_disk2: integer;
    signal Feature_disk3: integer;
    signal Feature_disk4: integer;
    signal Feature_disk5: integer;

    signal Feature_InvR: integer;
    signal Feature_Tanl: integer;
    signal Feature_Z0: integer;

    signal Feature_BendChi: integer;
    signal Feature_ChiRphi: integer;
    signal Feature_ChiRz: integer;


    signal valid: std_logic;
    
    
  begin
    process(ap_clk)
  begin
    if rising_edge(ap_clk) then

      tw_qr   <= to_integer(signed(LinksIn(0).data(14 downto 0)));
      tw_phi  <= to_integer(signed(LinksIn(0).data(26 downto 15)));
      tw_tanL <= to_integer(signed(LinksIn(0).data(42 downto 27)));
      tw_z0   <= to_integer(signed(LinksIn(0).data(54 downto 43)));

      tw_d0      <= to_integer(signed(LinksIn(1).data(12 downto 0)));
     
      tw_bendchi <= to_integer(signed(LinksIn(1).data(15 downto 13)));
      tw_hitmask <= LinksIn(1).data(22 downto 16);
      tw_chirz   <= to_integer(signed(LinksIn(1).data(26 downto 23)));
      tw_chirphi <= to_integer(signed(LinksIn(1).data(30 downto 27)));

      tw_valid1 <= LinksIn(0).valid;
      tw_valid2 <= LinksIn(1).valid;

      Feature_BendChi <= to_integer(to_signed(tw_bendchi,NN_bit_width));
      Feature_ChiRphi <= to_integer(to_signed(tw_chirphi,NN_bit_width));
      Feature_ChiRz   <= to_integer(to_signed(tw_chirz,NN_bit_width));

      Feature_InvR <= to_integer(to_signed(tw_qR/16,NN_bit_width));
      Feature_Tanl <= to_integer(to_signed(tw_tanL/32,NN_bit_width));
      Feature_Z0 <= to_integer(to_signed(tw_z0,NN_bit_width));

      if (tw_tanL >= 0 and tw_tanL < 6639) then
        Feature_layer1  <= to_integer(unsigned(tw_hitmask(0 downto 0)));
        Feature_layer2  <= to_integer(unsigned(tw_hitmask(1 downto 1)));
        Feature_layer3  <= to_integer(unsigned(tw_hitmask(2 downto 2)));
        Feature_layer4  <= to_integer(unsigned(tw_hitmask(3 downto 3)));
        Feature_layer5  <= to_integer(unsigned(tw_hitmask(4 downto 4)));
        Feature_layer6  <= to_integer(unsigned(tw_hitmask(5 downto 5)));
        Feature_disk1  <= 0;
        Feature_disk2  <= 0;
        Feature_disk3  <= 0;
        Feature_disk4  <= 0;
        Feature_disk5  <= 0;

      elsif (tw_tanL >= 6639 and tw_tanL < 10607) then
        Feature_layer1  <= to_integer(unsigned(tw_hitmask(0 downto 0)));
        Feature_layer2  <= to_integer(unsigned(tw_hitmask(1 downto 1)));
        Feature_layer3  <= to_integer(unsigned(tw_hitmask(2 downto 2)));
        Feature_layer4  <= 0;
        Feature_layer5  <= 0;
        Feature_layer6  <= 0;
        Feature_disk1  <= to_integer(unsigned(tw_hitmask(3 downto 3)));
        Feature_disk2  <= to_integer(unsigned(tw_hitmask(4 downto 4)));
        Feature_disk3  <= to_integer(unsigned(tw_hitmask(5 downto 5)));
        Feature_disk4  <= to_integer(unsigned(tw_hitmask(6 downto 6)));
        Feature_disk5  <= 0;

      elsif (tw_tanL >= 10607 and tw_tanL < 16137) then
        Feature_layer1  <= to_integer(unsigned(tw_hitmask(0 downto 0)));
        Feature_layer2  <= to_integer(unsigned(tw_hitmask(1 downto 1)));
        Feature_layer3  <= 0;
        Feature_layer4  <=0;
        Feature_layer5  <=0;
        Feature_layer6  <=0;
        Feature_disk1  <= 0;
        Feature_disk2  <= to_integer(unsigned(tw_hitmask(2 downto 2)));
        Feature_disk3  <= to_integer(unsigned(tw_hitmask(3 downto 3)));
        Feature_disk4  <= to_integer(unsigned(tw_hitmask(4 downto 4)));
        Feature_disk5  <= to_integer(unsigned(tw_hitmask(5 downto 5)));

      elsif (tw_tanL >= 16137 and tw_tanL < 24781) then
        Feature_layer1  <= to_integer(unsigned(tw_hitmask(0 downto 0)));
        Feature_layer2  <= 0;
        Feature_layer3  <= 0;
        Feature_layer4  <= 0;
        Feature_layer5  <= 0;
        Feature_layer6  <= 0;
        Feature_disk1  <= to_integer(unsigned(tw_hitmask(1 downto 1)));
        Feature_disk2  <= to_integer(unsigned(tw_hitmask(2 downto 2)));
        Feature_disk3  <= to_integer(unsigned(tw_hitmask(3 downto 3)));
        Feature_disk4  <= to_integer(unsigned(tw_hitmask(4 downto 4)));
        Feature_disk5  <= to_integer(unsigned(tw_hitmask(5 downto 5)));
      else
        Feature_layer1  <= 0;
        Feature_layer2  <= 0;
        Feature_layer3  <= 0;
        Feature_layer4  <= 0;
        Feature_layer5  <= 0;
        Feature_layer6  <= 0;
        Feature_disk1  <= 0;
        Feature_disk2  <= 0;
        Feature_disk3  <= 0;
        Feature_disk4  <= 0;
        Feature_disk5  <= 0;
          
      end if;
  
      input_1_V(0*NN_bit_width + NN_bit_width-1 downto 0*NN_bit_width) <= std_logic_vector(to_signed((Feature_ChiRz+Feature_ChiRphi)*8,NN_bit_width));
      input_1_V(1*NN_bit_width + NN_bit_width-1 downto 1*NN_bit_width) <= std_logic_vector(to_signed(Feature_BendChi*8,NN_bit_width));
      input_1_V(2*NN_bit_width + NN_bit_width-1 downto 2*NN_bit_width) <= std_logic_vector(to_signed(Feature_ChiRphi*8,NN_bit_width));
      input_1_V(3*NN_bit_width + NN_bit_width-1 downto 3*NN_bit_width) <= std_logic_vector(to_signed(Feature_ChiRz*8,NN_bit_width));
      input_1_V(4*NN_bit_width + NN_bit_width-1 downto 4*NN_bit_width) <= std_logic_vector(to_signed((Feature_layer1 +  Feature_layer2 +  Feature_layer3  
                                                                                                   +  Feature_layer4 +  Feature_layer5 +  Feature_layer6
                                                                                                   +  Feature_disk1  +  Feature_disk2  +  Feature_disk3  
                                                                                                   +  Feature_disk4  +  Feature_disk5 )*feature_integer_multiplier*8,
                                                                                                     NN_bit_width));
  
      input_1_V(5*NN_bit_width + NN_bit_width-1 downto 5*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer1*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(6*NN_bit_width + NN_bit_width-1 downto 6*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer2*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(7*NN_bit_width + NN_bit_width-1 downto 7*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer3*feature_integer_multiplier*8,NN_bit_width)); 
   
      input_1_V(8*NN_bit_width + NN_bit_width-1 downto 8*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer4*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(9*NN_bit_width + NN_bit_width-1 downto 9*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer5*feature_integer_multiplier*8,NN_bit_width));
      input_1_V(10*NN_bit_width + NN_bit_width-1 downto 10*NN_bit_width) <= std_logic_vector(to_signed(Feature_layer6*feature_integer_multiplier*8,NN_bit_width));
  
      input_1_V(11*NN_bit_width + NN_bit_width-1 downto 11*NN_bit_width) <= std_logic_vector(to_signed(Feature_disk1*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(12*NN_bit_width + NN_bit_width-1 downto 12*NN_bit_width) <= std_logic_vector(to_signed(Feature_disk2*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(13*NN_bit_width + NN_bit_width-1 downto 13*NN_bit_width) <= std_logic_vector(to_signed(Feature_disk3*feature_integer_multiplier*8,NN_bit_width));
  
      input_1_V(14*NN_bit_width + NN_bit_width-1 downto 14*NN_bit_width) <= std_logic_vector(to_signed(Feature_disk4*feature_integer_multiplier*8,NN_bit_width)); 
      input_1_V(15*NN_bit_width + NN_bit_width-1 downto 15*NN_bit_width) <= std_logic_vector(to_signed(Feature_disk5*feature_integer_multiplier*8,NN_bit_width)); 

      input_1_V(16*NN_bit_width + NN_bit_width-1 downto 16*NN_bit_width) <= std_logic_vector(to_signed(Feature_InvR*8,NN_bit_width));
      
      input_1_V(17*NN_bit_width + NN_bit_width-1 downto 17*NN_bit_width) <= std_logic_vector(to_signed(Feature_Tanl*8,NN_bit_width)); 
      input_1_V(18*NN_bit_width + NN_bit_width-1 downto 18*NN_bit_width) <= std_logic_vector(to_signed(Feature_Z0*8,NN_bit_width)); 
      input_1_V(19*NN_bit_width + NN_bit_width-1 downto 19*NN_bit_width) <= std_logic_vector(to_signed((Feature_disk1 +  Feature_disk2 +  Feature_disk3  
                                                                                                     +  Feature_disk4  +  Feature_disk5)*feature_integer_multiplier*8,
                                                                                                        NN_bit_width));
      input_1_V(20*NN_bit_width + NN_bit_width-1 downto 20*NN_bit_width) <= std_logic_vector(to_signed((Feature_layer1 +  Feature_layer2 +  Feature_layer3 
                                                                                                     +  Feature_layer4 +  Feature_layer5 +  Feature_layer6)*feature_integer_multiplier*8,
                                                                                                        NN_bit_width));
      
      if (tw_valid1 = '1') and (tw_valid2 = '1') then
        valid <= '1';
      else
        valid <= '0';
      end if;

      input_1_V_ap_vld <= valid;
      ap_start <=valid;
      
    end if;
  
  end process;
  
  end architecture rtl;