LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY MAC is
    port (clk, reset : in std_logic;
          Pt  : IN INTEGER;
          Phi : IN INTEGER;
          SumPt : OUT SIGNED ( 15 DOWNTO 0 )
    );
END ENTITY MAC;

architecture behavioral of MAC is
    
    signal s_pt,s_phi,s_sum : INTEGER;
    
begin

    s_pt <= Pt;
    s_phi <= Phi;

    process(clk) is

      variable input_pt, input_phi : INTEGER := 0;
      variable product, sum : INTEGER := 0;

     
    begin
        if rising_edge(clk) THEN
            if reset THEN
                sum := 0;
            else
                sum := product + sum;
            end if;

            s_sum <= sum;

            product := input_pt * input_phi;
            input_pt := s_pt;
            input_phi := s_phi;
        end if;
    end process;

    SumPt <= TO_SIGNED(s_sum/2**12,16);
    
end architecture behavioral;