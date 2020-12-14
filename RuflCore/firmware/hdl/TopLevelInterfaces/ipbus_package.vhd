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
-- -------------------------------------------------------------------------


-- -------------------------------------------------------------------------
PACKAGE ipbus IS

-- The signals going from master to slaves - parallel bus
  TYPE ipb_wbus IS
    RECORD
      ipb_addr   : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      ipb_wdata  : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      ipb_strobe : STD_LOGIC;
      ipb_write  : STD_LOGIC;
    END RECORD;

  TYPE ipb_wbus_array IS ARRAY( NATURAL RANGE <> ) OF ipb_wbus;

-- The signals going from slaves to master - parallel bus
  TYPE ipb_rbus IS
    RECORD
      ipb_rdata : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      ipb_ack   : STD_LOGIC;
      ipb_err   : STD_LOGIC;
    END RECORD;

  TYPE ipb_rbus_array IS ARRAY( NATURAL RANGE <> ) OF ipb_rbus;

  CONSTANT IPB_RBUS_NULL   : ipb_rbus := ( ( OTHERS => '0' ) , '0' , '0' );
  CONSTANT IPB_WBUS_NULL   : ipb_wbus := ( ( OTHERS => '0' ) , ( OTHERS => '0' ) , '0' , '0' );

-- Daisy-chain bus

-- Phase = 00: select phase (ipb_ad(4:0) is slave number, ipb_flag asserted to select new slave)
-- Phase = 01: address phase (ipb_ad is address, ipb_flag is write)
-- Phase = 10: wdata phase (ipb_ad is wdata)
-- Phase = 11: rdata phase (ipb_ad is rdata, ipb_flag is ack/nerr)

  CONSTANT IPBDC_SEL_WIDTH : INTEGER  := 5;

  TYPE ipbdc_bus IS
    RECORD
      phase : STD_LOGIC_VECTOR( 1 DOWNTO 0 );
      ad    : STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      flag  : STD_LOGIC;
    END RECORD;

  TYPE ipbdc_bus_array IS ARRAY( NATURAL RANGE <> ) OF ipbdc_bus;

  CONSTANT IPBDC_BUS_NULL : ipbdc_bus := ( "00" , ( OTHERS => '0' ) , '0' );

-- For top-level generics

  TYPE ipb_mac_cfg IS( EXTERNAL , INTERNAL );
  TYPE ipb_ip_cfg IS( EXTERNAL , INTERNAL );

END ipbus;
