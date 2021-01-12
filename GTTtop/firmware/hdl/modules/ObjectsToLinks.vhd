
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
    if VertexPipeIn(0)(0).DataValid then
      linksOut(0).data(7 downto 0) <= std_logic_vector(VertexPipeIn(0)(0).Z0);
      linksOut(0).data(23 downto 8) <= std_logic_vector(VertexPipeIn(0)(0).Weight);
      linksOut(0).valid <= '1';
      linksOut(0).start <= '0';
      linksOut(0).strobe <= '1';
    else
      linksOut(0).data <= (others => '0');
      linksOut(0).start <= '0';
      linksOut(0).strobe <= '1';
      linksOut(0).valid <= '0';
    END IF;

    if METPipeIn(0)(0).DataValid then
      linksOut(1).data(15 downto 0) <= std_logic_vector(METPipeIn(0)(0).Et);
      linksOut(1).valid <= '1';
      linksOut(1).start <= '0';
      linksOut(1).strobe <= '1';

      linksOut(2).data(15 downto 0) <= std_logic_vector(METPipeIn(0)(0).Px);
      linksOut(2).valid <= '1';
      linksOut(2).start <= '0';
      linksOut(2).strobe <= '1';

      linksOut(3).data(15 downto 0) <= std_logic_vector(METPipeIn(0)(0).Py);
      linksOut(3).valid <= '1';
      linksOut(3).start <= '0';
      linksOut(3).strobe <= '1';
    else
      linksOut(1).data <= (others => '0');
      linksOut(1).start <= '0';
      linksOut(1).strobe <= '1';
      linksOut(1).valid <= '0';
      linksOut(2).data <= (others => '0');
      linksOut(2).start <= '0';
      linksOut(2).strobe <= '1';
      linksOut(2).valid <= '0';
      linksOut(3).data <= (others => '0');
      linksOut(3).start <= '0';
      linksOut(3).strobe <= '1';
      linksOut(3).valid <= '0';
    end if;
  end if;
end process;

end Behavioral;
