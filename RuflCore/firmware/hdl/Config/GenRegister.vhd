-- #########################################################################
-- #########################################################################
-- ###                                                                   ###
-- ###   Use of this code, whether in its current form or modified,      ###
-- ###   implies that you consent to the terms and conditions, namely:   ###
-- ###    - You acknowledge my contribution                              ###
-- ###    - This copyright notification remains intact                   ###
-- ###                                                                   ###
-- ###   Many thanks,                                                    ###
-- ###     Dr. Andrew W. Rose, Imperial College London, 2018             ###
-- ###                                                                   ###
-- #########################################################################
-- #########################################################################

-- -------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;

USE work.FunkyMiniBus.ALL;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ENTITY GenRegister IS
  GENERIC(
          DefaultValue : INTEGER := 0;
          Registering  : INTEGER := 0;
          BusName      : STRING
         );
  PORT(
        DataOut : OUT STD_LOGIC_VECTOR;
        BusIn   : IN tFMBus;
        BusOut  : OUT tFMBus;
        BusClk  : IN STD_LOGIC := '0'
      );
END ENTITY GenRegister;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF GenRegister IS

  CONSTANT WidthOut : INTEGER := DataOut'LENGTH;

  TYPE mem_type IS ARRAY( 0 TO Registering ) OF STD_LOGIC_VECTOR( WidthOut -1 DOWNTO 0 );

  SHARED VARIABLE REG           : mem_type                                  := ( OTHERS => STD_LOGIC_VECTOR( TO_SIGNED( DefaultValue , WidthOut ) ) );

-- -------------------------------------------------------------------------
-- FMBus Signals
-- -------------------------------------------------------------------------
  SIGNAL FMBusWrite , FMBusRead : STD_LOGIC_VECTOR( WidthOut - 1 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL FMBusWriteEnable       : STD_LOGIC                                 := '0';
  SIGNAL FMBusClock             : STD_LOGIC                                 := '0';
-- -------------------------------------------------------------------------

BEGIN

  FMBusRegDecoderInstance : ENTITY work.FMBusRegDecoder
  GENERIC MAP(
    BusName => BusName
  )
  PORT MAP(
    BusIn     => BusIn ,
    BusOut    => BusOut ,
    BusClk    => BusClk ,
    ClkOut    => FMBusClock ,
    DataOut   => FMBusWrite ,
    DataIn    => FMBusRead ,
    DataValid => FMBusWriteEnable
  );

-- ConfigBus port
  PROCESS( FMBusClock )
  BEGIN
    IF RISING_EDGE( FMBusClock ) THEN

      IF Registering > 0 THEN
        FOR i IN Registering - 1 DOWNTO 0 LOOP -- REG IS A VARIABLE! ORDERING IS IMPORTANT!
          REG( i + 1 ) := REG( i );
        END LOOP;
      END IF;

      IF( FMBusWriteEnable = '1' ) THEN
          REG( 0 ) := FMBusWrite;
      END IF;
      FMBusRead <= REG( 0 );
    END IF;
  END PROCESS;

-- LUT port
  DataOut <= REG( Registering );

END ARCHITECTURE rtl;
