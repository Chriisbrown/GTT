library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

package Constants is

  constant feature_integer_multiplier : integer := 128;
  
  constant nFeatures : integer := 21;
  constant nClasses : integer := 1;
  
  constant NN_bit_width : integer := 16;

  subtype tx is signed(19 downto 0); --14 7
  subtype ty is signed(19 downto 0); --14 7

  function to_tx(x : integer) return tx;
  function to_ty(y : integer) return ty;

  function to_boolean(x: std_logic) return boolean;
  function to_std_logic(x: boolean) return std_logic;

end package;

package body Constants is

  function to_tx(x : integer) return tx is
  begin
    return to_signed(x, tx'length);
  end to_tx;

  function to_ty(y : integer) return ty is
  begin
    return to_signed(y, ty'length);
  end to_ty;

  function to_boolean(x: std_logic) return boolean is
    begin
      if x = '1' then
      return(true);
    else
      return(false);
    end if;
  end function to_boolean;

  function to_std_logic(x: boolean) return std_logic is
    begin
      if x then
      return('1');
    else
      return('0');
    end if;
  end function to_std_Logic;

end package body;
