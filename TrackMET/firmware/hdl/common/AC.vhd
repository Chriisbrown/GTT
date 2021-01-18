LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

ENTITY AC is
    port (clk, reset : in std_logic;
          Et  : IN Vector( 0 TO 17 );
          SumEx : OUT INTEGER;
          SumEy : OUT INTEGER
    );
END ENTITY AC;

architecture behavioral of AC is

    FUNCTION SumPx (EtVector : Vector) return Integer IS
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
  
    FUNCTION SumPy (EtVector : Vector) return Integer IS
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
    
    signal s_px,s_py,s_sumx,s_sumy : INTEGER;
    
    begin

        s_px <= SumPx(Et);
        s_py <= SumPy(Et);

    process(clk) is

      variable input_px,input_py : INTEGER := 0;
      variable sumx,sumy : INTEGER := 0;

    begin
        if rising_edge(clk) THEN
            if reset THEN
                sumx := 0;
                sumy := 0;
            else
                sumx := input_px + sumx;
                sumy := input_py + sumy;
            end if;

            s_sumx <= sumx;
            s_sumy <= sumy;

            input_px := s_px;
            input_py := s_py;

        end if;
    end process;

    SumEx <= s_sumx;
    SumEy <= s_sumy;
    
end architecture behavioral;