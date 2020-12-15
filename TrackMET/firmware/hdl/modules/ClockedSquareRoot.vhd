LIBRARY library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

ENTITY ClockedSquareRoot IS
    GENERIC (in_width NATURAL RANGE 4 TO 32 := 32);
    PORT (
        clk : IN STD_LOGIC := '0';
        ValueIn : IN UNSIGNED ( 31 DOWNTO 0 );
        Result : OUT UNSIGNED ( 16 DOWNTO 0 );
    );
END ClockedSquareRoot;

ARCHITECTURE behavioral OF ClockedSquareRoot IS
SIGNAL op : UNSIGNED(in_width-1 DOWNTO 0);
SIGNAL res: UNSIGNED(in_width-1 DOWNTO 0);
SIGNAL one: UNSIGNED(in_width-1 DOWNTO 0);

SIGNAL bits : INTEGER RANGE in_width DOWNTO 0;
TYPE states is (idle,shift,calc,done);
SIGNAL state: states;
    
BEGIN
  PROCESS(clk)
  BEGIN
    IF RISING_EDGE( clk ) THEN
      CASE state IS

          WHEN idle => THEN
            state <= shift;
            one <= TO_UNSIGNED( 2**(in_width -2 ), in_width);
            op <= ValueIn;
            res <= (OTHERS => '0');

          WHEN shift => THEN
            IF (one > op) THEN
              one <= one / 4;
            ELSE
              z <= calc;
            END IF;

          WHEN calc => THEN
            IF (one / = 0 ) THEN 
              IF (op> = res + one) THEN
                 op <= op - (res + one);
                 res <= res / 2 + one;
              ELSE 
                 res <= res / 2 ;
              END  IF ;
              one <= one / 4 ;
            ELSE
              z <= done;
            END  IF ;

          WHEN done => THEN
            z <= idle;
      END CASE;
    END IF;
  END PROCESS;

  Result <= UNSIGNED(res (Result 'RANGE));
END ARCHITECTURE behavioral;