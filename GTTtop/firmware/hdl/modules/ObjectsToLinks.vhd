
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;

library Vertex;
use Vertex.DataType.all;
use Vertex.ArrayTypes;

LIBRARY Et;
USE Et.DataType;
USE Et.ArrayTypes;

library Utilities;
use Utilities.Utilities.all;

Entity ObjectsToLinks is
port(
  clk : in std_logic := '0';
  VertexPipeIn : in Vertex.ArrayTypes.VectorPipe;
  METPipeIn : in Et.ArrayTypes.VectorPipe;
  linksOut : out ldata  
);
end ObjectsToLinks;

architecture Behavioral of ObjectsToLinks is

-- synthesis translate off
  -- A second copy of the links in the Debug compatible format
  --signal linksOutInt : Interfaces.ArrayTypes.Vector(0 downto 0) := Interfaces.ArrayTypes.NullVector(1);
-- synthesis translate on

  
begin

-- If the data is valid then first send a header (data valid, empty data)
-- On the next cycle send the valid data
process(clk)

  VARIABLE VertexZ0 : UNSIGNED( 7 DOWNTO 0 ) := ( OTHERS => '0');
  VARIABLE VertexWeight : UNSIGNED( 15 DOWNTO 0 ) := ( OTHERS => '0');
  VARIABLE MET : UNSIGNED( 15 DOWNTO 0) := ( OTHERS => '0');

  VARIABLE RecievedVertex : BOOLEAN := FALSE;
  VARIABLE RecievedMET : BOOLEAN := FALSE;
begin
  if rising_edge(clk) THEN
    if VertexPipeIn(0)(0).DataValid and VertexPipeIn(0)(0).FrameValid then
      RecievedVertex := TRUE;
      VertexZ0 := VertexPipeIn(0)(0).Z0;
      VertexWeight := VertexPipeIn(0)(0).Weight;
    else
      RecievedVertex := RecievedVertex;
      VertexZ0 := VertexZ0;
      VertexWeight := VertexWeight;
    END IF;

    if METPipeIn(0)(0).DataValid and METPipeIn(0)(0).FrameValid then
      RecievedMET := TRUE;
      MET := METPipeIn(0)(0).Et;
    else
      RecievedMET := RecievedMET;
      MET := MET;
    END IF;

    if (RecievedVertex) AND (RecievedMET) then
      linksOut(0).data(7 downto 0) <= std_logic_vector(VertexZ0);
      linksOut(0).data(23 downto 8) <= std_logic_vector(VertexWeight);
      linksOut(0).data(39 downto 24) <= std_logic_vector(MET);
      linksOut(0).valid <= '1';
      linksOut(0).start <= '0';
      linksOut(0).strobe <= '1';
      RecievedMET := FALSE;
      RecievedVertex := FALSE;

    else
      linksOut(0).data <= (others => '0');
      linksOut(0).start <= '0';
      linksOut(0).strobe <= '1';
      linksOut(0).valid <= '0';
    end if;
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
