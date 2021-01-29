LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

LIBRARY ET;
USE ET.DataType.ALL;
USE ET.ArrayTypes.ALL;

LIBRARY TrackMET;
USE TrackMET.constants.all;

ENTITY AC IS
    PORT (clk, reset : IN std_logic := '0';
          Et    : IN EtArray := ( OTHERS => ( OTHERS => '0' ) );
          SumEx : OUT SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
          SumEy : OUT SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0')
    );
END ENTITY AC;

ARCHITECTURE behavioral OF AC IS

    FUNCTION SumPx (EtVector : EtArray) RETURN SIGNED IS
    VARIABLE temp_px : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    BEGIN
      FOR i IN 0 TO 17 LOOP
        temp_px := temp_px + EtVector( i );
      END LOOP;
  
    RETURN temp_px; 
    END FUNCTION SumPx;
  
    FUNCTION SumPy (EtVector : EtArray) RETURN SIGNED IS
    VARIABLE temp_py : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    BEGIN
      FOR i IN 18 TO 35 LOOP
        temp_py := temp_py + EtVector( i );
      END LOOP;
  
    RETURN temp_py;
    END FUNCTION SumPy;
    
    SIGNAL signal_px   : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL signal_py   : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL signal_sumx : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL signal_sumy : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL Et_Buffer   : EtArray := ( OTHERS => ( OTHERS => '0' ) );

    SIGNAL temp_sumx : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL temp_sumy : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL input_px  : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    SIGNAL input_py  : SIGNED( 15 DOWNTO 0 ) := (OTHERS => '0');
    
    BEGIN

        Et_Buffer <= Et;  --Buffer to give more slack for timing

        signal_px <= SumPx(Et_Buffer);
        signal_py <= SumPy(Et_Buffer);

    PROCESS( clk ) IS


    BEGIN
        IF RISING_EDGE(clk) THEN
            IF reset THEN
                temp_sumx <= (OTHERS => '0');
                temp_sumy <= (OTHERS => '0');
                input_px  <= (OTHERS => '0');
                input_py  <= (OTHERS => '0');
            ELSE
                temp_sumx <= input_px + temp_sumx;
                temp_sumy <= input_py + temp_sumy;
            END IF;

            signal_sumx <= temp_sumx;
            signal_sumy <= temp_sumy;

            input_px <= signal_px;
            input_py <= signal_py;

        END IF;
    END PROCESS;

    SumEx <= signal_sumx;
    SumEy <= signal_sumy;
    
END ARCHITECTURE behavioral;