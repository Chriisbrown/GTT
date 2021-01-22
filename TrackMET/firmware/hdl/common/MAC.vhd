LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY MAC is
    PORT (clk, reset : IN std_logic := '0';
          Pt         : IN INTEGER   := 0;
          Phi        : IN INTEGER   := 0;
          SumPt      : OUT SIGNED ( 15 DOWNTO 0 ) := (OTHERS => '0')
    );
END ENTITY MAC;

ARCHITECTURE BEHAVIORAL OF MAC IS
    
    SIGNAL s_pt,s_phi,s_sum : INTEGER := 0;
    SIGNAL SumPt_Buffer : INTEGER := 0;
    
BEGIN

    s_pt  <= Pt;
    s_phi <= Phi;

    PROCESS( clk)  IS

      VARIABLE input_pt, input_phi : INTEGER := 0;
      VARIABLE product, sum        : INTEGER := 0;

     
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset THEN
                sum := 0;
            ELSE
                sum := product + sum;
            END IF;

            s_sum <= sum;

            product   := input_pt * input_phi;
            input_pt  := s_pt;
            input_phi := s_phi;
        END IF;
    END PROCESS;
    SumPt_Buffer <= s_sum/2**12;
    SumPt <= TO_SIGNED( SumPt_Buffer , 16) ;
    
END ARCHITECTURE BEHAVIORAL;