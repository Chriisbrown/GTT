LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

ENTITY AC IS
    PORT (clk, reset : IN std_logic := '0';
          Et  : IN Vector( 0 TO 17 ) :=  ET.ArrayTypes.NullVector( 18 );
          SumEx : OUT INTEGER := 0;
          SumEy : OUT INTEGER := 0
    );
END ENTITY AC;

ARCHITECTURE behavioral OF AC IS

    FUNCTION SumPx (EtVector : Vector) RETURN Integer IS
    VARIABLE temp_px : INTEGER := 0;
    BEGIN
      FOR i IN EtVector'RANGE LOOP
        IF EtVector( i ).DataValid THEN
          temp_px := temp_px + TO_INTEGER(EtVector( i ).Px);
        ELSE
          temp_px := temp_px;
        END IF;
      END LOOP;
  
    RETURN temp_px; 
    END FUNCTION SumPx;
  
    FUNCTION SumPy (EtVector : Vector) RETURN Integer IS
    VARIABLE temp_py : INTEGER := 0;
    BEGIN
      FOR i IN EtVector'RANGE LOOP
        IF EtVector( i ).DataValid THEN
          temp_py := temp_py + TO_INTEGER(EtVector( i ).Py);
        ELSE
          temp_py := temp_py;
        END IF;
      END LOOP;
  
    RETURN temp_py;
    END FUNCTION SumPy;
    
    SIGNAL signal_px,signal_py,s_sumx,s_sumy : INTEGER := 0;
    SIGNAL Et_Buffer : Vector( 0 TO 17 ) := ET.ArrayTypes.NullVector( 18 );
    
    
    BEGIN

        Et_Buffer <= Et;  --Buffer to give more slack for timing

        s_px <= SumPx(Et_Buffer);
        s_py <= SumPy(Et_Buffer);

    PROCESS( clk ) IS

      VARIABLE temp_sumx,temp_sumy : INTEGER := 0;
      VARIABLE input_px,input_py : INTEGER := 0;

    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset THEN
                temp_sumx := 0;
                temp_sumy := 0;
            ELSE
                temp_sumx := input_px + sumx;
                temp_sumy := input_py + sumy;
            END IF;

            signal_sumx <= temp_sumx;
            signal_sumy <= temp_sumy;

            input_px := signal_sumx;
            input_py := signal_sumy;

        END IF;
    END PROCESS;

    SumEx <= signal_sumx;
    SumEy <= signal_sumy;
    
END ARCHITECTURE behavioral;