LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;

USE work.vx_data_format.ALL;
USE work.ExtHist;
USE work.ExtSLV3;
USE work.ExtSL;
LIBRARY reusable;
USE reusable.DataPipe;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY MiniHisto IS
GENERIC(
  NBINS     : INTEGER := 8;
  registers : BOOLEAN := false
);
PORT(
  clk  : IN STD_LOGIC;
  rst  : IN STD_LOGIC := '0';
  itrk : IN trk;
  max  : OUT ExtHist.DataType := ExtHist.cNullData
);
END MiniHisto;

ARCHITECTURE Behavioral OF MiniHisto IS


CONSTANT pipelength : INTEGER := 3;
SUBTYPE slv3 IS STD_LOGIC_VECTOR( 2 DOWNTO 0 );
-- Data
SIGNAL mem        : ExtHist.Pipe( NBINS - 1 DOWNTO 0 )    := ExtHist.NullPipe( NBINS );
--signal mem : HistArray(NBINS - 1 downto 0) := (others => emptyHistData);
SIGNAL di         : ExtHist.DataType                      := emptyHistData;
SIGNAL do         : HistData                              := emptyHistData;
SIGNAL iHist      : ExtHist.DataType                      := ExtHist.cNullData;
SIGNAL ihist_pipe : ExtHist.Pipe( pipelength-1 DOWNTO 0 ) := ExtHist.NullPipe( pipelength );
SIGNAL incr       : HistData                              := emptyHistData;
SIGNAL incr_pipe  : ExtHist.Pipe( 3 DOWNTO 0 )            := ExtHist.NullPipe( 4 );
--signal max : ExtHist.DataType := ExtHist.cNullData; -- the maximum bin

-- Addresses
SIGNAL raddr      : ExtSLV3.DataType                      := ( OTHERS => '0' );
SIGNAL waddr      : ExtSLV3.DataType                      := ( OTHERS => '0' );
SIGNAL addr_pipe  : ExtSLV3.Pipe( 4 DOWNTO 0 )            := ExtSLV3.NullPipe( 5 );

-- Write Enable
SIGNAL we_pipe    : ExtSL.Pipe( pipelength-1 DOWNTO 0 )   := ExtSL.NullPipe( pipelength );

BEGIN

raddr     <= STD_LOGIC_VECTOR( itrk.z0( 2 DOWNTO 0 ) ); --addr_pipe(pipelength-1);
waddr     <= addr_pipe( 2 );
di.pt2    <= incr.pt2;
iHist.pt2 <= itrk.pt;

AddrPipe : ENTITY reusable.DataPipe
GENERIC MAP( Types => ExtSLV3 )
PORT MAP(
  clk      => clk ,
  DataIn   => raddr ,
  DataPipe => addr_pipe
);

WePipe : ENTITY reusable.DataPipe
GENERIC MAP( Types => ExtSL )
PORT MAP(
  clk      => clk ,
  DataIn   => itrk.valid ,
  DataPipe => we_pipe
);

-- Pipeline of values incoming
iHistPipe : ENTITY reusable.DataPipe
GENERIC MAP( Types => ExtHist )
PORT MAP(
  clk      => clk ,
  DataIn   => iHist ,
  DataPipe => ihist_pipe
);

-- Pipeline of values written to Histogram
incrPipe : ENTITY reusable.DataPipe
GENERIC MAP( Types => ExtHist )
PORT MAP(
  clk      => clk ,
  DataIn   => incr ,
  DataPipe => incr_pipe
);

mem_gen : IF NOT registers GENERATE
PROCESS( clk )
BEGIN
  IF( RISING_EDGE( clk ) ) THEN
-- Memory process
-- write
    IF( we_pipe( 2 ) = '1' ) THEN
      mem( TO_INTEGER( UNSIGNED( addr_pipe( 2 ) ) ) ) <= di;
    END IF;
-- read
    do <= mem( TO_INTEGER( UNSIGNED( raddr ) ) );

-- Increment process
    IF( addr_pipe( 1 ) = addr_pipe( 2 ) ) THEN
      incr.pt2 <= ihist_pipe( 1 ) .pt2 + incr_pipe( 0 ) .pt2;
    ELSIF( addr_pipe( 1 ) = addr_pipe( 3 ) ) THEN
      incr.pt2 <= ihist_pipe( 1 ) .pt2 + incr_pipe( 1 ) .pt2;
    ELSIF( addr_pipe( 1 ) = addr_pipe( 4 ) ) THEN
      incr.pt2 <= ihist_pipe( 1 ) .pt2 + incr_pipe( 2 ) .pt2;
    ELSE
      incr.pt2 <= ihist_pipe( 1 ) .pt2 + do.pt2;
    END IF;

-- Accumulate maximum process
    max.pt2 <= maximum( max.pt2 , incr.pt2 );
  END IF;
END PROCESS;
END GENERATE;

register_gen : IF registers GENERATE
PROCESS( clk )
BEGIN
  IF( RISING_EDGE( clk ) ) THEN
-- Memory process
    mem( TO_INTEGER( UNSIGNED( addr_pipe( 0 ) ) ) ) .pt2 <= mem( TO_INTEGER( UNSIGNED( addr_pipe( 0 ) ) ) ) .pt2 + ihist_pipe( 0 ) .pt2;
-- Accumulate maximum process
    max.pt2                                              <= maximum( max.pt2 , incr.pt2 );
  END IF;
END PROCESS;
END GENERATE;

END Behavioral;
