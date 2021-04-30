LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;


ENTITY MAC is
    PORT (clk, reset : IN std_logic := '0';
          Pt         : IN UNSIGNED( PtWidth - 1 DOWNTO 0 ) := ( OTHERS => '0' );
          Phi        : IN   SIGNED( GlobalPhiWidth DOWNTO 0 ) := ( OTHERS => '0' );  --(2**13 for 2**11 assuming 2**8 -> 2**10 phi LUT))
          SumPt      : OUT  SIGNED( PtWidth DOWNTO 0 ) := ( OTHERS => '0' )
    );
END ENTITY MAC;

ARCHITECTURE BEHAVIORAL OF MAC IS
    
    SIGNAL s_pt         : SIGNED  ( PtWidth DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL s_phi        : SIGNED  ( GlobalPhiWidth DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL s_sum        : SIGNED  ( PtWidth + GlobalPhiWidth + 1 DOWNTO 0 ) := ( OTHERS => '0' ); --(2**28 when phi is 2**13 assuming 2**8 -> 2**24 phi LUT))
    SIGNAL SumPt_Buffer : SIGNED  ( PtWidth + GlobalPhiWidth + 1 DOWNTO 0 ) := ( OTHERS => '0' );

    SIGNAL input_pt  : SIGNED  ( PtWidth DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL input_phi : SIGNED  ( GlobalPhiWidth DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL product   : SIGNED  ( PtWidth + GlobalPhiWidth + 1 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL sum       : SIGNED  ( PtWidth + GlobalPhiWidth + 1 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

    s_pt  <= TO_SIGNED( TO_INTEGER(Pt),PtWidth+1 );
    s_phi <= Phi;

    PROCESS( clk)  IS


     
    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset THEN
                sum <=      ( OTHERS => '0' );
                product <=  ( OTHERS => '0' );
                input_pt <=  ( OTHERS => '0' );
                input_phi <= ( OTHERS => '0' );
            ELSE
                sum <= product + sum;
            END IF;

            s_sum <= sum;

            product   <= input_pt * input_phi;
            input_pt  <= s_pt;
            input_phi <= s_phi;
        END IF;
    END PROCESS;
    SumPt_Buffer <= s_sum;
    SumPt <= TO_SIGNED(TO_INTEGER(SHIFT_RIGHT(SumPt_Buffer,(GlobalPhiWidth-GlobalPhiWidthExtra))),PtWidth+1);
    --SumPt <= SumPt_Buffer( PtWidth + GlobalPhiWidth + 1 DOWNTO GlobalPhiWidth + 1  ;
    
END ARCHITECTURE BEHAVIORAL;