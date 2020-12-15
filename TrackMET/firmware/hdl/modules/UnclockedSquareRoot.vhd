library IEEE;
use IEEE.STD_LOGIC_1164. ALL ;
use IEEE.NUMERIC_STD. ALL ;

ENTITY UnclockedSquareRoot IS
    GENERIC (in_width : NATURAL RANGE 4 TO 32 := 32);
    PORT (
        ValueIn : IN UNSIGNED ( 31 DOWNTO 0 );
        Result : OUT UNSIGNED ( 15 DOWNTO 0 )
    );
END UnclockedSquareRoot;


ARCHITECTURE behavioral OF UnclockedSquareRoot IS
BEGIN 
   PROCESS (ValueIn)
   VARIABLE vop: UNSIGNED ( in_width - 1  DOWNTO  0 );  
   VARIABLE vres: UNSIGNED ( in_width - 1  DOWNTO  0 );  
   VARIABLE vone: UNSIGNED ( in_width - 1  DOWNTO  0 );  
   BEGIN 

      vone := TO_UNSIGNED ( 2 ** ( in_width - 2 ), in_width);
      vop := UNSIGNED (ValueIn);
      vres := ( OTHERS => '0' ); 

      WHILE (vone /= 0 ) LOOP 
         IF (vop >= vres + vone) THEN
            vop := vop - (vres + vone);
            vres := vres / 2 + vone;
         ELSE 
            vres := vres / 2 ;
         END IF ;
         vone := vone / 4 ;
      END  LOOP ;
      Result <= UNSIGNED (vres (Result 'RANGE));
   END  PROCESS ;
END ARCHITECTURE behavioral;