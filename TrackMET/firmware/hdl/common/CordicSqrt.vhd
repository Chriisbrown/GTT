LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_MISC.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY CordicSqrt IS
    GENERIC (n_steps    : NATURAL RANGE 1 TO 8 := 4;
             multiplier : INTEGER := 1);
    PORT (
        clk  : IN STD_LOGIC := '0';
        Xin  : IN SIGNED ( 15 DOWNTO 0 )  := (OTHERS => '0');
        Yin  : IN SIGNED ( 15 DOWNTO 0 )  := (OTHERS => '0');
        Root : OUT UNSIGNED ( 15 DOWNTO 0 ) := (OTHERS => '0')
    );
END CordicSqrt;

ARCHITECTURE behavioral OF CordicSqrt IS

  TYPE tCordic IS RECORD
    x         : SIGNED( 15 DOWNTO 0 );
    y         : SIGNED( 15 DOWNTO 0 );
    sign      : BOOLEAN;
  END RECORD;

  CONSTANT cEmptyCordic : tCordic := ( ( OTHERS => '0' ) , ( OTHERS => '0' )  , FALSE );

  TYPE tCordicSteps IS ARRAY( n_steps + 1 DOWNTO 0 ) OF tCordic; -- Number of steps used by the CORDIC
  SIGNAL CordicSteps  : tCordicSteps := ( OTHERS => cEmptyCordic );

  SIGNAL NormedRoot : UNSIGNED( 21 DOWNTO 0 ) := (OTHERS => '0');
  SIGNAL TempRoot   : UNSIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');

BEGIN

PROCESS( clk ) 
    VARIABLE x_neg , y_neg : BOOLEAN;
  BEGIN
    IF( RISING_EDGE( clk ) ) THEN
      x_neg := ( Xin < 0 );
      y_neg := ( Yin < 0 );

      IF( NOT x_neg AND NOT y_neg ) THEN
        CordicSteps( 0 ) .sign <= True;
        CordicSteps( 0 ) .x    <= Xin;
        CordicSteps( 0 ) .y    <= Yin;
      ELSIF( x_neg AND NOT y_neg ) THEN
        CordicSteps( 0 ) .sign <= False;
        CordicSteps( 0 ) .x    <= -Xin;
        CordicSteps( 0 ) .y    <= Yin;
      ELSIF( x_neg AND y_neg ) THEN
        CordicSteps( 0 ) .sign <= True;
        CordicSteps( 0 ) .x    <= -Xin;
        CordicSteps( 0 ) .y    <= -Yin;
      ELSE
        CordicSteps( 0 ) .sign <= False;
        CordicSteps( 0 ) .x    <= Xin;
        CordicSteps( 0 ) .y    <= -Yin;
    END IF;

  END IF;
END PROCESS;



steps : FOR i IN 1 TO n_steps GENERATE
  PROCESS( clk )
    VARIABLE y_neg : BOOLEAN;
    BEGIN
      IF( RISING_EDGE( clk ) ) THEN
          y_neg := ( CordicSteps( i-1 ) .y < 0 );

          IF y_neg THEN
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x - SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y + SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          ELSE
            CordicSteps( i ) .x <= CordicSteps( i-1 ) .x + SHIFT_RIGHT( CordicSteps( i-1 ) .y , i-1 );
            CordicSteps( i ) .y <= CordicSteps( i-1 ) .y - SHIFT_RIGHT( CordicSteps( i-1 ) .x , i-1 );
          END IF;

          CordicSteps( i ) .sign <= CordicSteps( i-1 ) .sign;
      END IF;
  END PROCESS;
END GENERATE steps;

PROCESS( clk )
  VARIABLE unsigned_multiplier: UNSIGNED (5 DOWNTO 0) := TO_UNSIGNED(multiplier,6);
BEGIN
  IF ( RISING_EDGE( clk ) ) THEN
    CordicSteps( n_steps + 1 ) <= CordicSteps( n_steps );
    TempRoot                   <= UNSIGNED(CordicSteps( n_steps + 1 ).x);  --Buffer for clock constraint on DSP
    NormedRoot                 <= TempRoot*unsigned_multiplier;
    Root                       <= NormedRoot(21 DOWNTO 6);  --Divide by 2**6
  END IF;
END PROCESS;


END ARCHITECTURE behavioral;