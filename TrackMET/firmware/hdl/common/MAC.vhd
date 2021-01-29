LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


ENTITY MAC is
    PORT (clk, reset : IN std_logic := '0';
          Pt         : IN UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
          Phi        : IN  SIGNED ( 12 DOWNTO 0 ) := ( OTHERS => '0' );
          SumPt      : OUT SIGNED ( 15 DOWNTO 0 ) := ( OTHERS => '0' )
    );
END ENTITY MAC;

ARCHITECTURE BEHAVIORAL OF MAC IS
    
    SIGNAL s_pt         : SIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL s_phi        : SIGNED  ( 12 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL s_sum        : SIGNED  ( 28 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL SumPt_Buffer : SIGNED  ( 28 DOWNTO 0 ) := ( OTHERS => '0' );

    SIGNAL input_pt  : SIGNED  ( 15 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL input_phi : SIGNED  ( 12 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL product   : SIGNED  ( 28 DOWNTO 0 ) := ( OTHERS => '0' );
    SIGNAL sum       : SIGNED  ( 28 DOWNTO 0 ) := ( OTHERS => '0' );

BEGIN

    s_pt  <= SIGNED( Pt );
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
    SumPt <= SHIFT_LEFT(SumPt_Buffer( 28 DOWNTO 13 ),1) ;
    
END ARCHITECTURE BEHAVIORAL;