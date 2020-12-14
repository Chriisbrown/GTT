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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

--library GBDT;
use work.Types.all;
use work.Constants.all;

entity ValidOutput is
  generic(
    FileName : string := "ValidOutput.txt";
    FilePath : string := "./"
  );
  port(
    clk    : in std_logic;
    y : in std_logic := '0';
    v : in boolean := false
  );
end ValidOutput;
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
architecture rtl of ValidOutput is
begin
-- pragma synthesis_off
  process(clk)
    file f     : text open write_mode is FilePath & FileName;
    variable s : line;
  begin
  if rising_edge(clk) then
    if v then
      write(s, y, right, 10);
      write(s, string'(" "), right, 1);
      writeline( f , s );
    end if;
  end if;
  end process;
-- pragma synthesis_on    
end architecture rtl;
