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
USE work.ipbus.ALL;

USE work.FunkyMiniBus.ALL;
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
ENTITY IPbusToFunkyMiniBus IS
  PORT(
    ipbus_clk : IN STD_LOGIC := '0'; --! The IPbus clock
    ipbus_rst : IN STD_LOGIC := '0';
    ipbus_in  : IN ipb_wbus  := IPB_WBUS_NULL;
    ipbus_out : OUT ipb_rbus := IPB_RBUS_NULL;
    BusIn     : OUT tFMBus;
    BusOut    : IN tFMBus;
    BusClk    : OUT STD_LOGIC := '0'
  );
END IPbusToFunkyMiniBus;
-- -------------------------------------------------------------------------

-- -------------------------------------------------------------------------
ARCHITECTURE rtl OF IPbusToFunkyMiniBus IS
  SIGNAL ack                                                        : STD_LOGIC                       := '0';
  SIGNAL InfoSpaceSize                                              : INTEGER RANGE 0 TO 511          := 0;
  SIGNAL InfoSpaceAddr                                              : INTEGER RANGE 0 TO 2047         := 0;
  SIGNAL VectorInfoSpace                                            : tStdLogicInfoSpace( 0 TO 2047 ) := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL Counters                                                   : tStdLogicInfoSpace( 0 TO 15 )   := ( OTHERS => ( OTHERS => '0' ) );
  SIGNAL Instruction                                                : tFMBusState                     := Ignore;
  SIGNAL DataIn , DataOut                                           : STD_LOGIC_VECTOR( 31 DOWNTO 0 ) := ( OTHERS => '0' );
  SIGNAL InstructionValid , DataInValid , DataOutPop , Ready , Done : BOOLEAN                         := FALSE;
  SIGNAL StdLogicReady , StdLogicDataOutPop                         : STD_LOGIC                       := '0';

BEGIN

  FMBusMasterInstance : ENTITY Work.FMBusMaster
  PORT MAP(
    Clk              => ipbus_clk ,

    BusIn            => BusIn ,
    BusOut           => BusOut ,
    BusClk           => BusClk ,

    VectorInfoSpace  => VectorInfoSpace ,
    InfoSpaceSize    => InfoSpaceSize ,

    InstructionIn    => Instruction ,
    InstructionValid => InstructionValid ,
    Counters         => Counters ,

    DataIn           => DataIn ,
    DataInValid      => DataInValid ,

    DataOut          => DataOut ,
    DataOutPop       => DataOutPop ,

    Ready            => Ready ,
    Done             => Done
  );

  InfoSpaceAddr      <= TO_INTEGER( UNSIGNED( ipbus_in.ipb_addr( 10 DOWNTO 0 ) ) );
  ipbus_out.ipb_err  <= '0';
  ipbus_out.ipb_ack  <= ack;

  StdLogicReady      <= '1' WHEN Ready ELSE '0';
  StdLogicDataOutPop <= '1' WHEN DataOutPop ELSE '0';

  prc : PROCESS( ipbus_clk )
  BEGIN
    IF RISING_EDGE( ipbus_clk ) THEN

      Instruction         <= Ignore;
      InstructionValid    <= FALSE;
      DataInValid         <= FALSE;
      DataOutPop          <= FALSE;
      ack                 <= '0';
      DataIn              <= ( OTHERS => '0' );
      ipbus_out.ipb_rdata <= ( OTHERS => '0' );

      IF ipbus_in.ipb_strobe = '1' AND ack = '0' THEN
        CASE ipbus_in.ipb_addr( 13 DOWNTO 11 ) IS
-- -------------------------------------------------------------------------
          WHEN "000" =>
            ack              <= '1';
            Instruction      <= tFMBusState'VAL( TO_INTEGER( UNSIGNED( ipbus_in.ipb_wdata( 2 DOWNTO 0 ) ) ) );
            InstructionValid <= ( ipbus_in.ipb_write='1' );
-- -------------------------------------------------------------------------
          WHEN "001" =>
            ack                 <= '1';
            ipbus_out.ipb_rdata <= STD_LOGIC_VECTOR( TO_UNSIGNED( InfoSpaceSize , 32 ) );
-- -------------------------------------------------------------------------
          WHEN "010" =>
            ack                 <= '1';
            ipbus_out.ipb_rdata <= VectorInfoSpace( InfoSpaceAddr );
-- -------------------------------------------------------------------------
          WHEN "011" =>
            IF ipbus_in.ipb_write='1' THEN
              DataIn      <= ipbus_in.ipb_wdata;
              DataInValid <= Ready AND NOT DataInValid;
              IF Done THEN
                ack <= '1';
              END IF;
            ELSE
              DataOutPop          <= TRUE;
              ipbus_out.ipb_rdata <= DataOut;
              ack                 <= '1';
            END IF;
          WHEN "100" =>
            ack                 <= '1';
            ipbus_out.ipb_rdata <= Counters( InfoSpaceAddr );
          WHEN "101" | "110" | "111" =>
            ack <= '1';
-- -------------------------------------------------------------------------
          WHEN OTHERS => -- COVERS THE "UNDEFINED" STD_LOGIC STATES
            NULL;
-- -------------------------------------------------------------------------
        END CASE;

      END IF;

    END IF;
  END PROCESS;

END rtl;
