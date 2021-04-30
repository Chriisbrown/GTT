LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


library xil_defaultlib;
use xil_defaultlib.emp_data_types.all;
use xil_defaultlib.gtt_interface_pkg;

LIBRARY GTT;
USE GTT.GTTconfig.ALL;
USE GTT.GTTDataFormats.ALL;
--library work;
--use work.emp_data_types.all;

LIBRARY TTTrack;
USE TTTrack.DataType;
USE TTTrack.ArrayTypes;

LIBRARY InTTTrack;
USE InTTTrack.DataType;
USE InTTTrack.ArrayTypes;

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
  clk : in std_logic;
  VertexPipeIn : in Vertex.ArrayTypes.VectorPipe;
  METPipeIn : in Et.ArrayTypes.VectorPipe;
  linksOut : out gtt_interface_pkg.link_array  
);
end ObjectsToLinks;

architecture Behavioral of ObjectsToLinks is


  
begin

process(clk)
begin
  if rising_edge(clk) THEN
    if VertexPipeIn(0)(0).DataValid then
      linksOut(0).data(          VertexZ0Width - 1 downto 0) <= std_logic_vector(VertexPipeIn(0)(0).Z0);
      linksOut(0).data(PtWidth + VertexZ0Width - 1 downto VertexZ0Width) <= std_logic_vector(VertexPipeIn(0)(0).Weight);
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
      linksOut(1).data(                               METMagWidth - 1 downto 0)                         <= std_logic_vector(METPipeIn(0)(0).Et);
      linksOut(1).data(                 METMagWidth + METPhiWidth - 1 downto METMagWidth)               <= std_logic_vector(METPipeIn(0)(0).Phi);
      linksOut(1).data(METNtrackWidth + METMagWidth + METPhiWidth - 1 downto METMagWidth + METPhiWidth) <= std_logic_vector(METPipeIn(0)(0).NumTracks);
      linksOut(1).valid <= '1';
      linksOut(1).start <= '0';
      linksOut(1).strobe <= '1';

    else
      linksOut(1).data <= (others => '0');
      linksOut(1).start <= '0';
      linksOut(1).strobe <= '1';
      linksOut(1).valid <= '0';
    end if;

  end if;
end process;

end Behavioral;
