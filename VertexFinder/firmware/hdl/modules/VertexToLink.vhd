-- .library VertexFinder

-- .include TopLevelInterfaces/mp7_data_types.vhd
-- .include TopLevelInterfaces/PkgInterfaces.vhd
-- .include ReuseableElements/PkgArrayTypes.vhd in Interfaces
-- .include ReuseableElements/Debugger.vhd in Interfaces

-- -------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;

--library Interfaces;
--use Interfaces.DataType;
--use Interfaces.ArrayTypes;

library Vertex;
use Vertex.DataType.all;
use Vertex.ArrayTypes;

library Utilities;
use Utilities.Utilities.all;

Entity VertexToLink is
port(
  clk : in std_logic := '0';
  VertexPipeIn : in Vertex.ArrayTypes.VectorPipe;
  linksOut : out ldata  
);
end VertexToLink;

architecture Behavioral of VertexToLink is

-- synthesis translate off
  -- A second copy of the links in the Debug compatible format
  --signal linksOutInt : Interfaces.ArrayTypes.Vector(0 downto 0) := Interfaces.ArrayTypes.NullVector(1);
-- synthesis translate on
  
begin

-- If the data is valid then first send a header (data valid, empty data)
-- On the next cycle send the valid data
process(clk)
begin
  if VertexPipeIn(0)(0).DataValid then
    linksOut(0).data(bitloc.z0h downto bitloc.z0l) <= std_logic_vector(VertexPipeIn(0)(0).Z0);
    linksOut(0).data(bitloc.weighth downto bitloc.weightl) <= std_logic_vector(VertexPipeIn(0)(0).Weight);
    linksOut(0).data( 24 ) <= to_std_logic(VertexPipeIn(0)(0).DataValid);
    linksOut(0).valid <= '1';
    linksOut(0).start <= '0';
    linksOut(0).strobe <= '1';
  else
    linksOut(0).data <= (others => '0');
    linksOut(0).start <= '0';
    linksOut(0).strobe <= '1';
    linksOut(0).valid <= '0';
  end if;
end process;

-- synthesis translate off
--linksOutInt(0).data <= linksOut(0);
--linksOutInt(0).DataValid <= to_boolean(linksOut(0).valid);

-- Write the debug information to file
--DebugInstance : ENTITY Interfaces.Debug
--GENERIC MAP( "LinksOut" )
--PORT MAP( clk, linksOutInt );
-- synthesis translate on

end Behavioral;
