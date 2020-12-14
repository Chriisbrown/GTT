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


entity FeatureTransform is
    port(
      ap_clk    : in std_logic;
      feature_vector : out txArray(0 to nFeatures - 1) := (others => to_tx(0));
      feature_v : out boolean := false;
      LinksIn : in ldata(4 * N_REGION - 1 downto 0) := ( others => LWORD_NULL )
    );
  end FeatureTransform;

architecture rtl of FeatureTransform is
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


    signal Feature_BendChi: integer;
    signal Feature_ChiRphi: integer;
    signal Feature_ChiRz: integer;

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

    signal valid: boolean;

    
  begin
    process(ap_clk)
  begin
    if rising_edge(ap_clk) then

      tw_qr   <= to_integer(signed(LinksIn(0).data(14 downto 0)));
      tw_phi  <= to_integer(signed(LinksIn(0).data(26 downto 15)));
      tw_tanL <= to_integer(signed(LinksIn(0).data(42 downto 27)));
      tw_z0   <= to_integer(signed(LinksIn(0).data(54 downto 43)));

      tw_d0      <= to_integer(signed(LinksIn(1).data(12 downto 0)));
     
      tw_bendchi <= to_integer(unsigned(LinksIn(1).data(15 downto 13)));
      tw_hitmask <= LinksIn(1).data(22 downto 16);
      tw_chirz   <= to_integer(unsigned(LinksIn(1).data(26 downto 23)));
      tw_chirphi <= to_integer(unsigned(LinksIn(1).data(30 downto 27)));

      tw_valid1 <= LinksIn(0).valid;
      tw_valid2 <= LinksIn(1).valid;

      Feature_BendChi <= to_integer(to_signed(tw_bendchi,feature_bit_width));
      Feature_ChiRphi <= to_integer(to_signed(tw_chirphi,feature_bit_width));
      Feature_ChiRz   <= to_integer(to_signed(tw_chirz,feature_bit_width));

      Feature_InvR <= to_integer(to_signed(tw_qR/16,feature_bit_width));
      Feature_Tanl <= to_integer(to_signed(tw_tanL/32,feature_bit_width));
      Feature_Z0 <= to_integer(to_signed(tw_z0,feature_bit_width));

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
  
      feature_vector(0)  <= to_signed((Feature_ChiRz+Feature_ChiRphi),feature_bit_width);
      feature_vector(1) <= to_signed(Feature_BendChi,feature_bit_width);
      feature_vector(2) <= to_signed(Feature_ChiRphi,feature_bit_width); 
  
      feature_vector(3) <= to_signed(Feature_ChiRz,feature_bit_width);
      feature_vector(4) <= to_signed((Feature_layer1 +  Feature_layer2 +  Feature_layer3  
                                   +  Feature_layer4 +  Feature_layer5 +  Feature_layer6
                                   +  Feature_disk1  +  Feature_disk2  +  Feature_disk3  
                                   +  Feature_disk4  +  Feature_disk5 )*feature_integer_multiplier,
                                      feature_bit_width);
  
      feature_vector(5)  <= to_signed(Feature_layer1*feature_integer_multiplier,feature_bit_width); 
      feature_vector(6)  <= to_signed(Feature_layer2*feature_integer_multiplier,feature_bit_width); 
      feature_vector(7)  <= to_signed(Feature_layer3*feature_integer_multiplier,feature_bit_width); 
   
      feature_vector(8)  <= to_signed(Feature_layer4*feature_integer_multiplier,feature_bit_width); 
      feature_vector(9)  <= to_signed(Feature_layer5*feature_integer_multiplier,feature_bit_width);
      feature_vector(10) <= to_signed(Feature_layer6*feature_integer_multiplier,feature_bit_width);
  
      feature_vector(11)  <= to_signed(Feature_disk1*feature_integer_multiplier,feature_bit_width); 
      feature_vector(12)  <= to_signed(Feature_disk2*feature_integer_multiplier,feature_bit_width); 
      feature_vector(13)  <= to_signed(Feature_disk3*feature_integer_multiplier,feature_bit_width);
  
      feature_vector(14) <= to_signed(Feature_disk4*feature_integer_multiplier,feature_bit_width); 
      feature_vector(15) <= to_signed(Feature_disk5*feature_integer_multiplier,feature_bit_width); 

      feature_vector(16) <= to_signed(Feature_InvR,feature_bit_width);
      
      feature_vector(17) <= to_signed(Feature_Tanl,feature_bit_width); 
      feature_vector(18) <= to_signed(Feature_Z0,feature_bit_width); 
      feature_vector(19) <= to_signed((Feature_disk1 +  Feature_disk2 +  Feature_disk3  
                                    +  Feature_disk4  +  Feature_disk5)*feature_integer_multiplier,
                                       feature_bit_width);
      feature_vector(20) <= to_signed((Feature_layer1 +  Feature_layer2 +  Feature_layer3 
                                    +  Feature_layer4 +  Feature_layer5 +  Feature_layer6)*feature_integer_multiplier,
                                       feature_bit_width);
      
      if (tw_valid1 = '1' and tw_valid2 =  '1') then
        valid <= true;
      else
        valid <= false;
      end if;

      feature_v <= valid;
      
    end if;
  
  end process;
  
  end architecture rtl;